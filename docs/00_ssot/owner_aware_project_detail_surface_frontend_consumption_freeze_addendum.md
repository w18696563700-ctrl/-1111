---
owner: Codex 总控
status: frozen
purpose: Formally freeze the Flutter consumption boundary for the owner-aware project detail surface mainline, confirming that Flutter only consumes viewerProjectRelation for owner/non-owner surface branching and only admits a local manage-current sheet shell without widening into action execution or unrelated boards.
layer: L0 SSOT
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/owner_aware_project_detail_surface_pre_freeze_addendum.md
  - docs/00_ssot/owner_aware_project_detail_surface_truth_freeze_addendum.md
  - docs/00_ssot/owner_aware_project_detail_surface_contract_freeze_addendum.md
  - docs/00_ssot/owner_aware_project_detail_surface_persistence_freeze_addendum.md
  - docs/00_ssot/owner_aware_project_detail_surface_backend_bff_implementation_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_contract_mapper.dart
freeze_date_local: 2026-04-04
---

# owner-aware project detail surface frontend consumption 冻结单

## 1. Scope

- 本冻结单只覆盖 `owner-aware project detail surface frontend consumption freeze`。
- 本冻结单只冻结：
  - `ProjectReadModel.viewerProjectRelation` 的 Flutter 消费方式
  - owner surface 与 non-owner surface 的同页分流
  - `继续竞标 -> 管理当前` 的 CTA 分流
  - `管理当前` 的就地弹层 / action sheet / bottom sheet 壳层承接
  - 点击弹层外区域自动消失
- 本冻结单不进入：
  - Flutter 代码实现
  - 动作执行真义冻结
  - backend / BFF / persistence 变更
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

## 2. Flutter Consumption Freeze Conclusion

- Flutter 当前只消费：
  - `ProjectReadModel.viewerProjectRelation`
- 当前正式写死：
  - `owner` => owner surface
  - `non_owner` => non-owner surface
- 当前正式禁止：
  - Flutter 自己比对 raw id 推 owner 关系
  - Flutter 补算第二套 owner 判定逻辑

## 3. owner / non-owner 页面分流边界

- 同一条项目详情页正式只做：
  - 同页分流
- 当前正式不做：
  - 两条完全不同页面
  - owner-only 私域后台页
- 当前正式允许：
  - 公域信息区继续复用当前详情内容
  - 只在 CTA / 管理入口层分流
- 当前正式禁止：
  - 把 owner surface 膨胀成私域后台页面

## 4. CTA 分流边界

- owner surface 主 CTA 正式显示：
  - `管理当前`
- non-owner surface 继续显示：
  - 现有 state-based 公域 CTA
- 当前正式写死：
  - owner 不再显示 `继续竞标`
  - non-owner 不受本轮 owner 管理入口影响

## 5. `管理当前` 弹层壳层边界

- `管理当前` 正式以就地壳层承接：
  - 弹层
  - action sheet
  - bottom sheet
- 当前正式写死：
  - 点击外部自动消失
- 当前正式禁止：
  - 先跳独立管理页
  - 先把详情页改造成后台页

## 6. 候选动作集合的 Flutter 边界

- 以下动作当前只允许作为弹层中的候选动作文案壳：
  - `推广此项目`
  - `编辑`
  - `下架`
  - `删除此项目`
- 当前正式写死：
  - 这些动作当前不是已冻结业务执行真义
  - 当前不能把它们接成真实 action flow
- 本轮只冻结：
  - action sheet 中可显示这些项
  - 不冻结其后续跳转 / 执行 / 后端交互

## 7. 允许改动的 Flutter 文件范围

- `apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart`
- `apps/mobile/lib/features/exhibition/data/services/exhibition_contract_mapper.dart`
- 如 mapper / read model 适配必需，允许 very small touch：
  - `apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart`
  - `apps/mobile/lib/features/exhibition/presentation/widgets/**` 中与 detail CTA / sheet 直接相关的最小文件
- 对应最小测试文件
- 除上述范围外，不预授权其他生产代码文件

## 8. 禁止改动的范围

- 不改 path family
- 不改 create
- 不改 workbench
- 不改 my-project
- 不改附件
- 不改删除 / 下架 / 推广 / 编辑动作实现
- 不改任何无关板块

## 9. Explicit Frontend Guardrails

- 当前正式写死：
  - Flutter 只消费 `viewerProjectRelation`
  - owner / non-owner 分流只发生在 detail surface CTA / 管理入口层
  - `管理当前` 当前只冻结弹层壳，不冻结动作执行链
  - 候选动作集合当前只允许作为 UI 候选项，不等同于已实现能力
  - 不得扩到任何无关主线

## 10. Stage Conclusion

- 当前结论：
  - `Go` for entering the `owner-aware project detail surface Flutter implementation` stage
  - `No-Go` for直接进入动作实现
- 原因已正式写死为：
  - `viewerProjectRelation` 的 Flutter 消费边界已冻结
  - owner / non-owner 分流与 CTA 分流边界已冻结
  - `管理当前` 弹层壳与候选动作集合边界已写清
  - 下一步只允许在极窄 Flutter 范围内实现 owner-aware 分流与弹层壳

## 11. 修订记录

- `v1.0` `2026-04-04`
  - 首版冻结 `owner-aware project detail surface` frontend consumption 边界。
  - 正式确认 Flutter 只消费 `viewerProjectRelation` 并据此完成 owner / non-owner surface 分流。
  - 正式确认 `管理当前` 只冻结为就地弹层壳，候选动作集合不等同于已实现业务动作。
