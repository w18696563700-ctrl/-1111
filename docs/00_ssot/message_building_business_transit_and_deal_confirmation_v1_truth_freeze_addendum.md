---
owner: Codex 总控
status: frozen
closure_type: message_building_business_transit_truth_freeze
layer: L0 SSOT
scope:
  - messages building business transit station
  - ordinary unread versus business todo split
  - project communication chat availability
  - bid participation review handoff
  - publisher and bidder material review handoff
  - bid submit and quote material review handoff
  - deal-confirmation final amount entry boundary
effective_local_date: 2026-05-05
purpose: >
  Freeze the V1 truth and boundary for using the messages building as a
  project-scoped business transit station from bid participation application
  through material review, bid submit, quote material confirmation, chat
  unlock, and final deal-confirmation entry, without making messages, BFF, or
  Flutter own business truth, amount truth, payment truth, or a generic IM
  system.
---

# 消息楼业务中转站 / 合同金额确认全流程 V1 Truth Freeze Addendum

## 1. 总裁决

本文件冻结消息楼在当前 P0 下游链路中的 V1 角色：

`消息楼 = 项目级业务中转站 + 项目沟通容器 + 资料确认入口 + 最终金额确认入口 handoff`

消息楼不是：

- 泛聊天系统。
- 私聊 / 群聊 / 通用 IM。
- 业务真值 owner。
- 最终合同金额真值 owner。
- 订单、合同、支付、服务费、保证金、结算、发票、钱包真值 owner。

本文件允许进入下一阶段 contracts / OpenAPI 裁决，但不直接授权 Flutter、BFF、Server 代码施工，不授权云端部署，不授权真实写 smoke。

## 2. 与既有冻结文书的关系

本文件只补齐“消息楼业务中转站”横向主线，不重写以下既有真相：

| 已冻结文件 | 本文件承接方式 |
| --- | --- |
| `project_create_to_publish_mainline_closure_lock_addendum.md` | 上游创建到发布主链路保持封板，不 reopening。 |
| `downstream_bid_to_contract_amount_v1_truth_freeze_addendum.md` | 三个金额真值和最终金额唯一路径继续有效。 |
| `project_communication_workbench_ten_entry_review_day1_freeze_addendum.md` | 10 入口工作台、5+3 资料、合同确认、最终成交金额入口继续有效。 |
| `project_communication_unread_read_contract_field_table_day1_addendum.md` | 普通未读字段继续只表示项目沟通消息 unread。 |

如果本文件与旧草案或候选文书冲突，以本文件和上述已注册 frozen 文书为当前施工前真相。

## 3. 当前最小闭环

V1 最小闭环只覆盖：

| 顺序 | 节点 | 消息楼职责 | 真值 owner | 裁决 |
| --- | --- | --- | --- | --- |
| 1 | 有人申请参与我发布的项目 | 主体会话列表出现真实提醒 | Server BidParticipationRequest + ProjectCommunication unread projection | 消息楼只展示入口和提醒。 |
| 2 | 发布方进入具体项目 | 项目卡显示业务待办红点 | Server business todo projection | 不能复用普通 unread 伪造业务待办。 |
| 3 | 进入审核 | 工具入口显示待审核数量，跳转 review thread | Server BidParticipationRequest | approve / reject 必须 Server 留痕。 |
| 4 | 申请通过后 | 聊天继续锁定，提示先完成资料确认和竞标资料流转 | Server chatAvailability | Flutter 只消费锁状态。 |
| 5 | 竞标方确认发布方资料 | 资料确认单显示待确认红点和 5 类发布资料 | Server ProjectAttachment + FileAsset + MaterialReview | 三类必传资料仍来自上游发布真值。 |
| 6 | 竞标方提交报价和三附件 | 可从消息楼快捷进入竞标提交，但提交仍走 bid submit | Server Bid + FileAsset | `Bid.quoteAmount` 不是最终合同金额。 |
| 7 | 发布方确认竞标方报价资料 | 资料确认单显示待确认红点，确认报价表等资料 | Server ProjectCommunicationMaterialReview | 资料确认不等于成交。 |
| 8 | 资料和报价确认完成 | 聊天解锁，可以继续沟通合同上传和最终金额确认 | Server chatAvailability | 解锁只能来自 Server。 |
| 9 | 合同文件与最终成交价互确 | 消息楼提供入口和提示 | Server DealConfirmation / ContractConfirmation | 最终金额只看 `finalConfirmedAmount` 双方确认完成。 |

