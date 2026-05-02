---
owner: Codex 总控
status: effective
purpose: Freeze Day-1 truth for message-building project communication readability, business-entry copy, and in-app unread reminder boundaries.
layer: L0 SSOT
---

# Counterpart Conversation Message Building Readability Day1 Truth Freeze

## 结论

本轮正式目标是优化消息楼项目沟通的可读性和 App 内未读提醒，不改变聊天真值、不改变竞标/审核/订单状态机、不引入系统通知能力。

本轮修复的问题不是单纯 UI 样式，而是三类缺口：

- 项目入口缺少结构化 `projectPublishedAt`，不能展示真实项目发布时间。
- 项目页业务入口缺少结构化申请方字段，导致只能显示固定按钮文案或依赖 summary 文案。
- App 内消息未读没有从 project communication read cursor 聚合进 shell unread summary，底部消息楼没有红点/数字。

## 当前最小闭环

本轮只做以下闭环：

1. 消息楼对方主体总框页继续只列项目入口，不显示聊天框。
2. 项目入口卡片新增真实发布时间、未读提示和轻量进入按钮。
3. 项目页业务入口拆成：
   - 业务说明：`某某公司申请查看该项目详情并参与竞标`
   - 按钮：`进入审核`
4. App 内未读提示打通：
   - `shellContext.unreadSummary.messages`
   - 项目入口 `projectUnreadCount`
   - 项目入口 `hasProjectUnread`
5. 进入具体项目沟通页后，继续使用既有 read-cursor mark read。

## 总框页 IA 冻结

对方主体总框页正式保留为非聊天容器：

- 顶部卡片标题：`当前沟通对象`
- 展示字段：
  - 对方头像
  - 对方昵称或主体展示名
  - 认证公司
- 允许右上角入口：`沟通指南`
- 项目列表区：
  - 标题：`项目列表`
  - 说明：`选择具体项目后进入此项目竞标沟通；总框不承接聊天业务。`
  - tab：`我的发布 · n` / `我的竞标 · n`
  - 本地搜索框：`搜索项目名称`
  - 项目卡：状态 chip、业务数 chip、未读 chip、项目名、说明、发布时间、进入按钮
- 总框页仍禁止：
  - 聊天记录
  - 聊天输入框
  - 自动创建或消费项目聊天 thread
  - 跨项目合并消息

## 项目入口字段真值

项目入口新增字段的正式来源如下：

| Field | Source owner | Truth source | Display rule |
| --- | --- | --- | --- |
| `projectPublishedAt` | Server | `ProjectEntity.publishedAt` | 显示为 `发布时间：yyyy-MM-dd HH:mm`；为空时隐藏，不得用其它时间冒充。 |
| `projectUpdatedAt` | Server | `ProjectEntity.updatedAt` | 保留字段，可作为未来排序/说明，不替代发布时间。 |
| `latestActivityAt` | Server | counterpart conversation seed latest activity | 只表示当前沟通聚合最新活动，不得显示为发布时间。 |
| `projectUnreadCount` | Server | project communication thread + read cursor | 大于 0 时显示 `未读 n`。 |
| `hasProjectUnread` | Server | `projectUnreadCount > 0` | 可用于红点或轻量 badge。 |

明确禁止：

- Flutter 用 `latestActivityAt` 冒充 `projectPublishedAt`。
- BFF 生成或猜测项目发布时间。
- 用项目卡排序时间、活动时间、更新时间冒充发布时间。

## 业务入口字段真值

项目页业务入口新增字段如下：

| Field | Source owner | Applies to | Display rule |
| --- | --- | --- | --- |
| `requesterCompanyName` | Server | `project_name_access_request`, `bid_participation_request` | 用于业务说明中的真实申请公司名。 |
| `requesterOrganizationId` | Server | `project_name_access_request`, `bid_participation_request` | 用于审计和后续跳转上下文，不直接展示为主文案。 |

正式文案规则：

- 若同一项目存在参与竞标申请卡，则项目页业务说明显示：
  - `{requesterCompanyName}申请查看该项目详情并参与竞标`
- 若只有项目名称查看申请卡，则显示：
  - `{requesterCompanyName}申请查看该项目详情`
- 按钮固定为：
  - `进入审核`
- 不允许把长句塞进按钮。
- 不允许从 `summary` 字符串截取公司名。

## App 内未读提醒边界

本轮只开通 App 内未读提醒，不开通系统通知。

允许范围：

- `shellContext.unreadSummary.messages`
- 底部消息楼 badge
- 项目列表卡 `未读 n`
- 进入项目沟通页后继续使用既有 read-cursor 标记已读

计算规则：

- 只使用既有数据：
  - `project_communication_threads.lastMessageAt`
  - `project_communication_read_cursors.lastReadAt`
  - 当前组织 scope
- 对当前组织参与的 project communication threads 计算未读。
- 如果 `lastMessageAt` 为空，则未读为 0。
- 如果当前组织没有 cursor 且存在 last message，则视为未读。
- 如果 cursor `lastReadAt < lastMessageAt`，则视为未读。
- 本阶段项目级 `projectUnreadCount` 可以按 thread 粒度为 `0 | 1` 最小闭环；后续如需精确消息条数，另开字段冻结。

明确禁止：

- 引入 push token。
- 请求系统通知权限。
- 做声音、震动、锁屏通知。
- 做跨楼层通知中心。
- 做复杂通知设置页。

## 涉及层

| Layer | In scope | Rule |
| --- | --- | --- |
| SSOT | Yes | 本文件冻结本轮真相和边界。 |
| Contracts | Yes | 由配套 L2 addendum 冻结字段。 |
| Server | Yes | 只读 projection 补字段和未读聚合；不新增表、不迁移。 |
| BFF | Yes | 透传和校验，不拥有业务真值。 |
| Flutter | Yes | 页面重排、字段消费、本地搜索、未读显示。 |
| Cloud UAT | Yes | 最后阶段才执行云上 current 对齐和 8080 验收。 |

## 需要保留但暂不开通

- 系统级 push
- 声音震动
- 锁屏通知
- 跨楼层通知中心
- 复杂通知设置
- 通知偏好页
- 后台推送失败重试

## 后续扩展位

- 项目卡显示最后一条消息。
- 申请/审核/聊天分类未读。
- 消息页顶部 `新动态` 提示条。
- App 内 toast。
- 系统 push 独立阶段。

## 阶段判断

- 更稳：补 Server/BFF 结构化字段，再改 Flutter。
- 更省成本：只改 Flutter 样式，但不能真实解决发布时间、申请公司、未读提示。
- 更适合当前阶段：`projectPublishedAt + requesterCompanyName + unreadSummary.messages` 最小闭环。
- 风险更大：从 summary 截公司名、用 `latestActivityAt` 冒充发布时间、把 App 内未读扩大成系统通知。
