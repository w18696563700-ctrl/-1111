---
owner: Codex 总控
status: frozen
purpose: Formally freeze the truth boundary for the owner-aware project detail surface mainline, including owner-aware meaning, owner/non-owner surface split, CTA split, local manage-entry carry, and candidate-action boundaries without widening into workbench migration or action implementation.
layer: L0 SSOT
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/owner_aware_project_detail_surface_pre_freeze_addendum.md
  - 用户真人反馈：自己点击自己发布的项目，不应继续竞标，而应进入管理当前
  - apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart
  - apps/server/src/modules/project/entities/project.entity.ts
  - apps/server/src/modules/project/project-write.service.ts
freeze_date_local: 2026-04-04
---

# owner-aware project detail surface 真源冻结单

## 1. Scope

- 本冻结单只覆盖 `owner-aware project detail surface truth freeze`。
- 本冻结单只冻结：
  - “自己”的判断真义
  - owner surface 与 non-owner surface 的页面分流真义
  - owner 主 CTA 从 `继续竞标` 切换为 `管理当前`
  - `管理当前` 的就地弹层承接真义
  - 候选动作集合边界真义
- 本冻结单不进入：
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

## 2. Truth Freeze Conclusion

- 当前唯一主线正式冻结为：
  - 同一项目详情按 `viewer ownership` 分成 `owner surface` 与 `non-owner surface`
- 当前正式写死：
  - 这是 owner-aware 详情分流主线
  - 不是简单改按钮文案
- 当前正式允许：
  - owner 与 non-owner 看到不同 CTA 与管理入口
- 当前正式禁止：
  - 继续把 owner 压在现有 `继续竞标` 语义里

## 3. owner-aware 真义

- owner-aware 真义正式冻结为：
  - `creator_user_id + 当前 organization 与 project.organization_id` 的复合 owner-aware carrier
- 当前正式不采用：
  - 只按 `creator_user_id`
  - 只按当前 organization 与 `project.organization_id`
- 原因写死为：
  - 只看 creator 会脱离当前组织上下文
  - 只看 organization 会错误放大为同组织任意成员都等于 owner
- 因此后续 truth 正式以：
  - 发布者本人
  - 且当前组织上下文仍属于该项目组织
  作为 owner surface 成立条件

## 4. owner / non-owner 页面分流 truth

- 同一条项目详情正式存在：
  - `owner surface`
  - `non-owner surface`
- 两者允许共用大部分公域信息区。
- 分流重点正式只发生在：
  - CTA
  - 管理入口
- 当前正式禁止：
  - 把 owner surface 做成另一套私域后台详情
  - 把 non-owner 误导成 owner 管理视角

## 5. CTA truth

- owner surface 主 CTA 正式冻结为：
  - `管理当前`
- non-owner surface 继续沿用：
  - 现有 state-based 公域 CTA 逻辑
- 因此当前正式写死：
  - owner-aware 分流优先级高于当前单纯 `state == published` 的 CTA 逻辑
- 当前正式结论：
  - owner 不再显示 `继续竞标`
  - non-owner 对 `published` 项目仍可保留 `继续竞标`

## 6. `管理当前` 承接 truth

- `管理当前` 正式以以下就地承接形态为主：
  - 弹层
  - action sheet
  - bottom sheet
- 当前正式写死：
  - 点击弹层外区域自动消失
- 当前正式禁止：
  - 先跳全新管理页
  - 在未单独立项前把 owner 入口升级成完整后台页

## 7. 候选动作集合 truth

- 以下动作正式冻结为当前主线内的候选动作集合：
  - `推广此项目`
  - `编辑`
  - `下架`
  - `删除此项目`
- 当前这四项都还不是已冻结实现真义。
- 当前正式写死：
  - `删除此项目` 不能直接等同于硬删除实现
  - `下架` 不能直接等同于已有完整下架箱能力
  - `推广此项目` 不能直接等同于商业闭环已定义完成

## 8. 公域与私域边界 truth

- owner surface 仍然是：
  - 公域项目详情的 owner-aware 分流
- owner surface 不是：
  - 项目工作台
  - 我的项目后台
  - 私域管理后台
- 当前正式允许：
  - owner surface 保留公域信息区
  - 仅在动作区切换到 owner-aware 管理模式

## 9. Explicit Non-goals

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

## 10. Stage Conclusion

- 当前结论：
  - `Go` for entering the `owner-aware project detail surface contract freeze` stage
  - `No-Go` for直接进入 persistence freeze
  - `No-Go` for直接进入实现
- 原因已正式写死为：
  - owner-aware 真义已经冻结
  - 页面分流与 CTA 分流边界已经冻结
  - 候选动作集合与公私域边界已经冻结
  - 下一步必须先把最小 owner-aware carrier 如何进入 detail contract 写清

## 11. 修订记录

- `v1.0` `2026-04-04`
  - 首版冻结 `owner-aware project detail surface` truth 边界。
  - 正式确认 owner-aware 真义为 `creator_user_id + organization_id` 复合关系。
  - 正式确认 owner / non-owner 页面分流、CTA 分流与 `管理当前` 的就地承接形态。
