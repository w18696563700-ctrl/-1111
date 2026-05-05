---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the default posture initialization and backfill boundary for current
  `我的信用与约束 V2.1`, so approved active organizations do not fail the
  bounded read surface only because the three Server-owned posture rows are
  missing.
layer: L0 SSOT
freeze_date_local: 2026-05-05
inputs_canonical:
  - AGENTS.md
  - apps/server/AGENTS.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/my_building_v21_credit_deposit_transaction_guarantee_implementation_unlock_addendum.md
  - docs/00_ssot/order_rating_driven_org_credit_scoring_current_v21_non_pollution_verification_addendum_v1.md
  - docs/01_contracts/credit_deposit_transaction_guarantee_v1_contracts_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/02_backend/credit_deposit_transaction_guarantee_v1_backend_truth_addendum.md
  - docs/03_bff/credit_deposit_transaction_guarantee_v1_bff_surface_addendum.md
  - docs/04_frontend/credit_deposit_transaction_guarantee_v1_frontend_surface_addendum.md
  - apps/server/src/modules/credit_constraints/credit-constraints.query.service.ts
  - apps/server/src/modules/profile/profile-certification-write.service.ts
---

# 我的信用与约束 V2.1 Default Posture Initialization Stage Gate Addendum

## 1. 总裁决

- Gate 0：`PASS WITH EXISTING DIRTY WORKTREE RISK`。
- Gate 1：`PASS`。
- Day 2 允许进入：`Yes, Server-only bounded implementation`。

本文件只冻结默认 posture 初始化与历史 backfill 边界。它不改写
`我的信用与约束 V2.1` 的现有 route family，不新增 App-facing OpenAPI，不打开
payment、billing、settlement、refund、invoice、wallet、dispute、governance
console 或真实信用评分引擎。

## 2. Gate 0 Read-only Scan

### 2.1 已存在

- `Server` 已有三类 current posture truth carrier：
  - `organization_credit_constraint_postures`
  - `organization_deposit_postures`
  - `organization_transaction_guarantee_postures`
- `Server` 已有 bounded read surface：
  - `GET /server/profile/credit-and-constraints/status`
  - `GET /server/profile/credit-and-constraints/explanation`
  - `GET /server/profile/credit-and-constraints/handoff`
- `BFF` 已有 app-facing read surface：
  - `GET /api/app/profile/credit-and-constraints/status`
  - `GET /api/app/profile/credit-and-constraints/explanation`
  - `GET /api/app/profile/credit-and-constraints/handoff`
- `Flutter App` 已有 fail-closed consumption：缺少可读 posture 时显示
  `我的信用与约束当前暂不可用`。

### 2.2 当前缺口

- 认证通过并处于 active 的组织并不自动拥有三类 posture rows。
- 认证提交 / 重提路径当前只写：
  - `organizations`
  - `organization_certifications`
  - `audit_logs`
  - enterprise-display certification sync
- 未发现认证通过后自动创建三类 posture rows 的 Server 写入路径。

### 2.3 云端只读抽样事实

- 通过 `127.0.0.1:8080` 隧道读取云端 runtime，BFF / Server health 均已
  可达。
- 云端 approved active organizations 抽样统计：
  - approved active organization count：`84`
  - complete posture organization count：`1`
  - missing posture organization count：`83`
- 正常样本组织三类 posture rows 完整。
- 异常样本组织已是 `active` / `approved`，但三类 posture rows 均缺失。

### 2.4 Dirty Worktree Risk

当前工作区已有非本轮变更：

- `docs/00_ssot/source_of_truth_map.md`
- `docs/01_contracts/openapi.yaml`
- `packages/contracts/contracts-manifest.json`
- `packages/contracts/openapi/openapi.bundle.json`
- `docs/00_ssot/stale_notification_route_target_availability_v1_truth_freeze_addendum.md`
- `docs/01_contracts/stale_notification_route_target_availability_v1_contracts_addendum.md`

本轮不得覆盖或回退上述变更。若登记本文件到 `source_of_truth_map.md`，只能追加
本文件索引，不得改写既有 stale-notification 变更。

## 3. Gate 1 Truth And Contract Freeze

### 3.1 当前最小闭环

对符合条件的组织创建缺失的 V2.1 posture rows，使现有
`/api/app/profile/credit-and-constraints/*` read surface 能返回 bounded
content，而不是因为缺少姿态 carrier 进入 unavailable。

### 3.2 需要保留但暂不开通

- 不开通真实信用评分。
- 不开通风险分、等级、扣分、恢复、申诉。
- 不开通保证金缴纳、冻结、扣罚、赔付、退款、结算。
- 不开通交易保障案件、争议裁定、治理后台操作。
- 不开通新的 BFF / Flutter route family。

### 3.3 后续扩展位

- 后续可将默认 posture 初始化接入更细粒度的治理规则。
- 后续可将真实评分主线继续保持在
  `organization-credit-scoring` reserve family，不污染当前 V2.1。
- 后续可增加 dashboard / Admin report，只读统计 posture completeness。

## 4. Backfill Eligibility

### 4.1 会被补齐的组织

组织必须同时满足：

