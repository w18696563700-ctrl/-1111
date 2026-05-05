---
owner: Codex 总控
status: frozen
purpose: Freeze the V1 truth boundary for doing the four project-communication entries thoroughly without expanding into fulfillment, payment, or a generic chat system.
layer: L0 SSOT
effective_local_date: 2026-05-05
depends_on:
  - docs/00_ssot/message_building_business_transit_and_deal_confirmation_v1_truth_freeze_addendum.md
  - docs/00_ssot/downstream_bid_to_contract_amount_v1_truth_freeze_addendum.md
  - docs/00_ssot/project_communication_workbench_ten_entry_review_day1_freeze_addendum.md
  - docs/00_ssot/project_communication_album_rating_truth_freeze_addendum.md
---

# 项目沟通四入口做透 V1 Truth Freeze Addendum

## 1. 总裁决

项目沟通页四个一级入口保留，但职责重新收口：

| 入口 | V1 职责 | 真值 owner | 本轮裁决 |
| --- | --- | --- | --- |
| 项目相册 | 项目证据池：合同照片、进度照片、最终呈现、项目瑕疵 | Server `ProjectAlbumPhoto` + `FileAsset` | 做实 OSS 证据查看和真实图片预览；不扩成履约系统。 |
| 进入审核 | 发布方处理竞标方参与申请 | Server `BidParticipationRequest` | 支持待审红点、pending 直达和受控 disabled reason。 |
| 后续承接 | 商业闭环承接：最终成交确认、合同文件、订单承接 | Server `DealConfirmation / ContractConfirmation` + `Order` seed | 一级可见；成交确认优先展示，不隐藏商业闭环。 |
| 资料确认单 | 仅承接 8 项资料确认 | Server `ProjectCommunicationMaterialReview` | 只显示发布方 5 项资料和竞标方 3 项资料；不再承接成交确认。 |

本轮最小闭环是：

`进入审核 -> 资料确认单 8 项资料确认 -> 后续承接中的最终成交确认入口 -> Server 双方确认 finalConfirmedAmount`

## 2. 资料确认单 8 项边界

`资料确认单` 只承接资料审阅，不承接合同、订单、成交、支付或服务费。

### 2.1 发布方资料 5 项

| entryKey | 展示名 | 资料真值 |
| --- | --- | --- |
| `publisher_effect_image_review` | 效果图确认 | `ProjectAttachment(effect_image)` + `FileAsset` |
| `publisher_construction_doc_review` | 尺寸图 / 施工图确认 | `ProjectAttachment(construction_doc)` + `FileAsset` |
| `publisher_material_sample_review` | 材质图 / 材料样板确认 | `ProjectAttachment(material_sample)` + `FileAsset` |
| `publisher_equipment_material_list_review` | 设备物料清单确认 | `ProjectAttachment(equipment_material_list)` + `FileAsset` |
| `publisher_service_list_review` | 服务清单确认 | `ProjectAttachment(service_list)` + `FileAsset` |

### 2.2 竞标资料 3 项

| entryKey | 展示名 | 资料真值 |
| --- | --- | --- |
| `bid_project_understanding_review` | 项目理解确认 | `Bid.projectUnderstandingFileAssetId` |
| `bid_quote_sheet_review` | 报价表确认 | `Bid.quoteSheetFileAssetId` |
| `bid_schedule_plan_review` | 进度安排确认 | `Bid.schedulePlanFileAssetId` |

### 2.3 明确移出

以下不再作为资料确认单主展示内容：

- `contract_confirmation`
- `final_confirmed_amount_confirmation`

它们只允许作为 `后续承接` 的成交确认承接信息，不得走 `material-review` 命令。

## 3. 后续承接入口裁决

`后续承接` 是商业闭环入口，必须保持一级可见，不得藏在资料确认单或深层菜单中。

点击后续承接后，V1 轻量面板排序固定为：

1. `最终成交确认`
2. `合同文件`
3. `订单承接`

当 `businessTodoSummary.dealConfirmationPendingCount > 0` 时：

- `后续承接` 按钮必须显示具体红点数量。
- 面板必须优先展示最终成交确认卡。
- 文案必须表达：双方确认完成后，Server 才成立 `finalConfirmedAmount`。

禁止：

