---
owner: Codex 总控
status: frozen
purpose: >
  Record Day-3 BFF/Flutter targeted verification and Day-4 cloud smoke plus
  single-window UI smoke outcome for counterpart conversation project entry
  title correction.
layer: L0 SSOT
recorded_at_local: 2026-04-26
based_on:
  - docs/00_ssot/counterpart_conversation_project_entry_title_truth_freeze_addendum.md
  - docs/03_bff/counterpart_conversation_project_entry_title_bff_surface_addendum.md
  - docs/04_frontend/counterpart_conversation_project_entry_title_frontend_consumption_addendum.md
  - docs/00_ssot/counterpart_conversation_project_entry_title_day2_server_execution_receipt_addendum.md
---

# 《消息楼项目入口标题 Day-3 / Day-4 验证回执》

## 1. 结论

Day-3 本地 BFF / Flutter targeted verification 通过。

Day-4 云上 tunnel health / route smoke 通过。

Day-4 单窗口 UI smoke 未通过业务画面验收：当前 `mobile`
窗口的“我的”页显示 `江北嘴嘴帅 / 当前账号：已登录`，但“消息”
页项目沟通接口返回：

`AUTH_SESSION_INVALID: Request must include a forwardable auth transport carrier or actor hint`

因此，本轮不能宣称云上 App 单窗口已经看到 `西洽会 - 泸州`。
这不是标题规则本地验证失败，而是当前 App 消息接口请求没有带有效
auth carrier，导致无法进入真实项目沟通列表。

仍未执行双账号多项目 UAT。

## 2. Day-3 BFF 验证

变更文件：

- `apps/bff/test/message-interaction-transport.test.cjs`

验证点：

- Server detail fixture 下发 `projectDisplayTitle = 西洽会 - 泸州`。
- BFF read-model 读取并透传完整 `projectDisplayTitle`。
- BFF 透传 `titleVisibility = visible`。
- BFF 不拼接标题，不创建第二标题真值。

通过命令：

- `corepack pnpm --dir apps/bff build`
- `node --test apps/bff/test/message-interaction-transport.test.cjs`

结果：

- BFF build：pass。
- BFF targeted suite：9 passed，0 failed。

## 3. Day-3 Flutter 验证

变更文件：

- `apps/mobile/test/counterpart_conversation_chat_test.dart`

验证点：

- 总框项目列表显示 `西洽会 - 泸州`。
- 总框项目列表显示 `西洽会 - 成都`。
- 进入泸州项目沟通页后仍显示 `西洽会 - 泸州`。
- 泸州项目沟通页只出现 `泸州项目消息`。
- 成都项目消息不混入泸州项目页。
- 聊天请求继续绑定 `projectId + threadId`。

通过命令：

- `flutter test test/counterpart_conversation_chat_test.dart --plain-name "counterpart total frame switches between two projects without mixing messages"`
- `flutter test test/counterpart_conversation_chat_test.dart`
- `flutter analyze lib/features/exhibition/presentation/pages/counterpart_conversation_page.dart lib/features/exhibition/presentation/pages/counterpart_conversation_widgets.dart lib/features/messages/data/counterpart_conversation_parser.dart test/counterpart_conversation_chat_test.dart`

结果：

- 单用例：pass。
- Counterpart conversation suite：14 passed，0 failed。
- Targeted analyze：No issues found。

## 4. Day-4 云上 Smoke

当前本机已存在 8080 隧道监听：

- `ssh` process listening on `127.0.0.1:8080`
- 隧道目标按当前约定：`ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`

通过的 health / ready：

| Probe | Result |
|---|---|
| `GET /health/bff/live` | `200`, `service=exhibition-bff`, `port=3000` |
| `GET /health/bff/ready` | `200`, `status=ready`, `service=exhibition-bff` |
| `GET /health/server/live` | `200`, `service=exhibition-server`, `port=3001` |
| `GET /health/server/ready` | `200`, `status=ready`, `service=exhibition-server` |

