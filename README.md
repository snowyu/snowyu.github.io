## hexo-generator-indexed

```yml
# site _config.yml
index_generator:
  per_page: 10
  order_by: -updated # no useful, it should sort by -(updated||date)
  pagination_dir: page
```

now the post meta can use `sticky: true`

## hexo-next-coauthor

Show author info on article lists and article head.

## Math Formulas Render Support

### marked-it

* TODO: ASCIIMath more easy: https://github.com/quertt/markdown-it-asciimath

```bash
npm i hexo-renderer-markdown-it
```

```yml
#  _config.yml
# Markdown-it config
## Docs: https://github.com/celsomiranda/hexo-renderer-markdown-it/wiki
markdown:
  render:
    html: true
    xhtmlOut: false
    breaks: true
    linkify: true
    typographer: true
    quotes: '“”‘’'
  plugins:
    - markdown-it-abbr
    - markdown-it-footnote
    - markdown-it-ins
    - markdown-it-sub
    - markdown-it-sup
    - '@liradb2000/markdown-it-katex'
  anchors:
    level: 2
    collisionSuffix: 'v'
```

```yml
#  source/_data/next.yml
# Math Formulas Render Support
math:
  # hexo-renderer-markdown-it-plus (or hexo-renderer-markdown-it with markdown-it-katex plugin) required for full Katex support.
  katex:
    enable: true
    # See: https://github.com/KaTeX/KaTeX/tree/master/contrib/copy-tex
    copy_tex: false
```

### pandoc

```bash
sudo apt install pandoc
npm install hexo-renderer-pandoc
```

```yml
pandoc:
  mathEngine: katex # By default, mathEngine is mathjax.
```

```yml
# Math Formulas Render Support
math:
  # Default (true) will load mathjax / katex script on demand.
  # That is it only render those page which has `mathjax: true` in Front-matter.
  # If you set it to false, it will load mathjax / katex srcipt EVERY PAGE.
  per_page: true

  # hexo-renderer-pandoc (or hexo-renderer-kramed) required for full MathJax support.
  mathjax:
    enable: true
    # See: https://mhchem.github.io/MathJax-mhchem/
    mhchem: false
  katex:
    enable: false
```

## Theme-next Customized:

themes/next config: `source/_data/next.yml`:

`source/_data/head.swig`:

```html
<link rel="pgpkey" type="application/pgp-keys" href="/key.pub">
```

```bash
echo '(challenge text from indieauth.com)' | gpg --clearsign --armor
```

## Set up using IndieAuth.com(TODO)

IndieAuth.com is a service that allows you to sign in as your site by using your social media profiles. Your homepage and social media profiles need to link to each other for verification. Instead of registering for an account at indieauth.com, it uses your existing social media accounts to verify you own the URL you're signing in as.

1. Add rel-me links to your homepage for various ways to reach you,
e.g. <a href="https://github.com/aaronpk" rel="me">GitHub</a>.
Make sure any social media profiles you linked to have a link back to your homepage.
2. Finally, include <link rel="authorization_endpoint" href="https://indieauth.com/auth"> on your homepage.
