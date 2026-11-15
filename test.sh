#!/usr/bin/env bash
# Smoke test: Hexo must really produce non-empty output on the current Node.
# History: with hexo@4.1.0 + Node >= 14 (hexo-util CacheStream bug) `hexo g`
# reported success while every generated file was 0 bytes.
set -euo pipefail

cd "$(dirname "$0")"

fail() {
  echo "FAIL: $1" >&2
  exit 1
}

node_major=$(node -p 'process.versions.node.split(".")[0]')
[ "$node_major" -ge 18 ] || fail "Node >= 18 required, got $(node -v)"

npx hexo clean
npx hexo generate

count=$(find public -type f | wc -l | tr -d ' ')
[ "$count" -ge 300 ] || fail "expected >= 300 generated files, got $count"

empty=$(find public -type f -size 0 ! -name '.nojekyll' | wc -l | tr -d ' ')
[ "$empty" -eq 0 ] || fail "$empty empty file(s) generated, e.g.: $(find public -type f -size 0 ! -name '.nojekyll' | head -3 | tr '\n' ' ')"

for f in index.html CNAME search.xml atom.xml sitemap.xml post-sitemap.xml; do
  [ -s "public/$f" ] || fail "public/$f is missing or empty"
done

for f in index.html search.xml atom.xml CNAME; do
  echo "  ok  $f  $(wc -c < "public/$f") bytes"
done

post=$(find public/article -name index.html | head -1)
[ -n "$post" ] || fail "no article page generated"
grep -q '</article>' "$post" || fail "article page $post has no rendered <article> body"
echo "  ok  $post  $(wc -c < "$post") bytes"

echo "PASS: $count files, 0 empty, node $(node -v), hexo $(npx hexo version 2>/dev/null | sed -n 's/^hexo: //p')"
