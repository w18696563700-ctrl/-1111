---
owner: Codex 总控
status: frozen
purpose: Freeze the bounded backend truth change that aligns public case detail read settlement with enterprise detail public-read compensation semantics.
layer: L2 Backend
freeze_date_local: 2026-04-23
inputs_canonical:
  - docs/00_ssot/enterprise_hub_public_case_detail_read_alignment_truth_ruling_addendum.md
  - docs/01_contracts/enterprise_hub_public_case_detail_read_alignment_contract_note_addendum.md
  - apps/server/src/modules/enterprise_hub/enterprise-hub-query.service.ts
  - apps/server/test/enterprise-hub-public-read-closure.test.cjs
---

# 《enterprise hub public case detail read alignment backend truth》

## 1. Backend Objective

- 当前 backend patch 只负责：
  - 对齐 `getPublicCaseDetail()` 与 `getEnterpriseDetail()` 的 public-read 收敛顺序
  - 消除“父详情页可见案例卡，但二级案例详情假性 404”的读链漂移
- 当前 backend patch 不负责：
  - `formal-info` live truth fallback
  - data repair script
  - BFF / Flutter surface 变更

## 2. Required Truth

- `getPublicCaseDetail(caseId)` 在执行最终公域裁决前，必须先完成：
  - listing certification repair
  - published listing approved-history case repair
  - latest application finalize
- 完成收敛后才允许执行：
  - listing `published + visible`
  - case `approved`

## 3. Allowed Write Set

- 当前允许修改：
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-query.service.ts`
  - `apps/server/test/enterprise-hub-public-read-closure.test.cjs`
  - 与上述直接对应的最小 supporting docs

## 4. Required Test

- 当前至少必须补一条闭环回归：
  - 企业详情页可见案例卡
  - `public-cases/{caseId}` 详情读链同样可读
  - 不允许再出现因 approved-history / finalize 漂移导致的假性 `404`

## 5. Explicit Non-goals

- 不得对 `formal-info` 路由降级到 snapshot truth。
- 不得把该补丁扩展为新的发布审批状态机。
- 不得把“云端 live 数据缺失”伪装成本补丁已解决。
