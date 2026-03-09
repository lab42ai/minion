# Memory

minion has a dual memory system: file-based (human-readable markdown) and vector-based (semantic search with embeddings).

## File-Based Memory

Human-readable markdown files in `~/.minion/workspace/memory/`:

| File | Purpose |
|------|---------|
| `MEMORY.md` | Long-term facts (user preferences, project notes, important dates) |
| `YYYY-MM-DD.md` | Daily notes (auto-created by the agent) |

The agent reads `MEMORY.md` and the last 7 days of daily notes at the start of each conversation.

The agent can read and write these files using the `read_file` and `write_file` tools. You can also edit them directly.

## Vector Memory

An automatic system that extracts facts from conversations and stores them as embeddings for semantic retrieval.

### How It Works

After each conversation turn:

1. **Extract**: An LLM scans the conversation for memorable facts (user preferences, decisions, technical details)
2. **Consolidate**: Each fact is compared against existing memories (cosine similarity). The LLM decides: ADD (new info), UPDATE (merge with existing), DELETE (contradicts old info), or NOOP (already known)
3. **Store**: Facts are embedded and stored in SQLite (`~/.minion/memory/memories.db`)

Before each turn:

4. **Retrieve**: The user's message is embedded and similar memories are pulled into the system prompt as context

### Implicit Learning Feedback

minion tracks whether its memories are actually helping, without requiring any action from you:

- **Silence = success**. If you move on to the next topic, the retrieved memories worked.
- **"Thanks" / "perfect"** = positive signal. Memories used get a priority boost.
- **"No, that's wrong"** = correction. Memories used get a priority penalty.
- **Repeating a question** = retrieval failed. Negative signal.

Over time, useful memories float up in priority and bad ones sink. This is logged to `~/.minion/memory/learning_log.tsv` so you can see if learning is actually working.

### Checking Learning Stats

Use `/context` in any chat to see:

```
Memory & Learning
- Stored memories: 47
- Feedback (7d): 123 turns, avg score +0.31
- Signals: 28 positive, 89 neutral, 4 corrections, 2 repetitions
```

A positive avg score means the agent is generally recalling useful information. If corrections are high, the stored memories may need cleanup.

### Configuration

```json
{
  "memory": {
    "enabled": true,
    "dbPath": "~/.minion/memory/memories.db",
    "embeddingModel": "text-embedding-nomic-embed-text-v1.5",
    "extractionModel": "",
    "maxMemories": 1000,
    "compactionThreshold": 50,
    "checkpointInterval": 300
  }
}
```

| Field | Default | Description |
|-------|---------|-------------|
| `enabled` | `true` | Enable/disable vector memory |
| `dbPath` | `~/.minion/memory/memories.db` | SQLite database path |
| `embeddingModel` | `text-embedding-3-small` | Model for generating embeddings |
| `extractionModel` | (same as primary) | Model for extracting facts from conversations |
| `maxMemories` | 1000 | Max memories before pruning (lowest priority removed first) |
| `compactionThreshold` | 50 | Session messages before compaction |
| `checkpointInterval` | 300 | Seconds between memory snapshots |

**Embedding model**: If using a local provider (LM Studio/Ollama), use an embedding model your server supports. `text-embedding-nomic-embed-text-v1.5` works well with local servers. For cloud, `text-embedding-3-small` (OpenAI) is the default.

### CLI Commands

```bash
minion memory stats     # Show memory counts and stats
minion memory search "query"  # Search memories by text
```
