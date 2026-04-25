---
owner: Codex 总控
status: active
purpose: Record Day-15 acceptance, Computer Use click verification, regression evidence, release note, and cutover/rollback wording for project communication, album, and counterparty rating.
layer: L0 SSOT
execution_date_local: 2026-04-25
scheduled_date_local: 2026-05-15
based_on:
  - docs/00_ssot/project_communication_album_rating_truth_freeze_addendum.md
  - docs/00_ssot/project_communication_album_rating_day13_full_chain_integration_receipt_addendum.md
  - docs/00_ssot/project_communication_album_rating_day14_day15_acceptance_release_addendum.md
---

# 《项目沟通 / 相册 / 互评 Day-15 验收报告、Release Note 与 Cutover 口径》

## 1. 总控结论

- Day-15 当前判定：
  - `conditional acceptance`
  - completion: `94%`
- 已完成：
  - Flutter / BFF / Server 目标回归。
  - `127.0.0.1:8080` 隧道 health 验证。
  - Computer Use 实际点击验收。
  - Day-15 验收报告、release note、cutover / rollback 口径补齐。
- 不判定为 `100%` 的原因：
  - 当前可验样本项目为 `published`，不是 completed order。
  - 真实 completed-order counterparty rating submit 未执行。
  - 云上 `credit shadow recompute / ledger` DB 级验收未执行。

## 2. 测试补齐

本轮不新增重复测试文件，采用现有目标测试矩阵作为 Day-15 验收基线。

### 2.1 Flutter

- Command:
  - `flutter test test/counterpart_conversation_chat_test.dart`
- Result:
  - `9 passed`
- Coverage:
  - project communication realtime auth header / fallback polling
  - counterpart conversation header and full-flow business-card actions
  - ended-project avatar sheet counterparty rating submit once
  - project album upload through FileAsset flow and delete
  - chat composer optimistic send / refresh
  - failed draft retry
  - websocket reconnect lifecycle

### 2.2 Flutter Analyze

- Command:
  - `flutter analyze lib/features/exhibition/presentation/pages/counterpart_conversation_page.dart lib/features/exhibition/presentation/pages/counterpart_conversation_widgets.dart lib/features/exhibition/presentation/pages/counterpart_conversation_chat_widgets.dart lib/features/exhibition/presentation/pages/counterpart_conversation_subject_sheet.dart lib/features/exhibition/presentation/pages/project_album_section.dart lib/features/messages/data/counterpart_conversation_consumer_layer.dart lib/features/messages/data/counterpart_conversation_models.dart lib/features/messages/data/counterpart_conversation_parser.dart lib/features/messages/data/messages_interaction_models.dart test/counterpart_conversation_chat_test.dart`
- Result:
  - `No issues found`

### 2.3 BFF

- Command:
  - `node --test test/message-interaction-transport.test.cjs test/project-album-transport.test.cjs test/project-counterparty-rating-transport.test.cjs`
- Result:
  - `15 passed`
- Coverage:
  - message interactions and counterpart conversation route materialization
  - project communication HTTP routes
  - realtime gateway validation / event forwarding
  - project album list / bind / delete forwarding
  - project-counterparty-rating entry / submit forwarding
  - missing truth-anchor rejection
  - duplicate upstream state mapping

### 2.4 Server

- Commands:
  - `npm run build`
  - `node --test test/project-communication-album.test.cjs test/project-counterparty-rating.test.cjs test/credit-scoring-shadow.test.cjs test/upload-transport.test.cjs`
- Results:
  - build passed
  - `30 passed`
- Coverage:
  - chat requires explicit `projectId`
  - chat realtime event and clientMessageId dedupe
  - album 50-active-photo limit
  - album image-only `project_album_photo`
  - counterparty rating entry anchors `orderId/projectId/rateeOrganizationId`
  - counterparty rating direction truth and duplicate rejection
  - counterparty rating bridge into credit shadow aggregation
  - upload init / confirm project binding truth

## 3. Runtime Probe

- Tunnel:
  - `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`
- Probe:
  - `GET http://127.0.0.1:8080/health/bff/live`
- Result:
  - `200`
  - service: `exhibition-bff-isolated-s6`
  - port: `3000`

## 4. Computer Use 实际点击验收

### 4.1 Click Path

1. `展览` 首页。
2. 点击 `进入项目详情`。
3. 项目详情展示核心信息、地点与安排、继续处理、项目沟通区。
4. 点击底栏 `消息`。
5. 消息楼展示一张 `项目沟通` 对方主体会话卡。
6. 点击 `进入项目沟通`。
7. 统一项目沟通页展示：
   - 对方主体头像与昵称。
   - 项目分组 `西洽会`。
   - `项目名称申请` 业务卡。
   - `竞标沟通` 业务卡。
   - `项目相册` section。
   - 输入框和发送按钮。
8. 点击 `最终呈现 0` 相册分类。
9. 相册切换到 `最终呈现`，展示 `当前数量：0 / 50` 和 `上传图片 / 刷新相册`。
10. 点击 `查看申请`。
11. 进入 `名称查看申请` 受控 review thread。
12. 点击 `处理申请`。
13. 弹出审批 sheet，展示：
    - `同意查看项目名称`
    - `拒绝本次申请`
14. 关闭审批 sheet，未点击同意或拒绝。
15. 返回项目沟通页。
16. 点击 `进入竞标沟通`。
17. 进入 `沟通与投标` 页面，展示项目 ID、投标 ID、线程状态、参与方、发送消息区。
18. 点击参与方名片。
19. 弹出 `合作方名片` sheet，展示主体摘要、合作摘要、正式认证摘要。
20. 关闭名片 sheet。

