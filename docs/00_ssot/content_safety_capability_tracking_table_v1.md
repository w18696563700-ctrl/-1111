---
title: Content Safety Capability Tracking Table V1
status: frozen
owner: Codex Control
scope: docs-only
created_at: 2026-04-07
---

# 内容安全能力追踪总表 V1

## 1. Purpose

本表是《内容安全治理母版 V1 控制包》的唯一正式防遗漏追踪表。

未经本表登记的能力点，不得视为已冻结、已实施、已完成。

## 2. Status Vocabulary

状态只允许使用：

- 未开始
- 待冻结
- 冻结中
- 已冻结
- 待实施
- 实施中
- 待复核
- 已完成
- 明确延期
- 暂停

## 3. Tracking Table

| 编号 | 能力名称 | 所属层 | 当前阶段归属 | 当前状态 | 当前承接文书 | 当前承接线程 | 当前不纳入原因 | 后续回收节点 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| CS-001 | 昵称硬规则拦截 | 账号资料 | P0 | 已完成 | profile_safety_p0_freeze_addendum.md; profile_safety_plus_safety_audit_p0_final_implementation_result_verification_rerun_addendum.md | 总控 / 结果校验 | Profile Safety P0 边界内完成；不打开 OCR / QR / AI / 处罚 / 申诉 | Profile Safety P0 completion accepted |
| CS-002 | 头像基础文件校验 | 账号资料 | P0 | 已完成 | profile_safety_p0_freeze_addendum.md; profile_safety_plus_safety_audit_p0_final_implementation_result_verification_rerun_addendum.md | 总控 / 结果校验 | Profile Safety P0 边界内完成；不打开 OCR / QR / AI 图片审核 | Profile Safety P0 completion accepted |
| CS-003 | 简介硬规则拦截 | 账号资料 | P0 | 已完成 | profile_safety_p0_freeze_addendum.md; profile_safety_plus_safety_audit_p0_final_implementation_result_verification_rerun_addendum.md | 总控 / 结果校验 | Profile Safety P0 边界内完成；不打开 AI / 处罚 / 申诉 | Profile Safety P0 completion accepted |
| CS-004 | 账号资料先审后显状态流 | 账号资料 | P0 | 已完成 | profile_safety_p0_freeze_addendum.md; profile_safety_p0_state_machine_supplement_freeze_addendum.md; profile_safety_plus_safety_audit_p0_final_implementation_result_verification_rerun_addendum.md | 总控 / 结果校验 | Profile Safety P0 状态机边界内完成；不打开 Admin Review P0 | Profile Safety P0 completion accepted |
| CS-005 | 账号资料审核留痕 | 账号资料 | P0 | 已完成 | profile_safety_p0_freeze_addendum.md; safety_audit_p0_freeze_addendum.md; profile_safety_plus_safety_audit_p0_final_implementation_result_verification_rerun_addendum.md | 总控 / 结果校验 | Safety Audit P0 底座边界内完成；不打开处罚 / 申诉 | Safety Audit P0 completion accepted |
| CS-006 | 头像违规提示与拒绝原因回显 | 账号资料 | P0 | 已完成 | profile_safety_p0_freeze_addendum.md; profile_safety_plus_safety_audit_p0_final_implementation_result_verification_rerun_addendum.md | 总控 / 结果校验 | Profile Safety P0 边界内完成；OCR / QR / AI 风险仍延期 | Profile Safety P0 completion accepted |
| CS-007 | 头像 OCR 图中文字识别 | 账号资料 | P1 | 明确延期 | profile_safety_p0_freeze_addendum.md | 总控 | 当前 P0 不扩大图片审核能力面 | Profile Safety P1 |
| CS-008 | 头像二维码检测 | 账号资料 | P1 | 明确延期 | profile_safety_p0_freeze_addendum.md | 总控 | 当前 P0 不扩大图片审核能力面 | Profile Safety P1 |
| CS-009 | 头像 AI 风险识别 | 账号资料 | P1 | 明确延期 | content_safety_p0_runtime_dependency_judgment_addendum.md | 总控 | AI 仅作为 P1 reserved carrier，不作为 P0 runtime 前提 | Profile Safety P1 |
| CS-010 | 发帖举报入口 | 公开内容 | P0 | 已完成 | forum_report_p0_freeze_addendum.md; forum_report_p0_final_result_verification_rerun_addendum.md; forum_report_p0_completion_filing_addendum.md | 总控 / 结果校验 | Forum Report P0 边界内完成；不打开 precheck / AI / 自动下架 | Forum Report P0 completion filed |
| CS-011 | 评论举报入口 | 公开内容 | P0 | 已完成 | forum_report_p0_freeze_addendum.md; forum_report_p0_final_result_verification_rerun_addendum.md; forum_report_p0_completion_filing_addendum.md | 总控 / 结果校验 | Forum Report P0 边界内完成；不打开评论审核平台或 messages 复杂治理 | Forum Report P0 completion filed |
| CS-012 | 举报工单真源与状态流 | 治理动作 | P0 | 已完成 | forum_report_p0_freeze_addendum.md; forum_report_p0_final_result_verification_rerun_addendum.md; forum_report_p0_completion_filing_addendum.md | 总控 / 结果校验 | Server 持有举报工单真源；BFF 不持有第二状态机 | Forum Report P0 completion filed |
| CS-013 | 举报后台最小查看能力 | 治理动作 | P0 | 已完成 | forum_report_p0_freeze_addendum.md; admin_review_p0_freeze_addendum.md; forum_report_p0_final_result_verification_rerun_addendum.md; forum_report_p0_completion_filing_addendum.md | 总控 / 结果校验 | bounded PASS：仅完成 Admin Review P0 前置输入；Admin UI / Server Admin API 仍归后续 Admin Review P0 | Admin Review P0 |
| CS-014 | 帖子发前 precheck | 公开内容 | P1 | 明确延期 | forum_report_p0_freeze_addendum.md | 总控 | 当前 forum 仍为直接 published，P0 先不改主发布态 | Forum Safety P1 |
| CS-015 | 评论发前 precheck | 公开内容 | P1 | 明确延期 | forum_report_p0_freeze_addendum.md | 总控 | 当前 P0 先做举报闭环 | Forum Safety P1 |
| CS-016 | 帖子 AI 风险审核 | 公开内容 | P1 | 明确延期 | content_safety_p0_runtime_dependency_judgment_addendum.md | 总控 | 当前 P0 不把 AI 审核与 forum 发布态混包 | Forum Safety P1 |
| CS-017 | 评论 AI 风险审核 | 公开内容 | P1 | 明确延期 | content_safety_p0_runtime_dependency_judgment_addendum.md | 总控 | 当前 P0 不把 AI 审核与评论发布态混包 | Forum Safety P1 |
| CS-018 | 用户拉黑关系 | 私域互动 / 治理动作 | P0 | 已完成 | block_p0_freeze_addendum.md; block_p0_implementation_unlock_stage_gate_checklist_addendum.md; block_p0_implementation_unlock_judgment_addendum.md; block_p0_bounded_implementation_execution_prompt_addendum.md; block_p0_contracts_addendum.md; block_p0_backend_truth_addendum.md; block_p0_bff_surface_addendum.md; block_p0_frontend_surface_addendum.md; block_p0_packet1_backend_bounded_implementation_prompt_addendum.md; block_p0a_backend_verification_conclusion_addendum.md; block_p0a_execution_environment_blocker_disposition_judgment_addendum.md; block_p0a_result_verification_no_go_addendum.md; block_p0a_completion_filing_addendum.md | 总控 / 结果校验 | Block P0-A relation/status-only 已完成并 result verification rerun PASS；仅限 block/unblock/single-target status；CS-019 interaction blocking 不计入完成 | Block P0-A completion filed |
| CS-019 | 拉黑后互动屏蔽边界 | 私域互动 / 治理动作 | P0-B | 明确延期 | block_p0_freeze_addendum.md; block_p0_implementation_unlock_judgment_addendum.md; block_p0_bounded_implementation_execution_prompt_addendum.md; block_p0_packet1_backend_blocker_review_addendum.md; block_p0a_backend_verification_conclusion_addendum.md; block_p0a_execution_environment_blocker_disposition_judgment_addendum.md | 总控 | interaction-blocking hook 正式转入 Block P0-B；等待 future forum interaction-loop comment/reply/like 写命令后回收，未完成 | Block P0-B after future forum interaction-loop |
| CS-020 | 私信单条举报 | 私域互动 | P1 | 明确延期 | block_p0_freeze_addendum.md | 总控 | 当前 messages 域尚不完整，P0 不硬接私信举报 | Message Safety P1 |
| CS-021 | 私信硬规则拦截 | 私域互动 | P2 | 明确延期 | block_p0_freeze_addendum.md | 总控 | 当前域模型未成型，先不做复杂消息治理 | Message Safety P2 |
| CS-022 | 消息列表预览治理 | 私域互动 | P2 | 明确延期 | block_p0_freeze_addendum.md | 总控 | 当前 messages 仍在消费 forum interaction inbox | Message Safety P2 |
| CS-023 | 最小审核任务队列 | 治理动作 | P0 | 已完成 | admin_review_p0_freeze_addendum.md; admin_review_p0_result_verification_conditional_pass_addendum.md; admin_review_p0_result_verification_pass_addendum.md; admin_review_p0_completion_filing_addendum.md | 总控 / 结果校验 | 已完成：最小审核任务队列在 bounded `Admin Review P0` 边界内完成；`/review` reviewer-session 可达，queue/detail 闭环成立；forum report 仍仅 view-only；不含 penalty/appeal full desk、CS-019、CS-032/033/034、P1/P2 | Admin Review P0 completion filed |
| CS-024 | 最小审核后台 | 治理动作 | P0 | 已完成 | admin_review_p0_freeze_addendum.md; admin_review_p0_result_verification_conditional_pass_addendum.md; admin_review_p0_result_verification_pass_addendum.md; admin_review_p0_completion_filing_addendum.md | 总控 / 结果校验 | 已完成：最小审核后台在 bounded `Admin Review P0` 边界内完成；approve/reject 闭环成立，forum report 仍仅 view-only；不含 penalty/appeal full desk、CS-019、CS-032/033/034、P1/P2 | Admin Review P0 completion filed |
| CS-025 | 审计日志 | 治理动作 | P0 | 已完成 | safety_audit_p0_freeze_addendum.md; profile_safety_plus_safety_audit_p0_final_implementation_result_verification_rerun_addendum.md | 总控 / 结果校验 | Safety Audit P0 边界内完成；不打开完整处罚台 / 申诉台 | Safety Audit P0 completion accepted |
| CS-026 | 内容快照留存 | 治理动作 | P0 | 已完成 | safety_audit_p0_freeze_addendum.md; profile_safety_plus_safety_audit_p0_final_implementation_result_verification_rerun_addendum.md | 总控 / 结果校验 | Safety Audit P0 边界内完成；不打开存量复扫 | Safety Audit P0 completion accepted |
| CS-027 | 处罚动作体系 | 治理动作 | P1-A | 已完成 | admin_review_p0_freeze_addendum.md; safety_audit_p0_freeze_addendum.md; cs027_execution_environment_blocker_disposition_judgment_addendum.md; cs027_governance_penalty_p1a_server_verification_conclusion_addendum.md; cs027_governance_penalty_p1a_result_verification_pass_addendum.md | 总控 / 结果校验 | 已完成：Server/Admin 最小处罚动作切片 PASS；governance_penalties truth、Server Admin list/detail/apply、audit evidence、Admin 最小 list/detail/apply 消费与 /governance ingress 已对齐；不含申诉、用户端处罚历史、累计分、复扫、AI/precheck/CS-019 | CS-027 P1-A completion accepted |
| CS-028 | 申诉工单体系 | 治理动作 | P1-A | 已完成 | admin_review_p0_freeze_addendum.md; safety_audit_p0_freeze_addendum.md; cs028_governance_appeal_p1a_result_verification_pass_addendum.md; cs028_governance_appeal_p1a_completion_filing_addendum.md | 总控 / 结果校验 | 已完成（限 P1-A：admin appeals list/detail/decide）；`governance_appeal_cases` truth、Server Admin list/detail/decide、appeal decision audit、Admin 最小 list/detail/decide 消费已对齐；不含 `CS-030`、用户端申诉记录、永久封禁申诉、多轮申诉、AI/precheck/CS-019 | CS-028 P1-A completion filed |
| CS-029 | 我的举报记录 | 治理动作 | P1-A | 已完成 | forum_report_p0_freeze_addendum.md; cs029_my_report_history_result_verification_conditional_pass_addendum.md | 总控 / 结果校验 | 已完成：active Server/BFF/Flutter 普通用户回读链路通过，Server/BFF scoped active artifact 已同步回本地基线；不含处罚/申诉/Admin Review/AI/precheck/CS-019 | CS-029 completion accepted |
| CS-030 | 我的申诉记录 | 治理动作 | P2-A | 已完成 | admin_review_p0_freeze_addendum.md; cs028_governance_appeal_p1a_completion_filing_addendum.md; cs030_my_appeal_history_p2a_freeze_spec_bundle_addendum.md; cs030_my_appeal_history_p2a_contracts_addendum.md; cs030_my_appeal_history_p2a_backend_truth_addendum.md; cs030_my_appeal_history_p2a_bff_surface_addendum.md; cs030_my_appeal_history_p2a_frontend_surface_addendum.md; cs030_my_appeal_history_p2a_result_verification_pass_addendum.md; cs030_my_appeal_history_p2a_completion_filing_addendum.md | 总控 / 结果校验 | 已完成：仅 current actor 的 my-appeal-history list/detail；Server `/server/profile/governance/appeals*`、BFF `/api/app/profile/governance/appeals*`、Flutter bounded list/detail consumption 与 owned fixture live smoke 已对齐；不含 submit / penalty history / whitelist-permanent-ban history / CS-032/033/034 / CS-019 / Admin Review completion | CS-030 P2-A completion filed |
| CS-031 | 敏感词 / 保留词规则库 | 治理动作 | P0 | 已完成 | safety_audit_p0_freeze_addendum.md; profile_safety_plus_safety_audit_p0_final_implementation_result_verification_rerun_addendum.md | 总控 / 结果校验 | rule/manual P0 边界内完成；AI 审核服务仍为 P1 reserved carrier | Safety Audit P0 completion accepted |
| CS-032 | 用户违规累计分 | 治理动作 | P1-A | 已完成 | admin_review_p0_completion_filing_addendum.md; cs027_governance_penalty_p1a_result_verification_pass_addendum.md; cs028_governance_appeal_p1a_completion_filing_addendum.md; cs032_user_violation_score_p1a_freeze_spec_bundle_addendum.md; cs032_user_violation_score_p1a_contracts_addendum.md; cs032_user_violation_score_p1a_backend_truth_addendum.md; cs032_user_violation_score_p1a_bff_surface_addendum.md; cs032_user_violation_score_p1a_frontend_surface_addendum.md; cs032_user_violation_score_p1a_result_verification_pass_addendum.md; cs032_user_violation_score_p1a_completion_filing_addendum.md | 总控 / 结果校验 | 已完成：只限 governance-status family 的 bounded score snapshot；既有 `GET /server/profile/governance/status`、既有 `GET /api/app/profile/governance/status`、bounded `violationScoreSnapshot / violationScoreUpdatedAt` 与 Flutter 既有治理摘要 surface 的只读累计分快照展示已对齐；不含自动处罚、penalty history center、appeal center 扩写、whitelist/permanent-ban history、CS-033、CS-034、CS-019、release-prep/launch approval | CS-032 P1-A completion filed |
| CS-033 | 存量内容复扫 | 治理动作 | P2-A | 已完成 | forum_report_p0_freeze_addendum.md; safety_audit_p0_freeze_addendum.md; admin_review_p0_completion_filing_addendum.md; cs033_historical_content_rescan_p2a_freeze_spec_bundle_addendum.md; cs033_historical_content_rescan_p2a_contracts_addendum.md; cs033_historical_content_rescan_p2a_backend_truth_addendum.md; cs033_historical_content_rescan_p2a_bff_surface_addendum.md; cs033_historical_content_rescan_p2a_frontend_surface_addendum.md; cs033_historical_content_rescan_p2a_result_verification_pass_addendum.md; cs033_historical_content_rescan_p2a_completion_filing_addendum.md | 总控 / 结果校验 | 已完成：只限 Server Admin rescan-job slice；`POST /server/admin/governance/rescan-jobs`、`GET /server/admin/governance/rescan-jobs`、`GET /server/admin/governance/rescan-jobs/{rescanJobId}`、`governance_rescan_jobs` 最小 truth、bounded forum content candidate selection 与既有 review-task/Admin Review P0 handoff 基线已对齐；不含自动处罚、penalty/appeal full desk、user-side rescan history、BFF/Flutter 新 surface、AI runtime gateway completion、CS-019、CS-020/021/022、release-prep/launch approval | CS-033 P2-A completion filed |
| CS-034 | AI 审核服务统一接入层 | 治理动作 | P1-A | 已完成 | content_safety_p0_runtime_dependency_judgment_addendum.md; forum_publish_ai_review_gate_boundary_addendum.md; forum_publish_ai_review_gate_contracts_addendum.md; forum_publish_ai_review_gate_truth_addendum.md; forum_publish_ai_review_gate_bff_surface_addendum.md; forum_publish_ai_review_gate_frontend_surface_addendum.md; cs034_ai_review_runtime_gateway_p1a_freeze_spec_bundle_addendum.md; cs034_ai_review_runtime_gateway_p1a_contracts_addendum.md; cs034_ai_review_runtime_gateway_p1a_backend_truth_addendum.md; cs034_ai_review_runtime_gateway_p1a_bff_surface_addendum.md; cs034_ai_review_runtime_gateway_p1a_frontend_surface_addendum.md; cs034_ai_review_runtime_gateway_p1a_result_verification_pass_addendum.md; cs034_ai_review_runtime_gateway_p1a_completion_filing_addendum.md | 总控 / 结果校验 | 已完成：只限 Server-only internal gateway slice；`ai_review_gateway_requests`、`ai_review_gateway_results`、provider request normalization、provider response normalization、internal trace linkage 与 no-public-route boundary 已对齐；不含 `/api/app/*` AI route、`/server/admin/*` AI console route、裸 `/ai/*` public route、automatic punishment、penalty/appeal full desk、user-facing AI center、CS-019、CS-020/021/022、release-prep/launch approval | CS-034 P1-A completion filed |

