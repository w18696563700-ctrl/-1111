---
owner: Codex 总控
status: frozen
purpose: Freeze the Round B backend and BFF implementation boundary for project publish only, limited to the three admitted richer fields and without widening any other board, path family, or implementation scope.
layer: L0 SSOT
gate_basis:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/project_publish_round_b_truth_freeze_addendum.md
  - docs/00_ssot/project_publish_round_b_contract_freeze_addendum.md
  - docs/02_backend/project_publish_round_b_persistence_truth_addendum.md
  - docs/00_ssot/project_publish_round_b_persistence_migration_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/server/src/modules/project/entities/project.entity.ts
  - apps/server/src/modules/project/project.controller.ts
  - apps/server/src/modules/project/project-query.service.ts
  - apps/server/src/modules/project/project-write.service.ts
  - apps/server/src/modules/project/project.presenter.ts
  - apps/server/src/core/migrations/migrations.ts
  - apps/bff/src/routes/project/app-project.controller.ts
  - apps/bff/src/routes/project/project.service.ts
freeze_date_local: 2026-04-04
---

# 项目发布 Round B backend-BFF 实现边界冻结单

## 1. Scope

- 本冻结单只覆盖 `项目发布 Round B backend-BFF implementation freeze`。
- 本冻结单只允许围绕以下 3 个字段冻结实现边界：
  - `areaSqm`
  - `buildingTypeRemark`
  - `scheduleDetail`
- 本冻结单只服务于：
  - `POST /server/projects`
  - `GET /server/projects/{projectId}`
  - `POST /api/app/project/create`
  - `GET /api/app/project/detail`
- 本冻结单不冻结：
  - 业务代码本体
  - forum
  - 消息
  - Profile
  - 企业库
  - 订单 / 合同 / 履约 / 验收 / 评分 / 争议
  - `project/list`
  - workbench
  - upload binding truth 变更
  - Flutter / Admin

## 2. Upstream Freeze Intake

- 当前唯一准入的 Round B richer fields 只有：
  - `areaSqm`
  - `buildingTypeRemark`
  - `scheduleDetail`
- 当前上游已经冻结完成：
  - truth 边界
  - app-facing / server-facing contract
  - persistence truth
  - additive migration 合法边界
- 因此本轮 implementation freeze 的真实含义是：
  - 只给后续 Backend / BFF 实现提供最小施工边界
  - 不重新裁定 truth
  - 不重新裁定 contract
  - 不 author migration file

## 3. Explicitly Blocked Items

- 以下内容继续被明确挡在本轮之外：
  - `预算区间`
  - `奖励金额`
  - `创建前附件主表单化`
- 不得以任何形式把它们带入：
  - `Server create/detail`
  - `BFF create/detail`
  - `entity / mapper / presenter`
  - upload binding flow
  - `project/list`
  - workbench

## 4. Backend Implementation Freeze

### 4.1 Backend 允许职责

- 后续 Backend 实现只允许完成以下职责：
  - 在 `public.project` 执行一轮已冻结范围内的 additive migration，增加：
    - `area_sqm`
    - `building_type_remark`
    - `schedule_detail`
  - 在 `ProjectEntity` 承接这 3 个字段
  - 在 `POST /server/projects` 的 create 写入链路承接这 3 个字段
  - 在 `GET /server/projects/{projectId}` 的 detail read 链路回读这 3 个字段

### 4.2 Backend create 写入规则

- `areaSqm`
  - 只允许按 canonical `sqm` 数值写入
  - 必须为正数
  - 最多两位小数
  - omitted / `null` 时写 `NULL`
- `buildingTypeRemark`
  - omitted / `null` 时写 `NULL`
  - 空字符串必须归一为 `NULL`
  - 最大长度与 contract / persistence freeze 一致
- `scheduleDetail`
  - omitted / `null` 时写 `NULL`
  - 空字符串必须归一为 `NULL`
  - 最大长度与 contract / persistence freeze 一致

### 4.3 Backend detail 回读规则

- `GET /server/projects/{projectId}` 只允许按同名同义回读：
  - `areaSqm`
  - `buildingTypeRemark`
  - `scheduleDetail`
- DB `NULL` 必须保持回读为 app-facing `null`。
- 不允许：
  - 改名输出
  - 衍生第二 detail-only richer model
  - 把 `scheduleDetail` 扩写为 schedule object

### 4.4 Backend 预期改动面

- 后续 Backend 实现预期允许触碰：
  - [migrations.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/core/migrations/migrations.ts) 对应的一轮 `public.project` additive migration authoring 入口
  - [project.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/project/entities/project.entity.ts)
  - [project-write.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/project/project-write.service.ts)
  - [project-query.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/project/project-query.service.ts)
  - [project.presenter.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/project/project.presenter.ts)
- 如仅为 compile-required mechanical touch，允许最小触碰：
  - [project.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/project/project.controller.ts)
  - [project.module.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/project/project.module.ts)

### 4.5 Backend 明确禁止

- 不得借本轮改动：
  - `project/list`
  - workbench projection
  - upload flow
  - forum / 消息 / Profile / 企业库 / 订单 / 合同 / 履约 / 验收 / 评分 / 争议
  - `project` 聚合全量 richer refactor