### 4.2 Click Acceptance Result

- Passed:
  - home project card layout remains correct.
  - project detail route works.
  - message entry card works.
  - unified counterpart conversation opens.
  - project grouping remains visible and not merged.
  - business cards keep consistent width.
  - name-access review thread opens.
  - approval sheet opens without executing approval.
  - album section renders category tabs and 50-photo counter.
  - bid communication route opens.
  - participant card opens.
- Not executed in the initial read-only pass:
  - chat final send button click.
  - album `上传图片` file picker and upload.
  - `同意查看项目名称` / `拒绝本次申请`; `同意查看项目名称` was later executed only in the scoped dual-account UAT supplement below after action-time confirmation.
  - counterparty rating submit.
- Reason:
  - these are write actions or representational communication to another party and require action-time confirmation.
  - Day-13 already proved owner-side chat write and album upload/delete through the tunnel; Day-15 Computer Use stayed read-only except opening sheets/routes.

### 4.3 Dual-Account Name-Access Approval UAT Supplement

- Execution date:
  - `2026-04-25`
- Participants:
  - applicant window: `江北嘴嘴帅`
  - publisher window: `重庆海川展览工厂`
- Truth anchors:
  - threadId / requestId: `6c5a0f59-8ef1-453e-b37d-82a2885f651c`
  - projectId: `c788eaff-6243-4e97-8be3-c4e174ee7944`
- Publisher-side evidence:
  - message center opened a single counterpart conversation card for `江北嘴嘴帅`.
  - unified conversation kept project group `西洽会`.
  - `项目名称申请` and `竞标沟通` remained separate business cards under the project group.
  - `查看申请` opened the controlled name-access review thread.
  - after action-time confirmation, the review thread read back `当前状态：审批已通过`.
  - system result notification timestamp: `2026-04-24T19:28:26.601Z`.
- Applicant-side evidence:
  - project list refreshed from `项目名称需申请查看` to the real project name `西洽会`.
  - applicant review thread showed `当前状态：审批已通过` and `项目名称：西洽会`.
- Result:
  - name-access request / approval / applicant visibility refresh passed through real dual-account UI.
  - the unified message entry remained a container only; the truth state stayed anchored to the project-name-access review thread and `projectId`.

## 5. Release Note

### 5.1 Included

- Message center now exposes a unified `项目沟通` counterpart conversation entry.
- Counterpart conversation page groups business cards by project and preserves project boundaries.
- Business cards include:
  - project name access request
  - bid communication
  - future clarification / notice extension slots
- Project album is available inside project communication:
  - categories: `contract/progress/final/defect`
  - max active photos: `50`
  - upload based on FileAsset truth
  - delete through app-facing BFF route
- Avatar / subject sheet can expose controlled counterparty rating after:
  - project ended
  - ratingEntry exists
  - `canRate == true`
- Counterparty rating uses new truth route:
  - `POST /api/app/project-counterparty-rating/submit`
  - not old `/api/app/rating/submit`
- Credit bridge consumes new `project_counterparty_ratings` locally through shadow aggregation.

### 5.2 Not Included

- Generic DM.
- Group chat.
- Free chat inside name-access review thread.
- Production push notification.
- Rating list / moderation / appeal workspace.
- Payment / settlement / award workflow.
- Forced project completion fixture.

## 6. Cutover 口径

### 6.1 Recommended Cutover

- Recommendation:
  - `soft cutover / conditional acceptance`
- Current stage:
  - suitable for internal UAT and controlled staging validation.
  - not suitable for declaring full production acceptance.
- Why this is more stable:
  - project communication, album, and rating are already anchored to `projectId`.
  - BFF remains only a shaping and forwarding layer.
  - Server remains business truth owner.
  - existing legacy carriers are retained as fallback.

### 6.2 What Can Be Turned On

- Allow:
  - message center counterpart conversation entry.
  - project communication read path.
  - album list and controlled upload/delete for real logged-in users.
  - name-access review thread read and approval sheet access.
  - bid communication detail route.
  - participant card.

### 6.3 What Must Stay Blocked

- Block:
  - full production acceptance claim.
  - completed-order counterparty rating production claim.
  - credit score impact claim before DB ledger verification.
  - removing old `bid_thread` / `project_name_access_thread` fallback carriers.
  - generic DM or group chat expansion.

### 6.4 Rollback

- Frontend rollback:
  - hide or disable the counterpart conversation entry in message center.
  - retain old project-name-access and bid-thread routes.
- BFF rollback:
  - revert app-facing route exposure for album / counterpart conversation aggregation if needed.
  - keep auth, file upload, and legacy message routes untouched.
- Server rollback:
  - do not drop tables.
  - stop consuming new `project_counterparty_ratings` in credit shadow only if the bridge causes runtime issues.
  - preserve audit rows and FileAsset truth.
- Verification after rollback:
  - `/health/bff/live` returns `200`.
  - old message interaction center still opens.
  - old bid thread detail still opens.
  - old project name access thread still opens.

## 7. Final Gate

- Passed:
  - code regression.
  - route regression.
  - cloud tunnel health.
  - Computer Use actual click navigation.
  - release note.
  - cutover and rollback wording.
- Conditional:
  - name-access approval write was executed only after action-time confirmation and passed dual-account readback.
- Still blocked for 100%:
  - completed-order rating submit.
  - cloud credit ledger verification.

Formal verdict:

- Day-15: `conditional pass`
- Completion: `94%`
- Next allowed step:
  - proceed to a narrow completed-order rating and credit-ledger UAT round when a completed-order fixture is available.
