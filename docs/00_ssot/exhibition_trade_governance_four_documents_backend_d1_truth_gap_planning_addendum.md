---
owner: 后端 Agent（云端）
status: draft
purpose: Record a docs-only Backend D1 truth-gap planning addendum for the exhibition trade-governance four-document package, without unlocking implementation, migration, deploy, or release.
layer: L0 SSOT
planning_date_local: 2026-04-02
inputs_canonical:
  - AGENTS.md
  - apps/server/AGENTS.md
  - docs/00_ssot/exhibition_trade_governance_four_documents_delivery_scheme_stage_gate_checklist_addendum.md
  - docs/00_ssot/exhibition_trade_governance_four_documents_delivery_scheme_v1.md
  - docs/00_ssot/exhibition_trade_governance_four_documents_delivery_scheme_independent_review_conclusion_addendum.md
  - docs/00_ssot/exhibition_trade_governance_four_documents_bff_backend_contracts_stage_unlock_gate_checklist_addendum.md
  - docs/00_ssot/exhibition_trade_governance_four_documents_backend_truth_stage_gate_checklist_addendum.md
  - docs/00_ssot/exhibition_trade_governance_four_documents_mother_blueprint_v1.md
  - docs/00_ssot/exhibition_trade_governance_four_documents_app_aligned_freeze_v1.md
  - docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md
  - docs/02_backend/fake_project_report_and_adjudication_rules_v1_backend_truth_addendum.md
  - docs/02_backend/contract_archive_and_mandatory_fulfillment_chain_rules_v1_backend_truth_addendum.md
  - docs/02_backend/blacklist_whitelist_and_permanent_ban_rules_v1_backend_truth_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/server/src/modules/**
  - apps/server/src/core/migrations/migrations.ts
---

# 展览项目发布-竞标-履约治理四文书
# Backend D1 Truth-gap Planning Addendum

## 1. Scope

- 本文件只做 `backend D1 truth-gap planning`。
- 本文件不是：
  - backend implementation unlock
  - `apps/server` 实现派工
  - migration authoring
  - deploy
  - release
- 本文件的唯一作用是：
  - 在后续真正 backend bounded implementation prompt 之前
  - 先把四文书后端真值缺口、允许 carrier、禁止 carrier、最小接触层、Admin 真值边界、审计证据最低要求和实施顺序写清楚
- 本文件必须与以下硬边界同时成立：
  - 不把 `openapi.yaml` 的冻结 path 误读成 runtime connected
  - 不把 `apps/server/src/modules` 中的目录存在误读成 wired module
  - 不把 `BFF`、Flutter、Admin 的职责回写到 `Server` truth owner
  - 不新增第二套 identity / organization / permission / certification / governance truth

## 2. Current Backend Evidence Summary

### 2.1 当前已见的 `Server` 连接证据

- 当前 `AppModule` 只导入：
  - `EnterpriseHubModule`
  - `ProjectModule`
  - `UploadModule`
  证据见 [app.module.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/app.module.ts)。
- 当前有实际 handwritten controller / service / entity 落点的主线只集中在：
  - `project`
    - [project.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/project/project.controller.ts)
    - [project-write.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/project/project-write.service.ts)
    - [project-query.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/project/project-query.service.ts)
    - [project.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/project/entities/project.entity.ts)
  - `upload`
    - [upload.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/upload/upload.controller.ts)
    - [upload-write.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/upload/upload-write.service.ts)
    - [upload-storage.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/upload/upload-storage.service.ts)
    - [upload-session.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/upload/entities/upload-session.entity.ts)
    - [file-asset.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/upload/entities/file-asset.entity.ts)
  - `enterprise_hub`
    - [enterprise-hub-truth.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/enterprise_hub/enterprise-hub-truth.controller.ts)
    - [enterprise-hub-admin.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/enterprise_hub/enterprise-hub-admin.controller.ts)
    - [enterprise-hub-write.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts)
    - [enterprise-hub-query.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/enterprise_hub/enterprise-hub-query.service.ts)
    - [enterprise-hub.module.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/enterprise_hub/enterprise-hub.module.ts)
  - `audit`
    - [project-publish-audit.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/audit/project-publish-audit.service.ts)
    - [project-publish-audit-log.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/audit/project-publish-audit-log.entity.ts)
- 当前已挂到源码图中的 controller path family 也只直接可见于：
  - `server/projects`
  - `server/uploads`
  - `server/exhibition/enterprise-hub`
  - `server/admin/exhibition/enterprise-hub`
  证据见 [project.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/project/project.controller.ts)、[upload.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/upload/upload.controller.ts)、[enterprise-hub-truth.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/enterprise_hub/enterprise-hub-truth.controller.ts)、[enterprise-hub-admin.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/enterprise_hub/enterprise-hub-admin.controller.ts)。

### 2.2 当前仅见目录占位、不能视为 wired runtime 的范围

- 当前 [apps/server/src/modules](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules) 下确有目录名：
  - `identity`
  - `organization`
  - `membership`
  - `review`
  - `evidence`
  - `contract`
  - `milestone`
  - `inspection`
  - `order`
  - `bidding`
  - `dispute`
  - `rating`
- 但本轮仓内递归核查到的 handwritten `.ts` 文件仍只落在：
  - `audit`
  - `enterprise_hub`
  - `project`
  - `upload`
  证据见 [apps/server/src/modules](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules) 与 [app.module.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/app.module.ts)。
- 因此本文件明确采用以下读法：
  - 目录存在不等于 module wired
  - source presence 不等于 runtime connected
  - contract frozen 不等于 backend truth 已落代码

### 2.3 当前 migration 证据

- 当前 `serverMigrations` 只由：
  - `enterpriseHubMigrations`
  - `projectPublishCorridorMigrations`
  组成，证据见 [migrations.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/core/migrations/migrations.ts)。
- 当前 migration 已覆盖的主要落地对象仍是：
  - `enterprise_listing` 等 `enterprise_hub` 表族
  - `project`
  - `upload_session`
  - `file_asset`
  - `project_publish_audit_log`
  证据见 [migrations.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/core/migrations/migrations.ts)。
- 当前 migration 未见四文书运行真值所需的以下对象族：
  - `exhibition_report_cases`
  - `governance_penalties`
  - `governance_appeal_cases`
  - `governance_whitelist_memberships`
  - `governance_permanent_bans`
  - 四文书专属的 `contracts / milestones / inspections / evidences / audit_logs` 最小闭环增量
  证据仍见 [migrations.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/core/migrations/migrations.ts)。

### 2.4 当前冻结 path 与当前 runtime source 的缺口

- 当前 `openapi.yaml` 已冻结：
  - `profile` / `certification` path family
  - `profile/governance` path family
  - `exhibition/report` path family
  - `contract` / `milestone` / `inspection` path family
  - `server/admin/reviews/organizations/*`
  - `server/admin/governance/*`
  - `server/admin/exhibition/report-cases/*`
  证据见 [openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)。
- 但当前仓内 `Server` 真实挂线证据还未显示这些四文书 controller family 已接入 [app.module.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/app.module.ts)。
- 这意味着当前必须显式区分：
  - backend truth 文书已冻结
  - backend runtime truth 仍未形成闭环

## 3. Four-package Backend Truth-gap Inventory

### 3.1 Package 1: 账户与企业认证

| 项 | 当前规划结论 |
| --- | --- |
| 当前已有 backend truth 载体 | 冻结文书已把当前 canonical carrier 绑定到 `users / user_identities / sessions / organizations / organization_members / organization_certifications / organization_invitations / login_otp_codes / devices / security_events / audit_logs / file_assets`，证据见 [account_and_enterprise_certification_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md) |
| 当前 repo 已见运行证据 | `Server` 当前未见 dedicated `identity / organization / membership / certification review` handwritten module family；当前只见 `enterprise_hub` 的企业展示侧对象，并不能替代认证真值，证据见 [apps/server/src/modules](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules)、[enterprise-hub.module.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/enterprise_hub/enterprise-hub.module.ts)、[app.module.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/app.module.ts) |
| 当前缺失的 truth carrier | 不是新 identity 表，而是后续必须补齐：基于现有 truth family 的 profile/certification controller family、organization review admin family、derived eligibility service、certification audit/evidence binding |
| 当前禁止新增的 truth family | `real_identity_profiles`、`enterprise_certifications`、`qualification_assets`、`cert_review_tasks`、`eligibility_snapshots`、`responsible_person_profiles`，证据见 [account_and_enterprise_certification_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md) |
| 当前允许新增的 dedicated carrier | 本轮 planning 不批准新 dedicated 表；后续实现准备只能围绕现有 identity/org/certification truth family 与 derived eligibility 补齐 |

### 3.2 Package 2: 假项目举报与裁决

| 项 | 当前规划结论 |
| --- | --- |
| 当前已有 backend truth 载体 | 冻结文书已允许复用 `projects / bids / contracts / inspections / organizations / review_tasks / audit_logs / file_assets / evidences`，并只新增一个 dedicated case carrier：`exhibition_report_cases`，证据见 [fake_project_report_and_adjudication_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/fake_project_report_and_adjudication_rules_v1_backend_truth_addendum.md) |
| 当前 repo 已见运行证据 | 仅 `project` 与 shared `upload/file_asset` 已有 handwritten source；未见 report-case / review-task / evidence runtime family，证据见 [project.module.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/project/project.module.ts)、[upload.module.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/upload/upload.module.ts)、[apps/server/src/modules](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules) |
| 当前缺失的 truth carrier | 后续必须补齐：`exhibition_report_cases` entity/repository/module、report submit controller family、admin report-case adjudication family、restriction overlay consumption、review-task binding、evidence linkage、append-only audit |
| 当前禁止新增的 truth family | `report_evidences`、`risk_freeze_actions`、`explanation_submissions`、`adjudication_records`、`refund_actions`、`case_notifications`、`case_audit_logs`、第二套 report-local ticket table，证据见 [fake_project_report_and_adjudication_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/fake_project_report_and_adjudication_rules_v1_backend_truth_addendum.md) |
| 当前允许新增的 dedicated carrier | 仅 `exhibition_report_cases` |

### 3.3 Package 3: 合同归档与履约强制入链

| 项 | 当前规划结论 |
| --- | --- |
| 当前已有 backend truth 载体 | 冻结文书已把 canonical family 绑定到 `orders / contracts / contract_clauses / milestones / inspections / change_orders / ratings / disputes / evidences / file_assets / audit_logs`，证据见 [contract_archive_and_mandatory_fulfillment_chain_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/contract_archive_and_mandatory_fulfillment_chain_rules_v1_backend_truth_addendum.md) |
| 当前 repo 已见运行证据 | 当前 `Server` 代码未见 `contract / milestone / inspection / order / evidence / dispute / rating` handwritten files进入 runtime 连接；shared `file_asset` 与 corridor audit 已存在，但不能替代合同履约闭环，证据见 [apps/server/src/modules](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules)、[upload.module.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/upload/upload.module.ts)、[project-publish-audit.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/audit/project-publish-audit.service.ts) |
| 当前缺失的 truth carrier | 后续必须补齐：order-bound contract controller/service family、milestone continuity family、inspection continuity family、archive-dependent derived gating、object-bound evidence linkage、fulfillment audit writer |
| 当前禁止新增的 truth family | `contract_versions`、`contract_confirmations`、`daily_progress_logs`、`acceptance_archives`、`archive_exports`、`rectification_items`，证据见 [contract_archive_and_mandatory_fulfillment_chain_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/contract_archive_and_mandatory_fulfillment_chain_rules_v1_backend_truth_addendum.md) |
| 当前允许新增的 dedicated carrier | 当前 round 不批准这组新 dedicated 表；后续实现准备只能围绕现有 `contracts / milestones / inspections / evidences / file_assets / audit_logs` 的最小链补齐 |

### 3.4 Package 4: 黑白名单 / 永久封禁 / 申诉

| 项 | 当前规划结论 |
| --- | --- |
| 当前已有 backend truth 载体 | 冻结文书已允许复用 `organizations / organization_members / review_tasks / audit_logs / security_events / file_assets / evidences`，并只批准四个 governance overlay carrier：`governance_penalties`、`governance_appeal_cases`、`governance_whitelist_memberships`、`governance_permanent_bans`，证据见 [blacklist_whitelist_and_permanent_ban_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/blacklist_whitelist_and_permanent_ban_rules_v1_backend_truth_addendum.md) |
| 当前 repo 已见运行证据 | 当前 `Server` 运行代码未见 governance app-side summary、appeal submit、admin penalty/appeal/whitelist/permanent-ban controller family；现有 admin source 只见 `enterprise_hub`，证据见 [apps/server/src/modules](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules)、[enterprise-hub-admin.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/enterprise_hub/enterprise-hub-admin.controller.ts)、[app.module.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/app.module.ts) |
| 当前缺失的 truth carrier | 后续必须补齐：governance penalty write/query/admin family、appeal-case family、whitelist/permanent-ban admin family、derived governance summary read、governance audit/evidence linkage |
| 当前禁止新增的 truth family | `trust_levels`、`trust_snapshots`、`ban_relations`、`governance_status_snapshots`、`penalty_history_views`、`appeal_chat_threads`、`public_blacklist_directory`、`public_whitelist_directory`，证据见 [blacklist_whitelist_and_permanent_ban_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/blacklist_whitelist_and_permanent_ban_rules_v1_backend_truth_addendum.md) |
| 当前允许新增的 dedicated carrier | 仅 `governance_penalties`、`governance_appeal_cases`、`governance_whitelist_memberships`、`governance_permanent_bans` |

## 4. Allowed D1 Truth Carriers Only

### 4.1 D1 允许进入后续实现准备的 carrier

| 领域 | D1 允许的 truth carrier |
| --- | --- |
| account / certification / eligibility | `users`、`user_identities`、`sessions`、`organizations`、`organization_members`、`organization_certifications`、`organization_invitations`、`login_otp_codes`、`devices`、`security_events`、`audit_logs`、`file_assets`，以及基于这些 truth 的 derived eligibility，证据见 [account_and_enterprise_certification_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md) |
| fake-project report | `projects`、`bids`、`contracts`、`inspections`、`organizations`、`review_tasks`、`audit_logs`、`file_assets`、`evidences`、`exhibition_report_cases`，证据见 [fake_project_report_and_adjudication_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/fake_project_report_and_adjudication_rules_v1_backend_truth_addendum.md) |
| contract / archive / fulfillment | `orders`、`contracts`、`contract_clauses`、`milestones`、`inspections`、`change_orders`、`ratings`、`disputes`、`evidences`、`file_assets`、`audit_logs`，其中 D1 只准规划最小 contract / milestone / inspection / archive-dependent gating 主线，不准借机扩成 full trade suite，证据见 [contract_archive_and_mandatory_fulfillment_chain_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/contract_archive_and_mandatory_fulfillment_chain_rules_v1_backend_truth_addendum.md) |
| blacklist / whitelist / permanent-ban / appeal | `organizations`、`organization_members`、`review_tasks`、`audit_logs`、`security_events`、`file_assets`、`evidences`、`governance_penalties`、`governance_appeal_cases`、`governance_whitelist_memberships`、`governance_permanent_bans`，证据见 [blacklist_whitelist_and_permanent_ban_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/blacklist_whitelist_and_permanent_ban_rules_v1_backend_truth_addendum.md) |

### 4.2 仍然只是 product wording、当前不允许直接落表的对象

| 领域 | 当前不允许直接落表的对象 |
| --- | --- |
| account / certification / eligibility | `real_identity_profiles`、`enterprise_certifications`、`qualification_assets`、`cert_review_tasks`、`eligibility_snapshots`、`responsible_person_profiles`，以及 `U0/U1/U2/U3` 这类 governance label，证据见 [account_and_enterprise_certification_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md)、[exhibition_trade_governance_four_documents_app_aligned_freeze_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_app_aligned_freeze_v1.md) |
| fake-project report | `report_evidences`、`risk_freeze_actions`、`explanation_submissions`、`adjudication_records`、`refund_actions`、`case_notifications`、`case_audit_logs`，证据见 [fake_project_report_and_adjudication_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/fake_project_report_and_adjudication_rules_v1_backend_truth_addendum.md) |
| contract / archive / fulfillment | `contract_versions`、`contract_confirmations`、`daily_progress_logs`、`acceptance_archives`、`archive_exports`、`rectification_items`，证据见 [contract_archive_and_mandatory_fulfillment_chain_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/contract_archive_and_mandatory_fulfillment_chain_rules_v1_backend_truth_addendum.md) |
| blacklist / whitelist / permanent-ban / appeal | `trust_levels`、`trust_snapshots`、`ban_relations`、`governance_status_snapshots`、`penalty_history_views`、`appeal_chat_threads`、`public_blacklist_directory`、`public_whitelist_directory`，证据见 [blacklist_whitelist_and_permanent_ban_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/blacklist_whitelist_and_permanent_ban_rules_v1_backend_truth_addendum.md) |

## 5. Planned Backend Touch Set

| 层 | 当前是否存在 | 后续是否必须补 | 为什么必须补 |
| --- | --- | --- | --- |
| controller family | 当前只见 `project / upload / enterprise_hub` controller family，证据见 [project.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/project/project.controller.ts)、[upload.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/upload/upload.controller.ts)、[enterprise-hub-truth.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/enterprise_hub/enterprise-hub-truth.controller.ts)、[enterprise-hub-admin.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/enterprise_hub/enterprise-hub-admin.controller.ts) | 必须补 | `openapi.yaml` 已冻结 `profile/certification`、`exhibition/report`、`contract/milestone/inspection`、`profile/governance`、`server/admin/governance`、`server/admin/exhibition/report-cases` path family，但当前 `Server` 未见相应 truth controllers，证据见 [openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)、[app.module.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/app.module.ts) |
| service family | 当前只见 `project write/query`、`upload write/storage`、`enterprise_hub write/query/admin`、`project publish audit`，证据见 [apps/server/src/modules](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules) | 必须补 | 四文书 state responsibility 明确属于 `Server`；没有 package-specific write/query/admin services，就无法承载 derived eligibility、report-case state、contract/inspection state、governance overlays，证据见四份 [docs/02_backend](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend) 文书 |
| persistence family | 当前 migration 与 entity 只落在 `enterprise_hub / project / upload / corridor audit`，证据见 [migrations.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/core/migrations/migrations.ts)、[apps/server/src/modules](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules) | 必须补 | 后续实现必须只在允许 carrier 范围内补实体与迁移计划，否则 frozen backend truth 无法变成 runtime truth |
| audit writer | 当前只见 corridor 级 append-only 审计 writer：[project-publish-audit.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/audit/project-publish-audit.service.ts) | 必须补 | 四文书都要求 must-audit；认证审核、举报裁决、合同履约推进、处罚与申诉都不能复用“无对象边界”的模糊日志 |
| evidence linkage | 当前 shared upload + `FileAsset` truth 已存在，证据见 [upload-write.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/upload/upload-write.service.ts)、[file-asset.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/upload/entities/file-asset.entity.ts) | 必须补 | 四文书都要求 evidence object-bound；后续必须把 certification、report、contract、inspection、governance action 与 `FileAsset / Evidence` 绑定，而不是回退到 `objectKey` 或 raw URL |
| admin truth endpoints | 当前 admin source 只见 `enterprise_hub` admin family，证据见 [enterprise-hub-admin.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/enterprise_hub/enterprise-hub-admin.controller.ts) | 必须补 | `Admin` 必须直连 `Server Admin` 真值接口；认证审核、举报裁决、处罚生效、申诉复核、白名单与永久封禁都不能停留在文书或 `BFF` 层，证据见 [openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)、[AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md) |

## 6. D1 Minimal Sequence

### 6.1 D1-A: Package 1 先行

- 前置条件：
  - 继续服从 [exhibition_trade_governance_four_documents_backend_truth_stage_gate_checklist_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_backend_truth_stage_gate_checklist_addendum.md) 的 docs-only 边界
  - 继续承认 Package 1 不批准任何新 dedicated identity table
- 非目标：
  - full real-name registry
  - second certification truth
  - risk center runtime
- 风险：
  - 把 `enterprise_hub` 的企业展示快照误当认证真值
  - 把 `organizations.status` 和 `organization_certifications.certification_status` 混成一列
  - 过早引入 `eligibility_snapshots`
- 完成标志：
  - 后续实现 prompt 已能明确：Package 1 只基于现有 truth family 补 controller/service/audit/evidence/derived eligibility，不扩新表族

### 6.2 D1-B: Package 2 第二刀

- 前置条件：
  - D1-A 已把 actor / organization / certification / admin review baseline 边界锁清楚
  - `project` 仍是当前唯一已见业务锚点之一，证据见 [project.module.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/project/project.module.ts)
- 非目标：
  - public report center
  - user-side report history center
  - penalty tree 全量放开
- 风险：
  - 把 `forum report` 混成 `exhibition fake-project report`
  - 直接改写 `projects.status` 等对象主状态去承载 restriction
  - 违规新增 `report_evidences` 或 `adjudication_records`
- 完成标志：
  - 后续实现 prompt 已能明确：Package 2 只引入 `exhibition_report_cases`，并复用 `review_tasks / audit_logs / file_assets / evidences`

### 6.3 D1-C: Package 3 第三刀

- 前置条件：
  - D1-A 与 D1-B 已先锁清 subject truth、shared evidence truth、review/audit discipline
  - 继续服从 publish-board freeze，不把 D1 planning 写成 trade full unlock，证据见 [exhibition_trade_governance_four_documents_delivery_scheme_stage_gate_checklist_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_delivery_scheme_stage_gate_checklist_addendum.md)
- 非目标：
  - daily progress
  - archive export
  - final acceptance archive
  - dispute / rating runtime 扩面
- 风险：
  - 发明第二套 contract workflow
  - 把 archive readiness 写成 `BFF` 或 Flutter 猜测
  - 误以为空目录 `contract / milestone / inspection` 已代表 connected runtime
- 完成标志：
  - 后续实现 prompt 已能明确：Package 3 只围绕现有 `orders / contracts / milestones / inspections / evidences / file_assets / audit_logs` 形成最小真值链，不落禁表

### 6.4 D1-D: Package 4 最后补

- 前置条件：
  - D1-A 已锁 subject scope
  - D1-B 已锁 report/review handoff
  - Package 4 继续被定义为 governance overlay，而不是第二套身份权限系统
- 非目标：
  - trust score engine
  - public blacklist / whitelist directory
  - permanent-ban appeal
  - linked-subject ban network
- 风险：
  - 用 penalty 替代 membership / organization truth
  - 额外加 `governance_status_snapshots`
  - 把 whitelist 写成 permission bypass
- 完成标志：
  - 后续实现 prompt 已能明确：Package 4 只允许四个 overlay carrier + derived governance summary，不扩 trust/ban 侧新表族

## 7. Admin Ownership Boundary

- 下列动作必须留在 `Server Admin` 真值边界内，不能放到 `BFF`、Flutter、Admin 本地状态或注释流程里：
  - 认证审核
    - 组织认证 approve / reject
    - 组织 draft -> active 的耦合触发
    - 对应冻结基线见 [account_and_enterprise_certification_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md) 与 [openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)
  - 举报裁决
    - `request-explanation`
    - `decide`
    - `escalate`
    - 对应冻结基线见 [fake_project_report_and_adjudication_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/fake_project_report_and_adjudication_rules_v1_backend_truth_addendum.md) 与 [openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)
  - 处罚生效
    - penalty create / lift / expire-effect
    - blacklist / watchlist / restrict_publish / restrict_bid 只能由 `Server` 生效
    - 对应冻结基线见 [blacklist_whitelist_and_permanent_ban_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/blacklist_whitelist_and_permanent_ban_rules_v1_backend_truth_addendum.md)
  - 申诉复核
    - appeal submit 之后的 review / decide / modify / revoke
    - 不能用前端对话或客服备注替代
  - 白名单与永久封禁
    - whitelist membership create / revoke
    - permanent ban create
    - 都必须保持 `Server` append-only / controlled mutation discipline
- 当前 `Admin` 的边界仍是：
  - consume `Server Admin API` directly
  - not become truth owner
  证据见 [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md)、[apps/server/AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/AGENTS.md)、[openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)。

## 8. Audit / Evidence Minimum

- 后续 backend 实现前，以下留痕字段必须作为四文书共通最低要求固定：
  - 谁操作：
    - `actorId`
    - `userId`
    - `organizationId`
    - `reviewer/admin operator` attribution where applicable
  - 操作对象：
    - `aggregateType`
    - `aggregateId`
    - `sourceObjectType`
    - `sourceObjectId`
  - 时间：
    - `createdAt`
    - `submittedAt`
    - `decidedAt`
    - `effectiveFrom / effectiveUntil / closedAt` where applicable
  - 前后状态：
    - before state
    - after state
    - decision / restriction / certification / governance result fields
  - 关联文件或证据：
    - 必须走 `FileAsset`
    - 需要 object-bound `Evidence` linkage
    - `objectKey` 不能作为 business truth
  - 申诉入口或复核链：
    - 有处罚就必须可回溯到 appeal or review chain
    - 有举报就必须可回溯到 review / escalation chain
- D1 后续实现准备至少要为以下动作冻结 must-audit 口径：
  - certification submit / approve / reject
  - fake-project report submit / restriction apply / explanation request / adjudication decide / escalation
  - contract confirm / amend
  - milestone submit / inspection submit / inspection recheck / downstream completion derivation
  - penalty create / lift / expire
  - appeal submit / decide
  - whitelist membership create / revoke
  - permanent ban create

## 9. Explicit Non-goals

- 本轮不做：
  - controller 实现
  - service 实现
  - entity 实现
  - migration 实现
  - 接口联调
  - deploy
  - release 叙述
- 本轮也不做：
  - 修改 `apps/server/**`
  - 修改 `apps/bff/**`
  - 修改 `apps/mobile/**`
  - 修改 `apps/admin/**`
  - 改写四份 `docs/02_backend/*_v1_backend_truth_addendum.md` 的既有冻结主体
- 本轮明确不允许借 planning 名义偷渡：
  - 新裸路径家族
  - 第二套 identity / organization / permission / governance truth
  - “source presence = runtime connected”的夸大口径

## 10. Next Backend Prompt Prerequisites

### 10.1 下一条真正 backend implementation prompt 之前必须满足

- 总控确认：
  - 当前 planning addendum 已被接受为 implementation-prep 输入
  - 后续 prompt 仍受 [exhibition_trade_governance_four_documents_delivery_scheme_stage_gate_checklist_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_delivery_scheme_stage_gate_checklist_addendum.md) 约束
- 作用域确认：
  - 下一条 prompt 必须继续显式限定到 `apps/server/**`
  - 必须说明是单包还是多包 bounded implementation
  - 必须重申允许 / 禁止 carrier 清单
- 运行边界确认：
  - 是否允许 author migration 文件
  - 是否只允许 code-level verification
  - 是否禁止 deploy / release
- 审计证据确认：
  - 对应 package 的 must-audit family 和 evidence linkage 已被总控接受
- Admin 边界确认：
  - admin action family 仍只在 `/server/admin/*`
  - `Admin` 继续直接消费 `Server Admin API`

### 10.2 已可直接作为下一条 prompt 输入的内容

- 四份 backend truth 文书：
  - [account_and_enterprise_certification_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md)
  - [fake_project_report_and_adjudication_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/fake_project_report_and_adjudication_rules_v1_backend_truth_addendum.md)
  - [contract_archive_and_mandatory_fulfillment_chain_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/contract_archive_and_mandatory_fulfillment_chain_rules_v1_backend_truth_addendum.md)
  - [blacklist_whitelist_and_permanent_ban_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/blacklist_whitelist_and_permanent_ban_rules_v1_backend_truth_addendum.md)
- 当前代码证据：
  - [app.module.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/app.module.ts)
  - [apps/server/src/modules](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules)
  - [migrations.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/core/migrations/migrations.ts)
- 当前 contracts/path constitution：
  - [openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)
- 本 planning addendum：
  - 明确了 allowed carriers
  - 明确了 forbidden carriers
  - 明确了 D1 最小顺序
  - 明确了 Admin / audit / evidence 最低边界

### 10.3 仍缺总控签批的内容

- 真正 implementation unlock
- migration package authoring 放行
- BFF aggregation stage unlock
- Flutter / Admin consumption stage unlock
- deploy / release-prep / release execution

## 11. Planning Conclusion

- 当前四文书 backend truth 文书已冻结，但 backend runtime truth 仍未形成对应闭环。
- 后续 backend D1 实施前，必须先严格接受以下规划边界：
  - 只在允许 carrier 内施工
  - 不把产品词汇直接落成未批准新表
  - 先补 Package 1，再补 Package 2，再补 Package 3，最后补 Package 4
  - Admin action、audit、evidence、appeal/review chain 必须在 `Server` 真值边界内一次写清
- 若未先接受这些边界，下一条 backend prompt 仍不应进入实现口令。