- 把 `Order.totalAmount` 写成最终成交金额。
- 把 `Bid.quoteAmount` 写成最终成交金额。
- 把聊天内容、资料确认或 Flutter 本地状态写成最终成交金额。
- 让 `/api/app/contract/confirm` 承接 `finalConfirmedAmount`。

## 4. 项目相册证据池边界

`项目相册` 的初心是保留项目证据，V1 边界为：

- 上传仍走 `init -> direct upload -> confirm -> bind`。
- 业务真值是 Server `FileAsset` 与 `ProjectAlbumPhoto`。
- 图片进入 OSS 后可通过受控访问随时查看。
- Flutter 不得展示或保存 `objectKey`。
- 真实图片预览必须走受控 file access / preview access。

本轮不做：

- 履约相册。
- 验收相册。
- 争议举证系统。
- 案例公开展示。
- 图片审核治理。

这些保留为后续扩展位。

## 5. 进入审核入口边界

`进入审核` 必须服务于参与竞标申请审核：

- 红点来源：`businessTodoSummary.bidParticipationReviewPendingCount`。
- 有可打开业务卡时，优先打开业务卡。
- 无业务卡但存在 pending count 时，允许进入 pending 列表。
- 无权限、无待办或上下文缺失时，必须显示中文 disabled reason。

禁止：

- Flutter 根据文案或卡片标题推断审核状态。
- 有红点但无受控可达入口。
- 暴露英文 route 参数异常。

## 6. 红点真值

所有业务红点只读 Server 真值。

| UI 位置 | 红点来源 |
| --- | --- |
| 主体项目卡 | `projectGroups[].businessTodoSummary.totalPendingCount` |
| 进入审核 | `bidParticipationReviewPendingCount` |
| 资料确认单 | `publisherMaterialReviewPendingCount + bidMaterialReviewPendingCount` |
| 后续承接 | `dealConfirmationPendingCount` |
| 资料确认明细项 | `entries[].badgeCount` |
| 普通聊天未读 | `conversationUnreadCount / projectUnreadCount` |

规则：

- 普通未读不等于业务待办。
- BFF 不得计算红点。
- Flutter 不得用 enabled、附件数量、条目数量、文案或本地缓存推断业务待办。
- 资料确认提交后必须刷新 Server read model，不能本地减数字冒充成功。

## 7. 明确不做范围

本轮不得扩展到：

- 支付。
- 服务费扣费。
- 履约保证金。
- 结算。
- 发票。
- 钱包。
- 履约。
- 验收。
- 评价。
- 争议。
- 泛 IM、私聊、群聊、WebSocket。
- 上游项目创建到发布主链路。

## 8. 后续扩展位

| 扩展位 | 接入方式 | 当前裁决 |
| --- | --- | --- |
| 合同金额变更 | 接在 confirmed `finalConfirmedAmount` 后形成 amount amendment | 暂不开通 |
| 补充协议 | 接在合同确认后 | 暂不开通 |
| 履约相册 | 从项目相册证据池分出履约阶段视图 | 暂不开通 |
| 验收/争议举证 | 复用相册 FileAsset，但另开状态机 | 暂不开通 |
| 平台服务费 | 只读取双方 confirmed `finalConfirmedAmount` | 不在本轮触发扣费 |

## 9. 四类判断

| 判断 | 裁决 |
| --- | --- |
| 哪个更稳 | 四入口保留，资料确认与成交确认拆语义，后续承接一级可见，Server 红点统一。 |
| 哪个更省成本 | 只改 Flutter 文案和入口位置，但不能解决 contracts/generated 和红点真值缺口。 |
| 哪个最适合当前阶段 | 先补 SSOT / OpenAPI / generated，再做 Server/BFF/Flutter 最小对齐。 |
| 哪个风险最大 | 把后续承接扩成交易大中心，或继续把成交确认塞在资料确认单里。 |

## 10. Day 2 Admission

允许进入 Day 2 contracts / OpenAPI 裁决，仅限：

- 项目相册 app-facing paths。
- file preview/access 能否承接相册真实图片预览。
- workbench material-review 只允许 8 项资料。
- deal-confirmations 与 `/contract/confirm` 边界复核。
- 复用现有 `businessTodoSummary` 和 `entries[].badgeCount`，不得为了后续承接新增过重模型。
