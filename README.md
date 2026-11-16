# 数据库研习室

根据数据库课件、考试重点和上机 4–8 练习整理的中文学习网站。

[在线学习网站](https://database-study-lab-20261116.izumifushimi.chatgpt.site)（本人登录访问） · [GitHub 仓库](https://github.com/izumifushimi/Database-Study)（私有）

- 6 个课程模块、31 节讲解，包含关系代数、SQL、规范化、Oracle PL/SQL 与数据库设计。
- 4 组上机练习、32 个任务，提供 MySQL 8.0.16+ 参考解法、建表数据与自评清单。
- 10 道真正执行 SQL 的交互实验，使用本地打包的 sql.js / SQLite。
- 3 个综合案例、14 个分步任务，以及 42 道带解析的概念自测。
- 全文搜索、课程进度、错题记录、自动保存草稿、JSON 备份导入导出；适配手机。

## 本地运行

需要 Node.js 22+、npm 和 Python 3（仅作为静态服务器）。

```sh
npm ci
npm test
npm run build
npm run dev
```

打开 http://localhost:4173/ 。请通过 HTTP 服务器运行，浏览器 Worker 与 WASM 不适合直接双击 file:// 页面。

## GitHub Pages

仓库带有 `.github/workflows/pages.yml`，推送 `main` 后自动测试、构建并上传静态站点产物。启用下列设置后，可自动部署 `dist/` 到 Pages。

1. 将完整项目推送到自己的 GitHub 仓库。
2. 在仓库 Settings → Pages → Build and deployment 中将 Source 设为 **GitHub Actions**。
3. 在 Settings → Secrets and variables → Actions → Variables 添加仓库变量 `ENABLE_PAGES`，值为 `true`。
4. 推送 `main`，或在 Actions 中手动运行 **Build and deploy learning site**。
5. 工作流完成后，在 Pages 或工作流环境中打开部署 URL。

所有静态资源采用相对路径，支持 `https://用户名.github.io/仓库名/` 项目路径。私有仓库的 GitHub Pages 可用性由账号套餐决定；若不可用，可使用私有 Sites 站点预览或自行调整仓库发布方式。

## 项目结构

```text
content/               课程、练习、案例与样例数据（JSON / SQL）
web/                   页面、样式、交互与 SQL Worker 源码
scripts/build.mjs      生成可部署的 dist
scripts/test.mjs       内容与 SQL 逻辑检查
docs/                  方言说明、覆盖范围、可下载数据库脚本
dist/                  构建结果，可直接托管
.github/workflows/     GitHub Pages 自动部署
.openai/hosting.json   Sites 部署信息（项目标识不是凭据）
```

编辑 `content/*.json` 或 `web/*` 后，重新运行测试和构建。原始 PDF、Word、个人 SQL 及其提取文本只保存在本地忽略目录 `source-materials/`，不会提交到仓库或进入网站。

## 数据与检验范围

学习进度只保存在当前浏览器 localStorage；不同域名和设备不自动同步。复习页可导出、导入 JSON 备份，导入以合并方式保留已有记录。

实验室使用 SQLite，支持通用查询、DDL 和 DML；不能执行 Oracle PL/SQL 或 MySQL 存储程序。“检验答案”在独立初始数据中执行用户查询和参考查询，比较列顺序、值、行数和重复；排序题额外比较行顺序。样例结果一致不能证明任意数据上的语义等价。为避免耗时查询阻塞界面，查询 Worker 超时后会重置。

综合题和上机开放题提供参考解法与自评清单，不进行自动语义评分。Oracle / MySQL 编程题参考答案需要在对应数据库中运行；本项目的 SQLite 检验不等同于这些数据库上的编译验证。

## 技术与材料

前端为原生 HTML/CSS/JavaScript。SQL 引擎为 [sql.js](https://sql.js.org/) 1.13.0，MIT 许可证随构建一起保留。数据库课件与题目来自用户提供的课程材料；教学内容重新整理，保留材料原有归属。详见 [覆盖说明](docs/coverage.md) 与 [方言速查](docs/dialects.md)。
