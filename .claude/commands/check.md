---
description: Run a full read-only Schillwerk website check on a URL and write a branded report
argument-hint: <url> [--deep]
---

Run a complete read-only website check for: $ARGUMENTS

This is READ-ONLY. Do not log in, submit forms, or change anything on the site.

Procedure:

1. Derive a run folder from the domain and today's date, e.g.
   `checks/example-com-2026-07-05/`. If the arguments include `--deep`, set
   DEEP_A11Y=1 when running the collector (adds a WCAG2AA pass; needs Chrome).

2. Gather data:
   - Run `scripts/check-site.sh <url> <run-folder>` (prefix `DEEP_A11Y=1 ` if
     `--deep` was passed).
   - This writes: psi-mobile.json, psi-desktop.json, index.html, headers.txt,
     redirects.txt, tls.txt, robots.txt, sitemap.xml, mixed-content.txt,
     links.json, and (deep only) a11y.json.
   - If the script fails on any piece, continue and mark that section
     "not measured".

3. Read every output and pull real values only:
   - Performance: LCP, INP, CLS, and Lighthouse performance score, mobile and
     desktop. Prefer field (CrUX) data; note when it is lab-only.
   - Accessibility: Lighthouse a11y score plus failed audits; if a11y.json
     exists, list its specific WCAG2AA violations.
   - SEO / best-practices scores and failed audits.
   - Links: broken (4xx/5xx) links with the page they appear on.
   - Security & delivery hygiene:
     - redirects.txt: do http:// entries land on https://? Is one host canonical
       (www vs non-www), or are both serving 200s?
     - headers.txt: which of CSP, HSTS, X-Content-Type-Options: nosniff,
       Referrer-Policy, Permissions-Policy, X-Frame-Options (or CSP
       frame-ancestors) are present vs missing? If X-XSS-Protection is set to 1,
       flag it as deprecated. Do NOT list X-XSS-Protection as a missing header.
     - tls.txt: cert issuer and expiry. Flag if expired or within ~30 days.
     - robots.txt / sitemap.xml: present? Does robots reference the sitemap?
     - mixed-content.txt: any http:// resources on the page.

4. Do the markup review yourself from index.html:
   - Accessibility: images missing alt, inputs missing labels, missing landmarks,
     heading-order jumps, missing lang attribute, non-visible focus, visible
     low-contrast patterns in the CSS.
   - SEO: title and meta description quality, single H1, canonical link, Open
     Graph, JSON-LD structured data.
   - Trust signals: phone/email/address, reviews or testimonials, stated service
     area, credentials, and exactly one clear primary CTA.
   - Any business claim (insured, bonded, licensed, service area, guarantees):
     list under "confirm with client", do not assert it.

5. Write `report.md` in the run folder per the output structure in CLAUDE.md:
   one-line verdict, prioritized issue table, per-category detail (including the
   Security & delivery hygiene category), short "what we'd do first" close. Plain
   language. No guaranteed results. Every figure traces to a tool output; label
   anything not measured.

6. Print a two-sentence summary and the path to the report. Do not produce the
   client-facing PDF/DOCX here; that goes through the Schillwerk doc pipeline.
