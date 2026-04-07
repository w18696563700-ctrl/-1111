---
owner: Codex 总控
status: frozen
purpose: Formally freeze the contract boundary for the owner-aware project detail surface mainline, confirming that the stage reuses the existing detail path family and only adds a minimum owner-aware carrier on the shared ProjectReadModel without widening into owner-only endpoints or action matrices.
layer: L0 SSOT
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/owner_aware_project_detail_surface_truth_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/server/src/modules/project/project.controller.ts
  - apps/server/src/modules/project/project.presenter.ts
  - apps/bff/src/routes/project/app-project.controller.ts
  - apps/bff/src/routes/project/project.service.ts
freeze_date_local: 2026-04-04
---

# owner-aware project detail surface contract 冻结单

## 1. Scope

- 本冻结单只覆盖 `owner-aware project detail surface contract freeze`。
- 本冻结单只裁定：
  - 现有项目详情 read contract 如何显式承接 owner-aware truth
  - owner / non-owner surface 分流所需的最小 carrier
  - `继续竞标 -> 管理当前` 在 detail contract 层的最小支撑边界
- 本冻结单不进入：
  - persistence freeze
  - backend / BFF / Flutter 实现
- 本冻结单继续排除：
  - 项目工作台入口迁移
  - `我的项目` 下架箱实现
  - 删除 / 撤回发布 / 下架 / 关闭项目的最终实现
  - 推广商业闭环直接实现
  - 正式附件列表
  - richer 私域状态真相
  - `奖励金额`
  - `单位平方面积金额`
  - 搜索
  - 地域分类页面
  - 地图 / 经纬度
  - forum / 消息
  - 订单平台化后台
  - 合同后台
  - 履约治理后台
  - 其他无关板块

## 2. Contract Freeze Conclusion

- 本轮 contract freeze 的正式结论是：
  - `现有 path family 保持不变 + 共享 detail schema 最小增量`
- 当前正式不新增：
  - owner 专属 detail path
  - manage path
  - action path
  - 动作矩阵 schema
- 当前正式只新增一个最小 owner-aware carrier：
  - `viewerProjectRelation`

## 3. path family 结论

- 当前继续使用现有：
  - `GET /server/projects/{projectId}`
  - `GET /api/app/project/detail`
- 当前正式禁止：
  - 新增 `/project/manage`
  - 新增 `/project/actions`
  - 新增 owner-detail 专属 endpoint
- 当前正式写死：
  - owner surface 与 non-owner surface 共享同一条 detail path family

## 4. owner-aware carrier contract 结论

- detail read 面必须新增一个最小 owner-aware carrier。
- 当前正式冻结该 carrier 为：
  - `viewerProjectRelation`
- 当前正式冻结允许值为：
  - `owner`
  - `non_owner`
- 当前正式不采用：
  - raw `creator_user_id`
  - raw `organization_id`
  直接暴露给 Flutter
- 当前正式禁止：
  - 用前端自行比对 raw ids 推 owner-aware
  - 在 app-facing contract 暴露多余内部身份字段

## 5. owner / non-owner 分流在 contract 层的承接方式

- 当前只需要在现有 `ProjectReadModel` 上新增：
  - `viewerProjectRelation`
- 当前不需要：
  - 第二套 detail schema
  - 第二套 owner-only detail read model
- 当前正式允许：
  - 公域信息区字段继续复用现有 detail 字段
  - Flutter 仅依据 `viewerProjectRelation` 在 CTA / 管理入口层分流
- 当前正式禁止：
  - 把 owner surface 膨胀成另一套私域详情 contract

## 6. CTA 分流 contract 边界

- 当前 contract 层只负责告诉 Flutter：
  - 当前 viewer 是 `owner` 还是 `non_owner`
- 当前 contract 层不直接返回：
  - `manageActions`
  - `actionMenuItems`
  - `canDelete`
  - `canPromote`
  - `canEdit`
  - `canArchive`
  - 其他完整动作矩阵
- 当前正式写死：
  - contract 只为 surface 分流提供最小 owner-aware carrier
  - 不提前冻结完整动作能力矩阵

## 7. 候选动作集合 contract 边界

- `推广此项目 / 编辑 / 下架 / 删除此项目` 当前都不进入 contract。
- 当前正式禁止为了这些候选动作先加：
  - action schema
  - action endpoint
  - action availability field
- 当前正式写死：
  - 这些动作后续若要推进，必须单独进入 action boundary freeze

## 8. Server / BFF contract 责任边界

- owner-aware truth 由 Server 判断。
- BFF 只做透传 / trimming。
- 当前正式写死：
  - Server 持有 owner-aware 判断真义
  - BFF 不自己拼第二套 owner 判定逻辑

## 9. `openapi.yaml` 更新结论

### 9.1 需要更新的 path

- `GET /server/projects/{projectId}`
- `GET /api/app/project/detail`

### 9.2 需要更新的 schema

- `ProjectReadModel`
  - 新增 `viewerProjectRelation`
- `ProjectViewerRelation`
  - 新增 enum schema：
    - `owner`
    - `non_owner`

### 9.3 保持 no-op 的 path / schema

- `POST /api/app/project/create`
- `GET /api/app/project/list`
- `GET /api/app/my/projects`
- `GET /api/app/exhibition/workbench`
- `POST /server/projects`
- `GET /server/projects`
- `GET /server/my/projects`
- `GET /server/my/projects/{projectId}`
- 所有 action endpoint
- 所有 action schema
- 所有 list / workbench / create-success schema

## 10. Explicit Contract Guardrails

- 当前正式写死：
  - 不新增 detail path family
  - 不重造第二套 detail schema
  - 不暴露多余内部 id 供 Flutter 自行拼 owner 判定
  - 不提前冻结动作矩阵
  - 不把 owner surface 膨胀成私域后台
  - 不扩到任何无关主线

## 11. Stage Conclusion

- 当前结论：
  - `Go` for entering the `owner-aware project detail surface persistence freeze` stage
  - `No-Go` for直接进入实现
- 原因已正式写死为：
  - owner-aware carrier 如何进入 detail contract 已正式冻结
  - path family 与 schema 变化面已写清
  - 候选动作集合继续被排除在 contract 实现面外
  - 下一步必须继续确认该最小 carrier 是否完全保持 persistence no-op

## 12. 修订记录

- `v1.0` `2026-04-04`
  - 首版冻结 `owner-aware project detail surface` contract 边界。
  - 正式确认 path family 保持不变。
  - 正式确认在 `ProjectReadModel` 上新增最小 carrier：`viewerProjectRelation`。
