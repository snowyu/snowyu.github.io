#!/usr/bin/env bash
# Smoke test: Hexo must really produce non-empty output on the current Node.
# History: with hexo@4.1.0 + Node >= 14 (hexo-util CacheStream bug) `hexo g`
# reported success while every generated file was 0 bytes.
set -euo pipefail

cd "$(dirname "$0")"

NODE_MAJOR_MIN=${NODE_MAJOR_MIN:-20}
THEME_VERSION=${THEME_VERSION:-7.8.0}

fail() {
  echo "FAIL: $1" >&2
  exit 1
}

node_major=$(node -p 'process.versions.node.split(".")[0]')
[ "$node_major" -ge "$NODE_MAJOR_MIN" ] || fail "Node >= $NODE_MAJOR_MIN required, got $(node -v)"

# Hexo 8 is the target (engines.node >= 20.19); node_modules must match package.json.
hexo_ver=$(node -p "require('./package.json').hexo.version")
[ "${hexo_ver%%.*}" -ge 8 ] || fail "package.json pins hexo $hexo_ver, expected major >= 8"

npx hexo version 2>/dev/null | grep -q "^hexo: $hexo_ver$" || fail "installed hexo does not match package.json (expected $hexo_ver)"
npx hexo clean
build_log=$(mktemp)
trap 'rm -f "$build_log"' EXIT
npx hexo generate 2>&1 | tee "$build_log" || fail "hexo generate exited non-zero"

# Hexo's script loader (hexo/dist/hexo/load_plugins.js -> loadScripts) walks
# `scripts/` recursively and evals EVERY file as JS -- no extension filter.
# Any non-JS asset parked in scripts/ therefore logs "Script load failed".
if grep -q 'load failed' "$build_log"; then
  fail "hexo reported load failure(s): $(grep 'load failed' "$build_log" | tr '\n' ' | ')"
fi
echo "  ok  no script/plugin load failures"

count=$(find public -type f | wc -l | tr -d ' ')
[ "$count" -ge 300 ] || fail "expected >= 300 generated files, got $count"

empty=$(find public -type f -size 0 ! -name '.nojekyll' | wc -l | tr -d ' ')
[ "$empty" -eq 0 ] || fail "$empty empty file(s) generated, e.g.: $(find public -type f -size 0 ! -name '.nojekyll' | head -3 | tr '\n' ' ')"

for f in index.html CNAME search.xml atom.xml sitemap.xml; do
  [ -s "public/$f" ] || fail "public/$f is missing or empty"
done

for f in index.html search.xml atom.xml CNAME; do
  echo "  ok  $f  $(wc -c < "public/$f") bytes"
done

# sitemap: one flat, self-contained sitemap.xml (no index + sub-sitemaps, no
# vendored ejs 2 / lodash / moment from hexo-generator-seo-friendly-sitemap).
# It must cover every generated post page and every tag/category archive
# (the tag/category index pages themselves are not meant to be listed).
posts_gen=$(find public/article public/life -name index.html | wc -l)
posts_map=$(grep -c "<loc>https://riceball.me/\(article\|life\)/" public/sitemap.xml || true)
[ "$posts_map" -eq "$posts_gen" ] || fail "sitemap has $posts_map post URLs but $posts_gen post pages were generated"
tags_gen=$(( $(find public/tags -name index.html | wc -l) - 1 ))
cats_gen=$(( $(find public/categories -name index.html | wc -l) - 1 ))
tags_map=$(grep -c "<loc>https://riceball.me/tags/" public/sitemap.xml || true)
cats_map=$(grep -c "<loc>https://riceball.me/categories/" public/sitemap.xml || true)
[ "$tags_map" -eq "$tags_gen" ] || fail "sitemap has $tags_map tag URLs, expected $tags_gen"
[ "$cats_map" -eq "$cats_gen" ] || fail "sitemap has $cats_map category URLs, expected $cats_gen"
[ "$(grep -c '<loc>' public/sitemap.xml)" -ge 200 ] || fail "sitemap.xml looks incomplete"
echo "  ok  sitemap.xml  $(grep -c '<loc>' public/sitemap.xml) urls ($posts_map posts / $tags_map tags / $cats_map cats)"

post=$(find public/article -name index.html | head -1)
[ -n "$post" ] || fail "no article page generated"
grep -q '</article>' "$post" || fail "article page $post has no rendered <article> body"
echo "  ok  $post  $(wc -c < "$post") bytes"

# Heading anchors: scripts/heading-anchor.js + styles/heading-anchor.styl
# replace the unpublished hexo-theme-next-anchor npm package. The .styl lives
# outside scripts/ on purpose (see the load-failure check above).
grep -q 'class="heading-anchor"' "$post" || fail "no heading anchors in $post (check next.yml anchor.enable)"
grep -q 'heading-anchor' public/css/main.css || fail ".heading-anchor rules missing from public/css/main.css"
echo "  ok  heading anchors  $(grep -o 'class="heading-anchor"' "$post" | wc -l) link(s), styled in main.css"

# Theme must not lag behind: NexT warns "Your theme NexT is outdated".
theme_ver=$(grep -oE "version[^0-9]*[0-9]+\.[0-9]+\.[0-9]+" public/index.html | head -1 | grep -oE "[0-9]+\.[0-9]+\.[0-9]+")
[ -n "$theme_ver" ] || fail "could not read theme version from public/index.html"
[ "$theme_ver" = "$THEME_VERSION" ] || fail "theme NexT is $theme_ver, expected $THEME_VERSION"
echo "  ok  theme NexT $theme_ver"

echo "PASS: $count files, 0 empty, node $(node -v), hexo $(npx hexo version 2>/dev/null | sed -n 's/^hexo: //p')"
