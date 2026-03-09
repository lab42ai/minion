# Tools

minion comes with a set of built-in tools. All tools are available by default unless noted.

## Core Tools

### File Operations

| Tool | Description |
|------|-------------|
| `read_file(path)` | Read file contents |
| `write_file(path, content)` | Write/create a file |
| `edit_file(path, old_text, new_text)` | Replace text in a file |
| `list_dir(path)` | List directory contents |

Files are relative to the workspace (`~/.minion/workspace/`) by default. Set `tools.restrictToWorkspace: true` in config to enforce this.

### Shell Execution

| Tool | Description |
|------|-------------|
| `exec(command, working_dir)` | Run a shell command |

- Timeout: configurable (`tools.exec.timeout`, default 60s)
- Dangerous commands are blocked (rm -rf, format, dd, shutdown, etc.)
- Output truncated at 10,000 characters

### Web

| Tool | Description |
|------|-------------|
| `web_search(query, count)` | Search the web (Brave/Tavily) |
| `web_fetch(url, extractMode)` | Fetch and extract content from a URL |

Requires at least one search API key in `.env` (BRAVE_API_KEY or TAVILY_API_KEY).

All web content passes through the security pipeline:
- URLs checked against maltrail threat intelligence
- Content scanned by YARA rules
- Results scanned by output guard

### Communication

| Tool | Description |
|------|-------------|
| `message(content, channel, chat_id)` | Send a message to a different channel |

Use this to send messages to a different channel than the one the user is chatting on. For example, if the user is on CLI but wants results delivered to Telegram.

### Background Tasks

| Tool | Description |
|------|-------------|
| `spawn(task, label)` | Run a task in a background subagent |

Spawns an independent agent that works on the task and reports back when done. Good for long-running operations that shouldn't block the conversation.

### Scheduling

| Tool | Description |
|------|-------------|
| `cron(action, message, ...)` | Create/list/remove scheduled jobs |

See [Cron & Heartbeat](Cron-and-Heartbeat) for details.

## Browser Tool

**Status: Experimental. Disabled by default.**

A headless browser for interacting with web pages (clicking, filling forms, extracting dynamic content).

```json
{
  "tools": {
    "browser": {
      "enabled": false,
      "phantomUrl": "ws://127.0.0.1:9222",
      "autoLaunch": true,
      "timeout": 30,
      "maxChars": 50000
    }
  }
}
```

Set `enabled: true` only if you want to test it. It requires a Chromium-based browser with remote debugging enabled.

## Result Offloading

When tool results are large (long file contents, big web pages), minion offloads them to a file and gives the agent a preview instead. This keeps the context window clean.

```json
{
  "tools": {
    "offload": {
      "enabled": true,
      "thresholdTokens": 500,
      "thresholdBytes": 2000,
      "maxPreviewTokens": 150,
      "storageDir": ".artifacts",
      "retentionDays": 7
    }
  }
}
```

The agent can read the full content from the artifact file when needed. Artifacts are cleaned up after `retentionDays`.

## Adding Tool Documentation

If you want to give the agent extra context about how to use tools, edit `~/.minion/workspace/TOOLS.md`. This is loaded into the system prompt.

See [Workspace Files](Workspace-Files) for details.
