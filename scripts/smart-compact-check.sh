#!/bin/bash
# Smart Compact — SessionStart hook
# Checks if a context file exists for the current working directory.
# Does NOT read contents — only checks existence and metadata.

# Derive project path (same convention as Claude Code: / → -)
PROJECT_PATH=$(echo "$PWD" | sed 's|^/|-|' | sed 's|/|-|g' | sed 's| |-|g')
CONTEXT_FILE="$HOME/.claude/projects/${PROJECT_PATH}/smart-compact-context.md"

# If file doesn't exist or is empty, no output (zero overhead)
if [ ! -s "$CONTEXT_FILE" ]; then
  exit 0
fi

# Calculate size and last modified date
SIZE=$(du -h "$CONTEXT_FILE" | cut -f1 | tr -d ' ')

# Cross-platform date: macOS (stat -f) vs Linux (stat -c)
if [[ "$(uname)" == "Darwin" ]]; then
  MOD_DATE=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$CONTEXT_FILE" 2>/dev/null)
else
  MOD_DATE=$(stat -c "%y" "$CONTEXT_FILE" 2>/dev/null | cut -d. -f1)
fi

# Emit JSON for Claude Code
cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "SMART COMPACT: Previous session context available (${SIZE}, last updated ${MOD_DATE}). You MUST ask the user before doing anything else: 'I have saved context from a previous session. Would you like me to load it to pick up where we left off, or do you prefer to start fresh?'"
  }
}
EOF
