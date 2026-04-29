---
owner: Codex 总控
status: superseded
purpose: >
  Freeze the L5 Flutter consumption boundary for `exhibition_trade_task_p0_pay`,
  covering task-publish type selection, authenticity materials, fixed-price bid
  service-fee preauthorization, inquiry deposit payment, inquiry quotation seats,
  inquiry result processing, contract confirmation, payment result polling,
  project-detail and message-building read-only P0-Pay status display, controlled
  failure states, and the strict rule that Flutter only consumes BFF app-facing
  surfaces and never owns payment truth or calls Server directly.
layer: L5 Frontend
author_date_local: 2026-05-01
freeze_date_local: 2026-05-02
version: V1.3
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/exhibition_trade_task_payment_mainline_p0_pay_freeze_v1_3.md
  - docs/01_contracts/exhibition_trade_task_p0_pay_contracts_addendum_v1_3.md
  - docs/02_backend/exhibition_trade_task_p0_pay_server_truth_addendum_v1_3.md
  - docs/02_backend/exhibition_trade_task_p0_pay_persistence_state_audit_freeze_addendum_v1_3.md
  - docs/03_bff/exhibition_trade_task_p0_pay_bff_surface_freeze_addendum_v1_3.md
  - docs/04_frontend/project_transaction_skeleton_p0_frontend_surface_addendum.md
  - docs/04_frontend/messages_interaction_center_and_bidder_carry_frontend_consumption_freeze_addendum.md
  - docs/04_frontend/frontend_ssot.md
  - docs/04_frontend/flutter_screen_map.md
---

## Supersede Note

本文件已被 [platform_pricing_frontend_consumption_master_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/04_frontend/platform_pricing_frontend_consumption_master_v1.md) 正式覆盖。

自 `2026-04-29` 起，本文件不再作为当前收费 `L5 Flutter consumption` authority。

以下旧 Flutter 收费消费语义当前只保留为历史迁移参考，不得继续指挥现行收费施工：

1. 以 `trade-task` 作为当前收费 Flutter 主对象
2. 以 `询价发单诚意金` 作为当前唯一 `200` 对象
3. 以 `3% + 预计平台服务费 + service-fee preauthorization` 作为当前 `4000` 主消费面
4. 以 `p0-pay-summary` 作为当前唯一收费只读摘要

本文件当前只保留三类用途：

1. 审计回溯
2. 差异比对
3. 旧实现迁移参考

# 展览平台任务发布与交易收费规则 P0-Pay Flutter Consumption Freeze V1.3

## 1. Scope

本冻结单只覆盖 Flutter 对 P0-Pay 的消费边界。

Flutter 当前只允许：

1. 消费 BFF `/api/app/*`。
2. 展示任务发布类型选择。
3. 展示真实性材料和声明。
4. 展示明价竞标报价与平台服务费预授权确认。
5. 拉起支付通道 SDK / H5 / QR 的 channel payload。
6. 轮询 BFF 返回的支付 / 预授权状态。
7. 展示询价发单诚意金支付入口和状态。
8. 展示询价报价席位。
9. 展示询价结果处理入口。
10. 展示合同确认与最终成交金额确认入口。
11. 在项目详情和消息楼展示只读 P0-Pay 状态。
12. 展示 controlled loading / content / failure / unavailable / forbidden / invalid-state。

Flutter 当前不得：

1. 直连 Server。
2. 本地持有资金真相。
3. 本地持有支付回调真相。
4. 本地计算最终平台服务费真相。
5. 本地判断报价席位最终占用。
6. 本地判断合同确认最终生效。
7. 保存支付宝账号、微信账号、银行卡号、支付密码、短信验证码或长期扣款授权。
8. 实现履约保证金。
9. 实现钱包、余额、金币或资金池。

## 2. Frontend Freeze Conclusion

当前正式冻结：

- Flutter App 是本地唯一前端。
- Flutter 只消费 BFF app-facing projection。
- BFF/Server 在阿里云，本地不得假设存在可写可运行后端。
- 支付动作通过 BFF 创建订单，再由 Flutter 拉起支付通道。
- 支付结果以 BFF read status 为准。
- 消息楼只展示只读资金状态和 handoff。

本冻结单不是：

- `apps/mobile/**` 实现。
- Flutter 支付 SDK 集成完成。
- 隧道联调完成。
- Computer Use 联调完成。
- 上线批准。

## 3. Page / Route Carrier Matrix

| Flutter carrier | P0-Pay 定位 | 当前裁决 |
|---|---|---|
| `ProjectPublish` / project create flow | 选择明价竞标单或询价报价单 | 允许 |
| `ProjectPublish` authenticity section | 真实性材料和声明 | 允许 |
| `ProjectDetailPage` | P0-Pay 只读状态和 CTA handoff | 允许 |
| `BidSubmitPage` or fixed-price bid flow | 明价竞标报价与平台服务费预授权 | 允许 |
| `InquiryDepositSheet` or payment sheet | 询价发单诚意金支付 | 允许 |
| `InquiryQuotationPage` or quote sheet | 询价报价与席位状态 | 允许 |
| `InquiryResultSheet` | 发布方选择 / 关闭 / 取消说明 | 允许 |
| `ContractConfirmationSheet` | 最终成交金额确认 | 允许 |
| `PaymentResultPage` or result sheet | 支付 / 预授权状态轮询 | 允许 |
| `MessagesPage` / bid thread | 只读资金状态展示和 handoff | 允许 |

