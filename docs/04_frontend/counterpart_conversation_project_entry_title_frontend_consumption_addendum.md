---
owner: Codex 总控
status: frozen
purpose: >
  Freeze Flutter consumption rules for counterpart conversation project entry
  titles.
layer: L5 Flutter
recorded_at_local: 2026-04-26
based_on:
  - docs/00_ssot/counterpart_conversation_project_entry_title_truth_freeze_addendum.md
  - docs/04_frontend/counterpart_conversation_project_sliced_frontend_consumption_addendum.md
---

# 《消息楼项目入口标题 Flutter Consumption Addendum》

## 1. 结论

Flutter 不拼标题。

冻结规则：

- 总框项目列表显示 `projectGroups[].projectDisplayTitle`。
- 项目沟通页标题显示同一个 `projectDisplayTitle`。
- 已授权时应显示具体项目名，例如 `西洽会 - 泸州`。
- 未授权时继续显示 Server 下发的遮罩标题。

## 2. Flutter 禁止项

Flutter 不得：

- 本地拼接 `exhibitionName + brandName`。
- 从 `projectId` 推断城市或展台。
- 把 `summary.title` 当项目名。
- 把 `focusProjectId` 解释为已选择聊天项目。
- 在没有 `projectId + threadId` 时加载或发送聊天。

## 3. 验收点

本地 targeted 验收至少包含：

- fixture 中 `exhibitionName = 西洽会`。
- fixture 中 `project.title / projectDisplayTitle = 西洽会 - 泸州`。
- 总框项目入口显示 `西洽会 - 泸州`。
- 项目沟通页显示 `西洽会 - 泸州`。
- 同一对方主体多项目时，入口标题能区分不同项目。

## 4. 当前最小闭环

1. Flutter 总框只列项目入口。
2. 项目入口标题直接显示 Server/BFF 下发的 `projectDisplayTitle`。
3. 点击具体项目后进入项目沟通页。
4. 项目聊天绑定 `projectId + threadId`。

## 5. 策略判断

- 更稳：Flutter 只消费投影字段。
- 更省成本：无需前端拼接或新增字段。
- 更适合当前阶段：把标题真值留在 Server。
- 风险更大：Flutter 临时拼标题，掩盖后端投影错误。
