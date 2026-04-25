---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the L0 truth boundary for the project communication text-chat,
  project album, and post-completion counterparty rating package.
layer: L0 SSOT
freeze_date_local: 2026-04-24
target_schedule:
  - 2026-04-27 Day 1 docs freeze
  - 2026-04-28 Day 2 Server truth skeleton
  - 2026-04-29 Day 3 Server read/write completion
based_on:
  - AGENTS.md
  - docs/00_ssot/counterpart_conversation_truth_freeze_addendum.md
  - docs/00_ssot/project_name_access_request_truth_freeze_addendum.md
  - docs/00_ssot/order_rating_driven_org_credit_scoring_master_rules_v1.md
---

# 《项目沟通文字聊天 / 项目相册 / 双方互评 truth freeze》

## 1. Scope

- 本冻结单覆盖三个独立真值对象：
  - `ProjectCommunicationThread / ProjectCommunicationMessage / ProjectCommunicationReadCursor`
  - `ProjectAlbumPhoto`
  - `ProjectCounterpartyRating`
- 三个对象都必须强制锚定：
  - `projectId`
- 互评必须额外锚定：
  - `orderId`
  - `raterOrganizationId`
  - `rateeOrganizationId`

## 2. Non-Goals

- 不做 generic DM。
- 不做陌生人私信。
- 不做群聊。
- 不做语音、表情、红包、砍价。
- 不在本轮做实时 WebSocket / SSE。
- 不把相册照片保存进聊天消息表。
- 不把评价保存进聊天消息表。
- 不把 `counterpart_conversation` 变成业务状态机。

## 3. Truth Ownership

- `Server` 是唯一业务真值所有者。
- `BFF` 只做 app-facing transport、response shaping、auth forwarding、visibility trimming。
- `Flutter` 只消费 BFF，不直连 Server。
- `counterpart_conversation` 只做聚合展示容器，不拥有聊天、相册、评价状态。

## 4. Project Communication Truth

- `ProjectCommunicationThread` 表示一个项目下两个组织之间的一条沟通线程。
- 唯一边界：
  - `projectId + ownerOrganizationId + counterpartOrganizationId`
- `ProjectCommunicationMessage` 表示文字消息。
- 当前首版只支持：
  - `text`
- 每条消息必须携带：
  - `threadId`
  - `projectId`
  - `senderOrganizationId`
  - `senderUserId`
  - `body`
- `ProjectCommunicationReadCursor` 只记录组织维度已读游标。
- 当前首版允许短轮询刷新，不要求实时送达。

## 5. Project Album Truth

- `ProjectAlbumPhoto` 表示项目级共享相册照片。
- 相册最多允许：
  - 每个项目 `50` 张 active 照片。
- 分类固定为：
  - `contract`
  - `progress`
  - `final`
  - `defect`
- 每张照片必须绑定：
  - `fileAssetId`
  - `projectId`
  - `category`
  - `uploadedByOrganizationId`
- 只允许 image FileAsset。
- `objectKey` 不得作为业务真值。
- 删除首版采用软删除：
  - `photoState = removed`

## 6. Counterparty Rating Truth

- `ProjectCounterpartyRating` 表示项目结束或订单完成后，一方组织对另一方组织的评价。
- 互评开放条件：
  - 项目已结束，或订单处于完成态。
- 每个方向最多一条 active/submitted 评价：
  - `orderId + raterOrganizationId + rateeOrganizationId`
- 评价提交后允许进入信用 shadow 聚合链路。
- 信用体系仍只消费正式评价结果，不直接消费聊天或相册。

## 7. Counterpart Conversation Projection

- 统一项目沟通页可展示：
  - 名称申请卡
  - 竞标沟通卡
  - 项目相册入口
  - 文本聊天区
  - 项目结束后的评价入口
- 页面聚合不改变真值：
  - 名称申请仍归 `ProjectNameAccessRequest`
  - 竞标沟通仍归 `BidThread`
  - 文字聊天归 `ProjectCommunication*`
  - 相册归 `ProjectAlbumPhoto`
  - 评价归 `ProjectCounterpartyRating`

## 8. Veto Rules

- 不得出现无 `projectId` 的聊天消息。
- 不得出现无 `projectId` 的相册照片。
- 不得出现无 `orderId/projectId/rater/ratee` 的互评。
- 不得把跨项目消息合并成一个业务状态。
- 不得以前端限制替代 Server 的 50 张相册上限。
- 不得用旧 owner-private `project_attachments` 伪装成双方共享项目相册。

## 9. Stage Conclusion

- L0 truth boundary is frozen.
- 下一步允许：
  - L2/L3/L4/L5 文书冻结。
  - Server skeleton authoring after gate pass.
- 下一步不允许：
  - 跳过文书直接实现。
  - 扩成 generic chat。
