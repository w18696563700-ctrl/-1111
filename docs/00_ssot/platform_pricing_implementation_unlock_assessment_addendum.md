---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Day 3 implementation unlock assessment for the current platform
  pricing rebaseline, clarifying whether the repo may move from truth-freeze
  into implementation-dispatch authoring and what still blocks direct code
  implementation.
layer: L0 SSOT
freeze_date_local: 2026-04-29
version: V1
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/platform_pricing_rules_master_v1.md
  - docs/00_ssot/platform_pricing_rebaseline_pre_implementation_stage_gate_checklist_addendum.md
  - docs/01_contracts/platform_pricing_contracts_master_v1.md
  - docs/01_contracts/platform_pricing_contracts_companion_patch_v1.md
  - docs/02_backend/platform_pricing_backend_truth_master_v1.md
  - docs/02_backend/platform_pricing_persistence_migration_truth_addendum_v1.md
  - docs/02_backend/platform_pricing_audit_truth_addendum_v1.md
  - docs/03_bff/platform_pricing_bff_surface_master_v1.md
  - docs/04_frontend/platform_pricing_frontend_consumption_master_v1.md
  - docs/00_ssot/platform_pricing_runtime_drift_register_v1.md
---

# 《平台收费规则 Implementation Unlock Assessment V1》

## 0. 总结论

当前收费重基线经过 Day 1 到 Day 3 后，**仍然不允许直接进入代码实现**。

本轮正式裁决：

1. `No-Go for direct implementation`
2. `Candidate Go for implementation dispatch bundle authoring only`
3. 当前还不能做 `deploy / cloud write / runtime verification / release`

当前更稳的方案：

- 先把 implementation drift register 冻结，再只放行“实现派工包编写”

当前更省成本的方案：

- 按 `Server -> BFF -> Flutter -> Message interaction carry -> verification docs` 五片切，不做一把梭重构

当前阶段最适合的方案：

- 继续停在 docs 层，完成 Day 4 门禁重提后，只允许进入 implementation dispatch bundle authoring

风险更大的方案：

- 现在直接让任一端开始改代码，尤其是直接动 `mobile` 或 `BFF` 去兜旧 `trade-task / inquiry-deposit / 3%`

## 1. 当前最小闭环

当前已经完成的最小闭环：

1. `L0` 唯一收费母文件已冻结
2. `L2 contracts` 与 `openapi/error_codes` companion patch 已冻结
3. `L3 backend truth` 与 persistence / audit companion truth 已冻结
4. `L4 BFF` 与 `L5 Flutter` 消费面文书已冻结
5. `runtime drift` 已可进入明确盘点

## 2. 需要保留但暂不开通

当前必须保留但暂不开通：

1. direct implementation
2. 云端发布
3. runtime 联调
4. release-prep
5. production go-live

## 3. 后续扩展位

后续扩展位正式保留：

1. implementation dispatch bundle authoring
2. bounded pricing implementation unlock addendum
3. code implementation round
4. post-deploy cloud validation

## 4. 当前阻断 direct implementation 的 veto

### 4.1 Root Guardrail Veto

`AGENTS.md` 当前 Phase 0 guardrail 仍明确把：

1. `payment`
2. `billing`
3. `settlement`

放在默认 non-goal 里。

因此在没有**单独的 bounded pricing implementation unlock** 之前：

1. 不能直接开 `apps/server/**`
2. 不能直接开 `apps/bff/**`
3. 不能直接开 `apps/mobile/**`

### 4.2 Runtime Drift Veto

三端仍存在大面积旧 runtime 语义：

1. `trade-tasks`
2. `inquiry-deposit`
3. `service-fee-authorizations`
4. `p0-pay-summary`
5. `3% / estimatedFeeAmount / feeRate`

在 drift register 未被切片吸收前，直接实现会导致：

1. 双路径并存
2. 双错误码并存
3. 双文案并存
4. 双状态词表并存

### 4.3 Message Carry Veto

消息楼 / counterpart conversation 仍在读旧 `p0PaySummary` 与旧 routeTarget。

这意味着即使 `project publish`、`4000 gate`、`deal confirmation` 正链改完，消息侧也会把旧真相重新漏回前端。

### 4.4 Verification Veto

当前仍未做：

1. code-level implementation
2. runtime verification
3. cloud validation

所以当前阶段不允许把“文书已完成”误判成“可以直接落代码并上云”。

## 5. 当前可以放行到哪一步

### 5.1 允许

当前允许进入：

1. `implementation dispatch bundle authoring`
2. 即：把未来代码改动切成明确的实现包、责任边界、验证项和回退边界

### 5.2 不允许

当前仍不允许：

1. `direct implementation`
2. `cloud write`
3. `deploy`
4. `integration run`
5. `release`

## 6. 未来实现切片顺序

实现阶段如果获批，只允许按以下顺序切片：

1. `Server pricing domain cutover`
2. `BFF pricing route and error normalization cutover`
3. `Flutter canonical path and consumer cutover`
4. `message interaction pricing carry cutover`
5. `tests and cloud validation`

严禁先改：

1. Flutter 页面文案而不改 upstream truth
2. BFF route 而不改 Server canonical path
3. message carry 而不改 pricing source

## 7. Day 3 评估结论

当前评估结论：

1. `direct implementation = No-Go`
2. `implementation dispatch bundle authoring = provisional Go`

这里的 `provisional Go` 仍需第 4 天《阶段门禁核查表》正式复核后才能生效。

原因：

1. 文书链已闭合到足以切 implementation package
2. root guardrail 仍阻断直接改代码
3. runtime drift 仍需要先被切成可管理的实现包
