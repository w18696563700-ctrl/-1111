---
owner: Codex 总控
status: active
purpose: Define the bounded execution prompt for the BFF board-scoped family package so company / factory / supplier canonical app-facing families can be implemented without widening into Flutter or Server truth changes.
layer: L0 SSOT
freeze_date_local: 2026-04-19
inputs_canonical:
  - docs/00_ssot/enterprise_display_three_board_independence_bff_implementation_dispatch_bundle_addendum.md
  - docs/01_contracts/enterprise_display_three_board_independence_bff_board_family_contract_concretization_addendum.md
---

# 《enterprise display three-board independence BFF board-scoped family execution prompt》

## 1. Unique Goal

- 建立：
  - `/api/app/exhibition/enterprise-hub/company/**`
  - `/api/app/exhibition/enterprise-hub/factory/**`
  - `/api/app/exhibition/enterprise-hub/supplier/**`

## 2. Frozen Inputs

- 固定只消费：
  - board-scoped family contract concretization
  - shared bridge compatibility expectation
  - existing enterprise-hub service / workbench / published-change semantics

## 3. Must Touch

- `apps/bff/src/routes/enterprise_hub/**`
- 与之直接相关的最小 `apps/bff/test/**`

## 4. Must Not Touch

- `apps/server/**`
- `apps/mobile/**`
- deploy / release surface

## 5. Canonical Route Rule

- canonical family 下不得再要求 client 显式传：
  - `boardType`
  - `applyBoardType`
- 若 client 显式重提冲突 board identity：
  - 返回受控失败
  - 不得静默覆盖后伪装成功

## 6. Acceptance Checks

- 三套 canonical family 已注册
- fixed-board forwarding 生效
- board-sensitive payload 注入 / 冲突拒绝生效

## 7. Receipt Requirements

- 必须记录：
  - 新增 family 清单
  - touched files
  - targeted tests
  - residual risks
