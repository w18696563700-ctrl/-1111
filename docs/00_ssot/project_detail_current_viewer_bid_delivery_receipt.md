# 《项目详情 currentViewerBid 防重复提交交付回执》

## 0. 总裁决

- 本轮本地施工：Pass。
- 云上联调：Pass。
- 是否改支付 / 订单 / 合同：否。
- 是否改竞标提交状态机：否。
- 是否动云端数据：否。

## 1. 完成范围

| 层级 | 结果 |
|---|---|
| SSOT | 已冻结 currentViewerBid 真相来源和职责边界 |
| Contracts | `ProjectReadModel.currentViewerBid?: { bidId, state } \| null` 已进入 OpenAPI / generated types |
| Server | `project/detail` 按 `projectId + currentOrganizationId` 返回当前组织竞标摘要 |
| BFF | 只读投影 Server `currentViewerBid`，不自行查询竞标 |
| Flutter | 项目详情关闭重复竞标入口；竞标提交页直接进入时按钮锁定为 `已提交竞标` |

## 2. 本地验证

| 命令 | 结果 |
|---|---|
| `ruby packages/contracts/scripts/check_contracts.rb` | 通过 |
| `npm run build` in `apps/server` | 通过 |
| `node --test test/project-bid-candidates-read-model.test.cjs` | 通过 |
| `npm run build` in `apps/bff` | 通过 |
| `node --test test/project-detail-bid-candidates.test.cjs` | 通过 |
| `flutter analyze --no-pub ...` | 通过 |
| `flutter test --no-pub test/shell_app_test.dart --plain-name "project detail current viewer bid closes repeat bid entry"` | 通过 |
| `flutter test --no-pub test/shell_app_test.dart --plain-name "bid submit current viewer bid starts locked without POST"` | 通过 |
| `flutter test --no-pub test/shell_app_test.dart --plain-name "duplicate bid submission stays controlled and visible"` | 通过 |
| `flutter test --no-pub test/shell_app_test.dart --plain-name "bid submit success stays in minimum bid continuation only"` | 通过 |

## 3. 云上联调门禁

云上 BFF / Server 已发布本轮 `currentViewerBid` release：

| 项 | 值 |
|---|---|
| Server current | `/srv/releases/server/20260429043658-current-viewer-bid` |
| BFF current | `/srv/releases/bff/20260429043658-current-viewer-bid/apps/bff` |
| Server rollback | `/srv/releases/server/20260429013340-membership-fee-runtime-alignment` |
| BFF rollback | `/srv/releases/bff/20260429040649-my-bids-project-no-preview-bff/apps/bff` |

云端验证：

1. `systemctl is-active exhibition-server`：`active`。
2. `systemctl is-active exhibition-bff`：`active`。
3. `GET http://127.0.0.1:8080/health/server/live`：`200`。
4. `GET http://127.0.0.1:8080/health/bff/live`：`200`。
5. 测试账号 `18676681020` 登录后，`GET /api/app/project/detail?projectId=c057f243-5a88-446e-afae-6fe383eb5782` 返回 `currentViewerBid.bidId/state`。

Computer Use 联调结果：

1. 从 `项目展示` 列表进入已投项目。
2. 项目详情显示 `已提交竞标`。
3. 项目详情按钮显示 `沟通与投标`。
4. 页面不再显示 `立即参与竞标`。
5. 点击 `沟通与投标` 进入对应 bid thread。

## 4. 仍保留的边界

1. 不扩竞标工作台。
2. 不返回报价历史。
3. 不改 `POST /api/app/bid/submit` 成功体。
4. 不改变 owner-only `bidCandidates / bidSelection` 用途。
5. 不让 BFF / Flutter 拥有竞标归属真相。
