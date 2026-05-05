# 项目沟通 Shell 未读与互动中心可见投影同源修复 Addendum

状态：冻结

## 1. 总裁决

本轮选择更稳方案：修云上 Server unread 投影同源。

`shell/context.unreadSummary.messages` 仍由 Server 派生，但派生口径必须与 `GET /api/app/message/interactions?lane=project_communication` 当前可见互动中心列表同源。Flutter 不在启动阶段自行压掉 shell badge，BFF 不重算未读。

## 2. 当前最小闭环

本轮只处理以下闭环：

1. Server `shell/context.unreadSummary.messages` 使用 message interactions 可见会话投影求和。
2. 求和字段为可见 `counterpart_conversation` 列表项的 `conversationUnreadCount`。
3. BFF 继续透传 `/server/shell/context` 与 `/server/message/interactions`。
4. Flutter 继续默认显示 shell badge，进入消息页后保留现有前端展示纠偏。

## 3. 需要保留但暂不开通

本轮不做：

1. 不新增 App-facing route。
2. 不改 OpenAPI 字段。
3. 不改 read cursor 写入规则。
4. 不新增通用消息中心。
5. 不把论坛互动并入 `message/interactions`。
6. 不在 Flutter 启动阶段本地猜测 unread。
7. 不在 BFF 建立第二套未读真相。

## 4. 后续扩展位

后续如果需要让 shell badge 展示更多来源，必须先扩展 `message/interactions` 的可见承接项，而不是让 `shell/context` 单独统计不可见线程。

可扩展方向：

1. 补充新的 bounded card source，使被 shell 统计的项目沟通线程能在互动中心可见。
2. 增加只读诊断字段，例如 unread source breakdown，但不得成为新业务真相。
3. 做双账号 runtime UAT：同一登录态下 `shell/context.unreadSummary.messages` 等于 `message/interactions.items[].conversationUnreadCount` 合计。

## 5. 稳定性与成本判断

- 更稳：Server shell badge 与 `message/interactions` 共用可见会话投影，避免底栏显示用户无法找到的未读。
- 更省成本：保留 Flutter 进入消息页后的展示纠偏，但这不能解决冷启动角标。
- 更适合当前阶段：Server 小范围修正读取投影，不改合同、不改状态机、不扩大消息中心。
- 风险更大：继续让 shell 直接统计所有项目沟通线程，会再次出现 `shell=2`、`interactions=0` 的不可解释角标。

## 6. 云上问题证据

2026-05-04 通过本地隧道对指定登录态只读对比：

| Route | Result |
| --- | --- |
| `GET /api/app/shell/context` | `200`, `unreadSummary.messages = 2` |
| `GET /api/app/message/interactions?lane=project_communication` | `200`, `items.length = 1`, `conversationUnreadCount sum = 0` |

Computer Use 复现：

1. 清理 Flutter 生成缓存后启动 App，首页底部消息角标显示 `2`。
2. 点击消息进入互动中心后，底部角标消失。
3. 互动中心可见项目沟通卡未展示未读。

## 7. 验收标准

1. Server 本地测试证明 shell unread 优先等于 visible `message/interactions` 聚合。
2. BFF 不新增 unread 计算。
3. Flutter 不再新增启动阶段 unread 猜测。
4. 部署后同一登录态只读验证：
   - `shell/context.unreadSummary.messages == sum(message/interactions.items[].conversationUnreadCount)`.
