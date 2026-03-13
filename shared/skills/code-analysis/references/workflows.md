# Code Analysis Workflows

Detailed workflow patterns for jCodeMunch-MCP integration.

## Workflow 0: Documentation Repository Analysis

**Use Case:** Navigate and analyze documentation-heavy projects (like ICM).

**Steps:**
1. Index the documentation repository
2. List symbols to see headings, sections, links
3. Search for specific topics
4. Retrieve relevant sections

**Example:**
```
# Index ICM documentation
index_folder(path="/path/to/ICM")

# Find all CLAUDE.md references
search_symbols(query="CLAUDE")

# Find specific topic sections
search_symbols(query="research pipeline")

# Retrieve a specific section
retrieve_symbol(symbol_id="Research Pipeline")
```

**Token Savings:** ~96% vs reading all markdown files

**Useful for:** Documentation repos, knowledge bases, MWP workspaces

---

## Workflow 1: Single Symbol Retrieval

**Use Case:** Find and understand a specific function or class.

**Steps:**
1. Ensure repository is indexed
2. Search for symbol by name (fuzzy matching supported)
3. Retrieve full definition
4. Find references to understand usage

**Example:**
```
# Find the "processRequest" function
search_symbols(query="processRequest")
# Returns: [{id: "processRequest", type: "function", file: "src/api.ts:45"}]

retrieve_symbol(symbol_id="processRequest")
# Returns: Full function implementation

find_references(symbol_id="processRequest")
# Returns: All files that call this function
```

**Token Savings:** ~80% vs reading entire files

---

## Workflow 2: Multi-File Analysis

**Use Case:** Understand how a feature spans multiple files.

**Steps:**
1. Search for related symbols using patterns
2. Retrieve key definitions
3. Build call graph to see relationships
4. Synthesize understanding

**Example:**
```
# Find all authentication-related symbols
search_symbols(query="auth|login|token")
# Returns: Multiple symbols across files

# Get the main auth function
retrieve_symbol(symbol_id="authenticate")

# See what calls it
get_call_graph(function_name="authenticate")

# Get class relationships if using OOP
get_class_hierarchy(class_name="AuthProvider")
```

**Token Savings:** ~90% vs reading all related files

---

## Workflow 3: Repository Overview

**Use Case:** Get a quick understanding of a codebase structure.

**Steps:**
1. Index the repository
2. List all symbols
3. Group by file/directory
4. Identify key components

**Example:**
```
# Index a local project
index_folder(path="/path/to/project")

# Get all symbols
list_symbols()
# Returns: [{name, type, file, line}, ...]

# Get structure without full code
get_symbol_structure(symbol_name="UserService")
# Returns: Outline with method signatures
```

**Token Savings:** ~95% vs reading all files

---

## Workflow 4: Research Pipeline Integration

**Use Case:** Analyze GitHub repositories as part of research.

**Steps:**
1. Index GitHub repository
2. Search for relevant symbols
3. Retrieve implementations
4. Document findings

**Example:**
```
# Index a GitHub repo for research
index_github_repo(repo_url="https://github.com/org/interesting-project")

# Find API endpoints
search_symbols(query="endpoint|route|api")
# Returns: All route definitions

# Get implementation details
retrieve_symbol(symbol_id="handleWebhook")

# Document in research output
# → Include in Stage 03-Analysis output
```

**Integration Points:**

| Research Stage | jCodeMunch Usage |
|----------------|------------------|
| 02-Discovery | Index GitHub repos, list symbols |
| 03-Analysis | Search, retrieve, analyze patterns |
| 04-Synthesis | Compare implementations across repos |

---

## Workflow 5: Codebase Comparison

**Use Case:** Compare implementations between repositories.

**Steps:**
1. Index both repositories
2. Search for similar concepts in each
3. Retrieve and compare implementations
4. Document differences

**Example:**
```
# Index repo A
index_github_repo(repo_url="https://github.com/org/repo-a")

# Index repo B
index_github_repo(repo_url="https://github.com/org/repo-b")

# Find similar functions
search_symbols(query="parseConfig") # in repo A
search_symbols(query="parseConfig") # in repo B

# Compare implementations
retrieve_symbol(symbol_id="parseConfig") # from each
```

---

## Workflow 6: Refactoring Analysis

**Use Case:** Understand impact of code changes.

**Steps:**
1. Find the symbol to modify
2. Get all references
3. Build call graph
4. Identify affected components

**Example:**
```
# Find function to refactor
search_symbols(query="legacyFormat")

# Get current implementation
retrieve_symbol(symbol_id="legacyFormat")

# Find all usages
find_references(symbol_id="legacyFormat")

# See what depends on it
get_call_graph(function_name="legacyFormat")
# Now you know the full impact scope
```

---

## Workflow 7: Dependency Mapping

**Use Case:** Understand code dependencies and architecture.

**Steps:**
1. List all symbols in a module
2. For each key symbol, get call graph
3. Build dependency map
4. Identify coupling points

**Example:**
```
# List symbols in a module
get_file_symbols(file_path="src/services/user.ts")

# For key functions, trace dependencies
get_call_graph(function_name="createUser")
get_call_graph(function_name="updateUser")

# Build mental map of dependencies
```

---

## Error Handling

### Index Not Found

```
Error: Repository not indexed
Solution: Run index_folder or index_github_repo first
```

### Symbol Not Found

```
Error: Symbol 'xyz' not found
Solution: Try broader search with search_symbols
         Check spelling - fuzzy matching is limited
```

### Language Not Supported

```
Error: Unsupported language
Solution: Check supported languages list in SKILL.md
         Use Read tool for unsupported file types
```

---

## Best Practices

1. **Index Once, Query Many:** Don't re-index unless files changed
2. **Use Search First:** Don't guess symbol names, search for them
3. **Structure Before Code:** Use get_symbol_structure for quick overview
4. **Combine with Read:** Use jCodeMunch for code, Read for docs/configs
5. **Parallel Searches:** Run multiple search_symbols in parallel for broad queries

---

## Anti-Patterns

| Anti-Pattern | Better Approach |
|--------------|-----------------|
| Re-indexing on every query | Check index status first |
| Reading entire files | retrieve_symbol for specific code |
| Using grep for code search | jCodeMunch's AST-based search |
| Manual symbol lookup | search_symbols with patterns |
| Reading docs with jCodeMunch | Use Read tool for markdown/text |
