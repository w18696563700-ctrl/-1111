---
owner: Codex 总控
status: completed
layer: L0 receipt
receipt_date_local: 2026-05-24
purpose: Record Day21-Day24 Server execution for explicit bid-to-order and order completion flow.
---

# 项目交易链路 Day21-Day24 Server 执行回执

## 1. Scope

本回执覆盖：

- 2026-05-21：实现“选定合作方 -> 生成订单”事务命令。
- 2026-05-22：实现订单完成 request / confirm / reject 预留流。
- 2026-05-23：Server 缺陷修复，不扩大范围。
- 2026-05-24：状态机回归测试。

## 2. Day21 Result

完成：

- 新增 Server route:
  - `POST /server/bid/select-bid-and-create-order`
- 新增 service semantic entry:
  - `BidAwardWriteService.selectBidAndCreateOrder`

实现口径：

- 该入口复用原 `award` 事务，不创建第二套竞标选择状态机。
- 仍在同一事务中完成：
  - project lock
  - single-winner guard
  - duplicate order guard
  - order insert
  - contract insert
  - fulfillment seed
  - bid winner/loser state
  - project `converted_to_order`
  - `BidAwarded` audit

验收结论：

- 不能重复生成订单。
- 合同 seed 失败时仍整体回滚。
- 显式 API 和原 `award` API 行为一致。

## 3. Day22 Result

完成：

- 新增 Server routes:
  - `POST /server/order/complete/request`
  - `POST /server/order/complete/confirm`
  - `POST /server/order/complete/reject`
- 新增 Server files:
  - `project-order-completion.controller.ts`
  - `project-order-completion.service.ts`
  - `project-order-completion.presenter.ts`
  - `project-order.errors.ts`

完成流语义：

- `request`：
  - seller only。
  - order 必须是 `active`。
  - order state 保持 `active`。
  - `completionRequestState -> requested`。
- `confirm`：
  - buyer only。
  - 必须存在 pending completion request。
  - `orders.state -> completed`。
  - `completionRequestState -> confirmed`。
  - `completed_at` 写入。
  - 后续互评 gate 由 `orders.state = completed` 打开。
- `reject`：
  - buyer only。
  - 必须存在 pending completion request。
  - order state 保持 `active`。
  - `completionRequestState -> rejected / dispute_reserved`。

## 4. Persistence

迁移 `20260520_project_order_truth_state_machine` 补充：

- `completion_request_state`
- `completion_requested_at`
- `completion_requested_by`
- `completion_requested_by_organization_id`
- `completion_request_note`
- `completion_confirmed_at`
- `completion_confirmed_by`
- `completion_confirmed_by_organization_id`
- `completion_rejected_at`
- `completion_rejected_by`
- `completion_rejected_by_organization_id`
- `completion_rejection_reason`
- `chk_orders_completion_request_state`
- `idx_orders_completion_request_state_updated`

## 5. Day23-Day24 Repair

修复/加固：

- `ProjectOrder` 状态机补充 completion request substate。
- `ProjectOrderEntity` 映射新增字段。
- `OrderModule` 注册 completion controller/service/presenter。
- `BidAward` 测试补显式 select-bid-and-create-order 入口。
- `ProjectOrderCompletion` 测试覆盖 seller/buyer 权限、request/confirm/reject/dispute reserve。

## 6. Verification

已执行：

```bash
npm --prefix apps/server run build
node --test apps/server/test/bid-award-bridge.test.cjs \
  apps/server/test/project-order-completion.test.cjs \
  apps/server/test/project-order-truth.test.cjs \
  apps/server/test/project-counterparty-rating.test.cjs \
  apps/server/test/s2-order-contract-fulfillment-read-corridor.test.cjs
```

结果：

- Server build: pass
- Target tests after new API: `29 passed`

## 7. Remaining Gates

仍未完成，且不得冒充完成：

- BFF app-facing route shaping。
- Flutter 订单完成动作入口。
- Aliyun Server/BFF 发版。
- 双账号真实 UAT：
  - seller request completion
  - buyer confirm completion
  - both sides submit counterparty rating
  - credit shadow/ledger verification
