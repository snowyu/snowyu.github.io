/* global hexo */

'use strict';

// Apply the site's `source/_data/languages.yml` label overrides to the theme
// i18n (e.g. coauthor: 著者, overriding hexo-next-coauthor's own
// languages/zh-CN.yml which says 合著者).
//
// NexT does exactly this itself in
// themes/next/scripts/events/lib/config.js ("Custom languages support"), but
// it runs on the `generateBefore` event, and Hexo 8 has not filled the `data`
// local (the Data model built from `source/_data/**`) at that point yet:
//
//   PROBE generateBefore  data.keys=[]            <- NexT sees nothing
//   PROBE before_generate data.keys=["body-end","coauthors","languages",...]
//
// (probe: `hexo.on('generateBefore', ...)` + a `before_generate` filter, both
// reading `hexo.locals.get('data')`; same root cause as the dead
// `source/_data/next.yml`, see TODO.md §5).
//
// `before_generate` runs after the Data model exists and before Hexo freezes
// the per-page `__()` helper (hexo/dist/plugins/filter/template_locals/i18n.js,
// applied per route in Hexo._routerRefresh), so merging here does take effect.

function mergeThemeLanguages() {
  const data = hexo.locals.get('data');
  const overrides = data && data.languages;
  if (!overrides) return;

  const i18n = hexo.theme && hexo.theme.i18n;
  if (!i18n) return;

  const configured = hexo.config.language;
  const langs = [].concat(configured, 'default');

  for (const lang of langs) {
    const patch = overrides[lang];
    if (!patch) continue;
    // Same shape as NexT: read the current bucket, patch it, write it back
    // (i18n.set() flattens nested keys, e.g. `symbol.colon`).
    i18n.set(lang, Object.assign(i18n.get(lang), patch));
    hexo.log.debug(`theme-i18n: merged source/_data/languages.yml (${lang})`);
  }
}

// Priority 1: before any other plugin's before_generate work.
hexo.extend.filter.register('before_generate', mergeThemeLanguages, 1);
