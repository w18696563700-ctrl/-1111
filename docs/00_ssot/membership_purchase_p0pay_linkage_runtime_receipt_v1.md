# 会员直购与 P0-Pay 联动 runtime 回执 v1

status: passed_with_runtime_limits
owner: Codex Control
created_at: 2026-05-01

## 0. 总裁决

- 会员直购最小闭环：已落地到 Server / BFF / Flutter，并完成云端 Server / BFF 部署。
- 会员订单状态与 Admin 最小查询：已落地，Admin 云端 `/membership` 入口已部署并受登录门禁保护。
- P0-Pay 9折/8折服务费联动：Server / BFF / Flutter 本地验证通过，云端 P0-Pay summary 读态可用。
- 真实支付：未触发。
- 真实会员订单：未创建。
- 真实预授权 / 竞标提交 / 项目发布：未触发。
- 退款、发票、续费、取消、KA / 旗舰、Admin 写操作：仍关闭。

## 1. Release 记录

Release id: `20260501055524-membership-purchase-p0pay-linkage`

| 单元 | 当前 release | previous rollback target | 状态 |
|---|---|---|---|
| Server | `/srv/releases/server/20260501055524-membership-purchase-p0pay-linkage` | `/srv/releases/server/20260501053918-p0-bcde-closure` | active |
| BFF | `/srv/releases/bff/20260501055524-membership-purchase-p0pay-linkage/apps/bff` | `/srv/releases/bff/20260501053918-p0-bcde-closure/apps/bff` | active |
| Admin | `/srv/releases/admin/20260501055524-membership-purchase-p0pay-linkage` | `/srv/releases/admin/20260412160203` | active |

Rollback target 记录：

- `/srv/shared/rollback-server-before-20260501055524-membership-purchase-p0pay-linkage.txt`
- `/srv/shared/rollback-bff-before-20260501055524-membership-purchase-p0pay-linkage.txt`
- `/srv/shared/rollback-admin-before-20260501055524-membership-purchase-p0pay-linkage.txt`

## 2. 本地验证

| 检查 | 结果 |
|---|---|
| `corepack pnpm --dir apps/server build` | passed |
| `corepack pnpm --dir apps/bff build` | passed |
| `corepack pnpm --dir apps/admin build` | passed |
| `corepack pnpm contracts:check` | passed |
| `node --test apps/server/test/membership-direct-purchase.test.cjs` | passed |
| `node --test apps/server/test/p0-pay-calculator-idempotency.test.cjs` | passed |
| `node --test apps/server/test/p0-pay-server-mainline.test.cjs` | passed |
| `node --test apps/bff/test/profile-membership-purchase-transport.test.cjs` | passed |
| `node --test apps/bff/test/exhibition-p0-pay-transport.test.cjs` | passed |
| `corepack pnpm --dir apps/admin test:admin-side:prepare` | passed |
| `node --test apps/admin/test/admin-api-client.test.cjs apps/admin/test/admin-route-guard.test.cjs` | passed |
| `flutter test test/profile_page_test.dart --plain-name "my membership entry consumes shell summary and the four bounded read pages"` | passed |
| `flutter test test/p0_pay_flutter_consumption_test.dart` | passed |
| `flutter test test/shell_app_test.dart --plain-name "bid submit service fee uses fixed validity and user-facing copy"` | passed |

Note:

- A broader `flutter test test/shell_app_test.dart --plain-name "bid submit"` also ran unrelated legacy bid-submit tests and exposed pre-existing unrelated failures around `竞标已提交` copy visibility. The precise P0-Pay service-fee test passed.

## 3. 云端部署与服务状态

| 检查 | 结果 |
|---|---|
| `systemctl is-active exhibition-server` | active |
| `systemctl is-active exhibition-bff` | active |
| `systemctl is-active exhibition-admin` | active |
| `systemctl is-active nginx` | active |
| `GET /health/bff/live` through `127.0.0.1:8080` | 200 |
| `GET /health/server/live` through `127.0.0.1:8080` | 200 |
| BFF post line-gate split restart | active, current points to release `20260501055524-membership-purchase-p0pay-linkage` |
| Admin `/api/health` on `127.0.0.1:3002` | 200 |
| Admin `/membership` on `127.0.0.1:3002` | 307 to `/login?next=%2Fmembership` |

Server migration runner evidence:

