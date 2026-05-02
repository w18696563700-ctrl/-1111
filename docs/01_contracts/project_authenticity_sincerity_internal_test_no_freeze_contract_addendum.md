---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the L2 app-facing contract delta for the internal-test no-freeze
  policy of `200 元项目真实性诚意金`, including the pricing-summary status
  field, publish-gate state, policy notice, and feedback statistics endpoint.
layer: L2 Contracts
freeze_date_local: 2026-05-02
version: V1
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_authenticity_sincerity_internal_test_no_freeze_boundary_freeze_addendum.md
  - docs/01_contracts/platform_pricing_contracts_master_v1.md
  - docs/01_contracts/openapi.yaml
  - docs/01_contracts/error_codes.yaml
---

# 《项目真实性诚意金内测暂不冻结 Contract Addendum》

## 0. 总裁决

本 addendum 对 `platform_pricing_contracts_master_v1` 作最小追加，不重写既有收费合同。

当前正式冻结：

1. `internal_test_no_freeze_required` 是新的项目诚意金业务状态。
2. `internal_test_no_freeze_allowed` 是新的 publish gate 派生状态。
3. `sincerityFreezePolicyNotice` 是 App 展示内测政策说明的正式字段。
4. `freezeFeedbackSummary` 是只读统计，不参与门禁。
5. 新增 feedback 写接口，支持 `support_freeze / oppose_freeze` 两种选择。

## 1. Pricing Summary Delta

既有 path 保持不变：

```text
GET /api/app/project/{projectId}/pricing-summary
```

`publisherPricing.authenticitySincerityStatus` 允许新增枚举值：

```text
internal_test_no_freeze_required
```

该状态只允许表示内测政策下“暂不冻结真实资金，但流程仍保留”。它不得表示：

1. `paid`
2. `frozen`
3. `succeeded`
4. `not_required`
5. 真实扣费完成
6. 真实预授权冻结完成

`publisherPricing.publishGateStatus` 允许新增枚举值：

```text
internal_test_no_freeze_allowed
```

`publisherPricing` 新增可选字段：

```ts
{
  sincerityFreezePolicyNotice?: string;
  freezeFeedbackSummary?: ProjectAuthenticitySincerityFreezeFeedbackSummary;
}
```

`ProjectAuthenticitySincerityFreezeFeedbackSummary`：

```ts
{
  supportFreezeCount: number;
  opposeFreezeCount: number;
  myChoice: 'support_freeze' | 'oppose_freeze' | null;
  updatedAt: string | null;
}
```

## 2. Publish Gate Delta

`POST /api/app/project/publish` 保持既有 path、request、response。

Server publish gate 判断新增：

1. 当 `authenticitySincerityStatus=paid` 时，按既有逻辑允许发布。
2. 当 Server 内测豁免开关开启，且当前项目满足发布前资料和状态要求时，可派生 `publishGateStatus=internal_test_no_freeze_allowed` 并允许发布。
3. 当内测豁免关闭时，未 `paid` 的项目必须继续返回 `PROJECT_AUTHENTICITY_SINCERITY_REQUIRED`。
4. App 不得仅根据 `channelActionType=unavailable` 推断可发布。

发布成功审计 payload 必须能区分：

```ts
{
  pricingGateApplied: true;
  authenticitySincerityRequired: true;
  authenticitySincerityStatus: 'paid' | 'internal_test_no_freeze_required';
  authenticitySincerityGateResult: 'paid' | 'internal_test_no_freeze_allowed';
}
```

## 3. Pay-init Delta

既有 path 保持不变：

```text
POST /api/app/project/{projectId}/authenticity-sincerity/orders/{orderId}/pay-init
```

当支付通道不可用时，response 仍允许：

```ts
{
  paymentInitStatus: 'pending_user_confirm';
  channelActionType: 'unavailable';
  channelPayload: {
    provider: 'alipay';
    reasonCode: 'alipay_app_pay_disabled' | string;
    callbackAwaiting: true;
  };
}
```

但该 response 不得推进：

1. 项目诚意金为 `paid`
2. 项目诚意金为 `frozen`
3. PaymentOrder 为 `succeeded`
4. Project 为 `published`

## 4. Feedback Endpoint

新增 app-facing path：

```text
POST /api/app/project/{projectId}/authenticity-sincerity/freeze-feedback
```

Request：

```ts
{
  choice: 'support_freeze' | 'oppose_freeze';
}
```

Response：

```ts
{
  projectId: string;
  myChoice: 'support_freeze' | 'oppose_freeze';
  supportFreezeCount: number;
  opposeFreezeCount: number;
  updatedAt: string;
  traceId?: string;
}
```

Canonical Server path：

```text
POST /server/project/{projectId}/authenticity-sincerity/freeze-feedback
```

Server truth rule：

1. `userId + projectId` 唯一有效选择。
2. 重复提交同一 choice 为幂等成功。
3. 提交不同 choice 为覆盖选择。
4. 覆盖选择只改变统计，不改变支付和发布状态。

## 5. Error Family Delta

新增错误码：

| Code | HTTP | Meaning |
|---|---:|---|
| `PROJECT_AUTHENTICITY_SINCERITY_INTERNAL_TEST_POLICY_UNAVAILABLE` | 409 | 当前项目不满足内测豁免条件，仍需完成项目真实性诚意金 |
| `PROJECT_AUTHENTICITY_SINCERITY_FREEZE_FEEDBACK_INVALID` | 400 | feedback choice 不在 `support_freeze / oppose_freeze` 内 |
| `PROJECT_AUTHENTICITY_SINCERITY_FREEZE_FEEDBACK_REJECTED` | 409 | 当前用户、组织或项目状态不允许写入反馈 |

既有错误码仍保留：

1. `PROJECT_AUTHENTICITY_SINCERITY_REQUIRED`
2. `PROJECT_AUTHENTICITY_SINCERITY_ORDER_CREATE_REJECTED`
3. `PROJECT_AUTHENTICITY_SINCERITY_ORDER_NOT_FOUND`
4. `PROJECT_AUTHENTICITY_SINCERITY_PAY_INIT_REJECTED`
5. `PROJECT_AUTHENTICITY_SINCERITY_INVALID_STATE`

## 6. Idempotency

feedback 写入的幂等边界：

1. 以 `userId + projectId` 为自然幂等边界。
2. `x-idempotency-key` 可透传，但不是防刷票唯一 owner。
3. 统计必须按当前有效选择聚合，不按历史点击次数聚合。

## 7. No-Go

本 contract 不允许：

1. 新增通用支付中心。
2. 新增钱包或资金池。
3. 把 `internal_test_no_freeze_required` 写入 paid/frozen 财务状态。
4. BFF 自行计算发布门禁。
5. Flutter 自行根据支付通道不可用放行发布。
6. 用户反馈改变发布、支付、退款、扣费状态。
