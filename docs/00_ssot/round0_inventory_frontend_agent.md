---
owner: 前端 Agent
status: round0_inventory
purpose: Round 0 唯一交付物 — 前端盘点版文书（零施工，仅登记）
layer: L0 SSOT 配套文书
related: round0_inventory_review_rubric_and_checklist_draft.md（§4、§7 已回填）
---

# Round 0 盘点版文书 — 前端

## 边界与确认

| 项 | 内容 |
|----|------|
| **本地盘点路径范围** | `apps/mobile/**`（含 `lib/`、`test/`、`scripts/`、`dev/visual_demo/`）。**不**盘点 `apps/admin`、`apps/bff`、`apps/server`、基础设施目录（除非仅作文档交叉引用）。 |
| **不得在本地编写 BFF/Server 代码** | **确认**：Round 0 未修改、未新增 `apps/bff`、`apps/server` 内任何文件；前端职责仅限 Flutter 客户端仓库内事实登记。 |
| **隧道与验证基址** | 与总控既定口径一致：经 `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198` 后，本地验证使用 **`http://127.0.0.1:8080`**（密码/密钥仅手动输入，不入库）。客户端默认 API 基址为 **`http://127.0.0.1:8080/api/app`**（见下文代码指针）。**本轮前端未执行隧道 HTTP 实测**，故不将「线上可用」写入证据层级。 |

## 与 BFF 的基址约定（代码事实）

- **默认**：`AppApiConfig.defaultBaseUrl = 'http://127.0.0.1:8080/api/app'`（`apps/mobile/lib/core/api/app_api_client.dart`）。
- **覆盖**：运行时环境变量 `APP_BFF_BASE_URL`、编译期 `--dart-define=APP_BFF_BASE_URL=...`；可选 `APP_BFF_ACTOR_ID` / `APP_BFF_USER_ID` 注入头（同文件）。
- **路径形态**：业务请求以 **`/api/app/...` canonical path** 解析至上述 base（`resolveCanonicalPath` / `get` / `post` / `put`）。
- **非生产演示**：`lib/dev/visual_demo/*` 使用 `FakeAppApiTransport` — **不得**在台账中记为「已完成 BFF 接入」。

## 主要 feature 与路由索引

**楼级（`app_building.dart`）**

- `/exhibition`、`/renovation`、`/custom-furniture`、`/messages`、`/profile`；`/` → 展览。底部 Tab 仅展览 / 消息 / 我的（装修与全屋定制默认不在底栏）。

**展览子路由（`exhibition_routes.dart` + `app_router.dart`）**

- 首页/工作台：`/exhibition/showcase`、`/exhibition/workbench`、`/exhibition/projects`、`/exhibition/projects/create`、`/exhibition/projects/detail`（含 query）。
- 交易延伸：投标、订单、合同、里程碑、验收、评价、争议等（路径常量见 `exhibition_routes.dart`）。
- 论坛：`/exhibition/forum` 及 square/local/following、topics、posts、authors、comments、publish、drafts、search、me/* 等；动态段 `topics/{id}`、`posts/{id}`、`authors/{id}`。
- 企业黄页：`/exhibition/companies|factories|suppliers`、对应 `detail`、入驻与申请状态。

**Profile（`profile_routes.dart`、`profile_identity_routes.dart`）**

- `/profile/me`、`/profile/company`、`/profile/forum`、`/profile/settings`。
- 身份与组织：`/profile/login`、`/profile/organization`、`/create`、`/join`、`/profile/certification/current`、`/profile/session`。

**注册机制**：`MaterialApp` → `AppRouter.onGenerateRoute` / `onUnknownRoute`（`apps/mobile/lib/shell/navigation/app_router.dart`）。

## 已存在模块/页面（模块级，不全文展开）

- **Shell**：`shell_page.dart`、`app_shell_scaffold.dart`、`shell_state_page.dart`、`route_unavailable_page.dart`。
- **展览**：`exhibition_hub_page.dart` → `exhibition_home_page.dart`；`exhibition_page.dart`（工作台）；`exhibition_trade_pages.dart` 与 `presentation/pages/*`（项目/订单/合同/里程碑等）；`enterprise_hub_*`、`forum/*` 大量 presentation + data consumer。
- **消息**：`messages_page.dart`（实现上调用 `ForumConsumerLayer` 加载 interaction inbox）。
- **Profile**：`profile_page.dart`、`profile_detail_pages.dart`、`profile_forum_pages.dart`、`profile_identity_access_pages.dart`、`profile_organization_pages.dart`。
- **隐藏楼占位**：`renovation_page.dart`、`custom_furniture_page.dart`（`BuildingSkeletonPage`）。
- **状态与启动**：`AppBootstrapController`、`AppShellScope`、`AppSessionStore`、`AppConfigManifest`。

## 与 BFF 对接面（仓库内路径映射，非线上验收）

| 域 | 代表文件 | canonical 前缀（节选） |
|----|----------|------------------------|
| 壳上下文 | `core/boot/app_shell_context_consumer.dart` | `GET /api/app/shell/context` |
| 认证 | `core/auth/auth_consumer_layer.dart` | `/api/app/auth/otp/*`、`refresh`、`logout` |
| 展览首页聚合 | `features/exhibition/data/exhibition_home_aggregation_client.dart` | `/api/app/exhibition/home`、`.../refresh`、`.../location/select` |
| 展览交易 | `features/exhibition/data/exhibition_consumer_layer.dart`（part `exhibition_canonical_paths.dart`） | `exhibition/workbench`、`project/*`、`order/*`、`contract/*`、`milestone/*`、`inspection/*`、`rating/*`、`dispute/*`、`file/upload/*` |
| 论坛 | `features/exhibition/data/forum_consumer_layer.dart` | `/api/app/forum/*`、`/api/app/file/access` |
| 企业黄页 | `features/exhibition/data/enterprise_hub_consumer_layer.dart` | `/api/app/exhibition/enterprise-hub/*` |

## 已知风险（Round 0 仅列示，不修复）

- **仓库存在 ≠ 首期应对用户开放**：交易/企业/论坛等页面均已注册路由；与「首期仅展览+消息+个人」的产品裁剪需总控与 SSOT 对齐，避免深链误暴露未就绪流程。
- **消息楼与论坛耦合**：`MessagesPage` 依赖论坛 inbox API；若产品定义独立「消息域」，后续契约与 consumer 可能需拆分。
- **开发配置散落**：`profile_identity_access_pages.dart` 等存在直连主机类常量痕迹时，与「统一经 8080 隧道」的运营口径需后续收敛（Round 0 不改动代码）。
- **Mock/Fake**：测试与 `dev/visual_demo` 中的假传输层**不得**记为生产接入完成。

## 修订记录

- v0.1：前端 Agent Round 0 首次盘点登记。
