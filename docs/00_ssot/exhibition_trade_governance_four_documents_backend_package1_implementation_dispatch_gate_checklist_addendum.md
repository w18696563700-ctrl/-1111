---
owner: 总控文书冻结执行位
status: frozen
purpose: Record the dispatch gate decision for whether the next bounded Backend Agent implementation prompt may enter apps/server for Package 1 only.
layer: L0 SSOT
decision_date_local: 2026-04-02
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/exhibition_trade_governance_four_documents_delivery_scheme_stage_gate_checklist_addendum.md
  - docs/00_ssot/exhibition_trade_governance_four_documents_backend_truth_stage_gate_checklist_addendum.md
  - docs/00_ssot/exhibition_trade_governance_four_documents_bff_backend_contracts_stage_unlock_gate_checklist_addendum.md
  - docs/00_ssot/exhibition_trade_governance_four_documents_delivery_scheme_v1.md
  - docs/00_ssot/exhibition_trade_governance_four_documents_delivery_scheme_independent_review_conclusion_addendum.md
  - docs/00_ssot/exhibition_trade_governance_four_documents_backend_d1_truth_gap_planning_addendum.md
  - docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md
  - docs/02_backend/fake_project_report_and_adjudication_rules_v1_backend_truth_addendum.md
  - docs/02_backend/contract_archive_and_mandatory_fulfillment_chain_rules_v1_backend_truth_addendum.md
  - docs/02_backend/blacklist_whitelist_and_permanent_ban_rules_v1_backend_truth_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/server/src/app.module.ts
  - apps/server/src/modules/**
  - apps/server/src/core/migrations/migrations.ts
---

# 展览项目发布-竞标-履约治理四文书
# Backend Package 1 Implementation Dispatch Gate Checklist Addendum

## 1. Scope

- 本文件只裁定两件事：
  - 现在是否允许发出下一条真正进入 `apps/server` 的 Backend Agent implementation prompt
  - 若允许，该 prompt 是否只能针对 Package 1
- 本文件明确不裁定：
  - Package 2 / Package 3 / Package 4 implementation unlock
  - `apps/bff` implementation unlock
  - `apps/mobile` implementation unlock
  - `apps/admin` implementation unlock
  - release-prep
  - release execution
- 本文件是门禁裁定文书，不是实现口令，不是发布说明。

## 2. Gate Basis

### 2.1 实际依据的门禁与方案文书

- [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md)
- [gate_register_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/gate_register_v1.md)
- [exhibition_trade_governance_four_documents_delivery_scheme_stage_gate_checklist_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_delivery_scheme_stage_gate_checklist_addendum.md)
- [exhibition_trade_governance_four_documents_backend_truth_stage_gate_checklist_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_backend_truth_stage_gate_checklist_addendum.md)
- [exhibition_trade_governance_four_documents_bff_backend_contracts_stage_unlock_gate_checklist_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_bff_backend_contracts_stage_unlock_gate_checklist_addendum.md)
- [exhibition_trade_governance_four_documents_delivery_scheme_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_delivery_scheme_v1.md)
- [exhibition_trade_governance_four_documents_delivery_scheme_independent_review_conclusion_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_delivery_scheme_independent_review_conclusion_addendum.md)
- [exhibition_trade_governance_four_documents_backend_d1_truth_gap_planning_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_backend_d1_truth_gap_planning_addendum.md)

### 2.2 实际依据的 backend truth 与 contracts

- [account_and_enterprise_certification_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md)
- [fake_project_report_and_adjudication_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/fake_project_report_and_adjudication_rules_v1_backend_truth_addendum.md)
- [contract_archive_and_mandatory_fulfillment_chain_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/contract_archive_and_mandatory_fulfillment_chain_rules_v1_backend_truth_addendum.md)
- [blacklist_whitelist_and_permanent_ban_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/blacklist_whitelist_and_permanent_ban_rules_v1_backend_truth_addendum.md)
- [openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)

### 2.3 实际依据的 `Server` 代码证据

- [app.module.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/app.module.ts)
- [apps/server/src/modules](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules)
- [migrations.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/core/migrations/migrations.ts)

## 3. Current Inputs Summary

- 当前总前提仍然是：上游冻结完成度高，运行实现完成度低。该口径已在 [exhibition_trade_governance_four_documents_delivery_scheme_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_delivery_scheme_v1.md) 固定。
- `delivery scheme` 已完成，它给出了当前态、目标态、D0-D4 推进顺序与客户口径，但它本身不是 implementation unlock，证据见 [exhibition_trade_governance_four_documents_delivery_scheme_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_delivery_scheme_v1.md) 与 [exhibition_trade_governance_four_documents_delivery_scheme_stage_gate_checklist_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_delivery_scheme_stage_gate_checklist_addendum.md)。
- `independent review` 已完成，它确认方案包口径稳健、未夸大现状，并只放行“下一条 Backend Agent docs-only D1 truth-gap prompt”；它本身不是 runtime implementation unlock，证据见 [exhibition_trade_governance_four_documents_delivery_scheme_independent_review_conclusion_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_delivery_scheme_independent_review_conclusion_addendum.md)。
- `backend D1 planning` 已完成，它冻结了四个 package 的 truth-gap、允许 carrier、禁止 carrier 与顺序关系；但它仍然只是 truth-gap planning，不是实现派工，证据见 [exhibition_trade_governance_four_documents_backend_d1_truth_gap_planning_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_backend_d1_truth_gap_planning_addendum.md)。
- 当前 `Server` 已接线主线仍主要只有 `project`、`upload`、`enterprise_hub`，配套 handwritten 审计主线主要可见于 `audit`，证据见 [app.module.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/app.module.ts) 与 [apps/server/src/modules](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules)。
- 当前 migration 仍主要只有 `enterpriseHubMigrations` 与 `projectPublishCorridorMigrations`，证据见 [migrations.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/core/migrations/migrations.ts)。
- 当前四文书中，只有 Package 1 在 planning 中被明确列为“第一刀候选”，且明确要求“不批准任何新 dedicated identity table”，证据见 [exhibition_trade_governance_four_documents_backend_d1_truth_gap_planning_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_backend_d1_truth_gap_planning_addendum.md) 与 [account_and_enterprise_certification_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md)。
- 即便本轮结论最终为 `Go`，也不自动放开 Package 2 / 3 / 4，不自动放开 `BFF`、`Flutter`、`Admin`，也不自动放开 migration authoring。

## 4. Passed Gates

- `truth-first` 顺序已满足。当前已先后具备 L0 方案文书、独立复核、L3 backend truth addendum、D1 truth-gap planning，符合 [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md) 规定的“先 SSOT/contract/backend truth，后实现”顺序。
- `gate register` 要求的独立门禁裁定条件已具备。本文件即作为进入下一阶段前的正式《阶段门禁核查表》补充裁定，依据见 [gate_register_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/gate_register_v1.md)。
- Package 1 的 canonical truth family、禁止新增 truth family、derived eligibility 规则、audit/evidence 绑定边界已冻结到位，足以支撑“bounded implementation prompt authoring”，证据见 [account_and_enterprise_certification_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md)。
- Package 1 的 planning 已把“只基于现有 truth family 补 controller/service/audit/evidence/derived eligibility，不扩新表族”写清，可作为最小实现放行的范围约束，证据见 [exhibition_trade_governance_four_documents_backend_d1_truth_gap_planning_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_backend_d1_truth_gap_planning_addendum.md)。
- 当前 `Server` 代码现状已被充分摸清，能够明确 bounded prompt 的接触面与非目标，不再处于“证据不足无法 authoring”状态，证据见 [app.module.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/app.module.ts)、[apps/server/src/modules](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules)、[migrations.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/core/migrations/migrations.ts)。

## 5. Failed Gates

### 5.1 当前未通过、但不直接阻断 Package 1 implementation dispatch 的门

- Package 2 / 3 / 4 仍未进入实现放行状态。它们虽然已有 truth 文书与 planning，但未被本文件裁定为可进入 `apps/server` 实现。
- `BFF`、`Flutter`、`Admin` 仍未进入实现放行状态。当前仅裁定 Backend Package 1 最小实现放行，不裁定消费层同步开工。
- 四文书全链联调、验收、release-prep、release execution 仍全部未通过。
- dedicated governance/report/contract 层 migration 仍未通过放行。本文件不把“当前 migration 缺失”解释为“现在允许补所有 migration”。

### 5.2 当前未通过、且会直接阻断 Package 1 implementation dispatch 的门

- 本轮未发现“在严格限定为 Package 1 only、`apps/server` only、no migration、no second truth”的前提下，仍然直接阻断 Package 1 bounded implementation prompt 的剩余 failed gate。
- 但若下一条 prompt 触及以下任一行为，则本条门禁立即失效并回退为 `No-Go`：
  - 把范围扩大到 Package 2 / 3 / 4
  - 同步放开 `apps/bff`、`apps/mobile`、`apps/admin`
  - author migration 或新增 dedicated table
  - 把 planning 文书当成“代码已实现”的依据

## 6. Veto Gates

以下任一项触发即一票否决：

- second truth：发明第二套 identity / organization / certification / governance truth。
- implementation ahead of frozen truth：实现先于已冻结 truth family、状态责任、audit/evidence 约束。
- 放大为四包全开工：把本轮 Package 1 最小放行偷换为四文书整体 implementation unlock。
- 越权放开 `BFF` / `Flutter` / `Admin`：借 Backend 派工带出消费层和运营台同步施工。
- 新增裸路径家族：新造 `/auth/*`、`/orgs/*`、`/me/*`、`/risk/*`、`/penalty/*`、`/appeal/*`、`/ban/*`。
- 把 planning 文书当已实现依据：把 [exhibition_trade_governance_four_documents_backend_d1_truth_gap_planning_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_backend_d1_truth_gap_planning_addendum.md) 误读成 runtime completion。
- 把 `enterprise_hub` 展示快照误当认证真值。
- 把 `objectKey` 升格成业务真相，绕过 `FileAsset` / evidence 绑定。

## 7. Stage Go / No-Go

`Go` for bounded Backend Agent implementation prompt for Package 1 only

原因如下：

- 当前 delivery scheme、independent review、backend D1 truth-gap planning 都已完成，且三者合并后已足以支撑“下一条 prompt 如何写边界”，不再只是抽象建议。
- Package 1 的 backend truth 边界最清晰，且 planning 已明确其“第一刀”顺序与“不扩新表族”的约束，因此当前只有 Package 1 具备最小实现 authoring 条件。
- 当前代码证据已足够证明：需要补的是 Package 1 controller/service/audit/evidence/derived eligibility 接触面，而不是再补一轮抽象讨论。
- 该 `Go` 仅是最小实现放行，不是四文书整体 implementation unlock，不是 migration unlock，不是 `BFF` / `Flutter` / `Admin` unlock。

## 8. If Go, Allowed Range

### 8.1 允许触碰的目录

- 只限 `apps/server`
- 最小允许目录范围只能是：
  - `apps/server/src/app.module.ts`
  - `apps/server/src/modules/**`
- 明确不允许触碰：
  - `apps/bff/**`
  - `apps/mobile/**`
  - `apps/admin/**`
  - `apps/server/src/core/migrations/**`

### 8.2 允许完成的工作类型

- 只限 Package 1。
- 只限围绕现有 frozen truth family 的最小运行接线：
  - Package 1 controller family
  - Package 1 service family
  - Package 1 module wiring
  - Package 1 admin review truth endpoints
  - Package 1 derived eligibility read/write logic
  - Package 1 audit writer 与 evidence linkage
- 只允许基于已冻结 carrier 施工，不得新造 dedicated identity / certification table。

### 8.3 明确禁止的事项

- 不自动放开 migration authoring 或 migration execution。
- 不自动放开 Package 2 / 3 / 4。
- 不自动放开 `BFF` / `Flutter` / `Admin`。
- 不得引入第二套 identity / organization / certification / governance truth。
- 不得把 `enterprise_hub` 展示态对象冒充认证真值闭环。
- 不得把本轮 prompt 写成 release-prep 或 release execution。

## 9. If No-Go, Required Prerequisites

- 本轮结论为 `Go`，因此不存在“发出 Package 1 bounded implementation prompt 前还必须新增哪份文书”的额外 prerequisite。
- 但若后续想扩大范围，则必须重新补门禁，而不能沿用本文件：
  - 若要 author migration，必须先单独补 migration scope gate
  - 若要进入 Package 2 / 3 / 4，必须分别补各自 implementation dispatch gate
  - 若要进入 `BFF` / `Flutter` / `Admin`，必须分别补对应 stage unlock gate

## 10. Next Unique Action

- 下一条允许发给 Backend Agent。
- 但只允许发一个 bounded Backend Agent implementation prompt for Package 1 only。
- 该下一条 prompt 必须同时写死以下边界：
  - 只限 `apps/server`
  - 只限 Package 1
  - 不得新增 migration
  - 不得触碰 Package 2 / 3 / 4
  - 不得触碰 `apps/bff/**`
  - 不得触碰 `apps/mobile/**`
  - 不得触碰 `apps/admin/**`
  - 不得引入第二套 truth family
- 若下一条 prompt 不能满足上述条件，则应退回总控重新出 gate，而不是带条件直接开工。

