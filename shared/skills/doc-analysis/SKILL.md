---
name: doc-analysis
description: Token-efficient documentation navigation using jDocMunch-MCP. Works with Markdown, MDX, RST, TXT, JSON, XML, HTML, AsciiDoc, Jupyter notebooks. PRIMARY tool for ICM's documentation-heavy structure (93% markdown). Use when finding sections, navigating CLAUDE.md files, or reading methodology docs. Triggers on: find section, navigate docs, documentation search, CLAUDE.md, CONTEXT.md
---

# Documentation Analysis (jDocMunch-MCP)

Token-efficient documentation navigation that saves 80-99% of tokens compared to reading entire markdown files. **PRIMARY tool for ICM's documentation-heavy structure.**

## Why jDocMunch for ICM

ICM is ~93% markdown (405+ .md files vs ~32 code files). jDocMunch enables:
- Section-based retrieval: "get the routing table" instead of "read all of CLAUDE.md"
- Semantic search across all documentation
- 80-99% token savings on documentation navigation

## When to Use

Invoke this skill when:
- Finding sections in CLAUDE.md files
- Navigating stage CONTEXT.md files
- Reading methodology documentation
- Any "find the section about X" request
- Searching across all ICM documentation

**ALWAYS use jDocMunch instead of Read/Glob/Grep for markdown navigation.**

## Supported File Types

| Format | Extensions | Notes |
|--------|------------|-------|
| Markdown | `.md`, `.markdown` | ATX (`# Heading`) and setext headings |
| MDX | `.mdx` | JSX tags, frontmatter, import/export stripped |
| Plain text | `.txt` | Paragraph-block section splitting |
| RST | `.rst` | reStructuredText support |
| AsciiDoc | `.adoc`, `.asciidoc` | ATX-style headings |
| HTML | `.html`, `.htm` | Converted to text, script/style stripped |
| Jupyter | `.ipynb` | Notebook cells converted to markdown |
| JSON | `.json`, `.jsonc` | Top-level keys become headings |
| XML | `.xml`, `.svg`, `.xhtml` | Element hierarchy to headings |
| OpenAPI | `.yaml`, `.yml`, `.json` | Auto-detected, operations by tag |

## Token Savings

| Task | Traditional | With jDocMunch | Savings |
|------|-------------|-----------------|---------|
| Find section in CLAUDE.md | ~3,000 tokens | ~200 tokens | **93%** |
| Search all documentation | ~50,000 tokens | ~500 tokens | **99%** |
| Navigate stage CONTEXT.md | ~2,000 tokens | ~150 tokens | **92%** |

## Prerequisites

**MCP Server Required:** jDocMunch-MCP must be configured in Claude Code.

**Installation:**
```bash
pip install jdocmunch-mcp
# Or use uvx (recommended for MCP clients)
uvx jdocmunch-mcp
```

**MCP Config (`~/.mcp.json`):**
```json
{
  "mcpServers": {
    "jdocmunch": {
      "command": "uvx",
      "args": ["jdocmunch-mcp"]
    }
  }
}
```

## Tool Selection Guide

```
┌─────────────────────────────────────────────────────────────┐
│ WHAT DO YOU NEED?                                           │
│                                                             │
│ "What sections are in this doc?"                            │
│   └─► get_toc or get_toc_tree                               │
│                                                             │
│ "Find sections about X"                                     │
│   └─► search_sections(query="...")                          │
│                                                             │
│ "Get full content of section"                               │
│   └─► get_section(section_id="...")                         │
│                                                             │
│ "What's in one document?"                                   │
│   └─► get_document_outline(doc_path="...")                  │
│                                                             │
│ "Get multiple sections at once"                             │
│   └─► get_sections(section_ids=[...])                       │
└─────────────────────────────────────────────────────────────┘
```

## MCP Tools (10 Available)

