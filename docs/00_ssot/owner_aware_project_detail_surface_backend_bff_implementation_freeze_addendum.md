---
owner: Codex 总控
status: frozen
purpose: Formally freeze the Server and BFF implementation boundary for the owner-aware project detail surface mainline, confirming that the stage only adds viewerProjectRelation on the existing detail read chain and does not widen into new paths, action implementations, or unrelated boards.
layer: L0 SSOT
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/owner_aware_project_detail_surface_pre_freeze_addendum.md
  - docs/00_ssot/owner_aware_project_detail_surface_truth_freeze_addendum.md
  - docs/00_ssot/owner_aware_project_detail_surface_contract_freeze_addendum.md
  - docs/00_ssot/owner_aware_project_detail_surface_persistence_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/server/src/modules/project/project.controller.ts
  - apps/server/src/modules/project/project.presenter.ts
  - apps/server/src/modules/project/project-query.service.ts
  - apps/server/src/modules/project/project.module.ts
  - apps/bff/src/routes/project/app-project.controller.ts
  - apps/bff/src/routes/project/project.service.ts
  - apps/bff/src/routes/project/project.module.ts
freeze_date_local: 2026-04-04
---

# owner-aware project detail surface backend-BFF implementation 冻结单

## 1. Scope

- 本冻结单只覆盖 `owner-aware project detail surface backend-BFF implementation freeze`。
- 本冻结单只允许冻结以下实现议题：
  - Server 如何在现有 `GET /server/projects/{projectId}` 读链上派生 `viewerProjectRelation`
  - BFF 如何在现有 `GET /api/app/project/detail` 上透传该最小 carrier
- 本冻结单不进入：
  - Flutter 实现
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

## 2. Backend / BFF Implementation Freeze Conclusion

- 本轮 backend / BFF implementation freeze 的正式结论是：
  - `现有 detail read 链最小增量`
- 当前正式允许的 Server / BFF 实现变化只有：
  - 在现有 detail read 链上补出 `viewerProjectRelation`
- 当前正式不允许：
  - 新增 endpoint
  - 新增动作能力 carrier
  - 新增第二套 owner 判定逻辑
  - 新增动作矩阵

## 3. Server implementation 边界

- `viewerProjectRelation` 只允许在现有：
  - `GET /server/projects/{projectId}`
  读链中派生。
- 当前正式写死：
  - 只依赖现有 `creator_user_id`
  - 只依赖现有 `organization_id`
  - 只依赖当前 viewer + 当前 organization scope
- 当前正式不新增：
  - 新 controller path
  - 新 query path
  - 新 action endpoint
  - 新动作矩阵
- 当前正式返回：
  - `owner`
  - `non_owner`
- 当前正式不返回：
  - raw `creator_user_id`
  - raw `organization_id`

## 4. BFF implementation 边界

- BFF 只在现有：
  - `GET /api/app/project/detail`
  上透传 / trimming `viewerProjectRelation`。
- 当前正式写死：
  - BFF 不自己重算 owner 关系
  - BFF 不新增二次 owner 判定逻辑
- 当前正式不新增：
  - owner-detail 专属 app 路由
  - action menu schema
  - `manageActions`
  - `canDelete`
  - `canPromote`
  - `canEdit`
  - `canArchive`

## 5. 允许改动的文件范围

### 5.1 Server

- `apps/server/src/modules/project/project.controller.ts`
- `apps/server/src/modules/project/project.presenter.ts`
- `apps/server/src/modules/project/project-query.service.ts`

### 5.2 Server very small touch

- `apps/server/src/modules/project/project.module.ts`
  - 仅当 wiring 必需时允许 very small touch

### 5.3 BFF

- `apps/bff/src/routes/project/app-project.controller.ts`
- `apps/bff/src/routes/project/project.service.ts`

### 5.4 BFF very small touch

- `apps/bff/src/routes/project/**`
  - 仅限与 detail shaping 直接相关的最小文件
  - 不授权扩到 create / list / action / 其他 route family

## 6. 禁止改动的范围

- 不改 path family
- 不改 list/read 之外的 action 链
- 不改 `my-project` 主线 contract
- 不改工作台
- 不改 create
- 不改附件
- 不改删除 / 下架 / 推广 / 编辑动作实现
- 不改任何无关板块

## 7. 后续实现必须满足的验证要求

- non-owner 请求项目详情时，`viewerProjectRelation = non_owner`
- owner 请求自己项目详情时，`viewerProjectRelation = owner`
- `GET /api/app/project/detail` 与 `GET /server/projects/{projectId}` 都能稳定返回该 carrier
- 不影响现有 detail 字段
- 不引入动作矩阵字段
- 不影响：
  - `project/list`
  - `project/create`
  - `workbench`
  - `my-project`

## 8. Explicit Guardrails

- 当前正式写死：
  - 这是对现有 detail read 链的最小增量
  - 不新增 endpoint
  - 不新增动作能力 carrier
  - 不新增第二套 owner 判定逻辑
  - 不扩到 Flutter action sheet 实现
  - 不扩到任何无关主线

## 9. Stage Conclusion

- 当前结论：
  - `Go` for entering the `owner-aware project detail surface frontend consumption freeze` stage
  - `No-Go` for直接进入 Flutter 实现
- 原因已正式写死为：
  - Server / BFF 的最小实现边界已正式冻结
  - 允许改动面与禁止改动面已写清
  - 未扩大到动作实现或无关板块
  - 下一步必须先冻结 Flutter 如何消费 `viewerProjectRelation` 并完成 owner / non-owner CTA 分流

## 10. 修订记录

- `v1.0` `2026-04-04`
  - 首版冻结 `owner-aware project detail surface` backend-BFF implementation 边界。
  - 正式确认只在现有 detail read 链上补出 `viewerProjectRelation`。
  - 正式确认不新增 endpoint、不新增动作矩阵、不新增第二套 owner 判定逻辑。
