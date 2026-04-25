---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Day-1 L0 truth boundary for `对方主体会话容器`, defining the
  information architecture, naming, project-boundary split, old-carrier
  downgrade, and the title-click permission-sheet rule without inventing a new
  business state machine.
layer: L0 SSOT
freeze_date_local: 2026-04-24
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/messages_interaction_center_and_bidder_carry_implementation_unlock_addendum.md
  - docs/00_ssot/project_name_access_request_truth_freeze_addendum.md
  - docs/01_contracts/messages_interaction_center_contract_freeze_addendum.md
  - docs/01_contracts/project_name_access_request_contract_freeze_addendum.md
---

# 《对方主体会话容器 truth freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `一个对方主体一个会话容器`
  - 统一消息入口下的 `counterpart conversation` 聚合信息架构
  - 旧 `project_name_access_thread / bid_thread` 的降级规则
  - 项目详情标题点击权限 sheet 规则
- 本冻结单不覆盖：
  - generic DM / group chat
  - 新统一聊天状态机
  - 审批 / 申请 / 竞标 / 澄清 / 通知的真值迁移
  - 跨项目业务状态合并

## 2. Final Truth Conclusion

- 当前统一入口下新增的 active object 固定为：
  - `CounterpartConversationContainer`
- 其正式语义固定为：
  - `按对方主体聚合展示的会话容器`
  - `只负责入口聚合与项目内分片展示`
  - `不是新的统一业务状态机`
- 当前对方主体锚点固定为：
  - `counterpartOrganizationId`
- 当前容器 canonical anchor 固定为：
  - `viewerOrganizationId + counterpartOrganizationId`

## 3. Information Architecture

- 当前信息架构正式固定为四层：
  1. `message/interactions` 列表入口
  2. `CounterpartConversationListItemProjection`
  3. `CounterpartConversationDetailProjection`
  4. `carrier detail`
- `message/interactions` 只承担：
  - 统一消息入口
  - 输出 `interactionType = counterpart_conversation`
- `CounterpartConversationListItemProjection` 只回答：
  - 当前用户与该对方主体之间是否存在 admitted 项目沟通容器
  - 当前最值得处理的 `focusProjectId`
  - 当前统一入口应跳往哪个 counterpart detail
- `CounterpartConversationDetailProjection` 只回答：
  - 当前 `conversationId` 下有哪些 `projectGroups`
  - 每个 `projectGroup` 对应哪个 `projectId`
  - 每个 `card` 应继续跳往哪个原业务 carrier
- `carrier detail` 继续回到原业务真值：
  - `project_name_access_thread`
  - `bid_thread`
  - `project_clarification`
  - future admitted carrier families only after separate freeze

## 4. Project Boundary Rule

- 统一消息入口成立，但项目边界不得合并。
- `CounterpartConversationContainer` 内部必须按 `projectId` 切开。
- 任一项目切片的审批 / 申请 / 竞标 / 澄清 / 通知动作：
  - 都继续锚定原业务真值
  - 都必须强制携带 `projectId`
- 当前明确禁止：
  - 在容器层生成跨项目统一 `status`
  - 在容器层做多项目审批队列真值
  - 在容器层揉平项目内外的不同动作语义

## 5. Data Model Naming Freeze

- 当前正式冻结的读模型命名只有：
  - `CounterpartConversationListItemProjection`
  - `CounterpartConversationDetailProjection`
  - `CounterpartConversationProjectGroupProjection`
  - `CounterpartConversationBusinessCardProjection`
  - `CounterpartConversationTruthAnchorProjection`
  - `CounterpartConversationRouteTarget`
- 当前正式写死：
  - 上述全部都是聚合读模型命名
  - 不是新的 persistence truth owner
  - 不是新的审批或聊天实例 owner

## 6. Old Carrier Downgrade

- 旧 `project_name_access_thread` 正式降级为：
  - `ProjectNameAccess truth detail carrier`
- 旧 `bid_thread` 正式降级为：
  - `Bid truth detail carrier`
- 它们当前不再承担：
  - 主入口列表 object
  - 对方主体聚合容器 object
- 它们当前继续承担：
  - 原业务真值详情承接
  - 原业务动作 detail carrier

## 7. Truth Ownership Rule

- `CounterpartConversationContainer` 不拥有：
  - 审批真值
  - 申请真值
  - 竞标真值
  - 澄清真值
  - 通知真值
- 当前原业务真值继续固定在：
  - `ProjectNameAccessRequest`
  - `Bid`
  - `BidPrivateThread`
  - `BidThreadMessage`
  - admitted project-scoped source carriers only
- BFF 与 Flutter 不得把容器本地缓存解释为业务最终真相。

## 8. RouteTarget / ActionKey Truth Rule

- `CounterpartConversationRouteTarget` 只允许承担：
  - counterpart detail 打开
  - 原业务 carrier 打开
  - 权限 sheet 打开
- 当前冻结的 `routeTarget.actionKey` 只允许：
  - `counterpart_conversation.open`
  - `project_name_access_thread.open`
  - `bid_thread.open`
  - `project_clarification.open`
  - `project_name_access.permission_sheet.open`
- 当前正式写死：
  - 所有进入原业务动作的 routeTarget.params 都必须带 `projectId`
  - 不得省略 `projectId` 只靠 `threadId` 推导项目语义

## 9. Project Detail Title Click Rule

- 公域项目详情标题 `项目名称需申请查看` 当前正式固定为可点击。
- 点击标题时不得直接进入聊天页。
- 点击标题时必须：
  - 打开 `permission sheet`
  - 该 sheet 的 actionKey 固定为：
    - `project_name_access.permission_sheet.open`
- `permission sheet` 当前只允许承接：
  - 当前标题为何被遮罩
  - 当前 actor 是否可申请查看
  - 若可申请则进入原 `ProjectNameAccessRequest` 命令面
- 当前明确禁止：
  - 标题点击直接创造新 thread
  - 用标题点击绕开原审批真值

## 10. Hard Boundary

- 不新造统一会话状态机
- 不新造跨项目统一审批状态
- 不让 `CounterpartConversationContainer` 成为业务真值 owner
- 不让旧 `project_name_access_thread / bid_thread` 继续当主入口
- 不允许任何业务动作丢失 `projectId`

## 11. Stage Conclusion

- `对方主体会话容器` 的 L0 truth boundary 现正式冻结。
- 当前已明确：
  - 信息架构
  - 数据模型命名
  - routeTarget / actionKey
  - 旧 carrier 降级
  - 标题点击权限 sheet
- 下一步只允许：
  - `Go for field / route table authoring`
  - `Go for L2/L3/L4/L5 freeze authoring`
- 当前仍：
  - `No-Go for code implementation`
