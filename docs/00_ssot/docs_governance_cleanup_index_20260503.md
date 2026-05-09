# docs 文书治理清理索引表 20260503

## 1. 总裁决

Conditional Pass for docs governance index。

本轮只新增治理索引文件，不执行清理、不移动、不删除、不重命名、不补 frontmatter、不修改任何既有文书。后续任何清理批次必须重新经过总控二次确认。

## 2. 本轮目的

建立 `docs/**` 文书治理索引，先把文书按风险、状态、领域和后续处理建议登记清楚，避免直接清理导致 SSOT、contracts、backend truth、BFF surface、frontend surface、receipt、evidence 断链。

## 3. 本轮允许范围

- 只新增本文件：`docs/00_ssot/docs_governance_cleanup_index_20260503.md`
- 只登记治理建议，不执行建议动作。
- 只登记 `NO_STATUS` 文件，不补 frontmatter。
- 只登记 `superseded` 文件，不删除、不移动。
- 只输出后续批次路线和门禁。

## 4. 本轮禁止范围

- 不修改 `docs/00_ssot/current_truth_index.md`。
- 不修改 `docs/01_contracts/openapi.yaml`。
- 不修改 `docs/legal/**`。
- 不修改 `packages/contracts/**`、generated types、Flutter、BFF、Server、Admin。
- 不移动、不删除、不重命名任何 addendum / receipt / draft / candidate / template / evidence。
- 不做 commit，不做 push，不部署，不重启，不执行 migration。
- payment / pricing / contracts / backend truth / BFF surface / frontend surface 相关文书全部视为高风险，禁止执行性处理。

## 5. docs 当前规模统计

| path | area | category | detected_status | risk_level | recommended_action | move_allowed_now | delete_allowed_now | requires_owner_confirmation | referenced_by_current_truth_index | notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| docs/00_ssot/** | SSOT | Current / Evidence / Receipt / Addendum mixed | mixed | P0 | 建索引 | 否 | 否 | 是 | 部分是 | 1556 files；平台级真相、回执、证据混合，必须分批治理。 |
| docs/01_contracts/** | Contracts | Contract truth / Addendum mixed | mixed | P0 | 建索引 | 否 | 否 | 是 | 部分是 | 116 files；接口合同层，高风险。 |
| docs/02_backend/** | Backend truth | Backend truth addendum | mixed | P0 | 建索引 | 否 | 否 | 是 | 部分是 | 115 files；Server 真值边界，高风险。 |
| docs/03_bff/** | BFF surface | BFF surface addendum | mixed | P0 | 建索引 | 否 | 否 | 是 | 部分是 | 88 files；BFF app-facing 边界，高风险。 |
| docs/04_frontend/** | Frontend surface | Frontend truth / UI receipt | mixed | P1 | 建索引 | 否 | 否 | 是 | 部分是 | 158 files；Flutter/Admin 消费边界，高风险。 |
| docs/05_admin/** | Admin surface | Admin surface addendum | mixed | P1 | 建索引 | 否 | 否 | 是 | 未确认 | 5 files；Admin 专属边界。 |
| docs/legal/** | Legal | Legal policy | NO_STATUS | P0 | 保留 | 否 | 否 | 是 | 未确认 | 2 files；法律文书，禁止本轮处理。 |
| docs/templates/** | Templates | Template | not found | P2 | 保留 | 否 | 否 | 是 | 否 | 本轮扫描未发现目录，后续若出现按 Template 管理。 |
| docs/**/*.md | Docs total | Markdown | mixed | P0-P3 | 建索引 | 否 | 否 | 是 | 部分是 | 1990 markdown files。 |
| docs/**/*receipt* | Evidence / Receipt | Receipt | mixed | P0-P2 | 保留并建索引 | 否 | 否 | 是 | 部分是 | 253 receipt-name files；不能作为垃圾清理。 |
| docs/**/*addendum* | Addendum | Addendum | mixed | P0-P2 | 分组索引 | 否 | 否 | 是 | 部分是 | 1765 addendum-name files；必须先按模块归档策略冻结。 |
| docs/**/*draft* | Draft | Draft candidate | draft / NO_STATUS | P2-P3 | 归档候选 | 否 | 否 | 是 | 未确认 | 22 draft-name files；只登记，不移动。 |
| docs/**/*candidate* | Candidate | Candidate | candidate / NO_STATUS | P2-P3 | 归档候选 | 否 | 否 | 是 | 未确认 | 4 candidate-name files；只登记，不移动。 |
| docs/**/*template* | Template | Template | template / NO_STATUS | P2 | 建索引 | 否 | 否 | 是 | 未确认 | 12 template-name files；只登记。 |
| docs/**/*evidence* | Evidence | Evidence | mixed | P0-P2 | 保留并建索引 | 否 | 否 | 是 | 部分是 | 33 evidence-path files/dirs；不可清理。 |
| docs/**/*screenshots* | Evidence | Screenshot evidence | mixed | P1 | 保留并建索引 | 否 | 否 | 是 | 部分是 | 23 screenshot-path entries；不可清理。 |