当前不新开：

1. 通用支付中心页面。
2. 钱包页面。
3. 余额页面。
4. 保证金中心页面。
5. 结算中心页面。
6. 发票中心页面。
7. 财务后台页面。
8. 完整争议处理台。

## 4. Canonical API Consumption

Flutter 只允许消费以下 BFF app-facing routes：

- `POST /api/app/exhibition/trade-tasks`
- `GET /api/app/exhibition/trade-tasks/{taskId}`
- `POST /api/app/exhibition/trade-tasks/{taskId}/authenticity-materials`
- `POST /api/app/exhibition/trade-tasks/{taskId}/fixed-price-bids`
- `POST /api/app/exhibition/trade-tasks/{taskId}/fixed-price-bids/{bidId}/service-fee-authorizations`
- `POST /api/app/exhibition/trade-tasks/{taskId}/fixed-price-bids/{bidId}/service-fee-authorizations/{authorizationId}/authorize-init`
- `GET /api/app/exhibition/trade-tasks/{taskId}/fixed-price-bids/{bidId}/service-fee-authorizations/{authorizationId}`
- `POST /api/app/exhibition/trade-tasks/{taskId}/inquiry-deposit/orders`
- `POST /api/app/exhibition/trade-tasks/{taskId}/inquiry-deposit/orders/{depositOrderId}/pay-init`
- `GET /api/app/exhibition/trade-tasks/{taskId}/inquiry-deposit/orders/{depositOrderId}`
- `POST /api/app/exhibition/trade-tasks/{taskId}/inquiry-quotations`
- `POST /api/app/exhibition/trade-tasks/{taskId}/inquiry-result`
- `POST /api/app/exhibition/trade-tasks/{taskId}/contract-confirmations`
- `GET /api/app/exhibition/trade-tasks/{taskId}/p0-pay-summary`

Flutter 不得消费：

1. `/server/*`。
2. `/api/app/payment/*`。
3. `/api/app/wallet/*`。
4. `/api/app/settlement/*`。
5. `/api/app/invoice/*`。
6. `/api/app/guarantee-deposit/*`。

## 5. Project Publish Consumption

项目发布页允许新增：

1. 任务类型 segmented control：
   - `明价竞标单`
   - `询价报价单`
2. 项目真实性材料槽位。
3. 项目真实性声明勾选。
4. 询价报价单发单诚意金提示。

Flutter 必须：

1. 在未完成真实性声明前禁用提交。
2. 在真实性材料未 confirmed 前禁用公开发布。
3. 对询价报价单展示 200 元发单诚意金入口。
4. 对明价竞标单不向发布方展示发单诚意金。

Flutter 不得：

1. 本地判定认证通过。
2. 本地提升真实性等级。
3. 把 objectKey 当作材料真相。
4. 把发单诚意金写成押金、罚款或保证金。

## 6. Fixed-price Bid Consumption

明价竞标报价页允许展示：

- 报价金额。
- 报价有效期。
- 是否含税。
- 是否含运输。
- 是否含安装。
- 施工方案。
- 材料说明。
- 工艺说明。
- 搭建流程。
- 交付节点。
- 风险说明。
- 报价附件。
- 平台服务费预授权确认。

预授权确认页必须展示：

- 本次报价。
- 平台服务费率：3%。
- 预计服务费。
- 预授权不是实际扣费。
- 未中标自动释放。
- 中标并合同确认后正式扣费。
- 最终成交金额变化时重新计算。

Flutter 必须：

1. 先提交 bid，再按 BFF 返回 requirement 拉起预授权。
2. 只用 BFF 返回的 `estimatedFeeAmount` 展示预计金额。
3. 只用 BFF 返回的 `channelPayload` 拉起通道。
4. 轮询 BFF 预授权状态。

Flutter 不得：

1. 本地创建 authorizationId。
2. 本地生成支付通道签名。
3. 本地把 `authorized` 显示为已扣款。
4. 本地把未中标状态显示成已收费。

## 7. Inquiry Deposit Consumption

询价报价单发布方必须看到：

- `发单诚意金`
- `200 元`
- 用途说明。
- 合规处理后退回说明。
- 逾期不处理 / 恶意询价 / 虚假发布 / 绕单成立可扣除说明。

Flutter 必须：

1. 创建发单诚意金订单。
2. 拉起支付通道。
3. 轮询 BFF 状态。
4. 在 `paid` 前避免展示公开发布成功。
5. 在 `refunded / deducted / dispute_hold` 状态下展示只读结果和原因。

Flutter 不得：

1. 将 200 元称为押金。
2. 向工厂收取询价报价费。
3. 本地判断扣除成立。
4. 本地判断退回成功。

## 8. Inquiry Quotation And Result Consumption

