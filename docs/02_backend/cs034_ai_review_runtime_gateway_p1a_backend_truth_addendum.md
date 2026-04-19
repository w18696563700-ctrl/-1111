---
owner: Codex 总控
status: frozen
purpose: Freeze the bounded Server-owned truth and carrier boundary for CS-034 AI review runtime gateway.
layer: L2 Backend Truth
---

# CS-034 AI 审核服务统一接入层 P1-A Backend Truth Addendum

## 1. 当前包范围

本文件只冻结 `CS-034` 当前最小 Server truth/read-model 承接：

- unified AI gateway request truth
- unified AI gateway result truth
- provider normalization truth
- audit/trace linkage truth

## 2. 当前真值归属

`Server` 继续是唯一 AI gateway truth owner。

本包新增的 dedicated truth carrier 只允许是：

- `ai_review_gateway_requests`
- `ai_review_gateway_results`

本包不得把 `BFF`、Flutter 或 provider 变成 truth owner。

## 3. 当前 provider normalization 规则

当前 gateway 只允许：

- 接收 provider-specific input
- 在 `Server` 内归一化为统一 request/response envelope
- 将 provider result 作为 signal input，而不是最终业务 truth

当前 gateway 不允许：

- 直接 materialize business penalty truth
- 直接 materialize appeal truth
- 直接 materialize app-facing publish truth

## 4. 当前最小字段族

`ai_review_gateway_requests` 最小字段只允许：

- `id`
- `engine_type`
- `provider_key`
- `review_object_type`
- `object_id`
- `policy_profile`
- `request_payload_ref`
- `trace_id`
- `created_at`

`ai_review_gateway_results` 最小字段只允许：

- `id`
- `request_id`
- `decision`
- `risk_score`
- `risk_labels`
- `provider_response_ref`
- `status`
- `created_at`

当前最小 `status` family 固定为：

- `queued`
- `processing`
- `completed`
- `failed`

## 5. 当前 bounded truth 语义

- 当前 gateway 只提供 normalized AI review carrier
- 当前 gateway 不是 launch-ready AI runtime
- 当前 gateway 不是自动处罚状态机
- 当前 gateway 不是 app-facing AI console

## 6. 当前明确不纳入项

- 自动处罚 truth
- penalty / appeal full desk truth
- public app-facing AI surface
- `CS-019`
- `CS-020`
- `CS-021`
- `CS-022`
- release-prep / launch approval

## 7. 当前 Formal Conclusion

`CS-034 P1-A` 的 Server truth/read-model 边界已冻结：

- `Server` 继续是唯一 truth owner
- 只允许 bounded gateway carrier 与 provider normalization truth
- 不得越界打开 app-facing AI console、自动处罚、full governance center 或 implementation unlock
