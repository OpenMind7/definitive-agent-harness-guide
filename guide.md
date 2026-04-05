# The Definitive Agent Harness Guide
## Beyond Prompt Engineering: 7 Levels of Agent Mastery

**April 2026 | Definitive Edition v2.1 — Post-Adversarial Review**
*Original concept: @keshavsuki | Extended to production-grade by NeuroAlchemist*
*Research: Martin Fowler, Anthropic, OpenAI, LangChain, HumanLayer, GitHub, ArXiv | 60+ sources*

---

> "The framework matters less than the infrastructure you build around it."
> — LangChain Engineering Blog, 2026

> "Anytime you find an agent makes a mistake, engineer a solution such that the agent never makes that mistake again."
> — HumanLayer, Skill Issue: Harness Engineering for Coding Agents

---

## Table of Contents

1. [The 7 Levels of Agent Engineering](#the-7-levels-of-agent-engineering)
2. [Level 1: Prompt Engineering](#level-1-prompt-engineering)
3. [Level 2: Context Engineering](#level-2-context-engineering)
4. [Level 3: Harness Engineering](#level-3-harness-engineering)
   - 3a: Hooks & Lifecycle
   - 3b: MCP Servers & Tool Integration
   - 3c: Skills & Progressive Disclosure
   - 3d: Back-Pressure & Verification
5. [Level 4: Orchestration Engineering](#level-4-orchestration-engineering)
   - Bridge: Your First Multi-Agent Pattern
   - 4a: Agent Definitions & Dispatch
   - 4b: Typed Schemas & Action Contracts
   - 4c: A2A Protocol & Agent Discovery
6. [Level 5: Self-Evolution Engineering](#level-5-self-evolution-engineering)
7. [Level 6: Adversarial Engineering](#level-6-adversarial-engineering)
8. [Level 7: Distributed Intelligence](#level-7-distributed-intelligence)
9. [The Complete Architecture](#the-complete-architecture)
10. [Quick Start: 20-Minute Setup](#quick-start-20-minute-setup-level-3)
11. [The Protocol Stack](#the-protocol-stack)
12. [Cost Management](#cost-management)
13. [Debugging Your Harness](#debugging-your-harness)
14. [Anti-Patterns](#anti-patterns-what-not-to-do)
15. [Metrics That Matter](#metrics-that-matter)
16. [Research Sources](#research-sources)

---

## The 7 Levels of Agent Engineering

The original guide proposed 3 levels. Production reality demands 7.

| Level | Name | What You Build | Who's Here |
|-------|------|----------------|------------|
| **L1** | Prompt Engineering | Better instructions per session. Resets every time. | 80% of users |
| **L2** | Context Engineering | Right info at the right time. CLAUDE.md, RAG, memory files. | 15% of users |
| **L3** | Harness Engineering | Structure: hooks, MCP servers, skills, back-pressure loops. | 4% of users |
| **L4** | Orchestration Engineering | Multi-agent coordination. Typed contracts. Agent-to-agent protocols. | <1% |
| **L5** | Self-Evolution Engineering | Agent improves its own patterns, decays stale knowledge, learns from failures. | <0.1% |
| **L6** | Adversarial Engineering | Security hardening, behavioral analysis, kill-chain detection, fail-closed gates. | <0.01% |
| **L7** | Distributed Intelligence | Knowledge graphs, cross-session learning, terminal isolation, fleet orchestration. | Bleeding edge |

**Most people are stuck at L1.** They write better prompts and wonder why the AI forgets everything.
**L2 fixes memory.** L3 builds the machine. L4+ builds the factory that builds machines.

### Important: Maturity vs Autonomy

This is a **harness-maturity ladder** — it measures the sophistication of what you build around the agent. It is NOT an autonomy taxonomy. For autonomy levels, see:
- **[Sema4.ai](https://sema4.ai/blog/the-five-levels-of-agentic-automation/):** L0 (fixed automation) → L5 (full autonomy)
- **[CSA](https://cloudsecurityalliance.org/blog/2026/01/28/levels-of-autonomy):** L0 (human-only) → L5 (autonomous agents) with explicit governance requirements at each level

The two axes are orthogonal. You can have L7 maturity (sophisticated harness) at L2 autonomy (human-in-the-loop for all decisions), or L3 maturity at L4 autonomy (basic harness, high agent freedom — risky). **Best practice: harness maturity should always lead autonomy.** Don't grant autonomy you can't govern.

---

## Level 1: Prompt Engineering (The Starting Point)

You write instructions every session. More detail = better output. Resets every time.

**Signs you're here:**
- You paste the same context into every conversation
- You manually remind the AI of your preferences
- Output quality varies wildly between sessions

**How to graduate:** Create persistent files that load automatically.

---

## Level 2: Context Engineering

### File 1: CLAUDE.md (Project Root)

Lives in your project root. Loads automatically at every session start. This is the agent's permanent operating manual.

```markdown
# CLAUDE.md

## Identity
Company: [name] | Industry: [industry] | Stack: [tools]

## Rules (max 20 — each line dilutes the last)
- Tone: [direct/professional/casual]
- Always: [next steps, follow-ups, specific patterns]
- Never: [commitments without asking, specific anti-patterns]

## Active Context
- Current focus: [project/sprint]
- Key decisions: [recent architectural choices]

## Memory Protocol
- Session start: read MEMORY.md
- Session end: update MEMORY.md with what changed
```

**Critical insight:** Keep CLAUDE.md under 50 lines. Every extra line dilutes the critical ones. Models start skimming when files get long. Don't document what the model already knows by default.

### File 2: MEMORY.md (Live State)

Dashboard, not journal. Current state only. History goes in daily logs.

```markdown
# MEMORY.md — Current State

## Active Projects
- [Project] — [status] — deadline: [date]

## This Week
1. [Priority 1]
2. [Priority 2]

## Blockers
- [What is stuck and why]
```

### File 3: Rules Directory (Scoped Instructions)

Instead of one massive CLAUDE.md, use scoped rule files:

```
.claude/
  rules/
    common/
      coding-style.md      # Code quality standards
      git-workflow.md       # Commit conventions
      security.md           # Security checklist
      testing.md            # TDD requirements
    project-specific/
      api-patterns.md       # Your API conventions
      deployment.md         # Deploy procedures
```

Rules load contextually. The agent gets coding rules when coding, deploy rules when deploying.

### File 4: Session Memory Loop (The Memory Closer)

The memory loop closes via hooks, not a standalone file. Add this to your CLAUDE.md:

```markdown
## Memory Protocol
- Session start: read MEMORY.md + active-work-{workstream}.md
- Session end: update both with current state. Remove resolved items. Add new items.
- Log key decisions to memory/daily/YYYY-MM-DD.md
```

Then wire it with a `Stop` hook (see L3a below) that blocks completion until memory is updated:

```bash
#!/usr/bin/env bash
# session-end.sh — Stop hook that ensures memory is updated
# For Stop hooks: use JSON stdout to block, or stderr on exit 2
printf '{"decision": "block", "reason": "Before stopping: update MEMORY.md with what changed this session."}\n'
exit 0
```

The `Stop` hook with `"decision": "block"` prevents the agent from ending its turn until it processes the reason. This closes the memory loop automatically.

**Why this matters:** Without closing the loop, memory is write-once. With it, memory is self-maintaining. The next session starts with perfect context without you doing anything.

### Three-Layer Memory Architecture

Production systems use three layers, not one:

| Layer | Contents | When Loaded |
|-------|----------|-------------|
| **L1: MEMORY.md** | Short pointers, index of topics (under 200 lines) | Always — injected into every conversation |
| **L2: Topic files** | Detailed notes per project/domain (e.g., `memory/payments-api.md`) | On demand — referenced when relevant |
| **L3: Raw transcripts** | Full session logs, archived conversations | Search only — accessed via KB or grep |

The key: L1 is a dashboard with links. L2 holds the depth. L3 is the archive. Most people put everything in L1 and wonder why the agent starts ignoring instructions.

---

## Level 3: Harness Engineering

You build the structure. The agent runs without you.

### 3a: Hooks & Lifecycle

Hooks fire at specific lifecycle events. They're how the harness evaluates, validates, and steers itself.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/pre-bash-safety.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/lint-on-edit.sh"
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
            "command": "bash ~/.claude/hooks/session-end.sh"
          }
        ]
      }
    ]
  }
}
```

**Hook Types and When They Fire:**

| Hook | Fires When | Use For |
|------|-----------|---------|
| `SessionStart` | Agent starts | Load state, check system health, detect workstream |
| `UserPromptSubmit` | User sends a message | Inject context, route workstream, validate input |
| `PreToolUse` | Before any tool call | Validate safety, check permissions, classify intent |
| `PostToolUse` | After any tool call | Lint, format, extract patterns, trigger reviews |
| `PreCompact` | Before context compression | Save state snapshot, preserve critical context |
| `Stop` | End of agent turn | Update memory, verify work, trigger notifications |
| `Notification` | On significant events | Discord/Slack alerts, logging |
| `SubagentStop` | Subagent completes | Collect results, update task status |

**Hook design principles:**
- **Stdout visibility varies by hook type.** This is the #1 mistake in harness engineering:

| Hook | Plain stdout visible to model? | How to steer the model |
|------|-------------------------------|----------------------|
| `SessionStart` | **Yes** | Echo directly — model sees it |
| `UserPromptSubmit` | **Yes** | Echo directly — model sees it |
| `PreToolUse` | **No** | Use JSON stdout: `{"additionalContext": "your message"}` on exit 0, or stderr on exit 2 (blocks) |
| `PostToolUse` | **No** | Use JSON stdout: `{"additionalContext": "your message"}` on exit 0, or stderr on exit 2 |
| `Stop` | **No** | Use JSON stdout: `{"decision": "block", "reason": "update memory first"}` on exit 0, or stderr on exit 2 |

- Exit codes: **0** = success (JSON processed), **1** = non-blocking error (logged only), **2** = block action (stderr fed to model).
- Succeed silently on success. Surface only errors and actionable guidance.
- Keep hot-path hooks under 5ms (PreToolUse, PostToolUse).
- Write hooks as real scripts, not inline shell. Inline commands break at complexity.

**Example: pre-bash-safety.sh**
```bash
#!/usr/bin/env bash
# Block dangerous commands before execution (PreToolUse)
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
```

### 3b: MCP Servers & Tool Integration

**MCP (Model Context Protocol) is the missing layer most guides skip.** It's the standardized protocol for connecting agents to external tools and data — 97M+ monthly SDK downloads, adopted by every major AI provider.

Think of it this way:
- **L2 gives the agent memory** (what it knows)
- **L3a gives the agent reflexes** (hooks)
- **L3b gives the agent hands** (tools via MCP)

#### What MCP Provides

MCP servers expose four capability types:

| Capability | Purpose | Example |
|-----------|---------|---------|
| **Resources** | Read-only data access | Database schemas, file contents, API docs |
| **Tools** | Executable actions | Run queries, create PRs, send messages |
| **Prompts** | Reusable templates | Code review prompts, analysis frameworks |
| **Sampling** | Reverse LLM calls | Server asks the model for help |

#### Architecture Pattern: Domain-Specific Servers

Don't build one MCP server that does everything. Build domain-specific servers connected via a central registry:

```
Agent
  ├── mcp-postgres      (database queries, schema inspection)
  ├── mcp-github        (PRs, issues, code search)
  ├── mcp-slack         (messages, channels, threads)
  ├── mcp-knowledge-base (search, add, relate entries)
  └── mcp-monitoring    (metrics, alerts, logs)
```

Each server:
- Has its own security boundary
- Can be version-controlled independently
- Limits context bloat (only relevant tools loaded)
- Enables fine-grained access control

#### MCP Configuration

```json
{
  "mcpServers": {
    "knowledge-base": {
      "command": "node",
      "args": ["./mcp-servers/kb-server/index.js"],
      "env": {
        "KB_PATH": "/path/to/knowledge.db"
      }
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

#### MCP Anti-Patterns

- **Tool sprawl**: Installing 20+ MCP servers "just in case" — each tool's description consumes context
- **God server**: One server with 50 tools — the agent can't choose effectively
- **CLI duplication**: Wrapping well-known CLIs (git, npm) as MCP servers when the agent already knows them from training data
- **Missing schemas**: Tools without explicit input/output schemas — leads to hallucinated parameters

#### When to Use MCP vs CLI vs Direct API

| Approach | Use When | Example |
|----------|----------|---------|
| **MCP server** | Custom integrations, structured data, access control needed | Knowledge base, internal APIs |
| **CLI tool** | Well-known tool, already in training data | git, npm, docker, curl |
| **Direct API** | One-off calls, no reuse needed | Quick webhook test |

### 3c: Skills & Progressive Disclosure

Skills are the bridge between static CLAUDE.md rules and dynamic agent behavior. They load context on-demand, preventing the "instruction budget" problem where 500 lines of rules cause the model to follow none of them.

#### What a Skill Is

A skill is a markdown file that activates when needed:

```
.claude/skills/
  code-review/
    SKILL.md         # Instructions for code review
    checklist.md     # Detailed review checklist
    examples/        # Example reviews
  deployment/
    SKILL.md         # Deploy procedures
    rollback.md      # Rollback steps
  security-audit/
    SKILL.md         # Security audit framework
```

When the agent or user invokes `/code-review`, only that skill's context loads. The other skills stay dormant, preserving the context window.

#### Skill Design Principles

1. **Progressive disclosure**: Load depth only when needed
2. **Self-contained**: Each skill has everything it needs
3. **Composable**: Skills can invoke other skills
4. **Measurable**: Skills define their own success criteria

#### Example: SKILL.md for Code Review

```markdown
# Code Review Skill

## Trigger
Activated after code changes are written.

## Process
1. Read all changed files
2. Run 4-lens analysis: correctness, security, architecture, maintainability
3. Rate findings: CRITICAL (must fix) / HIGH / MEDIUM / LOW
4. Output structured findings

## Rules
- Never approve code you haven't read
- Flag silent error swallowing as CRITICAL
- Check for tenant/user scoping on all queries
- Verify immutability patterns

## Output Format
### [CRITICAL/HIGH/MEDIUM/LOW] Finding Title
- File: path:line
- Issue: what's wrong
- Fix: how to fix it
```

### 3d: Back-Pressure & Verification

**This is the highest-leverage configuration investment.** Back-pressure mechanisms tell the agent when its work is wrong without human intervention.

#### The Feedback Loop

```
Agent writes code
       ↓
  TypeScript compiler runs (PostToolUse hook)
       ↓
  ┌── Passes → continue
  └── Fails → error fed back to agent → agent fixes → re-check
```

#### Effective Back-Pressure Sources

| Source | What It Catches | Context Cost |
|--------|----------------|--------------|
| **Type checker** (tsc, mypy) | Type mismatches, missing imports | Low (errors only) |
| **Linter** (eslint, ruff) | Style violations, common bugs | Low |
| **Build** (webpack, cargo) | Compilation errors, dependency issues | Low |
| **Unit tests** | Logic errors, regressions | Medium |
| **Integration tests** | API contract violations | Medium |
| **E2E tests** | Full workflow failures | High |

**Key principle: Show only errors.** A passing test suite that dumps 200 lines of "OK" output wastes context. Configure your tools to be silent on success, verbose on failure.

#### Example: PostToolUse Lint Hook

```bash
#!/usr/bin/env bash
# lint-on-edit.sh — PostToolUse hook for Write/Edit
# PostToolUse: plain stdout is NOT model-visible. Use JSON additionalContext.
FILE="$CLAUDE_FILE_PATH"
[ -z "$FILE" ] && exit 0

ERRORS=""
case "$FILE" in
  *.ts|*.tsx) ERRORS=$(npx tsc --noEmit "$FILE" 2>&1 | tail -20) ;;
  *.py) ERRORS=$(python -m py_compile "$FILE" 2>&1) ;;
  *.rs) ERRORS=$(cargo check 2>&1 | tail -20) ;;
  *) exit 0 ;;
esac

if [ -n "$ERRORS" ]; then
  # Feed errors back to model via JSON additionalContext
  ESCAPED=$(printf '%s' "$ERRORS" | jq -Rs .)
  printf '{"additionalContext": %s}\n' "$ESCAPED"
fi
exit 0
```

#### The Evaluator Pattern

The agent must evaluate its own work. Separate evaluation from generation — Anthropic's research shows agents have "leniency bias" when judging their own output.

**Hard Gates (blocking — must pass):**

| Gate | Pass | Fail |
|------|------|------|
| Correctness | All edge cases covered | Happy-path only |
| Security | No new attack surface | Introduces vulnerability |
| Silent failures | No swallowed errors | Empty catch blocks |
| Data scoping | Proper tenant/user isolation | Missing scope filters |
| Immutability | No shared-state mutation | Mutates shared state |

**Quality Checks (advisory — failure escalates depth):**
- Maintainable in 30 seconds by a stranger?
- Pass the "tomorrow test" — would you make the same choice fresh?
- Pass the "adversary test" — can a malicious actor exploit this?

**Best practice from Anthropic:** Use a separate evaluator agent (or model) that's tuned to be skeptical. "Tuning a standalone evaluator to be skeptical turns out to be far more tractable than making a generator critical of its own work."

---

## Level 4: Orchestration Engineering

Single agents hit limits. The breakthrough: **multiple specialized agents working in concert.**

### Bridge: Your First Multi-Agent Pattern

The jump from L3 to L4 is the steepest in this guide. Here's how to cross it gradually:

**Step 1: Add one reviewer agent (Day 1)**

Create `.claude/agents/code-reviewer.md`:
```markdown
# Code Reviewer Agent

You are a senior code reviewer. You receive diffs and find bugs.

## Rules
- Read every changed file completely before commenting
- Rate findings: CRITICAL / HIGH / MEDIUM / LOW
- Never suggest style changes unless they affect correctness
- Check for: null handling, error paths, security, race conditions

## Output
List findings with file:line references and suggested fixes.
```

Now after writing code, spawn it:
```
# In Claude Code, use the Task tool:
Task: code-reviewer agent reviews your recent changes
```

That's it. You just went from L3 to L4. One agent reviewing another's work.

**Step 2: Add a planner agent (Week 1)**

Before implementing features, spawn a planner that reads the codebase and produces a step-by-step plan. You review the plan, then implement.

**Step 3: Run them in parallel (Week 2)**

After writing code, spawn security-reviewer + code-reviewer + architecture-reviewer simultaneously. Merge findings. Fix. This is the parallel swarm pattern.

**Step 4: Build the control plane (Week 3-4)**

Before adding more agents, you need infrastructure to coordinate them. "Create specialized agents as markdown files" gets you started, but production orchestration needs:

| Control Plane Component | What It Does | Without It |
|---|---|---|
| **Task objects** | Structured work items with status, owner, blockedBy | Agents duplicate work or miss tasks |
| **Ownership & leases** | Each task assigned to one agent with timeout | Two agents edit the same file simultaneously |
| **Queues & priority** | Ordered work dispatch with priority levels | Important work starved by bulk tasks |
| **Retry & idempotency** | Failed tasks retry safely without side-effect duplication | Partial failures leave inconsistent state |
| **Budget limits** | Per-task and per-session token/cost caps | Runaway agents burn through API credits |
| **Failure recovery** | Dead-letter queue for tasks that exhaust retries | Failed work silently disappears |
| **Observability** | Logs of who did what, when, and what it cost | Debugging multi-agent issues becomes impossible |
| **Approval routing** | High-risk actions escalate to human or senior agent | Agents autonomously take irreversible actions |

Modern agent frameworks (Claude Code Teams, LangGraph, CrewAI) provide some of these primitives. The point: multi-agent orchestration is infrastructure engineering, not just "spawn more agents."

**Step 5: Add a second model (Month 1)**

Dispatch the same review task to a different model (GPT, Gemini). Compare findings. This is the dual-brain adversarial pattern. Catches blind spots that any single model misses.

### 4a: Agent Definitions & Dispatch

Create specialized agents as markdown files:

```
.claude/agents/
  planner.md           # Architecture and planning
  code-reviewer.md     # Post-implementation review
  security-reviewer.md # Pre-commit security audit
  tdd-guide.md         # Test-driven development
  debugger.md          # Root cause analysis
  build-resolver.md    # Fix build failures
```

Each agent has a system prompt defining its role, tools, and constraints. The orchestrator dispatches tasks to the right specialist.

#### Modern Subagent Capabilities (2026)

Agent definitions now support far more than markdown system prompts:

```yaml
---
# .claude/agents/security-reviewer.md (YAML frontmatter)
name: security-reviewer
description: Reviews code for security vulnerabilities
tools:
  - Read
  - Grep
  - Glob
  - Bash
disallowedTools:
  - Write
  - Edit
permissionMode: plan        # Requires plan approval before acting
model: sonnet               # Cost-effective model for reviews
isolation: worktree          # Isolated git worktree
maxTurns: 20                # Budget: cap agent turns
---

# Security Reviewer Agent
You review code for security vulnerabilities...
```

Key capabilities (all YAML frontmatter fields):
- **Tool allow/deny lists**: `tools` and `disallowedTools` — restrict what each agent can do
- **Permission modes**: `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, `plan`
- **Model routing**: `model` — assign cheaper models to worker agents
- **Worktree isolation**: `isolation: worktree` — agent works on an isolated repo copy
- **Background execution**: `background: true` — long-running agents work asynchronously
- **MCP scoping**: `mcpServers` — each agent accesses different MCP servers
- **Memory scoping**: `memory` — `user`, `project`, or `local` memory access
- **Skills**: `skills` — pre-load specific skills for the agent
- **Hooks**: `hooks` — agent-specific hook configuration
- **Agent teams** (experimental): Shared task lists, direct messaging between agents, lifecycle hooks (`TaskCreated`, `TaskCompleted`, `TeammateIdle`)

> **Note:** As of Claude Code v2.1.63, the `Task(...)` API was renamed to `Agent(...)`. Subagents cannot spawn other subagents — this is an intentional safety constraint.

#### Multi-Agent Patterns

**Pattern 1: Sequential Pipeline**
```
Research → Plan → Implement → Review → Fix → Re-review → Commit
```

**Pattern 2: Parallel Swarm**
```
┌─ Security Reviewer ──────┐
├─ Code Reviewer ───────────┤ → Merge findings → Fix
├─ Architecture Reviewer ───┤
└─ Performance Reviewer ────┘
```

**Pattern 3: Planner-Generator-Evaluator (Anthropic's Pattern)**
```
Planner ──→ defines success criteria ("sprint contract")
Generator ──→ writes code to meet criteria
Evaluator ──→ grades work against criteria (separate model/agent)
    ↓
  Pass? → commit
  Fail? → Generator retries with evaluator feedback
```

**Pattern 4: Dual-Brain (Adversarial)**
```
Brain A (Claude) ──→ writes code
Brain B (GPT)    ──→ reviews code
                      ↓
                Findings merged
                      ↓
                Brain A fixes
```

#### Agent Selection Matrix

| Situation | Agents | Pattern |
|-----------|--------|---------|
| Simple bug fix | 1 (debugger) | Direct |
| New feature | 2 (planner → implementer) | Sequential |
| Code review | 3+ (security + architecture + quality) | Parallel |
| High-risk change | 4+ (dual-brain + swarm review) | Adversarial |
| Cross-system refactor | 5+ (planner + per-domain specialists) | Coordinated |

### 4b: Typed Schemas & Action Contracts

**Most multi-agent failures come from unstructured data exchange.** GitHub's research: "Natural language is messy. Typed schemas make it reliable."

#### The Problem

Agent A tells Agent B: "Fix the authentication issue."
Agent B interprets this as: "Rewrite the entire auth module."

#### The Solution: Typed Schemas

Define explicit contracts for inter-agent communication:

```typescript
// Instead of passing natural language between agents,
// define structured action schemas:

type ReviewFinding = {
  severity: "critical" | "high" | "medium" | "low";
  file: string;
  line: number;
  issue: string;
  suggested_fix: string;
  confidence: number;
};

type ReviewResult = {
  findings: ReviewFinding[];
  summary: string;
  approved: boolean;
  blocking_count: number;
};
```

#### Action Schemas for Agent Outputs

Constrain what agents can do with discriminated unions:

```typescript
type AgentAction =
  | { type: "fix"; file: string; line: number; replacement: string }
  | { type: "escalate"; reason: string; to: "human" | "senior-agent" }
  | { type: "request-info"; question: string; context: string }
  | { type: "approve"; confidence: number; notes: string };
```

This prevents agents from inventing actions or producing ambiguous output.

#### Sprint Contracts (Anthropic's Pattern)

Before implementation, the planner and evaluator negotiate explicit success criteria:

```markdown
## Sprint Contract: Add User Preferences API

### Success Criteria
1. GET /api/preferences returns user settings (200 with JSON body)
2. PUT /api/preferences updates settings (200 on success, 422 on invalid)
3. Auth required on both endpoints (401 without token)
4. Input validation on all fields (no empty strings, valid enums)
5. Unit tests cover happy path + 3 error cases
6. No N+1 queries

### Non-Goals
- UI changes
- Migration scripts
- Cache invalidation
```

Both the generator and evaluator agree on these criteria before any code is written.

### 4c: A2A Protocol & Agent Discovery

For advanced multi-agent systems, the **Agent-to-Agent (A2A) protocol** standardizes how agents discover and communicate with each other.

#### The Protocol Stack (2026)

```
┌───────────────────────────────────┐
│  Layer 3: A2A                     │  Agent ↔ Agent orchestration
│  (discovery, delegation, tasks)    │
├───────────────────────────────────┤
│  Layer 2: MCP                     │  Agent ↔ Tool integration
│  (resources, tools, prompts)       │
├───────────────────────────────────┤
│  Layer 1: WebMCP                  │  Agent ↔ Web (structured access)
│  (web resources, HTTP)             │
└───────────────────────────────────┘
```

#### When to Use Which

| Scenario | Protocol |
|----------|----------|
| Connect agent to database, API, or service | **MCP** |
| One agent delegates work to another agent | **A2A** |
| Reuse integrations across AI providers | **MCP** |
| Build autonomous agent teams | **A2A** |
| Complex task requiring negotiation | **A2A** |

#### Agent Cards (Discovery)

A2A uses Agent Cards — JSON manifests at `/.well-known/agent.json` that describe what an agent can do:

```json
{
  "name": "security-reviewer",
  "description": "Reviews code for security vulnerabilities",
  "capabilities": ["code-review", "vulnerability-scan", "dependency-audit"],
  "input_schema": { "type": "object", "properties": { "diff": { "type": "string" } } },
  "output_schema": { "$ref": "#/definitions/ReviewResult" }
}
```

This enables dynamic agent discovery — new agents register themselves and are automatically available to the orchestrator.

---

## Level 5: Self-Evolution Engineering

> **Maturity note:** L5-L7 are experimental patterns observed in bleeding-edge production systems. They work (we run them daily), but they require significant engineering investment and aren't necessary for most teams. **L1-L4 covers 95% of practical agent engineering.** Treat L5+ as aspirational architecture, not a checklist.

The agent improves itself over time. Not just memory — **behavioral learning.**

### The ReasoningBank

A persistent, evolving knowledge base of patterns the agent has learned:

```markdown
# patterns.md

### [PAT-042] API Error Envelope Pattern
- Confidence: 0.92
- Domain: api_design
- Pattern: Always return {success, data, error, meta}
- Evidence: Applied 47 times, 0 regressions
- Transfer: Also works for WebSocket message formats
- Last-used: 2026-04-05

# anti-patterns.md

### [AP-019] Silent Catch-All
- Confidence: 0.95
- Domain: error_handling
- Pattern: catch(e) {} with no logging = data loss
- Evidence: Caused 3 production incidents
- Last-used: 2026-04-03
```

### Confidence Mechanics

```
New pattern:              confidence = 0.60
Each successful use:      confidence += 0.05 (cap 0.99)
Each failure:             confidence -= 0.10
Unused 60+ days:          confidence -= 0.02/month (stale decay)
Below 0.30:               archived (pruned)
```

**Why decay matters:** Patterns that never expire become dogma. What worked for React 17 may be an anti-pattern in React 19. Decay forces re-validation.

### The Dream Protocol

Periodic consolidation (daily or on `/dream`):
1. Review recent trajectories (what worked, what didn't)
2. Extract new patterns from successful sessions
3. Identify anti-patterns from failures
4. Decay unused patterns (prevent staleness)
5. Sync local learnings to knowledge base
6. Prune trajectories to keep only the 20 most recent
7. Check for pattern conflicts and resolve by evidence strength

### Metacognitive State Vector (MSV)

Before every task, the agent computes:

```
MSV = [novelty, uncertainty, complexity, risk, conflict]
     0.0 = familiar/safe        1.0 = novel/dangerous
```

**Routing based on MSV:**

| Condition | Route | Depth |
|-----------|-------|-------|
| avg <= 0.2, risk < 0.2 | System 1 (fast) | Apply pattern directly |
| avg <= 0.3, risk < 0.3 | System 1 (fast) | Pattern + one adversarial check |
| avg > 0.3 or risk >= 0.3 | System 2 (deep) | 3-lens analysis |
| avg > 0.5 or risk >= 0.6 | System 2 + agents | 4-lens + subagent |
| uncertainty > 0.5 | System 2 + dual-brain | 5-lens + adversarial review |
| risk >= 0.8 or PHI/HIPAA | Maximum depth | All lenses + human approval |

This means the agent **automatically goes deeper on hard problems** and stays fast on familiar ones.

### Task-Class Priors

When MSV dimensions aren't determinable, use priors:

| Task Class | Default MSV Prior | Rationale |
|---|---|---|
| Spec/document editing | 0.25 | Familiar structure |
| Pattern-matched bug fix | 0.20 | Well-known failure class |
| Config/settings change | 0.20 | Routine operation |
| New feature (known domain) | 0.40 | Moderate novelty |
| New feature (unknown domain) | 0.50 | Standard default |
| Security/auth/PHI work | 0.60 | Always elevated |
| Cross-system integration | 0.50 | Multiple unknowns |

---

## Level 6: Adversarial Engineering

The agent protects itself and your systems from harm.

### Behavioral Analysis (Hot Path)

Every tool call gets scored in <5ms:

```
score = operational_load x 0.3
      + risk_behavior x 0.4
      + target_sensitivity x 0.3
```

**Escalation tiers:**
- Tier 0 (normal): Score < 0.3 — proceed normally
- Tier 1 (elevated): Score 0.3-0.6 — add verification step
- Tier 2 (high): Score 0.6-0.8 — require human confirmation
- Tier 3 (lockdown): Score > 0.8 — block + alert

### Kill-Chain Detection

Monitor for attack progression:
```
Reconnaissance → Disable defenses → Persist access → Exfiltrate data → Lateral movement
```

If the agent's tool calls match this pattern (even accidentally), escalate immediately.

### Security Hook Pipeline

```
PreToolUse:
  1. baseline-event.sh       — telemetry capture
  2. pre-bash-dispatch.sh    — command classification
  3. protect-secrets.sh      — no hardcoded keys
  4. phi-guard.sh            — PHI/PII scrubbing
  5. lightweight-gate.py     — risk scoring + allow/block

PostToolUse:
  1. lint-on-edit.sh         — format + lint
  2. behavioral-tracker.py   — anomaly scoring
  3. auto-review.sh          — async adversarial review on commits
  4. context-guard.sh        — context budget enforcement
```

### Pre-Commit Security Checklist

Before every commit, verify:
- [ ] No hardcoded secrets (keys, passwords, tokens)
- [ ] All user inputs validated
- [ ] SQL parameterized, HTML sanitized
- [ ] CSRF protection active
- [ ] Auth/authz verified on all endpoints
- [ ] Rate limiting on public endpoints
- [ ] Error messages don't leak internals
- [ ] PHI audit trail maintained (if applicable)

### Security Architecture (Beyond Scoring)

Behavioral scoring catches runtime anomalies. But production agent security needs architectural controls:

**Least-Privilege Auth:**
- Each agent gets only the permissions it needs. A code-reviewer agent shouldn't have Write access.
- Use tool restrictions in agent definitions to enforce capability boundaries.
- Short-lived credentials — rotate tokens per session, never embed long-lived secrets.

**Kill Switches:**
- Global halt: one command stops all agents immediately (e.g., `fleet halt --all`)
- Per-agent halt: terminate a specific runaway agent without affecting others
- Automatic triggers: cost threshold exceeded, error rate spike, unauthorized action attempted

**Rollback:**
- Agents work in worktrees (isolated branches). If work fails review, discard the branch — zero blast radius.
- Database changes require explicit migration files reviewed by human, never direct DDL from agents.
- Every agent action logged with enough context to reconstruct and reverse.

**Tamper-Evident Audit:**
- Append-only audit log. Agent actions, tool calls, approvals, escalations — all recorded.
- Hash-chain or write-once storage so logs can't be retroactively altered (see [AWS CloudTrail integrity validation](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-log-file-validation-intro.html) for the production pattern: per-log hashes + signed digest files).
- Regular audit log review — automated anomaly detection on the log itself.
- Reference: [CSA Agentic Trust Framework](https://cloudsecurityalliance.org/blog/2026/02/02/the-agentic-trust-framework-zero-trust-governance-for-ai-agents) defines circuit breakers, manual kill switches (<1 second), session revocation, state rollback, and graceful degradation requirements.

**Approval Enforcement:**
- High-risk actions (deploy, delete, push, send external messages) require explicit human approval.
- Permission modes: `plan` mode forces agents to propose actions before executing.
- Escalation is the default — agents should prove actions are safe, not assume they are.

### Circuit Breaker Pattern

For long-running agent sessions, implement circuit breakers:

```
State: CLOSED (normal operation)
  → 3 consecutive failures or risk score spike
State: OPEN (block all non-read operations)
  → wait 30 seconds
State: HALF-OPEN (allow one probe operation)
  → success → CLOSED
  → failure → OPEN
```

This prevents cascading failures in multi-agent systems.

---

## Level 7: Distributed Intelligence

Knowledge that persists, connects, and grows across all sessions and agents.

### Knowledge Base Architecture

Replace flat MEMORY.md with a searchable, graph-connected knowledge system:

```
┌─────────────────────────────────────────┐
│              Knowledge Base              │
│                                         │
│  ┌──────────┐  ┌──────────┐  ┌───────┐ │
│  │ FTS5     │  │ Semantic │  │ Graph │ │
│  │ (BM25)   │  │ (Vector) │  │ (PPR) │ │
│  └────┬─────┘  └────┬─────┘  └───┬───┘ │
│       └──────────┬───┴────────────┘     │
│            Hybrid Reranker              │
│         (10 learned features)           │
└─────────────────────────────────────────┘
```

**Three-tier search routing:**
- **Tier 0 (fast):** BM25 exact match — <10ms for known terms
- **Tier 1 (hybrid):** FTS + vector + graph fusion — standard retrieval
- **Tier 2 (deep):** Graph-first traversal — dependency chains, causal paths

**Categories:**
`code_pattern | api_docs | research | project_knowledge | lesson_learned | anti_pattern | architecture | debug_solution | tool_usage | domain_knowledge`

### Terminal Isolation

When running multiple workstreams, prevent context bleed:

```
Terminal A (ttys001) → locked to "payments-api"
Terminal B (ttys002) → locked to "mobile-app"
Terminal C (ttys003) → locked to "patent-filing"
```

**Implementation:**
1. SessionStart hook fingerprints terminal (TERM_SESSION_ID, iTerm tab, SSH_TTY)
2. Auto-detects workstream from CWD or asks user if ambiguous
3. Writes sticky state to `/tmp/nexus-sticky/{terminal-id}`
4. Agent reads ONLY its workstream's active-work file
5. Cross-workstream reads are blocked by hook

### Workstream-Scoped Memory

```
memory/
  MEMORY.md                         # Global index (under 200 lines)
  active-work-payments-api.md       # Terminal A's context
  active-work-mobile-app.md         # Terminal B's context
  active-work-patent-filing.md      # Terminal C's context
  reasoning/
    patterns.md                     # Self-evolving pattern library
    anti-patterns.md                # Known failure modes
    trajectories.md                 # Recent decision traces (max 20)
    meta-learning.md                # What the agent learned about learning
  daily/
    2026-04-05.md                   # Today's decisions
  archive/
    2026-Q1/                        # Quarterly archives
```

### Fleet Orchestration

For teams running agents across multiple machines:

```bash
# Dispatch to remote agents
fleet dispatch agent-name "task description" --target vps-01

# Health check all fleet members
fleet check --all

# Sync knowledge base across fleet
fleet sync kb --push

# Parallel dispatch across fleet
fleet parallel --targets vps-01,vps-02,vps-03 \
  "Run security audit on /app" --merge-findings
```

### Cross-Agent Learning

When one agent learns something, propagate it:

```
Agent A discovers pattern → writes to KB
                                ↓
                        KB triggers sync
                                ↓
Agent B, C, D pick up pattern on next KB search
```

This creates a **hive mind** — the collective intelligence of all your agents exceeds any individual.

---

## The Complete Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    SESSION LIFECYCLE                         │
│                                                             │
│  SessionStart                                               │
│    ├─ System health check (disk, memory, uptime)            │
│    ├─ Terminal fingerprint → workstream lock                 │
│    ├─ Load MEMORY.md + active-work-{workstream}.md          │
│    ├─ MCP server connectivity probe                         │
│    ├─ Check dream/consolidation gates                       │
│    └─ KB connectivity probe                                 │
│                                                             │
│  During Session                                             │
│    ├─ PreToolUse: classify → score → allow/block            │
│    ├─ MSV routing: System 1 (fast) or System 2 (deep)      │
│    ├─ MCP tool calls: schema-validated, access-controlled   │
│    ├─ Multi-agent dispatch with task objects + ownership    │
│    ├─ Worktree isolation for parallel agent execution       │
│    ├─ PostToolUse: lint → analyze → extract patterns        │
│    ├─ Back-pressure: build errors fed back automatically    │
│    ├─ Observability: trace agent calls, costs, decisions    │
│    └─ Context budget enforcement (prevent overflow)         │
│                                                             │
│  Session End                                                │
│    ├─ MEMORY.md rewrite (current state only)                │
│    ├─ active-work-{workstream}.md update                    │
│    ├─ Pattern extraction → ReasoningBank                    │
│    ├─ KB sync (learnings persisted)                         │
│    └─ Notification dispatch (Discord/Slack)                 │
│                                                             │
│  Background (Cron/Automation)                               │
│    ├─ Morning briefing (6am)                                │
│    ├─ Nightly consolidation / dream (3am)                   │
│    ├─ Knowledge decay (monthly)                             │
│    └─ Fleet sync (hourly)                                   │
└─────────────────────────────────────────────────────────────┘
```

---

## Quick Start: 20-Minute Setup (Level 3)

```bash
#!/usr/bin/env bash
set -euo pipefail

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

# 3. Create session-end hook (Stop hook — uses JSON to steer model)
cat > .claude/hooks/session-end.sh << 'HOOK_EOF'
#!/usr/bin/env bash
# Stop hook: block completion until memory is updated
# Plain stdout is NOT model-visible for Stop hooks — use JSON
printf '{"decision": "block", "reason": "Update MEMORY.md with what changed this session before stopping."}\n'
exit 0
HOOK_EOF
chmod +x .claude/hooks/session-end.sh

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

echo "Setup complete. Run 'claude' to start a session."
```

**After the 20 minutes:**
1. Start a session: `claude`
2. Verify hooks: type `/hooks` to see active hooks
3. Write some code — the lint hook should fire after edits
4. Try your first multi-agent review: ask the agent to spawn the code-reviewer

---

## The Protocol Stack

The 2026 agent ecosystem has three layers:

```
┌──────────────────────────────────────────────────────┐
│                                                      │
│  Layer 3: A2A (Agent-to-Agent)                      │
│  ────────────────────────────────────────────        │
│  Agent discovery, task delegation, negotiation       │
│  Wire: JSON over HTTP + SSE streaming                │
│  Discovery: Agent Cards (/.well-known/agent.json)    │
│                                                      │
├──────────────────────────────────────────────────────┤
│                                                      │
│  Layer 2: MCP (Model Context Protocol)              │
│  ────────────────────────────────────────────        │
│  Agent-to-tool integration                           │
│  Capabilities: Resources, Tools, Prompts, Sampling   │
│  Wire: JSON-RPC 2.0 over stdio/SSE/HTTP             │
│  97M+ monthly SDK downloads                          │
│                                                      │
├──────────────────────────────────────────────────────┤
│                                                      │
│  Layer 1: WebMCP / Direct                           │
│  ────────────────────────────────────────────        │
│  Structured web access, HTTP APIs, CLI tools         │
│  The foundation everything else builds on            │
│                                                      │
└──────────────────────────────────────────────────────┘
```

**Rule of thumb:**
- **Building tools for agents?** → MCP
- **Building agents that talk to agents?** → A2A
- **Building both?** → MCP for tools, A2A for orchestration

---

## Cost Management

Multi-agent patterns at L4+ can burn through API credits fast. Here's how to manage it.

### Model Routing

Not every task needs your most powerful model:

| Model Tier | Use For | Typical Cost |
|-----------|---------|-------------|
| **Haiku/Mini** | Worker agents, pair programming, simple reviews | $0.25-1/M tokens |
| **Sonnet/Mid** | Main dev work, orchestration, complex coding | $3-15/M tokens |
| **Opus/Max** | Architecture decisions, deep reasoning, research | $15-75/M tokens |

**Pattern: Use expensive models for planning, cheap models for execution.**

```
Opus plans the architecture (1 call, ~$0.50)
    ↓
Sonnet implements each module (5 calls, ~$1.00)
    ↓
Haiku runs code review on each file (10 calls, ~$0.25)
    ↓
Opus does final architecture review (1 call, ~$0.50)

Total: ~$2.25 vs $5.00+ if everything used Opus
```

### Context Budget Enforcement

Stay out of the last 15% of the context window — model quality degrades there.

```bash
# context-guard.sh — PostToolUse hook
USAGE=$(echo "$CLAUDE_CONTEXT_USAGE" | jq -r '.percentage // 0')
if (( $(echo "$USAGE > 85" | bc -l) )); then
  echo "WARNING: Context usage at ${USAGE}%. Consider compacting or splitting the task."
fi
```

### Token-Efficient Patterns

1. **Skills over massive CLAUDE.md** — load context on-demand, not all-at-once
2. **Error-only output** — configure tools to be silent on success
3. **Subagent context firewalls** — intermediate noise doesn't pollute the parent
4. **Structured outputs** — shorter than natural language, more precise
5. **Batch similar work** — 5 files reviewed in one agent call, not 5 separate calls

---

## Debugging Your Harness

When things break — and they will — here's how to diagnose.

### Common Failure Modes

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Agent ignores rules | CLAUDE.md too long (>100 lines) | Trim to <50 lines, move detail to rules/ |
| Agent loops on same error | Back-pressure not configured | Add PostToolUse lint/build hooks |
| Agent uses wrong tool | Too many MCP servers loaded | Prune to essential servers only |
| Agent forgets mid-session | Context window full | Add context-guard hook, split tasks |
| Hooks not firing | Settings file in wrong location | Verify `.claude/settings.json` path |
| Memory stale | No session-end update | Add Stop hook for MEMORY.md rewrite |
| Agent talks to wrong workstream | No terminal isolation | Implement SessionStart fingerprinting |
| Multi-agent findings conflict | No resolution protocol | Add conflict resolution to orchestrator |

### Diagnostic Steps

1. **Check hooks are active**: `/hooks` in Claude Code
2. **Check MCP servers**: `/mcp` to see connected servers
3. **Check context usage**: Watch for quality degradation near end of window
4. **Review memory state**: Read MEMORY.md — is it current?
5. **Test back-pressure**: Introduce a deliberate error, verify the agent catches it
6. **Trace agent dispatch**: Log which agents are called and their outputs

### The "Dumb Zone"

When an agent suddenly performs worse, it's usually one of:
- **Context overflow**: Too much loaded, model can't prioritize
- **Tool confusion**: Too many similar tools, model picks wrong one
- **Instruction conflict**: Two rules contradict each other
- **Stale patterns**: Applying outdated patterns to new code

Fix: Simplify. Remove tools, shorten instructions, clear stale memory. **Less is more.**

---

## Anti-Patterns (What NOT to Do)

1. **Memory bloat**: MEMORY.md over 200 lines = model starts skimming. Keep it a dashboard.
2. **Rule inflation**: 50+ rules in CLAUDE.md = none are followed well. Pick 10-20 critical ones.
3. **Hook overload**: >10 hooks per event = latency kills flow. Keep hot-path hooks under 5ms.
4. **No evaluation**: Running without Stop hooks = the agent never checks its own work.
5. **Single-brain trust**: One model reviewing its own code = blind spots. Use adversarial review.
6. **Flat memory**: Text files without search = context lost at scale. Graduate to a KB.
7. **Context bleed**: Multiple projects sharing one terminal = cross-contamination. Isolate workstreams.
8. **No decay**: Patterns that never expire become dogma. Implement confidence decay.
9. **All-or-nothing hooks**: Binary allow/block = too rigid. Use escalation tiers.
10. **Manual context loading**: If you're explaining context every session, your harness is broken.
11. **Premature optimization**: Designing the ideal config upfront before observing failures. Start simple, add configuration only when the agent actually fails.
12. **Tool sprawl**: Installing dozens of MCP servers and skills "just in case" — each competes for context.
13. **Auto-generated CLAUDE.md**: AI-written project instructions hurt performance while costing 20%+ more tokens. Write them yourself.
14. **Full test suite on every change**: Running all 500 tests after each edit pollutes context. Run targeted tests, full suite on commit only.
15. **Self-evaluation trust**: Agents confidently overrate their own work. Always use external evaluation.

---

## Metrics That Matter

Track these to know if your harness is working:

### Operational Metrics (Track These First)

| Metric | Target | How to Measure |
|--------|--------|---------------|
| Context re-explanation | 0 per session | If you manually explain context, harness failed |
| First-attempt accuracy | >85% | Tasks completed correctly without revision |
| Recovery from failure | <2 retries | Agent self-corrects errors without cycling |
| Change failure rate | <5% | Agent-written code that causes regressions |
| Cost per successful task | Trending down | API spend per completed feature (not per call) |
| Hook latency | <5ms hot path | PreToolUse/PostToolUse hooks stay fast |
| Security violations | 0 | Secrets committed, injection vectors introduced |
| Context budget usage | <85% | Stay out of the last 15% of context window |

### Advanced Metrics (L4+ Multi-Agent Systems)

| Metric | Target | How to Measure |
|--------|--------|---------------|
| Agent dispatch accuracy | >90% | Right agent chosen for the task |
| Rollback latency | <5 min | Time from failure detection to safe state |
| Exception rate | <1% | Agent calls that result in unhandled errors |
| Audit completeness | 100% | Every agent action logged with provenance |
| Containment time | <30 sec | Time from anomaly detection to agent halt |
| Pattern reuse rate | >60% | Tasks where existing patterns applied |
| Approval hit rate | >95% | Human-reviewed actions that get approved (low = agent wasting time on bad proposals) |

---

## What Your Harness Looks Like at Each Level

| Time | L3 (Basic) | L5 (Self-Evolving) | L7 (Distributed) |
|------|-----------|-------------------|------------------|
| **Session start** | Reads MEMORY.md, hooks active | + Loads patterns, probes KB, computes MSV | + Terminal isolation, workstream lock, fleet sync |
| **During work** | Hooks verify safety, MCP tools available | + Multi-lens reasoning, dual-brain dispatch | + Graph-powered retrieval, behavioral scoring |
| **On commit** | Lint + type-check passes | + Pattern extraction, async adversarial review | + Fleet-wide learning propagation |
| **Session end** | Updates MEMORY.md | + ReasoningBank sync, trajectory logging | + Workstream-scoped handoff, notification |
| **Overnight** | Git commits preserved | + Dream consolidation, confidence decay | + Fleet consolidation, KB clustering |
| **Next morning** | Briefing available | + MSV-informed priorities, pattern-matched tasks | + Cross-workstream insights, fleet dashboard |

---

## Research Sources

> Sources are classified: **Primary** (official docs, engineering blogs from the companies building these systems), **Academic** (peer-reviewed or preprint), **Industry** (frameworks, standards bodies), **Secondary** (analysis, commentary — useful context but not authoritative). When claims conflict, primary and academic sources govern.

### Foundational (Primary)
- [Martin Fowler — Harness Engineering](https://martinfowler.com/articles/exploring-gen-ai/harness-engineering.html) (2026)
- [Martin Fowler — Harness Engineering for Coding Agents](https://martinfowler.com/articles/harness-engineering.html) (2026)
- [Anthropic — Harness Design for Long-Running Apps](https://www.anthropic.com/engineering/harness-design-long-running-apps) (2026)
- [OpenAI — Harness Engineering](https://openai.com/index/harness-engineering/) (2026)
- [LangChain — Anatomy of an Agent Harness](https://blog.langchain.com/the-anatomy-of-an-agent-harness/) (2026)

### Architecture & Patterns (Primary + Secondary)
- [HumanLayer — Skill Issue: Harness Engineering for Coding Agents](https://www.humanlayer.dev/blog/skill-issue-harness-engineering-for-coding-agents)
- [GitHub — Multi-Agent Workflows That Don't Fail](https://github.blog/ai-and-ml/generative-ai/multi-agent-workflows-often-fail-heres-how-to-engineer-ones-that-dont/)
- [GitHub — Building Reliable AI Workflows with Agentic Primitives](https://github.blog/ai-and-ml/github-copilot/how-to-build-reliable-ai-workflows-with-agentic-primitives-and-context-engineering/)
- [GitHub — Context Engineering for Better AI Outputs](https://github.blog/ai-and-ml/generative-ai/want-better-ai-outputs-try-context-engineering/)
- [NxCode — What Is Harness Engineering? Complete Guide 2026](https://www.nxcode.io/resources/news/what-is-harness-engineering-complete-guide-2026)
- [Phil Schmid — The Importance of Agent Harness in 2026](https://www.philschmid.de/agent-harness-2026)

### Protocols (Primary)
- [MCP Architecture Overview](https://modelcontextprotocol.io/docs/learn/architecture)
- [IBM — MCP Architecture Patterns for Multi-Agent AI Systems](https://developer.ibm.com/articles/mcp-architecture-patterns-ai-systems/)
- [Pinterest — Production-Scale MCP Ecosystem](https://www.infoq.com/news/2026/04/pinterest-mcp-ecosystem/)
- [MCP vs A2A: Complete Guide to AI Agent Protocols 2026](https://dev.to/pockit_tools/mcp-vs-a2a-the-complete-guide-to-ai-agent-protocols-in-2026-30li)
- [Building AI-Native Applications with MCP 2026](https://dev.to/universe7creator/the-complete-guide-to-model-context-protocol-mcp-building-ai-native-applications-in-2026-5e57)

### Production Case Studies (Secondary — analysis/commentary)
- [Claude Code Agent Harness Architecture](https://wavespeed.ai/blog/posts/claude-code-agent-harness-architecture/)
- [Claude Code Leak: Agentic Architecture Lessons](https://www.digitalapplied.com/blog/claude-code-leak-agentic-architecture-lessons-2026)
- [Everything Claude Code: The Agent Harness Your Team Is Missing](https://www.bighatgroup.com/blog/everything-claude-code-ai-agent-harness-guide/)
- [Cursor 3 Multi-Agent Architecture](https://www.digitalapplied.com/blog/cursor-3-agents-window-design-mode-complete-guide)
- [Devin 2.0 Agent-Native Design](https://medium.com/@takafumi.endo/agent-native-development-a-deep-dive-into-devin-2-0s-technical-design-3451587d23c0)
- [Circuit Breaker Resilience for Agentic AI](https://medium.com/@michael.hannecke/resilience-circuit-breakers-for-agentic-ai-cc7075101486)

### Academic
- [ArXiv 2506.05109 — Truly Self-Improving Agents Require Intrinsic Metacognitive Learning](https://arxiv.org/abs/2506.05109)
- [ArXiv 2603.19461 — Hyperagents: Meta-Level Improvements Transferring Across Domains](https://arxiv.org/abs/2603.19461)
- [ArXiv 2507.21046 — A Survey of Self-Evolving Agents](https://arxiv.org/abs/2507.21046)
- [ArXiv 2508.07407 — Self-Evolving AI Agents: Bridging Foundation Models and Lifelong Systems](https://arxiv.org/abs/2508.07407)

### Official Product Docs (Primary)
- [Claude Code — Hooks Documentation](https://docs.anthropic.com/en/docs/claude-code/hooks)
- [Claude Code — Sub-Agents Documentation](https://docs.anthropic.com/en/docs/claude-code/sub-agents)
- [Claude Code — Agent Teams](https://docs.anthropic.com/en/docs/claude-code/teams)
- [Windsurf — Rules, Agents, and Memories](https://docs.windsurf.com/windsurf/cascade/memories)

### Industry Frameworks & Standards
- [Sema4.ai — Five Levels of Agentic Automation](https://sema4.ai/blog/the-five-levels-of-agentic-automation/) (autonomy taxonomy, not harness maturity)
- [CSA — Autonomy Levels for Agentic AI (L0-L5)](https://cloudsecurityalliance.org/blog/2026/01/28/levels-of-autonomy) (autonomy taxonomy with governance requirements)
- [CSA — Agentic Trust Framework: Zero Trust Governance](https://cloudsecurityalliance.org/blog/2026/02/02/the-agentic-trust-framework-zero-trust-governance-for-ai-agents) (Intern→Principal promotion model, kill switches, rollback, least-privilege)
- [MCP Authorization Specification](https://modelcontextprotocol.io/specification/2025-06-18/basic/authorization) (token scoping, short-lived credentials)
- [GitHub — /fleet: Multiple Agents with Copilot CLI](https://github.blog/ai-and-ml/github-copilot/run-multiple-agents-at-once-with-fleet-in-copilot-cli/) (task objects, ownership, dependency graphs)
- [State of AI Agent Memory 2026](https://mem0.ai/blog/state-of-ai-agent-memory-2026)
- [LangGraph vs CrewAI vs AutoGen Comparison](https://o-mega.ai/articles/langgraph-vs-crewai-vs-autogen-top-10-agent-frameworks-2026)
- [Maxim AI — Agent Evaluation 2026](https://www.getmaxim.ai/articles/top-5-tools-for-agent-evaluation-in-2026/)
- [GitHub Agent HQ for Engineering Teams](https://www.eficode.com/blog/why-github-agent-hq-matters-for-engineering-teams-in-2026)
- [awesome-agent-skills](https://github.com/VoltAgent/awesome-agent-skills) — 1000+ community agent skills
- [claude-code-harness](https://github.com/Chachamaru127/claude-code-harness) — Plan-Work-Review autonomous harness

---

*The difference between levels: L1 people rewrite prompts every session. L7 people wake up to work already done, reviewed by a second brain, with learnings persisted and knowledge growing overnight.*

*You don't need to reach L7 to be effective. Most teams would see massive gains just reaching L3. But now you know what's possible.*
