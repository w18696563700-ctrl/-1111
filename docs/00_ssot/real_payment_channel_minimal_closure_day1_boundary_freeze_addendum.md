---
owner: Codex 总控
status: frozen
layer: L0 SSOT
freeze_date_local: 2026-05-09
purpose: Freeze Day-1 boundary for the real payment-channel minimum closure package before contracts, implementation, and cloud UAT.
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/payment_finance_mainline_l0_freeze.md
  - docs/00_ssot/payment_finance_capability_blueprint_v1.md
  - docs/00_ssot/payment_channel_constraints_assumptions_v1.md
  - docs/00_ssot/alipay_app_pay_channel_integration_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/server/src/modules/p0_pay/p0-pay-payment-channel.service.ts
  - apps/server/src/modules/p0_pay/p0-pay-callback.service.ts
  - apps/bff/src/routes/exhibition_p0_pay/exhibition-p0-pay.service.ts
  - apps/mobile/lib/features/exhibition/data/services/p0_pay_consumer_service.dart
---

# 真实支付通道最小闭环 Day-1 边界冻结单

## 0. 总裁决

本轮真实资金通道最小闭环进入 Day-2 的裁决为 `Go with strict limits`。

当前允许继续冻结的对象仅为：

1. 单渠道：`alipay_candidate`。
2. 单业务对象：`4000 元竞标服务费预授权额度`。
3. 单状态目标：Server 回读 `authorizationStatus=frozen`。
4. 单业务解锁：Server 回读 `chatAvailability.canSendMessage=true`。

当前仍为 `No-Go` 的对象：

1. 公开全量生产真实支付。
2. 微信支付真实通道施工。
3. 扣款、退款、结算、发票、财务后台、钱包、余额、金币、资金池。
4. Flutter 或 BFF 判断支付成功。
5. 手工改库或绕过 Server callback 解锁消息发送。

## 1. 当前 other_candidate 闭环核实

当前 `other_candidate` 已完成受控业务闭环，但它不是外部真实资金通道。

已核实的受控闭环：

1. `create` 返回既有 `authorizationId=f79f93ed-c9a6-462a-8ff8-33b1a09136d8`，初始 `authorizationStatus=pending_freeze`。
2. `freeze-init` 使用 `other_candidate`，返回 `channelActionType=web_redirect` 且 `callbackAwaiting=true`。
3. `status` 回读 `authorizationStatus=frozen`。
4. 项目沟通线程回读 `chatAvailability.canSendMessage=true`。
5. 真实消息发送成功并可回读，`messageState=active`。

证据目录：

```text
.tmp/20260509134344-other-candidate-controlled-callback/uat/
```

解释：

- 该闭环证明 Server-owned 状态推进、BFF/Flutter 读取、消息锁解除已可工作。
- 该闭环不证明支付宝、微信或任何外部支付机构已完成资金冻结。

## 2. 单渠道选择

本轮真实通道仅选择 `alipay_candidate`。

选择依据：

1. Server 已有 `alipay` 分支，可生成 Alipay APP Pay `sdk_payload`。
2. Server 已有 Alipay RSA2 callback 验签逻辑。
3. Flutter 已有 `orderString` 识别和 Alipay APP Pay native method channel 调用路径。
4. 云端运行中 Server 进程已确认支付宝相关配置项存在，但未输出任何配置值。
5. 微信当前仅保留为 `wechat_candidate` 枚举候选，未见等价真实渠道适配和云端配置证据。

Day-2 需要冻结的 channel candidate：

```text
alipay_candidate -> Server internal channel: alipay
```

Day-2 不得冻结为本轮施工对象：

```text
wechat_candidate
```

## 3. 资金语义冻结

`4000 元`当前冻结为：

```text
竞标服务费预授权额度
```

它不是：

1. 已付款。
2. 报名费。
3. 竞标费。
4. 履约保证金。
5. 平台钱包余额。
6. 成交后最终服务费扣款。

用户侧文案必须保持：

```text
预授权不是扣款。
```

