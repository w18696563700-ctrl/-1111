# 申请参与竞标 Phase 1 执行与门禁回执

## 0. 总裁决

- Day1 L0 规则冻结：Pass
- Day2 L2 Contracts 冻结：Pass
- Day3 L3 Server Truth / Persistence 冻结：Pass
- Day4 Server 实现：Pass locally
- Day5 BFF 只转发与消息整形：Pass locally
- Day6 Flutter 改造：Pass locally
- Day7 本地回归与云端只读核查：Pass
- Day8 云端受控联调：Pass with Risk

云端 Server/BFF 已对齐本地 Phase 1 实现，`bid_participation_requests` migration 已执行；双账号受控联调已覆盖 pending / approved / rejected、项目名称解锁、报价依据资料门禁、消息楼承接和 approved CTA。

剩余风险：云端历史数据中仍存在旧 `project_name_access_request` 历史卡片；本期只冻结并下线新用户入口，不物理删除历史申请记录。

## 1. 本轮完成内容

| 层 | 完成内容 |
|---|---|
| SSOT | 新增一期规则冻结单，明确旧「申请查看项目名称」用户入口下线 |
| Contracts | 新增 app-facing / server-facing route、状态、错误码与消息卡片字段 |
| Server | 新增 `BidParticipationRequest` 真值、状态机、审计、准入门禁、迁移 |
| BFF | 新增 app-facing route，只转发 Server 并做中文错误整形 |
| Flutter | 公域按钮改为申请参与竞标；消息楼承接申请状态；approved CTA 可进竞标提交 |
| Tests | 补 Server / BFF / Flutter 关键路径测试 |

## 2. 本地验证

| 命令 | 结果 |
|---|---|
| `corepack pnpm --dir apps/server build` | PASS |
| `corepack pnpm --dir apps/bff build` | PASS |
| `flutter analyze ...` targeted files | PASS |
| `node --test apps/server/test/bid-participation-request-phase1.test.cjs apps/server/test/bid-submit.test.cjs apps/server/test/project-attachment-corridor.test.cjs` | PASS, 38 tests |
| `node --test apps/bff/test/bid-participation-request-transport.test.cjs` | PASS, 3 tests |
| `node --test apps/bff/test/message-interaction-transport.test.cjs apps/bff/test/project-bid-material.test.cjs apps/bff/test/bid-submit-error-mapping.test.cjs apps/bff/test/file-access-forwarding.test.cjs` | PASS, 22 tests |
| `flutter test test/project_name_access_day45_test.dart test/counterpart_conversation_chat_test.dart test/messages_instance_todo_test.dart` | PASS, 27 tests |

## 3. 云端只读核查

| 只读检查 | 结果 |
|---|---|
| `GET /health/bff/live` | `200 OK` |
| `GET /health/server/live` | `200 OK` |
| Server current pointer | `/srv/releases/server/20260429172003-bid-participation-phase1` |
| BFF current pointer | `/srv/releases/bff/20260429172003-bid-participation-phase1/apps/bff` |
| Migration | `20260429_bid_participation_request_phase1_truth` applied |
| `POST /api/app/project/bid-participation/request` with empty body/no auth | `400 BID_PARTICIPATION_UNAVAILABLE` |
| `GET /api/app/project/bid-participation/thread/detail?threadId=__readonly_probe__` | `401 AUTH_SESSION_INVALID` |
| `GET /api/app/my/projects/__readonly_probe__/bid-participation/pending` | `401 AUTH_SESSION_INVALID` |

只读结论：新增 route 已不再 404，Day7 route gate 通过。

## 4. Day8 受控联调

| 门禁 | 结论 |
|---|---|
| 新 route 不再 404 | Pass |
| Migration 已在云端执行 | Pass |
| 双账号登录 | Pass：`18696563700` / `18676681020` 均可登录 |
| 申请创建 | Pass：竞标方创建两条 pending request |
| 发布方待审列表 | Pass：发布方可看到申请方主体认证信息 |
| 审批通过 | Pass：approved 样本返回 `202` |
| 审批拒绝 | Pass：rejected 样本返回 `202` |
| 竞标方消息状态 | Pass：approved / rejected thread 均可读 |
| 发布方消息状态 | Pass：owner thread 可读，且 pending 时有 review action |
| 项目名称解锁 | Pass：approved 后 `nameAccess.status=visible`；rejected 保持隐藏 |
| 报价依据资料门禁 | Pass：approved 后 `GET /project/bid-materials` 返回 `200`；rejected 返回 `403 BID_PARTICIPATION_REQUIRED` |
| approved CTA | Pass：竞标方 thread decision action 为 `bid_submit.open`，参数含 `projectId` |
| 消息楼承接 | Pass：counterpart conversation 中 approved card 指向 `bid_submit.open`，rejected card 指回申请线程 |
| 支付触发 | Pass：本轮未调用竞标提交、预授权初始化、支付初始化、回调或扣款接口 |

## 5. 云端样本证据

| 场景 | 项目 / request | 结果 |
|---|---|---|
| approved path | `5beb03bf-9489-4892-a641-23ec60f395ff` / `97b23b4a-2ebc-4cfc-ac87-b328585779cc` | 名称可见、资料可读、CTA 到竞标提交 |
| rejected path | `e75af0c1-1ae1-428f-84fa-38d15e67ff2c` / `d9e5be46-0e36-40c3-ab76-e36fc8d00b37` | 名称继续隐藏、资料继续 403、CTA 留在申请线程 |

## 6. 本轮补丁验证

| 命令 / 检查 | 结果 |
|---|---|
| `corepack pnpm --dir apps/server build` | PASS |
| `corepack pnpm --dir apps/bff build` | PASS |
| `flutter analyze lib/features/exhibition/data/project_name_access_consumer_layer.dart lib/features/exhibition/presentation/pages/project_name_access_thread_page.dart test/project_name_access_day45_test.dart` | PASS |
| `node --test apps/server/test/bid-participation-request-phase1.test.cjs` | PASS, 5 tests |
| `node --test apps/bff/test/bid-participation-request-transport.test.cjs` | PASS, 3 tests |
| `flutter test test/project_name_access_day45_test.dart` | PASS, 3 tests |

## 7. 下一轮唯一动作

进入 Flutter 真实设备 / macOS App 走查：从项目详情发起申请、消息楼查看 approved / rejected、approved 后点击 CTA 进入竞标提交页。若走查通过，可进入本功能收口提交。
