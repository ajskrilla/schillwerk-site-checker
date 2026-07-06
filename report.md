---
description: Turn a completed check's report.md into a branded Schillwerk PDF + Word doc
argument-hint: <run-folder> [Client Name]
---

Build the client-facing branded audit documents for: $ARGUMENTS

1. Identify the run folder (e.g. `checks/<domain>-<date>/`) and confirm
   `report.md` exists in it.
2. Determine the client business name and site URL. Use any name passed in the
   arguments; otherwise infer the site from the folder name and read report.md
   for the business name. If the client name is genuinely unclear, ask before
   building rather than guessing.
3. Before building, scan report.md for any statement that ASSERTS a fact about
   the business (licensed, insured, bonded, service area, guarantees) rather than
   flagging it. If one is asserted, surface it to the user to confirm first. Do
   not ship unverified claims in a client-facing document.
4. Run: `scripts/build-report.sh "<run-folder>" "<Client Name>" "<site-url>"`
5. Confirm report.pdf and report.docx were written and print their paths. Remind
   the user: the PDF is the emailable leave-behind, the Word doc is the editable
   copy, and this command sends nothing anywhere.
