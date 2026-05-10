---
owner: Codex 总控
status: frozen
layer: L2 Contracts
freeze_date_local: 2026-05-09
purpose: Freeze the Day-2 App-facing, Server callback, state, error, and handoff contract boundary for the real payment-channel minimum closure package.
inputs_canonical:
  - docs/00_ssot/real_payment_channel_minimal_closure_day1_boundary_freeze_addendum.md
  - docs/00_ssot/alipay_app_pay_channel_integration_addendum.md
  - docs/00_ssot/payment_channel_constraints_assumptions_v1.md
  - docs/01_contracts/openapi.yaml
  - docs/01_contracts/payment_finance_mainline_contracts_addendum.md
  - apps/server/src/modules/p0_pay/p0-pay-payment-channel.service.ts
  - apps/server/src/modules/p0_pay/p0-pay-callback.service.ts
  - apps/bff/src/routes/exhibition_p0_pay/exhibition-p0-pay-payload.service.ts
  - apps/mobile/lib/features/exhibition/data/services/p0_pay_consumer_service.dart
---

# 真实支付通道最小闭环 Day-2 Contracts 冻结单

## 0. 总裁决

Day-2 contracts freeze 结论为 `Conditional Pass`。

已冻结并通过本地 contracts 校验的内容：

1. 单真实通道候选：`alipay_candidate`。
2. 保留受控测试通道：`other_candidate`。
3. 保留但本轮不施工通道：`wechat_candidate`。
4. 单业务对象：`4000 元竞标服务费预授权额度`。
5. 单完成真相：Server 回读 `authorizationStatus=frozen`。
6. 单 App-facing 入口族：既有 create / freeze-init / status。

当前不得进入真实写链和云端联调的原因：

1. 已只读核实云端 Nginx 存在 `POST /server/exhibition/p0-pay/payment-callbacks/alipay` ingress。
2. 已只读核实云端 Server 进程存在 Alipay APP Pay 必要 runtime config 项，但未输出任何配置值。
3. 支付宝沙箱 / 白名单的真实 callback delivery 尚未形成可引用回执。
4. 未取得外部渠道真实 callback delivery 证据前，不得创建真实资金订单、不得拉起 Alipay SDK、不得声称真实资金通道闭环。

## 1. App-facing Contract

本轮复用既有 App-facing 路径，不新增接口。

```text
POST /api/app/project/{projectId}/bid-service-fee-authorizations
POST /api/app/project/{projectId}/bid-service-fee-authorizations/{authorizationId}/freeze-init
GET  /api/app/project/{projectId}/bid-service-fee-authorizations/{authorizationId}
```

### 1.1 create request / response

Create request 继续冻结为：

| Field | Frozen contract | Rule |
|---|---|---|
| `bidParticipationRequestId` | string | 绑定当前竞标参与申请 |
| `expectedAmount` | number | 当前必须为 `4000` |
| `expectedCurrency` | `CNY` | 不开放多币种 |
| `ruleVersion` | string | 使用冻结规则版本 |
| `ruleSnapshotHash` | string | 使用冻结规则快照 |
| `idempotencyKey` | string | App/BFF 仅传递，Server 处理幂等 |

Create response 继续冻结为：

| Field | Frozen contract | Rule |
|---|---|---|
| `authorizationId` | string | Server truth |
| `authorizationStatus` | `BidServiceFeeAuthorizationStatus` | Server truth |
| `authorizationQuotaAmount` | number | 当前为 `4000` |
| `currency` | `CNY` | 当前唯一币种 |
| `channelCandidates` | string[] | 可包含候选，但不代表渠道运行可用 |
| `expiresAt` / `updatedAt` | date-time | Server truth |

### 1.2 freeze-init request / response

OpenAPI 已将 `payChannel` 从裸 string 收紧为：

```text
BidServiceFeeAuthorizationPayChannel:
  alipay_candidate
  wechat_candidate
  other_candidate
```

本轮实际施工只允许：

```text
alipay_candidate
```

`other_candidate` 仅用于 Server-owned 受控测试闭环；`wechat_candidate` 仅保留兼容，不进入本轮真实通道施工。

OpenAPI 已将 `channelActionType` 从裸 string 收紧为：

```text
PricingChannelActionType:
  sdk_payload
  web_redirect
  qr_code
  unavailable
```

解释：

1. `sdk_payload` 表示 Flutter 可尝试拉起原生 SDK。
2. `web_redirect` 表示受控测试或 H5 类 handoff，不代表支付成功。
3. `qr_code` 为后续扩展保留，本轮不施工。
4. `unavailable` 必须 fail-closed，不得本地伪成功。