Server 侧语义必须保持：

1. `frozen` 只表示当前竞标服务费预授权额度已被支付通道或受控 callback 证明完成。
2. 成交后的最终服务费扣取必须另走合同确认和 locked snapshot 规则。
3. 未中标释放、退款、结算、发票必须另开包，不得在本轮顺手打开。

## 4. 当前路径和字段

### 4.1 App-facing path

当前 App-facing 主路径已经存在：

```text
POST /api/app/project/{projectId}/bid-service-fee-authorizations
POST /api/app/project/{projectId}/bid-service-fee-authorizations/{authorizationId}/freeze-init
GET  /api/app/project/{projectId}/bid-service-fee-authorizations/{authorizationId}
```

本轮 Day-2 优先复用现有 path，不新增新的 App-facing path。

### 4.2 Server callback path

当前 Server callback path 已存在：

```text
POST /server/exhibition/p0-pay/payment-callbacks/{paymentChannel}
```

Alipay callback 对应：

```text
POST /server/exhibition/p0-pay/payment-callbacks/alipay
```

Day-2 必须确认该 path 的公开 ingress 方式、签名字段、幂等字段和响应形态。

在 Day-2 完成前，禁止执行：

```text
创建真实支付订单
pay-init 写调用
拉起 Alipay SDK
调用真实或模拟 provider callback
真实预授权
真实竞标资金验证
```

### 4.3 Flutter path

当前 Flutter 消费层已存在：

1. `createProjectBidServiceFeeAuthorization`
2. `initProjectBidServiceFeeAuthorizationFreeze`
3. `loadProjectBidServiceFeeAuthorizationStatus`
4. `pollProjectBidServiceFeeAuthorizationStatus`

Day-5 只能在现有预授权页接入 Alipay 拉起与等待回调 UI，不得新增消息页内支付执行台。

## 5. 状态机草案

Day-2 contracts freeze 应以现有状态为基础，不在 Flutter 或 BFF 新造状态机。

### 5.1 Authorization status

当前已存在：

```text
pending_freeze
frozen
release_pending
released
charge_pending
charged
breach_hold
cancelled
failed
expired
```

Day-2 可评估是否需要补充 `channel_pending` 作为显示/transport 态，但不得让它替代 Server authorization truth。

### 5.2 Payment order status

当前已存在：

```text
created
pending_user_confirm
succeeded
failed
cancelled
closed
release_pending
released
refund_pending
refunded
expired
```

Alipay APP Pay 最小闭环只允许使用：

```text
created -> pending_user_confirm -> succeeded
created -> pending_user_confirm -> failed
created -> pending_user_confirm -> closed/cancelled/expired
```

不得在本轮打开：

```text
refund_pending
refunded
released
settlement
invoice
```

## 6. 错误码草案

当前已有可复用错误码：

```text
BID_SERVICE_FEE_AUTHORIZATION_REQUIRED
BID_SERVICE_FEE_AUTHORIZATION_CREATE_REJECTED
BID_SERVICE_FEE_AUTHORIZATION_NOT_FOUND
BID_SERVICE_FEE_AUTHORIZATION_FREEZE_INIT_REJECTED
BID_SERVICE_FEE_AUTHORIZATION_RELEASE_REJECTED
BID_SERVICE_FEE_AUTHORIZATION_INVALID_STATE
P0_PAY_INVALID
P0_PAY_RESOURCE_UNAVAILABLE
P0_PAY_PERMISSION_DENIED
P0_PAY_STATE_CONFLICT
P0_PAY_IDEMPOTENCY_CONFLICT
PRICING_RULE_VERSION_MISMATCH
```

Day-2 必须明确是否补充或标准化以下 channel reason code：

```text
alipay_app_pay_disabled
alipay_runtime_config_missing
alipay_public_key_missing
alipay_signature_missing
alipay_signature_type_unsupported
alipay_app_id_mismatch
alipay_signature_invalid
payment_order_not_found
payment_amount_mismatch
unsupported_event_type
```