| Tool | Purpose | When to Use |
|------|---------|-------------|
| `index_local` | Index local documentation folder | Starting point for local analysis |
| `index_repo` | Index a GitHub repository's docs | Research Pipeline integration |
| `list_repos` | List indexed documentation sets | See what's available |
| `get_toc` | Flat section list in document order | Browse all sections |
| `get_toc_tree` | Nested section tree per document | See hierarchy |
| `get_document_outline` | Section hierarchy for one document | Single doc overview |
| `search_sections` | Weighted search returning summaries | Find specific content |
| `get_section` | Full content of one section | Read specific section |
| `get_sections` | Batch content retrieval | Read multiple sections |
| `delete_index` | Remove a doc index | Force re-index |

## ICM Index Status

**ALREADY INDEXED. No setup required.**

| Repo ID | Files | Sections | Status |
|---------|-------|----------|--------|
| `local/Interpreted-Context-Methdology` | 282 | 5,702 | ✅ Ready |

**Use immediately:** `search_sections(repo="local/Interpreted-Context-Methdology", query="...")`

## ICM-Specific Patterns

### Pattern 1: Navigate CLAUDE.md Routing

```
1. search_sections(repo="local/Interpreted-Context-Methdology", query="routing table")
2. get_section(section_id="...") → Get routing section only
```

### Pattern 2: Find Stage Context

```
1. search_sections(repo="...", query="discovery stage")
2. get_section(section_id="...") → Get relevant stage info
```

### Pattern 3: Find Methodology

```
1. search_sections(repo="...", query="methodology")
2. get_section(section_id="...") → Get methodology section
```

### Pattern 4: Get Document Outline

```
1. get_document_outline(repo="...", doc_path="CLAUDE.md")
2. get_section(section_id="...") → Get specific section
```

## Section IDs

Section IDs follow the format:
```
{repo}::{doc_path}::{slug}#{level}
```

Examples:
- `owner/repo::docs/install.md::installation#1`
- `local/myproject::CLAUDE.md::routing#2`

## Integration Points

### With Research Pipeline

- **Stage 01-Scoping:** Find methodology sections
- **Stage 02-Discovery:** Navigate source evaluation criteria
- **Stage 03-Analysis:** Access analysis patterns
- **All Stages:** Navigate CONTEXT.md files efficiently

### With Code Analysis (jCodeMunch)

- jDocMunch = Documentation (Markdown, MDX, TXT, JSON, XML, etc.)
- jCodeMunch = Code (Python, JS, TS, Bash, etc.)

Use jDocMunch for .md files, jCodeMunch for scripts.

## Common Mistakes

| Don't | Do Instead |
|-------|------------|
| Read entire CLAUDE.md files | Use search_sections + get_section |
| Grep for documentation content | Use jDocMunch's semantic search |
| Skip indexing for large doc repos | Index once, query many times |
| Use Glob to find markdown files | Use search_sections for content |

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────────┐
│              JDOCMUNCH QUICK REFERENCE                      │
├─────────────────────────────────────────────────────────────┤
│  NEW LOCAL DOCS?       →  index_local                       │
│  NEW GITHUB DOCS?      →  index_repo                        │
│  WHAT'S INDEXED?       →  list_repos                        │
│  ALL SECTIONS?         →  get_toc                           │
│  SECTION TREE?         →  get_toc_tree                      │
│  ONE DOC OUTLINE?      →  get_document_outline              │
│  FIND SECTION?         →  search_sections → get_section     │
│  FULL SECTION?         →  get_section                       │
│  BATCH RETRIEVE?       →  get_sections                      │
│  FORCE RE-INDEX?       →  delete_index → index_local        │
│                                                             │
│  WORKFLOW: Index → Search → Get Section                     │
│  SAVINGS: 80-99% fewer tokens than reading files            │
│  PRIMARY FOR: ICM's 405+ markdown files                     │
│  USE WITH CODE: jCodeMunch (companion product)              │
└─────────────────────────────────────────────────────────────┘
```
