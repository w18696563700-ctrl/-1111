---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the L1 information architecture for project communication text chat,
  project album, and post-completion counterparty rating, carrying forward the
  L0 truth boundary without introducing a new business state owner.
layer: L1 Information Architecture
freeze_date_local: 2026-04-24
based_on:
  - docs/00_ssot/project_communication_album_rating_truth_freeze_addendum.md
  - docs/00_ssot/counterpart_conversation_truth_freeze_addendum.md
  - docs/00_ssot/project_communication_album_rating_field_table_addendum.md
  - docs/00_ssot/project_communication_album_rating_route_table_addendum.md
---

# 《项目沟通 / 项目相册 / 双方互评 L1 信息架构补充》

## 1. 结论

- 更稳的方案：三个业务对象继续独立建模，并全部强制锚定 `projectId`；互评额外锚定 `orderId / raterOrganizationId / rateeOrganizationId`。
- 更省成本的方案：`counterpart_conversation` 只作为聚合展示容器复用现有入口，不新增业务状态机、不迁移聊天/相册/互评真值。
- 更适合当前阶段的方案：先冻结项目内文字聊天、项目相册、项目结束后双方互评的最小闭环，后续再扩展实时、评分聚合、相册治理和更多展示卡片。
- 风险更大的方案：把三者揉进 `counterpart_conversation` 或任一聊天表内，形成跨项目、跨订单、跨对象的混合状态，会导致权限、审计、信用链和后续扩展边界失控。

## 2. 当前最小闭环

### 2.1 Project Communication Text Chat

- 文本聊天的业务对象固定为：
  - `ProjectCommunicationThread`
  - `ProjectCommunicationMessage`
  - `ProjectCommunicationReadCursor`
- 所有线程、消息、已读游标都必须强制携带 `projectId`。
- 首版只承接项目内双方文字沟通：
  - `messageKind = text`
  - 不承接附件消息、语音、表情、红包、砍价、群聊或 generic DM。
- `ProjectCommunicationThread` 的项目内双方边界固定为：
  - `projectId + ownerOrganizationId + counterpartOrganizationId`
- `ProjectCommunicationMessage` 不得脱离 `threadId/projectId/senderOrganizationId/senderUserId/body` 独立存在。

### 2.2 Project Album

- 项目相册的业务对象固定为：
  - `ProjectAlbumPhoto`
- 每张照片必须强制携带 `projectId`。
- 每张照片必须绑定正式文件真值：
  - `fileAssetId`
- `objectKey` 只属于存储定位，不得作为业务真值。
- 首版相册分类固定为：
  - `contract`
  - `progress`
  - `final`
  - `defect`
- 首版只承接项目级共享相册，不承接聊天附件库、企业案例库、公共资源区或项目私有附件的真值迁移。

### 2.3 Project Counterparty Rating

- 双方互评的业务对象固定为：
  - `ProjectCounterpartyRating`
- 每条互评必须强制携带：
  - `projectId`
  - `orderId`
  - `raterOrganizationId`
  - `rateeOrganizationId`
- 互评唯一方向边界固定为：
  - `orderId + raterOrganizationId + rateeOrganizationId`
- 互评只在项目结束或订单完成后开放。
- 互评可作为后续信用 shadow 聚合输入，但本 L1 不直接开通信用分实时重算、申诉、奖惩或公开榜单。

## 3. Counterpart Conversation 容器边界

- `counterpart_conversation` 的正式定位固定为：
  - 对方主体维度的聚合展示容器
  - 项目内业务卡片和入口的展示组织方式
  - 跳转到原业务 carrier 的 route target 承接面
- `counterpart_conversation` 不拥有：
  - 文字聊天状态
  - 相册照片状态
  - 互评状态
  - 订单状态
  - 项目信用状态
  - 跨项目统一审批或统一会话状态
- `counterpart_conversation` 可展示：
  - 项目沟通入口和最近消息摘要
  - 项目相册入口和照片数量摘要
  - 项目结束后的互评入口
- `counterpart_conversation` 只能读取和展示三类业务对象投影，不得把本地聚合缓存解释为业务最终真相。

## 4. 信息架构分层

- L1 页面/入口层：
  - `counterpart_conversation` 可以作为统一展示入口。
- 业务对象层：
  - 文字聊天归 `ProjectCommunication*`。
  - 项目相册归 `ProjectAlbumPhoto`。
  - 双方互评归 `ProjectCounterpartyRating`。
- 真值归属层：
  - `Server` 是唯一业务真值 owner。
  - `BFF` 只做 auth forwarding、aggregation、response shaping、visibility trimming、error mapping。
  - `Flutter` 只消费 BFF projection，不直连 Server，不自建业务真值。
- 归档与审计层：
  - 聊天、相册、互评分别保留自己的 audit/actionKey 边界。
  - 不允许通过展示容器抹平审计来源。

## 5. 需要保留但暂不开通

- 实时 WebSocket / SSE 只作为后续增强，不是当前 L1 必需条件。
- 图片评论、相册批量治理、相册水印、相册审核流暂不开通。
- 互评申诉、互评修改、信用分公开展示、奖惩联动暂不开通。
- 通用私信、陌生人 DM、群聊、语音、表情、红包、砍价暂不开通。
- 跨项目统一会话状态、跨项目统一待办队列暂不开通。

## 6. 后续扩展位

- Realtime 扩展位：
  - 在 HTTP 真值闭环稳定后，为 `ProjectCommunicationThread` 增加实时到达能力，但 HTTP 仍保留为消息真值与兜底链路。
- Album Governance 扩展位：
  - 在 `ProjectAlbumPhoto` 上扩展审核、分类治理、批量排序、来源标记和水印策略。
- Rating Credit 扩展位：
  - 在 `ProjectCounterpartyRating` 提交后接入信用 shadow 聚合、风控抽样、申诉治理和公开展示策略。
- Counterpart Projection 扩展位：
  - 在 `counterpart_conversation` 中继续增加只读卡片，但每个卡片必须回指自己的业务 truth anchor。

## 7. Veto Rules

- 不得出现无 `projectId` 的项目沟通线程、消息、已读游标或项目相册照片。
- 不得出现无 `projectId/orderId/raterOrganizationId/rateeOrganizationId` 的互评。
- 不得把 `counterpart_conversation` 当成聊天、相册、互评、订单或信用的业务状态 owner。
- 不得把相册照片保存进聊天消息表。
- 不得把评价保存进聊天消息表。
- 不得用 `objectKey` 替代 `FileAsset` 或 `ProjectAlbumPhoto` 真值。
- 不得为了展示方便合并跨项目状态。

## 8. Stage Conclusion

- 本 L1 信息架构正式冻结。
- 当前允许进入：
  - 已冻结 L2/L3/L4/L5 链条内的边界复核。
  - 后续文书补齐和实现验收引用。
- 当前不新增允许：
  - 新路由。
  - 新状态机。
  - BFF/Flutter 业务真值。
  - 直接代码实现授权。
