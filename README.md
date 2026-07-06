# Schillwerk Simple Website Checker (Claude-powered)

A simple, one-command, read-only checker for small-business sites, run through
Claude Code. Point it at a live URL and get a branded, defensible leave-behind:
real performance numbers, accessibility and SEO passes, broken-link check,
security and delivery hygiene, and a trust-signal review.

Simple to run, thorough underneath. The everyday run needs no browser and no
extra services. One deeper check (full WCAG) is opt-in.

## What it checks
- Performance / Core Web Vitals (PageSpeed Insights, mobile + desktop)
- Accessibility (Lighthouse score + markup review; full WCAG2AA with `--deep`)
- SEO basics (title/meta, H1, canonical, Open Graph, JSON-LD, robots, sitemap)
- Broken links (recursive crawl)
- Security & delivery hygiene (HTTPS enforcement, www/non-www canonicalization,
  TLS cert expiry, current security headers, mixed content)
- Trust signals (contact info, reviews, service area, credentials, clear CTA)

## One-time setup (you do these)

1. Install Claude Code and sign in.
2. Confirm the collector's dependencies (all standard on macOS/Linux/WSL):
   `node --version`, `curl --version`, `openssl version`, `python3 --version`.
3. Get a free Google PageSpeed Insights API key so performance numbers are
   reliable and not rate-limited:
   - Google Cloud Console > APIs & Services > enable "PageSpeed Insights API"
   - Create an API key under Credentials, then:
     ```bash
     echo 'export PSI_API_KEY="your-key-here"' >> ~/.zshrc   # or ~/.bashrc
     ```
   Runs without a key too, just at Google's lower keyless quota.
4. Make the collector executable:
   ```bash
   chmod +x scripts/check-site.sh
   ```
5. (Optional) Keep this folder in its own Git repo so runs are versioned and the
   checker doubles as AI-native-development portfolio evidence.

## Running a check (the "one go")

From inside the repo, launch Claude Code and run:
```
/check https://prospect-domain.com
```
Add `--deep` for a full WCAG2AA accessibility pass (slower; needs headless
Chrome, which pa11y pulls via npx):
```
/check https://prospect-domain.com --deep
```
Claude Code gathers the data, reads it, does the markup review, and writes
`checks/<domain>-<date>/report.md`.

## What it does and does not do
- Read-only. Never logs in, submits forms, or changes the target site.
- Every metric traces to a tool output. Nothing is estimated.
- No guaranteed rankings or results. Findings are issues and opportunities.
- Business claims (insured, bonded, licensed, service area) are flagged
  "confirm with client", never asserted.
- Stops at the markdown report. The client-facing navy/gold PDF + DOCX come from
  the Schillwerk doc pipeline.

## Files
- `CLAUDE.md` - context Claude Code loads every session (rules, rubric, output).
- `.claude/commands/check.md` - the `/check <url> [--deep]` command.
- `scripts/check-site.sh` - read-only collector.
- `checks/` - one folder per run.
