# Tracing

Tracing lets you inspect exactly what the agent does: every LLM call, tool execution, and decision. Useful for debugging, optimizing prompts, and understanding agent behavior.

**Disabled by default.** Enable it when you need to debug.

## Configuration

```json
{
  "tools": {
    "trace": {
      "enabled": false,
      "dir": "traces",
      "maxInlineChars": 2000,
      "capturePrompt": false,
      "llmPreviewChars": 600
    }
  }
}
```

| Field | Default | Description |
|-------|---------|-------------|
| `enabled` | `false` | Enable/disable tracing |
| `dir` | `"traces"` | Directory for trace files (relative to workspace) |
| `maxInlineChars` | 2000 | Max chars to inline in trace (longer content is offloaded) |
| `capturePrompt` | `false` | Capture the full system prompt in traces |
| `llmPreviewChars` | 600 | How much of LLM responses to preview in the trace |

## Enabling Tracing

Set `enabled: true` in your config:

```json
{
  "tools": {
    "trace": {
      "enabled": true
    }
  }
}
```

Restart the gateway (`minion restart` or `minion arise`).

## Trace Output

Traces are written to `~/.minion/workspace/traces/` as JSON files. Each conversation turn produces a trace with:

- **LLM calls**: Model, messages sent, response received, token counts
- **Tool calls**: Tool name, arguments, result, execution time
- **Decisions**: Which tools were selected and why

## When to Use

- **Debugging**: Agent isn't using the right tool, or giving wrong answers
- **Prompt tuning**: See exactly what's in the system prompt (enable `capturePrompt`)
- **Cost analysis**: See token counts per turn
- **Skill development**: Verify a skill is loading and triggering correctly

## Tips

- Keep `capturePrompt: false` unless you specifically need to see the full system prompt (it's large).
- Traces can grow large. Check the `traces/` directory periodically and clean up old files.
- Disable tracing in production to avoid unnecessary disk I/O.
