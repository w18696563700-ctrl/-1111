---
owner: Codex 总控
status: frozen
purpose: Freeze the Flutter surface copy for public project list visibility and my-project stage grouping.
layer: L5 Frontend
decision_date_local: 2026-04-28
inputs_canonical:
  - docs/00_ssot/project_list_visibility_copy_clarity_ruling_addendum.md
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_truth_boundary_freeze_addendum.md
  - docs/00_ssot/my_project_four_stage_smooth_flow_rule_freeze_addendum.md
---

# 项目列表可见范围提示 frontend surface

## 1. 公开项目列表

- 筛选卡必须显示固定提示：
  - `公开项目只展示当前仍在有效期内的项目；已过期或已结束项目不会进入公开接单列表，与当前账号相关的项目请到“我的项目”查看。`
- 空态必须避免暗示故障：
  - 可以提示用户切换筛选条件。
  - 必须补充：项目也可能已经结束并退出公开展示。

## 2. 我的项目列表

- 阶段卡必须说明：
  - 当前页按阶段分栏。
  - 当前只显示所选阶段。
  - 用户可切换上方阶段标签查看其他项目。
- 当前不得：
  - 把 `我的项目` 说成公开项目池。
  - 把阶段筛选结果说成账号项目总数。
  - 暗示已结束公开项目一定会在当前账号下出现。

## 3. 不变项

- 不改 Flutter 路由。
- 不改 BFF / Server。
- 不改项目列表分页合同。
- 不新增 `includeExpired`、`expiredOnly` 或第二套可见性字段。
