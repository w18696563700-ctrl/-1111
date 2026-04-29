---
owner: Codex 总控
status: superseded
purpose: >
  Freeze the L4 BFF app-facing surface for `exhibition_trade_task_p0_pay`,
  covering app-facing route exposure, Server mapping, auth consolidation,
  request shaping, response shaping, idempotency forwarding, controlled error
  normalization, payment-channel payload pass-through, and message-building
  read-only payment-status handoff while explicitly forbidding BFF-owned payment
  truth, callback truth, persistence, wallet, guarantee deposit, settlement,
  invoice, or a second state machine.
layer: L4 BFF
author_date_local: 2026-04-29
freeze_date_local: 2026-04-30
version: V1.3
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/exhibition_trade_task_payment_mainline_p0_pay_freeze_v1_3.md
  - docs/01_contracts/exhibition_trade_task_p0_pay_contracts_addendum_v1_3.md
  - docs/02_backend/exhibition_trade_task_p0_pay_server_truth_addendum_v1_3.md
  - docs/02_backend/exhibition_trade_task_p0_pay_persistence_state_audit_freeze_addendum_v1_3.md
  - docs/03_bff/project_transaction_skeleton_p0_bff_surface_addendum.md
  - docs/03_bff/messages_interaction_center_and_bidder_carry_bff_surface_freeze_addendum.md
  - docs/03_bff/bff_ssot.md
  - docs/03_bff/bff_routes.md
---

## Supersede Note

本文件已被 [platform_pricing_bff_surface_master_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/platform_pricing_bff_surface_master_v1.md) 正式覆盖。

自 `2026-04-29` 起，本文件不再作为当前收费 `L4 BFF surface` authority。

以下旧 `P0-Pay` BFF 语义当前只保留为历史迁移参考，不得继续指挥现行收费施工：

1. 以 `/api/app/exhibition/trade-tasks/*` 作为当前收费 app-facing 主骨架
2. 以 `inquiry-deposit/orders` 作为当前唯一 `200` 资金对象
3. 以旧 `service-fee-authorizations + 3% / quotedAmount dynamic authorization` 作为当前 `4000` 收费主线
4. 以 `p0-pay-summary` 作为当前唯一收费只读摘要

本文件当前只保留三类用途：

1. 审计回溯
2. 差异比对
3. 旧实现迁移参考

# 展览平台任务发布与交易收费规则 P0-Pay BFF Surface Freeze V1.3

## 1. Scope

本冻结单覆盖 P0-Pay 的 `L4 BFF surface`。

BFF 当前只允许承担：

1. `/api/app/*` app-facing route 暴露。
2. auth / session / organization scope 汇聚。
3. request shaping。
4. response shaping。
5. visibility trimming。
6. idempotency key 转发与冲突错误归一。
7. controlled error normalization。
8. 支付通道拉起 payload 的透明 pass-through。
9. 消息楼资金状态只读聚合。

BFF 当前不得承担：

1. 业务真相。
2. 资金真相。
3. 支付回调真相。
4. 支付订单持久化。
5. 预授权状态机。
6. 发单诚意金状态机。
7. 合同确认状态机。
8. 第二套交易状态机。
9. 钱包、余额、金币、资金池。
10. 履约保证金。
11. 清分结算、发票、财务后台。

## 2. BFF Freeze Conclusion

当前正式冻结：

- Flutter 只调用 BFF `/api/app/*`。
- BFF 只调用 Server 内部 route family。
- Server 是 P0-Pay 唯一 business truth / payment truth / callback truth / audit truth owner。
- BFF 可塑形 app-friendly DTO，但不能改写 money state。
- BFF 可做轻幂等 carrier 传递，但不能本地裁决资金幂等结果。

本轮不是：

- `apps/bff/**` 实现。
- 云上 BFF 发布。
- 支付通道回调配置。
- Computer Use 联调。

## 3. App-facing Path Family

