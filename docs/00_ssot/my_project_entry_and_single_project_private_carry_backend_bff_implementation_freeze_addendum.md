---
owner: Codex 总控
status: frozen
purpose: Freeze the backend and BFF implementation boundary for my-project entry and single-project private carry, limited to the private my-project read family and without widening any unrelated board, state machine, or persistence carrier.
layer: L0 SSOT
gate_basis:
  - AGENTS.md
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_truth_freeze_addendum.md
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_contract_freeze_addendum.md
  - docs/02_backend/my_project_entry_and_single_project_private_carry_persistence_truth_addendum.md
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_persistence_migration_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/server/src/modules/project/project-query.service.ts
  - apps/server/src/modules/project/project.presenter.ts
  - apps/server/src/modules/project/project.module.ts
  - apps/server/src/modules/project/entities/project.entity.ts
freeze_date_local: 2026-04-04
---

# 我的项目入口与单项目私域承接 backend-BFF 实现边界冻结单

## 1. Scope

- 本冻结单只覆盖 `我的项目入口与单项目私域承接 backend-BFF implementation freeze`。
- 本冻结单只围绕以下 path 与 read model 冻结实现边界：
  - `GET /server/my/projects` -> `MyProjectListResponse`
  - `GET /server/my/projects/{projectId}` -> `MyProjectDetailReadModel`
  - `GET /api/app/my/projects` -> `MyProjectListResponse`
  - `GET /api/app/my/projects/{projectId}` -> `MyProjectDetailReadModel`
- 本冻结单只服务于：
  - Backend 私域 my-project read family
  - BFF 私域 my-project app-facing shaping
- 本冻结单不进入：
  - 业务代码本体
  - migration 文件修改
  - Flutter 实现
  - 其他板块
  - 搜索 index
  - 地域分类 projection
  - 地图 / 经纬度
- 正式附件列表继续排除在本主线外。

## 2. Upstream Freeze Intake

- `我的项目` truth 已冻结：
  - `我的楼 -> 我的项目`
  - `进行中 / 历史项目`
  - 单项目 `公域信息区 + 私域进度区`
  - `plannedEndAt` 不等于正式完结
  - `待评价 / 已评价` 只是准入与完成边界
- `我的项目` contract 已冻结：
  - 私域 `my/projects` path family
  - `MyProjectListResponse`
  - `MyProjectDetailReadModel`
  - `publicProject + privateProgress`
  - `formalCompletionStatus + evaluationStatus`
- `我的项目` persistence 已冻结：
  - 私域归属依赖 `public.project.organization_id`
  - `publicProject` 继续复用 `public.project`
  - `privateSummary / privateProgress` 只读既有业务真相并读时聚合
  - 不新增 my-project-only table / snapshot / materialized view / migration
- 因此本轮 implementation freeze 的真实含义是：
  - 只给后续 Backend / BFF 提供最小 read-side 施工边界
  - 不重新裁定 truth
  - 不重新裁定 contract
  - 不重新裁定 persistence

## 3. Backend Implementation Freeze

### 3.1 Backend 允许职责

- 后续 Backend 实现只允许完成以下职责：
  - 在现有 `/server/my/projects` family 下承接私域 list/detail read entry
  - 基于 current actor 的 current organization scope 做私域归属过滤
  - `publicProject` 继续复用已冻结的公域项目 read model 字段
  - `privateSummary / privateProgress` 继续只从既有订单 / 合同 / 履约 / 验收 / 争议 / 评价真相读时聚合
  - 依据 `formalCompletionStatus` 的读时派生结果完成 `ongoingProjects / historicalProjects` 分组

### 3.2 `GET /server/my/projects` list read 边界

- 后续 list 实现只允许完成：
  - 获取 current organization scope
  - 按 `project.organization_id = current scope id` 过滤项目
  - 从 `public.project` 读出 `publicProject`
  - 从既有业务真相读时聚合出 `privateSummary`
  - 按 `formalCompletionStatus` 分组到：
    - `ongoingProjects`
    - `historicalProjects`
- `publicProject` 只允许承接：
  - `projectId`
  - `projectNo`
  - `title`
  - `buildingType`
  - `budgetAmount`
  - `state`
  - `summary`
  - `areaSqm`
  - `provinceCode`
  - `provinceName`
  - `cityCode`
  - `cityName`
- `privateSummary` 只允许承接：
  - `hasAcceptedOrder`
  - `orderStatus`
  - `contractStatus`
  - `fulfillmentStatus`
  - `acceptanceStatus`
  - `afterSalesOrDisputeStatus`
  - `formalCompletionStatus`
  - `evaluationStatus`
- 后续 list 实现明确不得带入：
  - 完整订单详情 / 合同详情 / 履约详情 / 验收详情
  - 正式附件列表
  - 平台治理信息
  - `奖励金额`
  - `单位平方面积金额`

### 3.3 `GET /server/my/projects/{projectId}` detail read 边界

- 后续 detail 实现只允许完成：
  - 基于 current organization scope 校验单项目归属
  - `publicProject` 继续复用已冻结的 `ProjectReadModel`
  - `privateProgress` 继续只从既有订单 / 合同 / 履约 / 验收 / 争议 / 评价真相读时聚合
  - `formalCompletionStatus` / `evaluationStatus` 按已冻结 persistence truth 读时派生
