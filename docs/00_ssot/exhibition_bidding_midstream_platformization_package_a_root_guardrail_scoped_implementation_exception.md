---
owner: Codex 总控
status: frozen
purpose: Grant the shortest scoped root-guardrail exception needed to lift the Phase 0 business-flow veto only for Package A backend-first bounded implementation inside exhibition bidding midstream platformization, without opening Package B/C, integration, or release.
layer: L0 SSOT
freeze_date_local: 2026-04-13
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/exhibition_bidding_midstream_platformization_package_a_implementation_unlock_assessment.md
  - docs/00_ssot/exhibition_bidding_midstream_platformization_package_a_implementation_unlock_independent_review.md
  - docs/00_ssot/exhibition_bidding_midstream_platformization_minimum_closure_freeze.md
  - docs/01_contracts/exhibition_bidding_midstream_platformization_contract_freeze.md
  - docs/02_backend/exhibition_bidding_midstream_platformization_backend_truth_persistence_freeze.md
  - docs/03_bff/exhibition_bidding_midstream_platformization_bff_surface_freeze.md
  - docs/04_frontend/exhibition_bidding_midstream_platformization_frontend_consumption_freeze.md
  - docs/00_ssot/exhibition_bidding_midstream_platformization_implementation_dispatch_freeze.md
  - docs/00_ssot/runtime_release_stabilization_execution_checklist_dispatch_freeze.md
  - docs/00_ssot/forum_implementation_unlock_addendum.md
  - docs/00_ssot/source_of_truth_map.md
---

# 《展览竞标平台化中段 Package A root guardrail scoped implementation exception》

## 1. 当前例外对象

- 当前例外只对以下对象生效：
  - `展览竞标平台化中段`
  - `Package A = seat + bid package completeness`

## 2. 当前例外的唯一目的

- 当前例外只用于解除根目录 `AGENTS.md` 中：
  - `No trading flow implementation`
  对 `Package A` 当前阶段的直接阻断
- 当前例外不改写：
  - 全局 `Phase 0 Guardrail`
  - 全局 `No trading flow implementation` 默认规则
- 当前例外不为以下对象自动开口：
  - `Package B`
  - `Package C`
  - integration
  - release-prep
  - release

## 3. 当前例外的阶段边界

- 当前只放行到：
  - `backend-first bounded implementation`
- 当前固定顺序为：
  1. `Package A backend bounded implementation`
  2. backend receipt passes 后
  3. 才能继续判断 `Package A BFF bounded implementation`
  4. BFF receipt passes 后
  5. 才能继续判断 `Package A frontend bounded implementation`
- 当前不自动放行：
  - `Package B`
  - `Package C`
  - integration
  - release-prep
  - release

## 4. 当前例外继续绑定的硬边界

- 当前只允许：
  - `seat`
  - `bid package completeness`
- 当前继续严格禁止：
  - `buyer compare`
  - `winner decision`
  - `loser feedback`
  - 支付
  - 保证金
  - 复杂评分
  - 治理台
  - 合同 / 履约 / 争议 / 信用飞轮
- `docs/00_ssot/runtime_release_stabilization_execution_checklist_dispatch_freeze.md`
  必须继续作为并行硬门禁输入。
- 任何 backend / BFF / frontend bounded implementation、verification、smoke、release-prep 讨论，都不得绕过该并行硬门禁。

## 5. 当前例外的控制含义

- 当前例外只修订一个局部判断：
  - 根 Phase 0 的交易流实现禁令，不再对 `Package A backend-first bounded implementation` 构成绝对阻断
- 当前例外不修订以下判断：
  - compare / winner decision / loser feedback 仍未放行
  - 支付 / 保证金 / 复杂评分 / 治理台 仍未放行
  - integration / release-prep / release 仍未放行
- 当前例外继续服从：
  - contract-first
  - backend-truth-first
  - BFF-second
  - frontend-third
  - result-verification-before-integration

## 6. 当前阶段直接放行结论

- `Go for Package A backend-first bounded implementation`
- `No-Go for Package B`
- `No-Go for Package C`
- `No-Go for integration`
- `No-Go for release-prep`

## 7. 合规与发布门禁

- 当前 scoped exception 形成后，仍然不得：
  - 把 Package A 写成 runtime 已通
  - 把 Package A 写成 release-ready
  - 跳过 backend receipt 直接写 BFF / frontend 放行
- 当前 scoped exception 之后，仍必须逐步满足：
  - backend receipt
  - BFF receipt
  - frontend receipt
  - result verification
  - runtime checklist evidence

## 8. No-Go 边界

- 不得把当前 scoped exception 写成全局 guardrail 改写
- 不得把当前 scoped exception 写成 Package A 全栈立即放行
- 不得把当前 scoped exception 写成 Package B/C 自动放行
- 不得顺手带入：
  - 支付 / 保证金
  - 复杂评分引擎
  - 治理台
  - 合同 / 履约 / 争议 / 信用飞轮
- 不得绕过结果校验直接进 integration / release-prep

## 9. 下一步唯一动作

- 下一步唯一动作：
  - `输出《展览竞标平台化中段 Package A prompt bundle》`

## 10. 裁决

- `《展览竞标平台化中段 Package A root guardrail scoped implementation exception》是否可入库：是`
