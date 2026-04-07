---
owner: Codex 总控
status: frozen
purpose: Freeze the backend and BFF implementation boundary for aligning project showcase with project publish, limited to showcase list/detail read models and without widening any other board, projection, or implementation scope.
layer: L0 SSOT
gate_basis:
  - AGENTS.md
  - docs/00_ssot/project_showcase_publish_alignment_truth_freeze_addendum.md
  - docs/00_ssot/project_showcase_publish_alignment_contract_freeze_addendum.md
  - docs/02_backend/project_showcase_publish_alignment_persistence_truth_addendum.md
  - docs/00_ssot/project_showcase_publish_alignment_persistence_migration_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/server/src/modules/project/project.presenter.ts
  - apps/server/src/modules/project/project-query.service.ts
  - apps/server/src/modules/project/project.controller.ts
  - apps/server/src/modules/project/project.module.ts
  - apps/server/src/modules/project/entities/project.entity.ts
  - apps/bff/src/routes/project/project.service.ts
  - apps/bff/src/routes/project/project.controller.ts
  - apps/bff/src/routes/project/app-project.controller.ts
  - apps/bff/src/routes/project/project.module.ts
freeze_date_local: 2026-04-04
---

# 项目展示与项目发布对齐 backend-BFF 实现边界冻结单

## 1. Scope

- 本冻结单只覆盖 `project showcase publish alignment backend-BFF implementation freeze`。
- 本冻结单只围绕以下两类 read model 冻结实现边界：
  - `ProjectShowcaseListItemReadModel`
  - shared showcase detail `ProjectReadModel`
- 本冻结单只服务于：
  - `GET /server/projects` 的 list read 职责
  - `GET /server/projects/{projectId}` 的 detail read 职责
  - `GET /api/app/project/list` 的 app-facing list shaping
  - `GET /api/app/project/detail` 的 app-facing detail shaping
- 本冻结单不进入：
  - 业务代码本体
  - migration 文件修改
  - Flutter 实现
  - 其他板块
  - 搜索 index
  - 地域分类 projection
  - 地图 / 经纬度

## 2. Upstream Freeze Intake

- showcase list/detail truth 已冻结：
  - 列表卡片只准入最小 card fields
  - detail 只准入 shared showcase detail fields
  - 正式附件列表必须独立立项
- showcase list/detail contract 已冻结：
  - `ProjectShowcaseListItemReadModel`
  - shared showcase detail `ProjectReadModel`
  - 轻标签不进入显式 `tags` 数组
- showcase list/detail persistence truth 已冻结：
  - 当前都继续由 `public.project` 直出
  - 不新增 list-only projection table
  - 不新增 detail-only read table
  - 不新增 showcase-only migration
- 因此本轮 implementation freeze 的真实含义是：
  - 只给后续 Backend / BFF 提供最小 read-side 施工边界
  - 不重新裁定 truth
  - 不重新裁定 contract
  - 不重新裁定 persistence

## 3. Backend Implementation Freeze

### 3.1 Backend 允许职责

- 后续 Backend 实现只允许完成以下职责：
  - 在现有 `/server/projects` family 下承接 showcase list read entry，只返回 `ProjectShowcaseListItemReadModel`
  - 在 `GET /server/projects/{projectId}` 承接 shared showcase detail `ProjectReadModel`
  - list/detail 继续只从 `public.project` 直出
  - 只在 presenter/query/controller 层完成 read shaping

### 3.2 `GET /server/projects` list read 边界

- 后续 list 响应只允许承接：
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
- 后续 list 实现不得带入：
  - `districtCode`
  - `districtName`
  - `detailAddress`
  - `scopeSummary`
  - `plannedStartAt`
  - `plannedEndAt`
  - `scheduleDetail`
  - `buildingTypeRemark`
  - `description`
  - 正式附件列表
- 轻标签继续只允许从这些字段派生，不新增显式 `tags` carrier。

### 3.3 `GET /server/projects/{projectId}` detail read 边界

- 后续 detail 响应只允许承接：
  - `projectId`
  - `projectNo`
  - `title`
  - `buildingType`
  - `buildingTypeRemark`
  - `budgetAmount`
  - `areaSqm`
  - `provinceCode`
  - `provinceName`
  - `cityCode`
  - `cityName`
  - `districtCode`
  - `districtName`
  - `detailAddress`
  - `scopeSummary`
  - `plannedStartAt`
  - `plannedEndAt`
  - `scheduleDetail`
  - `state`
  - `summary`
  - `description`
- 后续 detail 实现必须保持：
  - 同名同义回读
  - `buildingTypeRemark` 只作说明补充
  - `detailAddress` 只作自由文本补充
