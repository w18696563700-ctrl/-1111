---
owner: Codex 总控
status: frozen
purpose: Freeze the L0 truth for the messages-building notification guidance system V1.
layer: L0 SSOT
---

# 消息提示与引导体系 V1 Truth Freeze Addendum

## 1. 总裁决

本 addendum 冻结 `消息提示与引导体系 V1`：

- 铃铛是全平台通知入口，不等于论坛互动页。
- `项目沟通` Tab 只展示项目沟通主体 / 项目 / 项目聊天链路。
- `论坛互动` Tab 只展示论坛互动提醒。
- 业务待办不等于普通未读。
- 点击通知成功定位到承接页面后，才允许标记该通知已读。
- 无法定位的通知必须保留未读，并显示中文受控提示。

本轮目标是解决：

1. 铃铛数字口径不可解释。
2. 项目沟通消息和论坛互动信息互相污染。
3. 通知点击无法引导用户一步步定位到未读 / 未处理事项。

## 2. 四类真值

| 真值 | 归属 | 说明 |
| --- | --- | --- |
| 普通通知未读 | Server | 通知中心 unread truth，按来源分桶并汇总。 |
| 项目沟通未读 | Server | 项目沟通 message / thread / conversation read truth，不由论坛互动承接。 |
| 论坛互动未读 | Server | 论坛回复、点赞、关注等 forum interaction truth，不由项目沟通承接。 |
| 业务待办红点 | Server | 继续读取 `businessTodoSummary` 与 `entries[].badgeCount`，不混入普通通知 unread。 |

BFF 只允许转发和 shape，不拥有未读、待办、路由定位、已读清除真值。

Flutter 只允许展示、筛选、导航和请求已读；不得本地计算业务待办，不得用普通 unread 伪造成业务待办。

## 3. 来源分流规则

通知来源必须可解释：

| 来源 | 允许承接 | 禁止承接 |
| --- | --- | --- |
| `project_communication` | 项目沟通消息、项目沟通到达提醒、项目上下文提醒 | 论坛互动列表 |
| `forum_interaction` | 论坛回复、点赞、关注等论坛互动提醒 | 项目沟通主体会话列表 |
| `business_todo` | 业务待办入口分组；V1 可映射既有 bid participation request 等待办通知 | 普通聊天未读、论坛互动未读 |
| `system` | 平台系统通知 | 项目沟通业务状态、论坛互动业务状态 |

`business_todo` 是通知筛选 / 展示 lane，不替代项目沟通业务待办真值。项目沟通工具红点仍以 `businessTodoSummary` 与 `entries[].badgeCount` 为唯一来源。

## 4. 铃铛边界

铃铛是全平台通知入口，应支持来源分组：

- 全部
- 项目沟通
- 论坛互动
- 业务待办
- 系统

铃铛顶部总数必须可解释：

`unread.total = projectCommunication + forumInteraction + businessTodo + system`

若 V1 仍保留兼容字段 `bidParticipationRequest`，它只能作为 `businessTodo` 的组成项或兼容投影，不得在 UI 上造成第二套业务待办口径。

铃铛不得把项目消息塞进论坛互动，不得把论坛互动塞进项目沟通。

## 5. Tab 边界

### 5.1 项目沟通 Tab

只展示：

- 项目沟通主体会话列表。
- 主体下项目列表。
- 具体项目聊天框。
- 项目级业务快捷入口。

不得展示论坛互动 inbox 内容。

### 5.2 论坛互动 Tab

只展示：

- 回复我的。
- 收到的赞。
- 新关注。
- 其他已冻结的论坛互动提醒。

不得展示项目沟通消息、项目申请、项目资料确认、竞标待办。

## 6. 已读清除规则

通知已读清除必须满足：

1. 通知存在。
2. `routeTarget` 或等价承接目标可用。
3. Flutter 成功发起定位。
4. 然后才允许调用 mark-read。

如果 `routeTarget` 不存在、缺少必要参数、目标已失效、目标未冻结、或 Flutter 无法构造安全路由：

- 不允许 mark-read。
- 不允许假装处理完成。
- 必须显示中文提示：`当前通知暂时无法定位，请稍后重试或从对应入口进入。`
- 该通知保持未读，直到 Server truth 被正确处理或后续目标恢复。

## 7. 业务待办与普通未读

业务待办红点属于业务状态，不属于普通通知未读。

项目沟通中的：

- 进入审核红点
- 资料确认单红点
- 后续承接红点
- 项目卡业务待办红点

只能读取 Server 下发的：

- `businessTodoSummary`
- `entries[].badgeCount`

普通通知 unread 只能表达通知是否已读，不代表业务是否完成。

## 8. 不做范围

本轮不做：

- 泛 IM、群聊、私聊系统。
- 通知偏好中心。
- 推送渠道完整治理。
- 新论坛业务状态机。
- 新项目业务状态机。
- 支付、服务费、钱包、结算、发票、保证金。
- 履约、验收、评价、争议。
- 上游项目创建到发布主链路改动。

## 9. Runtime 与验收规则

本地代码、OpenAPI、generated types 不能证明云端 runtime 已对齐。

云端验收必须通过隧道 `http://127.0.0.1:8080` 做只读 smoke：

- `/api/app/notifications/list?source=project_communication`
- `/api/app/notifications/list?source=forum_interaction`
- `/api/app/notifications/list?source=business_todo`
- `/api/app/forum/interaction/inbox`
- `/api/app/message/interactions`

写入 smoke、部署、重启云端、清除真实通知、真实 mark-read 批量操作，均需单独授权。
