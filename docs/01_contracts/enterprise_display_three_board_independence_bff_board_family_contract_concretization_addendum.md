---
owner: Codex 总控
status: frozen
purpose: Concretize the canonical BFF app-facing path families for enterprise-display three-board independence so the previously frozen direction becomes implementable without relying on a shared boardType bridge as the long-term API identity.
layer: L1 Contracts
freeze_date_local: 2026-04-19
inputs_canonical:
  - docs/01_contracts/enterprise_display_three_board_independence_contract_freeze_addendum.md
  - docs/03_bff/enterprise_display_three_board_independence_bff_surface_scope_addendum.md
---

# 《enterprise display three-board independence BFF board-family contract concretization》

## 1. Scope

- 当前 concretization 只覆盖：
  - three-board app-facing canonical family path
  - shared enterprise-hub bridge retention
  - board-sensitive payload injection expectation
- 当前不覆盖：
  - Flutter consumption patch
  - Server path mutation
  - upload transport rewrite

## 2. Canonical Family

- company canonical family：
  - `/api/app/exhibition/enterprise-hub/company/**`
- factory canonical family：
  - `/api/app/exhibition/enterprise-hub/factory/**`
- supplier canonical family：
  - `/api/app/exhibition/enterprise-hub/supplier/**`

## 3. Compatibility Bridge

- 共享 bridge family 继续保留为：
  - `/api/app/exhibition/enterprise-hub/**`
- 正式裁决：
  - 该 family 继续兼容既有 client
  - 但不再是 long-term canonical identity

## 4. Board-sensitive Contract Tightening

- 以下动作在 canonical family 下不再要求 client 显式提交 `boardType`：
  - `GET workbench`
  - `GET recommendations`
  - `GET enterprises`
  - `GET enterprises/{enterpriseId}`
  - `POST enterprises/ensure-shell`
  - `POST applications`
  - `POST enterprises/{enterpriseId}/cases`
- 对应 BFF 必须按 family 自动注入固定 board identity。
- 若 client 在 canonical family 中显式重提冲突 `boardType / applyBoardType`：
  - 必须返回受控失败
  - 不得静默覆盖后伪装成功

## 5. Unchanged Carriers

- 以下 route carrier 继续保持不变，只是迁入新 canonical family：
  - `enterpriseId`
  - `caseId`
  - `applicationId`
  - `fileAssetId`
  - `fileAssetIds[]`
- published-change corridor 继续保持：
  - `changes/current/**`

## 6. Anti-revert

- 不得把 concrete canonical family 再退回成“只有 shared path + query boardType”。
- 不得把 shared bridge 误写为 canonical family。
- 不得在 BFF canonical family 中引入第二套 truth owner。
