---
owner: Codex 总控
status: frozen
purpose: Record the cloud runtime deployment and verification receipt for project authenticity sincerity internal-test no-freeze policy and freeze-feedback statistics.
layer: L0 SSOT
freeze_date_local: 2026-05-02
inputs_canonical:
  - docs/00_ssot/project_authenticity_sincerity_internal_test_no_freeze_boundary_freeze_addendum.md
  - docs/01_contracts/project_authenticity_sincerity_internal_test_no_freeze_contract_addendum.md
  - docs/00_ssot/current_cloud_deploy_rollback_procedure_baseline_addendum.md
---

# 《项目真实性诚意金内测暂不冻结云端发布与验收回执》

## 1. Scope

本回执只覆盖：

- Server 内测暂不冻结发布门禁。
- Server 反馈统计表 additive migration。
- BFF App-facing 反馈接口与 pricing summary 透传。
- Flutter 对 `internal_test_no_freeze_required` / `internal_test_no_freeze_allowed` 的展示消费。
- 8080 隧道只读 / 真实测试账号接口验证。

本回执不覆盖：

- 真实支付宝冻结或扣费。
- 财务 paid / frozen 状态伪造。
- 支付通道正式启用。
- Nginx、systemd unit、数据库回滚或云基础设施改造。

## 2. Release Record

| Item | Value |
|---|---|
| Release id | `20260502052616-sincerity-internal-no-freeze` |
| Previous Server current | `/srv/releases/server/20260501140152-notification-preview-drift-recovery` |
| Previous BFF current | `/srv/releases/bff/20260501140152-notification-preview-drift-recovery/apps/bff` |
| New Server current | `/srv/releases/server/20260502052616-sincerity-internal-no-freeze` |
| New BFF current | `/srv/releases/bff/20260502052616-sincerity-internal-no-freeze/apps/bff` |
| Server rollback pointer | `/srv/shared/rollback-server-before-20260502052616-sincerity-internal-no-freeze.txt` |
| BFF rollback pointer | `/srv/shared/rollback-bff-before-20260502052616-sincerity-internal-no-freeze.txt` |
| Server restart | `systemctl restart exhibition-server` |
| BFF restart | `systemctl restart exhibition-bff` |
| Nginx | Not modified |

## 3. Migration Evidence

Server boot log recorded:

- `applied migration 20260606_project_authenticity_sincerity_internal_test_feedback`
- `migration reconciliation complete; appliedThisBoot=20260606_project_authenticity_sincerity_internal_test_feedback`

Migration is additive:

- Adds `project_authenticity_sincerity_freeze_feedback`.
- Adds project/count indexes and one-user-one-project unique index.
- Does not drop, rename, or rewrite existing payment truth.

## 4. Runtime Verification

| Probe | Result | Judgment |
|---|---|---|
| `POST /api/app/project/nonexistent/authenticity-sincerity/freeze-feedback` without auth | `401 AUTH_SESSION_INVALID` | Pass. Route mounted; no longer raw 404. |
| `GET /api/app/project/nonexistent/pricing-summary` without auth | `401 AUTH_SESSION_INVALID` | Pass. BFF route still guarded. |
| direct Server `GET /server/projects/nonexistent/pricing-summary` | `404 P0_PAY_RESOURCE_UNAVAILABLE` | Pass. Canonical Server route mounted. |
| test account pricing summary for `d44d4741-a650-4222-b9e9-57c57e312bb3` | `authenticitySincerityStatus=internal_test_no_freeze_required`, `publishGateStatus=internal_test_no_freeze_allowed` | Pass. Gate truth comes from Server. |
| test account feedback submit | `myChoice=support_freeze`, `supportFreezeCount=1`, `opposeFreezeCount=0` | Pass. Feedback writes and reads back through cloud BFF/Server. |

## 5. Validation Commands

Local validation before cloud deployment:

- `apps/server`: `npm run build`
- `apps/bff`: `npm run build`
- `apps/server`: `node --test test/project-lifecycle.test.cjs test/p0-pay-server-mainline.test.cjs`
- `apps/bff`: `node --test test/exhibition-p0-pay-transport.test.cjs`
- `apps/mobile`: `flutter analyze lib/features/exhibition/presentation/exhibition_trade_pages.dart test/my_project_private_carry_test.dart`
- `apps/mobile`: `flutter test test/my_project_private_carry_test.dart`

All listed validations passed.

## 6. Gate Judgment

| Gate | Result |
|---|---|
| SSOT boundary frozen | Pass |
| Contracts frozen | Pass |
| Server owns publish gate truth | Pass |
| BFF remains forwarding/shaping layer | Pass |
| Flutter does not spoof paid/frozen | Pass |
| Cloud active runtime aligned | Pass |
| True payment freeze/deduct | Not opened |
| True iPhone visual confirmation | Pending user-side smoke |
| Real project publish mutation | Not executed in this receipt |

Current judgment:

- `Go` for cloud runtime availability of internal-test no-freeze status and feedback statistics.
- `Pass with Risk` for full user-facing flow until iPhone visual confirmation and an explicitly approved real publish mutation are completed.

## 6.1 iPhone Human UAT Supplement

User-side iPhone verification was reported after installation:

| Item | Result | Note |
|---|---|---|
| Login | Pass | Test account login succeeded. |
| My project list | Pass | Project list loaded normally. |
| Prepublish detail | Pass | Detail opened normally. |
| Sincerity status | Pass | Displayed internal-test no-freeze copy and did not present paid/frozen as truth. |
| Policy copy | Pass | User confirmed clear copy: internal-test period does not freeze real funds. |
| Refresh status | Pass | Refresh worked. |
| Continue sincerity payment | Pass | No real deduction was reported. |
| Support / oppose feedback buttons | Pass with product note | Buttons worked, but user recommends one-time choice instead of allowing support then oppose. |
| Publish gate | Pass | Publishing was not blocked by sincerity-money freeze; user reported direct publish success. |
| Text overflow / bottom obstruction | Pass | No overflow or obstruction reported. |

Updated judgment after human UAT:

- Core internal-test no-freeze flow: `Go`.
- Remaining non-blocking product follow-ups:
  - Feedback choice should be considered for one-time lock or stronger confirmation.
  - `作废删除` currently moves the project to archived state; copy may need to reflect archive semantics.
  - Public resource contract template returned `当前附件暂不可用`; mobile download UX should be handled in a separate public-resource download round.

## 7. Risk Notes

- 更稳：Server 返回正式内测豁免状态，BFF/Flutter 只消费，不把 `pending_payment` 改成 `paid`。
- 更省成本：复用现有支付订单与 pricing summary，只新增一个反馈统计闭环。
- 更适合当前阶段：保留支付流程和用户感知，同时避免内测期真实扣费影响留存。
- 风险更大：直接把豁免写成 paid/frozen，或让反馈按钮影响发布门禁。
