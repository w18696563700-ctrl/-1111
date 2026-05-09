---
owner: Codex 总控
status: frozen
closure_type: downstream_business_truth_freeze
layer: L0 SSOT
scope:
  - published project downstream chain
  - bid participation request
  - bid submit quote and three attachments
  - project communication material review
  - BidAward
  - Order and Contract seed
  - final confirmed contract amount boundary
effective_local_date: 2026-05-04
purpose: >
  Freeze the V1 downstream business truth from a published exhibition project
  through bid participation, bid submit, project communication, BidAward,
  Order / Contract seed, and final confirmed contract amount entry. This file
  protects the closed create-to-publish mainline and prevents amount truth,
  message truth, order seed, contract seed, and payment surfaces from drifting
  into each other.
---

# 下游竞标到合同金额确认链路 V1 Truth Freeze Addendum

## 1. 总裁决

本文件冻结的 V1 下游链路是：

`published 项目 -> 竞标方申请参与 -> 发布方审核 -> 竞标方报价 / 三附件 -> 消息楼沟通 / 资料确认 -> 发布方选择合作方 -> BidAward -> Order / Contract seed -> 最终合同金额确认入口 / 最终合同金额确认边界`

本文件明确：

- `Server` 是参与申请、报价、资料确认、BidAward、Order / Contract seed、最终合同金额确认的唯一业务真值 owner。
- `BFF` 只能做 app-facing 转发、聚合、塑形、错误归一，不得计算最终合同金额，不得生成成交状态。
- `Flutter` 只能做页面、表单、入口和状态展示，不得拼接、缓存或判定业务真值。
- 消息楼可以承接沟通、资料确认、补充资料、状态通知和最终金额确认入口，但不得承接最终合同金额真值。
- 最终合同金额只允许由 Server 持久化的 `finalConfirmedAmount` 表达，并且必须双方确认完成后才成立。

本文件不允许借下游链路 reopening 已收口的上游发布主链路。

## 2. 上游发布主链路保护

以下内容继续以
[project_create_to_publish_mainline_closure_lock_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/project_create_to_publish_mainline_closure_lock_addendum.md)
为唯一收口锁定来源，本文件不得修改、重命名、重排或重新解释：

- 项目创建页。
- 草稿编辑页。
- 预发布补资料页。
- 发布确认页。
- `draft -> submitted -> published` 状态链。
- 三类必传报价依据资料门禁。
- 绿色通道表态规则。
- 上传三步流。
- `FileAsset / Evidence / ProjectAttachment` 真值归属。

任何任务只要触碰上述对象，必须先提交新的 reopening gate。

## 3. V1 当前最小闭环

| 顺序 | 节点 | 业务含义 | 真值 owner | V1 边界 |
| --- | --- | --- | --- | --- |
| 1 | published 项目可见 | 项目进入公域竞标展示 | Server Project | 仅 published 公域读面，不回写发布主链路 |
| 2 | 申请参与竞标 | 竞标方申请进入竞标准入 | Server BidParticipationRequest | 替代独立项目名申请用户主入口 |
| 3 | 发布方审核 | 发布方 approve / reject 参与申请 | Server BidParticipationRequest | BFF / Flutter 不得本地判定最终审核状态 |
| 4 | 报价依据资料查看 | approved 后读取五类报价依据资料 | Server ProjectAttachment + FileAsset | 文件访问必须走受控 access，不暴露 objectKey |
| 5 | 竞标报价提交 | 竞标方提交报价、方案摘要、三份附件 | Server Bid + FileAsset | `Bid.quoteAmount` 只是报价，不是最终合同金额 |
| 6 | 消息楼沟通 / 资料确认 | 双方沟通、确认资料或要求补充 | Server ProjectCommunicationMaterialReview | 资料确认不等于合同金额确认 |
| 7 | 发布方选择合作方 | 发布方选定意向竞标方 | Server BidAward | BidAward 是桥接真值，不是成交金额真值 |
| 8 | Order / Contract seed | 生成后续承接锚点 | Server Order + Contract | seed 不等于正式成交，不等于最终合同金额确认 |
| 9 | 最终金额确认入口 | 进入 deal-confirmation 入口 | Server read model + BFF route target | 入口可见不等于金额已确认 |
| 10 | 最终合同金额确认 | 双方确认 `finalConfirmedAmount` | Server DealConfirmation / ContractConfirmation | 双方确认完成后才成立 |

