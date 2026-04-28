---
owner: Codex 总控
status: frozen
purpose: Freeze the user-visible clarification for public project list visibility and my-project stage grouping.
layer: L0 SSOT
decision_date_local: 2026-04-28
based_on:
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_truth_boundary_freeze_addendum.md
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_contract_freeze_compatibility_ruling_addendum.md
  - docs/00_ssot/my_project_four_stage_smooth_flow_rule_freeze_addendum.md
  - apps/server/src/modules/project/project-query.service.ts
  - apps/mobile/lib/features/exhibition/presentation/pages/project_list_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_list_page.dart
---

# 项目列表可见范围提示规则冻结单

## 1. 当前最小闭环

- `公开项目列表` 只解释公域可发现范围：
  - 仅展示当前仍在有效期内、可进入公开查看或接单判断的项目。
  - 已过期或已结束项目退出公开列表，不代表项目不存在。
  - 与当前账号相关的项目，应回到 `我的项目` 查看。
- `我的项目` 只解释私域组织范围：
  - 当前不是全量平铺列表。
  - 页面按 `我的发布 / 我的竞标` 和阶段分组展示。
  - 当前阶段区只显示所选阶段，用户可切换阶段查看其他项目。

## 2. 需要保留但暂不开通

- 保留后续扩展：
  - `已结束公开项目` 独立历史查看入口。
  - `全部阶段` 汇总视图。
  - 列表分页加载更多。
- 本轮暂不开通：
  - 不新增 `includeExpired`。
  - 不新增 `expiredOnly`。
  - 不把过期项目重新放回公开项目池。
  - 不修改 BFF / Server 可见性规则。

## 3. 后续扩展位

- 若后续需要让接单方复盘已结束公开项目，应另开 `public project archive` 阶段。
- 若后续需要在 `我的项目` 首屏展示全部阶段，应另开 `my-project all-stage overview` 阶段。

## 4. 风险裁决

- 更稳：保留 Server 公域过期退出规则，只补 Flutter 用户可见提示。
- 更省成本：不改接口、不改状态机、不改数据库，只改文案和目标测试。
- 更适合当前阶段：用提示解释“不是故障”，避免用户误以为列表漏数据。
- 风险更大：把过期项目放回公开列表，或把 `公开项目`、`我的发布`、`我的竞标` 混成一个无边界大列表。
