owner: Codex 总控
status: draft
purpose: Round 0 现状资产识别：识别已存在资产、可复用资产、需补做资产、禁止重复资产。
layer: L0 SSOT

# 《项目现状资产识别单》

## 盘点范围
- 本地工程目录：`/Users/wangweiwei/Desktop/展览装修之家总控`
- 代码现状与 docs 资产。
- 本轮仅盘点，不执行本地开发、云端开发、变更、部署。

## A. 现有前端资产（本地）
- `apps/mobile` 为 Flutter App 主体，当前可见文件量约 `411` 个（`rg --files apps/mobile` 统计）。
- 已存在展览业务消费链与多个功能页面：
  - 展览主页/列表/详情/工作台路径
  - 项目创建、项目详情、订单、合同、里程碑、验收、争议、评分等消费页
  - 行业论坛相关页面与消费层（feed/评论/详情/附件）
  - 身份与主页（profile）相关页面与测试
- 已存在本地测试资产：`apps/mobile/test/*` 中有多条 `exhibition`、`forum`、`profile`、`contract/phase23` 等验证文件。
- 结论：前端非空，具备可复用基础；Round 0 仅可补齐消费层边界，不可重建页面体系。

## B. 现有 BFF 资产
- `apps/bff` 当前存在可运行骨架与现网相关路由/服务模块：
  - `apps/bff/src/app.module.ts`
  - `apps/bff/src/main.ts`
  - `apps/bff/src/routes/routes.module.ts`
  - `apps/bff/src/routes/forum/*`
  - `apps/bff/src/routes/file/*`
  - `apps/bff/src/routes/enterprise_hub/*`
  - `apps/bff/src/core/*`
- 存在 `package.json`、`tsconfig*`、`nest-cli.json` 等基础工程文件。
- 结论：存在 BFF 现有资产，可复用与扩展；本轮不得本地新建 BFF 平行模块，不得按空壳重写。

## C. 现有后端资产
- `apps/server` 当前存在大量领域模块与企业库模块，已可见：
  - `apps/server/src/modules/*` 下多模块（identity、organization、project、order、contract、bidding、dispute、message、milestone 等）
  - `apps/server/src/modules/enterprise_hub/*` 已存在多实体与 truth/controller/service
  - `apps/server/src/app.module.ts`、`src/core/*`
  - 工程与构建配置：`package.json`、`tsconfig*`、`nest-cli.json`
- 结论：后端存在可复用真相基础；禁止“无服务即重建”式平行建设。

## D. 现有部署/配置/文档资产
- 部署/运维基础：`infra/docker-compose.yml`、`infra/nginx/cloud.conf`、`infra/scripts/*`、`infra/README.md`
- SSOT 主干：`docs/00_ssot/*` 与历史治理文书多份；
- 契约文书与脚本：`docs/01_contracts/*`、`docs/03_bff/*`、`packages/contracts/*`。
- 结论：治理资产、网关与环境文档具备基础量；Round 0 需要做的是一致性核验而非重写。

## E. 可直接沿用（Round 0）
- 已有 Flutter shell 与主要建筑层（exhibition/messages/profile）；
- 已有 BFF/Server 的代码主干与模块分层；
- 现有门户/网关/健康检查脚本；
- 既有 SSOT、permissions、release/gate 文书。

## F. 需要补做（Round 1 前提准备）
- 本轮要求：明确“Round 0 资产账单快照（按云端与本地分别）”；
- 需要云端盘点（不本地修正）：
  - 云端 BFF 当前 `current` 指向的 release 跑通范围；
  - 云端 Server 当前 `current` 指向的 release 与路由挂载状态；
  - `127.0.0.1:8080` 隧道映射与关键路径通路。

## G. 需要修正（仅记录，不本轮施工）
- 已有若干历史文书口径与当前拓扑口径不完全一致；
- 文书口径需统一到本轮 V2 的 80 端口隧道与本地/云端边界定义。
- 旧资产引用路径与当前 `new_workflow v2` 的 top-level 口令需在后续 Round 1 前对齐。

## H. 不得重复
- 禁止本地新建平行 BFF；
- 禁止本地新建平行 Server；
- 禁止重写已有页面/接口/表结构；
- 禁止重复发布旧路由体系；
- 不允许出现“无盘点先实现”。
