---
owner: Codex 总控
status: completed
purpose: Record the executed contract trim for enterprise display chain P1 package E so the public enterprise-board list no longer overclaims fake filter capability.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/enterprise_display_chain_single_source_of_truth_freeze_addendum.md
  - docs/00_ssot/enterprise_display_chain_p1_minimal_closure_implementation_checklist_addendum.md
  - docs/00_ssot/enterprise_display_chain_p1_package_d_result_verification_conclusion_addendum.md
  - docs/00_ssot/enterprise_display_chain_p1_package_e_filter_contract_trim_stage_gate_checklist_addendum.md
  - docs/00_ssot/enterprise_display_chain_p1_package_e_filter_contract_trim_execution_prompt_addendum.md
  - docs/01_contracts/openapi.yaml
  - packages/contracts/**
---

# 《enterprise display chain P1 package E filter contract trim execution receipt》

## 1. 修改文件清单

- `docs/01_contracts/openapi.yaml`
- `packages/contracts/contracts-manifest.json`
- `packages/contracts/openapi/openapi.bundle.json`
- `packages/contracts/src/generated/app-api.types.ts`
- `packages/contracts/src/generated/error-codes.ts`
- `docs/00_ssot/enterprise_display_chain_p1_package_e_filter_contract_trim_execution_receipt_addendum.md`

## 2. 被删除的 query 参数清单

- `sortBy`
- `certifiedOnly`
- `exhibitionType`
- `serviceCity`
- `caseCountRange`
- `reputationLevel`
- `processType`
- `urgentCapability`
- `warehouseCapability`
- `supplyCategory`
- `supplyMode`
- `responseLevel`

## 3. 保留的 query 参数清单

- `boardType`
- `keyword`
- `provinceCode`
- `cityCode`
- `plantAreaRange`
- `page`
- `pageSize`

## 4. 删除原因与 trim 结论

- `sortBy` 当前不能保留，因为 P1 最小真实筛选集里没有排序真相；继续暴露只会把历史 UI 残留伪装成正式能力。
- `certifiedOnly` 当前不能保留，因为 `Server` 未提供该公域筛选真相；保留会让 `BFF / Flutter` 误判为可执行筛选。
- `exhibitionType` 当前不能保留，因为它不在本轮被验证的最小真实筛选集内；继续出现在 contract 中属于 overclaim。
- `serviceCity` 当前不能保留，因为真实实现只承接 `provinceCode / cityCode`；额外保留会制造第二套地域筛选口径。
- `caseCountRange` 当前不能保留，因为 `Server` 未按该维度提供正式筛选能力；它只是历史残留，不是 P1 真实能力。
- `reputationLevel` 当前不能保留，因为当前没有正式 reputation 评分筛选真相；保留会继续制造 fake-action。
- `processType` 当前不能保留，因为当前 contract 没有对应的真实后端筛选承接；它不属于 P1 已落地集合。
- `urgentCapability` 当前不能保留，因为当前没有正式紧急单能力筛选真相；保留会把 board-specific 文案伪装成正式 contract。
- `warehouseCapability` 当前不能保留，因为当前没有正式仓储能力筛选真相；继续保留只会扩大 contract overclaim。
- `supplyCategory` 当前不能保留，因为当前没有 supplier category 的正式筛选实现；它不是 P1 最小真实筛选集的一部分。
- `supplyMode` 当前不能保留，因为当前没有 supplier mode 的正式筛选实现；继续保留会误导 downstream 继续接 fake filter。
- `responseLevel` 当前不能保留，因为当前没有响应等级的正式筛选真相；它仍是历史残留，不是当前 contract truth。

## 5. 为什么 `page / pageSize` 仍保留

- `page / pageSize` 属于列表读取的最小分页 transport，不属于业务筛选扩张。
- enterprise board public list 作为 canonical list read path，仍需要稳定分页参数来承接结果翻页。
- 保留 `page / pageSize` 不会造成筛选能力 overclaim，只维持 list consumption 的最小 contract 完整性。

## 6. 为什么 `plantAreaRange` 只在 `factory` 成立

- 当前已冻结的最小真实筛选集中，`plantAreaRange` 只对应 `factory` 的厂房面积维度。
- `company` 与 `supplier` 当前没有同构的面积筛选 truth；如果把它写成三板块通用筛选，就会直接构成 contract overclaim。
- 因此本轮在 canonical path 中保留 `plantAreaRange`，同时显式注明：
  - 它只适用于 `factory`
  - 不得暗示其是跨 `boardType` 的通用筛选

## 7. packages/contracts regenerate 结果

- 执行：
  - `ruby packages/contracts/scripts/generate_contracts.rb`
- 结果：
  - `contracts_generate=passed`
- 本轮 regenerate 已把 enterprise public list canonical path 收口到以下 7 个 query 参数：
  - `boardType`
  - `keyword`
  - `provinceCode`
  - `cityCode`
  - `plantAreaRange`
  - `page`
  - `pageSize`
- 说明：
  - `packages/contracts` 属于全量 generated projection。
  - 本轮 package-E 的实质 contract trim 只限 enterprise public list query 收口，不把其他 contract 变更冒充为 package-E 目标。

## 8. contracts:check 结果

- 执行：
  - `ruby packages/contracts/scripts/check_contracts.rb`
- 结果：
  - `contracts_check=passed`

## 9. 当前门禁结论

- 当前结果已经证明：
  - enterprise public list contract 不再 overclaim 公域筛选能力
  - 下一步 `BFF / Flutter` 无需再猜哪些筛选是正式能力
  - fake-filter cleanup 已回到 contract-first 顺序
- 当前是否允许进入 `BFF package E`：
  - `是`
- 说明：
  - `BFF package E` 现在可以围绕正式最小筛选集继续收口
  - `Flutter package E` 仍不得越过 `BFF` 直接自行保留 fake filter
