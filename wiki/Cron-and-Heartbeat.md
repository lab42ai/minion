# Cron & Heartbeat

minion has two systems for recurring work: cron jobs (user-scheduled) and heartbeat (periodic file check).

## Cron Jobs

Schedule reminders or recurring tasks from any chat. The agent uses the `cron` tool.

### Creating Jobs

From chat, ask naturally:

```
"Remind me to stretch every 20 minutes"
"Check Hacker News front page every hour"
"Send me a weather update every morning at 8am"
```

Or use the tool directly:

```
cron(action="add", message="Time to stretch!", every_seconds=1200)
cron(action="add", message="Check HN front page", cron_expr="0 * * * *")
cron(action="add", message="Morning weather", cron_expr="0 8 * * *")
```

### Two Modes

1. **Reminder**: The message is sent directly to you as-is.
2. **Task**: The message is a task description — the agent executes it and sends the result.

The agent decides which mode to use based on the message content. "Remind me to..." = reminder. "Check..." or "Run..." = task.

### Managing Jobs

```
cron(action="list")                    # See all jobs
cron(action="remove", job_id="abc123") # Remove a job
```

From CLI:

```bash
minion cron list
```

### Time Expressions

| You say | Parameters |
|---------|------------|
| every 20 minutes | `every_seconds: 1200` |
| every hour | `every_seconds: 3600` |
| every day at 8am | `cron_expr: "0 8 * * *"` |
| weekdays at 5pm | `cron_expr: "0 17 * * 1-5"` |
| every Monday at 9am | `cron_expr: "0 9 * * 1"` |

Jobs are stored in `~/.minion/cron/jobs.json` and survive restarts.

## Heartbeat

The heartbeat is a periodic check of `~/.minion/workspace/HEARTBEAT.md`. The agent reads this file at a regular interval and executes any active tasks.

### Configuration

```json
{
  "heartbeat": {
    "enabled": true,
    "intervalS": 7200
  }
}
```

`intervalS` is the check interval in seconds. Default: 7200 (2 hours).

### HEARTBEAT.md Format

```markdown
# Heartbeat Tasks

## Active Tasks

- [ ] Check GitHub notifications and summarize
- [ ] Read today's top HN stories
- [ ] Check if any background tasks completed

## Completed

- [x] Set up daily standup reminder
```

**How it works:**
- If there are no active tasks (`- [ ]` items), the heartbeat is skipped (no tokens used).
- The agent executes each active task, using its full tool set.
- It may mark tasks complete (`- [x]`) or add notes.
- Each heartbeat runs in a fresh session (no stale history accumulation).

### Use Cases

- **Daily routines**: "Check GitHub, summarize emails, update project status"
- **Monitoring**: "Check if deploy succeeded, alert if errors in logs"
- **Content**: "Find interesting articles on topic X"
- **Maintenance**: "Clean up old artifacts, check disk space"

### Tips

- Start with a long interval (7200s = 2 hours) and shorten if needed.
- Each heartbeat costs tokens — keep the task list focused.
- The agent reads the file, not a cache, so edits take effect immediately.
- Set `"enabled": false` to disable without deleting the file.
