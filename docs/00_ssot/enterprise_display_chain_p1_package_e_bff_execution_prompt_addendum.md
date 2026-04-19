---
owner: Codex 总控
status: active
purpose: Freeze the BFF execution prompt for enterprise display chain P1 package E so BFF removes historical public-list filter transport drift and aligns with the trimmed contract.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/enterprise_display_chain_single_source_of_truth_freeze_addendum.md
  - docs/00_ssot/enterprise_display_chain_p1_minimal_closure_implementation_checklist_addendum.md
  - docs/00_ssot/enterprise_display_chain_p1_package_e_filter_contract_trim_result_verification_conclusion_addendum.md
  - docs/00_ssot/enterprise_display_chain_p1_package_e_bff_stage_gate_checklist_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/bff/src/routes/enterprise_hub/app-enterprise-hub.controller.ts
  - apps/bff/src/routes/enterprise_hub/enterprise-hub.controller.ts
  - apps/bff/src/routes/enterprise_hub/enterprise-hub.service.ts
---

# 《enterprise display chain P1 package E BFF execution prompt》

## 1. 当前阶段

- 主线：
  - `enterprise display chain`
- 子阶段：
  - `P1 minimal closure`
- 当前包：
  - `package E / BFF`

## 2. 唯一目标

- 你这轮只关闭 enterprise public list 在 `BFF` 这一层的筛选 transport drift。
- 当前唯一目标固定为：
  - 让 `BFF` 对外暴露和对内转发的 enterprise public list query，只保留正式 contract 允许的最小集合

## 3. 强制阅读

- `docs/00_ssot/enterprise_display_chain_single_source_of_truth_freeze_addendum.md`
- `docs/00_ssot/enterprise_display_chain_p1_minimal_closure_implementation_checklist_addendum.md`
- `docs/00_ssot/enterprise_display_chain_p1_package_e_filter_contract_trim_result_verification_conclusion_addendum.md`
- `docs/00_ssot/enterprise_display_chain_p1_package_e_bff_stage_gate_checklist_addendum.md`
- `docs/01_contracts/openapi.yaml`

## 4. 只允许修改的范围

- `apps/bff/src/routes/enterprise_hub/**`
- 与本轮最小 query-transport 收口直接相关的最小测试文件

## 5. 禁止事项

- 不改 `apps/server/**`
- 不改 `apps/mobile/**`
- 不改 `apps/admin/**`
- 不新增新的 `/api/app/*` path family
- 不把 package-E 扩成后端筛选能力扩张
- 不恢复任何已从 contract 删除的 query 参数
- 不在 `BFF` 自持第二套筛选真相

## 6. 当前已冻结事实

1. enterprise public list 正式 query 现在只允许：
   - `boardType`
   - `keyword`
   - `provinceCode`
   - `cityCode`
   - `plantAreaRange`
   - `page`
   - `pageSize`
2. `plantAreaRange` 只适用于 `factory`
3. `BFF` 当前仍保留并转发历史残留 query 参数
4. 当前包只负责收口 `BFF`，不负责 `Flutter` UI cleanup

## 7. 你必须完成

1. 在 enterprise public list 的 `BFF` controller query surface 中移除所有已被 contract 删除的 query 参数
2. 在 `EnterpriseHubListQuery` 与 `buildListParams()` 中只保留正式最小集合
3. 保持：
   - canonical path 不漂移
   - 错误码不漂移
   - `BFF` 只做 transport trim，不新增业务真相
4. 如存在双 controller surface，必须一起收口，不允许留一处历史入口

## 8. 你必须补的测试

至少补齐以下覆盖：

1. enterprise public list 只透传：
   - `boardType`
   - `keyword`
   - `provinceCode`
   - `cityCode`
   - `plantAreaRange`
   - `page`
   - `pageSize`
2. 已删除的历史 query 参数不会再进入 `Server` 请求
3. `plantAreaRange` 仍可正常透传
4. canonical path 与错误归一化不被破坏

## 9. 完成标准

- 结果必须能证明：
  1. `BFF` 已不再自持历史残留筛选 transport
  2. `BFF` 对 enterprise public list 的 query 解释与正式 contract 完全一致
  3. 当前 fake-filter cleanup 剩余责任层已收敛到 `Flutter package E`
- 如果只能闭合一部分：
  - 必须逐条写出未闭合项
  - 不得把 `package E / BFF` 整体写成已完成

## 10. 回执要求

- 回执必须单独落盘为：
  - `docs/00_ssot/enterprise_display_chain_p1_package_e_bff_execution_receipt_addendum.md`
- 回执至少必须包含：
  1. 修改文件清单
  2. 删除的 query transport 清单
  3. 保留的 query transport 清单
  4. 新增或更新的测试清单
  5. build / test 结果
  6. 当前剩余未闭合项
  7. 是否允许进入 `Flutter package E`

## 11. 输出禁令

- 不要写“应该可以”
- 不要把 contract 已删掉的 query 参数继续藏在 controller 或 service
- 不要把问题再甩回 contract 层
- 不要借机扩 `Server`
- 只给真实 query trim、真实测试、真实剩余风险
