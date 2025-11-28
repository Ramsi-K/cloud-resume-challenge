# Discord MCP Server

![Discord MCP](../assets/images/project_icons/discord-mcp.webp)

**Model Context Protocol server for Discord integration. Enables AI assistants to interact with Discord servers through intelligent workflows and atomic operations.**

<div class="section-label">Project Status</div>

**Status**: Alpha Development (v0.0.1) | **License**: MIT | **Testing**: MCP Inspector

---

## Project Overview

Built an MCP-compliant Discord integration server that enables AI assistants like Claude to interact with Discord servers through a consolidated workflow architecture. The project combines atomic operations with intelligent, LLM-powered workflows for natural language Discord management.

<div class="section-label">Architecture Highlights</div>

- **9 tools** (consolidated from 26) - Simplified, powerful interface
- **Natural language** - Workflows understand intent (e.g., "find channel general")
- **Template-based messaging** - Rich Discord messages via Jinja2 templates
- **Production-ready** - Comprehensive integration tests with real Discord API

---

## Key Features

### Atomic Tools (3)

Fast, direct operations for specific tasks:

- **discord_send** - Send messages with reply/embed support
- **discord_get** - Get entity details by ID (server, channel, role, member, message)
- **discord_list** - List entities with pagination (servers, channels, roles, members)

### Intelligent Workflows (4)

Multi-step operations with natural language understanding:

#### Discovery Workflow

- Find servers/channels/roles by name
- Example: `intent="find channel general in MyServer"`
- Uses LLM-powered fuzzy matching

#### Message Workflow

- Send messages with templates and smart routing
- Example: `intent="send tournament announcement to #events"`
- Supports Jinja2 templates for rich formatting

#### Campaign Workflow

- Full campaign lifecycle management
- Create reaction-based opt-in campaigns
- Tally reactions, build reminders, send to opted-in users
- Example: `intent="create campaign for tournament signup"`

#### Diagnostics Workflow

- Bot health and permissions checks
- Actions: status, ping, verify_access, check_permissions, health_report
- Graceful offline handling

### Automation

- **discord_run_due_reminders** - Process scheduled campaign reminders (cron job)

---

## Architecture & Technical Approach

### System Flow

```text
AI Assistant
  → MCP Client
  → Discord MCP Server
  → Discord Bot
  → Discord API
  → SQLite Database (campaigns, reminders)
```

### Technology Stack

- **MCP Protocol**: Full implementation with tools, prompts, and resources
- **Discord.py**: Discord API wrapper
- **SQLite**: Campaign and reminder persistence
- **Jinja2**: Message template engine
- **Python 3.10+**: Core implementation
- **uv**: Package manager

### Project Structure

```text
discord-mcp/
├── src/discord_mcp/
│   ├── server.py             # MCP server + prompts/resources
│   ├── discord_client/       # Discord bot implementation
│   ├── database/             # SQLite models, repos, migrations
│   ├── tools/                # Tool registration (atomic + legacy)
│   ├── workflows/            # 4 workflow implementations
│   ├── internal/             # Helpers (intent parser, access control)
│   └── resources/            # Templates & prompts
├── tests/
│   ├── unit/                 # Unit tests (mocks)
│   └── integration/          # Integration tests (real Discord)
└── docs/                     # Architecture & workflow docs
```

---

## Development & Testing

### MCP Inspector Testing

The project uses MCP Inspector for local testing before deployment:

```bash
# Start MCP Inspector
npx @modelcontextprotocol/inspector python -m discord_mcp

# Test tools in browser UI
# - Atomic operations (send, get, list)
# - Workflows (discovery, message, campaign, diagnostics)
# - Natural language intents
```

### Configuration

Environment variables for bot configuration:

| Variable              | Description                                   |
| --------------------- | --------------------------------------------- |
| `DISCORD_TOKEN`       | Discord bot token (required)                  |
| `MCP_DISCORD_DB_PATH` | SQLite database path                          |
| `GUILD_ALLOWLIST`     | Comma-separated server IDs to restrict access |
| `LOG_LEVEL`           | Logging level (DEBUG, INFO, WARNING, ERROR)   |
| `DRY_RUN`             | Test mode without Discord API calls           |

---

## Skills Demonstrated

**MCP Protocol Design**: Tool registration, workflow architecture, prompt engineering, resource management

**Discord API Integration**: Bot development, message handling, reaction tracking, permission management

**Software Architecture**: Consolidated workflow design, atomic operations, separation of concerns

**Database Design**: SQLite schema, repository pattern, campaign persistence, reminder scheduling

**Natural Language Processing**: Intent parsing, fuzzy matching, LLM-powered entity discovery

**Template Engineering**: Jinja2 templates, rich message formatting, dynamic content generation

**Testing Strategy**: Unit tests with mocks, integration tests with real API, MCP Inspector validation

**DevOps**: Package distribution, environment configuration, logging, error handling

---

## Release Roadmap

- **Local Development** (Current) - Testing with MCP Inspector
- **Alpha (0.0.x)** - Publish to PyPI for Claude Desktop testing
- **Beta (0.1.x)** - Feature-complete, polishing bugs
- **Release (1.0.0)** - Stable, production-ready

### Future Features

- Role management workflows
- Member analytics and insights
- Thread support
- Advanced permission checks
- Webhook integration

---

## Links

- **GitHub**: [mcp-discord](https://github.com/Ramsi-K/mcp-discord)
- **Documentation**: [Architecture Guide](https://github.com/Ramsi-K/mcp-discord/blob/main/docs/ARCHITECTURE.md)
- **Workflows**: [Discovery](https://github.com/Ramsi-K/mcp-discord/blob/main/docs/DISCOVERY_FLOW.md) | [Message](https://github.com/Ramsi-K/mcp-discord/blob/main/docs/MESSAGE_FLOW.md) | [Campaign](https://github.com/Ramsi-K/mcp-discord/blob/main/docs/CAMPAIGN_FLOW.md)
- **Issues**: [GitHub Issues](https://github.com/Ramsi-K/mcp-discord/issues)

---

[← Back to Projects](index.md)
