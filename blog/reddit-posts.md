# Reddit Posts for The Definitive Agent Harness Guide

## r/ClaudeAI

**Title:** I wrote a 1500-line guide to agent harness engineering after studying 60+ sources. Here's the biggest mistake almost everyone makes.

**Body:**

After months of building production agent systems (170+ patterns, 12K+ hook lines, dual-brain architecture with Claude + GPT), I distilled everything into a structured guide covering 7 levels of agent engineering.

**The #1 mistake:** Hook stdout visibility. Most harness guides (including early drafts of mine) show examples like:

```bash
# PreToolUse hook
echo "WARNING: Dangerous command detected"
exit 0
```

**This doesn't work.** Plain stdout from PreToolUse, PostToolUse, and Stop hooks is NOT visible to the model. Only `SessionStart` and `UserPromptSubmit` show plain stdout. For other hooks, you need:

```bash
# Correct: JSON additionalContext
printf '{"additionalContext": "WARNING: Dangerous command detected"}\n'
exit 0

# Or block with stderr
echo "BLOCKED: Destructive command" >&2
exit 2
```

This one fix makes your hooks actually steer the agent instead of silently doing nothing.

**The 7 levels:**

| Level | Name | Who's Here |
|-------|------|------------|
| L1 | Prompt Engineering | 80% of users |
| L2 | Context Engineering | 15% |
| L3 | Harness Engineering | 4% |
| L4 | Orchestration Engineering | <1% |
| L5 | Self-Evolution | <0.1% |
| L6 | Adversarial Engineering | <0.01% |
| L7 | Distributed Intelligence | Bleeding edge |

Most people are stuck at L1. Most teams would see massive gains just reaching L3.

The guide includes a 20-minute Quick Start script, ready-to-use hook templates, agent definitions, and a framework translation table (concepts map to Cursor, Copilot, Windsurf too).

**Full guide:** https://github.com/OpenMind7/definitive-agent-harness-guide

Two rounds of adversarial review (including GPT-5.4 as hostile reviewer). All findings fixed. 60+ cited sources from Fowler, Anthropic, OpenAI, HumanLayer, GitHub, ArXiv.

Happy to answer questions about any level.

---

## r/MachineLearning

**Title:** [P] The Definitive Agent Harness Guide — 7 levels of agent engineering, 60+ research sources, production-tested patterns

**Body:**

I've been building production agent harness systems for the past year and compiled everything into a structured guide: https://github.com/OpenMind7/definitive-agent-harness-guide

**What it covers:**

The guide maps agent engineering across 7 maturity levels — from one-shot prompt engineering (L1) to distributed intelligence with cross-session learning and fleet orchestration (L7). Key sections:

- **Hook lifecycle engineering** with correct stdout visibility rules (the most common mistake in harness guides)
- **MCP integration patterns** — when to use MCP vs CLI vs direct API
- **Multi-agent orchestration** — typed schemas, control planes, agent-to-agent protocols
- **Self-evolution patterns** — confidence-weighted pattern libraries with decay, metacognitive state vectors for automatic depth routing
- **Security architecture** — least-privilege auth, kill switches, tamper-evident audit (referencing CSA's Agentic Trust Framework)

**Key insight from the research:** Harness maturity and agent autonomy are orthogonal axes. Sema4.ai and CSA define autonomy taxonomies (L0-L5). This guide defines a harness-maturity ladder. Best practice: maturity should always lead autonomy.

1500+ lines, 60+ sources (Fowler, Anthropic, OpenAI, LangChain, HumanLayer, GitHub, ArXiv, Sema4.ai, CSA). Two rounds of adversarial review.

Examples use Claude Code syntax but every concept (hooks, memory layers, back-pressure, orchestration) is framework-agnostic.

---

## r/artificial

**Title:** Most people using AI agents are stuck at Level 1. Here are 7 levels of agent engineering.

**Body:**

After building production AI agent systems and studying 60+ research sources, I mapped agent engineering into 7 maturity levels:

**L1 — Prompt Engineering (80% of users)**
You write better prompts every session. Output quality varies wildly. Everything resets.

**L2 — Context Engineering (15%)**
Persistent files (CLAUDE.md, MEMORY.md) that load automatically. The agent remembers across sessions.

**L3 — Harness Engineering (4%)**
Hooks that fire on lifecycle events. MCP servers for tool integration. Back-pressure loops that feed build errors back to the agent automatically. This is where reliability begins.

**L4 — Orchestration Engineering (<1%)**
Multiple specialized agents working in concert. Typed contracts between agents. Control planes with task objects, ownership, and budget limits.

**L5-L7 — Self-Evolution, Adversarial, Distributed (experimental)**
Agents that improve their own patterns over time, protect against attacks, and share knowledge across sessions and machines.

**The practical takeaway:** You don't need L7 to be effective. Most teams would see massive gains just reaching L3 — persistent context, hooks that steer the agent, and back-pressure loops that catch errors automatically.

Full guide with code examples, templates, and a 20-minute Quick Start: https://github.com/OpenMind7/definitive-agent-harness-guide

The concepts apply to any agent framework (Claude Code, Cursor, Copilot, Windsurf, OpenAI agents).
