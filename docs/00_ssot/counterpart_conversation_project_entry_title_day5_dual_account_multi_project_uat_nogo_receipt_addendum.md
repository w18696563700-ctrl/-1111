---
owner: Codex 总控
status: frozen
purpose: >
  Record Day-5 dual-account multi-project UAT attempt for counterpart
  conversation project entry titles and project-level chat isolation.
layer: L0 SSOT
recorded_at_local: 2026-04-26
result: no_go
based_on:
  - docs/00_ssot/counterpart_conversation_project_entry_title_truth_freeze_addendum.md
  - docs/00_ssot/counterpart_conversation_project_entry_title_day2_server_execution_receipt_addendum.md
  - docs/00_ssot/counterpart_conversation_project_entry_title_day3_day4_verification_receipt_addendum.md
  - docs/00_ssot/counterpart_conversation_project_sliced_day5_uat_boundary_and_remaining_gates_addendum.md
---

# 《消息楼项目入口标题 Day-5 双账号多项目 UAT No-Go 回执》

## 1. 结论

Day-5 双账号多项目 UAT 本次结论为 `NO-GO`。

不能允许后续发布判断。

核心原因：

- 云上真实 `project` 表当前只有 `西洽会 - 泸州` 一个目标项目。
- `西洽会 - 成都` 云上真实样本不存在。
- 当前同一 owner/counterpart 下只有一个 `project_communication_thread`。
- 只有一个可见 `mobile` App 窗口，不满足双账号双窗口 UAT。
- 阿里云 active Server runtime 仍是旧 projection 代码，未包含 Day-2
  `project.title` 优先修正。

因此，本次只能记录为：

- tunnel / active route 可达：`PASS`
- A/B 账号 DB session 存在：`PASS for prep`
- 单项目真实样本：`PASS`
- 双项目真实样本：`FAIL`
- 双账号多项目 UI UAT：`NOT RUN / BLOCKED`
- 发布判断：`NO-GO`

## 2. 当前云上运行态

8080 隧道当前可达：

- 本机 `127.0.0.1:8080` 由 `ssh` 进程监听。
- `GET /health/bff/live` 返回 `200`。

活跃承接方式：

- Nginx `80` 转发到 `127.0.0.1:3000` / `127.0.0.1:3001`。
- PM2 进程在线：
  - BFF：`bff-s6-r4`
  - Server：`server-s6-r6`
- systemd `exhibition-bff` / `exhibition-server` 当前显示反复失败，
  但不是 80/8080 当前活跃承接链。

active source snapshot：

- BFF cwd：`/srv/releases/bff/20260426035500-bff-order-detail-anchors/apps/bff`
- Server cwd：`/srv/releases/server/20260426033000-order-detail-anchors`

active Server dist 检查：

- `counterpart-conversation.projection.service.js` 仍使用
  `projection?.displayTitle ?? buildProjectDisplayTitle(project)`。
- 未看到 Day-2 新增的 `buildCounterpartProjectDisplayTitle()`。

判定：

- Day-2 Server patch 尚未对齐到阿里云 active runtime。
- 不能用当前云上 UI 证明标题修正已生效。

## 3. 当前真实样本

云上 `project` 表只读核验：

| Check | Result |
|---|---:|
| total project count | `1` |
| `西洽会 - 泸州` count | `1` |
| `西洽会 - 成都` count | `0` |

唯一目标项目：

| Field | Value |
|---|---|
| `projectId` | `c788eaff-6243-4e97-8be3-c4e174ee7944` |
| `project_no` | `EXH-2026-DD93A8` |
| `title` | `西洽会 - 泸州` |
| `exhibition_name` | `西洽会` |
| `brand_name` | `泸州` |
| `state` | `converted_to_order` |
| owner organization | `重庆坤特展览展示有限公司` |
| counterpart organization | `重庆展宏展览展示有限公司` |

当前真实沟通 thread：

| Field | Value |
|---|---|
| `threadId` | `afa6f969-66ea-403d-aafc-072fd5cd0f53` |
| `projectId` | `c788eaff-6243-4e97-8be3-c4e174ee7944` |
| `thread_state` | `open` |
| message count checked | `6` |
| direction proof | messages exist from both organizations |

判定：

- 单项目 `projectId + threadId` 锚点存在。
- 没有第二个真实项目入口，不能验证同一对方主体下多项目隔离。

## 4. 双账号条件

已有 A/B 非敏感账号锚点：

