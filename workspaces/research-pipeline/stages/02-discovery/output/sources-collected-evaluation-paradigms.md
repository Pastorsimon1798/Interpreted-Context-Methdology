# Sources Collected: Evaluation Paradigms for AI Output

**Created:** 2026-03-11
**Research Goal:** Create comprehensive practitioner guide on AI output evaluation

---

## Summary

| Metric | Count |
|--------|-------|
| Total sources found | 30 |
| High credibility (70+) | 16 |
| Medium credibility (40-69) | 12 |
| Low credibility (<40) | 2 - excluded from conclusions |
| **Gap-filling sources added** | 6 |

---

## Sources by Question

### Question 1: Core Quality Dimensions

#### High Credibility Sources (70+)

**Datadog: Building an LLM Evaluation Framework**
- URL: https://www.datadoghq.com/blog/llm-evaluation-framework-best-practices/
- Credibility: **85** (High)
- Scoring: +25 enterprise vendor blog, +15 detailed technical content, +10 https, +10 2025 publication, +10 author credentials, +15 comprehensive coverage
- Relevance: Defines core evaluation dimensions: context-specific (faithfulness, needle-in-haystack), user experience (topic relevancy, sentiment), security/safety (toxicity, jailbreak detection)
- Key Quote: "An effective LLM evaluation framework will include metrics to characterize both prompts and responses—as well as internal inputs and outputs in agentic or chain-based LLM applications"

**Arize AI: Evidence-Based Prompting Strategies for LLM-as-a-Judge**
- URL: https://arize.com/blog/evidence-based-prompting-strategies-for-llm-as-a-judge-explanations-and-chain-of-thought/
- Credibility: **82** (High)
- Scoring: +25 observability vendor, +15 research-backed, +10 https, +10 2025, +10 multiple authors with credentials, +12 practical examples
- Relevance: Covers explanation order, chain-of-thought effectiveness, reasoning models tradeoffs
- Key Quote: "Explanations give you three concrete things: stability in scoring, visibility into decision criteria, and reusable supervision signals"

#### Medium Credibility Sources (40-69)

**Confident AI: LLM-as-a-Judge Simply Explained**
- URL: https://www.confident-ai.com/blog/why-llm-as-a-judge-is-the-best-llm-evaluation-method
- Credibility: **65** (Medium)
- Scoring: +20 vendor blog, +10 https, +10 2025, +10 author credentials (ex-Googler), +10 comprehensive, -5 promotional bias
- Relevance: Complete guide to LLM-as-judge methodology, prompting strategies
- Key Quote: "LLM-as-a-Judge is the process of using LLMs to evaluate LLM (system) outputs"

---

### Question 2: Evaluation Methodologies

#### High Credibility Sources (70+)

**Comet: LLM-as-a-Judge Ultimate Guide**
- URL: https://www.comet.com/site/blog/llm-as-a-judge/
- Credibility: **75** (High)
- Scoring: +20 ML platform vendor, +15 comprehensive guide, +10 https, +10 2025, +10 practical focus, +10 includes bias/failure modes
- Relevance: Rubrics, judge architectures, bias mitigation strategies
- Key Quote: Covers how to build reliable, scalable evaluation for LLM apps

**Weights & Biases: Exploring LLM-as-a-Judge**
- URL: https://wandb.ai/site/articles/exploring-llm-as-a-judge/
- Credibility: **78** (High)
- Scoring: +25 leading ML platform, +15 research-backed, +10 https, +10 recent, +10 practical, +8 includes when NOT to use
- Relevance: When to use LLM-as-judge, common bias and failure modes, research-backed best practices

#### Medium Credibility Sources (40-69)

**Galileo AI: Comprehensive Guide to LLM-as-a-Judge**
- URL: https://galileo.ai/blog/llm-as-a-judge-guide-evaluation
- Credibility: **62** (Medium)
- Scoring: +20 AI evaluation vendor, +10 https, +10 recent, +10 comprehensive, +12 practical -5 vendor bias
- Relevance: Prompting strategies comparison, range of approaches vs single approach

---

### Question 3: LLM-as-Judge Best Practices

#### High Credibility Sources (70+)

**Arize AI: Evidence-Based Prompting Strategies** (covered above)
- Key practices: explanation-first prompting, when to use CoT, reasoning model tradeoffs

**DeepEval vs Ragas Comparison**
- URL: https://deepeval.com/blog/deepeval-vs-ragas
- Credibility: **72** (High)
- Scoring: +20 framework docs, +15 detailed comparison, +10 https, +10 2025, +10 engineering focus, +7 GitHub-backed
- Relevance: Practical comparison of evaluation approaches, CI/CD integration

