#!/usr/bin/env bash
# Schillwerk Simple Website Checker - read-only data collector.
# Usage: scripts/check-site.sh <url> <output-folder>
# Set DEEP_A11Y=1 for a full WCAG pass (needs headless Chrome, slower).
# Read-only: never writes to, logs into, or submits anything on the target site.

set -uo pipefail

URL="${1:?usage: check-site.sh <url> <output-folder>}"
OUT="${2:?usage: check-site.sh <url> <output-folder>}"
mkdir -p "$OUT"

enc() { python3 -c 'import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1]))' "$1"; }
HOST="$(python3 -c 'import urllib.parse,sys;print(urllib.parse.urlparse(sys.argv[1]).netloc)' "$URL")"
BARE="${HOST#www.}"

PSI="https://www.googleapis.com/pagespeedonline/v5/runPagespeed"
KEYARG=""; [[ -n "${PSI_API_KEY:-}" ]] && KEYARG="&key=${PSI_API_KEY}"
CATS="&category=performance&category=accessibility&category=seo&category=best-practices"
UA="SchillwerkChecker/1.0 (read-only site check)"

echo "==> PageSpeed Insights (mobile + desktop)"
for S in mobile desktop; do
  curl -sS "${PSI}?url=$(enc "$URL")&strategy=${S}${CATS}${KEYARG}" \
    -o "$OUT/psi-${S}.json" || echo "   PSI ${S} failed (continuing)"
done

echo "==> Raw HTML"
curl -sSL -A "$UA" "$URL" -o "$OUT/index.html" || echo "   HTML fetch failed (continuing)"

echo "==> Response headers (security posture)"
curl -sSIL -A "$UA" "$URL" -o "$OUT/headers.txt" || echo "   header fetch failed (continuing)"

echo "==> HTTPS + canonicalization hygiene"
{
  for ENTRY in "http://${BARE}" "http://www.${BARE}" "https://${BARE}" "https://www.${BARE}"; do
    RESULT="$(curl -sS -A "$UA" -o /dev/null -L \
      -w '%{http_code} redirects=%{num_redirects} -> %{url_effective}' "$ENTRY" 2>/dev/null || echo 'unreachable')"
    printf '%-28s %s\n' "$ENTRY" "$RESULT"
  done
} > "$OUT/redirects.txt"

echo "==> TLS certificate"
{
  echo | openssl s_client -servername "$HOST" -connect "${HOST}:443" 2>/dev/null \
    | openssl x509 -noout -issuer -dates 2>/dev/null || echo "cert read failed"
} > "$OUT/tls.txt"

echo "==> robots.txt + sitemap.xml"
curl -sS -A "$UA" "https://${HOST}/robots.txt"   -o "$OUT/robots.txt"   || echo "   no robots.txt"
curl -sS -A "$UA" "https://${HOST}/sitemap.xml"  -o "$OUT/sitemap.xml"  || echo "   no sitemap.xml"

echo "==> Mixed content (http:// resources on the page)"
grep -oiE '(src|href)="http://[^"]+"' "$OUT/index.html" 2>/dev/null | sort -u > "$OUT/mixed-content.txt" || true

echo "==> Broken links (linkinator, read-only crawl)"
npx --yes linkinator "$URL" --recurse --format json > "$OUT/links.json" 2>/dev/null \
  || echo "   linkinator failed (continuing)"

if [[ "${DEEP_A11Y:-0}" == "1" ]]; then
  echo "==> Deep accessibility (pa11y / WCAG2AA - needs Chrome)"
  npx --yes pa11y --standard WCAG2AA --reporter json "$URL" > "$OUT/a11y.json" 2>/dev/null \
    || echo "   pa11y failed (Chrome missing?) (continuing)"
fi

echo "==> Done. Data in $OUT"
