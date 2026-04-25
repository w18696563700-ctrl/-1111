---
owner: Codex 总控
status: conditional_pass
purpose: >
  Record the Day-6 to Day-8 Flutter acceptance, regression, and live tunnel
  verification result for the counterpart conversation container and project
  name access permission sheet.
layer: L5 Frontend
verified_at_local: 2026-04-24
target_schedule:
  - Day 6: 2026-05-05
  - Day 7: 2026-05-06
  - Day 8: 2026-05-07
based_on:
  - docs/00_ssot/counterpart_conversation_truth_freeze_addendum.md
  - docs/00_ssot/counterpart_conversation_route_table_addendum.md
  - docs/04_frontend/counterpart_conversation_frontend_consumption_freeze_addendum.md
  - docs/04_frontend/project_name_access_request_frontend_consumption_freeze_addendum.md
---

# 《对方主体会话容器 Day-6 至 Day-8 前端验收报告》

## 1. Scope

- 本报告覆盖：
  - Day-6 项目详情标题点击权限 sheet
  - Day-7 本地 Flutter 通过隧道连接阿里云运行态联调
  - Day-8 回归、缺陷记录、上线包前置判断
  - 2026-05-07 项目沟通文字聊天实际点击验收
- 本报告不覆盖：
  - Server / BFF 新业务真值实现本身
  - 生产 UAT 签字
  - 旧入口最终下线

## 2. Day-6 Acceptance

- 项目详情页标题 `项目名称需申请查看` 已改为可点击入口。
- 点击标题后弹出 `ProjectNameAccessPermissionSheet`。
- `申请查看项目名称`、`查看申请状态`、`刷新状态` 已收进 sheet。
- 详情页下方独立 `项目名称查看权限` 大卡已删除。
- 未授权态不再通过独立大卡承接名称申请动作。
- 已保留旧 `project_name_access_thread` 作为申请状态 detail carrier。

## 3. Day-7 Live Tunnel Verification

- 运行入口：
  - `APP_RUNTIME_ENTRY_MODE=ssh_tunnel APP_INITIAL_ROUTE=/ ./scripts/run_macos_formal.sh`
- Flutter app-facing base URL：
  - `http://127.0.0.1:8080/api/app`
- 隧道前置：
  - `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`

## 4. Computer Use Verification Evidence

- 消息楼一级入口：
  - 只看到 `项目沟通` 容器卡。
  - 对方主体为 `重庆海川展览工厂`。
  - 卡片不再展示 `对方主体 / 1 个项目 / 名称申请` 三个 chip。
  - 卡片改为展示头像、对方主体名称、`昵称`、业务摘要。
  - CTA 为 `进入项目沟通`，按钮与卡片宽度对齐。
- 统一会话页：
  - 点击 `进入项目沟通` 后进入统一容器页。
  - 页面按项目分组展示。
  - 项目分组标题为 `项目名称需申请查看`。
  - 分组内同时承接 `项目名称申请` 和 `竞标沟通` 两类业务卡。
  - `查看申请` 与 `进入竞标沟通` 两个 CTA 同宽并在底部输入栏上方完整露出。
- 旧 carrier fallback：
  - 点击 `查看申请` 后进入旧 `名称查看申请` 详情 carrier。
  - 页面可见 `线程 ID / 项目 ID / 申请 ID / 当前状态`。
  - 旧 carrier 仅作为真值详情承接，不再作为消息楼主入口。
  - 点击 `进入竞标沟通` 后进入旧 `沟通与投标` carrier。
  - 旧 `bid_thread` 页面仍可见项目 ID、投标 ID、线程状态与参与方。
- 项目沟通文字聊天：
  - 本地 macOS Flutter 使用 `APP_RUNTIME_ENTRY_MODE=ssh_tunnel`。
  - 通过 `127.0.0.1:8080` 连接阿里云 BFF。
  - 统一项目沟通页底部文字输入框可输入并发送文字。
  - 实际发送消息：`ua`。
  - 发送后聊天区出现 `ua`，时间为 `17:18`。
  - 点击 `刷新聊天` 后，accessibility tree 仍包含 `ua 17:18`，确认消息从云上读回，不是本地临时草稿。
- 项目详情标题 sheet：
  - 进入项目详情页后，下方独立 `项目名称查看权限` 大卡已不存在。
  - 点击标题 `项目名称需申请查看` 后弹出权限 sheet。
  - sheet 内展示 `待审批`、当前说明、`等待审批中`、`查看申请状态`、`刷新状态`。

