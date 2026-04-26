---
owner: Codex 总控
status: frozen
purpose: >
  Record Day-4 acceptance evidence for the corrected counterpart conversation
  project-sliced IA: Flutter targeted tests, necessary BFF / Server smoke, and
  cloud dual-account multi-project UAT gate result.
layer: L0 SSOT
recorded_at_local: 2026-04-26 17:21 CST
result: pass_with_blockers
based_on:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/counterpart_conversation_project_sliced_ia_correction_addendum.md
  - docs/04_frontend/counterpart_conversation_project_sliced_frontend_consumption_addendum.md
  - docs/00_ssot/counterpart_conversation_project_sliced_day1_stage_gate_checklist_addendum.md
  - docs/00_ssot/project_communication_album_rating_bff_server_day4_execution_receipt_addendum.md
  - docs/00_ssot/project_communication_realtime_ws_dual_account_uat_data_and_remaining_gates_20260427_addendum.md
  - docs/00_ssot/project_communication_album_rating_day0427_day0430_uat_login_state_blocker_20260426_addendum.md
---

# 《对方主体会话容器项目切片 Day-4 验收与云上 UAT 记录》

## 1. 结论

Day-4 当前裁决：

| Gate | Result | 说明 |
|---|---|---|
| Flutter targeted tests | PASS | 本地项目切片 IA、项目级聊天、名称申请入口相关测试通过。 |
| Flutter touched-file analyze | PASS | 本次触达页面与两组相关测试无 analyzer issue。 |
| `git diff --check` | PASS | 未发现空白/补丁格式问题。 |
| 8080 tunnel | PASS | 本机已有 `127.0.0.1:8080 -> 47.108.180.198:80` SSH 隧道监听。 |
| Cloud BFF / Server health | PASS | BFF / Server `live` 与 `ready` 均返回 `200`。 |
| App-facing route smoke | PASS | 项目沟通相关保护路由返回受控 `401 AUTH_SESSION_INVALID`，不是路由级 `404`。 |
| Computer Use single-window UI smoke | PASS | 当前 `mobile` 窗口可进入消息页、总框项目列表、单项目沟通页。 |
| Cloud dual-account multi-project UAT | BLOCKED / NO-GO | 当前只有一个可见 App 窗口和一个项目入口，不能冒充双账号多项目 UAT 通过。 |
| Production / release judgment | NO-GO | 多项目隔离的真实双账号 UI 证据未完成。 |

Day-4 允许收口为 `PASS WITH BLOCKERS`，不允许写成 production pass。

## 2. 验收边界

本轮验收只承认三个证据层：

1. 本地 Flutter targeted tests。
2. 通过 8080 隧道访问云上 BFF / Server 的必要 smoke。
3. 真实双账号、多项目、UI 可点击链路的 UAT 证据。

本轮没有做、也不允许用来替代 UAT 的事项：

- 不启动本地 BFF / Server。
- 不把 BFF / Server 假设成本地可写可运行。
- 不记录密码、OTP、access token、refresh token。
- 不用 actor hint、mock token、DB 直改来冒充双账号 UI 验收。
- 不把单项目 smoke 写成多项目隔离通过。

## 3. Flutter Targeted Evidence

执行目录：

```bash
cd /Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile
```

| Command | Result | Evidence |
|---|---|---|
| `flutter test test/counterpart_conversation_chat_test.dart test/project_name_access_day45_test.dart test/messages_instance_todo_test.dart` | PASS | `24` tests passed. |
| `flutter test test/shell_app_test.dart --name "messages interactions jump stably to project communication page|core v1 local chain runs from bid submit to my bids"` | PASS | `2` tests passed. |
| `flutter analyze lib/features/exhibition/presentation/pages/counterpart_conversation_page.dart lib/features/exhibition/presentation/pages/counterpart_conversation_widgets.dart lib/features/exhibition/presentation/pages/project_album_page.dart test/counterpart_conversation_chat_test.dart test/project_name_access_day45_test.dart` | PASS | No issues found. |
| `git diff --check` | PASS | No output. |

备注：

