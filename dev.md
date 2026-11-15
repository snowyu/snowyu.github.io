# 构建环境

- Node.js: 已验证 v22（`package.json` 里 `engines.node >= 20.19`，Hexo 8 的要求）
- 安装: `npm install`（锁文件是 `package-lock.json`；旧的 `yarn.lock` 里记录的
  `registry.npm.taobao.org` 证书已过期，已删除）
- 冒烟测试: `npm test`（`./test.sh`：`hexo clean && hexo generate`，并断言
  1. `public/` 下没有 0 字节文件
  2. `index.html / CNAME / search.xml / atom.xml / sitemap.xml` 非空
  3. `sitemap.xml` 覆盖所有生成的文章页 + tag/category 归档页
  4. 文章页里有标题锚点（`.heading-anchor`），且 `css/main.css` 里有对应样式
  5. 主题版本 = `THEME_VERSION`（默认 7.8.0）
  6. 安装的 Hexo 与 `package.json` 里 `hexo.version` 一致
- 本地预览: `npm run server`
- 部署: `./deploy.sh`（= `npm run build && npm run deploy`，hexo-deployer-git 推到 master）

## 当前版本

| 组件 | 版本 | 备注 |
|---|---|---|
| Hexo | 8.1.2 | 6/7 的 API 兼容，配置无需改动 |
| 主题 NexT | 7.8.0（子模块） | `theme-next` 组织已迁到 `next-theme/hexo-theme-next`，v8.x 需迁移配置，未做 |
| Markdown 渲染 | `hexo-next-imarkdown@0.1.7` | 见下方「别删」说明 |

## 历史坑（别回退）

- `hexo@4.1.0` 在 Node >= 14 下会「成功但写出 0 字节文件」：`hexo-util@1.6.1`
  的 `CacheStream` 与新版 stream 语义不兼容，官方只在 4.2.1 修，不回溯 4.1.x。
  `npm test` 的第 1 条断言就是为它加的。
- `hexo-theme-next-anchor@1.0.3` 已于 2022-09-13 从 npm 下架（`ENOVERSIONS`），
  而且 Hexo 7+ 的插件加载器直接跳过 `hexo-theme-*` 包名 —— 站点 `_config.yml` 里的
  `theme_config.anchor.enable: true` 其实一直是死的。现已由
  `scripts/heading-anchor.js` + `scripts/heading-anchor.styl` 取代（不依赖 cheerio，
  用正则处理 `<hN id=...>`）。
- `hexo-inject`（已停止维护）已移除：注入点是 NexT 自带的
  （`themes/next/scripts/events/lib/injects.js` + `source/_data/*.swig`）。
- `hexo-generator-seo-friendly-sitemap`（0.0.25/0.2.1）会带进硬 pin 的
  `ejs@2.6.1` / `lodash@4.17.12` / `moment@2.24.0`（多个 CVE），已换成官方
  `hexo-generator-sitemap@3`。差异：只输出一个扁平 `sitemap.xml`，不再有
  `post-sitemap.xml` 等子 sitemap 和 `sitemap.xsl`。
- **Markdown 渲染由 `hexo-next-imarkdown` 提供**（它注册 renderer；Hexo 5+ 自带渲染器
  不含 Markdown），删掉它会导致全站空白。
- **`source/_data/next.yml`（910 行）实测不生效**：NexT 在 `generateBefore` 合并主题
  配置，那时 Hexo 还没处理 `source/_data`，所以走的是 `_config.yml` 的 `theme_config:`
  分支。改 next.yml 不会有任何效果，见 `TODO.md` 第 5 节（含探针证据）。
- `package.json` 必须保留 `"hexo": {"version": "x.y.z"}` 对象：hexo-cli 靠它识别站点
  目录，缺了就只打印 usage 且不报错。

## packages/ 目录

`packages/` 下是几个 fork 的源码副本：

- `markdown-it-interactive/`、`markdown-it-highlightjs/`：已入库（对应 npm 上的
  `markdown-it-interactive`、`markdown-it-highlight-i`）。
- `hexo-next-imarkdown/`：npm 包的参考副本，与 `node_modules` 里的版本一致，已
  `.gitignore`（1.8 MB，npm 有发布，不必入库）。要改它时再 vendor 成
  `"hexo-next-imarkdown": "file:packages/hexo-next-imarkdown"`。
- 注意这三个目录里都嵌了一个多余的 `.git`（是主仓库的克隆，`git submodule status`
  报错的根源之一）。要彻底清掉：`rm -rf packages/*/.git`。

## 已知未修的 CVE（都来自停更的 hexo-next-* / imarkdown 依赖链）

`npm audit` 还剩 1 critical / 8 high / 3 moderate / 8 low，全部来自：

- `hexo-next-imarkdown` → `limax` → `pinyin` → `nodejieba` → `@mapbox/node-pre-gyp` → `tar`（critical，构建期原生模块）
- `hexo-next-imarkdown` → `markdown-it@10`、`highlight.js@9`
- `next-util` / `hexo-next-share` → `js-yaml@3`、`lodash`（lodash 官方无 4.x 修复）
- `hexo-util` → `deepmerge`（low，上游未修）

要清就得接手 `hexo-next-imarkdown`（升到 markdown-it 14 + emoji 2 + 换掉 limax 的
CJK slug 方案），见 `packages/hexo-next-imarkdown/`。
