---
owner: Codex 总控
status: active
purpose: Record Day-13 full-chain integration verification for project communication, project album, counterparty rating, credit bridge, SSH tunnel login, and Computer Use read-only UI validation.
layer: L0 SSOT
execution_date_local: 2026-04-25
scheduled_date_local: 2026-05-13
based_on:
  - docs/00_ssot/project_communication_album_rating_truth_freeze_addendum.md
  - docs/00_ssot/project_communication_album_rating_route_table_addendum.md
  - docs/04_frontend/project_communication_album_rating_day6_day7_frontend_execution_receipt.md
  - docs/00_ssot/project_counterparty_rating_credit_bridge_and_r2_verification_receipt_addendum.md
---

# 《项目沟通 / 相册 / 互评 Day-13 全链路联调回执》

## 1. 总控结论

- Day-13 不能判定为 `100% 完成`。
- 原 `45%` 可上调为 `78%`。
- 已通过：
  - 本地 Flutter 消费测试。
  - BFF app-facing 转发测试。
  - Server truth / upload / rating / credit shadow 本地测试。
  - `127.0.0.1:8080 -> Aliyun BFF` 隧道登录态真实读写。
  - owner 账号真实聊天发送。
  - owner 账号真实项目相册 `init -> OSS PUT -> confirm -> bind -> delete`。
  - Computer Use 只读点击：消息楼进入项目沟通页，并看到 Day-13 消息回显。
- 未通过：
  - 双账号真实 Flutter 对发验收。
  - counterpart 账号真实登录验收。
  - 已完成订单上的真实双方互评提交。
  - 真实 `ProjectCounterpartyRating -> credit shadow recompute / ledger` 数据库闭环。

## 2. 五条链路结果

| 链路 | 判定 | 证据 | 剩余缺口 |
|---|---|---|---|
| 聊天 | pass for owner-side tunnel write/read | 登录态读消息 `200`；发送 `202`；readback 命中 `messageId=51d11bf1-8a81-4261-ad2f-7028ac739cd9`、`clientMessageId=day13-20260424180344` | counterpart 账号未完成同轮 GUI 对发 |
| 项目相册 | pass for owner-side real upload/delete | list `200`；init `200`；OSS PUT `200`；confirm `200`；bind `202`；delete `202`；删除后 list `photoCount=0` | Flutter GUI 相册区可继续补 screenshot 证据 |
| 真实互评 | blocked by truth condition | counterpart conversation detail `200`，但项目状态为 `published`，ratingEntry 为空；probe order 返回 `404 PROJECT_COUNTERPARTY_RATING_UNAVAILABLE` | 需要 completed order 的 `orderId/projectId/rateeOrganizationId` |
| 信用新桥 | pass locally, blocked in cloud real trigger | Server credit shadow tests passed；new rating bridge code present | 没有真实互评提交，因此没有云上 ledger / recompute trigger 数据验收 |
| 登录态隧道 | partial pass | `health/bff/live` 返回 `200`；owner OTP test login `200`；业务路由可真实读写 | counterpart 账号 OTP `000000` 返回 `401 AUTH_LOGIN_INVALID`，无可用 token |

## 3. 本地代码验证

- Server:
  - `npm run build`
  - result: passed
  - `node --test test/project-communication-album.test.cjs test/project-counterparty-rating.test.cjs test/credit-scoring-shadow.test.cjs test/upload-transport.test.cjs`
  - result: `30 passed`
- BFF:
  - `node --test test/message-interaction-transport.test.cjs test/project-album-transport.test.cjs test/project-counterparty-rating-transport.test.cjs`
  - result: `15 passed`
- Flutter:
  - `flutter test test/counterpart_conversation_chat_test.dart`
  - result: `9 passed`

## 4. 隧道与真实登录态

- Tunnel:
  - local listener: `ssh` on `127.0.0.1:8080`
  - fixed route: `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`
- BFF health:
  - `GET /health/bff/live`
  - result: `200`
  - service: `exhibition-bff-isolated-s6`
