---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Flutter-only display treatment for masked project names in the
  counterpart conversation project list.
layer: L5 Frontend
freeze_date_local: 2026-04-29
based_on:
  - docs/00_ssot/counterpart_conversation_project_entry_title_truth_freeze_addendum.md
  - docs/03_bff/counterpart_conversation_project_entry_title_bff_surface_addendum.md
  - docs/04_frontend/counterpart_conversation_project_sliced_frontend_consumption_addendum.md
  - docs/04_frontend/counterpart_conversation_project_entry_title_frontend_consumption_addendum.md
---

# 《消息楼项目列表名称查看入口表现 Frontend Addendum》

## 1. 结论

本轮只收敛消息楼 `项目沟通 -> 项目列表` 的 Flutter 展示体验：

- `titleVisibility = masked` 时，项目入口标题继续显示 BFF/Server 下发的 `projectDisplayTitle`，默认文案为 `项目名称需申请查看`。
- 遮罩标题在项目列表卡片中使用绿色强调，并配锁形图标，语义是“这是可进入的名称查看/申请入口线索”，不是“项目名已公开”。
- `titleVisibility = visible` 时，项目标题保持普通黑色标题样式。
- `projectState` 与业务数仍独立展示，例如 `已发布 / 1 项业务`、`已转订单 / 2 项业务`。
- Flutter 不新增字段、不本地生成候选、不重算标题。

## 2. 当前最小闭环

1. 消息楼进入对方主体 `项目沟通`。
2. 总框只显示项目列表，不加载聊天。
3. 每个项目入口显示状态、业务数和项目标题。
4. 遮罩项目名以绿色入口样式提示可继续处理名称查看申请。
5. 点击项目后进入该项目的竞标沟通页，再承接项目名称查看申请、订单状态和项目相册入口。

## 3. 需要保留但暂不开通

- 不新增 `canRequestNameAccessInList`。
- 不新增项目列表内的完整申请按钮。
- 不在项目列表页展开申请、订单、相册或聊天内容。
- 不把绿色标题解释为审批已通过。
- 不改 BFF/Server title projection。

## 4. 后续扩展位

- 若后续需要更细颗粒度，可由 Server/BFF 增加专用 `nameAccessListHint` 或 `canRequestNameAccess` 投影。
- 若后续项目列表需要承接更多业务，可在 `cards[]` 基础上增加受控业务类型摘要，但不得替代项目沟通页。
- 若名称申请流程扩展为独立工作台，应另开冻结单，不并入当前总框列表。

## 5. 策略判断

- 更稳：沿用 `projectDisplayTitle + titleVisibility + projectState + cards`，只改 Flutter 表现。
- 更省成本：不动云上 BFF/Server，不新增接口字段。
- 更适合当前阶段：先把用户在列表里的可见语义讲清楚，让“受限项目名”和“业务状态/订单状态”分开。
- 风险更大：在 Flutter 本地判断权限、生成申请状态或把项目列表做成完整业务工作台。
