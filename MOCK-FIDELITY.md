# Mock fidelity rules (referenced by /ship step 5)

The mock's job: modernize while keeping base functionality and content the same.
A prospect should recognize their site, working, just better.

1. Coverage — build the real page set from crawl/pages.txt, or agree a scoped
   subset with Andrew first. Never silently ship fewer pages.
2. Functionality — every link/button/form from crawl/functionality.md works:
   real destinations for external links, tel:, mailto:, portals; Formspree or
   labeled stubs for forms; no dead controls. Anything not carried over is
   listed for Andrew, never dropped silently.
3. Content — reuse the client's real copy from the mirror; modernize structure,
   don't invent claims.
4. Assets — real favicon(s) + logo from crawl/assets/ referenced in <head>;
   no favicon 404.
5. Contrast — WCAG 2.2 AA in default AND dark sections; visible focus states.
6. SEO — per-page title, ~155-char description, one H1, structured data.
7. Staging safety — _headers noindex, robots.txt disallow, LF gitattributes.
8. QA before review — serve locally, zero 404s, all routes resolve.
