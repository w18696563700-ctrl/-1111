---
owner: Codex 总控
status: active
purpose: Freeze the next unique action after P1 package A verification: patch the contact write contract so the remaining contact persistence blocker can enter legal BFF and Flutter execution.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/enterprise_display_chain_single_source_of_truth_freeze_addendum.md
  - docs/00_ssot/enterprise_display_chain_p1_minimal_closure_implementation_checklist_addendum.md
  - docs/00_ssot/enterprise_display_chain_p1_package_a_result_verification_conclusion_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/01_contracts/enterprise_display_workbench_v1_contract_freeze_addendum.md
---

# 《enterprise display chain P1 contact write contract patch execution prompt》

## 1. 当前唯一动作

- 当前唯一动作固定为：
  - `contact write contract patch`

## 2. 唯一目标

- 只补齐企业展示工作台“普通保存联系人”所需的最小 contract truth。
- 这一步只解决：
  - 联系人普通保存为什么当前不合法
  - 下一步 BFF / Flutter 怎样在不猜字段的前提下补上 write path

## 3. 只允许修改的范围

- `docs/01_contracts/openapi.yaml`
- 与本次 contract patch 直接相关的最小 contract 文书
- `packages/contracts/**` generated outputs
- 如必须为 drift-free 收口，可同步更新 `apps/bff/src/shared/contracts.ts` 依赖的 generated projection，但不得直接进入 BFF 业务实现

## 4. 禁止事项

- 不改 `apps/server/**` 业务实现
- 不改 `apps/bff/**` 业务实现
- 不改 `apps/mobile/**` 业务实现
- 不新增新的 `/api/app/*` path family
- 不新开第二条 contact update family
- 不顺手扩到 wechat / phone / email / position 当前未在普通保存 UI 暴露的字段

## 5. 当前必须补齐的 contract 真相

- 当前 `EnterpriseHubUpdateBasicRequest` 缺少联系人普通保存字段。
- 当前工作台普通保存 UI 实际可编辑的联系人字段只有两项：
  - `联系人姓名`
  - `联系人手机号`
- 因此本轮 contract patch 只允许最小补入：
  - `contactName`
  - `contactMobile`

## 6. 你必须完成

1. 在 `EnterpriseHubUpdateBasicRequest` 中补入：
   - `contactName`
   - `contactMobile`
2. 保持这两个字段为当前普通保存最小补丁，不扩展到额外 contact 家族
3. 更新相关 contract 冻结文书，使其明确：
   - 普通保存链允许承接当前 UI 暴露的联系人姓名与手机号
4. 重新生成 `packages/contracts/**`
5. 通过 `contracts:check`

## 7. 完成标准

- 结果必须能证明：
  - 联系人普通保存已具有正式 contract 入口
  - 下一步 `BFF package B` 无需猜字段
  - 当前 contract-first 门禁重新满足

## 8. 交付要求

- 交付至少包含：
  1. 修改文件清单
  2. 新增字段定义
  3. 为什么只补 `contactName / contactMobile`
  4. contracts generate / check 结果
  5. 是否允许进入 `BFF package B`

## 9. 当前下一步门禁

- 本 patch 未完成前：
  - `BFF package B = No-Go`
  - `Flutter package C = No-Go`