## 5. Five Required Checks

- 统一消息入口成立：
  - passed
  - 一级消息楼显示对方主体会话容器，而不是多个旧业务 thread。
- 项目边界清楚：
  - passed
  - 统一容器页按项目分组展示，不合并项目状态。
- 所有动作带 `projectId`：
  - passed
  - 旧 carrier 页面可见 `项目 ID`，自动化测试覆盖 route query handoff。
- 标题弹 sheet 成立：
  - passed
  - 标题点击先弹权限 sheet，不直接跳旧 thread。
- 旧真值接口仍可回退：
  - passed
  - `名称查看申请` 旧 carrier 可由统一容器和 sheet 进入。
- 项目沟通文字发送：
  - passed
  - 统一项目沟通页发送文字后刷新仍存在。

## 6. Regression Commands

- Flutter 静态检查：
  - `flutter analyze lib/features/exhibition/presentation/exhibition_trade_pages.dart lib/features/exhibition/presentation/pages/project_detail_page.dart lib/features/exhibition/presentation/pages/project_detail_actions_support.dart lib/features/exhibition/presentation/pages/project_name_access_permission_sheet.dart test/project_name_access_day45_test.dart`
  - result: passed
- 项目沟通消息楼与聊天 targeted check：
  - `flutter analyze lib/features/messages/presentation/messages_page.dart lib/features/exhibition/presentation/pages/counterpart_conversation_widgets.dart lib/features/exhibition/presentation/pages/counterpart_conversation_page.dart lib/features/exhibition/presentation/pages/counterpart_conversation_chat_widgets.dart`
  - result: passed
- 项目沟通 targeted widget tests：
  - `flutter test test/counterpart_conversation_chat_test.dart test/messages_instance_todo_test.dart`
  - result: passed
- macOS 本地云上联调启动：
  - `APP_RUNTIME_ENTRY_MODE=ssh_tunnel APP_INITIAL_ROUTE=/messages ./apps/mobile/scripts/run_macos_formal.sh`
  - result: build passed and app launched against `http://127.0.0.1:8080/api/app`
- 项目名称申请与消息楼测试：
  - `flutter test test/project_name_access_day45_test.dart test/messages_instance_todo_test.dart --reporter expanded`
  - result: passed
- shell 主链回归：
  - `flutter test test/shell_app_test.dart --name "messages interactions jump stably to bid thread routes|core v1 local chain runs from bid submit to my bids, interactions, thread and snapshot" --reporter expanded`
  - result: passed

## 7. Defect Log

- `D7-001`：
  - symptom: 旧 macOS 运行实例仍显示详情页下方独立权限大卡。
  - classification: stale local binary, not source defect.
  - disposition: 结束旧进程并通过 `run_macos_formal.sh` 重启后通过。
- `D7-002`：
  - symptom: 裸 `curl` 请求 `GET /api/app/message/interactions` 返回 `401`。
  - classification: expected auth boundary.
  - disposition: 带真实 app session 的本地 Flutter 通过隧道联调成功，裸请求不作为业务失败。
- `D7-003`：
  - symptom: 消息楼项目沟通卡仍显示 `对方主体 / 1 个项目 / 名称申请` 三个 chip。
  - classification: visual acceptance defect.
  - disposition: fixed，改为头像 + 对方主体名称 + `昵称` + 摘要。
- `D7-004`：
  - symptom: 统一项目沟通页底部输入栏遮挡低位 `进入竞标沟通` CTA。
  - classification: visual / clickability acceptance defect.
  - disposition: fixed，压缩项目沟通头部和业务卡高度，两个 CTA 完整露出。
- `D7-005`：
  - symptom: Computer Use `set_value` 可改 accessibility 值，但 Flutter `TextField` controller 仍认为内容为空。
  - classification: automation input limitation.
  - disposition: 改用真实键盘输入 ASCII `ua`，发送成功；不是业务接口缺陷。

## 8. Acceptance Decision

- Day-6：
  - passed
- Day-7：
  - passed for engineering integration verification
- Day-8：
  - conditional pass for UAT entry
- 2026-05-07 actual click verification：
  - passed
  - 消息楼进入项目沟通、查看申请、进入竞标沟通、发送文字、刷新后仍存在均已实测。
- 当前结论：
  - Flutter 侧可进入用户 UAT。
  - 项目沟通页可作为 UAT 主入口候选。
  - 旧 carrier 必须继续保留。
  - 旧入口显式露出是否下线，必须等待 UAT 通过后再裁决。
