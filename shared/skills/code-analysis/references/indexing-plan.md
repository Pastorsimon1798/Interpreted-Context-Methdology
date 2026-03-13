# jCodeMunch Indexing Plan

Repositories and codebases to index for efficient exploration.

## Priority 1: Active ICM Projects (Index First)

### ICM Repository
```
Path: /Users/simongonzalezdecruz/Desktop/Interpreted-Context-Methdology/
Files: ~281 (md, sh, js, ts, py)
Purpose: Main documentation and workspace structure
```

**Exclude:**
- `node_modules/`
- `.git/`
- `output/` (generated)
- `logs/` (generated)

---

### agent-swarm-simulator
```
Path: /Users/simongonzalezdecruz/Desktop/agent-swarm-simulator/
Files: ~132 source files
Purpose: Agent simulation code (TypeScript/JavaScript)
```

**Exclude:**
- `node_modules/`
- `.git/`
- `dist/`
- `.pi/`
- `__tests__/` (optional - if not analyzing tests)

---

### AudioJournal
```
Path: /Users/simongonzalezdecruz/Desktop/AudioJournal/
Files: ~278 source files
Purpose: Audio journaling application
```

**Exclude:**
- `node_modules/`
- `.git/`
- `dist/`
- `build/`
- iOS/Android build directories

---

### Agent Project (Selective)
```
Path: /Users/simongonzalezdecruz/Desktop/Agent Project/
Key subdirectories:
  - efva/              (Python voice agent)
  - goose-skills/      (Skills for Goose agent)
  - *.md               (Architecture docs)
```

**Exclude:**
- `efva/__pycache__/`
- `efva/.venv/`
- `efva-test/` (test code)
- All `.git/` directories

---

## Priority 2: Frequently Researched GitHub Repos

Index these directly from GitHub when researching specific topics:

### AI/Agent Frameworks
| Repo | Use Case |
|------|----------|
| `anthropics/claude-code` | Claude Code patterns, MCP integration |
| `anthropics/anthropic-cookbook` | Claude API patterns |
| `modelcontextprotocol/servers` | MCP server implementations |
| `openai/openai-node` | OpenAI SDK patterns |

### Research/Search Tools
| Repo | Use Case |
|------|----------|
| `mendableai/firecrawl` | Web scraping patterns |
| `exa-labs/exa-search-sdk` | Search API usage |
| `run-llama/llama_index` | RAG patterns |

### Workflow/Protocol Projects
| Repo | Use Case |
|------|----------|
| `githubnext/monaspace` | Font/typography (if relevant) |
| `continuedev/continue` | IDE extension patterns |

---

## Priority 3: On-Demand Indexing

Index these when working on specific tasks:

### Knowledge Base
```
Path: ~/knowledge-base/
When: Researching personal notes, saved articles
```

### Google Workspace Agent
```
Path: /Users/simongonzalezdecruz/Desktop/Interpreted-Context-Methdology/workspaces/google-workspace-agent/
When: Working on GWS automation
```

---

## Exclusion Patterns

Standard exclusions for all local indexes:

```
node_modules/
.git/
dist/
build/
output/
logs/
__pycache__/
.venv/
*.min.js
*.min.css
```

---

## Indexing Commands

### Quick Reference

```bash
# ICM (documentation-heavy)
index_folder(path="/Users/simongonzalezdecruz/Desktop/Interpreted-Context-Methdology")

# Agent swarm (TypeScript)
index_folder(path="/Users/simongonzalezdecruz/Desktop/agent-swarm-simulator")

# AudioJournal (multi-platform app)
index_folder(path="/Users/simongonzalezdecruz/Desktop/AudioJournal")

# GitHub repo (direct)
index_github_repo(repo_url="https://github.com/anthropics/claude-code")
```

---

## Index Status Tracking

| Repository | Status | Last Indexed | Notes |
|------------|--------|--------------|-------|
| ICM | ⬜ Not indexed | - | Priority 1 |
| agent-swarm-simulator | ⬜ Not indexed | - | Priority 1 |
| AudioJournal | ⬜ Not indexed | - | Priority 1 |
| Agent Project/efva | ⬜ Not indexed | - | Priority 1 |
| claude-code (GitHub) | ⬜ Not indexed | - | On-demand |
| MCP servers (GitHub) | ⬜ Not indexed | - | On-demand |

---

## Usage Patterns After Indexing

### ICM Repository
```
search_symbols(query="research pipeline")
search_symbols(query="CONTEXT.md")
search_symbols(query="skill|SKILL")
list_symbols() → See all workspaces and stages
```

### Agent Projects
```
search_symbols(query="agent|Agent")
search_symbols(query="tool|Tool")
get_call_graph(function_name="processMessage")
find_references(symbol_id="Agent")
```

### GitHub Research
```
search_symbols(query="MCP|server")
search_symbols(query="anthropic|claude")
retrieve_symbol(symbol_id="tool_definition")
```

---

## Refresh Schedule

| Type | Frequency |
|------|-----------|
| Active projects (ICM, agent-swarm) | After significant changes |
| GitHub repos | Before research sessions |
| Stable projects | Monthly or on-demand |

---

## Notes

- Indexes persist across sessions - no need to re-index
- Use `get_index_status()` to check if index exists
- Re-index only when files have changed significantly
- Token savings compound over multiple queries on same index
