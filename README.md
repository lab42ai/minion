<div align="center">
 <h1>minion: Personal AI Agent</h1>
 <p>
   <img src="https://img.shields.io/badge/python-≥3.11-blue" alt="Python">
   <img src="https://img.shields.io/badge/license-MIT-green" alt="License">
 </p>
</div>


🦾 **minion** is a personal AI agent that works for you across Telegram, Discord, WhatsApp, and Slack. It runs locally or in the cloud, connects to any LLM provider, and handles tasks autonomously with tools, memory, and scheduled jobs.


## Install


```bash
curl -sSL https://raw.githubusercontent.com/lab42ai/minion/main/install.sh | bash
```


Then run the setup wizard:


```bash
minion setup
```


## Update


```bash
minion update
```


## Features


- Multi-channel chat (Telegram, Discord, WhatsApp, Slack, CLI)
- Any LLM provider — cloud (Anthropic, OpenAI, OpenRouter) or local (LM Studio, Ollama)
- Tool use with parallel execution
- Persistent memory (file-based + vector search)
- Background subagents for long-running tasks
- Scheduled jobs (cron) and periodic heartbeat
- Security pipeline — input/output guards, YARA rules, URL scanning
- Document parsing (PDF, DOCX, PPTX, XLSX, CSV)
- RAG retrieval with hybrid search (BM25 + vector)
- Code interpreter (Docker sandbox)
- MCP (Model Context Protocol) for external tool servers
- ReAct mode for models without native function calling
- Extensible skills system


## Slash Commands


| Command | Description |
|---------|-------------|
| `/help` | List available commands |
| `/export [format]` | Export conversation (markdown, json, text) |
| `/context` | Show token usage and context window info |
| `/models [ref]` | List models or switch provider |
| `/discard` | Reset session without saving memories |


## Documentation


See the [full documentation](https://github.com/lab42ai/minion/wiki) for detailed setup and configuration guides.




