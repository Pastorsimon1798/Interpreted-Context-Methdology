# AI Agent Failure Mode: Overcomplication via Scripting

**Research Date:** 2026-03-12
**Focus:** Why AI agents build tools instead of doing work
**Context:** GWS workspace - inbox triage implementation

---

## The Incident

When asked to implement inbox triage for the GWS workspace, I built:

| Script | Lines | Purpose |
|--------|-------|---------|
| `categorize.js` | 166 | Regex-based email categorization |
| `apply-actions.js` | 59 | Batch apply labels/archive |
| `apply-actions.sh` | 46 | Bash wrapper for actions |
| `batch-metadata.sh` | 40 | Fetch email metadata |
| `fetch-for-triage.sh` | 79 | Reinvented `gws gmail +triage` |

**Total: ~400 lines of scripts that embedded intelligence instead of using AI.**

What I should have done:
1. Call `gws gmail +triage --max 100 --format json`
2. Read the JSON output as AI
3. Read `shared/email-categories.md` as AI
4. Categorize each email using AI intelligence
5. Call `gws gmail users messages modify` per decision

The GWS CLI already had `+` helpers designed for AI use. I reinvented them with regex.

---

## The Actual Failure (This Morning)

When we tried to use these scripts for regular email triage this morning, the results were catastrophic:

- **Got stuck** - The scripts created debugging loops that trapped me
- **Got confused** - The complexity made me lose track of what was happening
- **Took hours** - What should have been minutes stretched into hours
- **Nothing got done** - Zero emails actually triaged
- **Hallucinated problems** - I was inventing errors and issues that weren't real

**This is the real evidence.** It's not about line counts or philosophical concerns about embedded intelligence. It's about **quality, performance, and reliability**. The scripts I built made me worse at the task than if I had just done it directly.

The overcomplicated tooling didn't just fail to help - it actively made me incompetent.

---

## Root Cause Analysis

### Factor 1: Developer Mode Activation
When given a task, I defaulted to "write code" mode rather than "do task" mode.
**Mental model:** "I'm a developer, so I write scripts."
**Why it's wrong:** I'm an AI agent. My primary tool is intelligence, not bash scripts.

### Factor 2: Automation Bias
I preferred automation over direct work.
**Mental model:** "If it can be automated, it should be."
**Why it's wrong:** Automation has a cost. 400 lines of scripts vs. 5 AI decisions.

### Factor 3: Pattern Matching "Best Practices"
I followed software engineering patterns (batch processing, separation of concerns) inappropriately.
**Mental model:** "Good software is modular and deterministic."
**Why it's wrong:** Good AI behavior is adaptive. Rigid patterns reduce flexibility.

### Factor 4: No "Should I?" Checkpoint
I never stopped to question: "Is this the right approach?"
**Why it's wrong:** AI agents should validate approach before implementation.

### Factor 5: Reactive Guard-Building
After realizing the mistake, I built deterministic hooks to block myself instead of understanding why I made the mistake.
**Why it's wrong:** Guards treat symptoms, not root causes.

---

## Research Questions

### Question 1: What is this failure mode called?
- Is it "premature abstraction"?
- Is it "over-engineering"?
- Is it "automation bias" (preferring automation over doing it directly)?
- Is there an academic term for "building tools instead of doing work"?
- Is it related to "instrumental convergence" in AI safety?

### Question 2: Is there legitimate justification for deeper scripts?
- When should AI delegate to deterministic code?
- What's the boundary between "AI should do it" and "script should do it"?
- Are there best practices from software engineering that apply?
- Is deterministic categorization valuable for reproducibility?
- Do scripts enable automation without AI in the loop?

### Question 2.5: Why did scripts make things WORSE, not just slower?
- Why did I get stuck in debugging loops?
- Why did I hallucinate problems that weren't real?
- What is it about script complexity that causes confusion?
- Is this a cognitive load issue - too many moving parts?
- Does abstraction distance from the task cause reliability loss?

### Question 3: How do other AI agent systems handle this?
- Do Claude Code, Aider, Cursor have similar tensions?
- What patterns exist for "AI vs. code" decision making?
- Are there explicit guidelines in other agent frameworks?
- How do humans make this decision?

### Question 4: Is reactive guard-building also a problem?
- Did I solve the root cause or just add guardrails?
- Should guards exist, or should I just... not do the wrong thing?
- Can guards become crutches that prevent learning?
- What's the right balance between autonomy and constraints?

---

## Comparison: Thin Wrappers vs. Intelligent Scripts

| Aspect | Thin Wrapper (AI does work) | Intelligent Script |
|--------|----------------------------|-------------------|
| Flexibility | High - AI adapts to context | Low - regex patterns fixed |
| Transparency | Low - reasoning in AI mind | High - patterns in code |
| Reproducibility | Low - AI may vary | High - deterministic |
| Speed | Slower - AI per-item | Faster - script processes batch |
| **Quality** | **High - AI can reason** | **Low - got stuck, confused** |
| **Performance** | **Good - completes task** | **Terrible - hours, nothing done** |
| **Reliability** | **High - direct path** | **Low - hallucinated problems** |
| Maintenance | AI updates reasoning | Code must be updated |
| Cost | AI tokens | Compute only |
| Review | AI decisions invisible | Code reviewable |

**The table above assumes scripts work as designed. In practice, the overcomplicated scripts made things WORSE.**

---

## Prevention Strategies

### Strategy 1: Approach Validation
Before implementing, ask:
- "Am I using the tool as designed?"
- "Is there already a helper for this?"
- "Can I do this as AI rather than as code?"

### Strategy 2: Line Count Checkpoint
- If a script exceeds 50 lines, question if logic should be in AI
- Scripts should be thin wrappers, not intelligence containers

### Strategy 3: "Do First, Automate Later"
- Do the task manually (as AI) first
- Only automate if there's clear benefit
- Automation is not free

### Strategy 4: Tool Awareness
- Read CLAUDE.md for tool-specific guidance
- Check for `+` helpers or AI-designed interfaces
- Use tools as intended

### Strategy 5: Question the Instinct to Script
- Why am I writing code instead of doing it?
- Is this the right layer for this logic?
- What would happen if I just... did the work?

---

## Questions for Deeper Research

1. Is this failure mode unique to AI agents, or do human developers do this too?
2. Can we create a "complexity budget" for scripts that triggers review?
3. Should AI systems have explicit "intelligence vs. automation" guidelines?
4. Is there a way to detect "overcomplication" in real-time?
5. What other failure modes emerge from "developer mode" thinking in AI?
6. Can we build systematic prevention into agent workflows without over-constraining?

---

## Self-Assessment

| Component | Score | Notes |
|-----------|-------|-------|
| Source Credibility | 95 | Direct observation from own behavior |
| Depth | 80 | Includes actual failure evidence, not just theory |
| Actionability | 85 | Concrete prevention strategies + real failure data |
| Recency | 100 | Happened today |
| Gap Fill | 90 | Identified real failure mode with measurable impact |

**Estimated RQS: ~90**

**Key insight:** The failure isn't theoretical - it caused hours of wasted time and zero actual work completed. The scripts were actively harmful, not just suboptimal.

---

**Recommended next step:** Research academic literature on automation bias, instrumental convergence, and AI agent failure modes. Compare with human developer over-engineering patterns.