### 1.3 status response

OpenAPI 已补齐 `expired`，当前授权状态冻结为：

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

Flutter 只能在 Server/BFF 回读 `authorizationStatus=frozen` 时展示预授权完成。

## 2. Server Callback Contract

Server callback path 继续冻结为：

```text
POST /server/exhibition/p0-pay/payment-callbacks/{paymentChannel}
```

Alipay 对应：

```text
POST /server/exhibition/p0-pay/payment-callbacks/alipay
```

该 path 不是 App-facing path，BFF 不得接收或转发 provider callback。

## 3. Alipay Callback Field Mapping

Alipay callback 输入字段与 Server canonical callback command 的映射冻结如下：

| Alipay field | Server canonical field | Rule |
|---|---|---|
| `out_trade_no` | `merchantOrderNo` | 用于定位 Server payment order |
| `trade_no` | `channelOrderId` | 支付宝交易号 |
| `notify_id` | `providerEventId` | 优先作为 callback 幂等事件源 |
| `notify_id` or `trade_no` | `channelEventId` | 缺少 `notify_id` 时降级使用 `trade_no` |
| `notify_type` | `eventType` | 不由 Flutter 解释 |
| `trade_status` | `eventStatus` | Server 归一化为成功/失败/关闭 |
| `total_amount` / `receipt_amount` | `amount` | 必须与 Server payment order amount 匹配 |
| runtime currency | `currency` | 当前固定 `CNY` |
| `app_id` | app id verification input | 必须与 runtime config 匹配 |
| `sign_type` | signature algorithm input | 当前仅允许 RSA2 |
| `sign` | signature input | 验签失败不得推进状态 |

## 4. Idempotency And Duplicate Callback

幂等冻结如下：

| Operation | Idempotency owner | Idempotency input |
|---|---|---|
| create authorization | Server | `idempotencyKey` + actor / project / request binding |
| freeze-init | Server | `idempotencyKey` + authorization binding |
| provider callback | Server | `paymentChannel` + `channelEventId` |

重复 callback 必须：

1. 返回 duplicate 语义或 no-op apply 语义。
2. 不重复推进 payment order。
3. 不重复推进 authorization。
4. 不重复解锁消息发送。

## 5. State Flow

### 5.1 Authorization state

正路径：

```text
pending_freeze -> frozen
```

失败 / 关闭路径：

```text
pending_freeze -> failed
pending_freeze -> cancelled
pending_freeze -> expired
```

本轮不开放的后续状态执行：

```text
release_pending
released
charge_pending
charged
breach_hold
```

这些状态可保留在 contracts 中，但不得在本轮新增执行入口。

### 5.2 Payment order state

Alipay APP Pay 最小路径：

```text
created -> pending_user_confirm -> succeeded
created -> pending_user_confirm -> failed
created -> pending_user_confirm -> closed
created -> pending_user_confirm -> expired
```

只有 `succeeded` 且金额、币种、订单、签名全部匹配时，Server 才允许推进 authorization 到 `frozen`。

## 6. Error And Reason Codes

App-facing 继续使用既有错误族，不新增裸 `/api/app/payment/*` 错误面：

| Code | Meaning |
|---|---|
| `BID_SERVICE_FEE_AUTHORIZATION_REQUIRED` | 竞标服务费预授权仍未满足 |
| `BID_SERVICE_FEE_AUTHORIZATION_CREATE_REJECTED` | 创建预授权被拒绝 |
| `BID_SERVICE_FEE_AUTHORIZATION_NOT_FOUND` | 预授权对象不存在 |
| `BID_SERVICE_FEE_AUTHORIZATION_FREEZE_INIT_REJECTED` | 拉起预授权通道被拒绝 |
| `BID_SERVICE_FEE_AUTHORIZATION_INVALID_STATE` | 当前状态不可执行该动作 |
| `P0_PAY_INVALID` | 参数、通道、回调或规则输入无效 |
| `P0_PAY_RESOURCE_UNAVAILABLE` | 资源或运行能力不可用 |
| `P0_PAY_PERMISSION_DENIED` | 当前组织无权访问该对象 |
| `P0_PAY_STATE_CONFLICT` | 当前资金状态冲突 |
| `P0_PAY_IDEMPOTENCY_CONFLICT` | 幂等键冲突 |

Provider / Server audit reason code 冻结如下，默认不直接暴露给普通用户：