当前 BFF 唯一对外 path family 与 L2 保持一致：

| App-facing path | Method | BFF 定位 |
|---|---|---|
| `/api/app/exhibition/trade-tasks` | `POST` | 创建交易任务 request shaping |
| `/api/app/exhibition/trade-tasks/{taskId}` | `GET` | 任务详情 response shaping |
| `/api/app/exhibition/trade-tasks/{taskId}/authenticity-materials` | `POST` | 真实性材料绑定 request shaping |
| `/api/app/exhibition/trade-tasks/{taskId}/fixed-price-bids` | `POST` | 明价竞标提交 request shaping |
| `/api/app/exhibition/trade-tasks/{taskId}/fixed-price-bids/{bidId}/service-fee-authorizations` | `POST` | 平台服务费预授权订单创建 shaping |
| `/api/app/exhibition/trade-tasks/{taskId}/fixed-price-bids/{bidId}/service-fee-authorizations/{authorizationId}/authorize-init` | `POST` | 支付通道预授权拉起 shaping |
| `/api/app/exhibition/trade-tasks/{taskId}/fixed-price-bids/{bidId}/service-fee-authorizations/{authorizationId}` | `GET` | 预授权状态只读 shaping |
| `/api/app/exhibition/trade-tasks/{taskId}/inquiry-deposit/orders` | `POST` | 发单诚意金订单创建 shaping |
| `/api/app/exhibition/trade-tasks/{taskId}/inquiry-deposit/orders/{depositOrderId}/pay-init` | `POST` | 发单诚意金支付拉起 shaping |
| `/api/app/exhibition/trade-tasks/{taskId}/inquiry-deposit/orders/{depositOrderId}` | `GET` | 发单诚意金状态只读 shaping |
| `/api/app/exhibition/trade-tasks/{taskId}/inquiry-quotations` | `POST` | 询价报价提交 shaping |
| `/api/app/exhibition/trade-tasks/{taskId}/inquiry-result` | `POST` | 询价结果处理 shaping |
| `/api/app/exhibition/trade-tasks/{taskId}/contract-confirmations` | `POST` | 合同确认 shaping |
| `/api/app/exhibition/trade-tasks/{taskId}/p0-pay-summary` | `GET` | P0-Pay 只读聚合 shaping |

当前明确不新增：

1. `/api/app/payment/*`。
2. `/api/app/wallet/*`。
3. `/api/app/balance/*`。
4. `/api/app/settlement/*`。
5. `/api/app/invoice/*`。
6. `/api/app/guarantee-deposit/*`。

## 4. Server Mapping Boundary

BFF 内部只允许映射到 Server-owned P0-Pay route family。

建议 server-facing family：

| App-facing path family | Server-facing family | 说明 |
|---|---|---|
| `trade-tasks` | `/server/exhibition/trade-tasks` | 交易任务真相由 Server 持有 |
| `authenticity-materials` | `/server/exhibition/trade-tasks/{taskId}/authenticity-materials` | 只绑定 confirmed FileAsset |
| `fixed-price-bids` | `/server/exhibition/trade-tasks/{taskId}/fixed-price-bids` | 报价与方案真相由 Server 持有 |
| `service-fee-authorizations` | `/server/exhibition/p0-pay/service-fee-authorizations/*` | 预授权订单与状态由 Server 持有 |
| `inquiry-deposit/orders` | `/server/exhibition/p0-pay/inquiry-deposits/*` | 发单诚意金订单与状态由 Server 持有 |
| `inquiry-quotations` | `/server/exhibition/trade-tasks/{taskId}/inquiry-quotations` | 席位占用由 Server 事务裁决 |
| `inquiry-result` | `/server/exhibition/trade-tasks/{taskId}/inquiry-result` | 处理结果和诚意金 outcome 由 Server 裁决 |
| `contract-confirmations` | `/server/exhibition/trade-tasks/{taskId}/contract-confirmations` | 最终成交金额由 Server 持有 |
| `p0-pay-summary` | `/server/exhibition/trade-tasks/{taskId}/p0-pay-summary` | 只读聚合由 Server 派生 |

