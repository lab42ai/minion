# Configuration

All configuration lives in `~/.minion/minion.json`. The installer creates a default config. You can edit it directly or use `minion setup` for guided configuration.

## Full Config Reference

```json
{
  "models": {
    "providers": {
      "lmstudio": {
        "baseUrl": "http://127.0.0.1:1234/v1",
        "apiKey": "lm-studio",
        "api": "openai",
        "models": [
          {
            "id": "qwen3-coder-next",
            "name": "Qwen3 Coder Next",
            "reasoning": false,
            "input": ["text"],
            "contextWindow": 20000,
            "maxTokens": 4096
          }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "workspace": "~/.minion/workspace",
      "model": {
        "primary": "lmstudio/qwen3-coder-next"
      },
      "fallbacks": [],
      "maxTokens": 8192,
      "temperature": 0.6,
      "timezone": "America/New_York",
      "maxToolIterations": 5
    },
    "subagentProfiles": {}
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "allowFrom": ["your-telegram-user-id"],
      "proxy": null
    },
    "discord": {
      "enabled": false,
      "token": "",
      "allowFrom": []
    },
    "whatsapp": {
      "enabled": false,
      "bridgeUrl": "ws://localhost:3001",
      "allowFrom": []
    },
    "slack": {
      "enabled": false,
      "botToken": "",
      "appToken": "",
      "allowFrom": []
    }
  },
  "gateway": {
    "host": "127.0.0.1",
    "port": 7777
  },
  "tools": {
    "web": {
      "search": {
        "apiKey": "BRAVE_API_KEY",
        "tavilyApiKey": "TAVILY_API_KEY",
        "maxResults": 5
      }
    },
    "browser": {
      "enabled": false,
      "phantomUrl": "ws://127.0.0.1:9222",
      "autoLaunch": true,
      "timeout": 30,
      "maxChars": 50000
    },
    "exec": {
      "timeout": 60
    },
    "offload": {
      "enabled": true,
      "thresholdTokens": 500,
      "thresholdBytes": 2000,
      "maxPreviewTokens": 150,
      "storageDir": ".artifacts",
      "retentionDays": 7
    },
    "restrictToWorkspace": false,
    "trace": {
      "enabled": false,
      "dir": "traces",
      "maxInlineChars": 2000,
      "capturePrompt": false,
      "llmPreviewChars": 600
    }
  },
  "security": {
    "enabled": true,
    "inputGuardEnabled": true,
    "outputGuardEnabled": true,
    "mlPromptInjectionEnabled": false
  },
  "heartbeat": {
    "enabled": true,
    "intervalS": 7200
  },
  "memory": {
    "enabled": true,
    "dbPath": "~/.minion/memory/memories.db",
    "embeddingModel": "text-embedding-nomic-embed-text-v1.5",
    "extractionModel": "",
    "maxMemories": 1000,
    "compactionThreshold": 50,
    "checkpointInterval": 300
  },
  "session": {
    "retentionDays": 30,
    "maxSessions": 1000,
    "cleanupOnStartup": true
  },
  "usage": {
    "dailyBudgetUsd": 0.0,
    "monthlyBudgetUsd": 0.0,
    "warnAtPercent": 80
  }
}
```

## Key Settings

### Model (`agents.defaults.model.primary`)

Format: `provider/model-id`

Examples:
- `lmstudio/qwen3-coder-next` - Local model via LM Studio
- `anthropic/claude-sonnet-4-5` - Anthropic cloud
- `openai/gpt-4o` - OpenAI cloud
- `openrouter/meta-llama/llama-4-maverick` - OpenRouter

See [Model Configuration](Model-Configuration) for full provider setup.

### Max Tool Iterations (`agents.defaults.maxToolIterations`)

How many tool calls the agent can make per message before stopping. Lower = cheaper but less capable for complex tasks. Default: 20. Set to 5 if you want to keep API costs low.

### Temperature (`agents.defaults.temperature`)

Controls randomness. Lower (0.3) = more focused, higher (0.8) = more creative. Default: 0.7.

### Browser (`tools.browser.enabled`)

Browser tool is included but still being tested. **Set to `false`** (default) unless you're ready to experiment with it. When enabled, it launches a headless Chromium browser for web interaction.

### Restrict to Workspace (`tools.restrictToWorkspace`)

When `true`, file operations (read, write, edit, list) are sandboxed to the workspace directory only. Default: `false`.

## API Keys (`.env`)

API keys go in `~/.minion/.env`, not in `minion.json`:

```bash
# LLM providers
ANTHROPIC_API_KEY=sk-ant-...
OPENAI_API_KEY=sk-...
OPENROUTER_API_KEY=sk-or-...

# Chat channels
TELEGRAM_BOT_TOKEN=123456:ABC...
DISCORD_BOT_TOKEN=...

# Web search (optional but recommended)
BRAVE_API_KEY=BSA...
TAVILY_API_KEY=tvly-...
```

The `minion.json` field `"apiKey": "BRAVE_API_KEY"` means "read from the environment variable `BRAVE_API_KEY`". The actual key lives in `.env`.