- Owner-side login:
  - whitelist owner account, masked as `186****3700`
  - `POST /api/app/auth/otp/login`
  - result: `200`
  - token not printed and not persisted
- Counterpart-side login:
  - masked as `186****1020`
  - `POST /api/app/auth/otp/login` with test code
  - result: `401 AUTH_LOGIN_INVALID`
  - verdict: no usable counterpart token in this run

## 5. 真实写链路证据

### 5.1 Chat

- Route:
  - `POST /api/app/message/project-communication/messages`
- Payload anchors:
  - `threadId=afa6f969-66ea-403d-aafc-072fd5cd0f53`
  - `projectId=c788eaff-6243-4e97-8be3-c4e174ee7944`
  - `clientMessageId=day13-20260424180344`
- Result:
  - `202`
  - `messageId=51d11bf1-8a81-4261-ad2f-7028ac739cd9`
- Readback:
  - `GET /api/app/message/project-communication/messages`
  - result: `200`
  - returned the same `clientMessageId`

### 5.2 Album

- Route family:
  - `POST /api/app/file/upload/init`
  - signed direct `PUT`
  - `POST /api/app/file/upload/confirm`
  - `POST /api/app/project/:projectId/album/photos`
  - `DELETE /api/app/project/:projectId/album/photos/:photoId`
- Payload anchors:
  - `businessType=project`
  - `businessId=c788eaff-6243-4e97-8be3-c4e174ee7944`
  - `fileKind=project_album_photo`
  - `category=progress`
- Result:
  - init `200`
  - direct PUT `200`
  - confirm `200`
  - bind `202`
  - `photoId=38622ffc-2f0e-4a40-938a-dc62813fa21e`
  - delete `202`
  - deleted photo state: `removed`
- Cleanup verification:
  - `GET /api/app/project/:projectId/album/photos`
  - result: `200`
  - `photoCount=0`

## 6. Computer Use 只读联调

- App:
  - macOS `mobile`
- Path:
  - 帖子详情 -> 消息 -> 进入项目沟通
- Observed UI:
  - 消息楼显示一张 `项目沟通` 会话卡。
  - 统一项目沟通页显示项目分组 `西洽会`。
  - 页面内展示 `项目名称申请` 卡和 `竞标沟通` 卡。
  - 聊天区展示 Day-13 消息 `Day13全链路联调 20260424180344`。
- Boundary:
  - 本次 Computer Use 未在 GUI 中提交新消息或上传图片。
  - GUI 仅作为只读结果校验。

## 7. Stage Gate

- Passed gates:
  - Flutter 只通过 BFF 访问。
  - BFF 不持有业务真值。
  - Chat / album / rating route 均保留 `projectId` truth anchor。
  - Album 不把图片消息化，不把 `objectKey` 当业务真值。
  - Counterpart conversation 仍只是展示容器，不形成统一业务状态机。
  - Owner-side logged-in tunnel read/write passed.
  - Day-13 chat and album minimum closed loop passed.
- Failed / blocked gates:
  - No completed-order rating truth available.
  - No real counterpart token available.
  - No real credit shadow ledger trigger from cloud rating submit.
- Next stage allowed:
  - 允许进入 Day-14 修复和验收准备，但不得把 Day-13 标为 100%。
  - 允许补充 completed order fixture 后重跑真实互评与信用 bridge UAT。
- Veto:
  - 不允许把本地测试冒充真实云上互评闭环。
  - 不允许把 owner 单账号验收冒充双账号验收。
  - 不允许绕过 completed order 状态强行提交互评。

## 8. Remaining Inputs For 100%

需要以下任一组输入才能完成剩余 22%：

1. 可登录的 counterpart 账号 token，或可用 OTP / 密码。
2. 一笔已完成订单的 `orderId/projectId/rateeOrganizationId`，且当前登录组织有评价资格。
3. 云上 DB 只读核查口径，用于确认：
   - `project_counterparty_ratings` 新增方向唯一评价。
   - `organization_shadow_credit_recompute_triggers` 新增/处理触发。
   - `organization_shadow_credit_ledgers` 追加 ledger。