本轮最小终点是：

`平台侧形成可进入 deal-confirmations 的金额确认入口，并且明确 finalConfirmedAmount 必须双方确认完成后才成立。`

本文件不把支付扣费、服务费、履约、结算作为本轮终点。

## 4. 四类真值冻结

### 4.1 普通未读

含义：项目沟通消息未读。

允许字段：

- `conversationUnreadCount`
- `hasUnread`
- `latestUnreadMessageAt`
- `projectUnreadCount`
- `hasProjectUnread`

规则：

- 普通未读只统计消息 unread。
- 普通未读不得代表“待审核申请”。
- 普通未读不得代表“待确认资料”。
- 普通未读不得代表“待确认报价”。
- 普通未读不得代表“待最终成交确认”。

### 4.2 业务待办红点

含义：当前项目在业务链路上需要当前组织处理的事项。

V1 允许冻结为一个 Server 派生读模型，后续 contracts 可命名为 `businessTodoSummary` 或等价结构。最小字段应覆盖：

| 待办桶 | 含义 | 典型展示位置 |
| --- | --- | --- |
| `bidParticipationReviewPendingCount` | 发布方待处理参与竞标申请数 | 项目卡、进入审核按钮 |
| `publisherMaterialReviewPendingCount` | 竞标方待确认发布方资料数 | 资料确认单按钮 |
| `bidMaterialReviewPendingCount` | 发布方待确认竞标方资料 / 报价表数 | 项目卡、资料确认单按钮 |
| `dealConfirmationPendingCount` | 当前组织待处理最终成交确认数 | 最终确认入口 |
| `totalPendingCount` | 上述待办合计 | 项目卡右上角红点 |

规则：

- 业务待办必须来自 Server 聚合。
- BFF 不得根据文案、旧卡片、文件数量或本地缓存推断业务待办。
- Flutter 不得根据 workbench 条目数量、普通 unread、按钮 enabled 状态推断业务待办。
- 待办数量为 0 时不显示假红点。

### 4.3 聊天锁定状态

含义：当前 `projectId + threadId + currentOrganizationId` 下是否允许发送项目沟通消息。

V1 允许冻结为一个 Server 派生读模型，后续 contracts 可命名为 `chatAvailability` 或等价结构。最小字段应覆盖：

| 字段 | 含义 |
| --- | --- |
| `canSendMessage` | 当前是否允许发送文字、图片、附件。 |
| `lockReasonCode` | 锁定原因代码；未锁定为 `null`。 |
| `lockReasonText` | Flutter 可展示的中文锁定说明；未锁定为 `null`。 |
| `requiredNextAction` | 建议下一步入口，例如审核申请、确认资料、提交竞标、确认报价、确认最终金额。 |

V1 锁定规则：

| 阶段 | canSendMessage | 原因 |
| --- | --- | --- |
| 参与申请待审核 | false | 先由发布方处理申请。 |
| 申请已通过但发布方资料尚待竞标方确认 | false | 先确认报价依据资料。 |
| 竞标方尚未提交报价和三附件 | false | 先完成竞标提交。 |
| 发布方尚未确认竞标方报价资料 | false | 先确认报价表和竞标资料。 |
| 报价资料确认闭环后 | true | 可继续围绕合同文件和最终成交金额沟通。 |
| 最终成交确认阶段 | true | 可沟通，但成交真值只看 deal-confirmations。 |

规则：

- Flutter 输入框、附件、图片发送必须消费 `chatAvailability.canSendMessage`。
- Server 写消息接口必须执行同一业务锁校验，不能只靠 Flutter 禁用按钮。
- BFF 不得覆盖 Server 锁定结果。
- 锁定时必须展示中文原因，不得泄露 raw exception。

### 4.4 最终合同金额

继续沿用既有金额三真值裁决：

- `Bid.quoteAmount`：竞标方报价金额，不是最终合同金额。
- `Order.totalAmount`：订单 seed 金额 / 中标报价参考，不是最终合同金额。
- `finalConfirmedAmount`：双方最终确认合同金额，唯一最终金额真值。

V1 规则：

