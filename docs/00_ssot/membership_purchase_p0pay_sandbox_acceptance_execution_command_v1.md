---
owner: Codex 总控
status: frozen_day1_no_go_to_write_chain
layer: L0 SSOT
created_at: 2026-05-01
scope: membership direct purchase and P0-Pay payment sandbox acceptance execution command
purpose: Freeze the controlled sandbox acceptance boundary before any membership order create, pay-init, payment callback, entitlement writeback, idempotency replay, rollback, Admin data-state check, or P0-Pay effective-membership read verification. This file does not approve production payment, real preauthorization, real bid submit, refund, invoice, renewal, cancellation, KA, flagship, Admin write operation, or cloud mutation beyond the explicitly gated sandbox write chain.
inputs_canonical:
  - docs/00_ssot/membership_purchase_p0pay_linkage_runtime_receipt_v1.md
  - docs/00_ssot/membership_direct_purchase_sku_price_and_channel_precondition_freeze_v1.md
  - docs/00_ssot/membership_purchase_admin_p0pay_implementation_ruling_v1.md
  - docs/01_contracts/membership_purchase_admin_p0pay_contracts_addendum_v1.md
  - docs/02_backend/membership_purchase_admin_p0pay_server_design_v1.md
  - docs/02_backend/p0_pay_membership_discount_linkage_design_v1.md
---

# 会员直购与 P0-Pay 支付沙箱验收执行口令 V1

## 0. 总裁决

- Day 1 是否完成：`Yes`
- 是否允许进入 Day 2 会员订单创建 / pay-init：`No-Go`
- No-Go 原因：云端 Server 当前未暴露 Alipay AppPay 沙箱运行配置，不能证明 pay-init 指向沙箱而非生产或不可用通道。
- 是否允许真实生产支付：`No-Go`
- 是否允许真实预授权 / 真实竞标 / 真实项目发布：`No-Go`
- 是否允许退款 / 发票 / 续费 / 取消：`No-Go`
- 是否允许 Admin 写操作：`No-Go`
- 是否允许 KA / 旗舰：`No-Go`

本文件只冻结执行口令和测试边界，不触发订单创建、pay-init、支付 SDK、支付回调、会员生效、P0-Pay 预授权或任何生产资金动作。

## 1. Day 1 取证结论

### 1.1 云端 release 与服务状态

| 对象 | 当前证据 | 裁决 |
|---|---|---|
| Server release | `/srv/releases/server/20260501055524-membership-purchase-p0pay-linkage` | 可作为验收基线 |
| BFF release | `/srv/releases/bff/20260501055524-membership-purchase-p0pay-linkage/apps/bff` | 可作为验收基线 |
| Admin release | `/srv/releases/admin/20260501055524-membership-purchase-p0pay-linkage` | 可作为验收基线 |
| `exhibition-server` | `active` | Pass |
| `exhibition-bff` | `active` | Pass |
| `exhibition-admin` | `active` | Pass |
| `nginx` | `active` | Pass |

Rollback target 已存在：

1. `/srv/shared/rollback-server-before-20260501055524-membership-purchase-p0pay-linkage.txt`
2. `/srv/shared/rollback-bff-before-20260501055524-membership-purchase-p0pay-linkage.txt`
3. `/srv/shared/rollback-admin-before-20260501055524-membership-purchase-p0pay-linkage.txt`

### 1.2 支付沙箱配置核对

| 配置项 | 当前云端进程证据 | 是否满足 Day 2 |
|---|---|---:|
| `P0_PAY_ALIPAY_APP_PAY_ENABLED` | Evidence Missing | No |
| `P0_PAY_ALIPAY_APP_ID` / `ALIPAY_APP_ID` | Evidence Missing | No |
| `P0_PAY_ALIPAY_APP_PRIVATE_KEY` / compatible private key | Evidence Missing | No |
| `P0_PAY_ALIPAY_PUBLIC_KEY` / `ALIPAY_PUBLIC_KEY` | Evidence Missing | No |
| `P0_PAY_ALIPAY_NOTIFY_URL` / `ALIPAY_NOTIFY_URL` | Evidence Missing | No |
| `P0_PAY_ALIPAY_GATEWAY_URL` | Evidence Missing; code default is production gateway if unset | No |
| `P0_PAY_CALLBACK_SECRET` | Present, masked | Pass only for generic callback secret, not Alipay sandbox |

结论：当前不能进入 Alipay 沙箱会员直购写链路。缺少 `P0_PAY_ALIPAY_GATEWAY_URL=https://openapi-sandbox.dl.alipaydev.com/gateway.do` 或等价沙箱网关证据时，任何 pay-init 都不得被认定为沙箱验收。

### 1.3 当前代码边界

| 能力 | 代码证据 | 结论 |
|---|---|---|
| 会员 purchase-offers | `apps/server/src/modules/membership/membership.controller.ts` exposes `GET purchase-offers` | 已具备 |
| 会员 order-create | `apps/server/src/modules/membership/membership.purchase.service.ts` creates `membership_orders` | 已具备但 Day 2 前禁止写 |
| 会员 pay-init | `apps/server/src/modules/membership/membership.purchase.service.ts` creates `payment_orders` and calls channel action builder | 已具备但 Day 2 前禁止写 |
| Alipay AppPay action | `apps/server/src/modules/p0_pay/p0-pay-payment-channel.service.ts` builds signed `orderString` only when Alipay config exists | 当前云端配置缺证 |
| 回调入口 | `apps/server/src/modules/p0_pay/p0-pay.controller.ts` owns `POST /server/exhibition/p0-pay/payment-callbacks/:paymentChannel` | 已具备但 Day 2 前禁止调用 |
| 回调验签 | `apps/server/src/modules/p0_pay/p0-pay-payment-channel.service.ts` verifies Alipay callback with public key | 当前云端 public key 缺证 |
| 权益写回 | `apps/server/src/modules/membership/membership.purchase.service.ts` writes `organization_paid_memberships` after payment success | 已具备但 Day 2 前禁止触发 |

