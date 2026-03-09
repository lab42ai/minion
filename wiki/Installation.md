# Installation

## Requirements

- Python 3.11+
- macOS or Linux (Windows via WSL)
- An LLM provider (cloud API key or local model server)

## Install

```bash
curl -sSL https://raw.githubusercontent.com/lab42ai/minion/main/install.sh | bash
```

This installs minion to `~/.minion/` with its own Python virtual environment. Nothing outside `~/.minion/` and `~/.local/bin/minion` is touched.

What the installer does:
- Finds Python >= 3.11 on your system
- Creates a venv at `~/.minion/venv/`
- Downloads the latest release wheel from GitHub
- Installs optional packages (PDF, DOCX, PPTX parsing, MCP)
- Creates a CLI wrapper at `~/.local/bin/minion`
- Sets up the workspace directory structure
- Creates default config and `.env` template

## Post-Install

Make sure `~/.local/bin` is in your PATH:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Add this to your `~/.bashrc` or `~/.zshrc` if it's not there already.

## Setup Wizard

Run the interactive setup:

```bash
minion setup
```

This walks you through:
- Your name and timezone
- Choosing an LLM provider and model
- Adding API keys
- Enabling chat channels (Telegram, Discord, etc.)
- Configuring heartbeat interval

## Verify

```bash
# Single message test
minion agent -m "Hello, what can you do?"

# Interactive chat
minion agent
```

## File Structure After Install

```
~/.minion/
  minion.json          # Main configuration
  .env                 # API keys and secrets
  .installed_version   # Current version tag
  venv/                # Python virtual environment
  workspace/
    SOUL.md            # Agent personality
    AGENTS.md          # Agent instructions
    USER.md            # User profile
    TOOLS.md           # Tool documentation
    HEARTBEAT.md       # Periodic tasks
    memory/
      MEMORY.md        # Long-term memory
      *.md             # Daily notes (YYYY-MM-DD.md)
    skills/            # Custom skills (you create these)
    exports/           # Exported conversations
  sessions/            # Conversation history (JSONL)
  logs/                # Runtime logs
```

## Updating

```bash
minion update
```

Downloads and installs the latest release. Your config, workspace, memories, and sessions are never touched.

Check for updates without installing:

```bash
minion update --check
```
