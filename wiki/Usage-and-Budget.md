# Usage & Budget

minion tracks token usage and supports daily/monthly spending limits. This is especially useful with cloud providers where every API call costs money.

## Configuration

```json
{
  "usage": {
    "dailyBudgetUsd": 0.0,
    "monthlyBudgetUsd": 0.0,
    "warnAtPercent": 80
  }
}
```

| Field | Default | Description |
|-------|---------|-------------|
| `dailyBudgetUsd` | 0.0 | Daily spending limit in USD. 0 = no limit. |
| `monthlyBudgetUsd` | 0.0 | Monthly spending limit in USD. 0 = no limit. |
| `warnAtPercent` | 80 | Warn when usage reaches this % of budget |

## How It Works

- **Tracking**: Every LLM call logs input tokens, output tokens, and estimated cost.
- **Warning**: When usage hits `warnAtPercent` of your budget, a warning is logged.
- **Blocking**: When the budget is exceeded, the agent stops making LLM calls and tells the user.

## Checking Usage

### From Chat

Use the `/context` slash command:

```
/context
```

Output includes:

```
Token Usage (Today)
- Requests: 42
- Input tokens: 85,200
- Output tokens: 12,300
- Total tokens: 97,500
- Cost: $0.1425
- Daily budget: $0.14 / $5.00 (2.9%)
```

### From CLI

```bash
minion status
```

Shows current config, provider status, and usage summary.

## Setting a Budget

### Example: $5/day limit

```json
{
  "usage": {
    "dailyBudgetUsd": 5.0,
    "warnAtPercent": 80
  }
}
```

At $4.00 spent, you'll see a warning. At $5.00, the agent stops.

### Example: $50/month limit

```json
{
  "usage": {
    "monthlyBudgetUsd": 50.0,
    "warnAtPercent": 80
  }
}
```

### No Limit (local models)

If you're running local models (LM Studio, Ollama), token costs are $0. You can leave budgets at 0:

```json
{
  "usage": {
    "dailyBudgetUsd": 0.0,
    "monthlyBudgetUsd": 0.0
  }
}
```

## Reducing Costs

- **Lower `maxToolIterations`**: Set to 5 instead of 20. The agent does fewer tool calls per message.
- **Use local models**: Run on LM Studio or Ollama — free after hardware cost.
- **Shorter context**: Keep SOUL.md, AGENTS.md small. Fewer `always: true` skills.
- **Disable heartbeat**: If you don't need periodic checks, set `heartbeat.enabled: false`.
- **Increase heartbeat interval**: `intervalS: 14400` (4 hours) instead of 7200 (2 hours).