询价报价页必须展示：

- 当前席位上限。
- 已用席位。
- 剩余席位。
- 报价入口是否开放。

Flutter 必须：

1. 以 BFF `quoteSeatSummary` 为准。
2. 席位满后禁用报价入口。
3. 报价截止后提示发布方处理。
4. 发布方处理结果时必须填写选择 / 关闭 / 取消说明。

Flutter 不得：

1. 本地抢占席位。
2. 本地发 seatNo。
3. 本地绕过 Server 提交第 6 个报价。
4. 本地判定诚意金扣除。

## 9. Contract Confirmation Consumption

合同确认入口允许展示：

- 中标 / 中选对象。
- 最终成交确认金额。
- 平台服务费最终金额。
- 多退少补或重新确认说明。
- 双方确认状态。

Flutter 必须：

1. 明确“合同确认才是正式扣平台服务费节点”。
2. 明确“中标不等于立即成交”。
3. 只按 BFF 返回的最终金额和服务费状态展示。
4. 对金额变化展示重新计算提示。

Flutter 不得：

1. 本地确认合同生效。
2. 本地触发扣费成功态。
3. 本地把发布预算作为收费真值。
4. 本地把工厂初始报价作为最终收费真值。

## 10. Payment Result And Polling

Flutter 支付结果页或 sheet 允许状态：

- `pending_user_confirm`
- `authorized`
- `paid`
- `succeeded`
- `failed`
- `expired`
- `cancelled`
- `release_pending`
- `released`
- `refund_pending`
- `refunded`
- `breach_hold`
- `dispute_hold`

Polling rules：

1. 只轮询 BFF status route。
2. 轮询必须有超时和停止条件。
3. 用户取消支付后展示可重试或返回。
4. callback awaiting 时展示等待确认，不伪装成功。
5. unknown / unavailable 必须展示 controlled failure。

Flutter 不得：

1. 接收支付通道回调。
2. 本地监听回调 URL 作为业务真相。
3. 本地持久化支付成功真相。
4. 以支付 SDK 返回码直接推进交易状态。

## 11. Project Detail And Message-building Read-only Display

项目详情和消息楼只允许展示：

1. 平台服务费预授权状态。
2. 发单诚意金状态。
3. 合同确认待处理。
4. 支付 / 预授权 result handoff。
5. 只读 routeTarget。

Flutter 必须：

1. 标记资金状态为只读。
2. 从 `p0-pay-summary` 或 BFF 聚合读状态。
3. 不在消息楼执行支付。
4. 不在消息楼执行扣费裁判。
5. 不在消息楼展示履约保证金裁判。

Flutter 不得：

1. 把消息楼改成支付执行台。
2. 把消息楼改成完整争议处理台。
3. 在消息楼产生资金状态。
4. 在消息楼修改资金状态。
5. 在消息楼裁定资金状态。

## 12. Controlled Failure States

Flutter 必须覆盖：

- `AUTH_SESSION_INVALID`
- `ORGANIZATION_CERTIFICATION_REQUIRED`
- `TRADE_TASK_INVALID_STATE`
- `SERVICE_FEE_AUTHORIZATION_RESULT_UNAVAILABLE`
- `INQUIRY_DEPOSIT_RESULT_UNAVAILABLE`
- `INQUIRY_QUOTE_SEAT_FULL`
- `PAYMENT_CHANNEL_UNAVAILABLE`
- `PAYMENT_CHANNEL_CONSTRAINT_REQUIRES_REVERIFICATION`
- `IDEMPOTENCY_KEY_CONFLICT`

UI 行为：

1. `AUTH_SESSION_INVALID`：引导登录。
2. `ORGANIZATION_CERTIFICATION_REQUIRED`：引导认证，不伪装可发布。
3. `PAYMENT_CHANNEL_CONSTRAINT_REQUIRES_REVERIFICATION`：展示通道暂不可用。
4. `IDEMPOTENCY_KEY_CONFLICT`：展示重复提交冲突，不自动成功。
5. unknown critical error：展示受控失败，不吞掉。

## 13. Frontend No-Go

当前 Flutter 明确禁止：

1. direct Server calls。
2. local payment truth。
3. local callback truth。
4. local fee final truth。
5. local quote seat final truth。
6. local contract confirmation truth。
7. wallet UI。
8. balance UI。
9. coin UI。
10. guarantee deposit UI。
11. settlement UI。
12. invoice UI。
13. finance-admin UI。
14. message-building payment execution UI。
15. generic DM / group chat expansion。

## 14. Stage Conclusion

当前阶段结论：

- `P0-Pay L5 Flutter consumption freeze = 通过`。
- `Go for implementation unlock and stage gate checklist authoring`。
- `No-Go for Flutter implementation until implementation unlock stage gate passes`。
- `No-Go for Computer Use integration`。
- `No-Go for release-prep`。
- `No-Go for production release`。

## 15. Formal Conclusion

P0-Pay Flutter consumption 正式冻结为：

```text
Flutter consumes BFF only, shows P0-Pay payment and authorization flows, polls read status, and never owns money truth.
```
