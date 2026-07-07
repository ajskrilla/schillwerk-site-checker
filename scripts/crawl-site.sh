#!/usr/bin/env bash
# Schillwerk deep crawl + asset harvest (read-only).
# Usage: scripts/crawl-site.sh <url> <output-folder>
# Produces:
#   <out>/pages.txt      full page list (sitemap-first, crawl fallback)
#   <out>/mirror/        rendered-source mirror of every page (HTML only)
#   <out>/assets/        favicons, logos, images, css/js referenced by the site
#   <out>/functionality.md  skeleton checklist of every link/button/form found
set -uo pipefail

URL="${1:?usage: crawl-site.sh <url> <output-folder>}"
OUT="${2:?usage: crawl-site.sh <url> <output-folder>}"
mkdir -p "$OUT/mirror" "$OUT/assets"
UA="SchillwerkChecker/1.0 (read-only prospect crawl)"
HOST="$(python3 -c 'import urllib.parse,sys;print(urllib.parse.urlparse(sys.argv[1]).netloc)' "$URL")"

echo "==> Page discovery (sitemap first)"
: > "$OUT/pages.txt"
for SM in "https://${HOST}/sitemap.xml" "https://${HOST}/sitemap_index.xml" "https://${HOST}/wp-sitemap.xml"; do
  BODY="$(curl -sS -A "$UA" --max-time 20 "$SM" 2>/dev/null || true)"
  [[ "$BODY" == *"<loc>"* ]] || continue
  # expand sitemap indexes one level
  echo "$BODY" | grep -oP '(?<=<loc>)[^<]+' | while read -r LOC; do
    if [[ "$LOC" == *.xml ]]; then
      curl -sS -A "$UA" --max-time 20 "$LOC" 2>/dev/null | grep -oP '(?<=<loc>)[^<]+' || true
    else
      echo "$LOC"
    fi
  done >> "$OUT/pages.txt"
  break
done

if [[ ! -s "$OUT/pages.txt" ]]; then
  echo "==> No sitemap; shallow crawl fallback (depth 2, same host)"
  python3 - "$URL" "$OUT/pages.txt" << 'PY'
import sys,urllib.request,urllib.parse,re,collections
start,outfile=sys.argv[1],sys.argv[2]
host=urllib.parse.urlparse(start).netloc
seen=set();q=collections.deque([(start,0)])
def fetch(u):
    try:
        r=urllib.request.Request(u,headers={'User-Agent':'SchillwerkChecker/1.0'})
        return urllib.request.urlopen(r,timeout=15).read().decode('utf-8','ignore')
    except Exception: return ''
while q and len(seen)<150:
    u,d=q.popleft()
    u=u.split('#')[0]
    if u in seen or urllib.parse.urlparse(u).netloc!=host: continue
    seen.add(u)
    if d>=2: continue
    for h in re.findall(r'href=["\']([^"\']+)',fetch(u)):
        nu=urllib.parse.urljoin(u,h)
        if urllib.parse.urlparse(nu).netloc==host and not re.search(r'\.(png|jpe?g|gif|webp|svg|pdf|zip|css|js|ico)(\?|$)',nu):
            q.append((nu,d+1))
open(outfile,'w').write('\n'.join(sorted(seen)))
PY
fi
sort -u "$OUT/pages.txt" -o "$OUT/pages.txt"
echo "    $(wc -l < "$OUT/pages.txt") pages found"

echo "==> Mirroring page HTML (read-only GETs)"
i=0
while read -r P; do
  [[ -z "$P" ]] && continue
  i=$((i+1)); [[ $i -gt 200 ]] && { echo "    (capped at 200 pages)"; break; }
  SAFE="$(python3 -c 'import sys,urllib.parse,re;p=urllib.parse.urlparse(sys.argv[1]).path.strip("/") or "index";print(re.sub(r"[^A-Za-z0-9._-]","_",p))' "$P")"
  curl -sSL -A "$UA" --max-time 25 "$P" -o "$OUT/mirror/${SAFE}.html" || true
done < "$OUT/pages.txt"

echo "==> Harvesting favicons + brand assets"
# favicons: declared links on the homepage + the conventional /favicon.ico
curl -sSL -A "$UA" "https://${HOST}/favicon.ico" -o "$OUT/assets/favicon.ico" 2>/dev/null || true
python3 - "$URL" "$OUT" << 'PY'
import sys,re,urllib.request,urllib.parse,os
url,out=sys.argv[1],sys.argv[2]
def fetch(u,binary=False):
    r=urllib.request.Request(u,headers={'User-Agent':'SchillwerkChecker/1.0'})
    d=urllib.request.urlopen(r,timeout=20).read()
    return d if binary else d.decode('utf-8','ignore')
try: html=fetch(url)
except Exception: sys.exit(0)
links=re.findall(r'<link[^>]+rel=["\'][^"\']*(?:icon|apple-touch)[^"\']*["\'][^>]*>',html,re.I)
hrefs=[re.search(r'href=["\']([^"\']+)',l).group(1) for l in links if re.search(r'href=["\']([^"\']+)',l)]
# og:image + first logo-ish imgs
for m in re.findall(r'property=["\']og:image["\'][^>]*content=["\']([^"\']+)',html): hrefs.append(m)
for m in re.findall(r'<img[^>]+src=["\']([^"\']*logo[^"\']*)["\']',html,re.I): hrefs.append(m)
seen=set()
for h in hrefs:
    u=urllib.parse.urljoin(url,h)
    if u in seen: continue
    seen.add(u)
    name=re.sub(r'[^A-Za-z0-9._-]','_',os.path.basename(urllib.parse.urlparse(u).path) or 'asset')
    try:
        data=fetch(u,binary=True)
        open(os.path.join(out,'assets',name),'wb').write(data)
        print(f"    saved {name} ({len(data)} bytes)")
    except Exception as e:
        print(f"    skip {u}: {e}")
PY

echo "==> Functionality skeleton (every link/button/form across mirrored pages)"
python3 - "$OUT" << 'PY'
import os,re,sys,html
out=sys.argv[1]
lines=["# Functionality checklist (auto-extracted; verify + complete by hand or via chat inventory)",""]
for f in sorted(os.listdir(os.path.join(out,'mirror'))):
    if not f.endswith('.html'): continue
    doc=open(os.path.join(out,'mirror',f),encoding='utf-8',errors='ignore').read()
    lines.append(f"## {f[:-5]}")
    for m in re.findall(r'<a[^>]+href=["\']([^"\']+)["\'][^>]*>(.*?)</a>',doc,re.S)[:60]:
        t=re.sub(r'<[^>]+>','',m[1]).strip()[:50]
        if t: lines.append(f"- [ ] link: \"{html.unescape(t)}\" -> {m[0]}")
    for m in re.findall(r'<form[^>]*action=["\']([^"\']*)["\']',doc)[:10]:
        lines.append(f"- [ ] FORM action: {m or '(js-handled)'} — must be reproduced (Formspree or equivalent)")
    for m in re.findall(r'<button[^>]*>(.*?)</button>',doc,re.S)[:30]:
        t=re.sub(r'<[^>]+>','',m).strip()[:50]
        if t: lines.append(f"- [ ] button: \"{html.unescape(t)}\" — wire real behavior or label as stub")
    lines.append("")
open(os.path.join(out,'functionality.md'),'w').write('\n'.join(lines))
print(f"    functionality.md written")
PY

echo "==> Done. Crawl data in $OUT"
