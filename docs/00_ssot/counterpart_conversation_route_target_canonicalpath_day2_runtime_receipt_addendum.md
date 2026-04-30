---
owner: Codex 总控
status: effective
purpose: Record Day1-Day2 implementation, cloud runtime alignment, dual-account UAT, and remaining risks for counterpart conversation routeTarget canonicalPath repair.
layer: L0 SSOT
---

# Counterpart Conversation RouteTarget CanonicalPath Day2 Runtime Receipt

## 结论

Day1 / Day2 当前闭环通过。BFF 已最小修复 `bid_service_fee_authorization.open` 的 `canonicalPath`，云上 BFF active runtime 已切到包含该 patch 的 release，双账号通过 8080 API smoke 和 Computer Use 可视化验收，项目沟通页不再出现 `detail routeTarget canonicalPath mismatch`。

本回执不声明支付授权全链路、订单流全链路或新项目全流程生产放行。

## Day1 产出

| Item | Result |
| --- | --- |
| 冻结修复真相 | `canonicalPath` 必须是 `/api/app/project/{projectId}/bid-service-fee-authorizations`；真实 projectId 进入 `params.projectId`。 |
| BFF patch | `counterpart-conversation.read-model.ts` 和 `bid-participation-request.read-model.ts` 已输出模板路径。 |
| BFF targeted build | `npm --prefix apps/bff run build` 通过。 |
| BFF targeted tests | `node --test apps/bff/test/message-interaction-transport.test.cjs`：9 pass；`node --test apps/bff/test/bid-participation-request-transport.test.cjs`：4 pass。 |
| Flutter targeted regression | `flutter test test/counterpart_conversation_chat_test.dart`：16 pass。 |

## Day2 云上 Runtime

| Check | Result |
| --- | --- |
| Final Server current | `/srv/releases/server/20260430205647-project-list-published-at` |
| Final BFF current | `/srv/releases/bff/20260430205647-project-list-published-at/apps/bff` |
| Server service | `exhibition-server` active, `MainPID=1432510`, `WorkingDirectory=/srv/apps/server/current` |
| BFF service | `exhibition-bff` active, `MainPID=1432521`, `WorkingDirectory=/srv/apps/bff/current` |
| Nginx | active |
| Patch presence in final BFF current | `src` and `dist` both contain `/api/app/project/{projectId}/bid-service-fee-authorizations` for `counterpart-conversation` and `bid-participation-request` read-models. |
| PM2 | historical `bff-s6-r4` and `server-s6-r6` entries are stopped and do not own ports |
| Superseded BFF patch release rollback file | `/srv/shared/20260430205400-route-target-canonicalpath-bff.rollback` |
| Final release rollback evidence | No `/srv/shared/20260430205647-project-list-published-at.rollback` file was found during final recheck; treat as retained runtime governance risk before broader release sign-off. |

## 8080 Smoke

| Route | Result |
| --- | --- |
| `GET /health/bff/live` | `200`, `status=ok`, `service=exhibition-bff` |
| `GET /health/bff/ready` | `200`, `status=ready`, `service=exhibition-bff` |
| `GET /health/server/live` | `200`, `status=ok`, `service=exhibition-server` |
| `GET /health/server/ready` | `200`, `status=ready`, `service=exhibition-server` |
| `GET /api/app/message/interactions?lane=project_communication` without auth | `401 AUTH_SESSION_INVALID`, not 404 |
| `GET /api/app/message/counterpart-conversation/detail?...` without auth | `401 AUTH_SESSION_INVALID`, not route drift |

## 双账号 API UAT

| Account | Result |
| --- | --- |
| KunTe account | `GET /api/app/message/interactions?lane=project_communication` returned `200`, `LIST_COUNT=1`; detail returned `200`; `MISMATCH_COUNT=0`. |
| ZhanHong account | `GET /api/app/message/interactions?lane=project_communication` returned `200`, `LIST_COUNT=1`; detail returned `200`; `FEE_CARD_COUNT=1`; `FEE_CARD OK ... /api/app/project/{projectId}/bid-service-fee-authorizations`; `MISMATCH_COUNT=0`. |

## Computer Use UAT

| Account | Observation | Evidence |
| --- | --- | --- |
| ZhanHong account | 从项目沟通总框进入项目入口后，页面显示 `竞标沟通`、`参与竞标申请 / 审核`、`订单状态`、`项目相册`、`聊天`，未出现 `detail routeTarget canonicalPath mismatch`。 | `docs/00_ssot/evidence/counterpart_route_target_canonicalpath_zhanhong_20260430.png` |
| KunTe account | 从互动中心进入项目沟通总框，再进入具体项目沟通页，页面显示 `竞标沟通`、业务按钮和聊天输入区，未出现 mismatch 受控卡。 | `docs/00_ssot/evidence/counterpart_route_target_canonicalpath_kunte_20260430.png` |

## 清理

- 8080 smoke 复用既有 `ssh -f -N ... -L 8080:127.0.0.1:80 root@47.108.180.198` 监听。
- 本轮曾尝试启动一个重复的前台 tunnel，因 8080 已被占用未承载流量；验收后已终止该前台 `ssh` 进程。
- Computer Use 验收后已退出 `mobile.app` 进程。
- 未保留本地 bootstrap token 文件。
- `apps/mobile/pubspec.lock` 无本轮差异。

## 剩余风险

- PM2 仍保留 stopped 历史条目；当前不占端口，正式运行已经回到 systemd，但后续可以单独冻结清理策略。
- Final active runtime later moved to `20260430205647-project-list-published-at`; it contains this patch, but its rollback evidence file was not found in `/srv/shared` during final recheck.
- 本次双账号 UAT 使用现有真实项目样本，不等于“全新项目从创建到竞标沟通”的生产放行。
- `bid_service_fee_authorization.open` 页面本身未做支付授权全链路点击验收；本轮只验证项目沟通入口不再被 canonicalPath mismatch 阻断。
- 当前回执允许后续发布判断继续推进，但不替代支付、订单、竞标提交主链路的独立验收。

## 判断

- 更稳：保持 Flutter 严格校验，BFF 对外投影统一模板 canonicalPath。
- 更省成本：本轮代码只改 BFF projection，不做 DB / migration / contract 扩张；最终 active runtime 已携带该 patch。
- 更适合当前阶段：这是已定位的云上投影漂移，最小 BFF release + 双账号 UAT 可闭环。
- 风险更大：继续靠页面错误态兜底，或在 Flutter 注册表加入实例路径，会让 routeTarget 漂移复发且更难发现。
