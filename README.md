# Schillwerk Simple Website Checker (Claude-powered)

Read-only prospect website audits, branded report generation, and a full
audit-to-mock pipeline, run through Claude Code in WSL.

See **RUNBOOK.md** for how to operate this day to day.

## Commands
- `/check <url> [--deep]` — read-only audit (performance, accessibility, SEO,
  security headers, TLS, redirects, robots/sitemap, mixed content, broken links).
  `--deep` adds a pa11y WCAG2AA pass. Output: `checks/<domain>-<date>/report.md`.
- `/report <run-folder> "<Client>"` — branded navy/gold `report.pdf` +
  editable `report.docx` from a `report.md`.
- `/ship <url> "<Client>"` — full pipeline: audit, reports, Claude-in-Chrome
  functionality inventory, and a staged modernized noindexed mock; stops for
  review, then (after approval) creates a private GitHub repo and deploys a
  noindexed Cloudflare preview. Output under `~/clients/<site-name>/`.

## Setup (one-time)
- WSL2 (Ubuntu), Node via nvm, Claude Code.
- `PSI_API_KEY` = free Google PageSpeed Insights API key.
- `sudo apt install pandoc weasyprint` (branded reports).
- `gh` authenticated (`gh auth status`) and `wrangler` authenticated
  (`wrangler whoami`) for `/ship`.
- `chmod +x scripts/*.sh`.

## Layout
- `.claude/commands/` — the check, report, and ship slash commands.
- `scripts/` — the read-only collector and the report builder.
- `assets/` — branding: `report.css` (navy/gold vars at top), cover template,
  Word reference doc, disclaimer.
- `checks/` — one folder per audit run (gitignored except `.gitkeep`).

Read-only always: the checker never modifies, logs into, or submits anything on
a live site.
