# Provider Rules

> Define which tech/AI providers you use and how to handle their emails.
> **ALWAYS extract blog content to KB/Resources.**

## Active Providers (Always Extract Blogs)

These are services you actively use. Their promos and blogs are relevant.

### AI/LLM Tools
| Provider | Blog Value | Promo Value | Notes |
|----------|------------|-------------|-------|
| Anthropic (Claude) | High | High | Free credits, API updates |
| OpenAI | High | High | Free credits, model updates |
| Google AI / Gemini | Medium | High | Free tier credits |
| Kilocode | High | High | Blog has great AI workflow content |
| Cursor | Medium | High | Pro plan discounts valuable |
| v0.dev | Medium | Medium | Component generation |
| Replit | Medium | Medium | Deployment credits |

### Cloud/Infrastructure
| Provider | Blog Value | Promo Value | Notes |
|----------|------------|-------------|-------|
| Vercel | High | High | Hobby/pro plan credits |
| Railway | Medium | High | Free tier credits |
| Render | Medium | Medium | Deployment credits |
| AWS | Medium | Medium | Free tier alerts |
| GCP | Medium | Medium | Credit expiry warnings |

### Dev Tools
| Provider | Blog Value | Promo Value | Notes |
|----------|------------|-------------|-------|
| GitHub | Medium | Low | Copilot promos maybe |
| Linear | Medium | Low | Project management |
| Notion | Low | Low | Template emails |

### Communities
| Provider | Blog Value | Promo Value | Notes |
|----------|------------|-------------|-------|
| Skool | Low | Low | Keep notifications - user is active |
| Discord | Low | Low | Keep relevant server notifications |

---

## Extraction Rules (Always-On)

**Every triage run MUST:**
1. Scan for provider blog emails
2. Extract content to `KB/Resources/` folder in Google Drive
3. Apply `provider-blog` label
4. Archive after extraction

**Extraction Template:**
```markdown
# [Title]

Source: [Provider] Blog
Date: [Date]
URL: [Link]

## Summary
[AI-generated 2-3 sentence summary]

## Key Insights
- [Insight 1]
- [Insight 2]
- [Insight 3]

## Actionable Takeaways
- [ ] [Action 1]
- [ ] [Action 2]

## Related To
- [Link to related projects/areas]
```

---

## Promo Detection Keywords

### High-Value Promo Signals
```
free credits
free inference
bonus credits
$X in credits
credit added
your account
discount code
save $
% off
limited time
expires
```

### Ignore These (Not Valuable)
```
upgrade now
go premium
try premium
discover
people also viewed
trending
you appeared
new features (unless from active provider)
webinar invite (unless relevant)
```

---

## Multi-Type Sender Rules

For providers that send multiple email types:

### Kilocode Example
| Email Type | Subject Pattern | Action |
|------------|-----------------|--------|
| Blog | "Kilocode Blog:", "Weekly Digest" | → `provider-blog` |
| Promo | "free credits", "discount", "save" | → `valuable-promo` |
| Support | "ticket", "response", "resolved" | → `action-required` |
| Receipt | "invoice", "receipt", "payment" | → `Receipts` |
| Marketing | "upgrade", "try premium" | → `promotional` |

### Cursor Example
| Email Type | Subject Pattern | Action |
|------------|-----------------|--------|
| Blog | "Cursor Blog:", "What's New" | → `provider-blog` |
| Promo | "% off", "discount", "save" | → `valuable-promo` |
| Usage | "usage alert", "limit" | → `action-required` |
| Receipt | "invoice", "receipt" | → `Receipts` |

---

## Provider-Specific Rules

### Anthropic
- `credit(s)` in subject → `valuable-promo`
- `API` or `model` in subject → `provider-blog`
- `security` in subject → `action-required`

### OpenAI
- `credit(s)` or `trial` in subject → `valuable-promo`
- `GPT` or `model` in subject → `provider-blog`
- `usage` or `limit` in subject → `action-required`

### Kilocode
- `blog` or `weekly` in subject → `provider-blog`
- `free` or `credit` or `discount` in subject → `valuable-promo`
- Anything else from kilocode → Check content

### Vercel
- `credit` or `free` in subject → `valuable-promo`
- `deployment` or `build` in subject → `reference`
- `overage` or `limit` in subject → `action-required`

---

*Last updated: 2026-03-12*