- `publicProject` 必须保持：
  - `plannedEndAt` 继续只属于公域计划时间
  - 不被包装成正式完结
- `privateProgress` 允许在未来 detail round 承接更细说明，但当前仍不得越界成：
  - 完整订单后台
  - 完整合同后台
  - 完整履约治理后台
  - 正式附件列表 carrier
  - 平台治理字段 carrier

### 3.4 Backend 实现方式边界

- 后续 Backend 实现优先建议新增独立读模块：
  - `apps/server/src/modules/my_project/**`
- 这样做的原因是：
  - 保持私域 `my/projects` path family 的单一职责
  - 避免把 `project / order / contract / inspection / dispute / rating` controller/service 混成一个手写文件
- 如复用现有公域能力，当前只允许 very small read-only mechanical touch：
  - `apps/server/src/modules/project/project.presenter.ts`
  - `apps/server/src/modules/project/project.module.ts`
  - `apps/server/src/modules/project/entities/project.entity.ts`
  - 相关既有 read-only query / repository wiring
- 当前正式禁止：
  - 写入任何 my-project snapshot
  - 新建第二套项目状态机
  - 新建 my-project-only table
  - 新建 my-project-only materialized view
  - 新建 my-project-only attachment carrier
  - 修改 migration 文件

## 4. BFF Implementation Freeze

### 4.1 BFF 允许职责

- 后续 BFF 实现只允许完成以下职责：
  - `GET /api/app/my/projects` 调用 `/server/my/projects`
  - `GET /api/app/my/projects/{projectId}` 调用 `/server/my/projects/{projectId}`
  - 承接 `MyProjectListResponse` 与 `MyProjectDetailReadModel`
  - 继续只承担：
    - auth envelope
    - controlled failure normalization
    - response shaping

### 4.2 `GET /api/app/my/projects` 边界

- BFF list shaping 只允许回传：
  - `MyProjectListResponse`
  - `ongoingProjects`
  - `historicalProjects`
  - 每个 item 下的 `publicProject`
  - 每个 item 下的 `privateSummary`
- BFF 当前不得：
  - 改 `publicProject` 真义
  - 改 `privateSummary` 真义
  - 新增显式 `tags` 数组
  - synthesize richer business truth

### 4.3 `GET /api/app/my/projects/{projectId}` 边界

- BFF detail shaping 只允许回传：
  - `MyProjectDetailReadModel`
  - `publicProject`
  - `privateProgress`
- BFF 当前不得：
  - 改 `publicProject` 真义
  - 改 `privateProgress` 真义
  - 新增正式附件列表
  - 把 `formalCompletionStatus` / `evaluationStatus` 改写成另一套状态名
  - 新增 `奖励金额`
  - 新增 `单位平方面积金额`

### 4.4 BFF 路由边界

- `my/projects` 现正式冻结为独立私域 path family。
- 当前明确不复用：
  - `project/list`
  - `project/detail`
  - `exhibition/workbench`
- BFF 后续实现不得：
  - 影响公域 showcase path 的真义
  - 影响 `project/create`
  - 影响 forum / upload / 其他无关板块

## 5. Allowed Change Surface

- 后续 Backend 实现阶段允许改动面冻结为：
  - `apps/server/src/modules/my_project/**`
  - 如复用必需，允许 very small touch：
    - `apps/server/src/modules/project/project.presenter.ts`
    - `apps/server/src/modules/project/project.module.ts`
    - `apps/server/src/modules/project/entities/project.entity.ts`
    - 相关既有 read-only query / repository wiring
- 后续 BFF 实现阶段允许改动面冻结为：
  - `apps/bff/src/routes/my_project/**`
  - 如复用必需，允许 very small touch：
    - `apps/bff/src/routes/project/project.module.ts`
    - app route registry / module wiring

## 6. Forbidden Change Surface

- 后续实现阶段明确不应触碰：
  - `apps/mobile/**`
  - `apps/admin/**`
  - `docs/**`
  - `apps/server/src/core/migrations/**`
  - `apps/server/src/modules/upload/**`
  - 公域 showcase 现有 path 的行为改义
  - `project/create`
  - `project/workbench`
  - forum / upload
  - 搜索 index
  - 地域分类 projection
  - 地图 / 经纬度
  - 其他板块任何实现

## 7. Formal Attachment List Follow-up

- 正式附件列表继续不进入本轮实现。
- 当前必须继续独立立项为附件 read 主线，不得混入：
  - `MyProjectListResponse`
  - `MyProjectDetailReadModel`
  - `privateSummary`
  - `privateProgress`

## 8. Stage Conclusion

- 当前结论：
  - `Go` for entering the `我的项目入口与单项目私域承接 frontend consumption freeze` stage
  - `No-Go` for直接进入 backend / BFF / Flutter 实现
- 本冻结单的真实含义是：
  - `我的项目` 的 backend / BFF 实现边界已正式冻结
  - public/private 两区的实现责任已写清
  - 正式附件列表仍继续被明确排除在本主线外

