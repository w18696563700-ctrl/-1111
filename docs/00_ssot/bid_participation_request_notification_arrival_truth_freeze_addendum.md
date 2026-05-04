---
owner: Codex 总控
status: frozen
purpose: Freeze the app-visible arrival reminder truth for bid participation request creation.
layer: L0 SSOT
---

# Bid Participation Request Notification Arrival Truth Freeze Addendum

## 1. 总裁决

本轮正式冻结：当竞标方成功创建 `bid_participation_request`
并进入 `pending` 状态时，Server 必须生成一条发布方组织可见的消息楼到达提醒。

该提醒用于解决“发布方不知道有新的参与竞标申请待审核”的最小闭环。
它不是普通项目沟通聊天消息，不改变参与竞标申请状态机，不新增通用消息平台。

## 2. 当前最小闭环

1. 竞标方在项目详情提交参与竞标申请。
2. Server 创建 `BidParticipationRequest`，状态为 `pending`。
3. Server 同事务创建一条 `app_notifications` 到达提醒。
4. 发布方账号的底部 `消息` badge 可以统计该提醒的未读数。
5. 发布方进入消息楼，在通知中心看到 `参与竞标申请待审核`。
6. 点击提醒进入既有参与竞标申请审核线程。
7. 标记 notification 已读后，底部 `消息` badge 刷新并清除对应 unread。

## 3. 提醒对象

新增提醒对象固定为：

- `bid_participation_request.pending.created`

它只在新申请成功进入 `pending` 时产生。

不得在以下场景重复产生同类到达提醒：

- 重复申请被拒绝或冲突返回。
- `approved` / `rejected` 状态变更。
- 竞标提交、竞标服务费预授权、成交确认、支付相关动作。

后续如需审批结果提醒，必须另行冻结。

## 4. Recipient

recipient 固定为项目发布方组织：

- `recipientOrganizationId = Project.organizationId`

本轮不指定某个发布方用户为唯一 recipient。

原因：

- 当前组织上下文是真实审核权限边界。
- 发布方组织内谁能处理审核，由既有 Server 权限判断。
- 不在 Flutter 或 BFF 本地判断审核权限。

## 5. Route Target

notification 的 routeTarget 必须进入既有参与竞标申请审核线程。

固定语义：

- `canonicalPath`: `/api/app/project/bid-participation/thread/detail`
- `localEntryKey` 或等价 action key: `bid_participation_request.open`
- required params:
  - `threadId`
  - `projectId`
  - `requestId`

其中：

- `threadId = bid_participation_requests.id`
- `requestId = bid_participation_requests.id`
- `projectId = bid_participation_requests.project_id`

不得新增审核 API，不得把 notification 直接绑定到 Server Admin route，
不得绕过既有 `BidParticipationRequest` 审核线程。

## 6. Read 语义

notification unread/read 是 Server-owned notification truth。

`POST /api/app/notifications/read` 只标记 notification center item read：

- 不替代 project communication read cursor。
- 不写入 project communication read cursor。
- 不创建 message-level read receipt。
- 不改变 `bid_participation_request.state`。

项目沟通消息 unread 仍由 `project_communication_read_cursors` 负责。

## 7. Shell Badge 语义

底部 `消息` badge 的 `shellContext.unreadSummary.messages` 从本轮开始允许统计：

1. 消息楼可见的项目沟通 unread。
2. 消息楼可见的 notification unread。

统计必须来自 Server 同源投影。BFF 不得计算 unread，Flutter 不得本地推断红点。

为避免重复计数：

- project communication message notification 不得与 project communication unread 重复叠加。
- `bid_participation_request.pending.created` 可以计入 notification unread，因为它不是 project communication message。

## 8. 分层边界

| Layer | Rule |
| --- | --- |
| Server | owns notification truth, unread/read truth, recipient, routeTarget, and permission checks |
| BFF | forwards and shape-validates only; no persistence, no unread calculation, no business state |
| Flutter | renders notification item, consumes shell badge, triggers mark-read and route jump only |

## 9. 本轮不做

- 不做 APNs / FCM 真实系统推送验收。
- 不做声音、震动、锁屏通知。
- 不把参与申请写成 project communication message。
- 不新增 generic `/api/app/messages/*`。
- 不新增 notification preference center。
- 不新增 Admin 审核 API。
- 不改变 `pending / approved / rejected` 状态机。
- 不接入支付、钱包、保证金、结算、退款或发票语义。

## 10. 需要保留但暂不开通

- 审批通过 / 拒绝结果提醒。
- 多成员组织内的个人级 recipient。
- 系统 push delivery 真机验收。
- 消息楼内按申请 / 聊天 / 系统分类 unread。
- 通知偏好设置。

## 11. 后续扩展位

- `bid_participation_request.approved`
- `bid_participation_request.rejected`
- 发布方组织内审核人分配。
- 通知中心分组筛选。
- APNs / FCM delivery adapter and true-device UAT.

## 12. 阶段判断

- 更稳：Server 生成 notification truth，BFF / Flutter 只消费。
- 更省成本：Flutter 本地根据 pending 申请伪造红点，但会产生第二套 unread truth。
- 更适合当前阶段：复用现有 `app_notifications` 和既有审核线程 routeTarget，不新增表、不重构消息楼。
- 风险更大：把参与申请写成 project communication system message，会污染聊天流和 read cursor。

## 13. No-Go 清单

进入实现前仍禁止：

- BFF 自行创建或持久化 notification。
- Flutter 自行扫描申请列表并生成本地 badge。
- 用 project communication message 承载申请提醒。
- 扩大成通用消息平台。
- 在未通过 contracts 前新增未冻结字段、枚举或 route。
