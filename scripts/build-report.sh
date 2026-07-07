#!/usr/bin/env bash
# Turn a check's report.md into a branded Schillwerk PDF + editable Word doc.
# Usage: scripts/build-report.sh <run-folder> "<Client Name>" "<site-url>" ["<Title>"]
# Title defaults to "Website Audit"; pass e.g. "AI Opportunity Plan" to rebrand.
# Outputs report.pdf and report.docx into the same run folder.

set -euo pipefail

RUNDIR="${1:?usage: build-report.sh <run-folder> \"<Client Name>\" \"<site-url>\"}"
CLIENT="${2:-}"
SITE="${3:-}"
TITLE="${4:-Website Audit}"

REPO="$(cd "$(dirname "$0")/.." && pwd)"
ASSETS="$REPO/assets"
SRC="$RUNDIR/report.md"
[[ -f "$SRC" ]] || { echo "No report.md found in $RUNDIR"; exit 1; }

DATE="$(date '+%B %d, %Y')"
SUBTITLE=""; [[ -n "$CLIENT" ]] && SUBTITLE="Prepared for $CLIENT"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
cat "$SRC" "$ASSETS/disclaimer.md" > "$TMP/combined.md"

echo "==> Building PDF"
pandoc "$TMP/combined.md" -f gfm+fenced_divs \
  --template "$ASSETS/report.html.template" \
  -M title="$TITLE" -M client="$CLIENT" -M site="$SITE" -M date="$DATE" \
  -o "$TMP/report.html"
weasyprint "$TMP/report.html" "$RUNDIR/report.pdf" -s "$ASSETS/report.css"

echo "==> Building Word doc"
pandoc "$TMP/combined.md" -f gfm+fenced_divs \
  --reference-doc "$ASSETS/reference.docx" \
  -M title="$TITLE" -M subtitle="$SUBTITLE" -M date="$DATE" \
  -o "$RUNDIR/report.docx"

echo "Wrote:"
echo "  $RUNDIR/report.pdf"
echo "  $RUNDIR/report.docx"
