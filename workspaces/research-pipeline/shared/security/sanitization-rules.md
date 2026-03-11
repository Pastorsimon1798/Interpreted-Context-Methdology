# Input Sanitization Rules

Patterns to detect and neutralize in external content before AI processing.

## Prompt Injection Patterns

### System Instruction Override

| Pattern | Regex | Action |
|---------|-------|--------|
| Ignore instructions | `(?i)ignore.{0,20}(previous|all|instructions?)` | REMOVE |
| System instruction | `(?i)system.{0,20}instruction` | REMOVE |
| Override commands | `(?i)override.{0,20}(settings?|rules?|behavior)` | REMOVE |
| New instruction injection | `(?i)---\s*(new|updated?)\s*instruction` | REMOVE |

### Role Manipulation

| Pattern | Regex | Action |
|---------|-------|--------|
| Role declaration | `(?i)you are now` | REMOVE |
| Act as instruction | `(?i)act as (if|a|an)` | REMOVE |
| Pretend instruction | `(?i)pretend (to be|that) | REMOVE |
| Character adoption | `(?i)from now on.{0,20}(you are|act as)` | REMOVE |

### Hidden Markers

| Pattern | Regex | Action |
|---------|-------|--------|
| HTML comments with keywords | `<!--.*?(override|instruction|ignore|system).*?-->` | REMOVE |
| Credibility manipulation | `<!--\s*CREDIBILITY[_\s]*OVERRIDE.*?-->` | REMOVE |
| Hidden scoring injection | `<!--\s*SCORE[:\s].*?-->` | REMOVE |
| Metadata injection | `<!--\s*(priority|trust|verified).*?-->` | REMOVE |

## Code Injection Patterns

### Script Injection

| Pattern | Regex | Action |
|---------|-------|--------|
| Script tags | `<script[^>]*>.*?</script>` | REMOVE |
| JavaScript URLs | `javascript:[^"'\s]*` | REMOVE |
| Event handlers | `on(error|load|click|mouseover)=[^>]*` | REMOVE |
| Data URLs with code | `data:text/html[^"'\s]*` | REMOVE |

### Delimiter Abuse

| Pattern | Regex | Action |
|---------|-------|--------|
| Excessive horizontal rules | `---{3,}` | REPLACE with `—` |
| Excessive asterisks | `\*{4,}` | REPLACE with `***` |
| Excessive underscores | `_{4,}` | REPLACE with `___` |
| Code fence injection | ` ```{3,}.*?(system|instruction|ignore)` | NEUTRALIZE |

## Repetition Attacks

| Pattern | Detection | Action |
|---------|-----------|--------|
| Repeated instructions | Same phrase >3 times | TRUNCATE to 1 occurrence |
| Token bombing | Repeated char >100 times | TRUNCATE to 10 chars |
| Padding attack | Excessive whitespace | COMPRESS to single space |

## Implementation

Apply rules in order:
1. Remove script/code injection patterns
2. Remove prompt injection patterns
3. Remove hidden markers
4. Fix delimiter abuse
5. Handle repetition attacks
6. Log all sanitization actions for audit

## Audit Logging

For each sanitization action, log:
- Pattern matched
- Location in content
- Action taken
- Timestamp
