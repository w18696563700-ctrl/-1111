---
owner: Codex 总控
status: Frozen
freeze_date_local: 2026-05-07
purpose: Freeze the minimum Server-owned test authorization path for validating project communication free-send unlock without adding payment, wallet, settlement, invoice, or DB schema scope.
layer: L0 SSOT
---

# 竞标服务费预授权 Test Authorization 最小方案 Addendum V1

## 0. 总裁决

本 Addendum 冻结 `4000 元竞标服务费预授权额度` 在测试阶段的最小可验收方案：

1. 测试放行必须由 Server 持有和执行。
2. 优先复用既有 `other` 受控支付通道、`PaymentOrder`、`PaymentCallbackEvent`、`PaymentTransaction`、`PlatformServiceFeeAuthorization` 和审计记录。
3. 不新增钱包、支付账户、资金池、真实扣费、保证金、结算、发票或自动解冻能力。
4. 不新增 DB schema，不执行 migration。
5. 不扩 OpenAPI，不生成 generated。
6. Flutter 不得本地绕过预授权，不得本地模拟已授权，不得本地模拟消息已发送。
7. BFF 只透传和 projection，不持有 test authorization 真值。

## 1. Supersede 范围

本 Addendum 只补充《竞标服务费预授权 Gate 后移与项目沟通开放条件 Addendum V1》中“测试环境放行原则”的可施工最小口径。

本 Addendum 不重开、不修改：

1. `bid submit` 后移 gate 裁决。
2. 项目创建到发布主链路。
3. `200 元项目真实性诚意金` 主规则。
4. BidAward / Order / Contract seed。
5. 最终合同金额确认。
6. 支付、扣费、保证金、结算、发票、钱包。

## 2. 最小测试授权链路

测试阶段的最小链路为：

1. 竞标方已有 submitted Bid 和三份竞标资料。
2. 发布方已确认三份竞标资料。
3. Server 创建 `PlatformServiceFeeAuthorization`，状态为 `pending_freeze`。
4. Server 通过既有 `other` 通道创建 `PaymentOrder`，业务类型为 `bid_service_fee_authorization_freeze`，订单角色为 `authorization`。
5. 受控测试回调携带 HMAC 签名进入 Server callback。
6. Server 校验签名、订单号、金额和通道。
7. Server 将 `PaymentOrder` 标记为 `succeeded`，写入 `PaymentTransaction`。
8. Server 将 `PlatformServiceFeeAuthorization` 标记为 `frozen` 并写入 `frozenAt / authorizedAt`。
9. 项目沟通 `chatAvailability.canSendMessage` 由 Server 读取 frozen 授权后变为 `true`。
10. 竞标方真实发送消息时，Server 才允许落库、生成 thread last message 和对方 unread。

## 3. Server / BFF / Flutter 边界

### 3.1 Server

Server 负责：

1. 创建预授权对象。
2. 创建受控 `other` 通道 authorization order。
3. 校验受控 callback 签名。
4. 写授权成功状态、交易记录和审计记录。
5. 作为 `chatAvailability.canSendMessage` 唯一真值 owner。
6. 拒绝未授权状态下的真实消息发送。

### 3.2 BFF

BFF 负责：

1. 透传 `/api/app/project/{projectId}/bid-service-fee-authorizations*` 到 Server。
2. 保持 `authorizationStatus`、`channelActionType`、`channelPayload`、`callbackAwaiting`、`updatedAt` 等字段 projection。
3. 不生成授权状态。
4. 不自行放行项目沟通发送。

### 3.3 Flutter

Flutter 负责：

1. 展示预授权入口和状态。
2. 展示 `other` 测试通道返回的受控 handoff 状态。
3. 根据 BFF / Server projection 刷新聊天锁态。
4. 未授权发送失败时展示提示。
5. 授权后再允许真实发送请求成功展示。

Flutter 不得：

1. 在本地把授权状态改成成功。
2. 本地插入已发送消息。
3. 在 Server 拒绝时生成对方 unread。

## 4. Contracts 裁决

现有 OpenAPI 已包含：

1. `POST /api/app/project/{projectId}/bid-service-fee-authorizations`
2. `POST /api/app/project/{projectId}/bid-service-fee-authorizations/{authorizationId}/freeze-init`
3. `GET /api/app/project/{projectId}/bid-service-fee-authorizations/{authorizationId}`

本最小方案只要求 Server 补齐既有 BFF 转发目标，不新增 App-facing path，不新增 schema，不生成 generated。

## 5. No-Go

本轮不得做：

1. 真实支付宝 / 微信预授权完整接入。
2. 自动解冻定时任务。
3. 钱包、余额、发票、结算、扣费。
4. 保证金。
5. Flutter 本地授权白名单。
6. 手动 DB 改授权状态。
7. 绕过 Server callback / audit 的测试放行。
8. 将 `PaymentOrder` 或聊天消息当成最终合同金额真值。

## 6. 验收标准

最小验收必须同时满足：

1. `POST /api/app/project/{projectId}/bid-service-fee-authorizations` 可创建或复用当前 Bid 的授权对象。
2. `POST /api/app/project/{projectId}/bid-service-fee-authorizations/{authorizationId}/freeze-init` 可用 `other_candidate` 创建受控 authorization order。
3. 受控 Server callback 成功后，授权状态变为 `frozen`。
4. A/B 双侧 `chatAvailability.canSendMessage=true`。
5. A 侧真实发送消息成功落库。
6. B 侧可读到该消息，且 unread / thread last message 正常变化。
7. 重复 callback 幂等，不重复生成授权成功副作用。
8. 未授权前发送仍被 Server 拒绝。
