# Slash Commands

Slash commands are intercepted before the message reaches the LLM — they cost zero tokens and work on all channels (Telegram, Discord, WhatsApp, Slack, CLI).

## Available Commands

### /help

List all available slash commands.

```
/help
```

### /export [format]

Export the current conversation to a file. Supported formats: `markdown` (default), `json`, `text`.

```
/export           # Export as markdown
/export json      # Export as JSON
/export text      # Export as plain text
```

Files are saved to `~/.minion/workspace/exports/` with a timestamped filename.

### /context

Show token usage, context window info, and learning stats.

```
/context
```

Output:

```
Context Information

Session: telegram:8281248569
Messages: 24 total (12 user, 12 assistant)

Model: lmstudio/qwen3-coder-next
Context Window: 20,000 tokens
History Tokens: ~8,500 (42.5% of window)
Available: ~11,500 tokens
Usage: [████████░░░░░░░░░░░░] 42.5%

Token Usage (Today)
- Requests: 42
- Input tokens: 85,200
- Output tokens: 12,300
- Cost: $0.0000

Memory & Learning
- Stored memories: 47
- Feedback (7d): 123 turns, avg score +0.31
- Signals: 28 positive, 89 neutral, 4 corrections, 2 repetitions
```

### /models [ref]

List configured providers and models, or switch the active model.

```
/models                              # List all providers and models
/models lmstudio/qwen3-coder-next   # Switch to a model
/models anthropic/claude-sonnet-4-5  # Switch to Claude
```

When you switch, the change is applied immediately and persisted to `minion.json`.

### /discard

Clear the current session without saving any memories. Use when a conversation went off track and you don't want the agent to remember it.

```
/discard
```

This clears message history but does not affect long-term memory or daily notes that were already saved.