- 不得把被挡项塞入：
  - `ProjectEntity`
  - create command
  - presenter
  - read model

## 5. BFF Implementation Freeze

### 5.1 BFF 允许职责

- 后续 BFF 实现只允许完成以下职责：
  - 在 `POST /api/app/project/create` 透传并整形：
    - `areaSqm`
    - `buildingTypeRemark`
    - `scheduleDetail`
  - 在 `GET /api/app/project/detail` 整形并回读：
    - `areaSqm`
    - `buildingTypeRemark`
    - `scheduleDetail`
  - 继续只承担：
    - auth envelope
    - controlled failure normalization
    - shaping

### 5.2 BFF 明确禁止

- `BFF` 不得为这 3 个字段新增本地真相。
- `BFF` 不得：
  - 解释 richer business semantics
  - 新增本地状态机
  - 改写 upload binding truth
  - 扩到 `project/list`
  - 扩到 workbench

### 5.3 BFF 预期改动面

- 后续 BFF 实现预期允许触碰：
  - [app-project.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/project/app-project.controller.ts)
  - [project.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/project/project.service.ts)
- 如仅为 compile-required mechanical touch，允许最小触碰：
  - [project.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/project/project.controller.ts)
  - [project.module.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/project/project.module.ts)

## 6. Create / Detail Only Boundary

- 这 3 个字段当前只进入：
  - create
  - detail
- 当前明确不进入：
  - `project/list`
  - workbench
- 原因正式冻结为：
  - 上游 truth / contract / persistence freeze 只要求 create 真写与 detail 真读
  - 当前没有任何已冻结义务要求 list/workbench 承担 richer projection
  - 若把 richer fields 提前带入 list/workbench，会无端扩大 `BFF` 与 `Server` 的 projection 面

## 7. Upload Non-impact Boundary

- `areaSqm` 不影响 upload truth。
- `buildingTypeRemark` 不影响 upload truth。
- `scheduleDetail` 不影响 upload truth。
- 当前 upload canonical truth 继续保持：
  - `businessType=project`
  - `fileKind=evidence`
  - `businessId=projectId`
  - `init -> direct upload -> confirm`
- 因此后续 Backend / BFF 实现均不得：
  - 修改 upload binding flow
  - 引入 pre-create attachment binding
  - 借 Round B richer fields 扩写 upload family

## 8. Backend / BFF Responsibility Split

- `Server` 的职责边界：
  - 拥有这 3 个字段的唯一 business truth
  - 负责 persistence write / read
  - 负责空字符串归一与 `NULL` 语义
  - 负责 detail 回读同名同义
- `BFF` 的职责边界：
  - 只做 app-facing create/detail 的 request / response shaping
  - 只做受控错误归一
  - 只做 auth envelope 转发
  - 不拥有这 3 个字段的 business truth

## 9. Allowed Change Surface

- 后续实现阶段允许改动面正式冻结为：
  - `apps/server/src/core/migrations/**`
  - `apps/server/src/modules/project/entities/project.entity.ts`
  - `apps/server/src/modules/project/project-write.service.ts`
  - `apps/server/src/modules/project/project-query.service.ts`
  - `apps/server/src/modules/project/project.presenter.ts`
  - `apps/server/src/modules/project/project.controller.ts`
  - `apps/server/src/modules/project/project.module.ts`
  - `apps/bff/src/routes/project/app-project.controller.ts`
  - `apps/bff/src/routes/project/project.service.ts`
  - `apps/bff/src/routes/project/project.controller.ts`
  - `apps/bff/src/routes/project/project.module.ts`
- 上述允许面只服务于：
  - create/detail richer-field binding
  - additive migration wiring
  - compile-required mechanical touch

## 10. Forbidden Change Surface

- 后续实现阶段明确不应触碰：
  - `apps/mobile/**`
  - `apps/admin/**`
  - `docs/**`
  - `apps/server/src/modules/upload/**`
  - forum 相关实现
  - `project/list` 相关 projection 扩面
  - workbench 相关 projection 扩面
- 后续实现阶段明确不应带入：
  - `预算区间`
  - `奖励金额`
  - `创建前附件主表单化`

## 11. Stage Conclusion

- 当前结论：
  - `Go` for bounded Backend / BFF implementation for Round B project publish richer fields only
  - `No-Go` for any wider project aggregate refactor
  - `No-Go` for `project/list` / workbench richer projection expansion
  - `No-Go` for upload binding truth change
  - `No-Go` for blocked Round B items
- 本冻结单的真实含义是：
  - `areaSqm`、`buildingTypeRemark`、`scheduleDetail` 已具备进入 backend / BFF 实现阶段的边界条件
  - 但后续实现必须严格限于 create/detail richer-field 闭环
  - 其他板块与被挡项继续完全不得进入

## 12. 修订记录

- `v1.0` `2026-04-04`
  - 首版冻结 `项目发布 Round B backend-BFF implementation` 边界。
  - 只放行 `areaSqm`、`buildingTypeRemark`、`scheduleDetail` 的 Backend / BFF create-detail 实现面。
  - 明确 `project/list` / workbench / upload binding 不在本轮。
