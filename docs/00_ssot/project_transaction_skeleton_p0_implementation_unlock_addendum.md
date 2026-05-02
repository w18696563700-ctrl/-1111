---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the single implementation unlock ruling for `项目交易骨架 P0`,
  answering only whether bounded P0 implementation may begin now and exactly
  what is allowed or prohibited.
layer: L0 SSOT
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_transaction_skeleton_p0_gate_checklist.md
  - docs/01_contracts/project_transaction_skeleton_p0_contracts_addendum.md
  - docs/02_backend/project_transaction_skeleton_p0_backend_truth_addendum.md
  - docs/03_bff/project_transaction_skeleton_p0_bff_surface_addendum.md
  - docs/04_frontend/project_transaction_skeleton_p0_frontend_surface_addendum.md
---

# 项目交易骨架 P0 Implementation Unlock Addendum

## 1. Final Status

- `status`: `frozen`
- `unlock`: `allowed`

## 2. 唯一允许开启的实现范围

当前只允许实现以下对象：

1. `bid/submit`
2. `order/create`
3. `contract/confirm`
4. `milestone/submit`
5. `inspection/submit`

同时允许配套落地以下 read baseline：

1. `order/detail`
2. `contract/detail`
3. `milestone/list`
4. `inspection/detail`

## 3. 当前禁止实现的对象

当前明确禁止实现：

1. `contract/amend`
2. `inspection/recheck`
3. `rating/entry`
4. `rating/submit`
5. `dispute/open`
6. `dispute/withdraw`
7. `payment`
8. `billing`
9. `deposit`
10. `guarantee`
11. `credit runtime gate`
12. `membership as project gate`
13. `project visibility/displayStatus runtime`
14. `project review state machine runtime`

## 4. 当前不得触碰的资金与风控链

当前实现中不得触碰：

1. 支付执行链
2. 账单执行链
3. 押金 / 保证金实缴链
4. 交易保障执行链
5. 佣金 / 服务费 / 结算链
6. 将 `profile/payment-and-billing-status/*` 接成 execution
7. 将 `profile/credit-and-constraints/*` 接成 runtime gate

## 5. 当前允许 unlock 的原因

1. 上游 `L0 / L2 / L3 / L4 / L5` 文书链已在本轮冻结。
2. 当前唯一合法大方向已被正式锁定为 `先做交易骨架`。
3. 当前已存在可复核的 read baseline 与 active runtime 主链证据。
4. 当前缺口已经从“方向不清”收敛为“bounded implementation 未做”。

## 6. 当前 unlock 不代表什么

本 unlock 不代表：

1. 真实交易闭环已成立
2. 支付 / 押金 / 佣金可并行开启
3. `rating / dispute` 已被批准
4. project visibility / review runtime 已批准
5. release / launch / production signoff 已批准

## 7. Formal Conclusion

当前 `项目交易骨架 P0` 的正式结论只有一个：

- `status: frozen`
- `unlock allowed`

且当前唯一允许的实现主题只有：

- `bid/submit -> order/create -> contract/confirm -> milestone/submit -> inspection/submit`
