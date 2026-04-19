---
owner: Codex 总控
status: active
purpose: Define the bounded execution prompt for the BFF compatibility bridge package so the shared enterprise-hub route family remains compatible while being demoted from canonical identity.
layer: L0 SSOT
freeze_date_local: 2026-04-19
inputs_canonical:
  - docs/00_ssot/enterprise_display_three_board_independence_bff_implementation_dispatch_bundle_addendum.md
  - docs/03_bff/enterprise_display_three_board_independence_bff_surface_scope_addendum.md
---

# 《enterprise display three-board independence BFF compatibility bridge execution prompt》

## 1. Unique Goal

- 保留共享：
  - `/api/app/exhibition/enterprise-hub/**`
- 并明确其定位已经降级为：
  - compatibility bridge

## 2. Frozen Inputs

- shared bridge compatibility expectation
- existing boardType bridge contract

## 3. Must Keep Compatible

- `workbench?boardType=...`
- `enterprises?boardType=...`
- `enterprises/{enterpriseId}?boardType=...`
- `recommendations?boardType=...`
- 既有 shared create / case / published-change path

## 4. Must Not Introduce

- 新的 `/api/app/bff/*` 产品 path
- 第二套 board truth
- 对 board mismatch 的静默容错

## 5. Bridge-only Constraints

- shared family 继续兼容旧 client
- 但不得再被写成 canonical family

## 6. Acceptance Checks

- 旧 shared route 继续通过既有测试
- 旧 shared route 继续保留 `boardType` 语义

## 7. Receipt Requirements

- 必须记录：
  - 兼容桥保留范围
  - 没有破坏的既有测试
  - 没有新增 second-truth 行为
