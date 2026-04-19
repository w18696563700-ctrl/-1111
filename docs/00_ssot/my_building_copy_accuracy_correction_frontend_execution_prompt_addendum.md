---
owner: Codex 总控
status: frozen
purpose: Freeze the minimal frontend execution prompt for the two approved copy corrections in my_building: personal profile intro wording and my_forum public-author-home wording.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/my_building_caliber_revision_ruling_v1.md
  - docs/00_ssot/my_building_object_type_copy_accuracy_register_v1.md
  - apps/mobile/lib/features/profile/presentation/profile_feature_status_copy.dart
---

# 《my_building 文案准确性纠偏前端执行口令》

你现在是：

- my_building copy accuracy correction frontend owner

你的唯一目标是：

- 只修正“我的楼”已冻结的 2 处文案准确性问题
- 不改任何功能边界
- 不改任何页面结构
- 不改任何状态机

这一步只做：

- `个人资料` 功能状态卡中的简介表述修正
- `我的论坛` 功能状态卡中的公域作者主页表述修正

这一步不做：

- 不改 `apps/server/**`
- 不改 `apps/bff/**`
- 不改 `apps/admin/**`
- 不改首页入口摘要状态
- 不改页面信息架构
- 不改 submit/status
- 不改任何功能可用性判断

允许修改范围：

- `apps/mobile/lib/features/profile/presentation/profile_feature_status_copy.dart`
- 与这两处文案直接相关的最小测试文件

你必须完成：

1. `个人资料` 功能状态卡里的未完成描述，统一改为：
   - `简介入口当前未开放；实名身份与更大范围资料治理仍未开放。`
2. 不得继续写成：
   - `简介编辑未做`
   - `简介能力不存在`
   - `简介编辑仍未开放` 之外会让人误判为后端能力不存在的中文
3. `我的论坛` 功能状态卡里的未完成描述，统一改为：
   - `我的论坛页不承接公域作者主页，也不扩成第二论坛首页或额外状态机。`
4. 不得继续写成：
   - `作者主页未做`
   - `整个 app 没有作者主页`
5. 如存在相关测试快照或直接文案断言，补齐最小测试覆盖。

你必须遵守：

1. 不得顺手修改任何其他卡片文案。
2. 不得把本轮文案纠偏扩大为“我的楼全量重写”。
3. 不得因为文案修正而改动运行逻辑、接口调用或功能状态枚举。
4. 不得新增第二套口径。

完成标准：

- `个人资料` 与 `我的论坛` 两处文案完全对齐已冻结真源
- 其他对象文案保持不变
- 页面行为、接口行为、状态行为不发生变化

交付回执要求：

1. 修改文件清单
2. 两处文案修改前后对照
3. 新增或更新的测试结果
4. 仍未覆盖的非目标清单
