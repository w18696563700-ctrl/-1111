---
owner: Codex 总控
status: frozen
purpose: >
  Record the Day7-Day8 frontend-only gate for the current create/prepublish
  convergence round, allowing only attachment entry and copy convergence around
  the prepublish-stage document corridor while preserving the existing
  FileAsset and project_attachments truth chain.
layer: L0 SSOT
freeze_date_local: 2026-04-26
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/project_create_prepublish_experience_day1_scope_freeze_addendum.md
  - docs/00_ssot/project_create_prepublish_and_factory_bid_day2_flow_brief_addendum.md
  - docs/00_ssot/project_prepublish_day4_confirmation_flow_brief_addendum.md
  - docs/00_ssot/project_create_prepublish_day5_day6_frontend_execution_receipt_addendum.md
  - docs/00_ssot/project_attachment_prepublish_and_bid_materials_truth_freeze_addendum.md
  - docs/01_contracts/project_attachment_prepublish_and_bid_materials_contract_freeze_addendum.md
  - docs/04_frontend/project_attachment_prepublish_and_bid_materials_frontend_surface_addendum.md
---

# 《Day7-Day8 附件体验前端阶段门禁核查表》

## 0. 总结论

Day7-Day8 允许进入 Flutter 前端文案与入口收敛，不授权 BFF / Server / contract / 状态机变更。

当前更稳的方案：

- 继续复用 `submitted-or-later owner continuation` 附件走廊，只把入口文案明确为预发布阶段可补 `效果图 / 施工图 / 其他资料`。

当前更省成本的方案：

- 不重开附件接口，不新增附件状态，不新增第二附件 carrier。

当前阶段最适合的方案：

- 让发布方在 `我的项目 -> 预发布列表 -> 单项目详情` 明确看到附件区已经开放，并在补资料后再确认发布。

风险更大的方案：

- 把附件真值改成本地 `objectKey`、在创建页直接上传正式附件、或新增 `prepublish` 状态来表达附件可写性。

## 1. Passed Gates

1. Day1-Day6 已冻结并完成前端闭环：创建页不再承接交易总控，预发布详情承担正式发布确认。
2. 附件前移正式真相已存在：owner 附件走廊从 `post-publish only` 调整为 `submitted-or-later`。
3. 附件真值链已冻结：`FileAsset` 是上传资产真值，`project_attachments` 是项目附件业务真值。
4. 当前本地只授权 Flutter：BFF / Server 运行在阿里云，不做本地假设和本地改动。

## 2. Allowed Frontend Changes

本阶段仅允许：

1. 收敛创建页和编辑页附件提示文案。
2. 收敛我的项目详情摘要卡中的附件入口文案。
3. 收敛预发布详情 `项目详情文书区` 的标题、摘要、空态文案。
4. 补充本地 widget tests，覆盖创建、跳转、草稿、预发布、附件入口。
5. 记录阶段执行回执。

## 3. Veto Gates

以下任一情况出现，本阶段立即 No-Go：

1. 修改 `apps/bff/**`、`apps/server/**`、contracts/OpenAPI。
2. 修改 upload `init -> direct upload -> confirm -> bind` 顺序。
3. 把 `objectKey` 当成附件业务真值。
4. 新增 `prepublish / prepublished` 状态或路径。
5. 让 `draft` 项目进入正式附件走廊。
6. 让工厂侧写入 owner 项目附件，或让 bid-side 读取 `other_material`。

## 4. Required Acceptance Evidence

Day8 本地验证必须覆盖：

1. 创建页提示：效果图、施工图、其他资料在进入预发布列表后开放。
2. 草稿编辑页：附件区未开放，提示保存到预发布列表后开放。
3. 预发布详情：显示项目详情文书区，包含 `效果图 / 施工图 / 其他资料` 入口。
4. 我的项目列表到预发布详情：入口文案为补资料后确认发布。
5. 附件真值链：测试仍走现有 attachment API mock，不新增 payload 字段或状态。

## 5. Stage Decision

```text
Go for Flutter-only attachment entry/copy convergence.
No-Go for BFF / Server / contract implementation.
No-Go for attachment truth-chain changes.
No-Go for Computer Use acceptance until local tests pass.
```