## 2. 测试对象冻结

| 对象 | 当前用途 | Runtime 证据 | 裁决 |
|---|---|---|---|
| 测试账号 A | 会员直购标准会员沙箱购买候选 | 登录 200；current organization `e6bf4567-016e-45f9-9420-9c950237690e`；`paidMembershipTier=null`；`purchaseEligible=true` | 可作为 Day 2 标准会员订单创建候选，但需先补齐沙箱配置 |
| 测试账号 B | 标准会员折扣读态 / 专业升级候选 | 登录 200；current organization `bdfb4523-aeb7-4b56-89a1-992170fb5d98`；`paidMembershipTier=standard`；`purchaseEligible=true` | 可作为 P0-Pay 标准会员有效态读态样本，或专业升级候选 |
| 标准会员 SKU | `membership_standard_year_v1` | `priceAmount=2599`, `currency=CNY`, `status=available` | 冻结 |
| 专业会员 SKU | `membership_professional_year_v1` | `priceAmount=4599`, `currency=CNY`, `status=available` | 冻结 |
| 支付通道候选 | `alipay_candidate`, `wechat_candidate` | purchase-offers returns both candidates | `alipay_candidate` only after sandbox config; `wechat_candidate` remains reserved/gray |

敏感信息处理：

1. 手机号、token、密码不得写入回执明文。
2. 后续执行日志只允许写测试账号 A / B 和组织 id。
3. 支付密钥、私钥、公钥只记录存在性、环境名、是否 sandbox，不记录原值。

## 3. Day 2 进入条件

Day 2 必须同时满足以下条件，否则继续 No-Go：

| 条件 | 必须证据 |
|---|---|
| Alipay AppPay 已启用 | `P0_PAY_ALIPAY_APP_PAY_ENABLED=true` |
| Alipay appId 已配置 | `P0_PAY_ALIPAY_APP_ID` 或 `ALIPAY_APP_ID` present，值遮蔽 |
| Alipay 应用私钥已配置 | private key present，值遮蔽 |
| Alipay 公钥已配置 | public key present，值遮蔽 |
| Alipay notify URL 已配置 | URL 必须指向当前受控 Server callback route |
| Alipay gateway 明确为沙箱 | `P0_PAY_ALIPAY_GATEWAY_URL` 必须是支付宝沙箱网关，不得使用默认生产网关 |
| 回调域名可达 | 支付宝沙箱能访问 notify URL；若仅内网隧道不可达，则不能做真实沙箱回调 |
| 回滚路径确认 | release rollback + 测试订单 / 支付流水 / 会员权益撤销或 void 标记方案明确 |

## 4. 允许与禁止动作

### 当前允许

1. 只读检查 release、service、health、env key presence。
2. 测试账号登录与 GET readback。
3. `GET /api/app/profile/membership/current`
4. `GET /api/app/profile/membership/purchase-offers`
5. `GET /api/app/project/:projectId/pricing-summary`
6. Admin 登录门禁与只读页面可达性检查。

### 当前禁止

1. `POST /api/app/profile/membership/orders`
2. `POST /api/app/profile/membership/orders/:membershipOrderId/pay-init`
3. 拉起 Alipay / WeChat SDK。
4. 调用支付 callback。
5. 手工伪造生产 callback。
6. 写入会员权益。
7. 创建真实会员订单。
8. 真实支付、真实预授权、真实竞标、真实项目发布。
9. Admin 写操作。
10. 删除测试数据或生产审计。

## 5. 回滚对象冻结

| 对象 | 回滚/撤销方式 | 当前状态 |
|---|---|---|
| Server release | 使用 `/srv/shared/rollback-server-before-20260501055524-membership-purchase-p0pay-linkage.txt` | 已具备 |
| BFF release | 使用 `/srv/shared/rollback-bff-before-20260501055524-membership-purchase-p0pay-linkage.txt` | 已具备 |
| Admin release | 使用 `/srv/shared/rollback-admin-before-20260501055524-membership-purchase-p0pay-linkage.txt` | 已具备 |
| 会员订单 | 后续 Day 2 若创建，只允许按测试 organization 精确 void，不硬删审计 | 待 Day 2 |
| 支付订单 / 流水 | 后续 Day 2 若创建，只允许沙箱或 test_voided 标记，不进入生产对账 | 待 Day 2 |
| paid membership entitlement | 后续若由沙箱回调写入，只允许按 sourceType/sourceRef 精确撤销或失效 | 待 Day 3/4 |
| callback event | 保留事件和审计，不硬删 | 待 Day 3/4 |

## 6. Day 1 验收结果

| 验收项 | 结果 |
|---|---|
| 测试账号确认 | Pass |
| 测试组织确认 | Pass |
| SKU 价格确认 | Pass |
| 支付候选通道确认 | Pass |
| release / rollback target 确认 | Pass |
| Alipay 沙箱 appId / key / notify URL / gateway 确认 | Fail |
| Day 2 是否可执行 | No-Go |

## 7. 下一轮唯一动作

补齐并只读复核 Alipay 沙箱运行配置：`P0_PAY_ALIPAY_APP_PAY_ENABLED=true`、沙箱 appId、沙箱私钥、沙箱支付宝公钥、沙箱 notify URL、沙箱 gateway URL。

在上述配置全部有证据前，不得创建会员订单，不得 pay-init，不得回调，不得生效会员权益。
