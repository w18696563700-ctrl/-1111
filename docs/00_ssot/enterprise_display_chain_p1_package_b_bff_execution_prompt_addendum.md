---
owner: Codex 总控
status: active
purpose: Freeze the BFF execution prompt for enterprise display chain P1 package B so BFF closes the contact write-path gap without redefining truth or scope.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/enterprise_display_chain_single_source_of_truth_freeze_addendum.md
  - docs/00_ssot/enterprise_display_chain_p1_minimal_closure_implementation_checklist_addendum.md
  - docs/00_ssot/enterprise_display_chain_p1_contact_write_contract_patch_result_verification_conclusion_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/01_contracts/enterprise_display_workbench_v1_contract_freeze_addendum.md
  - apps/bff/src/routes/enterprise_hub/**
---

# 《enterprise display chain P1 package B BFF execution prompt》

## 1. 当前阶段

- 主线：
  - `enterprise display chain`
- 子阶段：
  - `P1 minimal closure`
- 当前包：
  - `package B / BFF`

## 2. 唯一目标

- 你这轮只关闭联系人普通保存链在 `BFF` 这一层的剩余阻断。
- 当前唯一目标固定为：
  - 让 `contactName / contactMobile` 按正式 contract 进入 `updateBasic` write path

## 3. 强制阅读

- `docs/00_ssot/enterprise_display_chain_single_source_of_truth_freeze_addendum.md`
- `docs/00_ssot/enterprise_display_chain_p1_minimal_closure_implementation_checklist_addendum.md`
- `docs/00_ssot/enterprise_display_chain_p1_contact_write_contract_patch_result_verification_conclusion_addendum.md`
- `docs/01_contracts/openapi.yaml`
- `docs/01_contracts/enterprise_display_workbench_v1_contract_freeze_addendum.md`

## 4. 只允许修改的范围

- `apps/bff/src/routes/enterprise_hub/**`
- 与本轮最小透传闭环直接相关的最小测试文件

## 5. 禁止事项

- 不改 `apps/server/**`
- 不改 `apps/mobile/**`
- 不改 `apps/admin/**`
- 不新增新的 `/api/app/*` path family
- 不新增第二条 contact update family
- 不顺手扩到 `wechat / phone / email / position`
- 不在 `BFF` 自持 contact truth 或额外状态机

## 6. 当前已冻结事实

1. `EnterpriseHubUpdateBasicRequest` 现已正式允许：
   - `contactName`
   - `contactMobile`
2. 当前 `BFF` `normalizeBasicPayload()` 尚未透传这两个字段。
3. 当前包只负责让 BFF 按 contract 转发，不负责发明字段或改写真相。

## 7. 你必须完成

1. 在 `normalizeBasicPayload()` 中补齐：
   - `contactName`
   - `contactMobile`
2. 保持两字段都走当前最小普通保存链，不扩写其他联系人字段
3. 保持 `assertNoUrlTruth()`、canonical path、错误码、聚合边界不漂移
4. 如存在 BFF 侧 request/mapper 相关限制，同步收口到正式 contract

## 8. 你必须补的测试

至少补齐以下覆盖：

1. `updateBasic` payload 能透传 `contactName`
2. `updateBasic` payload 能透传 `contactMobile`
3. 未提供这两个字段时，现有 payload 行为不被破坏
4. 不会顺手接受 `wechat / phone / email / position`

## 9. 完成标准

- 结果必须能证明：
  1. `BFF` 不再吞掉联系人普通保存字段
  2. 透传字段与正式 contract 完全一致
  3. 当前联系人 write-path 剩余阻断已收敛到 `Flutter package C`
- 如果只能闭合一部分：
  - 必须逐条写出未闭合项
  - 不得把 `package B / BFF` 整体写成已完成

## 10. 回执要求

- 回执必须单独落盘为：
  - `docs/00_ssot/enterprise_display_chain_p1_package_b_bff_execution_receipt_addendum.md`
- 回执至少必须包含：
  1. 修改文件清单
  2. 每个修改点对应的冻结事实编号
  3. `contactName / contactMobile` 透传说明
  4. 未扩写其他 contact 字段的边界说明
  5. 新增或更新的测试清单
  6. build / test 结果
  7. 当前剩余未闭合项
  8. 是否可移交 `Flutter package C`

## 11. 输出禁令

- 不要写“应该可以”
- 不要把 contract 漏项再转嫁回前端
- 不要顺手扩字段
- 不要给 `BFF` 增加第二真相
- 只给真实透传、真实测试、真实剩余风险

