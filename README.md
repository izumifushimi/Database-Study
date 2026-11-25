# 数据库研习室

根据数据库课件、考试重点和上机 1–8 练习整理的中文学习网站。

[打开公开学习网站](https://izumifushimi.github.io/Database-Study/) · [GitHub 公开源码仓库](https://github.com/izumifushimi/Database-Study)

- 6 个课程模块、31 节讲解，包含关系代数、SQL、规范化、MySQL 存储程序 与数据库设计。
- 7 组上机练习、54 个任务，提供 MySQL 8.0.16+ 参考解法、建表数据与自评清单。
- 10 道 MySQL 通用 SELECT / WITH 查询练习，浏览器以 sql.js / SQLite 做兼容演示；完整 MySQL 实验脚本可下载。
- 3 个综合案例、14 个分步任务，以及 42 道带解析的概念自测。
- 全文搜索、课程进度、错题记录、自动保存草稿、JSON 备份导入导出；适配手机。
- 查询题支持“重新练本题”和“重练全部”：恢复初始代码、收起提示与答案，保留上次代码和累计通过记录。

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

本仓库已启用公开的 GitHub Pages。推送 `main` 后，`.github/workflows/pages.yml` 自动测试、构建并将 `dist/` 部署到 https://izumifushimi.github.io/Database-Study/ 。

如需部署到自己的仓库：

1. 将完整项目推送到自己的 GitHub 仓库。
2. 在仓库 Settings → Pages → Build and deployment 中将 Source 设为 **GitHub Actions**。
3. 推送 `main`，或在 Actions 中手动运行 **Build and deploy learning site**。
4. 工作流完成后，在 Pages 或工作流环境中打开部署 URL。

所有静态资源采用相对路径，支持 `https://用户名.github.io/仓库名/` 项目路径。仓库与学习网站均公开，访问网站无需登录。

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

所有教学与下载代码使用 MySQL 8.0.16+。浏览器演示使用 SQLite，仅支持通用 SELECT / WITH 查询，不运行 MySQL 服务器，也不执行 DDL、数据修改和存储程序。“检验答案”在独立初始数据中执行用户查询和参考查询，比较列顺序、值、行数和重复；排序题额外比较行顺序。样例结果一致不能证明任意数据上的语义等价。为避免耗时查询阻塞界面，查询 Worker 超时后会重置。

综合题和上机开放题提供参考解法与自评清单，不对用户开放答案自动评分。MySQL 编程题提供完整的建表、数据与存储程序脚本；使用 `npm run test:mysql` 对原生 MySQL 8.x 编译并验证运行行为，CI 使用 MySQL 8.4。SQLite 检验仅覆盖浏览器兼容查询。

## 技术与材料

前端为原生 HTML/CSS/JavaScript。SQL 引擎为 [sql.js](https://sql.js.org/) 1.13.0，MIT 许可证随构建一起保留。数据库课件与题目来自用户提供的课程材料；教学内容重新整理，保留材料原有归属。详见 [覆盖说明](docs/coverage.md) 与 [方言速查](docs/dialects.md)。

## 原生 MySQL 检查与下载脚本

提供 MySQL 8.x 服务和 mysql 客户端后，执行：

```sh
MYSQL_TEST_HOST=127.0.0.1 MYSQL_TEST_PORT=3306 MYSQL_TEST_USER=root npm run test:mysql
# 使用本机 socket 时：
MYSQL_TEST_SOCKET=/你的/mysql.sock npm run test:mysql
```

需要密码时设置 `MYSQL_TEST_PASSWORD` 环境变量。测试创建带唯一前缀的临时样例数据库并在结束时清理，需要测试账号具备相应建库权限。

- `docs/mysql-course.sql`：选课案例，含建表、数据、视图、游标、过程、函数和成绩审计。
- `docs/mysql-programming.sql`：第 6 章完整存储程序示例，先运行选课案例建表。
- `docs/mysql-lab.sql`：在线查询练习对应的完整 MySQL 数据与答案。
- `docs/sql/library-case.sql`、`docs/sql/employee-case.sql`：图书与薪资综合案例。
- `docs/sql/research.sql`、`teaching.sql`、`construction-intro.sql`、`student-selection.sql`：上机 1–3 的建表与样例数据。
- `docs/sql/*-answers.sql`：上机 1–8 参考答案，按题块和对应数据集执行。

## 查询题重复练习

“重新练本题”重新开始当前题；“重练全部 10 题”在确认后从第 1 题开始新一轮。重练会清除本轮通过标记、恢复起始代码，并收起提示与参考答案。上次代码可展开查看和恢复；刷新、切换题目或导入导出备份都会保留练习记录。复习页显示累计通过数，查询练习页显示本轮进度。
