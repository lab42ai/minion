# CLI Reference

All minion commands.

## Core Commands

| Command | Description |
|---------|-------------|
| `minion arise` | Start the gateway (channels + heartbeat + cron) |
| `minion stop` | Stop the gateway |
| `minion restart` | Restart the gateway |
| `minion status` | Show config, providers, and usage |

## Chat

| Command | Description |
|---------|-------------|
| `minion agent` | Interactive chat mode |
| `minion agent -m "..."` | Send a single message |
| `minion agent -m "..." --model lmstudio/qwen3` | Use a specific model |

## Setup

| Command | Description |
|---------|-------------|
| `minion setup` | Interactive setup wizard |
| `minion update` | Update to latest version |
| `minion update --check` | Check for updates without installing |

## Sessions

| Command | Description |
|---------|-------------|
| `minion sessions` | List conversation sessions |
| `minion cleanup` | Clean up old sessions and artifacts |

## Memory

| Command | Description |
|---------|-------------|
| `minion memory stats` | Show memory counts and statistics |
| `minion memory search "query"` | Search memories by text |

## Cron

| Command | Description |
|---------|-------------|
| `minion cron list` | List scheduled jobs |

## Channels

| Command | Description |
|---------|-------------|
| `minion channels login` | Authenticate WhatsApp (scan QR) |
