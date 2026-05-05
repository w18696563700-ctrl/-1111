---
owner: Codex 总控
status: frozen
purpose: Freeze the V1 app-facing contract fields for messages-building business transit todo badges, chat availability, workbench tool badges, and final amount route boundaries.
layer: L2 Contracts
effective_local_date: 2026-05-05
inputs_canonical:
  - docs/00_ssot/message_building_business_transit_and_deal_confirmation_v1_truth_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 消息楼业务中转站 / 合同金额确认全流程 V1 Contracts Addendum

## 1. 总裁决

本文件冻结 Day 2 contracts / OpenAPI 裁决：

- `businessTodoSummary` 是业务待办红点的唯一 app-facing 读模型字段，来源必须是 Server 聚合。
- `chatAvailability` 是项目聊天发送锁定 / 解锁的唯一 app-facing 读模型字段，来源必须是 Server。
- workbench 工具入口只允许消费 Server 下发的 `badgeCount` 和 `disabledReason`，Flutter / BFF 不得本地推断。
- `/api/app/project/{projectId}/deal-confirmations` 继续是最终合同金额确认唯一 app-facing 路径族。
- `/api/app/contract/confirm` 继续只允许承接旧合同 continuation，不得写入或推断 `finalConfirmedAmount`。

## 2. App-facing Surface Freeze

| Surface | Method | Path | Day 2 裁决 |
| --- | --- | --- | --- |
| 主体会话列表 | `GET` | `/api/app/message/interactions` | 第一层只保留主体级摘要和普通 unread，不新增我发布/我竞标分项统计。 |
| 主体项目列表 | `GET` | `/api/app/message/counterpart-conversation/detail` | `projectGroups[].businessTodoSummary` 是第二层项目业务待办红点来源。 |
| 项目聊天线程 | `GET` | `/api/app/message/project-communication/thread` | `chatAvailability` 是第三层聊天输入框锁定 / 解锁来源。 |
| 项目工作台 | `GET` | `/api/app/message/project-communication/workbench` | 返回 `businessTodoSummary`、`chatAvailability`、`entries[].badgeCount`、`entries[].disabledReason`。 |
| 资料确认命令 | `POST` | `/api/app/message/project-communication/workbench/material-review` | 仍只处理 8 个资料条目，不处理最终合同金额。 |
| 最终金额确认 | `POST/GET` | `/api/app/project/{projectId}/deal-confirmations*` | 唯一最终金额确认路径族。 |
| 合同 continuation | `POST` | `/api/app/contract/confirm` | 不得携带或写入最终合同金额。 |

## 3. `businessTodoSummary`

`ProjectCommunicationBusinessTodoSummary` 最小字段：

| Field | Type | Required | Rule |
| --- | --- | --- | --- |
| `bidParticipationReviewPendingCount` | `number` | yes | 发布方待处理参与竞标申请数。 |
| `publisherMaterialReviewPendingCount` | `number` | yes | 竞标方待确认发布方资料数。 |
| `bidMaterialReviewPendingCount` | `number` | yes | 发布方待确认竞标方资料 / 报价表数。 |
| `dealConfirmationPendingCount` | `number` | yes | 当前组织待处理最终成交确认数。 |
| `totalPendingCount` | `number` | yes | 上述待办合计，用于项目卡或工具入口红点。 |

规则：

- `businessTodoSummary` 不等于 `conversationUnreadCount`、`projectUnreadCount` 或通知中心 unread。
- BFF 不得根据卡片文案、附件数量、旧状态或缓存拼接待办数量。
- Flutter 不得根据按钮 enabled、workbench 条数、普通未读数推断业务待办。
- 待办数量为 `0` 时不显示假红点。

## 4. `chatAvailability`

`ProjectCommunicationChatAvailability` 最小字段：

| Field | Type | Required | Rule |
| --- | --- | --- | --- |
| `canSendMessage` | `boolean` | yes | 当前项目聊天是否允许发送文字、图片、附件。 |
| `lockReasonCode` | `string | null` | yes | 锁定原因代码；未锁定为 `null`。 |
| `lockReasonText` | `string | null` | yes | Flutter 可展示中文原因；未锁定为 `null`。 |
| `requiredNextAction` | `string` | yes | 建议下一步入口；无下一步时为 `none`。 |

V1 锁定原因最小枚举：

- `bid_participation_review_pending`
- `publisher_material_confirmation_pending`
- `bid_submission_pending`
- `bid_material_confirmation_pending`
- `deal_confirmation_pending`

V1 下一步动作最小枚举：

- `review_bid_participation`
- `confirm_publisher_materials`
- `submit_bid_materials`
- `confirm_bid_materials`
- `open_deal_confirmation`
- `none`

规则：

- Server 写消息接口必须执行与 `chatAvailability` 一致的锁定校验。
- Flutter 输入框禁用只是展示层保护，不是业务真值。
- BFF 只透传，不得覆盖锁定结果。

## 5. Workbench Tool Badge Freeze

`ProjectCommunicationWorkbenchEntry` 允许新增：

| Field | Type | Required | Rule |
| --- | --- | --- | --- |
| `badgeCount` | `number` | yes | 当前工具入口业务待办数量，来源 Server。 |
| `disabledReason` | `string | null` | yes | `actionState = blocked` 或不可进入时的中文原因；可进入时为 `null`。 |

规则：

- `badgeCount` 不得由 Flutter 用 `attachmentCount`、`reviewState` 或普通 unread 推断。
- `disabledReason` 不得用英文异常或 raw route error 替代。
- `contract_confirmation` 和 `final_confirmed_amount_confirmation` 的 route target 只能指向 `deal-confirmations` 路径族，不得指向 `/api/app/contract/confirm`。

## 6. Deal Confirmation Boundary Review

复核裁决：

- `DealConfirmationCreateRequest.finalConfirmedAmount` 是唯一最终合同金额输入字段。
- `DealConfirmationReadModel.finalConfirmedAmount` 是最终合同金额读取字段。
- `/api/app/project/{projectId}/deal-confirmations` 可由消息楼入口承接，但消息楼不保存最终金额真值。
- `/api/app/contract/confirm` 的 `ContractConfirmRequest` 只允许 `orderId`，不得新增：
  - `finalConfirmedAmount`
  - `quoteAmount`
  - `totalAmount`
  - `serviceFeeAmount`
  - payment / settlement / invoice / wallet fields

## 7. Explicit Non-Goals

- 不新增支付、服务费扣费、履约保证金、结算、发票、钱包字段。
- 不新增泛 IM、私聊、群聊、WebSocket 主线。
- 不改变上游项目创建到发布主链路。
- 不改变三类必传报价依据资料门禁、上传三步流、`FileAsset / Evidence / ProjectAttachment` 真值。
- 不生成 contracts types，不进入 Flutter / BFF / Server 实现，不做云端联调或部署。

## 8. Day 3 Admission

`Conditional Go` for generated types only after review.

进入 Day 3 前必须确认：

- `openapi.yaml` 中 `businessTodoSummary`、`chatAvailability`、`badgeCount`、`disabledReason` 无双命名。
- `deal-confirmations` 与 `/contract/confirm` 没有双最终金额入口。
- 生成范围只覆盖 contracts projection，不进入代码施工。
