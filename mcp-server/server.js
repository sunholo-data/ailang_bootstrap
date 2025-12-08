#!/usr/bin/env node
/**
 * AILANG MCP Server
 * Provides AILANG tools via the Model Context Protocol
 */

import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { z } from 'zod';
import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);

// Create the MCP server
const server = new McpServer({
  name: 'ailang-tools',
  version: '0.5.6',
});

// Helper to run AILANG CLI commands
async function runAilang(args) {
  try {
    const { stdout, stderr } = await execAsync(`ailang ${args}`, {
      timeout: 30000,
      maxBuffer: 1024 * 1024,
    });
    return stdout || stderr;
  } catch (error) {
    return error.stderr || error.message;
  }
}

// Tool: Get the teaching prompt (SOURCE OF TRUTH for syntax)
server.tool(
  'ailang_prompt',
  'Get the AILANG teaching prompt with current syntax rules and templates. This is the SOURCE OF TRUTH for AILANG syntax - ALWAYS call this before writing ANY AILANG code. Do not guess at syntax.',
  {},
  async () => {
    const result = await runAilang('prompt');
    return {
      content: [{ type: 'text', text: result }],
    };
  }
);

// Tool: Type-check a file
server.tool(
  'ailang_check',
  'Type-check an AILANG file without running it. Returns any type errors found.',
  {
    file: z.string().describe('Path to the .ail file to check'),
  },
  async ({ file }) => {
    const result = await runAilang(`check "${file}"`);
    return {
      content: [{ type: 'text', text: result }],
    };
  }
);

// Tool: Run a program
server.tool(
  'ailang_run',
  'Run an AILANG program with specified capabilities.',
  {
    file: z.string().describe('Path to the .ail file to run'),
    caps: z.string().optional().default('IO').describe('Comma-separated capabilities: IO,FS,Net,Clock,AI'),
    entry: z.string().optional().default('main').describe('Entry point function name'),
    ai_stub: z.boolean().optional().default(false).describe('Use AI stub for testing'),
  },
  async ({ file, caps, entry, ai_stub }) => {
    const stubFlag = ai_stub ? '--ai-stub' : '';
    const result = await runAilang(`run --caps ${caps} --entry ${entry} ${stubFlag} "${file}"`);
    return {
      content: [{ type: 'text', text: result }],
    };
  }
);

// Tool: List builtins (SOURCE OF TRUTH for stdlib documentation)
server.tool(
  'ailang_builtins',
  'List AILANG builtin functions with full documentation. This is the SOURCE OF TRUTH for stdlib - always use this for accurate, current documentation including parameters, return types, and examples.',
  {
    search: z.string().optional().describe('Optional search term to filter builtins (e.g., "httpGet", "array")'),
    by_module: z.boolean().optional().default(true).describe('Group by module (default: true)'),
    verbose: z.boolean().optional().default(true).describe('Show full documentation with examples (default: true)'),
  },
  async ({ search, by_module, verbose }) => {
    let cmd = 'builtins list';
    if (verbose) cmd += ' --verbose';
    if (by_module) cmd += ' --by-module';
    if (search) cmd += ` | grep -A 15 -i "${search}"`;
    const result = await runAilang(cmd);
    return {
      content: [{ type: 'text', text: result || 'No matches found' }],
    };
  }
);

// Tool: Evaluate expression in REPL
server.tool(
  'ailang_eval',
  'Evaluate a single expression in the AILANG REPL context.',
  {
    expression: z.string().describe('AILANG expression to evaluate'),
  },
  async ({ expression }) => {
    try {
      const { stdout, stderr } = await execAsync(`echo '${expression.replace(/'/g, "\\'")}' | ailang repl --non-interactive`, {
        timeout: 10000,
      });
      return {
        content: [{ type: 'text', text: stdout || stderr || 'No output' }],
      };
    } catch (error) {
      return {
        content: [{ type: 'text', text: `Error: ${error.message}` }],
      };
    }
  }
);

// Start the server
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error('AILANG MCP Server running');
}

main().catch(console.error);