Status scan summary：`frozen=1215`、`draft=293`、`active=224`、`NO_STATUS=132`、`completed=24`、`superseded=10`、`accepted=10`、`effective=7`、`pass=6`、`execution_receipt=6`，其余为少量单例状态。

## 6. 高风险禁止动清单

| path | area | category | detected_status | risk_level | recommended_action | move_allowed_now | delete_allowed_now | requires_owner_confirmation | referenced_by_current_truth_index | notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| docs/00_ssot/current_truth_index.md | SSOT | Current index | current | P0 | 保留 | 否 | 否 | 是 | 是 | 当前真相索引，禁止本轮修改。 |
| docs/00_ssot/release_scope_four_layer_alignment_20260503.md | SSOT | Current baseline | current | P0 | 保留 | 否 | 否 | 是 | 是 | release-scope 四层对齐基线。 |
| docs/00_ssot/evidence/mobile_uat_20260503/** | Evidence | Release evidence | evidence | P0 | 保留 | 否 | 否 | 是 | 是 | 20260503 发布验收证据。 |
| docs/00_ssot/evidence/project_communication_8_materials_matrix_20260503/** | Evidence | UI evidence | evidence | P1 | 保留 | 否 | 否 | 是 | 部分是 | 双账号 UAT 截图证据。 |
| docs/01_contracts/openapi.yaml | Contracts | OpenAPI | current | P0 | 保留 | 否 | 否 | 是 | 是 | 合同主文件，禁止治理批次直接处理。 |
| docs/01_contracts/** | Contracts | Contract addendum | mixed | P0 | 建索引 | 否 | 否 | 是 | 部分是 | 合同层不能移动或删除。 |
| docs/02_backend/** | Backend | Server truth | mixed | P0 | 建索引 | 否 | 否 | 是 | 部分是 | Server 真值和迁移边界不能清理。 |
| docs/03_bff/** | BFF | BFF surface | mixed | P0 | 建索引 | 否 | 否 | 是 | 部分是 | BFF app-facing 边界不能清理。 |
| docs/04_frontend/** | Frontend | Frontend surface | mixed | P1 | 建索引 | 否 | 否 | 是 | 部分是 | UI/消费口径需单独归档门禁。 |
| docs/legal/privacy_policy.md | Legal | Legal | NO_STATUS | P0 | 保留 | 否 | 否 | 是 | 未确认 | 法律文书，禁止处理。 |
| docs/legal/user_agreement.md | Legal | Legal | NO_STATUS | P0 | 保留 | 否 | 否 | 是 | 未确认 | 法律文书，禁止处理。 |
| docs/00_ssot/payment_*.md | Payment | Payment / pricing | mixed | P0 | 保留并建索引 | 否 | 否 | 是 | 部分是 | 支付、结算、退款、价格类全部高风险。 |
| docs/00_ssot/platform_pricing_*.md | Pricing | Pricing | mixed | P0 | 保留并建索引 | 否 | 否 | 是 | 部分是 | pricing 关联交易链，禁止执行性处理。 |
| docs/00_ssot/*contract*.md | Contract | Contract confirmation | mixed | P0 | 保留并建索引 | 否 | 否 | 是 | 部分是 | 合同确认相关禁止清理。 |

## 7. Current 文件索引

| path | area | category | detected_status | risk_level | recommended_action | move_allowed_now | delete_allowed_now | requires_owner_confirmation | referenced_by_current_truth_index | notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| docs/00_ssot/current_truth_index.md | SSOT | Current | current | P0 | 保留 | 否 | 否 | 是 | 是 | 当前真相入口。 |
| docs/00_ssot/release_scope_four_layer_alignment_20260503.md | SSOT | Current baseline | current | P0 | 保留 | 否 | 否 | 是 | 是 | 20260503 runtime release scope 基线。 |
| docs/00_ssot/project_communication_8_materials_matrix_20260503.md | SSOT | Current matrix | current | P0 | 保留 | 否 | 否 | 是 | 是 | 8 资料项业务 matrix。 |
| docs/00_ssot/project_communication_8_materials_ui_matrix_20260503.md | SSOT | Current UI matrix | current | P0 | 保留 | 否 | 否 | 是 | 是 | 3 入口 UI matrix。 |
| docs/00_ssot/docs_governance_cleanup_index_20260503.md | SSOT | Governance index | current | P1 | 保留 | 否 | 否 | 是 | 否 | 本轮新增治理索引。 |
| docs/01_contracts/openapi.yaml | Contracts | Current OpenAPI | current | P0 | 保留 | 否 | 否 | 是 | 是 | app-facing 合同主文件。 |
| docs/00_ssot/evidence/mobile_uat_20260503/20260503-release-acceptance-receipt.md | Evidence | Release receipt | pass | P0 | 保留 | 否 | 否 | 是 | 是 | 发布验收回执。 |
| docs/00_ssot/evidence/p0_contracts_parity_20260503/day0_day6_p0_contracts_parity_baseline_receipt.md | Evidence | Contracts parity receipt | pass | P0 | 保留 | 否 | 否 | 是 | 是 | P0 contracts parity 基线回执。 |

## 8. Evidence 文件索引

| path | area | category | detected_status | risk_level | recommended_action | move_allowed_now | delete_allowed_now | requires_owner_confirmation | referenced_by_current_truth_index | notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| docs/00_ssot/evidence/mobile_uat_20260503/** | Runtime evidence | Evidence | evidence | P0 | 保留并建索引 | 否 | 否 | 是 | 是 | Server/BFF/Admin release、smoke、UAT 证据。 |
| docs/00_ssot/evidence/project_communication_8_materials_matrix_20260503/** | Mobile UI evidence | Evidence | evidence | P1 | 保留并建索引 | 否 | 否 | 是 | 部分是 | 8 资料项 UI 截图证据。 |
| docs/00_ssot/evidence/project_communication_8_materials_matrix_20260503/computer_use_dual_account_uat/** | Mobile UI evidence | Evidence | evidence | P1 | 保留并建索引 | 否 | 否 | 是 | 部分是 | 双账号 Computer Use UAT evidence。 |
| docs/00_ssot/evidence/p0_contracts_parity_20260503/** | Contracts evidence | Evidence | evidence | P0 | 保留并建索引 | 否 | 否 | 是 | 是 | contracts parity evidence。 |
| docs/**/*screenshots* | Screenshot evidence | Evidence | mixed | P1 | 保留并建索引 | 否 | 否 | 是 | 未确认 | 截图类证据只登记，不清理。 |

