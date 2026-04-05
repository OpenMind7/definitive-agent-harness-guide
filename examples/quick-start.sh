#!/usr/bin/env bash
set -euo pipefail

# The Definitive Agent Harness Guide — 20-Minute Quick Start (Level 3)
# Run this in your project root to set up persistent memory, hooks, and agents.

echo "Setting up Level 3 Agent Harness..."

# 1. Create CLAUDE.md in your project root
cat > ./CLAUDE.md << 'CLAUDE_EOF'
# Project Instructions

## Stack
[Your language] | [Your framework] | [Your DB]

## Rules
- Always handle errors explicitly — no empty catches
- Write tests before implementation (TDD)
- Keep functions under 50 lines
- Use immutable patterns — never mutate shared state
- Validate all user input at system boundaries

## Memory
- Session start: read MEMORY.md
- Session end: update MEMORY.md with current state
CLAUDE_EOF
echo "[1/6] Created CLAUDE.md"

# 2. Create memory structure
mkdir -p memory/daily memory/archive .claude/hooks .claude/agents

cat > ./MEMORY.md << 'MEMORY_EOF'
# Current State

## Active Projects
- [Project] — [status]

## This Week
1. [Priority 1]

## Blockers
- [None yet]
MEMORY_EOF
echo "[2/6] Created MEMORY.md and directory structure"

# 3. Create session-end hook (Stop hook — uses JSON to steer model)
cat > .claude/hooks/session-end.sh << 'HOOK_EOF'
#!/usr/bin/env bash
# Stop hook: block completion until memory is updated
# Plain stdout is NOT model-visible for Stop hooks — use JSON
printf '{"decision": "block", "reason": "Update MEMORY.md with what changed this session before stopping."}\n'
exit 0
HOOK_EOF
chmod +x .claude/hooks/session-end.sh
echo "[3/6] Created session-end hook"

# 4. Create lint-on-edit hook (PostToolUse — uses JSON for model visibility)
cat > .claude/hooks/lint-on-edit.sh << 'HOOK_EOF'
#!/usr/bin/env bash
# PostToolUse: plain stdout NOT model-visible. Use JSON additionalContext.
FILE="${CLAUDE_FILE_PATH:-}"
[ -z "$FILE" ] && exit 0
ERRORS=""
case "$FILE" in
  *.ts|*.tsx) ERRORS=$(npx tsc --noEmit "$FILE" 2>&1 | tail -10) ;;
  *.py) ERRORS=$(python -m py_compile "$FILE" 2>&1) ;;
  *) exit 0 ;;
esac
if [ -n "$ERRORS" ]; then
  ESCAPED=$(printf '%s' "$ERRORS" | jq -Rs .)
  printf '{"additionalContext": %s}\n' "$ESCAPED"
fi
exit 0
HOOK_EOF
chmod +x .claude/hooks/lint-on-edit.sh
echo "[4/6] Created lint-on-edit hook"

# 5. Add hooks configuration
cat > .claude/settings.json << 'SETTINGS_EOF'
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/lint-on-edit.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/session-end.sh"
          }
        ]
      }
    ]
  }
}
SETTINGS_EOF
echo "[5/6] Created hooks configuration"

# 6. Create your first agent
cat > .claude/agents/code-reviewer.md << 'AGENT_EOF'
# Code Reviewer Agent

You review code changes for correctness, security, and maintainability.

## Process
1. Read all changed files completely
2. Check for: null handling, error paths, security issues, race conditions
3. Rate findings: CRITICAL / HIGH / MEDIUM / LOW
4. Output structured findings with file:line references

## Rules
- Never approve code you haven't fully read
- Flag empty catch blocks as CRITICAL
- Check all queries for proper scoping (tenant/user isolation)
AGENT_EOF
echo "[6/6] Created code-reviewer agent"

echo ""
echo "Done! Your Level 3 harness is ready."
echo ""
echo "What you got:"
echo "  - CLAUDE.md      — persistent project instructions"
echo "  - MEMORY.md      — session state dashboard"
echo "  - Stop hook      — auto-updates memory every session"
echo "  - PostToolUse    — auto-lints files after edits"
echo "  - Agent          — code-reviewer for structured reviews"
echo ""
echo "Next: Run 'claude' to start a session."
echo "The agent will automatically read CLAUDE.md and remember your context."
