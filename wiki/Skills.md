# Skills

Skills are modular packages that give your minion specialized capabilities. They live as directories containing a `SKILL.md` file with instructions the agent loads when needed.

## How Skills Work

minion uses a two-tier loading system to keep the context window lean:

1. **Always loaded**: Only the skill's `name` and `description` (from YAML frontmatter) are in the system prompt. This costs ~100 tokens per skill.
2. **On-demand**: When the agent decides a skill is relevant to the user's request, it reads the full `SKILL.md` body into context.

This means you can have many skills installed without bloating every conversation.

### Exception: `always: true`

If a skill needs its full instructions in the system prompt at all times (because the model needs them to know *how* to behave, not just *when* to trigger), add this to the frontmatter:

```yaml
metadata: {"minion": {"always": true}}
```

Use sparingly — each `always: true` skill adds its full content to every message.

## Where Skills Live

**Built-in skills** are bundled with minion (installed in the package).

**Custom skills** go in your workspace:

```
~/.minion/workspace/skills/
  my-skill/
    SKILL.md
    scripts/       # Optional: executable code
    references/    # Optional: documentation for the agent to read
    assets/        # Optional: files used in output (templates, images)
```

## Creating a Skill

### 1. Create the Directory

```bash
mkdir -p ~/.minion/workspace/skills/my-skill
```

### 2. Write SKILL.md

Every skill needs a `SKILL.md` with YAML frontmatter and markdown body:

```markdown
---
name: my-skill
description: Short description of what this skill does and WHEN to use it. This is the primary trigger — the agent reads this to decide if the skill is relevant.
---

# My Skill

Instructions for the agent go here. This is only loaded when the skill triggers.

## How to Use

Step-by-step workflow...

## Examples

Show the agent what good output looks like...
```

### 3. That's It

The skill is automatically discovered on the next conversation. No registration, no config changes.

## Skill Anatomy

```
my-skill/
  SKILL.md          # Required: frontmatter + instructions
  scripts/          # Optional: code the agent can execute
    process.py
  references/       # Optional: docs the agent reads when needed
    api-docs.md
  assets/           # Optional: files used in output
    template.html
```

### SKILL.md Frontmatter

Only two fields matter:

```yaml
---
name: my-skill
description: What this skill does and when to trigger it.
---
```

The `description` is critical — it's the only thing the agent sees when deciding whether to load the skill. Be specific about triggers:

**Good**: `"Create and edit PDF documents. Use when the user asks to generate, modify, rotate, merge, or extract text from PDF files."`

**Bad**: `"PDF stuff"`

### Scripts (`scripts/`)

Executable code for tasks that need to be deterministic or are rewritten every time.

Example: A `scripts/rotate_pdf.py` that the agent calls via `exec` instead of writing PDF rotation code from scratch each time.

### References (`references/`)

Documentation the agent reads into context when needed. Good for API docs, database schemas, domain knowledge.

Example: `references/api-docs.md` with endpoint documentation that the agent consults when building API calls.

### Assets (`assets/`)

Files used in the agent's output — templates, images, boilerplate. The agent doesn't read these into context; it copies or modifies them.

## Example: Weather Skill

A simple skill that uses free weather APIs:

```markdown
---
name: weather
description: Get current weather and forecasts (no API key required).
---

# Weather

## wttr.in (primary)

Quick one-liner:
\`\`\`bash
curl -s "wttr.in/London?format=3"
# Output: London: +8C
\`\`\`

Full forecast:
\`\`\`bash
curl -s "wttr.in/London?T"
\`\`\`

Tips:
- URL-encode spaces: wttr.in/New+York
- Airport codes: wttr.in/JFK
- Metric: ?m  Imperial: ?u
```

## Example: Daily Todo Skill

```markdown
---
name: daily-todo
description: Manage daily task lists. Use when the user asks about todos, tasks, or daily planning.
---

# Daily Todo

Manage tasks in `memory/YYYY-MM-DD.md` files.

## Adding Tasks

Append to today's file:
- [ ] Task description

## Completing Tasks

Change `- [ ]` to `- [x]`

## Daily Review

Read today's file, summarize completed vs remaining.
Carry over incomplete tasks to tomorrow if requested.
```

## Built-in Skills

minion comes with these skills out of the box:

| Skill | Description |
|-------|-------------|
| `weather` | Weather via wttr.in and Open-Meteo (no API key) |
| `cron` | Schedule reminders and recurring tasks |
| `daily-todo` | Task list management |
| `summarize` | Summarize long text or documents |
| `github` | GitHub operations |
| `skill-creator` | Guide for creating new skills |
| `tmux` | Terminal multiplexer operations |

## Tips

- **Keep SKILL.md under 500 lines**. If it's getting long, split into reference files.
- **The description is everything**. The agent only sees the description when deciding to load a skill. Make it specific.
- **Test with real conversations**. Send messages that should trigger the skill and see if it activates.
- **Don't duplicate tool docs**. The agent already knows tool signatures. Skills add *workflow* and *domain knowledge*, not API references.
