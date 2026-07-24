import assert from 'node:assert/strict';
import { spawn } from 'node:child_process';
import { chmod, mkdtemp, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { delimiter, join } from 'node:path';
import test from 'node:test';

const serverPath = new URL('../server.js', import.meta.url);

function runServer(messages, env = process.env) {
  return new Promise((resolve, reject) => {
    const child = spawn(process.execPath, [serverPath.pathname], {
      env,
      stdio: ['pipe', 'pipe', 'pipe'],
    });
    let stdout = '';
    let stderr = '';

    child.stdout.setEncoding('utf8');
    child.stderr.setEncoding('utf8');
    child.stdout.on('data', (chunk) => {
      stdout += chunk;
    });
    child.stderr.on('data', (chunk) => {
      stderr += chunk;
    });
    child.on('error', reject);
    child.on('close', (code) => {
      if (code !== 0) {
        reject(new Error(`server exited ${code}: ${stderr}`));
        return;
      }
      resolve(
        stdout
          .trim()
          .split('\n')
          .filter(Boolean)
          .map((line) => JSON.parse(line)),
      );
    });

    child.stdin.end(
      `${messages.map((message) => JSON.stringify(message)).join('\n')}\n`,
    );
  });
}

test('initializes and advertises all AILANG tools without npm dependencies', async () => {
  const responses = await runServer([
    {
      jsonrpc: '2.0',
      id: 1,
      method: 'initialize',
      params: {
        protocolVersion: '2025-03-26',
        capabilities: {},
        clientInfo: { name: 'test', version: '1' },
      },
    },
    { jsonrpc: '2.0', id: 2, method: 'tools/list', params: {} },
  ]);

  assert.equal(responses[0].result.serverInfo.name, 'ailang-tools');
  assert.deepEqual(
    responses[1].result.tools.map((tool) => tool.name),
    [
      'ailang_prompt',
      'ailang_check',
      'ailang_run',
      'ailang_builtins',
      'ailang_eval',
    ],
  );
});

test('reports a clear installation error when ailang is absent from PATH', async () => {
  const emptyPath = await mkdtemp(join(tmpdir(), 'ailang-mcp-empty-path-'));
  try {
    const responses = await runServer(
      [
        {
          jsonrpc: '2.0',
          id: 1,
          method: 'tools/call',
          params: { name: 'ailang_prompt', arguments: {} },
        },
      ],
      { ...process.env, PATH: emptyPath },
    );

    assert.equal(responses[0].result.isError, true);
    assert.match(responses[0].result.content[0].text, /CLI not found on PATH/);
    assert.match(responses[0].result.content[0].text, /install\.sh/);
  } finally {
    await rm(emptyPath, { recursive: true, force: true });
  }
});

test('passes arguments without shell interpolation', async () => {
  const mockPath = await mkdtemp(join(tmpdir(), 'ailang-mcp-mock-path-'));
  const mockAilang = join(mockPath, 'ailang');
  try {
    await writeFile(
      mockAilang,
      '#!/bin/sh\nprintf "%s\\n" "$@"\n',
      'utf8',
    );
    await chmod(mockAilang, 0o755);

    const responses = await runServer(
      [
        {
          jsonrpc: '2.0',
          id: 1,
          method: 'tools/call',
          params: {
            name: 'ailang_check',
            arguments: { file: 'file; echo unsafe.ail' },
          },
        },
      ],
      {
        ...process.env,
        PATH: `${mockPath}${delimiter}${process.env.PATH ?? ''}`,
      },
    );

    assert.equal(responses[0].result.isError, undefined);
    assert.equal(
      responses[0].result.content[0].text,
      'check\nfile; echo unsafe.ail',
    );
  } finally {
    await rm(mockPath, { recursive: true, force: true });
  }
});
