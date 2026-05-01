---
owner: Codex 总控
status: frozen
layer: Execution Receipt
updated_at: 2026-04-30
purpose: Record Day1-Day9 execution for the controlled finance mainline package, covering L0/L2/L3/persistence freeze, callback gate tests, paid readback, controlled runtime callback sample, charge rule freeze, and final charge implementation verification.
inputs_canonical:
  - docs/00_ssot/payment_finance_mainline_l0_freeze.md
  - docs/01_contracts/payment_finance_mainline_contracts_addendum.md
  - docs/02_backend/payment_finance_mainline_server_truth_addendum.md
  - docs/02_backend/payment_finance_mainline_persistence_migration_plan.md
  - docs/00_ssot/payment_finance_charge_rules_freeze_addendum.md
  - apps/server/src/modules/p0_pay/p0-pay-callback.service.ts
  - apps/server/src/modules/p0_pay/p0-pay-contract-confirmation.service.ts
  - apps/server/test/p0-pay-server-mainline.test.cjs
---

# 资金主线 Day1-Day9 执行回执

## 0. 总裁决

- Day1 L0 资金规则冻结：Pass
- Day2 L2 Contracts 冻结：Pass
- Day3 L3 Server truth 冻结：Pass
- Day4 Persistence / migration 设计：Pass, no destructive migration required
- Day5 Callback 实现：Pass by existing implementation + new behavior tests
- Day6 支付成功回读：Pass by existing readback + Flutter tests
- Day7 云端受控支付成功联调：Pass with Risk, controlled Server-internal callback sample only
- Day8 扣款规则冻结：Pass
- Day9 扣款实现：Pass by existing implementation + new idempotency / fail-closed tests
- 是否允许全量放开真实支付：No-Go
- 是否允许全量放开退款 / 结算：No-Go

核心原因：

1. 受控 callback 已可把测试 payment order 从 `pending_user_confirm` 推进为 `succeeded`，并把当前项目诚意金推进为 `paid`。
2. 合同最终扣费实现已复用 locked authorization snapshot，并补充了重复请求与缺通道 fail-closed 测试。
3. 退款和结算仍只有字段 / 状态占位，不具备 provider refund、清分、分账、发票、财务后台闭环。

## 1. Day Completion Matrix

| Day | 目标 | 完成度 | 证据 | 结论 |
|---|---|---:|---|---|
| 第 1 天 | L0 资金规则冻结 | 100% | `payment_finance_mainline_l0_freeze.md` | Pass |
| 第 2 天 | L2 Contracts 冻结 | 100% | `payment_finance_mainline_contracts_addendum.md` | Pass |
| 第 3 天 | L3 Server truth 冻结 | 100% | `payment_finance_mainline_server_truth_addendum.md` | Pass |
| 第 4 天 | Persistence / migration 设计 | 100% | `payment_finance_mainline_persistence_migration_plan.md` | Pass |
| 第 5 天 | Callback 实现 | 100% | `p0-pay-callback.service.ts` + server tests | Pass |
| 第 6 天 | 支付成功回读 | 100% | BFF/Flutter readback tests | Pass |
| 第 7 天 | 云端受控支付成功联调 | 90% | Server-internal callback sample | Pass with Risk |
| 第 8 天 | 扣款规则冻结 | 100% | `payment_finance_charge_rules_freeze_addendum.md` | Pass |
| 第 9 天 | 扣款实现 | 100% | `p0-pay-contract-confirmation.service.ts` + server tests | Pass |

## 2. Local Verification

Commands:

```bash
corepack pnpm --dir apps/server build
corepack pnpm --dir apps/bff build
node --test apps/server/test/p0-pay-calculator-idempotency.test.cjs apps/server/test/p0-pay-server-mainline.test.cjs
node --test apps/bff/test/exhibition-p0-pay-transport.test.cjs
flutter test --no-pub test/p0_pay_flutter_consumption_test.dart test/my_project_private_carry_test.dart
flutter analyze lib/features/exhibition/data/p0_pay_read_only_summary.dart lib/features/exhibition/data/services/p0_pay_consumer_service.dart lib/features/exhibition/presentation/pages/my_project_detail_page.dart lib/features/exhibition/presentation/presentation_support/project_publish_progress_support.dart lib/features/exhibition/presentation/widgets/exhibition_status_messages.dart test/p0_pay_flutter_consumption_test.dart test/my_project_private_carry_test.dart
```

Results:

