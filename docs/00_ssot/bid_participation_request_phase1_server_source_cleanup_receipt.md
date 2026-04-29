# 申请参与竞标 Phase 1C Server Source Cleanup 执行回执

## 0. 总裁决

- Day1 C 方案规则冻结：Pass
- Day2 Server 源头停发旧卡片：Pass
- Day3 BFF/Flutter 同步收口：Pass
- Day4 回归与云端联调：Pass

当前裁决：Pass with Risk。

剩余风险：旧 `project_name_access` 历史数据和旧 thread route 仍按冻结单保留；如后续要完全清理历史入口，需要另开历史迁移/归档包。

## 1. 本轮改动边界

| 层 | 本轮处理 |
|---|---|
| SSOT | 新增 `bid_participation_request_phase1_server_source_cleanup_addendum.md` |
| Server | `CounterpartConversationProjectionService` 不再注册 `CounterpartConversationProjectNameAccessSource` 作为主卡片源 |
| BFF | counterpart conversation read model 对旧 `project_name_access_request` 卡片做展示侧过滤兜底 |
| Flutter | 项目沟通入口不再 fallback 到旧项目名称申请卡；参与竞标申请页隐藏线程 ID / 项目 ID / 申请 ID 主展示 |
| 历史兼容 | 旧 `project_name_access` entity / route / parser 保留 |

## 2. 本地验证

| 命令 | 结果 |
|---|---|
| `corepack pnpm --dir apps/server build` | PASS |
| `corepack pnpm --dir apps/bff build` | PASS |
| `flutter analyze lib/features/exhibition/presentation/pages/counterpart_conversation_page.dart lib/features/exhibition/presentation/pages/project_name_access_thread_page.dart` | PASS |
| `node --test apps/server/test/message-interaction-bid-carry.test.cjs apps/server/test/bid-participation-request-phase1.test.cjs` | PASS, 15 tests |
| `node --test apps/bff/test/message-interaction-transport.test.cjs apps/bff/test/bid-participation-request-transport.test.cjs` | PASS, 12 tests |
| `flutter test test/counterpart_conversation_chat_test.dart test/project_name_access_day45_test.dart` | PASS, 19 tests |
| `flutter test test/project_name_access_day45_test.dart` | PASS, 3 tests |

## 3. 云端部署

| 项 | 结果 |
|---|---|
| Previous Server release | `/srv/releases/server/20260429172003-bid-participation-phase1` |
| Previous BFF release | `/srv/releases/bff/20260429172003-bid-participation-phase1/apps/bff` |
| New Server release | `/srv/releases/server/20260429182729-bid-participation-source-cleanup` |
| New BFF release | `/srv/releases/bff/20260429182729-bid-participation-source-cleanup/apps/bff` |
| Server service | `active` |
| BFF service | `active` |

本轮无 migration。

## 4. 云端联调证据

| 检查项 | 结果 |
|---|---|
| `GET /health/bff/live` | `200 OK` |
| `GET /health/server/live` | `200 OK` |
| 账号 A message interactions | `project_name_access_request` count = 0 |
| 账号 B message interactions | `project_name_access_request` count = 0 |
| 账号 A counterpart conversation detail | `project_name_access_request` count = 0 |
| 账号 B counterpart conversation detail | `project_name_access_request` count = 0 |
| 旧 name-access thread route | `200 OK`，历史详情仍可读 |
| bid participation approved thread | `200 OK`，decision action = `bid_submit.open` |
| 支付链路 | 未调用竞标提交、预授权、支付初始化、回调或扣款接口 |

## 5. 验收结论

| 验收项 | 结论 |
|---|---|
| Server 停发旧卡片 | Pass |
| 历史 route 兜底 | Pass |
| BFF/Flutter 不再主显旧卡片 | Pass |
| 参与竞标申请页隐藏技术 ID | Pass |
| 新主链 pending / approved / rejected | Pass，继承 Phase 1 回执样本 |
| 无支付触发 | Pass |

## 6. 下一轮唯一动作

做一次 Flutter macOS 真实点击走查：项目沟通列表不再出现旧项目名称申请卡，参与竞标申请页不直出技术 ID，approved 后仍可进入竞标提交页。

## 7. 复核回执：2026-04-29 18:55 CST

本次按 Day1-Day4 清单重新核查，未发现需要追加代码修改的缺口。

| 检查项 | 结果 |
|---|---|
| 文书冻结单 | 已存在，路径：`docs/00_ssot/bid_participation_request_phase1_server_source_cleanup_addendum.md` |
| Server cardSources | `CounterpartConversationProjectionService` 当前只注册 bid thread、bid participation、clarification，不注册旧 name-access source |
| BFF 展示兜底 | counterpart conversation read model 过滤 `project_name_access_request` |
| Flutter 入口收口 | 项目沟通主入口优先 `bid_participation_request`，不再回退旧 `project_name_access_request` |
| 参与竞标申请页字段减法 | `bidParticipation=true` 时不主显线程 ID、项目 ID、申请 ID |
| Server build | PASS |
| Server tests | PASS，15 tests |
| BFF build | PASS |
| BFF tests | PASS，12 tests |
| Flutter analyze | PASS |
| Flutter widget tests | PASS，19 tests |
| BFF health | 200 |
| Server health | 200 |
| 账号 A message interactions | `project_name_access_request` count = 0，`bid_participation_request` count = 1 |
| 账号 B message interactions | `project_name_access_request` count = 0，`bid_participation_request` count = 1 |
| 账号 A counterpart conversation detail | `project_name_access_request` count = 0，`bid_participation_request` count = 4 |
| 账号 B counterpart conversation detail | `project_name_access_request` count = 0，`bid_participation_request` count = 4 |
| 旧 name-access thread route | 200，历史详情仍可读 |
| approved bid participation thread | 200，decision item action = `bid_submit.open` |
| 支付链路 | 未调用竞标提交、预授权、支付初始化、回调或扣款接口 |

复核裁决：Pass with Risk。剩余风险仍为历史旧 route 需要继续保留只读兜底；如要彻底隐藏旧详情页，需要另开“旧项目名称申请历史只读收口包”。
