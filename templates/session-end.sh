#!/usr/bin/env bash
# Stop hook: block completion until memory is updated
# Plain stdout is NOT model-visible for Stop hooks — use JSON
printf '{"decision": "block", "reason": "Update MEMORY.md with what changed this session before stopping."}\n'
exit 0
