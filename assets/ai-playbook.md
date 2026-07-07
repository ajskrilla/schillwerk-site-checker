# Schillwerk AI Opportunity Playbook

The rubric /aiplan applies to map a business to AI plays. This is judgment
guidance for Claude Code, not deterministic rules. Every recommendation must
trace to an observed signal, and every assumption gets flagged for discovery.

## Step 1 — classify the business from observed signals only

Derive these from the crawl (pages.txt, mirror/, functionality.md), the audit,
and the homepage stack scan. Never invent; mark unknowns as discovery questions.

- **Trade / domain:** what they sell (services vs products), industry, regulated
  or safety-adjacent? (regulated => citations + human review are mandatory)
- **Size proxies:** page count, product/catalog size, locations, team page size,
  national vs local service area, martech sophistication (GTM, CRM, automation
  tools present = bigger org).
- **Customer type:** B2C local consumers, B2C national, B2B, trade/pro buyers,
  or mixed. Who fills the forms?
- **Inbound surface:** how many forms, what they ask, booking/scheduling
  present, phone-first vs form-first, live chat present.
- **Content assets:** document libraries (SDS, spec sheets, manuals), FAQ depth,
  blog volume, how-to content. Rich content = retrieval plays; thin content =
  content plays.
- **Existing AI/automation:** chat widgets, chatbots, marketing automation
  (SharpSpring/HubSpot), booking systems. If they already use AI, the pitch is
  "scale what you started," never "adopt AI."
- **Commerce model:** direct e-commerce, retail-distributed, quote-based,
  appointment-based.

## Step 2 — candidate plays (pick 2-3 that fit, never a laundry list)

Each play below lists its fit conditions. Recommend only where conditions are
met by observed signals; note the strongest one first.

**A. Document-grounded knowledge assistant (RAG).**
Fit: substantial document/FAQ/spec library; staff or customers ask repetitive
technical questions. Strong for manufacturers, trades with spec-heavy products,
anyone with SDS/manuals. Internal-first deployment; every answer cites source.
Weak fit: thin-content local service sites.

**B. Inbound triage + response drafting.**
Fit: multiple forms or high inquiry volume; email-first businesses; visible CRM
or marketing automation. Classifies inquiries, routes, drafts replies a human
approves. Strong for B2B and quote-based businesses.

**C. Quote / estimate assistant.**
Fit: quote-based service businesses (cleaning, contracting, landscaping) where
pricing follows describable rules. Guided intake that produces a draft estimate
a human confirms. Never auto-sends prices.

**D. Booking + follow-up automation.**
Fit: appointment businesses with no or clunky online booking. Usually
buy-the-stack first (a scheduler SaaS), with AI only for reminders/rebooking
copy. If a scheduler alone solves it, say so - do not force AI in.

**E. Content pipeline with human approval.**
Fit: businesses whose search visibility depends on fresh local/how-to content
but who publish rarely. Drafts posts/GBP updates from their own materials;
human approves everything (platform AI-labeling compliance).

**F. Review & reputation responses.**
Fit: local consumer businesses with active review profiles. Drafts responses in
the owner's voice for approval. Small, cheap, good first taste of AI.

**G. Internal ops copilot (docs/SOPs).**
Fit: larger orgs with internal procedures, onboarding, or compliance docs.
Same RAG mechanics as A, pointed inward. Needs an IT-ish buyer.

## Step 3 — sizing and pricing anchors (adjust to signals)

- Micro/local (single location, <15 pages): one small play, fixed-fee
  $1.5k-4k pilot; running cost pennies/day. Lead with C, D, E, or F.
- Mid (multi-page catalog, some martech): $4k-8k pilot. Lead with B or A.
- Larger/national (big catalog, CRM+automation stack, IT staff): $6k-12k+
  pilot, IT-owned framing, discovery call mandatory. Lead with A, B, or G.
Verify current Claude API pricing before quoting per-question costs.

## Step 4 — always include, non-negotiable

- Schillwerk defaults: cloud API (no self-hosting, no training), buy-the-stack,
  human-in-the-loop for anything customer-facing, bounded pilot first.
- A "signals we saw" section: every recommendation tied to an observation.
- A "to confirm in discovery" list: the assumptions behind each play.
- Honest exclusions: name at least one popular AI play that does NOT fit this
  business and say why. This builds more trust than the recommendations.
- No guaranteed outcomes. Accuracy bounded by their source content.
- If they already use AI: frame everything as scaling/hardening what exists.
