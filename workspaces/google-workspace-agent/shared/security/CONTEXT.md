# Security Routing

This folder contains security patterns for protecting the GWS Agent from prompt injection attacks via email, calendar, and task content.

## Files

| File | Purpose |
|------|---------|
| `sanitization-rules.md` | Patterns to strip/neutralize in external content |
| `validation-checklist.md` | Pre-processing checks before AI analysis |

## When to Use

| Stage | Security Check Required |
|-------|------------------------|
| 01-triage | Before processing email body content |
| 02-extraction | Before extracting to knowledge base |
| 04-digest | Before including email snippets in digest |

## Attack Vectors

| Source | Risk Level |
|--------|------------|
| Email subject/body | HIGH |
| Calendar event descriptions | MEDIUM |
| Task descriptions | MEDIUM |
| Email attachments (text content) | HIGH |

## Quick Reference

Before processing any external content:

1. Apply sanitization rules from `sanitization-rules.md`
2. Run validation checklist from `validation-checklist.md`
3. Use `skills/security-input-sanitization/SKILL.md` for implementation
