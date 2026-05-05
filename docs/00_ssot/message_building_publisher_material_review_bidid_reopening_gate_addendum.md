---
owner: Codex 总控
status: frozen
closure_type: message_building_publisher_material_review_bidid_reopening_gate
layer: L0 SSOT
scope:
  - project communication workbench material review
  - publisher material review before bid submit
  - bidId conditional requirement
effective_local_date: 2026-05-05
purpose: >
  Reopen only the project-communication material-review bidId boundary needed
  to remove the publisher-material confirmation deadlock after bid
  participation approval and before bid submit, while preserving service-fee,
  payment, final amount, and upstream publish-mainline gates.
---

# 消息楼发布方资料确认 bidId 死锁修复 Reopening Gate Addendum

## 1. 总裁决

本 reopening gate 只解决一个死锁：

`参与申请已通过 -> 竞标方需要先确认发布方 5 项资料 -> 尚未产生 bidId -> material-review 不能因为 bidId 缺失而拒绝发布方资料确认`

当前裁决：

- 发布方资料确认 entries 可以在 `bidId` 为空时写入。
- 竞标方资料 / 报价资料确认 entries 仍必须绑定真实 `bidId`。
- Server 仍是资料确认真值 owner。
- BFF 只转发，不补 `bidId`，不推断确认状态。
- Flutter 只消费 workbench entries、badge、lock，不保存资料确认真值。

## 2. 与既有冻结文书关系

本文件只 reopening 以下边界：

| 既有文书 | 本文件处理 |
| --- | --- |
| `message_building_business_transit_and_deal_confirmation_v1_truth_freeze_addendum.md` | 保持业务中转站、业务待办、聊天锁定、最终金额边界不变；仅补充 publisher material review 的 no-bid 写入规则。 |
| `project_communication_workbench_ten_entry_review_day1_freeze_addendum.md` | 保持 5+3+2 工作台结构不变；仅明确 5 项发布方资料确认可早于 bidId。 |
| `downstream_bid_to_contract_amount_v1_truth_freeze_addendum.md` | `Bid.quoteAmount`、`Order.totalAmount`、`finalConfirmedAmount` 三金额真值不变。 |
| `project_create_to_publish_mainline_closure_lock_addendum.md` | 上游创建、草稿、预发布补资料、绿色通道、确认发布主链路继续封板。 |

## 3. bidId 条件冻结

| entry 类别 | entry group | subject owner | reviewer | bidId 要求 | 持久化策略 |
| --- | --- | --- | --- | --- | --- |
| 发布方资料确认 | `publisher_materials` | 发布方 | 竞标方组织 | 可为空 | Server 使用稳定 no-bid key 承接，后续读取仍按同一 key。 |
| 竞标方资料 / 报价确认 | `bid_materials` | 竞标方 | 发布方组织 | 必须有真实 `bidId` | Server 使用真实 `bidId`。 |
| 合同确认入口 | `deal_confirmation` | 双方 | 双方 | 不走 material-review | 只能 handoff 到 deal-confirmations。 |

规则：

- `publisher_materials` 的 no-bid 确认只代表竞标方已确认发布方资料。
- no-bid 确认不得创建 Bid。
- no-bid 确认不得视为竞标提交。
- no-bid 确认不得绕过 `BID_SERVICE_FEE_AUTHORIZATION_REQUIRED`。
- no-bid 确认不得触发支付、服务费扣费、保证金、结算、发票、钱包。
- no-bid 确认不得写入或推断 `finalConfirmedAmount`。

## 4. Server 真值要求

Server 最小修复要求：

- `publisher_materials` 在资料存在、reviewer 匹配、sourceVersionToken 匹配时允许 `bidId = null`。
- `bid_materials` 在 `bidId` 缺失时必须继续拒绝。
- no-bid publisher review 必须可被 workbench read model 读取。
- no-bid publisher review 必须参与 `publisherMaterialReviewPendingCount` 归零计算。
- 聊天锁必须从 `publisher_material_confirmation_pending` 进入 `bid_submission_pending`，而不是直接解锁。

## 5. 明确不做

本 reopening gate 不做：

- 不修改服务费授权门禁。
- 不冻结或绕过 4000 元竞标服务费预授权。
- 不创建 Bid。
- 不提交竞标报价。
- 不改变三附件必传规则。
- 不改变上传三步流、`FileAsset`、`Evidence`、`ProjectAttachment` 真值。
- 不改变最终金额确认路径。
- 不进入支付、服务费扣费、履约保证金、结算、发票、钱包、履约、验收、评价、争议。

## 6. 验收标准

通过条件：

- 竞标方可以在无 `bidId` 时确认发布方 5 项资料。
- `bid_materials` 无 `bidId` 仍拒绝。
- 5 项发布方资料确认后，竞标方 workbench 待办从 `5` 归零。
- 5 项发布方资料确认后，聊天仍锁定，但锁原因变为 `bid_submission_pending`。
- 竞标提交仍受服务费授权门禁控制。

No-Go：

- 如果实现需要数据库列改 nullable 或新增迁移，必须先回到 Gate 1 重新裁决。
- 如果实现导致服务费门禁失效，必须立即回滚。
- 如果 no-bid review 被扩大到 `bid_materials`，必须立即回滚。
