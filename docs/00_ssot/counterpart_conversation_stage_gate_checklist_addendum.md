---
owner: Codex 总控
status: active
purpose: >
  Submit the Day-1 stage gate checklist for `对方主体会话容器`, checking whether
  the repo may proceed beyond docs freeze while preserving project boundaries,
  original truth ownership, and the old-carrier downgrade.
layer: L0 SSOT
updated_at: 2026-04-24
based_on:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/counterpart_conversation_truth_freeze_addendum.md
  - docs/00_ssot/counterpart_conversation_field_table_addendum.md
  - docs/00_ssot/counterpart_conversation_route_table_addendum.md
  - docs/01_contracts/counterpart_conversation_contract_freeze_addendum.md
  - docs/02_backend/counterpart_conversation_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/counterpart_conversation_bff_surface_freeze_addendum.md
  - docs/04_frontend/counterpart_conversation_frontend_consumption_freeze_addendum.md
---

# 《对方主体会话容器 Day-1 阶段门禁核查表》

## 1. Scope

- 当前对象：
  - `对方主体会话容器`
- 本门禁只服务于：
  - Day-1 文书冻结完成后的阶段裁决
- 本门禁不代表：
  - 直接实现通过
  - integration / release 通过

## 2. Passed Gates

- 文书链完整性 gate：
  - passed
  - `truth / field / route / gate / L2 / L3 / L4 / L5` 已齐备
- 统一入口不改五栋楼 gate：
  - passed
  - 仍在 `messages` building 内承接
- 无第二状态机 gate：
  - passed
  - 文书已明确容器只是聚合展示
- 项目边界不合并 gate：
  - passed
  - 文书已明确按 `projectId` 分 slice
- 旧 carrier 降级 gate：
  - passed
  - `project_name_access_thread / bid_thread` 已改为 detail carrier
- 标题点击权限 sheet gate：
  - passed
  - 已冻结专属 actionKey 与 handoff

## 3. Failed Gates

- Server runtime gate：
  - failed
  - 当前仓库尚未实现 `counterpart conversation` route family
- BFF runtime gate：
  - failed
  - 当前 app-facing shaping 仍未落地
- Frontend runtime gate：
  - failed
  - 当前统一入口与标题 sheet 仍未落地
- cloud integration gate：
  - failed
  - 当前无实际联调与运行态证据

## 4. Veto Gates

- 不得把 `CounterpartConversationContainer` 写成新的统一业务状态机
- 不得把跨项目动作揉平成一个 merged status
- 不得让任何审批 / 申请 / 竞标 / 澄清 / 通知动作丢失 `projectId`
- 不得继续把旧 `project_name_access_thread / bid_thread` 当主入口
- 不得把标题点击直接跳旧 thread，必须先弹权限 sheet

## 5. Stage Go / No-Go Decision

- `Go` for：
  - 后续 implementation authoring 讨论
  - Server/BFF/Flutter 按本文书链分层实现
- `No-Go` for：
  - 跳过 `projectId` 的统一容器实现
  - 旧 carrier 回升为主入口
  - 未弹权限 sheet 的标题点击直跳
  - 把容器写成 generic chat center

## 6. Current Gate Meaning

- 当前允许的真实含义：
  - 可以进入后续分层实现设计与编码阶段
- 当前不允许的真实含义：
  - 不能越过当前边界做统一业务状态机
  - 不能跳过旧 carrier 降级与标题 sheet 规则

## 7. Next Stage Allowed

- 是否允许下一阶段：
  - `Yes`
- 允许的下一阶段范围：
  - `Server / BFF / Flutter implementation authoring within the frozen boundary`
- 当前不允许进入：
  - `integration release judgment`