- 后续 detail 实现不得带入：
  - 正式附件列表
  - 奖励金额
  - 单位平方面积金额
  - 任何 second detail-only truth family

### 3.4 Backend 明确禁止

- Backend 不得借本轮改动：
  - `project/create`
  - `project/workbench`
  - 搜索 index
  - 地域分类 projection
  - 地图 / 经纬度
  - forum / 消息 / Profile / 企业库 / 订单 / 合同 / 履约 / 验收 / 评分 / 争议
- Backend 不得新增：
  - projection table
  - materialized view
  - tag persistence
  - attachment list carrier
  - migration 文件

## 4. BFF Implementation Freeze

### 4.1 BFF 允许职责

- 后续 BFF 实现只允许完成以下职责：
  - `GET /api/app/project/list` 承接 `ProjectShowcaseListItemReadModel`
  - `GET /api/app/project/detail` 承接 shared showcase detail `ProjectReadModel`
  - 继续只承担：
    - auth envelope
    - controlled failure normalization
    - shaping

### 4.2 `GET /api/app/project/list` 边界

- BFF list shaping 只允许回传：
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
- BFF 不得新增：
  - 显式 `tags` 数组
  - richer business truth
  - list-only attachment hints

### 4.3 `GET /api/app/project/detail` 边界

- BFF detail shaping 只允许回传 shared showcase detail `ProjectReadModel`：
  - `projectId`
  - `projectNo`
  - `title`
  - `buildingType`
  - `buildingTypeRemark`
  - `budgetAmount`
  - `areaSqm`
  - `provinceCode`
  - `provinceName`
  - `cityCode`
  - `cityName`
  - `districtCode`
  - `districtName`
  - `detailAddress`
  - `scopeSummary`
  - `plannedStartAt`
  - `plannedEndAt`
  - `scheduleDetail`
  - `state`
  - `summary`
  - `description`
- BFF 不得新增：
  - 正式附件列表
  - 奖励金额
  - 单位平方面积金额
  - 改义后的共享字段

### 4.4 BFF 明确禁止

- BFF 不得为 showcase list/detail 新增本地真相。
- BFF 不得：
  - synthesize richer business truth
  - 自建分类真相
  - 自建标签真相
  - 扩到 `project/workbench`
  - 扩到搜索 index 或地域分类 projection
  - 扩到其他板块

## 5. Allowed Change Surface

- 后续 Backend 实现阶段允许改动面冻结为：
  - `apps/server/src/modules/project/project.presenter.ts`
  - `apps/server/src/modules/project/project-query.service.ts`
  - `apps/server/src/modules/project/project.controller.ts`
  - 若编译必需，允许 very small mechanical touch：
    - `apps/server/src/modules/project/project.module.ts`
    - `apps/server/src/modules/project/entities/project.entity.ts`
- 后续 BFF 实现阶段允许改动面冻结为：
  - `apps/bff/src/routes/project/project.service.ts`
  - `apps/bff/src/routes/project/project.controller.ts`
  - `apps/bff/src/routes/project/app-project.controller.ts`
  - 若编译必需，允许 very small mechanical touch：
    - `apps/bff/src/routes/project/project.module.ts`

## 6. Forbidden Change Surface

- 后续实现阶段明确不应触碰：
  - `apps/mobile/**`
  - `apps/admin/**`
  - `docs/**`
  - `apps/server/src/core/migrations/**`
  - `apps/server/src/modules/upload/**`
  - forum 相关实现
  - `project/create`
  - `project/workbench`
  - 搜索 index
  - 地域分类 projection
  - 地图 / 经纬度
  - 其他板块任何实现

## 7. Formal Attachment List Follow-up

- 正式附件列表继续不进入本轮实现。
- 当前必须继续独立立项为：
  - `project showcase detail attachment read truth`
  - 后续再进入对应 contract / persistence freeze
- 当前不得：
  - 把附件列表混进 shared showcase detail `ProjectReadModel`
  - 把附件类型标签混进当前 list/detail read implementation

## 8. Stage Conclusion

- 当前结论：
  - `Go` for entering the `showcase alignment frontend consumption freeze` stage
  - `No-Go` for直接进入 backend / BFF / Flutter 实现
- 本冻结单的真实含义是：
  - showcase list/detail 的 backend-BFF 实现边界已正式冻结
  - 允许改动面与禁止改动面已写死
  - 正式附件列表仍必须独立立项

## 9. 修订记录

- `v1.0` `2026-04-04`
  - 首版冻结 `project showcase publish alignment` backend-BFF implementation 边界。
  - 正式限定 showcase list/detail 只围绕两类 read model 施工。
  - 正式限定轻标签继续只作派生、不进 shared carrier。
  - 正式重申正式附件列表必须独立立项。
