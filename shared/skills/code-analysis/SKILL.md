---
name: code-analysis
description: Token-efficient repository exploration using jCodeMunch-MCP. Works with code (14+ languages) via tree-sitter AST parsing. Use when analyzing codebases, finding functions, exploring repository structure, or navigating large projects. Triggers on: analyze code, find function, explore repo, navigate codebase, code search
---

# Code Analysis (jCodeMunch-MCP)

Token-efficient repository exploration that saves 80-99% of tokens compared to traditional file reading. Works with code via tree-sitter AST parsing.

## When to Use

Invoke this skill when:
- Exploring unfamiliar codebases
- Finding specific functions, classes, or methods
- Understanding project architecture without reading entire files
- Analyzing large repositories (>1,000 files)
- Multi-agent workflows sharing repository knowledge

**For Markdown documentation, use jDocMunch (companion product)** - see `shared/skills/doc-analysis/SKILL.md`

## Supported Languages

Python, JavaScript, TypeScript, Go, Rust, Java, PHP, Dart, C#, C, C++, Elixir, Ruby, SQL

## Token Savings

| Task | Traditional | With jCodeMunch | Savings |
|------|-------------|-----------------|---------|
| Find one function in 338-file repo | ~7,500 tokens | ~1,449 tokens | **80%** |
| Navigate large codebase | 40,000+ tokens | 200-500 tokens | **99%** |

## Prerequisites

**MCP Server Required:** jCodeMunch-MCP must be configured in Claude Code.

**Installation:**
```bash
pip install jcodemunch-mcp
# Or use uvx (recommended for MCP clients)
uvx jcodemunch-mcp
```

**MCP Config (`~/.mcp.json`):**
```json
{
  "mcpServers": {
    "jcodemunch": {
      "command": "uvx",
      "args": ["jcodemunch-mcp"]
    }
  }
}
```

## Tool Selection Guide

```
┌─────────────────────────────────────────────────────────────┐
│ WHAT DO YOU NEED?                                           │
│                                                             │
│ "What's in this repo?"                                      │
│   └─► index_folder → get_repo_outline                       │
│                                                             │
│ "Where is function X defined?"                              │
│   └─► search_symbols → get_symbol                           │
│                                                             │
│ "Show me the full implementation"                           │
│   └─► get_symbol                                            │
│                                                             │
│ "Index a GitHub repo"                                       │
│   └─► index_repo                                            │
│                                                             │
│ "Search for text (not symbols)"                             │
│   └─► search_text                                           │
└─────────────────────────────────────────────────────────────┘
```

## MCP Tools (12 Available)

| Tool | Purpose | When to Use |
|------|---------|-------------|
| `index_folder` | Index local directory | Starting point for local analysis |
| `index_repo` | Index GitHub repository | Research Pipeline integration |
| `list_repos` | List indexed repositories | See what's available |
| `get_repo_outline` | High-level repo overview | Quick overview |
| `get_file_tree` | Repository file structure | Navigate directories |
| `get_file_outline` | Symbols in a file | File-level exploration |
| `get_file_content` | Cached file content | Read file slices |
| `search_symbols` | Search symbols with filters | Find specific functions/classes |
| `get_symbol` | Full source of one symbol | Read implementation |
| `get_symbols` | Batch retrieve symbols | Read multiple at once |
| `search_text` | Full-text search | Find non-symbol content |
| `invalidate_cache` | Delete cached index | Force re-index |

## ICM Index Status

**ALREADY INDEXED. No setup required.**

| Repo ID | Files | Symbols | Languages |
|---------|-------|---------|-----------|
| `local/Interpreted-Context-Methdology-d323f6ef` | 32 | 285 | Python, JS, Bash, TSX |

**Use immediately:** `search_symbols(repo="local/Interpreted-Context-Methdology-d323f6ef", query="...")`

## Workflow Patterns

### Pattern 1: Repository Overview

```
1. index_folder(path="/path/to/repo")
2. get_repo_outline(repo="repo-name") → Get overview
3. get_file_tree(repo="repo-name") → Navigate structure
```

### Pattern 2: Find Specific Function

```
1. search_symbols(repo="repo-name", query="function_name") → Get matches
2. get_symbol(repo="repo-name", symbol_id="...") → Get full implementation
```

### Pattern 3: Understand a Class

```
1. get_file_outline(repo="repo-name", file_path="src/auth.py")
2. get_symbols(repo="repo-name", symbol_ids=["..."])
```

### Pattern 4: Research Pipeline Integration

```
1. index_repo(url="owner/repo")
2. search_symbols(repo="owner/repo", query="api|endpoint|route")
3. get_symbol(repo="owner/repo", symbol_id="...") → Get relevant code
```

## Symbol IDs

Symbol IDs follow the format:
```
{file_path}::{qualified_name}#{kind}
```

Examples:
- `src/main.py::UserService#class`
- `src/main.py::UserService.login#method`
- `src/utils.py::authenticate#function`

## Common Mistakes

| Don't | Do Instead |
|-------|------------|
| Read entire files to find one function | Use search_symbols + get_symbol |
| Grep for definitions | Use jCodeMunch's AST-based search |
| Skip indexing for large repos | Index once, query many times |

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────────┐
│              JCODEMUNCH QUICK REFERENCE                     │
├─────────────────────────────────────────────────────────────┤
│  NEW LOCAL REPO?       →  index_folder                      │
│  NEW GITHUB REPO?      →  index_repo                        │
│  WHAT'S AVAILABLE?     →  list_repos                        │
│  REPO OVERVIEW?        →  get_repo_outline                  │
│  FIND FUNCTION?        →  search_symbols → get_symbol       │
│  FULL CODE?            →  get_symbol                        │
│  BATCH RETRIEVE?       →  get_symbols                       │
│  SEARCH TEXT?          →  search_text                       │
│  FORCE RE-INDEX?       →  invalidate_cache → index_folder   │
│                                                             │
│  WORKFLOW: Index → Search → Get Symbol                      │
│  SAVINGS: 80-99% fewer tokens than reading files            │
│  FOR MARKDOWN: Use jDocMunch instead                        │
└─────────────────────────────────────────────────────────────┘
```