- Server build: Pass
- BFF build: Pass
- Server targeted tests: Pass, 19/19
- BFF targeted tests: Pass, 9/9
- Flutter targeted tests: Pass, 28/28
- Flutter targeted analyze: Pass, no issues

## 3. New Server Gate Tests

This execution added tests for:

1. Callback signature rejection records event without applying money state.
2. Contract final charge returns an existing charge idempotently.
3. Contract final charge fail-closes when locked payment channel is missing.

These supplement existing tests for:

1. Callback success / duplicate / failure preserving locked fee snapshot.
2. Project sincerity callback marking paid without auto-publishing the project.
3. `standard / professional / ka / flagship` final charge using locked tiered fee calculation.

## 4. Cloud Controlled Runtime Sample

Runtime tunnel health:

- BFF health: `200 OK`
- Server health: `200 OK`

Callback route exposure:

- Public Nginx path `/server/exhibition/p0-pay/payment-callbacks/other`: `404`, not exposed publicly through the app tunnel.
- Server internal path `127.0.0.1:3001/server/exhibition/p0-pay/payment-callbacks/other`: controlled `400 P0_PAY_INVALID` for empty route-check payload, proving route presence without writing money state.

Controlled callback sample:

- payment order: `c397b309-76b3-4ac9-aba4-09c715417f79`
- business type: `project_authenticity_sincerity_payment`
- task id: `6883586a-c8a3-47f4-aded-96450fe8c3fe`
- amount: `200.00`
- channel: `alipay`
- callback verification: `verified`
- callback apply status: `applied`
- payment order after callback: `succeeded`
- project sincerity order after callback: `paid`

Safety notes:

1. The callback was signed with the Server callback secret inside the cloud host; the secret was not printed.
2. No real Alipay / WeChat payment page was opened.
3. No real provider扣款 was triggered by this command.
4. This proves Server callback handling and state application only; it does not prove provider-side settlement.

## 5. Current Minimum Closure

Current completed closure:

1. Payment order can be created and pay-init can be issued.
2. Server callback can verify signed callback.
3. Verified success callback can mark a test project sincerity order as paid.
4. Flutter / BFF can read paid state and continue publish gate.
5. Contract final charge implementation can create one idempotent charge using locked snapshot.

## 6. Need To Keep But Not Open Yet

The following remain blocked:

1. Public callback gateway cutover.
2. Real Alipay / WeChat production payment confirmation.
3. Provider-side refund execution.
4. Provider-side preauthorization release verification.
5. Settlement / clearing / payout.
6. Invoice / tax / finance-admin.
7. Full payment reconciliation and exception operation console.

## 7. Risks

### P0 Blocker

1. Full真实支付仍未走 provider sandbox / production callback domain verification.
2. Refund / settlement have no full provider execution path.
3. Public callback ingress is intentionally not exposed through current Nginx app tunnel.

### P1 Risk

1. Cloud controlled callback changed one test payment order to `succeeded`; this is acceptable as a controlled sample but must not be treated as real payment evidence.
2. `platform_service_fee_charge` current implementation uses Server-side `server_capture / succeeded` semantics; provider-side capture is not proven.
3. Old `p0_pay` route names still exist internally as compatibility infrastructure.

### P2 Improvement

1. Add provider sandbox adapter after channel准入 is frozen.
2. Add callback route ingress allowlist and replay window.
3. Add finance-admin read-only reconciliation page after settlement package is frozen.

## 8. Four Judgments

| 判断 | 结论 | 原因 |
|---|---|---|
| 哪个更稳 | 继续受控 callback + final charge 门禁，不全量开放真实资金 | 已有最小闭环，但 provider 侧仍缺证 |
| 哪个更省成本 | 复用现有 P0-Pay 基础设施 | 不重建 payment order / callback / transaction |
| 哪个更适合当前阶段 | 开放项目发布 paid gate 与合同 charge 内部闭环，退款/结算后置 | 先保证主链不迷路、不误扣 |
| 哪个风险更大 | 直接宣布真实退款/结算可用 | 当前没有 provider refund / settlement 证据 |

## 9. Go / No-Go

- Go: Server callback controlled sample.
- Go: Flutter paid readback.
- Go: contract final charge locked snapshot implementation.
- No-Go: full real payment launch.
- No-Go: refund execution launch.
- No-Go: settlement launch.

## 10. 下一轮唯一动作

进入“真实渠道准入与退款/结算实施前置包”：

1. 冻结 provider sandbox / production callback ingress。
2. 冻结 provider refund / release API。
3. 冻结 reconciliation / settlement read model。
4. 通过后再进入真实支付渠道 adapter 实现。
