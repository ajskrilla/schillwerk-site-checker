---
description: Audit a prospect site, build reports, stage a modernized noindexed mock, then (after approval) create a private repo and deploy a Cloudflare preview
argument-hint: <url> "<Client Name>"
---

Run the Schillwerk audit-to-mock pipeline for: $ARGUMENTS

Prerequisites: `gh` and `wrangler` installed and authenticated (`gh auth status`,
`wrangler whoami`), plus pandoc + weasyprint for the reports. Everything through
Phase 1 is read-only and local. Nothing is created or published until Andrew
explicitly approves.

Derive a `<site-name>` from the domain: strip protocol and `www`, lowercase,
keep letters, numbers, and hyphens (e.g., heavydutyprogym.com -> heavydutyprogym).
Work under `~/clients/<site-name>/`.

## Phase 1 — build and stage (no side effects)

1. **Audit (read-only).** Run `scripts/check-site.sh <url> ~/clients/<site-name>/audit`,
   then read the outputs and write `~/clients/<site-name>/audit/report.md` following
   the checker rubric. Do not change anything on the live site.
2. **Reports.** Run `scripts/build-report.sh ~/clients/<site-name>/audit "<Client>" <url>`
   to produce the branded `report.pdf` and `report.docx` alongside the markdown.
3. **Inventory first.** Before building the mock, inventory the live site's
   functionality with Claude in Chrome (forms, booking, logins, third-party
   embeds, anything JS-rendered), read-only. If Chrome is unavailable, list what
   could not be verified and proceed cautiously. The mock must be a drop-in with
   no feature loss.
4. **Stage the modernized mock** into `~/clients/<site-name>/site/`: a static
   HTML/CSS/JS version that fixes the audit's searchability findings (accurate
   title and ~155-char meta description per page, one H1, structured data,
   semantic markup, accessibility labels, performance). Reproduce every item from
   the inventory. Include:
   - `_headers` with `/* \n  X-Robots-Tag: noindex` so the mock never indexes.
   - `robots.txt` with `User-agent: *` / `Disallow: /`.
   - a `.gitattributes` (`* text=auto eol=lf`) and a `.gitignore`.
5. **STOP for review.** Print: the audit's top findings, the report paths, the
   staged file tree, and how to preview locally (e.g., `npx serve site`). Then ask
   Andrew to review the staged files and **explicitly approve** before anything is
   created or published. Do not proceed to Phase 2 without a clear yes.

## Phase 2 — publish (only after explicit approval)

6. In `~/clients/<site-name>/`: `git init`, `git add -A`, `git commit -m "Audit + modernized mock for <site-name>"`.
7. **Private repo + push:** `gh repo create <site-name> --private --source=. --remote=origin --push`.
   Prospect-mock repos stay private until the client is won.
8. **Deploy a noindexed preview:** `wrangler pages deploy site/ --project-name <site-name> --branch preview`.
   Report the `*.pages.dev` preview URL back to Andrew.
9. **Remind:** this is a noindexed sales mock. The client's real domain is NOT
   attached. Go-live for a won client is a separate, deliberate step (production
   branch plus custom domain, a DNS change Andrew performs).
