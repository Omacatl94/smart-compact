# Smart Compact

> Save structured session context before `/clear` and auto-prompt to restore it next session. Never lose conversation context again.

## The Problem

Claude Code's `/clear` command wipes all conversation context. If you're mid-project and need a fresh context window, you lose everything — decisions made, problems solved, next steps planned. Starting over means re-explaining everything.

## The Solution

Smart Compact gives you two things:

1. **`/smart-compact` command** — Saves a structured summary of your session (what was done, why, decisions, problems, next steps) to a project-specific file.
2. **Auto-restore prompt** — On next session start, Claude automatically detects the saved context and asks if you want to load it.

## How It Works

```
You: /smart-compact
Claude: Context saved to smart-compact-context.md (3.2K).
        Run /clear when you want a fresh start.

You: /clear

--- Next session ---

Claude: I have saved context from a previous session. Would you like me
        to load it to pick up where we left off, or start fresh?
```

Context files are stored per-project at:
```
~/.claude/projects/<project-path>/smart-compact-context.md
```

## What Gets Saved

Each context snapshot includes:
- **Project status** — Self-contained summary of the current state
- **Work done** — What and why (not just what)
- **Decisions made** — With full reasoning and alternatives considered
- **Problems & solutions** — Root cause, fix, and lesson learned
- **Next steps** — Remaining work as a checklist

The file is a **living document** — new sessions are appended, old ones are pruned to keep it under ~2000 tokens.

## Installation

```bash
claude /plugin install paolodiana/smart-compact
```

## Recommended Setup

For the most reliable experience, add this rule to your `~/.claude/CLAUDE.md`:

```markdown
**Smart Compact**: If the system prompt mentions "session context available"
or "smart compact", your FIRST response MUST ask the user if they want to
load the saved context, BEFORE responding to anything else.
```

This ensures Claude always asks about saved context, even with casual greetings like "hey" or "hi".

> **Why?** The plugin hook injects context via `additionalContext` (system-reminder priority). With very short user messages, Claude may occasionally skip low-priority instructions. A CLAUDE.md rule has the highest priority and guarantees the behavior.

## Usage

### Save context before clearing
```
/smart-compact
```

### Context is auto-detected on next session
No action needed — the SessionStart hook checks for saved context automatically.

## How Context Is Stored

```
smart-compact-context.md
├── Project status (always current)
├── Session 2026-03-30 14:00
│   ├── Work done
│   ├── Files modified
│   ├── Decisions made
│   ├── Problems and solutions
│   └── Next steps
└── Session 2026-03-29 10:00 (older, pruned to key points)
```

## Smart Compact vs `/compact`

Claude Code has a built-in `/compact` command. Here's why Smart Compact exists alongside it:

| | `/compact` (built-in) | `/smart-compact` (this plugin) |
|---|---|---|
| **What it does** | Summarizes conversation history to free up context | Extracts key decisions, problems, and next steps into a structured file |
| **Context freed** | Partial — compresses old messages but keeps growing | Full — `/clear` after saving gives you ~100% free context |
| **Survives `/clear`** | No — cleared along with everything else | Yes — saved to disk, persists across sessions |
| **Cross-session** | No — lives only in the current session | Yes — auto-detected on next session start |
| **Format** | Opaque summary (you don't control what's kept) | Structured: decisions with reasoning, problems with root causes, explicit next steps |
| **Accumulation** | Re-compacts over itself, losing detail each time | Living document — appends new sessions, prunes old ones while keeping key lessons |

**Think of it this way:** `/compact` compresses the tape so you can keep recording a bit longer. `/smart-compact` saves the highlight reel to a separate disk, lets you start with a blank tape, and auto-loads the highlights next time.

**They work best together:** use `/compact` during a session to extend your runway, and `/smart-compact` at the end to preserve what matters before starting fresh.

## Requirements

- Claude Code CLI
- `jq` is NOT required (the hook uses pure bash)

## License

MIT