## 7. 允许改动清单

Day-2 后如进入实现，本轮允许的最小文件范围为：

```text
docs/00_ssot/real_payment_channel_minimal_closure_*.md
docs/01_contracts/openapi.yaml
packages/contracts/**
apps/server/src/modules/p0_pay/p0-pay-payment-channel.service.ts
apps/server/src/modules/p0_pay/p0-pay-callback.service.ts
apps/server/src/modules/p0_pay/p0-pay-service-fee-authorization.service.ts
apps/server/src/modules/p0_pay/p0-pay-project-bid-service-fee-authorization.service.ts
apps/server/src/modules/p0_pay/entities/*
apps/server/test/p0-pay-*.test.cjs
apps/bff/src/routes/exhibition_p0_pay/*
apps/bff/test/exhibition-p0-pay-transport.test.cjs
apps/mobile/lib/features/exhibition/data/services/p0_pay_consumer_service.dart
apps/mobile/lib/features/exhibition/data/commands/p0_pay_commands.dart
apps/mobile/lib/features/exhibition/presentation/presentation_support/bid_service_fee_authorization_flow_support.dart
apps/mobile/lib/features/exhibition/presentation/presentation_support/exhibition_payload_support.dart
apps/mobile/test/*p0_pay*
apps/mobile/test/bid_service_fee_authorization_page_test.dart
```

## 8. 禁止触碰清单

本轮默认禁止触碰：

```text
infra/env/formal_cloud_target.env
secret files
credential files
database migrations, unless Day-2/Day-3 proves a required schema gap
wallet / balance / coins modules
settlement modules
invoice modules
finance admin modules
generic refund workbench
message sending permission bypass
Flutter local success judgment
BFF-owned payment state
```

本轮不得执行：

```text
手工 DB 写入
伪造 Alipay callback 成真实资金成功
绕过 Server callback 直接 frozen
直接公开全量生产流量
同时接入 Alipay 和 WeChat
```

## 9. 云端联调前置条件

Day-7 前必须满足：

1. Server release / BFF release rollback target 已记录。
2. Alipay APP Pay runtime config 仅以 present/missing 形式核验，不输出配置值。
3. Public notify URL 可被 Alipay 访问。
4. Nginx / ingress 明确将 callback path 路由到 Server。
5. 测试账号和测试项目白名单明确。
6. Flutter 运行在支持 Alipay SDK 的 Android 或 iOS 环境；macOS 只能验证 payload 和轮询，不能证明真实 SDK 拉起。

## 10. 是否进入第 2 天

裁决：

```text
允许进入第 2 天：是，限 contracts freeze + Alipay sandbox / callback 配置只读补证。
```

限制：

1. 第 2 天只冻结 contracts 与字段，不实现代码。
2. 第 2 天必须继续维持单渠道 `alipay_candidate`。
3. 第 2 天必须补齐支付宝沙箱 / 白名单 / callback ingress 的只读证据；未补齐前不得进入 Day-3 Server 实现。
4. 如果发现 OpenAPI 与当前 Server/BFF/Flutter 字段冲突，先停在 contracts 修正，不进入 Day-3 Server 实现。

## 11. 四类判断

| 判断 | 结论 | 原因 |
|---|---|---|
| 哪个更稳 | Alipay APP Pay 单渠道白名单闭环 | 已有 Server 签单、验签和 Flutter `orderString` 消费基础 |
| 哪个更省成本 | 继续使用 `other_candidate` | 不接真实外部资金，但不能证明真实支付 |
| 哪个更适合当前阶段 | Alipay 单渠道 contracts freeze -> Server/BFF/Flutter 最小接线 -> 白名单 UAT | 可复用现有 P0-Pay，不扩大资金全家桶 |
| 哪个风险更大 | 同时打开 Alipay/WeChat、退款、结算、发票、生产全量 | 通道准入、法务、财务、对账和回滚风险叠加 |

## 12. Day-1 结论

Day-1 完成度：`100%`。

整体九天任务完成度：`11.1%`。