#### Medium Credibility Sources (40-69)

**Comet: LLM Evaluation Frameworks Head-to-Head**
- URL: https://www.comet.com/site/blog/llm-evaluation-frameworks/
- Credibility: **68** (Medium)
- Scoring: +20 ML platform, +15 benchmarking focus, +10 https, +10 2025, +10 practical, +3 guest post
- Relevance: Direct comparison of frameworks, performance benchmarks

---

### Question 4: Frameworks and Tools

#### High Credibility Sources (70+)

**Braintrust: DeepEval Alternatives 2026**
- URL: https://www.braintrust.dev/articles/deepeval-alternatives-2026
- Credibility: **74** (High)
- Scoring: +22 evaluation vendor, +15 2026 publication, +10 https, +10 comprehensive comparison, +10 honest assessment, +7 includes Galileo, Vellum, Langfuse, LangSmith
- Relevance: Comprehensive comparison of DeepEval, Galileo, Vellum, Langfuse, LangSmith

**MLflow Blog: DeepEval, RAGAS, Phoenix Judges**
- URL: https://mlflow.org/blog/third-party-scorers
- Credibility: **80** (High)
- Scoring: +30 official MLflow docs, +15 integration guide, +10 https, +10 2026, +10 practical, +5 open source
- Relevance: How to integrate multiple evaluation frameworks with MLflow

**GitHub: RAGAS LangSmith Integration**
- URL: https://github.com/explodinggradients/ragas/blob/main/docs/howtos/integrations/langsmith.md
- Credibility: **78** (High)
- Scoring: +30 official GitHub docs, +15 code examples, +10 https, +10 maintained, +8 practical integration, +5 open source
- Relevance: Direct integration between RAGAS and LangSmith

#### Medium Credibility Sources (40-69)

**Medium: Choosing the Right LLM Evaluation Framework 2025**
- URL: https://medium.com/@mahernaija/choosing-the-right-llm-evaluation-framework-in-2025-deepeval-ragas-giskard-langsmith-and-c7133520770c
- Credibility: **52** (Medium)
- Scoring: +15 Medium platform, +10 https, +10 2025, +10 comparison focus, +7 includes 5 frameworks -5 individual author (unverified)
- Relevance: Comparison of DeepEval, Ragas, Giskard, LangSmith, TruLens

**Medium: Top 17 LLM Evaluation Tools**
- URL: https://medium.com/@mkmanjula96/top-17-widely-used-llm-evaluation-tools-frameworks-in-industry-d1b7576f3080
- Credibility: **50** (Medium)
- Scoring: +15 Medium, +10 https, +10 2025, +10 comprehensive list, +5 industry focus -5 individual author
- Relevance: Broad survey of 17 tools in industry use

---

### Question 5: Production Evaluation Strategies

#### High Credibility Sources (70+)

**Datadog: Building an LLM Evaluation Framework** (covered above)
- Key sections: Pre-production evaluation, production monitoring, dashboard examples

**Databricks: Best Practices for LLM Evaluation**
- URL: https://www.databricks.com/blog/best-practices-and-methods-llm-evaluation
- Credibility: **76** (High)
- Scoring: +25 enterprise platform, +15 production focus, +10 https, +10 2025, +10 integrated judges, +6 practical
- Relevance: Mosaic AI Agent Framework, Agent Evaluation, groundedness/correctness/clarity/coherence metrics

#### Medium Credibility Sources (40-69)

**Deepchecks: How to Build an LLM Evaluation Framework 2025**
- URL: https://www.deepchecks.com/llm-evaluation/framework/
- Credibility: **60** (Medium)
- Scoring: +18 ML testing vendor, +12 comprehensive guide, +10 https, +10 2025, +10 practical -5 vendor bias
- Relevance: Production monitoring, safety, context-awareness, human review integration

**arXiv: Practical Guide for Evaluating LLMs**
- URL: https://arxiv.org/html/2506.13023v1
- Credibility: **70** (Medium-High)
- Scoring: +25 academic source, +15 2025, +10 https, +10 practical focus, +10 methodology -5 preprint
- Relevance: Proactive dataset curation, metric selection, evaluation methodology integration

---

### Question 6: Common Pitfalls

#### High Credibility Sources (70+)

