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
| CS-018 | 用户拉黑关系 | 私域互动 / 治理动作 | P0 | 待实施 | block_p0_freeze_addendum.md; block_p0_implementation_unlock_stage_gate_checklist_addendum.md; block_p0_implementation_unlock_judgment_addendum.md; block_p0_bounded_implementation_execution_prompt_addendum.md; block_p0_contracts_addendum.md; block_p0_backend_truth_addendum.md; block_p0_bff_surface_addendum.md; block_p0_frontend_surface_addendum.md; block_p0_packet1_backend_bounded_implementation_prompt_addendum.md; block_p0a_backend_verification_conclusion_addendum.md; block_p0a_execution_environment_blocker_disposition_judgment_addendum.md; block_p0a_result_verification_no_go_addendum.md | 总控 / 结果校验 | Result verification rerun NO-GO：Server active runtime/schema PASS，Flutter route correction PASS；剩余 BFF shaping/read-model 仍期待旧 ok/traceId/relationStatus/blocked 响应，与 Server blockedByMe/canInteract 响应不匹配 | Block P0-A BFF shaping/read-model correction |
| CS-019 | 拉黑后互动屏蔽边界 | 私域互动 / 治理动作 | P0-B | 明确延期 | block_p0_freeze_addendum.md; block_p0_implementation_unlock_judgment_addendum.md; block_p0_bounded_implementation_execution_prompt_addendum.md; block_p0_packet1_backend_blocker_review_addendum.md; block_p0a_backend_verification_conclusion_addendum.md; block_p0a_execution_environment_blocker_disposition_judgment_addendum.md | 总控 | interaction-blocking hook 正式转入 Block P0-B；等待 future forum interaction-loop comment/reply/like 写命令后回收，未完成 | Block P0-B after future forum interaction-loop |
| CS-020 | 私信单条举报 | 私域互动 | P1 | 明确延期 | block_p0_freeze_addendum.md | 总控 | 当前 messages 域尚不完整，P0 不硬接私信举报 | Message Safety P1 |
| CS-021 | 私信硬规则拦截 | 私域互动 | P2 | 明确延期 | block_p0_freeze_addendum.md | 总控 | 当前域模型未成型，先不做复杂消息治理 | Message Safety P2 |
| CS-022 | 消息列表预览治理 | 私域互动 | P2 | 明确延期 | block_p0_freeze_addendum.md | 总控 | 当前 messages 仍在消费 forum interaction inbox | Message Safety P2 |
| CS-023 | 最小审核任务队列 | 治理动作 | P0 | 已冻结 | admin_review_p0_freeze_addendum.md | 文书冻结 |  | Admin Review P0 backend truth |
| CS-024 | 最小审核后台 | 治理动作 | P0 | 已冻结 | admin_review_p0_freeze_addendum.md | 文书冻结 |  | Admin Review P0 admin surface |
| CS-025 | 审计日志 | 治理动作 | P0 | 已完成 | safety_audit_p0_freeze_addendum.md; profile_safety_plus_safety_audit_p0_final_implementation_result_verification_rerun_addendum.md | 总控 / 结果校验 | Safety Audit P0 边界内完成；不打开完整处罚台 / 申诉台 | Safety Audit P0 completion accepted |
| CS-026 | 内容快照留存 | 治理动作 | P0 | 已完成 | safety_audit_p0_freeze_addendum.md; profile_safety_plus_safety_audit_p0_final_implementation_result_verification_rerun_addendum.md | 总控 / 结果校验 | Safety Audit P0 边界内完成；不打开存量复扫 | Safety Audit P0 completion accepted |
| CS-027 | 处罚动作体系 | 治理动作 | P1 | 明确延期 | admin_review_p0_freeze_addendum.md; safety_audit_p0_freeze_addendum.md | 总控 | 当前 P0 只做最小治理闭环，不做完整处罚台 | Governance P1 |
| CS-028 | 申诉工单体系 | 治理动作 | P1 | 明确延期 | admin_review_p0_freeze_addendum.md; safety_audit_p0_freeze_addendum.md | 总控 | 当前 P0 不与处罚台、申诉台混包 | Governance P1 |
| CS-029 | 我的举报记录 | 治理动作 | P1 | 明确延期 | forum_report_p0_freeze_addendum.md | 总控 | 当前先把真源和后台最小查看跑通 | Governance P1 |
| CS-030 | 我的申诉记录 | 治理动作 | P2 | 明确延期 | profile_safety_p0_freeze_addendum.md; admin_review_p0_freeze_addendum.md | 总控 | 需依赖处罚与申诉台成型 | Governance P2 |
| CS-031 | 敏感词 / 保留词规则库 | 治理动作 | P0 | 已完成 | safety_audit_p0_freeze_addendum.md; profile_safety_plus_safety_audit_p0_final_implementation_result_verification_rerun_addendum.md | 总控 / 结果校验 | rule/manual P0 边界内完成；AI 审核服务仍为 P1 reserved carrier | Safety Audit P0 completion accepted |
| CS-032 | 用户违规累计分 | 治理动作 | P1 | 明确延期 | admin_review_p0_freeze_addendum.md; safety_audit_p0_freeze_addendum.md | 总控 | 依赖处罚体系与更多审核数据 | Governance P1 |
| CS-033 | 存量内容复扫 | 治理动作 | P2 | 明确延期 | forum_report_p0_freeze_addendum.md; safety_audit_p0_freeze_addendum.md | 总控 | 先完成增量治理基础设施 | Governance P2 |
| CS-034 | AI 审核服务统一接入层 | 治理动作 | P1 | 明确延期 | content_safety_p0_runtime_dependency_judgment_addendum.md | 总控 | 当前不直接作为 P0 实施项 | Safety Engine P1 |

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
