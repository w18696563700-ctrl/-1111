---
owner: Codex 总控
status: frozen
purpose: Freeze the BFF surface boundary for enterprise display province/city display-name truth correction.
layer: L3 BFF
freeze_date_local: 2026-04-17
round_id: TC-20260417-13
inputs_canonical:
  - docs/01_contracts/enterprise_display_trust_repair_round13_location_display_name_contract_freeze_addendum.md
  - docs/02_backend/enterprise_display_trust_repair_round13_location_display_name_backend_truth_scope_addendum.md
---

# 《enterprise display trust repair round 13 location display-name BFF surface scope》

## 1. BFF responsibility

- `BFF` 只负责：
  - transport forwarding
  - response shaping
  - controlled error mapping
- `BFF` 不负责：
  - `provinceName / cityName` lookup
  - stale-name correction
  - second truth derivation

## 2. write-side rule

- BFF 可以继续转发 client 提交的：
  - `provinceCode`
  - `provinceName`
  - `cityCode`
  - `cityName`
- 但正式禁止：
  - BFF 在转发前自行补 name
  - BFF 用本地常量或 asset 覆写 code/name 对

## 3. read-side rule

- BFF 对外返回的 `provinceName / cityName` 必须以 `Server` 返回结果为准。
- 若 `Server` 仍未返回可用 display truth，BFF 只能受控透传缺口，不得伪修。

## 4. error rule

- 若下一轮 backend 对 code/name correction 增加受控错误码：
  - BFF 只允许做 app-facing message mapping
  - 不允许用错误分支偷偷补第二套 display-name 逻辑

## 5. anti-revert

- 不得把当前对象退回为“前端自己映射一下就行”。
- 不得在 BFF 中复制一份地区 lookup，制造 server/BFF 双真源。