## 9. Receipt 文件索引

| path | area | category | detected_status | risk_level | recommended_action | move_allowed_now | delete_allowed_now | requires_owner_confirmation | referenced_by_current_truth_index | notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| docs/00_ssot/evidence/mobile_uat_20260503/20260503-release-acceptance-receipt.md | Release | Receipt | pass | P0 | 保留 | 否 | 否 | 是 | 是 | 20260503 发布验收总回执。 |
| docs/00_ssot/evidence/p0_contracts_parity_20260503/day0_day6_p0_contracts_parity_baseline_receipt.md | Contracts | Receipt | pass | P0 | 保留 | 否 | 否 | 是 | 是 | contracts parity 入库回执。 |
| docs/00_ssot/*receipt*.md | SSOT | Receipt | mixed | P1 | 建索引 | 否 | 否 | 是 | 部分是 | 253 receipt-name files；不可批量删除。 |
| docs/01_contracts/*receipt*.md | Contracts | Receipt | mixed | P0 | 建索引 | 否 | 否 | 是 | 部分是 | 合同层回执高风险。 |
| docs/02_backend/*receipt*.md | Backend | Receipt | mixed | P0 | 建索引 | 否 | 否 | 是 | 部分是 | Server truth 回执高风险。 |
| docs/03_bff/*receipt*.md | BFF | Receipt | mixed | P0 | 建索引 | 否 | 否 | 是 | 部分是 | BFF surface 回执高风险。 |
| docs/04_frontend/*receipt*.md | Frontend | Receipt | mixed | P1 | 建索引 | 否 | 否 | 是 | 部分是 | 前端验收回执需保留。 |

## 10. Draft / Candidate / Superseded / Template 候选索引

| path | area | category | detected_status | risk_level | recommended_action | move_allowed_now | delete_allowed_now | requires_owner_confirmation | referenced_by_current_truth_index | notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| docs/00_ssot/bff_server_containerization_migration_draft_addendum.md | SSOT | Draft | draft | P1 | 归档候选 | 否 | 否 | 是 | 未确认 | 可能涉及部署/容器化，不允许本轮处理。 |
| docs/00_ssot/messages_interaction_center_and_bidder_carry_core_v1_bounded_implementation_dispatch_draft_addendum.md | SSOT | Draft | draft | P1 | 归档候选 | 否 | 否 | 是 | 未确认 | 消息/竞标承接相关，需总控确认。 |
| docs/00_ssot/platform_pricing_bff_implementation_dispatch_draft_addendum.md | Pricing | Draft | draft | P0 | 保留并标高风险 | 否 | 否 | 是 | 未确认 | pricing/BFF 高风险。 |
| docs/00_ssot/platform_pricing_server_implementation_dispatch_draft_addendum.md | Pricing | Draft | draft | P0 | 保留并标高风险 | 否 | 否 | 是 | 未确认 | pricing/Server 高风险。 |
| docs/00_ssot/platform_pricing_frontend_implementation_dispatch_draft_addendum.md | Pricing | Draft | draft | P0 | 保留并标高风险 | 否 | 否 | 是 | 未确认 | pricing/Frontend 高风险。 |
| docs/00_ssot/current_active_implementation_candidate_inventory_addendum.md | SSOT | Candidate | candidate | P1 | 建索引 | 否 | 否 | 是 | 未确认 | active implementation 候选清单。 |
| docs/00_ssot/project_communication_realtime_ws_stability_candidate_gate_addendum.md | SSOT | Candidate | candidate | P1 | 归档候选 | 否 | 否 | 是 | 未确认 | realtime/ws 仍需 gate。 |
| docs/00_ssot/feature_status_register_v1_template.md | SSOT | Template | template | P2 | 保留 | 否 | 否 | 是 | 未确认 | 模板类，不能删除。 |
| docs/00_ssot/exhibition_trade_governance_four_documents_03_bff_implementation_unlock_blocker_evidence_submission_template.md | SSOT | Template | template | P1 | 保留 | 否 | 否 | 是 | 未确认 | 治理证据提交模板。 |
| docs/00_ssot/exhibition_trade_task_payment_mainline_p0_pay_freeze_v1_3.md | Payment | Superseded | superseded | P0 | 标废弃候选 | 否 | 否 | 是 | 未确认 | 支付主线高风险，只登记。 |
| docs/01_contracts/exhibition_trade_task_p0_pay_contracts_addendum_v1_3.md | Contracts | Superseded | superseded | P0 | 标废弃候选 | 否 | 否 | 是 | 未确认 | 合同层高风险，只登记。 |
| docs/02_backend/exhibition_trade_task_p0_pay_server_truth_addendum_v1_3.md | Backend | Superseded | superseded | P0 | 标废弃候选 | 否 | 否 | 是 | 未确认 | Server truth 高风险，只登记。 |
| docs/03_bff/exhibition_trade_task_p0_pay_bff_surface_freeze_addendum_v1_3.md | BFF | Superseded | superseded | P0 | 标废弃候选 | 否 | 否 | 是 | 未确认 | BFF surface 高风险，只登记。 |
| docs/04_frontend/exhibition_trade_task_p0_pay_frontend_consumption_freeze_addendum_v1_3.md | Frontend | Superseded | superseded | P1 | 标废弃候选 | 否 | 否 | 是 | 未确认 | 前端消费层，只登记。 |

## 11. NO_STATUS 文件登记队列

| path | area | category | detected_status | risk_level | recommended_action | move_allowed_now | delete_allowed_now | requires_owner_confirmation | referenced_by_current_truth_index | notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| docs/00_ssot/admin_login_truth_drift_cleanup_plan_addendum.md | SSOT | Addendum | NO_STATUS | P1 | 登记，后续补状态候选 | 否 | 否 | 是 | 未确认 | Admin login truth drift。 |
| docs/00_ssot/admin_session_carrier_login_truth_addendum.md | SSOT | Addendum | NO_STATUS | P1 | 登记，后续补状态候选 | 否 | 否 | 是 | 未确认 | Admin session carrier。 |
| docs/00_ssot/alipay_app_pay_channel_integration_addendum.md | Payment | Addendum | NO_STATUS | P0 | 登记，高风险保留 | 否 | 否 | 是 | 未确认 | 支付通道，禁止处理。 |
| docs/00_ssot/auth_login_legal_consent_minimum_closure_addendum.md | Auth / Legal | Addendum | NO_STATUS | P0 | 登记，高风险保留 | 否 | 否 | 是 | 未确认 | 登录与法务同意。 |
| docs/00_ssot/bff_runtime_execstart_repair_receipt_addendum.md | Runtime / BFF | Receipt | NO_STATUS | P0 | 登记，高风险保留 | 否 | 否 | 是 | 未确认 | runtime 修复回执。 |
| docs/00_ssot/bid_participation_request_phase1_rule_freeze_addendum.md | Bid | Addendum | NO_STATUS | P1 | 登记 | 否 | 否 | 是 | 未确认 | 竞标参与规则。 |
| docs/00_ssot/counterpart_conversation_identity_and_grouping_phase1_rule_freeze_addendum.md | Message / Project communication | Addendum | NO_STATUS | P1 | 登记 | 否 | 否 | 是 | 未确认 | 项目沟通身份与分组。 |
| docs/00_ssot/enterprise_display_* | Enterprise | Addendum / Receipt | NO_STATUS | P1 | 按模块登记 | 否 | 否 | 是 | 未确认 | 企业馆系列 NO_STATUS 文件较多，需单独批次。 |
| docs/00_ssot/payment_finance_* | Payment / Finance | Addendum / Receipt | NO_STATUS | P0 | 登记，高风险保留 | 否 | 否 | 是 | 未确认 | 支付、结算、退款规则，禁止处理。 |
| docs/00_ssot/platform_pricing_* | Pricing | Addendum / Receipt | NO_STATUS | P0 | 登记，高风险保留 | 否 | 否 | 是 | 未确认 | pricing 全部高风险。 |
| docs/00_ssot/project_communication_unread_read_* | Project communication | Receipt | NO_STATUS | P1 | 登记 | 否 | 否 | 是 | 未确认 | 项目沟通未读/已读链路回执。 |
| docs/00_ssot/project_transaction_lifecycle_* | Project transaction | Receipt | NO_STATUS | P0 | 登记，高风险保留 | 否 | 否 | 是 | 未确认 | 交易生命周期，不允许处理。 |
| docs/01_contracts/auth_password_login_round_b_contract_freeze.md | Contracts | Contract freeze | NO_STATUS | P0 | 登记，高风险保留 | 否 | 否 | 是 | 未确认 | contract freeze。 |
| docs/01_contracts/*_contracts_addendum.md | Contracts | Addendum | NO_STATUS | P0 | 登记，高风险保留 | 否 | 否 | 是 | 未确认 | 合同层 NO_STATUS，不补 frontmatter。 |
| docs/02_backend/* | Backend | Backend truth | NO_STATUS | P0 | 登记，高风险保留 | 否 | 否 | 是 | 未确认 | Server truth，不补 frontmatter。 |
| docs/03_bff/* | BFF | BFF surface | NO_STATUS | P0 | 登记，高风险保留 | 否 | 否 | 是 | 未确认 | BFF surface，不补 frontmatter。 |
| docs/04_frontend/* | Frontend | Frontend surface | NO_STATUS | P1 | 登记 | 否 | 否 | 是 | 未确认 | 前端 surface，不补 frontmatter。 |
| docs/legal/privacy_policy.md | Legal | Legal | NO_STATUS | P0 | 保留 | 否 | 否 | 是 | 未确认 | 法律文书。 |
| docs/legal/user_agreement.md | Legal | Legal | NO_STATUS | P0 | 保留 | 否 | 否 | 是 | 未确认 | 法律文书。 |

NO_STATUS 总数：132。Batch 2 只允许把本节队列扩展为完整逐文件清单，仍不补 frontmatter、不移动、不删除。

## 12. Addendum 模块分组索引

| path | area | category | detected_status | risk_level | recommended_action | move_allowed_now | delete_allowed_now | requires_owner_confirmation | referenced_by_current_truth_index | notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| docs/00_ssot/*project_communication*addendum.md | Project communication | Addendum | mixed | P1 | 分组索引 | 否 | 否 | 是 | 部分是 | 项目沟通、未读、UAT、通知相关。 |
| docs/00_ssot/*payment*addendum.md | Payment | Addendum | mixed | P0 | 高风险保留 | 否 | 否 | 是 | 部分是 | 支付、退款、结算禁止治理执行。 |
| docs/00_ssot/*pricing*addendum.md | Pricing | Addendum | mixed | P0 | 高风险保留 | 否 | 否 | 是 | 部分是 | pricing 关联交易链。 |
| docs/00_ssot/*enterprise*addendum.md | Enterprise | Addendum | mixed | P1 | 分组索引 | 否 | 否 | 是 | 部分是 | 企业馆/企业工作台系列。 |
| docs/00_ssot/*auth*addendum.md | Auth | Addendum | mixed | P0 | 分组索引 | 否 | 否 | 是 | 部分是 | 认证、登录、法务同意。 |
| docs/00_ssot/*admin*addendum.md | Admin | Addendum | mixed | P1 | 分组索引 | 否 | 否 | 是 | 部分是 | Admin 登录、治理、审核运维。 |
| docs/01_contracts/*addendum.md | Contracts | Addendum | mixed | P0 | 分组索引 | 否 | 否 | 是 | 部分是 | 合同层 addendum。 |
| docs/02_backend/*addendum.md | Backend | Addendum | mixed | P0 | 分组索引 | 否 | 否 | 是 | 部分是 | Server truth addendum。 |
| docs/03_bff/*addendum.md | BFF | Addendum | mixed | P0 | 分组索引 | 否 | 否 | 是 | 部分是 | BFF surface addendum。 |
| docs/04_frontend/*addendum.md | Frontend | Addendum | mixed | P1 | 分组索引 | 否 | 否 | 是 | 部分是 | Frontend consumption / surface addendum。 |

## 13. 后续 Batch 1-7 治理路线

| batch | scope | purpose | allowed_action | forbidden_action | expected_output |
| --- | --- | --- | --- | --- | --- |
| Batch 1 | Governance index | 只新增索引，冻结治理范围 | 新增索引文件 | 清理、移动、删除、重命名 | 本文件 |
| Batch 2 | NO_STATUS expansion | 把 132 个 NO_STATUS 展开成完整逐文件表 | 仅新增/更新治理索引或独立登记表，需单独批准 | 补 frontmatter、移动、删除 | NO_STATUS 完整登记表 |
| Batch 3 | Current / Evidence / Receipt reference map | 建立 current_truth_index 与 receipt/evidence 反向引用 | 只新增引用图谱 | 修改 current_truth_index | 引用关系表 |
| Batch 4 | Draft / Candidate review queue | 将 draft/candidate/template 分批排队 | 只新增审阅队列 | 删除 draft/candidate/template | 审阅队列表 |
| Batch 5 | Superseded mark plan | 对 superseded 文件制定标废弃计划 | 只写计划 | 删除、移动 | Superseded 标废弃方案 |
| Batch 6 | Addendum module map | 按模块给 addendum 建索引 | 只新增模块索引 | 移动 addendum | 模块分组索引 |
| Batch 7 | Execution cleanup proposal | 在前六批证据完整后提出清理执行方案 | 只出方案 | 未经批准执行清理 | 清理执行方案 |

## 14. 每一批次的进入门禁和退出验收标准

| batch | enter_gate | exit_acceptance | rollback_or_stop_condition |
| --- | --- | --- | --- |
| Batch 1 | git clean；只允许新增治理索引 | diff 只出现本索引文件 | 出现既有文件 modified/deleted/renamed 立即停止。 |
| Batch 2 | Batch 1 通过；总控批准扩展 NO_STATUS | 132 个 NO_STATUS 全部登记，未补 frontmatter | 发现 legal/payment/contracts 等被建议删除则停止。 |
| Batch 3 | Batch 2 通过；允许只读引用核对 | 引用图谱只读完成，无正文修改 | current_truth_index 需修改时停止并另开门禁。 |
| Batch 4 | Draft/Candidate/Template owner 确认 | 候选队列完成，无移动删除 | 分类歧义或引用未清时停止。 |
| Batch 5 | superseded owner 确认 | 标废弃方案完成，无删除移动 | 涉及 payment/contracts/backend/BFF 时升级 P0 停止。 |
| Batch 6 | 模块边界冻结 | addendum 模块索引完成 | 模块归属冲突时停止。 |
| Batch 7 | 前六批全部 PASS | 输出可执行清理方案，不执行 | 用户未批准执行清理时停止。 |

## 15. 最终执行结论

本轮只建立治理索引，不动原文。所有候选动作均为建议，不代表已经允许执行。Batch 2 可在总控确认后进入，但只允许把 `NO_STATUS` 队列扩展为完整逐文件登记表，仍禁止补 frontmatter、移动、删除、重命名或修改任何既有文书。
