# Workspace Files

The workspace (`~/.minion/workspace/`) contains markdown files that shape how your minion behaves. These are loaded into the system prompt at the start of every conversation.

Think of these files as "programming your agent in English."

## SOUL.md - Personality & Values

Defines who your minion *is*. This sets the tone for every interaction.

```markdown
# Soul

I am minion, a personal AI assistant.

## Personality

- Direct and helpful
- Proactive about suggesting next steps
- Honest when unsure

## Values

- User privacy first
- Quality over speed
- Security-conscious with web content

## Communication Style

- Keep responses concise unless asked for detail
- Use bullet points for lists
- Suggest next actions after completing tasks
```

**Tips:**
- Keep it short. Every token here is consumed on every message.
- Focus on what makes your agent *different* from a generic chatbot.
- The model already knows how to be helpful — tell it what's unique about working for *you*.

## AGENTS.md - Instructions & Behavior

Defines what your minion *does*. This is the operational manual.

```markdown
# Agent Instructions

You are minion, a personal AI assistant.

## Guidelines

- Always explain what you're doing before taking actions
- Ask for clarification when the request is ambiguous
- Remember important information in your memory files
- Be proactive about scheduling recurring tasks

## Tools Available

You have access to:
- **File operations** (read_file, write_file, edit_file, list_dir)
- **Shell commands** (exec)
- **Web access** (web_search, web_fetch)
- **Messaging** (message)
- **Background tasks** (spawn)
- **Scheduling** (cron)

## Memory

- Use `memory/` directory for daily notes
- Use `MEMORY.md` for long-term facts about the user

## Scheduled Reminders

When user asks for a reminder, use the cron tool:
- Parse the time from their message
- Create a cron job that delivers the reminder
```

**Tips:**
- List the tools you want the agent to know about — it helps it decide which tool to use.
- Include workflow examples for common tasks.
- Don't repeat what SOUL.md already says.

## USER.md - User Profile

Information about *you* that helps the agent personalize responses.

```markdown
# User Profile

## Basic Information

- **Name**: Alex
- **Timezone**: America/New_York
- **Language**: English

## Preferences

- Communication: Technical and concise
- Response length: Brief unless I ask for detail

## Work Context

- **Role**: Software Engineer
- **Stack**: Python, TypeScript, PostgreSQL
- **Tools**: VS Code, Docker, GitHub
```

**Tips:**
- Fill in your actual details — the agent uses these.
- The timezone matters for cron jobs and time-aware responses.
- Work context helps the agent give relevant technical answers.

## TOOLS.md - Tool Documentation

Extra documentation about available tools. The agent already knows the tool signatures, but this file lets you add context, examples, and notes.

```markdown
# Available Tools

## File Operations

### read_file
Read the contents of a file.
read_file(path: str) -> str

### write_file
Write content to a file (creates parent directories if needed).
write_file(path: str, content: str) -> str

### edit_file
Edit a file by replacing specific text.
edit_file(path: str, old_text: str, new_text: str) -> str

## Web Access

### web_search
Search the web. Results are scanned by the security pipeline.
web_search(query: str, count: int = 5) -> str

### web_fetch
Fetch and extract content from a URL.
web_fetch(url: str, extractMode: str = "markdown") -> str
```

**Tips:**
- You don't *need* to document every tool — only add notes for tools that need extra context.
- Good place to add "when to use X vs Y" guidance.

## HEARTBEAT.md - Periodic Tasks

Checked on a regular interval (configured in `heartbeat.intervalS`, default 7200 seconds = 2 hours). The agent reads this file and executes any active tasks.

```markdown
# Heartbeat Tasks

## Active Tasks

- [ ] Check for new GitHub notifications and summarize
- [ ] Read the daily news from Hacker News front page
- [ ] Check if any cron jobs failed and report

## Completed

- [x] Set up morning routine notifications
```

**Tips:**
- Use checkbox format (`- [ ]` for active, `- [x]` for done).
- If this file is empty or has no active tasks, the heartbeat is skipped (saves tokens).
- The agent can modify this file itself — it might mark tasks complete or add new ones.
- Set `heartbeat.enabled: false` in config to disable entirely.

## memory/MEMORY.md - Long-Term Memory

The agent reads and writes to this file to remember things across sessions. This is the file-based memory (separate from the vector memory database).

```markdown
# Memory

## User Preferences
- Prefers dark mode
- Uses vim keybindings
- Coffee order: oat milk latte

## Project Notes
- Main project repo: ~/projects/myapp
- Database runs on port 5433 (not default)

## Important Dates
- Team standup: Mon/Wed/Fri 10am
```

**Tips:**
- The agent will add to this file as it learns about you.
- You can also edit it directly to seed information.
- Keep it organized — the agent reads the whole file every session.

## memory/YYYY-MM-DD.md - Daily Notes

Auto-created by the agent for daily notes and observations. Each day gets its own file (e.g., `memory/2026-03-08.md`). The agent reads the last 7 days of notes for context.

You generally don't edit these yourself — the agent manages them.