- `finalConfirmedAmount` 必须由 Server 持久化。
- `finalConfirmedAmount` 必须双方确认完成后才成立。
- 唯一 app-facing 路径为 `/api/app/project/{projectId}/deal-confirmations`。
- `/api/app/contract/confirm` 不得携带或写入 `finalConfirmedAmount`。
- 消息楼只能提供入口、提示和只读状态，不得保存或裁定最终金额。

## 5. 消息楼入口边界

### 5.1 可以做

- 项目级沟通。
- 报价沟通。
- 资料确认入口。
- 补充资料提醒。
- 参与申请审核入口。
- 竞标提交快捷入口。
- 状态通知。
- 最终合同金额确认入口 handoff。

### 5.2 不可以做

- 用聊天文本替代资料确认。
- 用聊天文本替代最终金额确认。
- 用资料确认状态替代合同金额确认。
- 用普通 unread 替代业务待办。
- 用 Flutter 本地状态判定成交。
- 用 BFF fallback 判定成交。
- 触发支付、服务费扣费、保证金、结算、发票、钱包。

## 6. 关键页面 / 工具语义冻结

| 页面或区域 | V1 语义 | 红点来源 | 锁定来源 |
| --- | --- | --- | --- |
| 互动中心主体会话列表 | 一个主体容器，展示主体级普通未读和摘要 | 普通 unread projection | 不涉及 |
| 某主体下项目列表 | 一个项目一行 / 一卡，展示我方身份线和项目业务待办 | Server business todo projection | 不直接发送 |
| 项目聊天页 | 当前项目沟通，不跨项目混聊 | 工具级 todo projection | Server chatAvailability |
| 进入审核 | 参与竞标申请 review thread handoff | `bidParticipationReviewPendingCount` | 不涉及 |
| 资料确认单 | 5 发布资料 + 3 竞标资料 + deal entry 展示 | material review pending counts | 不涉及 |
| 聊天输入框 | 只在 business chain 允许时发送 | 不显示业务红点 | `chatAvailability.canSendMessage` |
| 最终确认入口 | 进入 deal-confirmations | `dealConfirmationPendingCount` | 不代表最终金额已成立 |

## 7. Server / BFF / Flutter 职责

### 7.1 Server

Server 必须拥有：

- 参与申请状态。
- 资料确认状态。
- 竞标提交和报价附件状态。
- 业务待办计数。
- 聊天业务锁状态。
- 最终成交确认状态。
- `finalConfirmedAmount`。

Server 必须拒绝不满足锁定规则的发送消息写入；不能只把锁交给 Flutter。

### 7.2 BFF

BFF 只能：

- 转发 Server。
- 做 app-facing 塑形。
- 校验字段类型。
- 归一错误。

BFF 不得：

- 计算业务待办。
- 计算聊天锁。
- 计算成交状态。
- 计算最终金额。
- 生成 fallback 红点。

### 7.3 Flutter

Flutter 只能：

- 展示红点。
- 展示锁定原因。
- 禁用输入框和附件按钮。
- 承接真实 routeTarget。
- 展示最终金额确认入口。

Flutter 不得：

- 本地推断业务待办。
- 本地推断聊天锁。
- 本地拼最终金额。
- 用普通未读替代业务待办。
- 用 workbench entries.length 当待办数。

## 8. 接口裁决方向

第 2 天 contracts / OpenAPI 应以最小加法为原则：

| Surface | 加法方向 | 说明 |
| --- | --- | --- |
| `GET /api/app/message/interactions` | 主体级摘要保持普通 unread，不添加我发布/我竞标假分项 | 第一层只展示主体级字段。 |
| `GET /api/app/message/counterpart-conversation/detail` | `projectGroups[].businessTodoSummary` | 第二层项目卡业务待办来源。 |
| `GET /api/app/message/project-communication/thread` | `chatAvailability` 或同等字段 | 聊天发送锁来源。 |
| `GET /api/app/message/project-communication/workbench` | workbench 级 summary / entry badge fields | 第三层工具入口红点来源。 |
| `POST /api/app/message/project-communication/messages` | Server 按 `chatAvailability` 同规则拒绝写入 | 防止 Flutter 绕过锁。 |
| `/api/app/project/{projectId}/deal-confirmations` | 最终金额确认唯一入口 | 不触发支付扣费 smoke。 |

