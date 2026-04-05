# Multi-Agent Code Review — Example (Level 4)

This example demonstrates Level 4 orchestration: parallel code review with typed contracts and agent discovery.

## Pattern

Instead of one reviewer, dispatch multiple specialized agents in parallel:

```
Orchestrator
  ├── security-reviewer   → finds vulnerabilities, auth issues
  ├── correctness-checker  → finds logic errors, edge cases
  ├── style-enforcer      → checks conventions, naming, structure
  └── performance-auditor → finds N+1 queries, blocking calls
```

## Agent Definitions

Each agent lives in `.claude/agents/` with YAML frontmatter:

```yaml
---
name: security-reviewer
description: Reviews code for security vulnerabilities and auth issues
tools:
  - Read
  - Grep
  - Glob
  - Bash
model: sonnet
---

# Security Reviewer

You are a security-focused code reviewer. Your job is to find vulnerabilities.

## Checklist
- [ ] SQL injection (parameterized queries only)
- [ ] XSS (all user input sanitized)
- [ ] Auth bypass (every endpoint checks permissions)
- [ ] Secret exposure (no hardcoded keys/tokens)
- [ ] CSRF protection on state-changing endpoints
- [ ] Rate limiting on public endpoints
```

## Typed Action Contract

```typescript
interface ReviewFinding {
  severity: 'CRITICAL' | 'HIGH' | 'MEDIUM' | 'LOW';
  file: string;
  line: number;
  category: string;
  description: string;
  suggestion: string;
}

interface ReviewResult {
  agent: string;
  findings: ReviewFinding[];
  summary: string;
  pass: boolean;
}
```

## Orchestration

The orchestrator:
1. Dispatches all 4 reviewers in parallel
2. Collects typed results from each
3. Deduplicates findings across reviewers
4. Blocks merge if any CRITICAL findings exist

## Key Insight

The control plane (L4 bridge) needs:

| Component | Purpose |
|-----------|---------|
| Task objects | What to do, who owns it |
| Ownership | Agent claims a task atomically |
| Dependency graph | Task B waits for Task A |
| Budget caps | Max tokens/cost per agent |
| Rollback | Undo agent changes on failure |
| Observability | Track what each agent did and why |

See the full guide (Level 4) for implementation details.