## 4. 三个金额真值裁决

### 4.1 `Bid.quoteAmount`

- 含义：竞标方报价金额。
- 真值 owner：Server `Bid`。
- 来源：竞标方在 `POST /api/app/bid/submit` 提交。
- 用途：发布方选择意向方、生成 Order seed 的参考。
- 禁止：不得被 Flutter、BFF、消息楼、合同详情页解释为最终合同金额。

### 4.2 `Order.totalAmount`

- 含义：Order seed 金额 / 中标报价参考。
- 真值 owner：Server `Order`。
- 来源：BidAward 后由 Server 从中标 `Bid.quoteAmount` 派生或按冻结规则生成。
- 用途：后续 Order / Contract seed 的承接显示。
- 禁止：不得作为最终合同金额、服务费计费源、支付源或合同金额变更基线。

### 4.3 `finalConfirmedAmount`

- 含义：双方最终确认合同金额。
- 真值 owner：Server `DealConfirmation / ContractConfirmation`。
- 来源：`/api/app/project/{projectId}/deal-confirmations` 对应的 Server 持久化确认对象。
- 成立条件：发布方和竞标方双方确认完成，Server 状态进入正式成交确认态。
- 用途：后续合同、服务费、支付、金额变更的唯一读取源。
- 禁止：不得由 `Bid.quoteAmount`、`Order.totalAmount`、聊天内容、Flutter 本地状态、BFF fallback、`/api/app/contract/confirm` 临时拼接或替代。

## 5. 消息楼边界

消息楼允许承接：

- 报价沟通。
- 资料确认。
- 补充资料请求。
- 状态通知。
- 最终金额确认入口和软链接。

消息楼禁止承接：

- 最终合同金额真值。
- 订单真值。
- 合同真值。
- 支付真值。
- 服务费真值。
- 用聊天文本、确认卡、资料确认状态替代 `deal-confirmation / contract-confirmation`。

消息楼页面必须区分：

- `资料已确认` 只表示资料确认。
- `确认合作并生成承接锚点` 只表示 BidAward / Order / Contract seed 已生成。
- `进入最终金额确认` 只表示进入确认入口。
- `最终金额已确认` 只能来自 Server confirmed deal 状态。

## 6. 接口路径裁决

| 能力 | V1 app-facing 主路径 | 裁决 |
| --- | --- | --- |
| 申请参与竞标 | `/api/app/project/bid-participation/*` | 当前 V1 准入主路径 |
| 报价依据资料 | `GET /api/app/project/bid-materials` | 五类资料只读主路径 |
| 竞标报价提交 | `POST /api/app/bid/submit` | 必须携带报价、方案摘要、三份附件 |
| 消息楼工作台 | `/api/app/message/project-communication/workbench*` | 资料确认与入口展示主路径 |
| 发布方选择合作方 | `POST /api/app/bid/award` | BidAward V1 唯一主路径 |
| 旧选择并建单 | `POST /api/app/bid/select-bid-and-create-order` | 仅允许兼容别名或历史路径，不得成为第二主路径 |
| 合同详情 | `GET /api/app/contract/detail` | Contract seed / detail 读取，不是最终金额确认 |
| 合同状态确认 | `POST /api/app/contract/confirm` | 仅允许确认合同 continuation state，不得携带 `finalConfirmedAmount` |
| 最终金额确认 | `/api/app/project/{projectId}/deal-confirmations` | 唯一 app-facing 最终金额确认路径 |

Server 内部可复用既有 `ContractConfirmation` 实体或 service，但 app-facing 主语义必须统一为 `deal-confirmations`。不得同时开放两套 app-facing 最终金额确认主路径。

## 7. 五个工作包冻结范围

### 7.1 竞标方申请参与与资料查看 V1

本轮允许：

- 竞标方创建参与申请。
- 发布方 approve / reject。
- approved 后解锁真实项目名、报价依据资料、文件访问、竞标提交入口。

本轮禁止：

- 新增独立“申请查看项目名称”用户主入口。
- BFF / Flutter 本地判定审核结果。
- 未 approved 读取受保护文件。

