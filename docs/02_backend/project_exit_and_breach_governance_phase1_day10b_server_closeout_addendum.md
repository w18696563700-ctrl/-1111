---
title: project_exit_and_breach_governance_phase1_day10b_server_closeout_addendum
owner: Codex 总控
status: frozen
layer: L3 Server Truth
updated_at: 2026-04-29
purpose: Freeze Server implementation detail for accepted mutual cancellation closeout.
inputs_canonical:
  - docs/00_ssot/project_exit_and_breach_governance_phase1_day10b_cancellation_closeout_addendum.md
---

# Day10B Server 收口 Truth

## 0. 裁决

Server 是唯一状态收口 owner。BFF 继续只转发，Flutter 继续只展示。

## 1. `respondCancellation(accept)` 事务步骤

1. 校验 `projectId / exitCaseId / decision / noAutomaticPenaltyConfirmed`。
2. 校验 `exitCase.exitType=mutual_cancellation` 且 `status=requested`。
3. 校验当前组织是 `counterpartyOrganizationId`。
4. 查找绑定订单：
   - 优先使用 `exitCase.orderId`
   - 订单不存在则 fail closed
   - 订单不是 `active` 则 fail closed
5. 写 case：
   - `status=accepted`
   - `respondedAt`
   - `respondedByUserId`
   - `closedAt`
6. 写 project：
   - `state=submitted`
   - `summary=回到预发布列表`
   - `publishedAt=null`
7. 写 order：
   - `state=cancelled`
8. 写 audit：
   - `project_cancellation_accepted`
   - payload 包含 `previousProjectState / nextProjectState / previousOrderState / nextOrderState`
9. 返回 accepted envelope：
   - `projectId`
   - `exitCaseId`
   - `projectState=submitted`
   - `caseStatus=accepted`
   - `action=accept_cancellation`
   - `orderId`
   - `orderState=cancelled`

## 2. `respondCancellation(reject)` 事务步骤

- 只更新 case 为 `rejected`。
- 项目状态不变。
- 订单状态不变。
- 写 audit `project_cancellation_rejected`。

## 3. 支付边界

- 本包不调用 P0-Pay release / hold / charge。
- 本包不初始化支付。
- 本包不执行 callback。
- 本包不写 `payment_orders`。
- 本包不写 `platform_service_fee_authorizations`。

## 4. 回滚

- 代码回滚可恢复旧行为。
- 已经写入的 `accepted` case、`project.state=submitted`、`order.state=cancelled` 不做自动回滚；如需修复，必须走单独运营修复单。
