# TODO

Node 22 / Hexo 8 迁移已完成（见 `dev.md` 与 `git log`）。以下是剩下要做的事，
按优先级排列。所有条目的验收标准都是 `npm test`（`./test.sh`）通过。

## 1. 需要人工动作（当下就卡住的）

- [ ] `direnv allow` —— 本仓库 `.envrc` 已从 `use node 12` 改成 `use node 22`，
      改过后 direnv 会 block，需要重新信任：
      `direnv allow`（然后 `direnv exec . node -v` 应打印 v22.x）
- [ ] 把 `dev` 分支也推到 `unas` 远端：上次尝试失败
      （`ssh: connect to host u-nas port 22: No route to host`）。
      恢复后：`git push unas dev`
- [ ] 发布：`./deploy.sh`（= `npm run build && npm run deploy`，
      hexo-deployer-git 会把 `public/` 推到 `master`）。
      **注意**：这是本次升级唯一还没跑的一步。

## 2. 依赖与安全（`npm audit`：1 critical / 8 high / 3 moderate / 8 low）

全部来自停更的 `hexo-next-*` 依赖链，官方包都已经是最新，semver 范围内无解：

- [ ] `hexo-next-imarkdown` 的 CJK slug 链：`limax` → `pinyin@2.11.2` →
      `nodejieba@2.5.2` → `@mapbox/node-pre-gyp` → **`tar`（critical）**。
      这是构建期原生模块（还要编译 C++）。做法：把 `limax` 换掉
      （markdown-it-anchor 自带 slugify，或用 `@sindresorhus/slugify`）
- [ ] `markdown-it@10`（high）+ `highlight.js@9`（moderate，ReDoS）：
      接手 `hexo-next-imarkdown`，升到 markdown-it 14 / emoji 2 / footnote 1，
      highlight.js 11。源码副本已在 `packages/hexo-next-imarkdown/`，
      改完可把依赖指回本地：`"hexo-next-imarkdown": "file:packages/hexo-next-imarkdown"`
- [ ] `next-util` / `hexo-next-share` 的 `js-yaml@3`（high）与 `lodash`
      （high，官方 4.x 不再修）：`next-util` 用的是 `yaml.safeLoad()`，
      升 js-yaml 4 要改成 `yaml.load()`；本地 `packages/` 里有这两个 fork 的源码
- [ ] `hexo-util → deepmerge`（low）、`hexo-*` 的 low：上游未修，只能等
- [ ] GitHub Dependabot 在默认分支（`master`）上仍报 2 个漏洞：那是历史提交进
      `master` 的旧 `package.json`。第 1 条的 deploy 跑完、或直接把 `master` 里的
      `package.json` 同步过来后会消掉
      （见 https://github.com/snowyu/snowyu.github.io/security/dependabot）

## 3. 主题：NexT 7.8.0 → 8.x（单独一个 PR）

现在是 `theme-next` 组织（已停更）的最后一个版本 v7.8.0，每次 generate 都会打
`WARN The upstream repository of theme NexT has been changed`。

- [ ] 子模块 URL 换成 `https://github.com/next-theme/hexo-theme-next`（最新 v8.29.1；
      注意该仓库没有 v7.x 的 tag，所以只能一步升 8）
- [ ] 迁移配置：`_config.yml` 的 `theme_config:`（第 152 行起）+
      `source/_data/next.yml`（910 行）。逐项核对
      https://theme-next.js.org/docs/getting-started/configuration.html
      与 v8 的 changelog（废弃项：`mediumzoom`、部分 `custom_file_path` 点位、
      FontAwesome → ForkAwesome 等）
- [ ] 验收：`npm test` 通过；并人工过一遍首页/文章/归档/搜索/评论（utteranc）/
      分享按钮（`hexo-next-share`）/ 著者标签（`hexo-next-coauthor`）是否正常
- [ ] 升 8 后可考虑删掉 `scripts/heading-anchor.js`，改用主题自带的标题锚点

## 4. 测试与 CI

- [ ] 加 GitHub Actions：`push` 时在 node 20 / 22 上跑
      `npm ci && npm test`（现在只有本地手动跑）
      workflow 需要 `actions/checkout@v4` + `submodules: recursive`
- [ ] `test.sh` 目前不校验 `atom.xml` 里条目数量、也不跑 `hexo deploy --generate`；
      可以补：断言 `hexo d -g` 不报配置错误（不真的 push）
