---
description: Generate a client-tailored AI opportunity action plan from audit + crawl signals (pairs with the website audit as one leave-behind)
argument-hint: <url> "<Client Name>"
---

Build an AI opportunity action plan for: $ARGUMENTS

This pairs with the website audit to form the full Schillwerk leave-behind:
"here is the state of your website, and here is how AI could help your
business." Everything is read-only and grounded in observed signals.

1. **Gather signals (reuse before re-collecting).** If `~/clients/<site-name>/`
   already has `audit/` and `crawl/` outputs, use them. Otherwise run
   `scripts/check-site.sh` and `scripts/crawl-site.sh` into that folder first.
   Also read any chat-produced `functionality-inventory.md` as authoritative.

2. **Classify the business** per Step 1 of `assets/ai-playbook.md`: trade,
   size proxies, customer type, inbound surface, content assets, existing
   AI/automation, commerce model. Every classification must cite the signal it
   came from (page, form, script host, content observed). Unknowns become
   discovery questions, never guesses.

3. **Select 2-3 plays** from the playbook whose fit conditions are actually met.
   Order by strength of fit. For each: what it does in plain language, the
   signals that make it fit, what it would take (Schillwerk defaults: cloud
   API, buy-the-stack, human-in-the-loop, bounded pilot), and a price anchor
   from the playbook sizing bands. Include the honest exclusion: one popular AI
   play that does NOT fit and why. If they already use AI or automation, frame
   as "scale what you have started."

4. **Write `~/clients/<site-name>/ai-plan/report.md`** with this structure:
   - Summary (2-3 sentences: the business as observed, the one-line opportunity)
   - What we observed (the signals, honestly labeled as outside-in)
   - Recommended plays (2-3, ordered, each with fit rationale + anchor)
   - What we would NOT do (the exclusion + why)
   - How a pilot works (phased: pilot -> evaluate -> expand; human-in-the-loop)
   - To confirm in discovery (the assumptions list)
   - Disclaimer: concept for discussion, not a proposal; no guaranteed
     outcomes; accuracy bounded by their content; SOW follows if they proceed.
   Plain language, no em-dashes, no unverified claims about their business.

5. **Brand it.** `scripts/build-report.sh ~/clients/<site-name>/ai-plan
   "<Client>" <url>` — but pass the title metadata "AI Opportunity Plan" so it
   does not render as "Website Audit". If build-report.sh does not yet accept a
   title argument, add an optional 4th positional arg TITLE (default "Website
   Audit") and use it in both pandoc -M title flags. ASCII-only metadata.

6. Print a 2-sentence summary, the report paths, and the discovery questions
   Andrew should ask first. Do not send anything anywhere.
