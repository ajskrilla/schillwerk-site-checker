# Schillwerk Simple Website Checker (Claude-powered)

A simple, one-command, read-only checker for small-business sites. Run it against
a prospect's live site and get a branded leave-behind. "Simple" is the UX (one
command, fast, minimal setup); the checks themselves are meant to be thorough.

This is the top of the Schillwerk engagement funnel: quick check -> assessment ->
SOW -> build.

## Hard rules
- READ-ONLY. Never change, log into, or submit anything on anyone's site. Fetch,
  measure, report. Nothing else.
- Every number in the report must trace to a tool output in `checks/<run>/`, not
  a guess. If something was not measured, say "not measured" and why. Never
  estimate performance numbers.
- Ground standards to the present. Core Web Vitals and WCAG guidance shift. The
  current Core Web Vitals are LCP, INP (which replaced FID), and CLS. Trust the
  Lighthouse/PSI output for current thresholds; if anything looks stale, verify.
- No guaranteed rankings or results anywhere. Frame findings as issues and
  opportunities, not promises.
- Any factual claim about the business (insured, bonded, licensed, service area,
  guarantees) goes under "confirm with client", never asserted.

## What the checker covers
1. Mobile / responsiveness
2. Accessibility (WCAG) - Lighthouse a11y score plus a markup review
   (alt text, form labels, landmarks, heading order, visible focus, contrast).
   If `checks/<run>/a11y.json` exists (deep pass), fold in its specific
   WCAG2AA violations.
3. SEO basics - title/meta, single H1, canonical, Open Graph, JSON-LD structured
   data, and whether robots.txt + sitemap.xml exist and reference each other.
4. Performance / Core Web Vitals - from PageSpeed Insights, mobile and desktop.
   Prefer field (CrUX) data when present; note when it is lab-only.
5. Broken links and obviously broken forms.
6. Missing trust signals - contact info, reviews, service area, credentials,
   exactly one clear primary CTA.
7. Security & delivery hygiene (from the collector outputs):
   - HTTPS enforced: http:// entry points redirect to https:// (see redirects.txt).
   - Canonical host: www vs non-www resolve consistently, not both live.
   - TLS certificate valid and not near expiry (see tls.txt).
   - Current security headers present (see headers.txt): Content-Security-Policy,
     Strict-Transport-Security, X-Content-Type-Options: nosniff, Referrer-Policy,
     Permissions-Policy, and X-Frame-Options or CSP frame-ancestors.
   - X-XSS-Protection is DEPRECATED. Do not recommend adding it. If it is present
     and set to 1, flag it as a legacy header to remove or set to 0.
   - No mixed content: no http:// resources loaded on an https page
     (see mixed-content.txt).

## Output
- Write the report to `checks/<domain>-<date>/report.md`.
- Structure: one-line verdict, then a prioritized issue table
  (Severity / Finding / Why it matters / Fix), then per-category detail, then a
  short "what we'd do first" close. Plain language, professional, no jargon dumps.
- Leave-behind length. This is the hook, not the full assessment.
- Brand: navy + gold when rendered. Markdown is the source; the client-facing
  PDF + DOCX are produced through the existing Schillwerk doc pipeline, not here.

## Tools
- `scripts/check-site.sh <url> <run-folder>` gathers everything read-only:
  PSI (mobile+desktop), raw HTML, response headers, redirect/canonicalization
  map, TLS cert, robots.txt, sitemap.xml, mixed-content scan, and a linkinator
  link report. Set `DEEP_A11Y=1` to add a pa11y WCAG2AA pass (needs Chrome).
- Run it first, then read its outputs to write the report.
- If the collector cannot run (no key, offline, no Chrome for deep a11y), fall
  back to what is available and label anything missing "not measured".