- [ ] `test.sh` 的锚点断言取的是 `find public/article | head -1`，不同机器上文章
      顺序不同（一次 36 个锚点、一次 5 个）。改成断言「所有文章页锚点总数 > 0」
      更稳定

## 5. 配置：`source/_data/next.yml` 是个死文件（实测）

NexT 在 `generateBefore` 里合并配置（`themes/next/scripts/events/index.js:5` →
`scripts/events/lib/config.js`：`if (data.next) … else merge(theme.config, config.theme_config)`），
但此时 Hexo 还没处理 `source/`，`hexo.locals.get('data')` 里**没有** `next`，
所以走的是 `theme_config` 分支。

证据（临时在 `next.yml` 末尾加 `__probe__: hello-from-next-yml`，再用一个
`after_generate` 探针脚本读值）：

```
PROBE data keys: body-end,head,coauthors,languages,next   # 文件确实被读进 data 模型
PROBE __probe__= undefined | minify= true                  # 但主题配置里没有它；minify 来自 _config.yml
```

叶子数对比：`_config.yml` 的 `theme_config` 190 项、`next.yml` 284 项。

- [ ] 94 项只存在于 `next.yml`，即这些设置**从未生效**，实际用的是 NexT 默认值。
      值得先核对的：`excerpt_description: true`、`read_more_btn: true`、
      `font.*`（Lato 字体设定）、`chat.*`（Chatra 按钮）
- [ ] 11 项两边冲突，赢的是 `_config.yml`（例如 `comments.active: utteranc`、
      `disqusjs.enable: true` + 真实 apikey、`tag_icon: true`、
      `symbols_count_time.item_text_total: true`、`github_banner.permalink`、
      `anchor.icon.enable: true`）。这些是对的，别被 next.yml 里的 `false`/`yourname` 迷惑
- [ ] 处理：把上面 94 项里真正想要的并进 `_config.yml` 的 `theme_config:`（第 152 行起），
      然后删掉 `source/_data/next.yml`，避免以后改它却没用。
      注意 `source/_data/head.swig`、`body-end.swig` **是生效的**
      （走 `theme_config.custom_file_path`，`_config.yml:163`），别一起删
- [x] 同类风险：`source/_data/languages.yml` 也走同一个 `generateBefore` 时机
      —— **已证实，已修**。探针：

      ```
      PROBE generateBefore  data.keys=[]
      PROBE before_generate data.keys=["body-end","coauthors","languages","head","next"]
      PROBE before_generate theme.i18n(zh-CN).coauthor="合著者"   # 插件自带的默认值
      ```

      即 NexT 的 `if (data.languages)` 分支拿到的是空 data，站点写的
      `coauthor: 著者` 从未生效，页面一直渲染 `合著者`。修法：
      `scripts/theme-i18n.js` 在 `before_generate`（priority 1）重做
      `i18n.set(lang, Object.assign(i18n.get(lang), data.languages[lang]))`；
      `test.sh` 断言全站 0 个 `合著者`、至少 1 个 `著者`
- [ ] 同一个时机问题适用于 `generateBefore` 里读 `hexo.locals.get('data')` 的
      任何主题/插件脚本（NexT 7.8.0 的 `scripts/events/lib/config.js` 是唯一一
      处）；升 NexT 8 后先看上游是否改成 `before_generate`，再决定要不要保留
      `scripts/theme-i18n.js`
- [ ] `source/_data/coauthors.yml` 由 `hexo-next-coauthor` 在渲染期读取，不受此影响

## 6. 小尾巴

- [ ] `packages/hexo-next-imarkdown/.git` 是误留下的主仓库克隆（`git submodule status`
      曾因此报错）。清掉：`rm -rf packages/hexo-next-imarkdown/.git`（工作区文件不受影响）
- [ ] `debug.log`（553 KB）已不被 git 跟踪（`.gitignore` 有 `*.log`），可删
- [ ] `scripts/index.js` 全是注释（hexo-cake-utils 的试验），确认无用后删除
- [ ] `theme_config.minify: true`（`_config.yml:159`）是 NexT 的「按需裁剪」开关
      （`themes/next/scripts/filters/minify.js`：删掉未启用的 `js/motion.js`、
      `lib/velocity`、`lib/font-awesome` 等），**不是** HTML 压缩。
      想压 HTML 需要另加 minifier，或在 `dev.md` 里把这点写清楚
