#!/usr/bin/env bash
# PostToolUse hook: Auto-lint files after editing
# Plain stdout is NOT model-visible for PostToolUse — use JSON additionalContext
FILE="${CLAUDE_FILE_PATH:-}"
[ -z "$FILE" ] && exit 0

ERRORS=""
case "$FILE" in
  *.ts|*.tsx) ERRORS=$(npx tsc --noEmit "$FILE" 2>&1 | tail -10) ;;
  *.py) ERRORS=$(python -m py_compile "$FILE" 2>&1) ;;
  *.go) ERRORS=$(go vet "$FILE" 2>&1) ;;
  *.rs) ERRORS=$(cargo check 2>&1 | tail -10) ;;
  *) exit 0 ;;
esac

if [ -n "$ERRORS" ]; then
  ESCAPED=$(printf '%s' "$ERRORS" | jq -Rs .)
  printf '{"additionalContext": %s}\n' "$ESCAPED"
fi
exit 0
