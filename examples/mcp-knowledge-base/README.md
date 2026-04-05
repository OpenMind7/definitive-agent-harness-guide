# MCP Knowledge Base Server — Example

This example demonstrates the domain-specific MCP server pattern from Level 3b of the guide.

## Pattern

Instead of one monolithic MCP server, build small domain-specific servers:

```
Agent
  ├── mcp-knowledge-base  (this example)
  ├── mcp-github          (PRs, issues, search)
  ├── mcp-postgres        (database queries)
  └── mcp-monitoring      (metrics, alerts)
```

Each server has its own security boundary, can be versioned independently, and limits context bloat.

## Configuration

Add to your `.claude/settings.json`:

```json
{
  "mcpServers": {
    "knowledge-base": {
      "command": "node",
      "args": ["./mcp-servers/kb-server/index.js"],
      "env": {
        "KB_PATH": "/path/to/knowledge.db"
      }
    }
  }
}
```

## When to Use MCP vs CLI

| Approach | Use When |
|----------|----------|
| **MCP server** | Custom integrations, structured data, access control needed |
| **CLI tool** | Well-known tool already in training data (git, npm, docker) |
| **Direct API** | One-off calls, no reuse needed |

## Anti-Patterns

- **Tool sprawl**: 20+ MCP servers "just in case" — each tool description consumes context
- **God server**: One server with 50 tools — the agent can't choose effectively
- **CLI duplication**: Wrapping git/npm as MCP when the agent already knows them
- **Missing schemas**: Tools without explicit input/output schemas

See the full guide for implementation details and production patterns.
