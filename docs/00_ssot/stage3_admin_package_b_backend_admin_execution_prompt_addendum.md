---
owner: Codex 总控
status: frozen
purpose: Freeze the execution-dispatch prompt for stage3 package B, limited to the minimal Admin/Server exhibition report-case desk under the /project_review seat.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/stage3_admin_package_b_controller_review_conclusion_addendum.md
  - docs/00_ssot/project_permission_and_state_unified_ruling_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/01_contracts/fake_project_report_and_adjudication_rules_v1_contracts_addendum.md
  - docs/02_backend/fake_project_report_and_adjudication_rules_v1_backend_truth_addendum.md
  - docs/03_bff/fake_project_report_and_adjudication_rules_v1_bff_surface_addendum.md
  - docs/05_admin/admin_governance_surface_matrix.md
---

# 《阶段3 package B backend/admin execution prompt》

## 1. 角色与目标

- 你现在是：
  - `阶段 3｜Admin 最小运营与治理闭环`
  - `package B backend/admin owner`
- 你的唯一目标是：
  - 在 `/project_review` 座位上收口 `exhibition report-cases` 最小案件台
  - 让 `Admin` 直连 `Server Admin API` 形成：
    - queue
    - detail
    - request explanation
    - decide
    - escalate
    的最小闭环

## 2. 本轮只做

- 本轮只允许做：
  - `Server` exhibition report-case truth/controller/service 最小实现
  - `Admin` `/project_review` 消费与动作最小闭环
  - `admin-api-client` 对 `report-cases*` 的最小 transport
  - 与上述对象直接相关的最小测试

## 3. 本轮不做

- 本轮明确不做：
  - 泛化 `project review state machine`
  - “项目审核通过后发布”
  - `template_config`
  - `audit`
  - `ticketing`
  - user-side report history
  - app-facing report detail center
  - `BFF` 介入 `Admin`
  - `release / deploy`

## 4. 允许修改范围

- 只允许修改：
  - `apps/admin/src/app/project_review/**`
  - `apps/admin/src/modules/project_review/**`
  - `apps/admin/src/core/server/admin-api-client.ts`
  - 与上述对象直接相关的最小 `apps/admin` tests
  - `apps/server/src/modules/**` 中与 `exhibition_report_cases` 直接相关的最小模块族
  - 如确有必要，可做最小 migration / module wiring / controller wiring / test wiring
- 不允许修改：
  - `apps/mobile/**`
  - `apps/bff/**`
  - `apps/admin/src/modules/template_config/**`
  - `apps/admin/src/modules/audit/**`
  - `apps/admin/src/modules/ticketing/**`
  - 与本轮无关的 `apps/server` 业务域

## 5. 你必须完成

1. `Server` 必须 materialize 以下 admin path family：
   - `GET /server/admin/exhibition/report-cases`
   - `GET /server/admin/exhibition/report-cases/{reportCaseId}`
   - `POST /server/admin/exhibition/report-cases/{reportCaseId}/request-explanation`
   - `POST /server/admin/exhibition/report-cases/{reportCaseId}/decide`
   - `POST /server/admin/exhibition/report-cases/{reportCaseId}/escalate`
2. `Admin` `/project_review` 必须消费并驱动以上 path family。
3. `/project_review` 页面语义必须明确为：
   - report-case queue / detail / adjudication desk
   - 不得继续暗示为 project publish review state machine
4. 当前最小 detail 至少要稳定承接：
   - `reportCaseId`
   - `targetType`
   - `targetId`
   - `reasonCode`
   - `reasonDetail`
   - `status`
   - `temporaryRestrictionState`
   - `reviewTaskId`
   - `governanceTicketId`
   - `submittedAt`
   - `explanationRequestedAt`
   - `explanationReceivedAt`
   - `adjudicationResult`
   - `decidedAt`
   - `decisionNote`
5. 所有动作仍必须：
   - 直连 `Server`
   - 保持审计归因
   - 不经 `BFF`

## 6. 你必须遵守

1. 不得发明项目审核状态机。
2. 不得让 `/project_review` 承担“审核通过后发布”的虚假语义。
3. 不得把本包扩写成：
   - penalty full tree
   - whitelist / permanent-ban
   - generic audit search
   - ticket routing console
4. 不得创建第二案件台真源。
5. 不得绕过审计。

## 7. 最小测试要求

1. `Server` 侧至少覆盖：
   - queue list
   - detail
   - request-explanation
   - decide
   - escalate
2. `Admin` 侧至少覆盖：
   - `/project_review` route guard under the existing session carrier
   - admin-api-client report-cases transport
   - minimal queue/detail/action consumption

## 8. 完成标准

- `/project_review` 不再只是 placeholder。
- `Server` 与 `Admin` 在同一 `report-cases` path family 上形成最小闭环。
- 当前 package-B 仍保持：
  - bounded
  - 不经 `BFF`
  - 不偷扩成 generic project review state machine

## 9. 交付回执要求

1. 修改文件清单
2. 为什么 `/project_review` 当前不能被理解为项目审核状态机
3. 当前如何把 `/project_review` 收口成 report-cases desk
4. `Server` 和 `Admin` 各自的最小闭环证据
5. 新增或更新的测试结果
6. 仍未覆盖的非目标清单