通过的 app-facing route smoke：

| Probe | Result |
|---|---|
| `GET /api/app/message/interactions` | `401 AUTH_SESSION_INVALID`, controlled auth gate |
| `GET /api/app/message/counterpart-conversation/detail?conversationId=route-smoke-org&projectId=route-smoke-project` | `401 AUTH_SESSION_INVALID`, controlled auth gate |

解释：

- `401 AUTH_SESSION_INVALID` 在未带登录 carrier 的 smoke 中是受控结果。
- 该结果证明路由 materialized 且受鉴权保护。
- 该结果不能证明业务数据里已经显示 `西洽会 - 泸州`。
- 该结果不能证明 Day-2 Server patch 已部署到云上 active runtime。

## 5. Day-4 单窗口 UI Smoke

Computer Use 检查对象：

- App：`mobile / com.example.mobile`
- Window：`mobile`

观察结果：

- “我的”页显示：
  - `江北嘴嘴帅`
  - `当前账号：已登录`
- “消息”页显示：
  - `项目沟通暂不可用`
  - `Request must include a forwardable auth transport carrier or actor hint (authorization, x-actor-id, or x-user-id header).`

判定：

- 单窗口 UI smoke：No-Go。
- 未看到 `西洽会 - 泸州` 项目入口。
- 阻断原因是当前 App 消息接口请求缺少有效 auth carrier。
- 不得把本地 Flutter widget test 通过冒充为云上单窗口 UI smoke 通过。

## 6. 当前最小闭环

当前已完成的最小闭环：

1. Server 本地专用 projection 修正已通过 targeted test。
2. BFF 本地 read-model 透传完整 `projectDisplayTitle` 已通过 targeted test。
3. Flutter 本地项目列表和项目页显示完整项目名已通过 targeted test。
4. 云上 BFF / Server health 与消息路由 materialization 已通过 tunnel smoke。

尚未闭合：

- 云上 active runtime 是否包含 Day-2 Server patch。
- 单窗口 App 真实项目入口是否显示 `西洽会 - 泸州`。
- 双账号多项目 UAT。

## 7. 需要保留但暂不开通

继续保留但本轮不开通：

- BFF 拼标题。
- Flutter 拼标题。
- 全局项目标题 helper 重构。
- 新增 `projectEntryTitle` 字段。
- 生产发布 / cutover。
- 双账号多项目 UAT 通过声明。

## 8. 后续扩展位

后续可单独开链：

- App auth carrier restoration：修复“我的”已登录但消息接口未带 carrier 的问题。
- Cloud runtime alignment：把 Day-2 Server patch 对齐到阿里云 active runtime。
- Real-account UI UAT：在有效账号会话下打开消息楼，检查 `西洽会 - 泸州` 项目入口。
- Dual-account multi-project UAT：同一对方主体下同时验证 `西洽会 - 泸州` / `西洽会 - 成都` 不串线。

## 9. 阶段判断

- 更稳：
  - 先保留 Day-3 本地验证通过结论，再把 Day-4 UI 阻断如实记录。
- 更省成本：
  - 只做 BFF/Flutter targeted tests 和 tunnel smoke，不在本轮强行发版。
- 更适合当前阶段：
  - 验证标题投影链路，并暴露真实 UI 验收的 auth carrier 阻断。
- 风险更大：
  - 在未看到真实 UI 的情况下宣称云上 App 已显示 `西洽会 - 泸州`，或用 Flutter widget test 替代真实登录态 UI smoke。

## 10. Next Stage Decision

允许进入下一阶段的范围：

- 修复或恢复 App 消息接口 auth carrier。
- 对齐云上 Server active runtime。
- 重新执行单窗口 UI smoke。

不允许进入：

- production release。
- cutover。
- 双账号多项目 UAT 通过声明。
