# Telegram Setup

Telegram is the easiest channel to set up. You need a bot token from BotFather.

## Step 1: Create a Bot

1. Open Telegram and search for `@BotFather`
2. Send `/newbot`
3. Choose a name (e.g., "My Minion")
4. Choose a username (must end in `bot`, e.g., `my_minion_bot`)
5. BotFather gives you a token like `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`

## Step 2: Get Your User ID

You need your Telegram user ID to restrict who can talk to the bot.

1. Search for `@userinfobot` on Telegram
2. Send it any message
3. It replies with your user ID (a number like `8281248569`)

## Step 3: Configure

Add the bot token to `~/.minion/.env`:

```bash
TELEGRAM_BOT_TOKEN=123456789:ABCdefGHIjklMNOpqrsTUVwxyz
```

Enable Telegram in `~/.minion/minion.json`:

```json
{
  "channels": {
    "telegram": {
      "enabled": true,
      "allowFrom": ["8281248569"]
    }
  }
}
```

**`allowFrom`** is a list of Telegram user IDs that are allowed to chat with your bot. If empty (`[]`), anyone can use it — not recommended for a personal agent.

## Step 4: Start the Gateway

```bash
minion arise
```

You should see:
```
Telegram channel started
Gateway listening on 127.0.0.1:7777
```

Now open Telegram, find your bot, and send `/start`. Then chat normally.

## Optional: Proxy

If you're behind a firewall or in a region where Telegram is blocked:

```json
{
  "channels": {
    "telegram": {
      "enabled": true,
      "allowFrom": ["8281248569"],
      "proxy": "socks5://user:pass@proxy-host:1080"
    }
  }
}
```

## What Works

- Text messages
- Photos (with captions)
- Voice messages (transcribed)
- Audio files
- Documents (PDF, DOCX, etc. — parsed and fed to the agent)
- Slash commands (`/export`, `/context`, `/models`, `/discard`)

## Running as a Service

To keep minion running in the background:

```bash
# Using tmux
tmux new -s minion
minion arise
# Ctrl+B, D to detach

# Using systemd (Linux)
# Create /etc/systemd/system/minion.service
[Unit]
Description=minion AI agent
After=network.target

[Service]
User=your-username
ExecStart=/home/your-username/.local/bin/minion arise
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```
