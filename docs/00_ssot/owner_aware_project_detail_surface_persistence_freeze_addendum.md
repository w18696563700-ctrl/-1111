---
owner: Codex 总控
status: frozen
purpose: Formally freeze the persistence boundary for the owner-aware project detail surface mainline, confirming that viewerProjectRelation is derived at read time from existing creator_user_id and organization_id truth and that the stage remains persistence-level no-op.
layer: L0 SSOT
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/owner_aware_project_detail_surface_truth_freeze_addendum.md
  - docs/00_ssot/owner_aware_project_detail_surface_contract_freeze_addendum.md
  - apps/server/src/modules/project/entities/project.entity.ts
  - apps/server/src/modules/project/project-write.service.ts
  - apps/server/src/modules/project/project-query.service.ts
freeze_date_local: 2026-04-04
---

# owner-aware project detail surface persistence 冻结单

## 1. Scope

- 本冻结单只覆盖 `owner-aware project detail surface persistence freeze`。
- 本冻结单只裁定：
  - `viewerProjectRelation` 的持久化真源
  - owner-aware 判断是否只复用现有项目真相
  - 是否需要新增列 / 表 / snapshot / materialized view
- 本冻结单不进入：
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

## 2. Persistence Freeze Conclusion

- 本轮 persistence freeze 的正式结论是：
  - `整体 no-op`
- `viewerProjectRelation` 不形成新的持久化真相载体。
- 当前正式写死：
  - 只复用现有项目真相
  - 不新增 owner-aware 专用 persistence carrier

## 3. `viewerProjectRelation` 的 persistence 真源

- `viewerProjectRelation` 当前正式只依赖现有：
  - `public.project.creator_user_id`
  - `public.project.organization_id`
  - 当前会话 organization scope
- 当前正式不需要新增：
  - owner-aware 专用列
  - owner-aware 关系表
  - owner snapshot

## 4. owner-aware 判断的持久化边界

- `viewerProjectRelation` 正式冻结为：
  - 读时派生
- 当前正式由 Server 基于：
  - 当前 viewer
  - 当前 organization scope
  - 项目现有字段
  直接派生出：
  - `owner`
  - `non_owner`
- 当前正式禁止：
  - 把该关系持久化成独立业务真相载体

## 5. migration 边界结论

- 本轮不需要任何 additive migration。
- 当前正式写死：
  - `0` 条 migration
  - `0` 条新增列
  - `0` 张新增表
  - `0` 个 snapshot
  - `0` 个 materialized view

## 6. 与现有真相的边界

- 当前 persistence 只复用项目已有真相。
- 当前明确不引入：
  - `manageActions` persistence
  - `action availability` persistence
  - `owner menu` persistence
- 当前正式写死：
  - `viewerProjectRelation` 只服务 surface 分流
  - 不服务动作矩阵固化

## 7. Explicit Persistence Guardrails

- 当前正式写死：
  - 不新增 owner-aware 专用列
  - 不新增 owner-aware 专用表
  - 不新增 snapshot / materialized view
  - 不把候选动作集合偷带入 persistence
  - 不影响任何无关板块 persistence

## 8. 明确继续排除在本轮 Persistence 外的范围

- 工作台入口迁移
- `我的项目` 下架箱
- 删除 / 下架 / 推广 / 编辑 的最终动作真义
- 正式附件列表
- richer 私域状态真相
- `奖励金额`
- `单位平方面积金额`
- 搜索 / 地域分类页面 / 地图
- forum / 消息
- 订单平台化后台 / 合同后台 / 履约治理后台
- 其他无关板块

## 9. Stage Conclusion

- 当前结论：
  - `Go` for entering the `owner-aware project detail surface backend-BFF implementation freeze` stage
  - `No-Go` for直接进入实现
- 原因已正式写死为：
  - `viewerProjectRelation` 的 persistence 真源已正式冻结
  - persistence no-op / migration 边界已写清
  - 候选动作集合继续被排除在 persistence 外
  - 下一步可以只围绕现有 detail read 链路进入 backend-BFF implementation freeze

## 10. 修订记录

- `v1.0` `2026-04-04`
  - 首版冻结 `owner-aware project detail surface` persistence 边界。
  - 正式确认 `viewerProjectRelation` 只依赖现有 `creator_user_id + organization_id` 真相并按读时派生承接。
  - 正式确认 `0 migration / 0 新增列 / 0 新增表 / 0 snapshot / 0 materialized view`。