Mapping rules：

1. `/server/*` 不得暴露给 Flutter。
2. BFF 不得发明未在 L2/L3 冻结的 server-facing business family。
3. 如实现阶段需要复用既有 `bid/submit` 内部 carrier，只能作为 BFF/Server 内部 adapter，不得改变 app-facing L2 语义。

## 5. Auth And Scope Shaping

BFF 必须统一承接：

- auth carrier。
- current user。
- current organization。
- actor role。
- request id / trace id。
- idempotency key。

BFF 必须保持：

1. 创建任务、竞标、报价、支付拉起、合同确认均为 private-auth。
2. 任务详情可按既有 project detail 策略支持 public / optional auth，但 P0-Pay 私域资金字段必须 visibility-trim。
3. 资金状态读取必须只对业务相关组织可见。
4. BFF 不得本地判断“是否可发布 / 是否可竞标 / 是否可扣款”的最终结论。

## 6. Request Shaping

BFF request shaping 只允许：

1. 字段白名单裁剪。
2. 类型基本校验。
3. envelope 归一。
4. idempotency key 透传。
5. clientPlatform 归一。
6. payChannel 归一为 L2 枚举。
7. auth / organization scope 注入到 Server 请求上下文。

BFF request shaping 不得：

1. 本地计算平台服务费最终真值。
2. 本地决定 3% 费率之外的会员费率。
3. 本地发报价席位号。
4. 本地创建 payment order id。
5. 本地生成 channel order id。
6. 本地补签支付通道 payload。
7. 本地保存支付账户信息。

## 7. Response Shaping

BFF response shaping 只允许：

1. 保留 L2 冻结字段。
2. 隐藏 Server internal 字段。
3. 将 Server state 映射为 app-facing enum。
4. 将 unavailable / forbidden / invalid-state 归一到稳定 error envelope。
5. 将 `channelPayload` 作为 opaque payload 传给 Flutter。
6. 为 Flutter 提供 `nextAction` / `routeTarget`。

BFF response shaping 不得：

1. 把支付失败伪装成成功。
2. 把 upstream 404 / transport gap 伪装成空成功。
3. 把 `authorized` 写成 `charged`。
4. 把 `paid` 写成 `refunded`。
5. 把 `pending_contract_confirm` 写成合同已完成。
6. 将支付通道 raw callback payload 原样透给 Flutter。

## 8. Payment Channel Payload Boundary

BFF 可以透传：

- `channelActionType`
- `channelPayload`
- `paymentReferenceId`
- `callbackAwaiting`
- `expiresAt`

BFF 不得读取、持久化或扩写：

- 支付宝账号。
- 微信账号。
- 银行卡号。
- 支付密码。
- 短信验证码。
- 长期自动扣款授权。
- 用户资金账户控制权。
- provider raw callback payload。

`channelPayload` 在 BFF 中只允许是 opaque object。

## 9. P0-Pay Summary Shaping

`GET /api/app/exhibition/trade-tasks/{taskId}/p0-pay-summary`

BFF 最小输出：

- `taskId`
- `taskType`
- `platformServiceFee`
- `inquiryDeposit`
- `contractConfirmation`
- `messageDisplaySummary`
- `updatedAt`

`messageDisplaySummary` 必须：

- `readOnly = true`
- 不含支付执行 action。
- 不含扣费裁判 action。
- 不含履约保证金 action。

BFF 不得在 summary 中出现：

- wallet balance。
- coin balance。
- guarantee frozen amount。
- settlement amount。
- invoice status。

## 10. Message-building Read-only Handoff

消息楼资金状态只能来自：

- P0-Pay Server summary。
- BFF read-only shaping。

消息楼最多展示：