- Applied `20260605_p0_pay_membership_discount_snapshot_truth`.
- Applied `20260501_membership_direct_purchase_minimum_loop`.

## 4. 只读 runtime 复核

Base URL: `http://127.0.0.1:8080`

Auth action:

- `POST /api/app/auth/password/login`
- Result: `200`, `shellBootstrapState=authenticated`

No real payment, pre-authorization, bid submit, project publish, refund, invoice, or membership order create was executed in runtime validation.

| Endpoint | Status | Runtime result |
|---|---:|---|
| `GET /api/app/shell/context` | 200 | `membershipStatus=active`, `paidMembershipTier=null` |
| `GET /api/app/profile/membership/current` | 200 | `paidMembershipTier=null`, `rateBand=null`, `serviceFeeDiscountSummary=null` |
| `GET /api/app/profile/membership/explanation` | 200 | standard/professional show `平台服务费 9 折 / 8 折` |
| `GET /api/app/profile/membership/quota` | 200 | quota read surface available |
| `GET /api/app/profile/membership/upgrade-guide` | 200 | available tiers use `serviceFeeDiscountSummary`; candidate old fields are null |
| `GET /api/app/profile/membership/purchase-offers` | 200 | standard SKU `2599`, professional SKU `4599`, channel candidates include Alipay and WeChat candidate; no `2.5% / 2.0% / 1.5%` mention |
| `GET /api/app/profile/payment-and-billing-status/status` | 200 | still handoff-only |
| `GET /api/app/project/a541e9ac-1c0f-4224-a399-25c6b8a7f310/pricing-summary` | 200 | `authorizationQuotaAmount=4000.00`, `readOnly=true`; no `2.5% / 2.0% / 1.5%` mention |
| `GET /api/app/project/5beb03bf-9489-4892-a641-23ec60f395ff/pricing-summary` | 200 | `authorizationQuotaAmount=4000.00`, status `failed`, `readOnly=true` |

## 5. 已落地能力

- 会员直购 SKU：标准会员年付 `2599`，专业会员年付 `4599`。
- 支付通道优先级：Alipay candidate 优先；WeChat candidate 保留/灰度。
- Server 会员订单最小闭环：offer、order create、pay-init、pay-result、callback entitlement writeback。
- BFF App 侧会员购买投影：只聚合与裁剪 Server 真相。
- Flutter 会员购买最小页面流：offer、确认、支付结果、订单状态只读。
- Admin 只读查询：会员订单列表、订单详情、组织会员状态。
- P0-Pay 折扣快照：`baseFeeAmount`、`membershipDiscountRate`、`capAmount`、`finalFeeAmount`。
- P0-Pay 正式折扣：标准 `0.9000`，专业 `0.8000`，免费认证/无会员 `1.0000`。

## 6. 仍关闭能力

- 真实生产支付验收。
- 会员续费。
- 会员取消。
- 会员退款。
- 会员发票。
- KA / 旗舰。
- Admin 手工开通 / 手工改会员 / 手工改支付状态。
- 复杂 quota rich workflow。

## 7. 风险与限制

- 本轮没有触发真实支付，因此支付通道商户配置、回调域名、ICP、沙箱/生产差异仍需独立支付验收。
- P0-Pay runtime 只做 read-only summary 验证，没有触发真实预授权、扣款或竞标提交。
- BFF P0-Pay read model 已拆分到 `apps/bff/src/routes/exhibition_p0_pay/exhibition-p0-pay.read-model.ts` 与 `apps/bff/src/routes/exhibition_p0_pay/exhibition-p0-pay.read-model-support.ts`，主文件 436 行，辅助文件 152 行，当前满足 450 行责任门禁。
- Admin 云端 `/membership` 已部署但只验证到登录门禁，未使用真实 Admin 会话进入页面数据态。

## 8. 下一阶段入口条件

- 若要进入正式支付灰度，必须先冻结支付通道商户参数、回调域名、沙箱/生产隔离、退款和对账回滚方案。
- 若要进入 P0-Pay 真实联动验收，必须准备受控测试项目、受控竞标账号、受控会员态和可回滚的测试支付/预授权通道。
- 若要进入 Admin 运营写能力，必须单独冻结权限、审计、异常处理和人工变更规则。

## 9. 下一轮唯一动作

输出《会员直购与 P0-Pay 支付沙箱验收方案》，只出方案，不直接触发真实支付。