| Reason | Meaning |
|---|---|
| `alipay_app_pay_disabled` | 支付宝 APP Pay 运行开关未开 |
| `alipay_runtime_config_missing` | 支付宝运行配置缺失 |
| `alipay_public_key_missing` | 验签公钥缺失 |
| `alipay_signature_missing` | callback 缺少签名 |
| `alipay_signature_type_unsupported` | 非 RSA2 签名 |
| `alipay_app_id_mismatch` | callback app id 不匹配 |
| `alipay_signature_invalid` | 验签失败 |
| `payment_order_not_found` | 找不到 Server payment order |
| `payment_amount_mismatch` | callback 金额不匹配 |
| `unsupported_event_type` | 当前事件类型不支持推进业务状态 |

## 7. Layer Boundary

| Layer | Allowed | Forbidden |
|---|---|---|
| Flutter | 拉起 SDK / H5 handoff，轮询 status，展示等待/失败/完成 | 本地写 `frozen`、本地解锁消息、接收 provider callback |
| BFF | 转发 App-facing create / freeze-init / status，归一化错误 | 保存支付结果、拥有状态机、接 provider callback |
| Server | 签单、验签、幂等、状态推进、审计 | 绕过验签推进真实通道、把测试通道伪装成真实资金 |
| Cloud ingress | 将 provider callback 安全路由到 Server | 将 callback 路由到 BFF / Flutter |

## 8. OpenAPI / Generated Closure

本轮已完成：

1. `docs/01_contracts/openapi.yaml` 补齐 `BidServiceFeeAuthorizationStatus.expired`。
2. `docs/01_contracts/openapi.yaml` 新增 `BidServiceFeeAuthorizationPayChannel`。
3. `docs/01_contracts/openapi.yaml` 新增 `PricingChannelActionType`。
4. `BidServiceFeeAuthorizationFreezeInitRequest.payChannel` 改为枚举 ref。
5. `BidServiceFeeAuthorizationFreezeInitResponse.channelActionType` 改为枚举 ref。
6. `pnpm contracts:generate` 通过。
7. `pnpm contracts:check` 通过。

Generated outputs:

```text
packages/contracts/contracts-manifest.json
packages/contracts/openapi/openapi.bundle.json
```

当前 TypeScript generated API 类型未产生文本 diff，合同变化已反映在 bundled OpenAPI 与 manifest hash。

## 8.1 Cloud Runtime Read-Only Evidence

本轮只读核实：

| Item | Result |
|---|---|
| BFF health | `200 OK` |
| Server health | `200 OK` |
| Alipay callback ingress | `present` |
| `P0_PAY_ALIPAY_APP_PAY_ENABLED` | `present` |
| `P0_PAY_ALIPAY_APP_ID` | `present` |
| Alipay app private key config | `present` |
| Alipay public key config | `present` |
| `P0_PAY_ALIPAY_NOTIFY_URL` | `present` |

未核实且不得推断：

1. 支付宝沙箱 / 白名单真实可用。
2. Alipay provider 能成功投递 callback。
3. Alipay callback 一定能推进 `authorizationStatus=frozen`。

## 9. No-Go

本 contracts 冻结单不允许：

1. 新增扣款接口。
2. 新增退款接口。
3. 新增结算接口。
4. 新增发票接口。
5. 新增钱包 / 余额 / 金币接口。
6. 让 BFF 拥有支付状态。
7. 让 Flutter 本地判断真实资金完成。
8. 用 `other_candidate` 结果声称支付宝真实资金通过。
9. 在 callback ingress 未证明前进入真实写链。

## 10. 是否允许进入 Day-3

裁决：

```text
允许进入 Day-3：是，限本地 Server 源码和测试最小实现。
```

允许范围：

1. 复核现有 Alipay adapter 是否已经满足本冻结单。
2. 补齐 Server 金额、验签、幂等、重复 callback、失败不推进的 targeted tests。
3. 如源码缺最小字段映射，可在 `apps/server/src/modules/p0_pay/*` 内最小补丁。

禁止范围：

1. 不允许真实创建 Alipay 资金订单。
2. 不允许拉起 Alipay SDK。
3. 不允许调用 provider callback。
4. 不允许部署或重启云端服务。
5. 不允许用本地测试声称云端真实资金闭环。

Day-7 仍需补齐：

1. 支付宝沙箱 / 白名单真实可用回执。
2. provider callback delivery 证据。
3. `authorizationStatus=frozen` 云端回读证据。
4. `chatAvailability.canSendMessage=true` 云端回读证据。

## 11. Day-2 结论

Day-2 完成度：`100%`。

整体九天任务完成度：`22.2%`。

当前阶段门禁：`Day-3 Blocked`。