### 7.2 竞标报价提交与三附件 V1

本轮允许：

- `Bid.quoteAmount`。
- `proposalSummary`。
- 三份 confirmed `FileAsset`：
  - `projectUnderstandingFileAssetId`
  - `quoteSheetFileAssetId`
  - `schedulePlanFileAssetId`

本轮禁止：

- 多轮报价。
- 报价版本。
- 把报价金额当最终合同金额。

### 7.3 消息楼资料确认与沟通承接 V1

本轮允许：

- 5 类发布方报价依据资料确认。
- 3 类竞标方提交资料确认。
- `confirmed / needs_supplement / pending_review / unsubmitted` 的 Server 真值状态。
- 最终金额确认入口展示。

本轮禁止：

- 聊天内容确认最终金额。
- 资料确认替代合同金额确认。
- 消息楼内直接成交、支付、扣费、结算。

### 7.4 发布方选择合作方 / BidAward / Order-Contract seed V1

本轮允许：

- 发布方通过 `BidAward` 选择意向合作方。
- Server 生成 `Order` seed 和 `Contract` seed。
- Flutter 展示后续承接锚点。

本轮禁止：

- 把 `BidAward` 写成最终合同金额确认。
- 把 `Order.totalAmount` 写成最终合同金额。
- 把 `Contract.state=pending_confirm` 写成合同已完成。

### 7.5 最终合同金额确认 V1

本轮允许：

- 最终金额确认入口和合同边界冻结。
- Server 侧唯一 `finalConfirmedAmount` 持久化语义。
- 双方确认完成后成立。

本轮禁止：

- 支付。
- 服务费扣费。
- 履约保证金。
- 结算、发票、钱包。
- 合同金额变更、补充协议。

## 8. 不做范围

本轮不得扩展到：

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

这些能力只允许作为后续扩展位，不得污染当前 P0 下游最小闭环。

## 9. 后续扩展位

| 扩展位 | 未来接入原则 |
| --- | --- |
| 多轮报价 / 报价版本 | 新增 Server quote version truth，不改 `Bid.quoteAmount` 既有语义 |
| 复杂议价 | 以独立 negotiation object 接入，不用消息文本做金额真值 |
| 合同金额变更 | 接在 confirmed `finalConfirmedAmount` 后形成 amount amendment |
| 补充协议 | 接 Contract version / supplement truth，不改 BidAward |
| 平台服务费 | 只读取 confirmed `finalConfirmedAmount`，不读取 Bid / Order 金额 |
| 支付 / 保证金 / 结算 / 发票 | 另开 payment / settlement / invoice 冻结链 |
| Admin 治理 | 接 Server 审计和治理 API，不走 BFF |

## 10. 验收标准

本 V1 只有同时满足以下条件，才允许进入后续 contracts / OpenAPI / generated / code 施工：

- 三个金额概念已经分层。
- 最终金额确认唯一路径已经明确。
- `/api/app/contract/confirm` 被明确排除在最终金额确认之外。
- 消息楼边界已经明确。
- `BidAward` 与 `Order / Contract seed` 不被解释为成交完成。
- 支付、服务费扣费、保证金、结算、发票、钱包均不进入本轮。
- 上游发布主链路不被 reopening。

## 11. 四类判断

| 判断项 | 结论 |
| --- | --- |
| 哪个更稳 | 以 Server `DealConfirmation / ContractConfirmation.finalConfirmedAmount` 作为唯一最终金额真值 |
| 哪个更省成本 | 保留现有 BidAward、Order / Contract seed、消息楼 workbench，只修路径和语义漂移 |
| 哪个更适合当前阶段 | 下游 V1 只覆盖到最终金额确认入口和边界，支付和履约继续锁住 |
| 哪个风险最大 | 用 Flutter、BFF、聊天内容、`/api/app/contract/confirm`、`Bid.quoteAmount` 或 `Order.totalAmount` 替代最终金额 |

## 12. 收口结论

本文件冻结：

`下游竞标到合同金额确认链路 V1 = 允许进入 contracts / OpenAPI / generated / 分层实现，但不得触碰上游发布主链路，不得开放支付和结算，不得制造第二套最终金额真值。`
