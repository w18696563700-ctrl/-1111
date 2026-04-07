---
owner: Codex 总控
status: frozen
purpose: Formally pre-freeze the owner-aware project detail surface mainline, confirming that the same project detail may split into owner and non-owner surfaces without widening into workbench migration, action implementation, or unrelated boards.
layer: L0 SSOT
inputs_canonical:
  - AGENTS.md
  - 用户真人反馈：自己点击自己发布的项目，不应继续竞标，而应进入管理当前
  - apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart
  - apps/server/src/modules/project/entities/project.entity.ts
  - apps/server/src/modules/project/project-write.service.ts
freeze_date_local: 2026-04-04
---

# owner-aware project detail surface 预冻结单

## 1. Scope

- 本冻结单只覆盖 `owner-aware project detail surface pre-freeze`。
- 本冻结单只定义一条主线：
  - 同一项目详情按 `viewer ownership` 分成 `owner surface` 与 `non-owner surface`
- 本冻结单允许讨论：
  - owner-aware 项目详情分流
  - `继续竞标 -> 管理当前`
  - `管理当前` 弹层 / action sheet / bottom sheet 承接
  - 点击窗口外区域自动消失
  - 管理动作入口边界
- 本冻结单不进入：
  - truth freeze
  - contract freeze
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

## 2. 为什么这条主线成立

- 当前公域项目详情页的主 CTA 主要按项目 `state` 决定。
- 当前 `published` 项目会继续显示：
  - `继续竞标`
- 当前 detail 消费层尚未显式承接：
  - 当前查看者是否为该项目 owner
- 因此“自己看自己的项目”和“别人看同一项目”当前被错误压成同一条详情链路。
- 这已经不是文案小修，而是一条新的：
  - owner-aware 详情分流与管理入口主线

## 3. 预冻结结论

- 当前唯一主线正式成立：
  - 同一项目详情按 `viewer ownership` 分成 `owner surface` 与 `non-owner surface`
- 当前正式允许：
  - owner 查看自己发布的项目时进入管理视角
  - non-owner 查看同一项目时继续保留当前公域查看 / 继续竞标视角
- 当前正式纳入主线：
  - `继续竞标 -> 管理当前`
  - `管理当前` 的就地弹层承接
  - `推广此项目 / 编辑 / 下架 / 删除此项目` 的候选动作集合

## 4. owner-aware 后续冻结方向

- 当前 owner-aware 判断后续只允许围绕以下候选继续冻结：
  - `creator_user_id`
  - 当前 organization 与 `project.organization_id`
  - 二者的复合 owner-aware carrier
- 当前正式不允许：
  - 先跳过 owner-aware 真义，直接做按钮替换实现
  - 先跳过 owner-aware 真义，直接做删除实现

## 5. 管理入口预冻结边界

- `管理当前` 后续优先以：
  - 弹层
  - action sheet
  - bottom sheet
  为主承接
- 点击窗口外区域自动消失，正式纳入主线
- 当前预冻结不支持：
  - 直接跳全新管理页
  - 直接把详情页膨胀成项目工作台或私域后台

## 6. 候选动作集合预冻结边界

- 以下仅作为候选动作集合纳入主线：
  - `推广此项目`
  - `编辑`
  - `下架`
  - `删除此项目`
- 当前正式不把这些候选动作等同为已冻结实现真义。
- 当前正式禁止：
  - 在 owner-aware truth 未冻结前，直接做“删除此项目”硬删除实现

## 7. Explicit Non-goals

- 不触碰项目工作台入口迁移
- 不触碰 `我的项目` 下架箱实现
- 不触碰删除 / 撤回发布 / 下架 / 关闭项目的最终实现
- 不触碰推广商业闭环直接实现
- 不触碰正式附件列表
- 不触碰 richer 私域状态真相
- 不触碰 `奖励金额`
- 不触碰 `单位平方面积金额`
- 不触碰搜索 / 地域分类页面 / 地图 / 经纬度
- 不触碰 forum / 消息
- 不触碰订单平台化后台 / 合同后台 / 履约治理后台
- 不触碰其他无关板块

## 8. Stage Conclusion

- 当前结论：
  - `Go` for entering the `owner-aware project detail surface truth freeze` stage
  - `No-Go` for直接进入 contract freeze
  - `No-Go` for直接进入实现
- 原因已正式写死为：
  - 当前唯一主线已经被收口
  - owner-aware 分流边界已被预冻结
  - 候选动作集合与排除范围已写清
  - 下一步必须先冻结 owner-aware 真义、页面分流与 CTA 分流真相

## 9. 修订记录

- `v1.0` `2026-04-04`
  - 首版冻结 `owner-aware project detail surface` 预冻结边界。
  - 正式确认同一项目详情允许按 owner / non-owner 分流。
  - 正式确认 `管理当前` 与候选动作集合进入主线，但尚未进入实现真义。
