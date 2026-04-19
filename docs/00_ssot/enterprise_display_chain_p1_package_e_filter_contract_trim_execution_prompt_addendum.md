---
owner: Codex 总控
status: active
purpose: Freeze the contract-trim execution prompt for enterprise display chain P1 package E so public enterprise-board filter truth is reduced to the minimal real set before downstream cleanup starts.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/enterprise_display_chain_single_source_of_truth_freeze_addendum.md
  - docs/00_ssot/enterprise_display_chain_p1_minimal_closure_implementation_checklist_addendum.md
  - docs/00_ssot/enterprise_display_chain_p1_package_d_result_verification_conclusion_addendum.md
  - docs/00_ssot/enterprise_display_chain_p1_package_e_filter_contract_trim_stage_gate_checklist_addendum.md
  - docs/01_contracts/openapi.yaml
  - packages/contracts/**
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_board_surface.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_list_pages.dart
  - apps/mobile/lib/features/exhibition/data/enterprise_hub_consumer_layer.dart
  - apps/bff/src/routes/enterprise_hub/enterprise-hub.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-query.service.ts
---

# 《enterprise display chain P1 package E filter contract trim execution prompt》

## 1. 当前阶段

- 主线：
  - `enterprise display chain`
- 子阶段：
  - `P1 minimal closure`
- 当前包：
  - `package E / filter contract trim`

## 2. 唯一目标

- 你这轮只关闭“公域筛选 fake-action”在 contract truth 这一层的剩余阻断。
- 当前唯一目标固定为：
  - 让 enterprise board public list 的正式 contract 只保留最小真实筛选集

## 3. 强制阅读

- `docs/00_ssot/enterprise_display_chain_single_source_of_truth_freeze_addendum.md`
- `docs/00_ssot/enterprise_display_chain_p1_minimal_closure_implementation_checklist_addendum.md`
- `docs/00_ssot/enterprise_display_chain_p1_package_d_result_verification_conclusion_addendum.md`
- `docs/00_ssot/enterprise_display_chain_p1_package_e_filter_contract_trim_stage_gate_checklist_addendum.md`
- `docs/01_contracts/openapi.yaml`

## 4. 只允许修改的范围

- `docs/01_contracts/openapi.yaml`
- `packages/contracts/**`
- 与本轮最小 contract trim 直接相关的最小 contract / SSOT 文书

## 5. 禁止事项

- 不改 `apps/server/**` 业务实现
- 不改 `apps/bff/**` 业务实现
- 不改 `apps/mobile/**` 业务实现
- 不新增新的 `/api/app/*` path family
- 不把 package-E 扩成后端筛选能力扩张
- 不保留用户可见 fake filter 后再声称 contract 已收口
- 不发明第二套筛选 contract truth

## 6. 当前已冻结事实

1. `P1` 当前最小真实筛选集固定为：
   - `keyword`
   - `provinceCode`
   - `cityCode`
   - `plantAreaRange` for `factory`
2. `Server` 当前真实实现只落了上述最小集合。
3. `openapi` 仍暴露多项历史残留 query 参数，造成 contract overclaim。
4. 在 contract trim 完成前：
   - `BFF package E = No-Go`
   - `Flutter package E = No-Go`

## 7. 你必须完成

1. 在 enterprise public list canonical path 中移除不属于最小真实筛选集的 query 参数 overclaim
2. 保留并只保留：
   - `boardType`
   - `keyword`
   - `provinceCode`
   - `cityCode`
   - `plantAreaRange`
   - `page`
   - `pageSize`
3. 明确 `plantAreaRange` 仅适用于 `factory`，不得在 contract 中暗示其是三板块通用筛选
4. 重新生成 `packages/contracts/**`
5. `contracts:check` 必须通过

## 8. 你必须补的说明

回执中至少必须明确：

1. 被移除的历史残留 query 参数清单
2. 为什么当前不能保留：
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
3. 为什么 `page / pageSize` 仍保留
4. 为什么 `plantAreaRange` 只在 `factory` 成立

## 9. 完成标准

- 结果必须能证明：
  1. contract 已不再 overclaim 公域筛选能力
  2. 下一步 `BFF / Flutter` 无需再猜哪些筛选是正式能力
  3. 当前 fake-filter cleanup 已重新回到 contract-first 顺序
- 如果只能闭合一部分：
  - 必须逐条写出未闭合项
  - 不得把 package-E contract trim 整体写成已完成

## 10. 回执要求

- 回执必须单独落盘为：
  - `docs/00_ssot/enterprise_display_chain_p1_package_e_filter_contract_trim_execution_receipt_addendum.md`
- 回执至少必须包含：
  1. 修改文件清单
  2. 被删除的 query 参数清单
  3. 保留的 query 参数清单
  4. `packages/contracts` regenerate 结果
  5. `contracts:check` 结果
  6. 是否允许进入 `BFF package E`

## 11. 输出禁令

- 不要写“应该可以”
- 不要把用户可见 fake filter 留到 `BFF / Flutter` 再决定
- 不要借 package-E 扩后端筛选能力
- 不要把 `sortBy` 继续伪装成 P1 正式能力
- 只给真实 contract trim、真实生成结果、真实剩余风险
