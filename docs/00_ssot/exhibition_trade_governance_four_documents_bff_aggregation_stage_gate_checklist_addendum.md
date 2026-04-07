---
owner: Codex 总控
status: draft
purpose: Record the stage gate checklist for moving the exhibition trade-governance four-document package from completed backend truth freeze into BFF aggregation specs only, without unlocking implementation, frontend/admin consumption, release-prep, or release execution.
layer: L0 SSOT
---

# 展览项目发布-竞标-履约治理四文书 BFF aggregation 阶段门禁核查表

## Scope
- Current object:
  - `展览项目发布-竞标-履约治理四文书 / BFF aggregation stage gate`
- This checklist applies only to:
  - the four-document governance package under `exhibition`
  - current truth authoring under `docs/**`
  - current transition from completed `docs/02_backend` truth freeze into `docs/03_bff` aggregation specs
- It does not by itself:
  - unlock `apps/bff` implementation
  - unlock `apps/server` implementation
  - unlock Flutter App or Admin consumption specs
  - unlock implementation
  - unlock release-prep
  - unlock release execution
  - override any active board freeze already in force

## Gate Basis
- Current gate basis is frozen against:
  - `docs/00_ssot/exhibition_trade_governance_four_documents_mother_blueprint_v1.md`
  - `docs/00_ssot/exhibition_trade_governance_four_documents_app_alignment_diff_v1.md`
  - `docs/00_ssot/exhibition_trade_governance_four_documents_app_aligned_freeze_v1.md`
  - `docs/00_ssot/account_and_enterprise_certification_rules_v1_app_aligned_freeze_addendum.md`
  - `docs/00_ssot/fake_project_report_and_adjudication_rules_v1_app_aligned_freeze_addendum.md`
  - `docs/00_ssot/contract_archive_and_mandatory_fulfillment_chain_rules_v1_app_aligned_freeze_addendum.md`
  - `docs/00_ssot/blacklist_whitelist_and_permanent_ban_rules_v1_app_aligned_freeze_addendum.md`
  - `docs/00_ssot/exhibition_trade_governance_four_documents_contracts_freeze_stage_gate_checklist_addendum.md`
  - `docs/00_ssot/exhibition_trade_governance_four_documents_backend_truth_stage_gate_checklist_addendum.md`
  - `docs/01_contracts/account_and_enterprise_certification_rules_v1_contracts_addendum.md`
  - `docs/01_contracts/fake_project_report_and_adjudication_rules_v1_contracts_addendum.md`
  - `docs/01_contracts/contract_archive_and_mandatory_fulfillment_chain_rules_v1_contracts_addendum.md`
  - `docs/01_contracts/blacklist_whitelist_and_permanent_ban_rules_v1_contracts_addendum.md`
  - `docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md`
  - `docs/02_backend/fake_project_report_and_adjudication_rules_v1_backend_truth_addendum.md`
  - `docs/02_backend/contract_archive_and_mandatory_fulfillment_chain_rules_v1_backend_truth_addendum.md`
  - `docs/02_backend/blacklist_whitelist_and_permanent_ban_rules_v1_backend_truth_addendum.md`
  - `docs/03_bff/bff_ssot.md`
  - `docs/03_bff/bff_routes.md`
  - `docs/03_bff/account_and_enterprise_certification_rules_v1_bff_surface_addendum.md`
  - `docs/03_bff/fake_project_report_and_adjudication_rules_v1_bff_surface_addendum.md`
  - `docs/03_bff/contract_archive_and_mandatory_fulfillment_chain_rules_v1_bff_surface_addendum.md`
  - `docs/03_bff/blacklist_whitelist_and_permanent_ban_rules_v1_bff_surface_addendum.md`
  - `docs/00_ssot/project_publish_board_boundary_freeze_addendum.md`
  - `docs/00_ssot/account_login_identity_permission_minimum_freeze_addendum.md`
  - `docs/00_ssot/review_ticket_risk_governance_baseline_addendum.md`
  - `docs/00_ssot/platform_capability_unified_baseline_addendum.md`
  - `docs/00_ssot/permission_matrix.md`
  - `docs/00_ssot/gate_register_v1.md`
  - `AGENTS.md`
  - `docs/00_ssot/exhibition_trade_governance_four_documents_03_bff_package1_account_cert_bff_freeze_checkpoint_addendum.md`
  - `docs/00_ssot/exhibition_trade_governance_four_documents_03_bff_package2_fake_project_report_bff_freeze_checkpoint_addendum.md`
  - `docs/00_ssot/exhibition_trade_governance_four_documents_03_bff_package3_contract_archive_bff_freeze_checkpoint_addendum.md`
  - `docs/00_ssot/exhibition_trade_governance_four_documents_03_bff_package4_blacklist_bff_freeze_checkpoint_addendum.md`
  - `docs/00_ssot/exhibition_trade_governance_four_documents_03_bff_body_level_independent_review_signoff_sheet.md`

## Passed Gates
- Current upstream-governance blueprint gate:
  - passed
