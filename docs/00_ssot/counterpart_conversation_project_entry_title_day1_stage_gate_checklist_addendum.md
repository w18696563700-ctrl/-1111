---
owner: Codex 总控
status: frozen
purpose: >
  Submit Day-1 stage gate checklist for counterpart conversation project entry
  title correction.
layer: L0 SSOT
recorded_at_local: 2026-04-26
based_on:
  - docs/00_ssot/counterpart_conversation_project_entry_title_truth_freeze_addendum.md
  - docs/03_bff/counterpart_conversation_project_entry_title_bff_surface_addendum.md
  - docs/04_frontend/counterpart_conversation_project_entry_title_frontend_consumption_addendum.md
---

# 《消息楼项目入口标题 Day-1 阶段门禁核查表》

## 1. Passed Gates

- 已明确 `exhibitionName` 是展会名。
- 已明确 `project.title` 是具体项目名。
- 已冻结消息楼项目入口标题规则。
- 已冻结 BFF 只校验透传。
- 已冻结 Flutter 只消费 `projectDisplayTitle`。
- 已保留名称查看遮罩规则。

## 2. Failed Gates

- 云上真实双账号多项目 UAT 未执行。
- 云上发版未执行。

## 3. Veto Gates

- 不允许 Flutter 本地拼标题。
- 不允许 BFF 重算标题。
- 不允许直接修改全局 `buildProjectDisplayTitle()` 影响公域项目展示。
- 不允许未授权 viewer 看到真实项目名。

## 4. Next Stage Decision

允许进入 Day-2：

- Server counterpart conversation projection 专用标题修正。
- Server targeted test 覆盖 `西洽会 - 泸州`。

不允许进入：

- production release
- cutover
- 宣称云上 UAT 已通过

## 5. 策略判断

- 更稳：先做 Server 专用 projection。
- 更省成本：BFF/Flutter 不改业务逻辑。
- 更适合当前阶段：修正消息楼项目入口识别。
- 风险更大：跨模块重构项目标题体系。
