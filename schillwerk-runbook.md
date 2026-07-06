# Schillwerk Pipeline — Operating Runbook

How to run the whole thing. Keep this in the checker repo root.

## Every session: start here
```bash
cd ~/schillwerk-site-checker     # the checker repo (never /mnt/c)
claude                           # launches Claude Code in the repo
```
Then use the slash commands below. If you just added or edited a command file,
restart Claude Code (`/exit`, then `claude`) so it re-scans.

## The three commands you'll actually use

**Audit a prospect (read-only).**
```
/check https://example.com
```
Add `--deep` for a full WCAG2AA accessibility pass (slower, needs Chrome):
```
/check https://example.com --deep
```
Output: `checks/<domain>-<date>/report.md`.

**Turn an audit into the branded client pair (PDF + Word).**
```
/report checks/<domain>-<date> "Client Name"
```
Output: `report.pdf` and `report.docx` next to the `report.md`.

**Full pipeline: audit to a live noindexed mock.**
```
/ship https://example.com "Client Name"
```
Phase 1 runs locally and read-only (audit, reports, Claude-in-Chrome inventory,
staged modernized mock), then STOPS and shows you what it built. You review.
Only after you approve does Phase 2 run: `git init` + commit, create a **private**
GitHub repo named after the site, and deploy a noindexed `*.pages.dev` preview.
Outputs land under `~/clients/<site-name>/` (`audit/` + `site/`).
The client's real domain is never attached. That is go-live, a separate step.

## Where things land
- Standalone audits: `~/schillwerk-site-checker/checks/<domain>-<date>/`
- Shipped mocks: `~/clients/<site-name>/` plus a private repo `<site-name>` and a
  Cloudflare preview at `<something>.pages.dev`.

## One-time setup (verify anytime with these checks)
Run each; if one fails, that is the thing to fix.
```bash
node -v                 # Node 22+ via nvm (not a C:\ path)
claude --version        # Claude Code installed
echo $PSI_API_KEY       # PageSpeed Insights key set (not empty)
pandoc --version        # else: sudo apt install pandoc weasyprint
weasyprint --version
gh auth status          # GitHub CLI authenticated (SSH protocol)
wrangler whoami         # Cloudflare CLI authenticated
```
Repo files that must exist:
- `.claude/commands/check.md`, `report.md`, `ship.md`
- `scripts/check-site.sh`, `scripts/build-report.sh` (both executable)
- `assets/report.css`, `report.html.template`, `reference.docx`, `disclaimer.md`
- `.gitattributes` (`* text=auto eol=lf`) and `.gitignore`

## Go-live (won client only, deliberate, not part of /ship)
1. Deploy to the production branch:
   `wrangler pages deploy site/ --project-name <site-name> --branch main`
2. Attach the client's custom domain in the Cloudflare dashboard
   (Pages project > Custom domains), then make the DNS change. You do this step.
3. Previews stay noindexed; only the real domain gets indexed.

## Troubleshooting
- **`Unknown command: /check` (or /report, /ship):** the file is not in
  `.claude/commands/`, or Claude Code needs a restart to re-scan.
- **npm/node resolves to a `C:\...` path:** Windows npm leaked into PATH. Reload
  nvm or open a fresh WSL tab; confirm `which node npm` is under `~/.nvm`.
- **Performance section says "not measured":** `PSI_API_KEY` is empty. Set it and
  re-run.
- **Phase 2 fails at repo creation or deploy:** `gh` or `wrangler` not
  authenticated. Check `gh auth status` and `wrangler whoami`.
- **Script won't run / `\r` errors:** the file got CRLF endings from a Windows
  edit. Keep the repo in `~`, edit via `code .`, and confirm the `.gitattributes`
  LF rule is in place.

## The Claude Project itself (claude.ai side)
- Paste `schillwerk-project-instructions.md` into the Project's custom
  instructions. That is what steers the assistant; this runbook is for you.
- Keep the "Current engagements" snapshot updated, or delete it and let project
  memory carry status.