1. 平台服务费预授权状态。
2. 发单诚意金状态。
3. 合同确认待处理。
4. 只读 routeTarget。

消息楼不得展示或触发：

1. 支付执行按钮。
2. 释放 / 扣除裁判按钮。
3. 履约保证金冻结按钮。
4. 完整争议处理台。
5. 群聊 / 泛私信 / 全局未读治理。

## 11. Idempotency And Retry Boundary

BFF 可以：

1. 要求写命令携带 `idempotencyKey`。
2. 将 `idempotencyKey` 透传给 Server。
3. 对网络失败提供安全重试提示。
4. 将 Server `IDEMPOTENCY_KEY_CONFLICT` 归一给 Flutter。

BFF 不得：

1. 本地缓存成功写结果作为资金真相。
2. 本地判定重复请求成功。
3. 本地创建幂等记录表。
4. 本地绕过 Server 事务裁决。

## 12. Error Mapping

BFF 必须保留并归一以下错误族：

- `AUTH_SESSION_INVALID`
- `ORGANIZATION_CERTIFICATION_REQUIRED`
- `TRADE_TASK_CREATE_REJECTED`
- `TRADE_TASK_NOT_FOUND`
- `TRADE_TASK_INVALID_STATE`
- `TRADE_TASK_AUTHENTICITY_MATERIAL_REQUIRED`
- `TRADE_TASK_AUTHENTICITY_DECLARATION_REQUIRED`
- `FIXED_PRICE_BID_CREATE_REJECTED`
- `SERVICE_FEE_AUTHORIZATION_CREATE_REJECTED`
- `SERVICE_FEE_AUTHORIZATION_INIT_REJECTED`
- `SERVICE_FEE_AUTHORIZATION_RESULT_UNAVAILABLE`
- `INQUIRY_DEPOSIT_ORDER_CREATE_REJECTED`
- `INQUIRY_DEPOSIT_PAY_INIT_REJECTED`
- `INQUIRY_DEPOSIT_RESULT_UNAVAILABLE`
- `INQUIRY_QUOTE_SEAT_FULL`
- `INQUIRY_QUOTATION_CREATE_REJECTED`
- `INQUIRY_RESULT_PROCESSING_REJECTED`
- `CONTRACT_CONFIRMATION_REJECTED`
- `P0_PAY_SUMMARY_UNAVAILABLE`
- `PAYMENT_CHANNEL_UNAVAILABLE`
- `PAYMENT_CHANNEL_CONSTRAINT_REQUIRES_REVERIFICATION`
- `IDEMPOTENCY_KEY_CONFLICT`

Error mapping rules：

1. unknown critical upstream error 不得伪装成功。
2. channel constraint 必须显示为 controlled unavailable。
3. invalid-state 必须保留为 invalid-state，不得改成用户可无脑重试。
4. forbidden 不得改成 unavailable。
5. unavailable 不得改成空成功。

## 13. BFF No-Go

当前 BFF 明确禁止：

1. BFF persistence。
2. BFF payment order truth。
3. BFF payment callback endpoint。
4. BFF fee calculation final truth。
5. BFF inquiry seat final truth。
6. BFF contract confirmation final truth。
7. BFF wallet / balance / coin。
8. BFF guarantee deposit freeze / release / deduction。
9. BFF settlement / invoice / finance-admin。
10. BFF message-building payment execution。
11. BFF second state machine。

## 14. Stage Conclusion

当前阶段结论：

- `P0-Pay L4 BFF surface freeze = 通过`。
- `Go for L5 Flutter consumption freeze authoring`。
- `No-Go for BFF implementation until implementation unlock stage gate passes`。
- `No-Go for integration`。
- `No-Go for release-prep`。
- `No-Go for production release`。

## 15. Formal Conclusion

P0-Pay BFF surface 正式冻结为：

```text
BFF exposes /api/app P0-Pay surfaces, forwards to Server, shapes app-facing payloads, and never owns payment truth.
```