| Field | Account A / owner side | Account B / counterpart side |
|---|---|---|
| Nickname | `重庆海川展览工厂` | `江北嘴嘴帅` |
| Organization | `重庆坤特展览展示有限公司` | `重庆展宏展览展示有限公司` |
| Organization id | `e6bf4567-016e-45f9-9420-9c950237690e` | `bdfb4523-aeb7-4b56-89a1-992170fb5d98` |
| Latest DB session status | `valid` | `valid` |

边界：

- 不记录 password。
- 不记录 OTP。
- 不记录 access token 或 refresh token。
- DB session 存在只能说明 UAT 准备条件存在，不能替代真实 App UI UAT。

当前 Computer Use 状态：

- 只看到一个 `mobile / com.example.mobile` 窗口。
- 当前窗口停留在创建项目页。
- 不满足双账号双窗口 UAT 条件。

## 5. 本次未执行的动作

本次未写入云上业务数据：

- 未创建 `西洽会 - 成都` 项目。
- 未创建第二条 bid / thread。
- 未发送测试聊天消息。
- 未直接改 DB 伪造 UAT 通过。
- 未用 actor hint / mock token 替代真实 UI UAT。

原因：

- 创建成都项目样本会写入云上业务数据。
- 发送测试聊天消息属于代表账号对第三方通信写入。
- 真实 UAT 不能用 DB/API/actor hint/mock token 冒充。

## 6. Day-5 Gate Checklist

Passed gates:

- SSH tunnel reachable：`PASS`
- BFF health through tunnel：`PASS`
- PM2 active BFF/Server process identified：`PASS`
- A/B account DB session exists：`PASS for prep`
- Existing `西洽会 - 泸州` project/thread/message anchors verified：`PASS`

Failed / blocked gates:

- `西洽会 - 成都` real cloud sample：`FAIL / MISSING`
- same counterpart with two real cloud project entries：`FAIL / NOT PROVEN`
- active Server runtime contains Day-2 title projection patch：`FAIL / NOT ALIGNED`
- two visible logged-in App windows：`BLOCKED`
- project A / project B UI chat isolation：`NOT RUN`
- cross-account send/receive UAT：`NOT RUN`
- production release judgment：`NO-GO`

Veto gates:

- 缺少两个真实云上项目时，不得宣称双项目 UAT 通过。
- 缺少两个真实登录 App 会话时，不得宣称双账号 UAT 通过。
- 当前 active Server 未包含 Day-2 patch 时，不得宣称云上标题修正通过。
- 不得用 DB / API / actor hint / mock token 替代真实 UI UAT。
- 发送测试聊天消息前必须单独确认。

## 7. 当前最小闭环

当前最小闭环只到：

1. 本地 Server / BFF / Flutter targeted tests 已证明投影和消费规则成立。
2. 云上 8080 tunnel 和消息 route 可达。
3. 云上真实单项目 `西洽会 - 泸州` 有项目沟通 thread。
4. 云上真实双项目 UAT 尚未成立。

## 8. 需要保留但暂不开通

继续保留但暂不开通：

- 发布判断。
- production release / cutover。
- DB 直写冒充 UAT。
- actor hint / mock token 冒充真实 App 登录态。
- 泛化群聊 / 泛化私信。
- 新增 `projectEntryTitle` 字段。

## 9. 后续扩展位

下一阶段必须先补齐：

1. 云上 Server runtime alignment：部署或切换到包含 Day-2 patch 的 Server。
2. 创建或通过真实流程产生 `西洽会 - 成都` 样本。
3. 为成都样本创建同一 counterpart 的真实竞标沟通入口和
   `project_communication_thread`。
4. 打开两个真实登录 App 窗口。
5. 逐项验证：
   - 总框同一对方主体下显示 `西洽会 - 泸州` / `西洽会 - 成都`。
   - 点泸州只加载泸州 `projectId + threadId`。
   - 点成都只加载成都 `projectId + threadId`。
   - 两边历史消息互不串线。
   - 如发送测试消息，记录 messageId、clientMessageId、时间戳、发送方。

## 10. 阶段判断

- 更稳：
  - 本轮如实记录 `NO-GO`，先补云上 runtime alignment 和真实成都样本。
- 更省成本：
  - 不直接改 BFF / Flutter；先只做必要云上 Server 对齐和样本准备。
- 更适合当前阶段：
  - 把 UAT 前置条件补齐后再做双账号 UI 验收。
- 风险更大：
  - 用本地 fixture、单项目 DB 证据、未对齐 runtime 或 actor hint/API
    route smoke 冒充双账号多项目 UAT 通过。