第 2 天不得新增 payment / wallet / deposit / settlement / invoice 字段。

## 9. 当前阶段不做范围

本轮不得做：

- 支付。
- 服务费扣费。
- 履约保证金。
- 结算。
- 发票。
- 钱包。
- 多轮报价。
- 报价版本。
- 平台仲裁定价。
- 合同金额变更。
- 补充协议。
- 履约。
- 验收。
- 评价。
- 争议。
- 泛 IM、私聊、群聊、在线状态、输入中状态。

## 10. 保留但暂不开通

| 能力 | 保留原因 | 暂不开通原因 |
| --- | --- | --- |
| 多轮报价 / 报价版本 | 后续议价需要 | 当前只保留 `Bid.quoteAmount` 单报价真值。 |
| 平台仲裁定价 | 复杂争议可能需要 | 当前不得让平台裁定最终金额。 |
| 合同金额变更 | 成交后可能需要 | 必须接在 confirmed `finalConfirmedAmount` 后另开 amount amendment。 |
| 补充协议 | 合同变更需要 | 当前不进入履约后阶段。 |
| 支付 / 服务费扣费 | 商业闭环需要 | 当前只冻结最终金额确认入口，不触发资金动作。 |
| 保证金 / 结算 / 发票 / 钱包 | 资金完整链需要 | 必须另开 payment / settlement / invoice 冻结链。 |
| Admin 治理视图 | 平台运营需要 | 当前消息楼 P0 不引入 Admin。 |

## 11. 后续扩展位

| 扩展位 | 接入原则 |
| --- | --- |
| `BusinessTodoSummary` 版本化 | 后续可新增更多待办桶，但不得改变普通 unread 语义。 |
| `ChatAvailability` 状态机扩展 | 后续可加入 dispute / fulfillment lock，但必须 Server truth。 |
| 资料补充多轮反馈 | 接 ProjectCommunicationMaterialReview 历史，不用聊天文本做真值。 |
| 最终金额变更 | 接 confirmed deal 后的 amendment，不改 Bid / Order seed。 |
| 服务费读取 | 只能读取 confirmed `finalConfirmedAmount`，不能读取报价或订单 seed。 |

## 12. 验收标准

本文件通过后，第 2 天 contracts / OpenAPI 才允许启动。Day 1 验收必须满足：

- 普通未读与业务待办已明确分离。
- 业务待办红点必须来自 Server。
- 聊天锁必须来自 Server，并且 Server 写接口必须执行同规则校验。
- 资料确认、报价确认、最终金额确认三者边界清楚。
- `finalConfirmedAmount` 唯一真值和 `deal-confirmations` 唯一路径保持不变。
- 上游创建到发布主链路不 reopening。
- 支付、服务费扣费、保证金、结算、发票、钱包不进入本轮。

## 13. Day 2 准入

Day 2 只允许进入 contracts / OpenAPI 裁决，范围限定为：

- `businessTodoSummary` 或等价业务待办 schema。
- `chatAvailability` 或等价聊天锁 schema。
- workbench 工具级 badge / disabled reason schema。
- Server 与 BFF 路径关系表。
- `deal-confirmations` 与 `/contract/confirm` 边界复核。

Day 2 不允许：

- Flutter 代码施工。
- BFF / Server 代码施工。
- generated types 更新。
- 云端部署或重启。
- 真实写 smoke。

## 14. 四类判断

| 判断项 | 结论 |
| --- | --- |
| 哪个更稳 | 先冻结 Server-owned `businessTodoSummary` 和 `chatAvailability`，再分层实现。 |
| 哪个更省成本 | 复用普通 unread 和 workbench entries 做本地红点，但这会制造假业务待办，不允许作为正式方案。 |
| 哪个更适合当前阶段 | 最小新增 Server 派生读模型，BFF 透传，Flutter 展示；最终金额入口只接 `deal-confirmations`，支付保持锁住。 |
| 哪个风险最大 | Flutter / BFF 根据申请卡、文件数量、聊天内容、本地按钮状态推断红点、锁定或成交。 |

## 15. 收口结论

`消息楼业务中转站 / 合同金额确认全流程 V1 = Conditional Pass for Day 2 contracts freeze only.`

本文件不授权代码施工，不授权云端写入，不授权部署，不授权支付或服务费扣费。
