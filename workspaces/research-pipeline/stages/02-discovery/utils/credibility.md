# Source Credibility Scoring System

Evaluate and score web sources for research quality.

## Scoring Criteria

### Positive Factors

| Factor | Points | Indicators |
|--------|--------|------------|
| Trusted domain | +30 | `.edu`, `.gov`, `.org` TLDs |
| Academic/research path | +10 | URL contains `/research/`, `/publications/`, `/papers/`, `/doi/` |
| HTTPS enabled | +5 | Secure connection |
| High engagement | +5 | Hacker News >100 points, Reddit >500 upvotes |
| Peer reviewed | +15 | DOI present, journal publication, conference paper |
| Primary source | +10 | Original research, official documentation, first-party |
| Recent publication | +5 | Published within last 2 years |
| Author credentials | +10 | Named author with expertise, academic affiliation |

### Negative Factors

| Factor | Points | Indicators |
|--------|--------|------------|
| Suspicious TLD | -20 | `.xyz`, `.tk`, `.ml`, `.ga`, `.cf` |
| No HTTPS | -10 | Insecure connection |
| Anonymous author | -5 | No named author or organization |
| Outdated content | -10 | Last updated >5 years ago |
| Sponsored content | -15 | Marked as ad, sponsored, or promotional |
| Paywall with no preview | -5 | No accessible content |
| Clickbait headline | -10 | Sensationalist language, ALL CAPS |

## Score Interpretation

| Score Range | Tier | Usage in Research |
|-------------|------|-------------------|
| 70-100+ | High | Primary evidence, cited directly |
| 40-69 | Medium | Supporting evidence, noted with caveat |
| 20-39 | Low | Background only, not cited in conclusions |
| <20 | Unreliable | Exclude from research |

## Default Threshold

**Minimum credibility score: 40**

Sources below 40 are excluded from conclusions but may be listed in "Low Credibility Sources" section for transparency.

## Scoring Process

For each source discovered:

1. **Extract domain metadata**
   - TLD (.com, .edu, .gov, etc.)
   - HTTPS status
   - URL path patterns

2. **Assess content indicators**
   - Author presence and credentials
   - Publication date
   - Peer review status
   - Primary vs secondary source

3. **Check engagement signals** (if applicable)
   - Social media metrics
   - Community ratings

4. **Calculate total score**
   ```
   score = sum(positive_factors) - sum(negative_factors)
   ```

5. **Assign tier**
   - High (70+): Use as primary evidence
   - Medium (40-69): Use with caveat
   - Low (<40): Exclude from conclusions

6. **Document in sources-collected.md**
   ```markdown
   ## [Source Title]
   - URL: [url]
   - Credibility Score: [score] ([tier])
   - Scoring Breakdown: [+30 domain, +5 https, -5 anonymous]
   ```

## Special Cases

### Official Documentation
- Vendor docs (docs.aws.amazon.com, react.dev): +20 (authoritative for that tech)
- GitHub README: +10 (primary source for open source)

### News Sources
- Major outlets (NYT, BBC, Reuters): +15 (editorial standards)
- Tech blogs (TechCrunch, The Verge): +5 (some editorial)
- Personal blogs: 0 (neutral, depends on author)

### Social/Community
- Stack Overflow accepted answer: +10 (community verified)
- Reddit/HN high-score post: +5 (community interest)
- Twitter/X thread: -5 (ephemeral, unverified)

## Example Scoring

**Example 1: Academic Paper**
```
URL: https://arxiv.org/abs/2024.12345
- .org domain: +30
- Academic path (/abs/): +10
- HTTPS: +5
- Peer reviewed: +15 (arXiv preprints: +10)
- Recent (2024): +5
Total: 65-70 (High tier)
```

**Example 2: Tech Blog**
```
URL: https://blog.example.com/how-to-xyz
- .com domain: 0
- HTTPS: +5
- Named author: +10
- Recent: +5
- Secondary source: 0
Total: 20 (Low tier - exclude from conclusions)
```

**Example 3: Official Docs**
```
URL: https://docs.python.org/3/library/asyncio.html
- .org domain: +30
- Official docs: +20
- HTTPS: +5
- Primary source: +10
Total: 65 (High tier for technical accuracy)
```
