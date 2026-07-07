---
description: Audit a prospect site, deep-crawl it, build reports, stage a high-fidelity noindexed mock, then (after approval) create a private repo and deploy a Cloudflare preview
argument-hint: <url> "<Client Name>"
---

Run the Schillwerk audit-to-mock pipeline for: $ARGUMENTS

Prerequisites: `gh` and `wrangler` authenticated, pandoc + weasyprint installed.
Everything through Phase 1 is read-only and local. Nothing is created or
published until Andrew explicitly approves.

Derive `<site-name>` from the domain (strip protocol/www, lowercase,
letters/numbers/hyphens). Work under `~/clients/<site-name>/`.

## Phase 1 — build and stage (no side effects)

1. **Audit (read-only).** `scripts/check-site.sh <url> ~/clients/<site-name>/audit`,
   then write `audit/report.md` per the checker rubric.

2. **Deep crawl + asset harvest (read-only).**
   `scripts/crawl-site.sh <url> ~/clients/<site-name>/crawl`
   This produces: `pages.txt` (sitemap-first full page list), `mirror/` (the HTML
   of every page), `assets/` (favicon(s), logo, og-image), and
   `functionality.md` (an auto-extracted checklist of every link, button, and
   form across the site). Read `pages.txt` and the mirror — the mock must cover
   the site's real page set, not just the homepage nav.

3. **Inventory.** Claude in Chrome is a CHAT-app tool and is NOT available inside
   Claude Code — do not pretend to use it. Instead:
   - If Andrew has placed a chat-produced inventory file in the client folder
     (e.g. `functionality-inventory.md`), treat it as authoritative.
   - Otherwise, use `crawl/functionality.md` plus the mirrored HTML as the
     inventory, and clearly list anything that could not be verified without a
     rendered browser (JS-injected widgets, dynamic forms). For complex or
     JS-heavy sites, recommend Andrew run the rendered inventory in the chat app
     first and re-run.

4. **Reports.** `scripts/build-report.sh ~/clients/<site-name>/audit "<Client>" <url>`.

5. **Stage the mock** into `~/clients/<site-name>/site/`. FIDELITY RULES — the
   goal is modernize while keeping base functionality and content the same:
   - **Coverage:** rebuild every substantive page in `pages.txt` (or, for very
     large sites, propose a representative scope to Andrew BEFORE building and
     let him choose). Never silently ship fewer pages than the site has.
   - **Functionality:** every link, button, and form in `functionality.md` must
     work in the mock. Buttons keep their real destinations (external links,
     tel:, mailto:, third-party portals point at the real URLs). Forms are wired
     to Formspree or clearly labeled stubs — never dead controls. Check off the
     checklist as you go; anything not reproduced gets listed in a
     "not carried over" section for Andrew, never dropped silently.
   - **Content:** reuse the site's real copy from the mirror (it is the client's
     own content) — modernize structure and presentation, do not invent new
     claims. Business facts follow the confirm-with-client rule.
   - **Assets:** include `crawl/assets/favicon.ico` (and any apple-touch icons)
     at the site root and reference them in <head> — no 404 favicon. Use the
     real logo. Serve images locally from the harvested assets where licensing
     is the client's own material.
   - **Contrast + theme:** meet WCAG 2.2 AA contrast in BOTH the default and any
     dark styling; test text-on-dark sections explicitly (this was a miss in a
     prior run). Visible focus states on all interactive elements.
   - **SEO corrections:** accurate per-page title + ~155-char meta description,
     one H1 per page, structured data, semantic markup.
   - **Staging safety:** `_headers` with X-Robots-Tag: noindex, `robots.txt`
     Disallow all, `.gitattributes` (`* text=auto eol=lf`), `.gitignore`.

6. **Local QA before review.** Serve the mock (`python3 -m http.server` from
   `site/`) and verify: no 404s in the request log (favicon included), every nav
   route resolves, forms and buttons behave per the checklist. Fix before
   presenting.

7. **STOP for review.** Print: top audit findings, report paths, page coverage
   (built vs. total in pages.txt), the functionality checklist status, anything
   not carried over, and the local preview command. Ask Andrew to review and
   EXPLICITLY approve before anything is created or published. Do not proceed
   without a clear yes.

## Phase 2 — publish (only after explicit approval)

8. `git init`, `git add -A`, `git commit -m "Audit + modernized mock for <site-name>"`.
9. Private repo + push: `gh repo create <site-name> --private --source=. --remote=origin --push`.
10. Deploy noindexed preview: `wrangler pages deploy site/ --project-name <site-name> --branch preview`.
    Report the `*.pages.dev` URL.
11. Remind: noindexed sales mock; the client's real domain is NOT attached.
    Go-live for a won client is a separate deliberate step.
