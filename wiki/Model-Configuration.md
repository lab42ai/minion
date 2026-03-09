# Model Configuration

minion works with any LLM that speaks the OpenAI chat completions API. This includes cloud providers (Anthropic, OpenAI, OpenRouter) and local servers (LM Studio, Ollama).

## How It Works

1. Define providers in `models.providers`
2. Set the active model in `agents.defaults.model.primary`
3. Format: `provider-name/model-id`

## Local Models

### LM Studio

[LM Studio](https://lmstudio.ai/) runs models locally with an OpenAI-compatible API.

1. Download and install LM Studio
2. Load a model (recommended: Qwen3-Coder or similar with good tool use)
3. Start the local server (default port 1234)
4. Set the context window in LM Studio settings (recommend 32K if your GPU has enough VRAM)

Config:

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
            "contextWindow": 32000,
            "maxTokens": 4096
          }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "lmstudio/qwen3-coder-next"
      }
    }
  }
}
```

**Model recommendations for LM Studio:**
- **Qwen3-Coder-Next** (80B MoE, IQ1_S quant, ~19GB) — excellent tool use
- Avoid models that are weak at multi-step function calling (e.g., smaller Qwen 2.5 models struggle with tool chains)

**`contextWindow`**: Must match what you set in LM Studio's model settings. If your model is loaded with 8K context in LM Studio but you set 32K here, requests will fail.

### Ollama

[Ollama](https://ollama.com/) is another local model runner.

```json
{
  "models": {
    "providers": {
      "ollama": {
        "baseUrl": "http://127.0.0.1:11434/v1",
        "apiKey": "ollama",
        "api": "openai",
        "models": [
          {
            "id": "llama3.1:70b",
            "name": "Llama 3.1 70B",
            "reasoning": false,
            "input": ["text"],
            "contextWindow": 8192,
            "maxTokens": 2048
          }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "ollama/llama3.1:70b"
      }
    }
  }
}
```

### Remote LM Studio / Ollama

If your model server runs on a different machine (e.g., a GPU server):

```json
"baseUrl": "http://192.168.1.100:1234/v1"
```

Make sure the port is accessible from the machine running minion.

## Cloud Providers

### Anthropic (Claude)

```json
{
  "models": {
    "providers": {
      "anthropic": {
        "apiKey": "ANTHROPIC_API_KEY"
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "anthropic/claude-sonnet-4-5"
      }
    }
  }
}
```

Add key to `~/.minion/.env`:
```
ANTHROPIC_API_KEY=sk-ant-api03-...
```

### OpenAI

```json
{
  "models": {
    "providers": {
      "openai": {
        "apiKey": "OPENAI_API_KEY"
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "openai/gpt-4o"
      }
    }
  }
}
```

### OpenRouter

[OpenRouter](https://openrouter.ai/) gives you access to many models through a single API key.

```json
{
  "models": {
    "providers": {
      "openrouter": {
        "apiKey": "OPENROUTER_API_KEY"
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "openrouter/anthropic/claude-sonnet-4-5"
      }
    }
  }
}
```

## Switching Models at Runtime

Use the `/models` slash command in any chat:

```
/models                              # List all configured providers and models
/models lmstudio/qwen3-coder-next   # Switch to a specific model
/models anthropic/claude-sonnet-4-5  # Switch to Claude
```

This updates both the running agent and persists to `minion.json`.

## ReAct Mode (for models without native tool use)

Some models don't support function calling natively. Set `toolCallFormat` to `"react"` to use a text-based Thought/Action/Observation loop instead:

```json
{
  "agents": {
    "defaults": {
      "toolCallFormat": "react"
    }
  }
}
```

When set to `"auto"` (default), minion uses native function calling. Only switch to `"react"` if your model doesn't handle tool calls properly.

## Provider Config Fields

| Field | Required | Description |
|-------|----------|-------------|
| `baseUrl` | For local | API endpoint URL |
| `apiKey` | Yes | API key or env var name |
| `api` | For local | Set to `"openai"` for OpenAI-compatible servers |
| `models` | For local | Array of model definitions |
| `models[].id` | Yes | Model identifier (matches what the server expects) |
| `models[].contextWindow` | Yes | Max context window in tokens |
| `models[].maxTokens` | No | Max output tokens per response |
| `models[].reasoning` | No | Whether the model uses reasoning/thinking tokens |
| `models[].input` | No | Supported input types (`["text"]` or `["text", "image"]`) |