## 4. Current P0 Freeze Result

已冻结 P0 直接能力：

- CS-001
- CS-002
- CS-003
- CS-004
- CS-005
- CS-006
- CS-010
- CS-011
- CS-012
- CS-013
- CS-018
- CS-019
- CS-023
- CS-024
- CS-025
- CS-026
- CS-031

明确延期能力：

- CS-007
- CS-008
- CS-009
- CS-014
- CS-015
- CS-016
- CS-017
- CS-020
- CS-021
- CS-022
- CS-027
- CS-028
- CS-029
- CS-030
- CS-032
- CS-033
- CS-034

## 5. Current Implementation Completion Filing

已完成 implementation-result acceptance 的能力：

| Package | Completed capabilities | Filing document | Boundary |
| --- | --- | --- | --- |
| Profile Safety P0 + Safety Audit P0 | CS-001, CS-002, CS-003, CS-004, CS-005, CS-006, CS-025, CS-026, CS-031 | profile_safety_plus_safety_audit_p0_final_implementation_result_verification_rerun_addendum.md | 不打开 Forum Report P0、Block P0、Admin Review P0、AI/OCR/QR、处罚/申诉、release-prep 或 launch approval |
| Forum Report P0 | CS-010, CS-011, CS-012, CS-013 | forum_report_p0_completion_filing_addendum.md | CS-013 仅按 bounded PASS 接受为 Admin Review P0 前置输入；不打开 Admin Review P0、Block P0、P1/P2、AI/OCR/QR、precheck、处罚/申诉、release-prep 或 launch approval |

仍未打开：

- CS-018 / CS-019: `Block P0`
- CS-023 / CS-024: `Admin Review P0`
- 全部明确延期的 P1 / P2 能力

## 6. Control Rule

本轮是否有母版能力点未登记、未承接、未回收：无。CS-001 至 CS-034 均已登记、承接或明确延期。
