---
owner: Codex 总控
status: frozen
purpose: Freeze the backend truth scope for enterprise display province/city display-name resolution.
layer: L2 backend
freeze_date_local: 2026-04-17
round_id: TC-20260417-13
inputs_canonical:
  - docs/00_ssot/enterprise_display_trust_repair_round10_location_display_name_truth_source_ruling_addendum.md
  - docs/01_contracts/enterprise_display_trust_repair_round13_location_display_name_contract_freeze_addendum.md
  - docs/00_ssot/enterprise_location_capability_v1_truth_freeze_addendum.md
---

# 《enterprise display trust repair round 13 location display-name backend truth scope》

## 1. owner

- `Server` 是 enterprise display `province/city display-name truth` 的唯一 owner。
- `BFF` 不得生成第二套 name truth。
- `Flutter` 不得以本地 asset 替 Server 补真值。

## 2. truth source baseline

- 下一轮 backend implementation 必须引入一条 `server-owned region lookup baseline`。
- 允许的实现形态：
  - server-side registered lookup table
  - server-consumable generated region artifact
  - formally registered backend constant lookup baseline
- 无论采用哪一种，必须满足：
  - source version 可登记
  - owner 明确属于云端 truth chain
  - mobile 与 server 不得各自独立漂移

## 3. correction rule

- 当 listing/basic write 提交了有效 `provinceCode / cityCode` 时：
  - 若 lookup 命中，`Server` 必须回写 canonical `provinceName / cityName`
  - 若已有 name 与 lookup 不一致，按 lookup 覆写，视为 stale correction
  - 若 code 无法命中，不得静默伪造 name truth

## 4. read-model rule

- workbench / public read / detail read 对外暴露的 `provinceName / cityName` 必须来自：
  - listing 已校正字段
  - 或 server-owned lookup 派生后的同源字段
- 不允许继续把：
  - code-based readiness pass
  - 与 display-name problem resolved
  混为一谈。

## 5. bounded implementation scope

- 下一轮 backend 允许处理：
  - listing basic write correction
  - workbench read correction
  - public/detail read correction
- 下一轮 backend 不处理：
  - bulk migration
  - map capability unlock
  - legal registration city semantics rewrite

## 6. anti-revert

- 不得直接运行时读取 `apps/mobile/assets/location/china_province_city.json` 作为 server truth。
- 不得只修 blank，不修 stale。
- 不得让 organization certification summary 或注册城市语义反向污染 enterprise display 当前城市展示名。

