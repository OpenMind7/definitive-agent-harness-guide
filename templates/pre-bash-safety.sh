#!/usr/bin/env bash
# PreToolUse hook: Block dangerous commands before execution
# Plain stdout is NOT model-visible for PreToolUse hooks — use JSON or stderr
INPUT="$CLAUDE_TOOL_INPUT"
CMD=$(echo "$INPUT" | jq -r '.command // empty')

# Block destructive operations — exit 2 feeds stderr to the model
if echo "$CMD" | grep -qE 'rm\s+-rf\s+/|DROP\s+TABLE|git\s+push.*--force'; then
  echo "BLOCKED: Destructive command detected. Requires explicit user approval." >&2
  exit 2
fi

# Add context for risky commands — JSON additionalContext on exit 0
if echo "$CMD" | grep -qiE 'API_KEY|SECRET|PASSWORD|TOKEN'; then
  printf '{"additionalContext": "WARNING: Possible secret in command. Review before proceeding."}\n'
  exit 0
fi

exit 0
