---
owner: Codex 总控
status: frozen
purpose: Freeze the app-facing contract rules for enterprise display province/city display-name truth before cloud implementation begins.
layer: L1 contracts
freeze_date_local: 2026-04-17
round_id: TC-20260417-13
inputs_canonical:
  - docs/00_ssot/enterprise_display_trust_repair_round10_location_display_name_truth_source_ruling_addendum.md
  - docs/00_ssot/project_location_standardization_contract_freeze_addendum.md
  - docs/01_contracts/enterprise_display_workbench_v1_contract_freeze_addendum.md
---

# 《enterprise display trust repair round 13 location display-name contract freeze》

## 1. canonical contract rule

- enterprise display read surface 继续同时返回：
  - `provinceCode`
  - `provinceName`
  - `cityCode`
  - `cityName`
- 其中：
  - `provinceCode / cityCode` = canonical classification truth
  - `provinceName / cityName` = canonical display truth

## 2. write contract rule

- app-facing write body 仍允许携带：
  - `provinceCode`
  - `provinceName`
  - `cityCode`
  - `cityName`
- 但从本轮开始正式冻结：
  - client 传入的 `provinceName / cityName` 只算 `display hint`
  - 若 `Server` 可通过自有 lookup 命中对应 code，则必须由 `Server` 覆写为 server-owned display truth
  - client 不得宣称自己生成的 name 是最终 truth

## 3. read contract rule

- app-facing read model 读取到的 `provinceName / cityName` 只允许来自：
  - `Server` 已校正后的 read truth
- `BFF` 与 `Flutter` 不得长期以 mobile asset 或本地映射替代该显示名 truth。

## 4. correction contract rule

- 本轮合同正式要求 backend implementation 至少覆盖：
  - blank `provinceName / cityName` backfill
  - stale `provinceName / cityName` correction
- 不再允许只修 blank code / blank name 其中一半，然后把旧显示值继续透给前台。

## 5. non-goals

- 本轮合同不扩：
  - legal registration location dedicated truth
  - map preview capability contract
  - new search/filter contract

## 6. anti-revert

- 不得把 mobile `china_province_city.json` 直接抬成 server runtime contract truth。
- 不得把 BFF 或 Flutter 的 name derivation 误写成正式 contract 行为。