- 曾并行启动两组 Flutter 命令，导致一次非业务性的 `unit_test_assets/shaders/ink_sparkle.frag` 写文件冲突；已中断并串行复跑，串行结果为 PASS。
- 扩大 analyzer 到 `test/messages_instance_todo_test.dart` 时存在一条既有 `use_null_aware_elements` info；该文件不是 Day2 / Day3 页面拆分触达面，未作为本轮 targeted gate 失败项。

Targeted 覆盖确认：

- 总框态只显示对方主体下的项目入口列表。
- 未点击具体项目入口前，不展示聊天记录、输入框、订单大卡、项目相册。
- 点击 `进入此项目竞标沟通` 后才进入项目沟通页。
- 项目沟通页按顺序承载：
  - `竞标沟通`
  - `项目名称查看申请 / 审核`
  - `订单状态`
  - `项目相册`
  - 聊天记录和输入框
- 项目聊天发送、刷新、实时订阅均以 `projectId + threadId` 为锚点。

## 4. Cloud BFF / Server Smoke

环境：

- Local tunnel:
  - `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`
- Observed listener:
  - `ssh` process listening on `127.0.0.1:8080` and `[::1]:8080`
- App-facing base:
  - `http://127.0.0.1:8080/api/app`

Health probes:

| Probe | Result |
|---|---|
| `GET /health/bff/live` | `200`, service `exhibition-bff`, port `3000` |
| `GET /health/bff/ready` | `200`, service `exhibition-bff` |
| `GET /health/server/live` | `200`, service `exhibition-server`, port `3001` |
| `GET /health/server/ready` | `200`, service `exhibition-server` |

App-facing protected route probes:

| Probe | Result | 裁决 |
|---|---|---|
| `GET /api/app/message/interactions?lane=project_communication` | `401 AUTH_SESSION_INVALID` | mounted and auth-gated |
| `GET /api/app/message/counterpart-conversation/detail?conversationId=...&projectId=...` | `401 AUTH_SESSION_INVALID` | mounted and auth-gated |
| `GET /api/app/message/project-communication/thread?projectId=...&counterpartOrganizationId=...` | `401 AUTH_SESSION_INVALID` | mounted and auth-gated |
| `GET /api/app/message/project-communication/messages?threadId=...&projectId=...` | `401 AUTH_SESSION_INVALID` | mounted and auth-gated |
| `POST /api/app/message/project-communication/messages` with `threadId + projectId + body` | `401 AUTH_SESSION_INVALID` | mounted and auth-gated |
| `POST /api/app/message/project-communication/read-cursor` with `threadId + projectId` | `401 AUTH_SESSION_INVALID` | mounted and auth-gated |

说明：

- 这些 probes 不创建项目、订单、相册、竞标、评价或聊天消息业务状态。
- `401 AUTH_SESSION_INVALID` 是受控鉴权失败；本轮 smoke 要证明的是路由存在并受鉴权保护，不是用未登录请求读取真实业务数据。
- App 必须只走 BFF。直接探测 `/server/project-communication/*` 经当前 Nginx 返回 `404`，不作为 App-facing 验收面。

## 5. Cloud Dual-Account Multi-Project UAT

当前可用资料：

- 既有 UAT 准备文档登记了 A/B 账号、组织、`projectId`、`threadId` 等非敏感锚点。
- 既有阻断回执记录过 two-window 登录态不可用，明确不能用 DB/API/actor hints/mock token 替代 Computer Use 证据。
- 本轮 CLI 环境变量检查只发现 `SSH_AUTH_SOCK`，没有可复用的 UAT 登录凭据、session、token 或 OTP。
- Computer Use 当前只发现一个 `mobile` 窗口。

Computer Use 单窗口 UI smoke：

| Step | Observed result | Result |
|---|---|---|
| App list | `mobile` is running as `com.example.mobile` | PASS |
| Open bottom tab `消息` | Shows `互动中心` and one `项目沟通` card for `江北嘴嘴帅` | PASS |
| Enter counterpart conversation | Page title `项目沟通`; shows counterpart header and `项目列表` only | PASS |
| Total frame content | Shows project entry `西洽会`; no chat input, no expanded order card, no expanded album | PASS |
| Enter project communication | Shows `竞标沟通`, project name `西洽会`, buttons `项目名称查看申请 / 审核`, `订单状态`, `项目相册`, then chat and input | PASS |
| Business mutation | No message was sent; no order/album/status action was clicked | PASS |

