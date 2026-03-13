# Relevance Criteria

How to filter, score, and prioritize research opportunities.

---

## The Three-Tier Priority System

### TIER 1: Immediate Action Required
**Score 10+** — Research this NOW

| Trigger | Weight | Examples |
|---------|--------|----------|
| Directly relates to active project | +5 | Multi-agent for ICM, edge deployment for mac-mini-agent |
| Breakthrough/new paradigm announced | +4 | New model architecture, novel training method |
| Production case study with numbers | +3 | "How X deployed agents at scale with 85% reliability" |
| Security vulnerability in tool we use | +3 | LangGraph vulnerability, prompt injection attack |

### TIER 2: Worth Investigating
**Score 6-9** — Add to research queue

| Trigger | Weight | Examples |
|---------|--------|----------|
| New framework/tool in our stack | +3 | New LangGraph feature, Hugging Face release |
| Interesting architecture pattern | +2 | Novel agent orchestration, state machine variant |
| Cost/performance improvement | +2 | "50% cheaper inference", "10x faster RAG" |
| Relevant arXiv paper | +2 | Multi-agent, RAG, evaluation papers |

### TIER 3: Background Awareness
**Score 3-5** — Include in digest, no immediate action

| Trigger | Weight | Examples |
|---------|--------|----------|
| General AI news | +1 | Funding rounds, product launches |
| Tutorial for known concept | +1 | "How to build RAG" (unless new approach) |
| Adjacent field crossover | +2 | AI + biology, AI + finance |

### SKIP
**Score <3** — Don't include

- Marketing fluff without substance
- Beginner tutorials ("Getting started with...")
- Funding/VC news without technical details
- Company drama, hiring posts, conference CFPs

---

## Keyword Framework

### Core Interest Areas (Weight: 3)

These directly relate to your projects:

```
AI Agents
├── agent architecture
├── multi-agent systems
├── agent orchestration
├── tool use / function calling
├── state machines
├── ReAct / reflection / planning
└── agent evaluation

LLMs & Models
├── new model releases
├── model benchmarks
├── fine-tuning / RAG
├── prompt engineering
├── context window improvements
└── cost optimization

Production & Deployment
├── production deployment
├── reliability / observability
├── edge deployment / local LLMs
├── latency optimization
└── security / prompt injection

Frameworks
├── LangGraph / LangChain
├── CrewAI / AutoGen / OpenAI Swarm
├── Hugging Face
└── Anthropic / OpenAI APIs
```

### Extended Interest Areas (Weight: 2)

Broader relevance:

```
Emerging Patterns
├── agentic RAG
├── world models
├── test-time compute
├── reflection / self-correction
├── memory systems
└── long-context handling

Business & Practice
├── ROI case studies
├── team workflows
├── evaluation frameworks
├── compliance / regulation
└── EU AI Act updates

Adjacent Tech
├── vector databases
├── embedding models
├── MCP (Model Context Protocol)
├── structured outputs
└── tool interfaces
```

### Discovery Keywords (Weight: 1)

Keep an eye out for unexpected value:

```
- new paradigm
- breakthrough
- significantly faster/cheaper/better
- production study
- 12-month review
- lessons learned
- we tried / we learned
- what worked / what didn't
```

---

## Source Credibility Multiplier

Apply to base score:

| Source Type | Multiplier | Notes |
|-------------|------------|-------|
| Official company blog | 1.3x | OpenAI, Anthropic, Meta AI |
| Peer-reviewed paper | 1.3x | arXiv, conference proceedings |
| Production case study | 1.2x | Company engineering blogs |
| Expert personal blog | 1.1x | Karpathy, Chip Huyen, etc. |
| Community discussion | 1.0x | Reddit HN with high engagement |
| Newsletter curation | 0.9x | Depends on author expertise |
| News article | 0.7x | Often surface-level |
| Marketing content | 0.5x | Verify claims elsewhere |

---

## Recency Bonus

| Age | Bonus |
|-----|-------|
| < 6 hours | +3 |
| < 24 hours | +2 |
| < 3 days | +1 |
| < 7 days | +0 |
| > 7 days | -1 |

---

## The Output Format

### TLDR Digest (Twice Daily)

```markdown
# AI Digest - March 11, 2026 (AM)

## 🔥 Must Know (Research Immediately)
1. **[LangGraph v0.4 Released]** - New streaming support, 40% faster
   - Why: Directly impacts ICM agent workflows
   - [Link]

2. **[arXiv] Multi-Agent Reliability Study (300 deployments)**
   - Why: Production data on what actually works
   - [Link]

## 📌 Worth Your Time (Queue for Later)
3. **[Anthropic] New prompt caching reduces costs 90%**
   - Why: Cost optimization for production
   - [Link]

4. **[Hugging Face] Qwen 3.5 released - best open model**
   - Why: Alternative to paid APIs
   - [Link]

## 📰 Background Awareness
5. OpenAI raised another $10B
6. New EU AI Act guidance published
7. Gemini 3.5 announced

---
💡 Suggestion: Research items #1 and #2 today?
```

---

## Special Monitoring Rules

### Watch for Contradictions
If source A says "X is best" and source B says "Y is best" → Flag for comparative research

### Watch for Patterns
If 3+ sources mention same topic in 24h → Auto-upgrade priority

### Watch for Your Projects
Any mention of:
- ICM / Interpreted-Context-Methodology
- mac-mini-agent
- PARA / knowledge management + AI
→ Immediate Tier 1

### Watch for Names You Trust
Authors/practitioners who have delivered value before:
- Viqus (production lessons)
- Galileo (agent benchmarks)
- Chip Huyen (ML systems)
- Sebastian Raschka (LLM training)
