# 构建环境

- Node.js: 已验证 v22（`package.json` 里 `engines.node >= 18`）
- 安装: `npm install`（锁文件是 `package-lock.json`；旧的 `yarn.lock` 里记录的
  `registry.npm.taobao.org` 证书已过期，已删除）
- 冒烟测试: `npm test`（`./test.sh`：`hexo clean && hexo generate`，并断言
  `public/` 下没有 0 字节文件、关键页面非空）
- 本地预览: `npm run server`
- 部署: `./deploy.sh`（= `npm run build && npm run deploy`）

## 历史坑（别回退）

- `hexo@4.1.0` 在 Node >= 14 下会「成功但写出 0 字节文件」：`hexo-util@1.6.1`
  的 `CacheStream` 与新版 stream 语义不兼容，官方只在 4.2.1 修，不回溯 4.1.x。
- `hexo-theme-next-anchor@1.0.3` 已于 2022-09-13 从 npm 下架（`ENOVERSIONS`），
  且它注册的 `theme_inject` 里依赖的 `theme.anchor` 在 NexT 7.6 配置中不存在，
  Hexo 7+ 也会直接跳过 `hexo-theme-*` 包 —— 已移除，无影响。
- `hexo-inject`（已停止维护）也已移除：注入点是 NexT 自带的
  （`themes/next/scripts/events/lib/injects.js` + `source/_data/*.swig`）。
- Markdown 渲染由 `hexo-next-imarkdown` 提供（Hexo 5+ 自带渲染器不含 Markdown），
  删掉它会导致全站空白。
