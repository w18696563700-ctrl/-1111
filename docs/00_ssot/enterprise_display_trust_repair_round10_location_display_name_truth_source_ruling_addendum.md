---
owner: Codex 总控
status: frozen
purpose: Freeze the truth-source ruling for province/city display names in the enterprise display chain after round-8 verified that code-based readiness is fixed but display-name truth is still incomplete.
layer: L0 SSOT
freeze_date_local: 2026-04-17
round_id: TC-20260417-10
inputs_canonical:
  - docs/00_ssot/enterprise_display_trust_repair_round8_independent_verification_judgment_addendum.md
  - docs/00_ssot/enterprise_display_workbench_v1_truth_freeze_addendum.md
  - docs/00_ssot/enterprise_display_workbench_upstream_truth_and_certification_summary_semantics_ruling_addendum.md
  - docs/00_ssot/mobile_province_city_picker_unification_truth_freeze_addendum.md
  - docs/00_ssot/project_location_standardization_contract_freeze_addendum.md
  - docs/00_ssot/enterprise_location_capability_v1_truth_freeze_addendum.md
  - apps/server/src/modules/enterprise_hub/enterprise-hub-workbench.query.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub.presenter.ts
---

# 《enterprise display trust repair round 10 location display-name truth-source ruling》

## 1. 当前 blocker 裁决

- 当前 `province/city` 问题不是“前端没显示好”这么简单。
- 当前真正缺的是：
  - `Server` 没有一条正式冻结的 `provinceCode/cityCode -> provinceName/cityName` 显示名真源
  - round-7/8 只修到了：
    - code-based readiness 可判定
    - 空白 `provinceCode / cityCode` 可从 organization truth 回填
  - 还没修到：
    - `provinceName / cityName` 的稳定显示真相
    - 旧值纠偏

## 2. 当前证据链

- round-8 judgment 已正式写明：
  - 只会回填空白 `listing.name / provinceCode / cityCode`
  - 不会补 `provinceName / cityName`
  - 不会纠正旧值
- enterprise display 与项目地点标准化相关正式文书已冻结：
  - `code` 承担 canonical classification truth
  - `name` 承担 display truth
- 现有 mobile 文书也已冻结：
  - `apps/mobile/assets/location/china_province_city.json` 只是 mobile shared lookup asset
  - 它不是当前 server formal truth
- 当前 cloud workspace 也只找到：
  - `apps/mobile/assets/location/china_province_city.json`
  - 未找到 server-side 对应 lookup baseline

## 3. 正式方案裁决

### 3.1 省市显示名必须有 server-owned 真源

- 当前正式裁决：
  - enterprise display 链路里的 `provinceName / cityName` 若需要由 `Server` 稳定对外呈现，就必须有 `Server` 自己拥有的显示名真源
- 该真源可以与 mobile 使用同一份上游地区数据谱系，但：
  - 不得在运行时直接依赖 `apps/mobile/assets/location/china_province_city.json`
  - 不得把前端本地派生结果当作云端业务真相

### 3.2 当前唯一允许的真源方向

- 当前唯一允许继续向下冻结的方向是：
  - 建立 `server-side region lookup baseline`
- 它可以是以下任一受控形态：
  - server 侧显式登记的 lookup table
  - server 可消费的共享生成产物
  - 受正式文书登记的后端常量基线
- 无论选哪一种，必须满足：
  - owner 明确属于云端真值链
  - 来源版本可登记
  - mobile 与 server 不能各自独立漂移

### 3.3 correction scope 不得再停留在 blank-only

- 当前正式裁决：
  - 下一轮 truth freeze 必须显式回答 correction scope
- 当前最小需要覆盖：
  - blank `provinceName / cityName`
  - stale `provinceName / cityName`
- 不允许继续只报“空白 backfill 已修”，然后把旧错误显示值留在生产口径里

### 3.4 语义边界继续保留

- 当前不允许把这个对象偷换成：
  - legal registration location truth
  - 地图能力完整解锁
  - 第二套 organization truth
- 当前展示命名边界继续成立：
  - 在 dedicated legal-registration-location truth 未冻结前，不得回退到 `注册城市` 命名

## 4. 下一轮必须冻结什么

- `docs/01_contracts`
  - enterprise display read/write 是否继续要求 `provinceName / cityName` 直传，还是允许由 server lookup 派生并回读
- `docs/02_backend`
  - server-side lookup baseline 的 owner、形态、版本与 correction 策略
- `docs/03_bff`
  - 只负责透传或整形，不得自行派生第二套显示名真相

## 5. Anti-revert

- 不得把 mobile asset 直接包装成 server runtime 真源。
- 不得让 BFF 或 Flutter 长期替 Server 合成 `provinceName / cityName`。
- 不得把 code-based readiness 的通过误报成显示名问题已关闭。
- 不得把当前对象偷带成法定注册地语义改写。

## 6. Formal Conclusion

- `province/city display-name` 下一轮实施前，必须先补 server-owned truth source。
- 当前正式结论不是“前端补个映射表”，而是“云端先补显示名真源”。
- 在该真源冻结并进入 backend truth 前，省市显示名问题仍然是 blocker，不得报已修复。
