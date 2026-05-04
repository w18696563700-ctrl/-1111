---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the app-facing contract delta for the project publish green-channel
  feedback gate. This addendum updates the prior internal-test no-freeze
  contract: feedback is no longer read-only observation for publish; current
  user feedback is a publish gate condition during the App launch stage.
layer: L2 Contracts
freeze_date_local: 2026-05-04
version: V2
---

# 《项目发布绿色通道表态门禁 Contract Addendum》

## 1. Publish Gate

`POST /api/app/project/publish` 的 path、request、success response 保持不变。

Server 允许发布的最小条件改为：

1. 当前项目状态为 `submitted`。
2. 当前项目正式附件中包含三类必传资料：
   - `effect_image`
   - `construction_doc`
   - `material_sample`
3. 当前发布用户已提交绿色通道表态：
   - `support_freeze`
   - `oppose_freeze`

表态任一选择均可放行。`paid/frozen` 不再作为当前内测期普通发布硬条件。

## 2. Pricing Summary

`ProjectPricingPublisherSummary` 必须承载：

```ts
{
  sincerityFreezePolicyNotice?: string | null;
  freezeFeedbackSummary?: {
    supportFreezeCount: number;
    opposeFreezeCount: number;
    myChoice: 'support_freeze' | 'oppose_freeze' | null;
    updatedAt: string | null;
  } | null;
}
```

`authenticitySincerityStatus` 允许：

```text
internal_test_no_freeze_required
```

`publishGateStatus` 允许：

```text
internal_test_no_freeze_allowed
```

## 3. Feedback Endpoint

App-facing path：

```text
POST /api/app/project/{projectId}/authenticity-sincerity/freeze-feedback
```

Canonical Server path：

```text
POST /server/projects/{projectId}/authenticity-sincerity/freeze-feedback
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
  traceId?: string | null;
}
```

## 4. Error Codes

新增或正式承认：

| Code | Owner | Meaning |
| --- | --- | --- |
| `PROJECT_AUTHENTICITY_SINCERITY_INTERNAL_TEST_POLICY_UNAVAILABLE` | Server | 当前项目未满足绿色通道放行条件，例如必传资料缺失或当前用户未表态 |
| `PROJECT_AUTHENTICITY_SINCERITY_FREEZE_FEEDBACK_INVALID` | Server | feedback choice 不在 `support_freeze / oppose_freeze` 内 |
| `PROJECT_AUTHENTICITY_SINCERITY_FREEZE_FEEDBACK_REJECTED` | Server | 当前用户、组织或项目状态不允许写入反馈 |

既有 `PROJECT_AUTHENTICITY_SINCERITY_REQUIRED` 保留给正式期或旧 paid/frozen 门禁失败，不得在当前绿色通道已表态条件满足时继续拦截普通发布。

## 5. No-Go

本 contract 不允许：

1. BFF 自行计算发布门禁。
2. Flutter 伪造 `myChoice` 或发布成功。
3. 将待上传草稿附件算作正式资料。
4. 将 `support_freeze / oppose_freeze` 写成支付成功、冻结成功或退款状态。
