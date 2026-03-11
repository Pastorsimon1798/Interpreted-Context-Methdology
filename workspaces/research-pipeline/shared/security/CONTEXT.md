# Security Routing

This folder contains security patterns for protecting the research pipeline from prompt injection and other AI-specific attacks.

## Files

| File | Purpose |
|------|---------|
| `sanitization-rules.md` | Patterns to strip/neutralize in external content |
| `validation-checklist.md` | Pre-processing checks before AI analysis |

## When to Use

| Stage | Security Check Required |
|-------|------------------------|
| 02-discovery | After fetching web content |
| 03-analysis | When extracting quotes and key findings |
| 05-output | Before including source excerpts in report |

## Attack Vectors

| Source | Risk Level |
|--------|------------|
| Web page content | CRITICAL |
| API responses | HIGH |
| User-provided topics | MEDIUM |
| PDF documents | HIGH |

## Quick Reference

Before processing any external content:

1. Apply sanitization rules from `sanitization-rules.md`
2. Run validation checklist from `validation-checklist.md`
3. Use `skills/security-input-sanitization/SKILL.md` for implementation
