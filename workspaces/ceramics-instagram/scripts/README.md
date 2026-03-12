# Instagram Intelligence Scripts

Extract, analyze, and automate your Instagram content strategy.

## Quick Start

```bash
# Set up virtual environment (first time only)
cd scripts
python3 -m venv venv
source venv/bin/activate
pip install instaloader pandas

# 1. Extract your full archive (first time only)
python extract-archive.py

# 2. Generate insights (run all three)
python analyze-voice.py
python analyze-hashtags.py
python analyze-performance.py

# 3. Weekly sync (run each Monday)
python sync-weekly.py
```

**Note:** Always activate the venv before running scripts:
```bash
source venv/bin/activate
```

## Scripts Overview

| Script | Purpose | Frequency |
|--------|---------|-----------|
| `extract-archive.py` | Full archive extraction | Once (or annually) |
| `analyze-voice.py` | Voice pattern analysis | Monthly |
| `analyze-hashtags.py` | Hashtag optimization | Monthly |
| `analyze-performance.py` | Performance dashboard | Weekly |
| `sync-weekly.py` | Incremental updates | Weekly |

## Output Files

| File | Location | Description |
|------|----------|-------------|
| `cerafica_archive.json` | `data/archive/` | Full post metadata |
| `cerafica_media/` | `data/archive/` | Downloaded images/videos |
| `voice-rules.md` | `brand-vault/` | Voice patterns from captions |
| `hashtag-library.md` | `shared/` | Optimized hashtag sets |
| `performance-insights.md` | `brand-vault/` | Engagement dashboard |
| `weekly-assets-*.md` | `stages/01-input/output/` | Weekly sync report |

## Dependencies

```bash
pip install instaloader pandas
```

## Notes

- All scripts work with public accounts without login
- Rate limiting is built in (2 second delays)
- Credentials are never stored or transmitted
- Media downloads respect Instagram's terms

## Troubleshooting

### "Profile not found"
- Check the username is correct
- Ensure the account is public

### Rate limiting errors
- Wait 1 hour before retrying
- The scripts include automatic delays

### Missing media files
- Some posts may fail to download
- Check the archive JSON for metadata anyway
