---
owner: Codex 总控
status: frozen
purpose: >
  Freeze Day-5 UAT boundary and remaining gates for counterpart conversation
  project-sliced IA after adding local two-project isolation coverage.
layer: L0 SSOT
recorded_at_local: 2026-04-26
result: targeted_pass_with_uat_blockers
based_on:
  - docs/00_ssot/counterpart_conversation_project_sliced_ia_correction_addendum.md
  - docs/04_frontend/counterpart_conversation_project_sliced_frontend_consumption_addendum.md
  - docs/00_ssot/counterpart_conversation_project_sliced_day4_acceptance_uat_record_addendum.md
---

# 《对方主体会话容器项目切片 Day-5 UAT 边界与剩余门禁冻结》

## 1. 结论

Day-5 当前结论：

- `Flutter two-project local isolation test: PASS`
- `Flutter targeted tests: PASS`
- `Touched-file analyze: PASS`
- `Messages shell jump tests: PASS`
- `Cloud dual-account multi-project UAT: BLOCKED / NO-GO`
- `Production acceptance: NO-GO`

Day-5 只能写成 `targeted pass with UAT blockers`，不能写成 cloud UAT pass 或 release ready。

## 2. Day-5 新增本地证据

新增 Flutter targeted test：

```bash
flutter test test/counterpart_conversation_chat_test.dart --plain-name "counterpart total frame switches between two projects without mixing messages"
```

覆盖规则：

- 对方主体总框显示 `西洽会泸州` / `西洽会成都` 两个项目入口。
- 未点击项目前，不调用：
  - `GET /api/app/message/project-communication/thread`
  - `GET /api/app/message/project-communication/messages`
- 点击 `西洽会泸州` 后，只请求：
  - `projectId=project-luzhou`
  - `threadId=thread-luzhou`
- 返回项目列表后点击 `西洽会成都`，只请求：
  - `projectId=project-chengdu`
  - `threadId=thread-chengdu`
- 泸州消息和成都消息在 UI 中互斥显示。
- read cursor 也分别携带对应 `projectId + threadId`。

同时修复：

- `_stopRealtime()` 关闭顺序调整为非阻塞取消监听，再关闭 subscription。
- subscription close 增加短超时，避免实时流异常时阻塞返回项目列表或切换项目。

## 3. Verification

执行目录：

```bash
cd /Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile
```

| Command | Result |
|---|---|
| `flutter test test/counterpart_conversation_chat_test.dart --plain-name "counterpart total frame switches between two projects without mixing messages"` | PASS |
| `flutter test test/counterpart_conversation_chat_test.dart test/project_name_access_day45_test.dart test/messages_instance_todo_test.dart` | PASS, `25` tests passed |
| `flutter analyze lib/features/exhibition/presentation/pages/counterpart_conversation_page.dart lib/features/exhibition/presentation/pages/counterpart_conversation_widgets.dart lib/features/exhibition/presentation/pages/project_album_page.dart test/counterpart_conversation_chat_test.dart test/project_name_access_day45_test.dart` | PASS |
| `flutter test test/shell_app_test.dart --name "messages interactions jump stably to project communication page|core v1 local chain runs from bid submit to my bids"` | PASS, `2` tests passed |
| `git diff --check` | PASS |

## 4. 本地 Test 与真实云上 UAT 边界

本地 Flutter test 已证明：

- IA 切片逻辑成立。
- 总框只列项目入口。
- 未点击项目前不加载聊天 thread / messages。
- 项目沟通页以 `projectId + threadId` 读取消息。
- 两个项目在本地 fixture 下不会混用 thread、messages、read cursor。

本地 Flutter test 不能证明：

- 云上真实账号登录态有效。
- 云上同一对方主体确实有两个真实项目入口。
- 双账号真实收发、历史回读、实时推送完全成立。
- 生产环境多项目隔离已经验收通过。

真实云上 UAT 必须补齐：

- 两个可操作 App 窗口，或受控账号切换流程。
- Account A / Account B 均为真实登录态。
- 同一对方主体下至少两个真实云上项目入口。
- 点项目 A 只加载 A 的 `projectId + threadId`。
- 点项目 B 只加载 B 的 `projectId + threadId`。
- A/B 项目聊天记录互不串线。
- 若验证实时能力，必须记录 messageId、clientMessageId、时间戳、是否需要手动刷新。

## 5. 阶段门禁核查表

Passed gates:

- Flutter targeted tests: PASS
- touched-file analyze: PASS
- `git diff --check`: PASS
- messages shell jump tests: PASS
- local two-project IA isolation: PASS
- Flutter only talks to BFF: PASS
- 总框只列项目入口: PASS
- 项目页才显示聊天: PASS
- 聊天锚定 `projectId + threadId`: PASS

Blocked / failed gates:

- dual-account real App sessions: BLOCKED
- two visible usable Flutter windows: BLOCKED
- same counterpart with two real cloud project entries: NOT PROVEN
- project A / project B cloud chat isolation: NOT PROVEN
- real send / receive cross-account UAT: NOT RUN / BLOCKED
- production acceptance: NO-GO
- cutover / release judgment: NO-GO

Veto gates:

- 缺真实双账号多项目证据时，生产发布一票否决。
- 用单窗口 / 单项目 smoke 冒充多项目隔离，一票否决。
- 用 DB / API / actor hint / mock token 替代真实 UI UAT，一票否决。
- Flutter direct-to-Server，一票否决。
- 未冻结字段边界就扩展 BFF / Server，一票否决。

## 6. 当前最小闭环

当前最小闭环：

1. 一个对方主体一个总框。
2. 总框只列项目入口。
3. 项目入口进入此项目竞标沟通页。
4. 项目页显示按钮化业务入口。
5. 项目页加载项目级聊天。
6. 本地双项目 fixture 已证明 `projectId + threadId` 不串线。

## 7. 需要保留但暂不开通

保留但暂不开通：

- production release
- cutover
- generic DM
- group chat
- 跨项目统一聊天
- 图片聊天消息
- DB / API / mock 登录态替代 UAT
- Flutter 本地伪造认证公司字段

## 8. 后续扩展位

后续扩展位：

- 准备或恢复同一对方主体下两个真实云上项目样本。
- 恢复两个已登录 App 窗口。
- 执行真实双账号多项目 UAT。
- 在真实 UAT 后补 cloud acceptance receipt。

## 9. 策略判断

- 更稳：
  - Day-5 只声明 targeted pass，不声明 production pass。
- 更省成本：
  - 不动 BFF / Server，先补登录态和双项目云上样本。
- 更适合当前阶段：
  - 用本地双项目测试补齐前端隔离门禁，再等待真实 UAT 输入条件。
- 风险更大：
  - 把本地双项目 fixture 或未登录 route smoke 包装成真实云上多项目 UAT 通过。