本轮实际裁决：

| 项 | Result |
|---|---|
| 单窗口 UI IA smoke | PASS |
| 双账号真实登录态 | BLOCKED |
| two-window Computer Use 点击证据 | BLOCKED |
| 同一对方主体下两个云上项目入口 | NOT PROVEN，当前可见为 `项目 1 个` |
| 项目 A / 项目 B 聊天不串线 | NOT PROVEN |
| 生产发布 UAT | NO-GO |

该阻断不是 Flutter targeted IA 失败，也不是 BFF / Server health 失败；它是云上真实 UAT 输入条件不足。

## 6. 阶段门禁核查表

Passed gates:

- `counterpart conversation project-sliced IA` 本地 targeted 测试通过。
- 本次触达 Flutter 文件 analyzer 通过。
- `git diff --check` 通过。
- 8080 隧道可用。
- BFF / Server health 通过。
- 项目沟通 app-facing routes 已 materialize，并且未登录时受控鉴权失败。
- Computer Use 单窗口 UI smoke 通过。
- 本地 Flutter 未直连 Server。
- 没有开启 generic DM / group chat / 跨项目统一聊天。

Failed / blocked gates:

- 云上双账号多项目 UI UAT 未通过。
- two-window Computer Use 点击验收未完成。
- 同一对方主体下两个项目的真实云上样本未被本轮证明。
- 全量 Flutter regression pass 未作为本轮通过项。
- Production / cutover gate 未通过。

Veto gate:

- 对生产发布：触发 veto。原因是多项目隔离的真实双账号 UAT 证据缺失。
- 对当前 targeted IA 收口：未触发 veto。原因是本地 IA 行为与 app-facing route smoke 已闭环。

## 7. 当前最小闭环

当前最小闭环是：

1. 消息楼一级仍是“一个对方主体一个总框”。
2. 对方主体总框只承载项目入口列表。
3. 具体项目入口才进入项目沟通页。
4. 聊天只在项目沟通页出现。
5. 聊天请求以 `projectId + threadId` 为强锚点。
6. 云上 BFF / Server 存活且项目沟通保护路由存在。
7. 单窗口 UI 已验证“总框只列项目入口，项目页才显示聊天”。

## 8. 需要保留但暂不开通

保留但本轮不开通：

- generic DM
- group chat
- 跨项目统一聊天
- 图片聊天消息
- 语音 / 表情 / presence / typing
- 订单状态在总框展开
- 项目相册在总框展开
- Flutter 本地伪造认证公司字段
- 未登录或 mock 登录态下的双账号 UAT 替代口径

## 9. 后续扩展位

后续扩展位：

- 准备或恢复同一对方主体下至少两个真实云上项目样本。
- 增加 Flutter 双项目隔离自动化：
  - 总框显示项目 A / 项目 B 两个入口。
  - 点项目 A 只加载 A 的 `projectId + threadId`。
  - 返回后点项目 B 只加载 B 的 `projectId + threadId`。
  - A/B 消息互不串线。
- 增加请求门禁测试：
  - 未点击项目入口前不得调用 thread / messages / WebSocket / album / order detail。
- 恢复两个已登录 App 窗口后执行 Computer Use UAT。

## 10. 策略判断

- 更稳：
  - 先承认 Day-4 `PASS WITH BLOCKERS`，补真实双账号多项目 UAT 数据后再签生产通过。
- 更省成本：
  - 不动 BFF / Server，复用现有 8080 隧道和已冻结 app-facing contract，优先补 UAT 登录态和双项目样本。
- 更适合当前阶段：
  - 以 targeted pass + cloud smoke pass 作为 Day-4 阶段收口，不把缺失的 UI UAT 写成已完成。
- 风险更大：
  - 只有未登录 route smoke 或单项目样本就宣称多项目隔离已通过。
  - 跳过 two-window UI 验收直接发布。
  - 为了验收临时直改 DB 或使用 actor hint 制造业务结果。

## 11. 下一阶段允许项

允许进入：

- Day-5 UAT 数据准备。
- 双账号登录态恢复。
- 双项目样本准备。
- 双项目隔离 targeted test 补强。

不允许进入：

- production release
- cutover
- 宣称 cloud dual-account multi-project UAT 已通过
