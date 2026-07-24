#!/usr/bin/env node
/**
 * Dependency-free stdio MCP server for the local AILANG CLI.
 *
 * Codex installs plugins directly from their Git source. Keeping this server on
 * Node's standard library avoids a hidden network-dependent `npm install` on
 * first launch.
 */

import { spawn } from 'node:child_process';
import { existsSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { createInterface } from 'node:readline';
import { fileURLToPath } from 'node:url';

const packageJson = JSON.parse(
  readFileSync(new URL('./package.json', import.meta.url), 'utf8'),
);

const PROTOCOL_VERSION = '2025-03-26';
const DEFAULT_TIMEOUT_MS = 30_000;
const packageRoot = fileURLToPath(new URL('..', import.meta.url));
const bundledAilang = resolve(
  packageRoot,
  'bin',
  process.platform === 'win32' ? 'ailang.exe' : 'ailang',
);
const ailangCommand =
  process.env.AILANG_BIN || (existsSync(bundledAilang) ? bundledAilang : 'ailang');

const tools = [
  {
    name: 'ailang_prompt',
    description:
      'Get the AILANG teaching prompt with current syntax rules and templates. This is the source of truth for AILANG syntax; call it before writing AILANG code.',
    inputSchema: {
      type: 'object',
      properties: {},
      additionalProperties: false,
    },
  },
  {
    name: 'ailang_check',
    description: 'Type-check an AILANG file without running it.',
    inputSchema: {
      type: 'object',
      properties: {
        file: { type: 'string', description: 'Path to the .ail file to check' },
      },
      required: ['file'],
      additionalProperties: false,
    },
  },
  {
    name: 'ailang_run',
    description: 'Run an AILANG program with specified capabilities.',
    inputSchema: {
      type: 'object',
      properties: {
        file: { type: 'string', description: 'Path to the .ail file to run' },
        caps: {
          type: 'string',
          default: 'IO',
          description: 'Comma-separated capabilities: IO,FS,Net,Clock,AI',
        },
        entry: {
          type: 'string',
          default: 'main',
          description: 'Entry point function name',
        },
        ai_stub: {
          type: 'boolean',
          default: false,
          description: 'Use the AI stub for testing',
        },
      },
      required: ['file'],
      additionalProperties: false,
    },
  },
  {
    name: 'ailang_builtins',
    description:
      'List AILANG builtin functions with their current documentation.',
    inputSchema: {
      type: 'object',
      properties: {
        search: {
          type: 'string',
          description: 'Optional case-insensitive term used to filter output',
        },
        by_module: {
          type: 'boolean',
          default: true,
          description: 'Group builtins by module',
        },
        verbose: {
          type: 'boolean',
          default: true,
          description: 'Show full builtin documentation',
        },
      },
      additionalProperties: false,
    },
  },
  {
    name: 'ailang_eval',
    description: 'Evaluate one expression in a non-interactive AILANG REPL.',
    inputSchema: {
      type: 'object',
      properties: {
        expression: {
          type: 'string',
          description: 'AILANG expression to evaluate',
        },
      },
      required: ['expression'],
      additionalProperties: false,
    },
  },
];

class AilangCommandError extends Error {
  constructor(message, output = '') {
    super(message);
    this.name = 'AilangCommandError';
    this.output = output;
  }
}

function commandOutput(stdout, stderr) {
  return [stderr.trim(), stdout.trim()].filter(Boolean).join('\n');
}

function runAilang(args, { input, timeoutMs = DEFAULT_TIMEOUT_MS } = {}) {
  return new Promise((resolve, reject) => {
    const child = spawn(ailangCommand, args, {
      cwd: process.cwd(),
      env: process.env,
      stdio: ['pipe', 'pipe', 'pipe'],
    });

    let stdout = '';
    let stderr = '';
    let timedOut = false;

    const timer = setTimeout(() => {
      timedOut = true;
      child.kill('SIGTERM');
    }, timeoutMs);

    child.stdout.setEncoding('utf8');
    child.stderr.setEncoding('utf8');
    child.stdout.on('data', (chunk) => {
      stdout += chunk;
    });
    child.stderr.on('data', (chunk) => {
      stderr += chunk;
    });

    child.on('error', (error) => {
      clearTimeout(timer);
      if (error.code === 'ENOENT') {
        reject(
          new AilangCommandError(
            'AILANG CLI not found on PATH. Install it with: curl -fsSL https://ailang.sunholo.com/install.sh | bash',
          ),
        );
        return;
      }
      reject(new AilangCommandError(error.message));
    });

    child.on('close', (code) => {
      clearTimeout(timer);
      const output = commandOutput(stdout, stderr);
      if (timedOut) {
        reject(
          new AilangCommandError(
            `ailang command timed out after ${timeoutMs}ms`,
            output,
          ),
        );
      } else if (code !== 0) {
        reject(
          new AilangCommandError(
            `ailang exited with status ${code}`,
            output,
          ),
        );
      } else {
        resolve(output);
      }
    });

    if (input !== undefined) {
      child.stdin.end(input);
    } else {
      child.stdin.end();
    }
  });
}

function requireString(args, name) {
  if (typeof args?.[name] !== 'string' || args[name].length === 0) {
    throw new AilangCommandError(`Missing required string argument: ${name}`);
  }
  return args[name];
}

function filterOutput(text, search) {
  if (!search) return text;
  const query = search.toLocaleLowerCase();
  const matches = text
    .split('\n')
    .filter((line) => line.toLocaleLowerCase().includes(query));
  return matches.join('\n') || 'No matches found';
}

async function callTool(name, args = {}) {
  switch (name) {
    case 'ailang_prompt':
      return runAilang(['prompt']);

    case 'ailang_check':
      return runAilang(['check', requireString(args, 'file')]);

    case 'ailang_run': {
      const commandArgs = [
        'run',
        '--caps',
        typeof args.caps === 'string' ? args.caps : 'IO',
        '--entry',
        typeof args.entry === 'string' ? args.entry : 'main',
      ];
      if (args.ai_stub === true) commandArgs.push('--ai-stub');
      commandArgs.push(requireString(args, 'file'));
      return runAilang(commandArgs);
    }

    case 'ailang_builtins': {
      const commandArgs = ['builtins', 'list'];
      if (args.verbose !== false) commandArgs.push('--verbose');
      if (args.by_module !== false) commandArgs.push('--by-module');
      const output = await runAilang(commandArgs);
      return filterOutput(output, args.search);
    }

    case 'ailang_eval':
      return runAilang(['repl', '--non-interactive'], {
        input: `${requireString(args, 'expression')}\n`,
        timeoutMs: 10_000,
      });

    default:
      throw new AilangCommandError(`Unknown tool: ${name}`);
  }
}

function success(id, result) {
  return { jsonrpc: '2.0', id, result };
}

function failure(id, code, message, data) {
  return {
    jsonrpc: '2.0',
    id,
    error: {
      code,
      message,
      ...(data ? { data } : {}),
    },
  };
}

async function handleRequest(message) {
  if (message.method === 'initialize') {
    return success(message.id, {
      protocolVersion: PROTOCOL_VERSION,
      capabilities: { tools: { listChanged: false } },
      serverInfo: {
        name: 'ailang-tools',
        version: packageJson.version,
      },
    });
  }

  if (message.method === 'tools/list') {
    return success(message.id, { tools });
  }

  if (message.method === 'tools/call') {
    try {
      const text = await callTool(
        message.params?.name,
        message.params?.arguments,
      );
      return success(message.id, {
        content: [{ type: 'text', text: text || 'No output' }],
      });
    } catch (error) {
      const messageText =
        error instanceof Error ? error.message : String(error);
      const detail =
        error instanceof AilangCommandError && error.output
          ? `${messageText}\n${error.output}`
          : messageText;
      return success(message.id, {
        content: [{ type: 'text', text: detail }],
        isError: true,
      });
    }
  }

  if (message.id === undefined) return null;
  return failure(message.id, -32601, `Method not found: ${message.method}`);
}

async function main() {
  const lines = createInterface({
    input: process.stdin,
    crlfDelay: Infinity,
  });

  console.error('AILANG MCP Server running');
  for await (const line of lines) {
    if (!line.trim()) continue;
    let response;
    try {
      response = await handleRequest(JSON.parse(line));
    } catch (error) {
      response = failure(
        null,
        -32700,
        'Parse error',
        error instanceof Error ? error.message : String(error),
      );
    }
    if (response) process.stdout.write(`${JSON.stringify(response)}\n`);
  }
}

if (
  process.argv[1] &&
  resolve(process.argv[1]) === fileURLToPath(import.meta.url)
) {
  main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
}

export { callTool, handleRequest, tools };