**HoneyHive: Avoiding Common Pitfalls in LLM Evaluation**
- URL: https://www.honeyhive.ai/post/avoiding-common-pitfalls-in-llm-evaluation
- Credibility: **72** (High)
- Scoring: +20 LLM evaluation platform, +15 2025, +10 https, +10 based on hundreds of teams, +10 practical, +7 detailed examples
- Relevance: Hidden challenges, common mistakes seen across hundreds of teams
- Key Quote: "Discover the hidden challenges of LLM evaluation and the most common mistakes we've seen after helping hundreds of teams build effective evals"

**Medium: The Six Hardest Problems in LLM Output Evaluation**
- URL: https://stackshala.medium.com/the-six-hardest-problems-in-llm-output-evaluation-79058a2433e0
- Credibility: **70** (High)
- Scoring: +15 Medium, +15 2025, +10 https, +10 technical depth, +10 practical, +10 covers hallucination detection
- Relevance: Six fundamental challenges including hallucination detection, no universal truth database, confident incorrectness
- Key Quote: "No Universal Truth Database: Unlike simple fact-checking, most real-world queries don't have a single correct answer"

#### Medium Credibility Sources (40-69)

**Responsible AI Labs: LLM Evaluation Benchmarks 2025**
- URL: https://responsibleailabs.ai/knowledge-hub/articles/llm-evaluation-benchmarks-2025
- Credibility: **58** (Medium)
- Scoring: +18 AI safety org, +12 2025, +10 https, +10 comprehensive, +8 benchmark focus -5 not widely known
- Relevance: Why generic benchmarks don't work, domain-specific evaluation needs

**Towards AI: Hallucinations in LLMs Deep Dive**
- URL: https://pub.towardsai.net/hallucinations-in-llms-a-deep-technical-dive-into-causes-detection-and-mitigation-90229180543b
- Credibility: **62** (Medium)
- Scoring: +18 AI publication, +12 2026, +10 https, +10 technical depth, +10 practical, +2 Medium platform
- Relevance: Causes, detection, mitigation strategies for hallucinations

**Qualifire: LLM Evaluation Frameworks Explained**
- URL: https://qualifire.ai/posts/llm-evaluation-frameworks-metrics-methods-explained
- Credibility: **55** (Medium)
- Scoring: +15 AI vendor, +12 2025, +10 https, +10 G-Eval coverage, +8 practical -5 vendor bias
- Relevance: G-Eval framework, MT-Bench, OpenAI Evals, Claude feedback systems

---

### Question 7: Standard Benchmarks

#### High Credibility Sources (70+)

**Evidently AI: 30 LLM Evaluation Benchmarks**
- URL: https://www.evidentlyai.com/llm-guide/llm-benchmarks
- Credibility: **75** (High)
- Scoring: +22 ML observability platform, +15 comprehensive (30 benchmarks), +10 https, +10 2026, +10 practical, +8 includes limitations
- Relevance: Complete guide to 30 benchmarks, limitations, when to use each
- Key Quote: "While LLM benchmarks help compare LLMs, they are not suitable for evaluating LLM-based products, which require custom datasets"

**DataForce: Disadvantages of Standard LLM Benchmarks**
- URL: https://www.dataforce.ai/blog/disadvantages-standard-llm-benchmarks
- Credibility: **70** (High)
- Scoring: +20 enterprise data platform, +15 2025, +10 https, +10 contamination focus, +10 practical, +5 vendor
- Relevance: Data contamination issues, lack of domain specificity, why public benchmarks fail for production
- Key Quote: "The biggest issue with standard benchmarks is that many LLMs are likely to have encountered these datasets during pretraining"

#### Medium Credibility Sources (40-69)

**Deepchecks: HellaSwag Limitations**
- URL: https://deepchecks.com/glossary/hellaswag/
- Credibility: **65** (Medium)
- Scoring: +18 ML testing vendor, +12 detailed analysis, +10 https, +10 2025, +10 limitations focus, +5 glossary format
- Relevance: How HellaSwag works, its limitations, when it's useful

**Rohan Paul: Benchmarks for LLMs**
- URL: https://rohan-paul.com/p/benchmarks-for-llms-capabilities
- Credibility: **60** (Medium)
- Scoring: +15 personal blog, +12 2025, +10 https, +10 comprehensive coverage, +10 practical, +3 good depth
- Relevance: Popular benchmarks (MMLU, HellaSwag, TruthfulQA), how they work, limitations

---

## Excluded Sources (Below Threshold)

