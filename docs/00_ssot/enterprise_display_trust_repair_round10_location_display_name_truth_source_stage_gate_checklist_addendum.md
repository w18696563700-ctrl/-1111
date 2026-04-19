---
owner: Codex 总控
status: frozen
purpose: Gate the next bounded object that opens the province/city display-name truth-source scheme for enterprise display trust repair.
layer: L0 SSOT
freeze_date_local: 2026-04-17
round_id: TC-20260417-10
inputs_canonical:
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/enterprise_display_trust_repair_round8_independent_verification_judgment_addendum.md
  - docs/00_ssot/enterprise_display_workbench_v1_truth_freeze_addendum.md
  - docs/00_ssot/enterprise_display_workbench_upstream_truth_and_certification_summary_semantics_ruling_addendum.md
  - docs/00_ssot/mobile_province_city_picker_unification_truth_freeze_addendum.md
  - docs/00_ssot/project_location_standardization_contract_freeze_addendum.md
  - docs/00_ssot/enterprise_location_capability_v1_truth_freeze_addendum.md
  - apps/server/src/modules/enterprise_hub/enterprise-hub-workbench.query.service.ts
---

# 《enterprise display trust repair round 10 location display-name truth-source stage gate checklist》

## 1. 本轮目标

- 正式打开 `province/city display-name truth-source scheme`。
- 只冻结：
  - 当前为什么还不能直接修 `provinceName / cityName`
  - 下一轮 server-side 显示名真源应如何选
  - 哪些边界仍然不得越过

## 2. 非目标

- 本轮不直接实施新的 server lookup registry。
- 本轮不直接把 mobile asset 挂到 server runtime 读取。
- 本轮不重开 `注册城市` 语义，不把它升级成法定注册地真相。
- 本轮不做 deploy / rollback / live smoke。

## 3. Passed Gates

- 真源门禁：
  - 现有正式文书已经把 location `code + name` 的语义写清：
    - `code` 承担 canonical classification truth
    - `name` 承担 display truth
- 架构边界门禁：
  - `Server` 仍是 enterprise display 位置真值 owner。
- 阶段控制门禁：
  - 当前只开 docs-only 的 truth-source 方案，不越级进实现。
- 运行态证据：
  - 当前 cloud workspace 已能证实只有 mobile 侧存在 `china_province_city.json`。

## 4. Failed Gates

- 真源门禁：
  - 目前没有 server-authoritative 的省市显示名 lookup baseline。
- 契约门禁：
  - 还没有冻结“当 `provinceCode / cityCode` 存在而 `provinceName / cityName` 空白或陈旧时，谁负责纠偏”。
- 状态机与数据门禁：
  - 还没有冻结 blank-only 还是 blank+stale correction 的策略。

## 5. Veto Gates

- 若本轮试图直接进 backend/BFF implementation：
  - `No-Go`
- 触发 veto 的原因：
  - 当前只有 mobile asset，没有 server-side 正式显示名真源
  - 还没有冻结 correction scope
  - 还没有冻结 contracts / persistence / presenter 的单一口径

## 6. Go / No-Go

- 对 `docs-only truth-source ruling`：
  - `Go`
- 对 `backend implementation / BFF implementation / frontend consumption retrofit`：
  - `No-Go`

## 7. 当前允许进入的下一阶段

- 只允许进入：
  - `location display-name truth-source ruling`
- 当前不允许进入：
  - code implementation
  - DB/lookup materialization
  - independent verification
  - integration release

## 8. Formal Conclusion

- `province/city display-name truth-source` 当前可以正式打开 docs-only bounded object。
- 在 server-side 显示名真源冻结前，不得把 mobile asset 或前端派生结果误报成云端已闭环。
