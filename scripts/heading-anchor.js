/* global hexo */

'use strict';

// Heading anchors for NexT — a local replacement for the `hexo-theme-next-anchor`
// npm package, which was unpublished from the registry on 2022-09-13 and is also
// skipped by Hexo 7+ (its plugin loader ignores `hexo-theme-*` package names).
//
// Config lives in source/_data/next.yml:
//
//   anchor:
//     enable: true
//     color: '#0e83cd'
//     position: right   # right = shown on hover, left = always visible
//     margin: 7px
//     text: '#'
//     icon:
//       enable: false
//       font: FontAwesome
//       content: '\f0c1'

const path = require('path');

// <h2 id="foo" class="x">…</h2>  (attributes may contain quoted '>' — handled)
const HEADING_RE = /<(h[1-6])((?:[^>"']|"[^"]*"|'[^']*')*)>((?:.|\r|\n)*?)<\/\1>/g;
const ID_RE = /\sid="([^"]+)"/;
const CLASS_RE = /\sclass="([^"]*)"/;

function anchorConfig() {
  return (hexo.theme && hexo.theme.config && hexo.theme.config.anchor) || {};
}

hexo.extend.filter.register('after_post_render', data => {
  const anchor = anchorConfig();
  if (!anchor.enable) return data;

  const left = anchor.position === 'left';
  let count = 0;

  data.content = data.content.replace(HEADING_RE, (full, tag, attrs, inner) => {
    const id = ID_RE.exec(attrs);
    if (!id) return full; // no id -> nothing to link to
    count += 1;

    const link = `<a class="heading-anchor" href="#${id[1]}" aria-hidden="true"></a>`;
    const classes = CLASS_RE.test(attrs)
      ? `heading-control ${CLASS_RE.exec(attrs)[1]}`
      : 'heading-control';
    const newAttrs = CLASS_RE.test(attrs)
      ? attrs.replace(CLASS_RE, ` class="${classes}"`)
      : `${attrs} class="${classes}"`;

    const open = `<${tag}${newAttrs}>`;
    const close = `</${tag}>`;
    return left ? `${open}${link}${inner}${close}` : `${open}${inner}${link}${close}`;
  });

  if (count) hexo.log.debug(`heading-anchor: added ${count} anchor(s) to ${data.path || data.source}`);
  return data;
});

hexo.extend.filter.register('theme_inject', injects => {
  if (!anchorConfig().enable) return;
  injects.style.push(path.join(__dirname, 'heading-anchor.styl'));
});