| Source | Score | Reason for Exclusion |
|--------|-------|---------------------|
| ZenML: DeepEval Alternatives | 35 | Blog post with limited depth, heavy SEO focus |
| DEV.to: Top 5 Open-Source Frameworks | 32 | Community post, limited editorial quality |

---

## Coverage Map

| Question | High Sources | Medium Sources | Coverage |
|----------|--------------|----------------|----------|
| Q1: Core dimensions | 2 | 1 | ✅ Strong |
| Q2: Methodologies | 2 | 1 | ✅ Strong |
| Q3: LLM-as-Judge best practices | 2 | 1 | ✅ Strong |
| Q4: Frameworks/tools | 3 | 2 | ✅ Strong |
| Q5: Production strategies | 2 | 2 | ✅ Good |
| Q6: Common pitfalls | 2 | 2 | ✅ Strong |
| Q7: Standard benchmarks | 2 | 2 | ✅ Strong |

**All questions now have adequate high-credibility source coverage.**

---

## Sources Ready for Analysis

**Primary sources (use for key claims):**
1. Datadog framework best practices
2. Arize prompting strategies
3. MLflow integration guide
4. GitHub RAGAS docs
5. **Nature journal: LLM-as-judge costs** (High, 80) - Actual cost/latency benchmarks

**Supporting sources (use for additional context):**
1. Confident AI LLM-as-judge guide
2. Weights & Biases exploration
3. Medium comparisons
4. Deepchecks framework guide

---

## Gap-Filling Sources (Added Post-Initial Discovery)

### Cost/Latency Benchmarks

**Nature Journal: Table 3 - LLM-as-a-Judge Costs**
- URL: https://www.nature.com/articles/s41746-025-02005-2/tables/3
- Credibility: **80** (High)
- Scoring: +30 peer-reviewed journal, +15 primary research data, +10 https, +10 2025, +10 comprehensive table, +5 reproducible
- Relevance: Actual inference time and cost data for all major judge models
- Key Data: GPT-4o $0.03/eval, GPT-o3-mini $0.02/eval, Human $50/eval

### Judge Model Selection

**Qodo: Claude Haiku vs Sonnet Benchmark (400 PRs)**
- URL: https://www.qodo.ai/blog/thinking-vs-thinking-benchmarking-claude-haiku-4-5-and-sonnet-4-5-on-400-real-prs/
- Credibility: **72** (High)
- Scoring: +20 AI tooling company, +15 real-world benchmark, +10 https, +10 2025, +10 large sample (400 PRs), +7 transparent methodology
- Relevance: Haiku 4.5 beats Sonnet 4 as judge (55% vs 45%), smaller models often better judges
- Key Data: Haiku wins at 1/3 the cost

**Ian L. Paterson: LLM Benchmark 2026 (38 Tasks, $2.29)**
- URL: https://ianlpaterson.com/blog/llm-benchmark-2026-38-actual-tasks-15-models-for-2-29/
- Credibility: **68** (Medium-High)
- Scoring: +15 individual researcher, +15 real-world tasks, +10 https, +10 2026, +10 cost transparency, +8 practical focus
- Relevance: "Routing beats model selection" - cheap models good enough for most tasks
- Key Data: Gemini Flash 97% at $0.003/run, GPT-oss-20b 98.3% local

**Emergent.sh: Claude Sonnet vs Haiku 2026**
- URL: https://emergent.sh/learn/claude-sonnet-vs-haiku
- Credibility: **65** (Medium)
- Scoring: +18 AI comparison site, +12 2026 data, +10 https, +10 detailed comparison, +10 practical, +5 balanced
- Relevance: Model selection guidance by use case

### Dev-to-Prod Transition

**Braintrust: LLM Evaluation Guide 2026**
- URL: https://www.braintrust.dev/articles/llm-evaluation-guide
- Credibility: **74** (High)
- Scoring: +22 evaluation vendor, +15 2026, +10 https, +10 comprehensive, +10 practical, +7 offline vs online distinction
- Relevance: Clear framework for development vs production evaluation
- Key Data: Offline vs online evaluation modes, regression testing patterns

**DEV.to: LLM Eval Pipeline That Catches Failures**
- URL: https://dev.to/pockit_tools/llm-evaluation-and-testing-how-to-build-an-eval-pipeline-that-actually-catches-failures-before-5e3n
- Credibility: **60** (Medium)
- Scoring: +15 community blog, +12 practical guide, +10 https, +10 2026, +10 code examples, +3 real scenarios
- Relevance: Production-tested patterns, five failure modes taxonomy
