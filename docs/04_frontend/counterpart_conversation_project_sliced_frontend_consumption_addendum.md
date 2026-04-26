---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the L5 Flutter consumption boundary for the corrected counterpart
  conversation IA: the counterpart container only renders project entries, and
  the project communication page owns the project-scoped chat UI.
layer: L5 Frontend
freeze_date_local: 2026-04-26
based_on:
  - docs/00_ssot/counterpart_conversation_project_sliced_ia_correction_addendum.md
  - docs/00_ssot/counterpart_conversation_truth_freeze_addendum.md
  - docs/04_frontend/counterpart_conversation_frontend_consumption_freeze_addendum.md
  - docs/04_frontend/project_communication_album_rating_frontend_consumption_freeze_addendum.md
---

# 《对方主体会话容器项目切片 frontend consumption freeze》

## 1. Scope

- 本冻结单只覆盖 Flutter 消费面：
  - 消息楼一级对方主体总框入口
  - 对方主体总框内项目列表页
  - 此项目竞标沟通页
  - 项目页内三个业务按钮和聊天消费边界
- 本冻结单不覆盖：
  - Flutter 直连 Server
  - BFF / Server 字段扩展实现
  - generic chat
  - 订单 / 相册 / 审核业务状态机改造

## 2. Screen State Freeze

- Flutter 必须把当前体验拆成两个明确页面态：
  1. `counterpartProjectList`
     - 对方主体总框内项目列表态
  2. `selectedProjectCommunication`
     - 已选择某个项目后的竞标沟通态
- 可以复用现有页面文件或路由壳，但运行时信息架构必须分开。
- `counterpartProjectList` 不得渲染或持有聊天输入态。
- `selectedProjectCommunication` 必须绑定一个明确的 `projectId`。

## 3. Counterpart Project List Consumption

- 进入对方主体总框后，Flutter 只允许渲染：
  - 对方主体基本信息
  - 该对方主体下的项目入口列表
- 每个项目入口最小显示：
  - `projectId`
  - `projectDisplayTitle` 或受控遮罩标题
  - `titleVisibility`
  - 轻量业务状态
  - `进入此项目竞标沟通`
- 此页面不得显示：
  - 聊天记录
  - 输入框
  - 手动同步
  - 订单状态展开卡
  - 项目相册展开内容
- 此页面不得触发：
  - load project communication thread
  - load messages
  - connect WebSocket
  - load album photos
  - load order detail

## 4. Project Entry Action

- 点击项目入口后，Flutter 必须进入 `selectedProjectCommunication`。
- 路由上下文必须至少携带：
  - `conversationId`
  - `counterpartOrganizationId`
  - `projectId`
- 若既有 BFF detail query 需要 `focusProjectId`，Flutter 可以继续传入。
- 但 Flutter 不得把 `focusProjectId` 解释为已选择聊天项目。
- 已选择聊天项目只来自用户点击的项目入口。

## 5. Selected Project Communication Consumption

- 项目沟通页必须按顺序渲染：
  1. 竞标沟通头部
  2. 项目名称查看申请 / 审核按钮
  3. 订单状态按钮
  4. 项目相册按钮
  5. 聊天记录和输入框
- 竞标沟通头部允许显示：
  - `avatarUrl`
  - `displayName`
  - 已冻结 projection 中真实存在的认证公司字段
- 未冻结真实认证公司字段前，Flutter 不得：
  - 拼接公司名
  - 从项目名推导公司名
  - 从昵称推导认证公司
  - 写死 mock 文案作为真实公司

## 6. Buttonized Business Entries

- `项目名称查看申请 / 审核`：
  - 只作为按钮入口
  - 根据既有 `routeTarget` 进入申请 / 审核详情
  - 当前页不展开完整审核流
- `订单状态卡`：
  - 只作为按钮入口
  - 默认不在当前页展开
  - 点击后进入订单状态详情或受控页
- `项目相册`：
  - 只作为按钮入口
  - 默认不在当前页展开照片列表
  - 点击后进入项目相册详情或受控页

## 7. Chat Consumption Boundary

- Flutter 只能在 `selectedProjectCommunication` 中加载聊天。
- 加载聊天前必须已知：
  - `projectId`
  - `threadId`
- 消息发送命令必须携带：
  - `projectId`
  - `threadId`
  - message content
- 本地缓存 key 必须包含：
  - `projectId`
  - `threadId`
- 页面切换项目时必须切换聊天上下文。
- Flutter 不得把聊天缓存挂在：
  - `counterpartOrganizationId`
  - `conversationId`
  - `displayName`

## 8. Error And Empty States

- 对方主体无项目时：
  - 显示空项目列表
  - 不显示聊天输入框
- 项目 thread 加载失败时：
  - 保留项目页头部和业务按钮
  - 聊天区显示受控失败态
  - 不回退到对方主体总框聊天
- `threadId` 缺失时：
  - 不允许发送消息
  - 不允许创建本地假 thread

## 9. Acceptance Checks

- 同一对方主体下两个项目时，总框只显示两个项目入口。
- 未点击项目入口前，不出现聊天记录和输入框。
- 点击 `西洽会泸州` 后，只加载泸州项目的 `projectId + threadId`。
- 返回总框再点击 `西洽会成都` 后，只加载成都项目的 `projectId + threadId`。
- 两个项目的消息不会互相出现。
- 订单状态和项目相册默认不在沟通页展开。
- 认证公司字段不存在时，不显示伪造公司名。

## 10. Current Minimum Loop

- 当前最小 Flutter 闭环：
  1. 消息入口点进对方主体总框
  2. 总框只显示项目列表
  3. 点项目入口进入项目沟通页
  4. 项目页显示三个业务按钮
  5. 项目页加载 `projectId + threadId` 聊天

## 11. Reserved But Closed

- 保留但暂不开通：
  - 总框聊天
  - 通用 IM
  - 图片聊天消息
  - 语音 / 表情
  - 认证公司本地推导
  - Flutter 本地订单状态机

## 12. Expansion Slots

- 后续扩展位：
  - 认证公司真实字段消费
  - 项目相册独立页
  - 订单状态独立页
  - 项目级 unread count
  - 接收侧 WebSocket 增量消息

## 13. Frontend No-Go

- 不得 direct-to-Server。
- 不得在总框页展示聊天。
- 不得在总框页加载 thread / messages。
- 不得用 `conversationId` 代替 `threadId`。
- 不得在没有 `projectId + threadId` 时发送消息。
- 不得伪造认证公司字段。

## 14. Stage Conclusion

- `对方主体会话容器项目切片` 的 L5 Flutter consumption boundary 现正式冻结。
- 下一步允许：
  - Flutter IA implementation within this boundary
- 当前仍：
  - No-Go for BFF / Server field expansion without separate freeze
  - No-Go for cloud release judgment