1. `organizations.status = active`
2. 最新 `organization_certifications.certification_status = approved`
3. 至少一个 active member：
   - `organization_members.member_status = active`
4. 缺少以下任一 row：
   - `organization_credit_constraint_postures`
   - `organization_deposit_postures`
   - `organization_transaction_guarantee_postures`

### 4.2 不会被补齐的组织

任一条件命中即不得补齐：

- 无组织账号。
- `organizations.status != active`。
- 无最新 approved organization certification。
- `organization_certifications.certification_status` 为
  `not_submitted` / `pending_review` / `rejected` / `expired`。
- 没有 active member。
- 当前已存在的 posture row，不得覆盖。
- 任何治理封禁、永久封禁、黑名单等需要单独规则冻结的组织，不在本轮扩大处理。

## 5. Default Posture Field Table

### 5.1 Credit Constraint Default

| 字段 | 默认值 |
| --- | --- |
| `credit_constraint_status` | `clear` |
| `performance_constraint_status` | `clear` |
| `execution_availability_status` | `available` |
| `restriction_reason_code` | `null` |
| `advisory_reason_code` | `null` |
| `explanation_key` | `credit_clear` |
| `handoff_key` | `credit_readonly_no_action` |
| `dependency_key` | `v22_payment_billing_required` |

### 5.2 Deposit Posture Default

| 字段 | 默认值 |
| --- | --- |
| `requirement_status` | `required` |
| `eligibility_status` | `eligible` |
| `restriction_status` | `clear` |
| `deposit_posture_status` | `handoff_required` |
| `handoff_key` | `deposit_open_payment_dependency` |
| `dependency_key` | `v22_payment_billing_required` |

### 5.3 Transaction Guarantee Default

| 字段 | 默认值 |
| --- | --- |
| `eligibility_status` | `eligible` |
| `restriction_status` | `clear` |
| `explanation_key` | `transaction_guarantee_dependency_required` |
| `handoff_key` | `transaction_guarantee_open_dependency` |
| `dependency_key` | `v22_payment_billing_required` |

## 6. Implementation Boundary

### 6.1 Server-only Go

允许：

- 新增 `CreditConstraintsPostureInitializationService`。
- 实现 `ensureDefaultPosturesForApprovedOrganization(organizationId)`。
- 认证通过路径在 `approved` 后调用该初始化服务。
- 新增 dry-run-first backfill tooling。
- 新增 targeted tests。

### 6.2 No-Go

禁止：

- Flutter 伪造默认 posture。
- BFF 生成或持久化 posture truth。
- 修改 `/api/app/profile/credit-and-constraints/*` contract。
- 改写 current `organization-credit-scoring` future-mainline reserve。
- 覆盖已有 posture rows。
- 对未认证或非 active 组织写入默认 posture。

## 7. Contract Freeze

本轮 OpenAPI 裁决：

- `No OpenAPI change required`。
- `GET /api/app/profile/credit-and-constraints/status`
  / `explanation` / `handoff` 保持不变。
- 新增的初始化 service 与 backfill tooling 均为 Server 内部能力，不构成
  App-facing contract。
- 现有 `docs/01_contracts/openapi.yaml` dirty diff 属于其他通知路由任务；
  本轮不得覆盖或追加 credit-and-constraints contract diff。

## 8. Rollback And Audit Strategy

### 8.1 Dry-run First

历史 backfill 默认必须 dry-run，输出：

- candidate organization count
- missing posture family count
- masked organization ref
- missing families
- execute command preview

不得输出：

- 手机号
- password / token / cookie
- DB connection string
- private key
- full organization id list in chat

### 8.2 Execute Gate

只有 dry-run receipt 经总控确认后，才允许使用显式 execute 开关写入云端。

### 8.3 Idempotency

- 已存在 row：不覆盖。
- 缺哪张补哪张。
- 重复执行不新增重复 row。
- 依赖唯一索引：
  - `idx_organization_credit_constraint_postures_org`
  - `idx_organization_deposit_postures_org`
  - `idx_organization_transaction_guarantee_postures_org`

### 8.4 Rollback

回滚只允许删除本次 run 新增的 rows，不得删除历史已有 posture rows。
execute receipt 必须保留本次新增对象的 masked refs 与 run id，供回滚定位。

### 8.5 Audit

允许使用 append-only execution receipt 记录本次 run。若写入 `audit_logs`，
只能记录：

- object type：`credit_constraints_default_posture`
- action：`CreditConstraintsDefaultPostureInitialized`
- before state：`missing`
- after state：`initialized`
- reason：run id 与 missing families

不得写入敏感字段。

## 9. Day-2 Entry Decision

Day 2 允许进入：

- `Server-only default posture initialization`
- `Targeted tests`

Day 2 不允许进入：

- 云端写入
- deploy
- service restart
- migration command
- App-facing contract change
- Flutter / BFF behavior change

正式结论：

- 更稳：规则冻结 + Server 初始化机制 + 历史 backfill + 云端 receipt。
- 更省成本：只做一次历史 backfill，但未来新增组织仍可能再漏。
- 更适合当前阶段：Server 最小初始化机制 + dry-run-first backfill。
- 风险更大：只补单个账号，或在 Flutter / BFF 伪造默认 posture。
