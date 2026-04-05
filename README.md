# The Definitive Agent Harness Guide

## Beyond Prompt Engineering: 7 Levels of Agent Mastery

**80% of people using AI agents are stuck at Level 1.** They write better prompts and wonder why the AI forgets everything next session. This guide shows the 7 levels that separate casual users from people whose agents run autonomously, review their own code, and grow smarter overnight.

| Level | Name | What You Build |
|-------|------|----------------|
| **L1** | Prompt Engineering | Better instructions per session |
| **L2** | Context Engineering | Persistent memory, CLAUDE.md, rules |
| **L3** | Harness Engineering | Hooks, MCP servers, skills, back-pressure |
| **L4** | Orchestration Engineering | Multi-agent coordination, typed contracts |
| **L5** | Self-Evolution Engineering | Agent improves its own patterns |
| **L6** | Adversarial Engineering | Security hardening, kill-chain detection |
| **L7** | Distributed Intelligence | Cross-session learning, fleet orchestration |

Most teams would see massive gains just reaching L3. But now you know what's possible.

## What's Inside

- **1500+ lines** of production-tested patterns and real code examples
- **60+ research sources** — Fowler, Anthropic, OpenAI, LangChain, HumanLayer, GitHub, ArXiv
- **20-minute Quick Start** to reach Level 3 immediately
- **Hook visibility rules** — the #1 mistake in harness engineering, explained
- **MCP integration patterns** — when to use MCP vs CLI vs direct API
- **Multi-agent orchestration** — typed schemas, agent discovery, control planes
- **Cost management**, **debugging strategies**, and **anti-patterns** sections
- **Post-adversarial reviewed** — two rounds of adversarial critique, all findings fixed

## Quick Start

```bash
# Clone and run the 20-minute setup
git clone https://github.com/OpenMind7/definitive-agent-harness-guide.git
cd definitive-agent-harness-guide
bash examples/quick-start.sh
```

This creates CLAUDE.md, MEMORY.md, hooks, and your first agent in under 5 minutes.

## Read the Guide

**[guide.md](guide.md)** — the complete 1500+ line guide

## Templates

| Template | Description |
|----------|-------------|
| [templates/CLAUDE.md](templates/CLAUDE.md) | Starter project instructions |
| [templates/MEMORY.md](templates/MEMORY.md) | Session memory dashboard |
| [templates/settings.json](templates/settings.json) | Hook configuration |
| [templates/code-reviewer.md](templates/code-reviewer.md) | Code review agent |
| [templates/pre-bash-safety.sh](templates/pre-bash-safety.sh) | Dangerous command blocker |
| [templates/session-end.sh](templates/session-end.sh) | Memory update enforcer |
| [templates/lint-on-edit.sh](templates/lint-on-edit.sh) | Auto-lint on file changes |

## Examples

| Example | Level | Description |
|---------|-------|-------------|
| [examples/quick-start.sh](examples/quick-start.sh) | L3 | 20-minute setup script |
| [examples/mcp-knowledge-base/](examples/mcp-knowledge-base/) | L3 | Domain-specific MCP server pattern |
| [examples/multi-agent-review/](examples/multi-agent-review/) | L4 | Parallel code review with typed contracts |

## Who This Is For

- **Developers** using Claude Code, Cursor, Windsurf, Copilot, or any AI coding agent
- **Teams** wanting reliable, repeatable AI-assisted workflows
- **Architects** designing multi-agent systems for production
- **Anyone** tired of re-explaining context to their AI every session

## Framework Agnostic

While examples use Claude Code syntax, every concept applies to any agent framework. The principles (hooks, memory layers, back-pressure, orchestration) are universal.

## Research Sources

The guide cites 60+ sources across 5 categories:
- **Primary**: Martin Fowler, Anthropic, OpenAI, LangChain, HumanLayer
- **Architecture**: GitHub Engineering, MCP specification, Pinterest, IBM
- **Academic**: ArXiv papers on self-evolving agents and metacognitive learning
- **Industry**: Sema4.ai, CSA, Mem0, LangGraph, GitHub Fleet
- **Case Studies**: Claude Code, Cursor 3, Devin 2.0 architectures

## Contributing

Found an error? Have a pattern to share? PRs welcome. Please keep contributions:
- Backed by real production experience or cited research
- Framework-agnostic where possible
- Concise — every line should earn its place

## License

[MIT](LICENSE) — use it, share it, build on it.

---

*The difference between levels: L1 people rewrite prompts every session. L7 people wake up to work already done, reviewed by a second brain, with learnings persisted and knowledge growing overnight.*
