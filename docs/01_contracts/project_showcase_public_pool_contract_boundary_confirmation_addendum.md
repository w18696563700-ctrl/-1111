---
owner: Codex 总控
status: frozen
layer: L2 Contracts
freeze_date_local: 2026-05-02
purpose: Confirm the minimum contract boundary for project showcase public-pool recovery without expanding `project/list` into private project truth.
inputs_canonical:
  - docs/00_ssot/project_showcase_public_pool_recovery_exit_boundary_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/01_contracts/project_name_access_request_contract_freeze_addendum.md
  - docs/01_contracts/project_list_published_at_contract_refinement_addendum.md
  - docs/03_bff/project_showcase_filter_and_project_create_form_refactor_bff_aggregation_app_facing_surface_freeze_addendum.md
  - apps/bff/src/routes/project/project.service.ts
  - apps/server/src/modules/project/project-query.service.ts
---

# 项目展示公开池恢复 Contracts / BFF / Server 边界确认单

## 0. 总裁决

- 当前是否新增 `GET /api/app/project/list` 路由：`No-Go`。
- 当前是否新增 query 参数：`No-Go`。
- 当前是否把 `my/projects` 或私域项目混入 `project/list`：`No-Go`。
- 当前是否需要 OpenAPI 最小校正：`Go`。
- 当前是否需要 BFF 重实现：`No-Go`。
- 当前是否需要 Server 最小保护：`Go`。

本轮 contract 处理不是能力扩面，而是把既有冻结单和 BFF/Server 已输出字段同步回 `openapi.yaml`，避免 contracts 与运行代码继续漂移。

## 1. `GET /api/app/project/list` 保持不扩路由

### 1.1 路由与 query 维持现状

`GET /api/app/project/list` 继续只承接：

1. `provinceCode`
2. `cityCode`
3. `areaBucket`
4. `budgetBucket`
5. `page`
6. `pageSize`

本轮不新增：

- `state`
- `visibility`
- `ownerOnly`
- `includePrivate`
- `includeHistorical`
- `includeConverted`
- `withAttachments`
- `withPrivateProgress`

### 1.2 响应模型维持公开列表卡片边界

`ProjectShowcaseListItemReadModel` 本轮只允许补齐既有冻结字段：

1. `displayTitle`
2. `nameAccess`
3. `publishedAt`

这些字段已分别由项目名称申请查看 contract 和 project list publishedAt refinement 冻结；本轮只把它们同步进 OpenAPI 投影。

## 2. BFF 边界确认

BFF 当前只允许：

1. 接收 app-facing query。
2. 转发到 `/server/projects`。
3. 做 app-facing response shaping。
4. 对 `publishedAt / displayTitle / nameAccess` 做 fail-closed 校验。

BFF 当前不得：

1. 调用 `/server/my/projects` 拼装 `/api/app/project/list`。
2. 根据 `state / publishedAt / plannedEndAt` 自己拥有公开资格真值。
3. 自己恢复 `submitted / converted_to_order / awarded` 到公开展示池。
4. 输出 Flutter 本地假项目。

## 3. Server 边界确认

Server 是唯一公开资格 owner。本轮 Server 最小修正只允许：

1. 保持 `publishedAt IS NOT NULL` 作为已进入公域公开列表的发布时间真源。
2. 保持 `plannedEndAt` 只做 public read trimming。
3. 在统一公开可见性判断里补齐 `state = published`。
4. 补充针对性测试，证明 `awarded / converted_to_order` 即使保留 `publishedAt` 也不进入普通 `project/list`。

本轮 Server 不允许：

1. 重构完整项目状态机。
2. 改写 bid award / order / contract / payment 主链。
3. 新增 migration。
4. 新增公开展示投影表。
5. 通过脚本批量改云端业务数据。

## 4. Generated Types 边界

如果更新 `openapi.yaml`，允许运行正式 contract generation，使 generated projection 与 OpenAPI 对齐。

不得手工扩大 generated types 到：

- private progress
- order / contract / milestone
- payment / authorization
- attachment list
- action matrix
- governance / review state

## 5. No-Go 清单

1. No-Go：把 `MyProjectListResponse` 合并进 `ProjectListResponse`。
2. No-Go：把 `ProjectReadModel` 详情字段大面积塞回 list card。
3. No-Go：把 `viewerProjectRelation` 加入 list。
4. No-Go：让 Flutter 用本地账号项目补空。
5. No-Go：让 BFF 用 fallback 数据补空。
6. No-Go：未二次确认前对云库补写 `publishedAt`。

## 6. 阶段结论

- `Go` for OpenAPI 最小校正。
- `Go` for generated contract projection update if the repo command is available.
- `Go` for 第 3 天 Server 最小保护。
- `No-Go` for BFF 重实现。
- `No-Go` for Flutter 修改。
- `No-Go` for cloud write before 第 4 天二次确认。