- Current app-alignment translation gate:
  - passed
- Current app-truth boundary gate:
  - passed
- Current four single-document freeze gate:
  - passed
- Current four-package `L2` contracts freeze gate:
  - passed
- Current generated-contract gate:
  - passed
- Current four-package backend truth and persistence freeze gate:
  - passed
- Current truth-ownership gate:
  - passed
- Current no-second-truth gate:
  - passed
- Current no-second-route-constitution gate:
  - passed
- Current `BFF` constitution gate:
  - passed
  - `docs/03_bff/bff_ssot.md` and `docs/03_bff/bff_routes.md` already freeze that `BFF` is aggregation only and never owns business truth
- Current active-board-conflict priority gate:
  - passed
  - active board freeze still wins where four-document direction is broader than the current project publish corridor
- Current `docs/03_bff` surface addendum body gate:
  - passed
  - blacklist/whitelist addendum本体已纳入本轮核验：
    - `docs/03_bff/blacklist_whitelist_and_permanent_ban_rules_v1_bff_surface_addendum.md`
- Current package-level checkpoint（`account` 包）：
  - passed
  - `docs/00_ssot/exhibition_trade_governance_four_documents_03_bff_package1_account_cert_bff_freeze_checkpoint_addendum.md`
- Current package-level checkpoint（`fake_project` 包）：
  - passed
  - `docs/00_ssot/exhibition_trade_governance_four_documents_03_bff_package2_fake_project_report_bff_freeze_checkpoint_addendum.md`
- Current package-level checkpoint（`contract` 包）：
  - passed
  - `docs/00_ssot/exhibition_trade_governance_four_documents_03_bff_package3_contract_archive_bff_freeze_checkpoint_addendum.md`
- Current package-level checkpoint（`blacklist/whitelist` 包）：
  - passed
  - `docs/00_ssot/exhibition_trade_governance_four_documents_03_bff_package4_blacklist_bff_freeze_checkpoint_addendum.md`

## Failed Gates
- Current docs/03_bff aggregation freeze gate:
  - passed
  - 四包 package-level checkpoint 已形成（`P1/P2/P3/P4`）
- Current Flutter App consumption-spec gate:
  - failed
- Current Admin consumption-spec gate:
  - failed
- Current `apps/bff` implementation gate:
  - failed
- Current `apps/server` implementation gate:
  - failed
- Current release-prep gate:
  - failed
- Current release-execution gate:
  - failed
- Current delivery-closure gate:
  - failed

## Veto Gates
- no `BFF` business truth ownership
- no second identity truth
- no second organization truth
- no second permission truth
- no second role system beyond current `roleKeys`
- no second certification truth beyond current `certificationStatus`
- no `BFF` state machine for certification, report, penalty, whitelist, ban, appeal, contract, fulfillment, or archive status
- no Admin routes through `BFF`
- no naked `/auth/*`, `/orgs/*`, `/me/*`, `/risk/*`, `/penalty/*`, `/appeal/*`, `/ban/*`, or `/whitelist/*` path family outside the current path constitution
- no active-board bypass over `project_publish_board_boundary_freeze_addendum.md`
- no silent auto-unlock of `bid / order / contract / milestone / inspection / rating / dispute` implementation because they are cited for App alignment, L2 contracts, or backend truth
- no implementation ahead of frozen `docs/03_bff` surface specs

## Stage Go / No-Go
- Stage decision:
  - `Go` for `docs/03_bff` aggregation specs only
  - `Go` for dispatching the next BFF-surface prompt bundle
  - `No-Go` for `apps/bff` implementation
  - `No-Go` for `apps/server` implementation
  - `No-Go` for Flutter App consumption specs
  - `No-Go` for Admin consumption specs
  - `No-Go` for implementation
  - `No-Go` for release-prep
  - `No-Go` for release execution

## Current Meaning
- Current allowed meaning:
  - the four-document package has completed upstream governance freeze, `L2` contracts freeze, and backend truth freeze
  - the next round may freeze app-facing BFF aggregation boundaries, response shaping limits, blocked-state copy semantics, and Server-handoff rules only
- Current non-allowed meaning:
  - the four-document package is not yet an implementation package
  - current project publish board is not automatically widened beyond its active minimum corridor
  - BFF does not become a truth owner for certification, report, penalty, whitelist, permanent-ban, appeal, contract archive, fulfillment, or archive gating

## Next Unique Action
- Freeze the fourth `docs/03_bff` aggregation package for:
  - `黑白名单与永久封禁规则 V1`
- Keep the next dispatch bounded to:
  - contract submit / contract acceptance gate shaping（仅按已冻结 `contract` 入口聚合边界）
  - fulfillment 日报/验收入口投影 shaping（仅 read-model 与不可执行态提示）
  - blocked-state and unavailable-state copy
  - command forwarding boundary（禁止 BFF 决策）
  - explicit non-ownership of truth
- Do not dispatch `apps/bff` implementation prompts before that BFF package is frozen.
