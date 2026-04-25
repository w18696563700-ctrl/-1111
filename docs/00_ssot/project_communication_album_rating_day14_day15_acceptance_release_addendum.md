---
owner: Codex 总控
status: active
purpose: Record 2026-05-14 repair and 2026-05-15 acceptance package for project communication, album, and counterparty rating.
layer: L0 SSOT
schedule_dates_local:
  - 2026-05-14
  - 2026-05-15
execution_date_local: 2026-04-24
based_on:
  - docs/00_ssot/project_communication_album_rating_truth_freeze_addendum.md
  - docs/04_frontend/project_communication_album_rating_frontend_consumption_freeze_addendum.md
  - docs/00_ssot/project_communication_album_rating_bff_server_day4_execution_receipt_addendum.md
---

# 《项目沟通 / 相册 / 互评 Day-14/Day-15 修复验收包》

## 1. Completion Judgment

- 当前判断：
  - `conditional pass for code-level regression`
  - `no production main-entry cutover`
- 原因：
  - 相关代码、BFF/Server route、Flutter targeted tests 已补齐。
  - CLI 无法代替真实 UAT 账号完成完整视觉点击验收。
  - 云上未执行本轮新补丁发版，因此不得宣称 production cutover。

## 2. Day-14 Repair Items

| Item | Result | Evidence |
|---|---|---|
| UI 宽度 | passed | 统一会话业务卡使用 full-width `SizedBox(width: double.infinity)`；聊天输入区贴合页面宽度 |
| 排序 | passed | Flutter 维持 focus project 优先、项目按 latestActivityAt 倒序、业务卡按类型优先级后按更新时间倒序 |
| 权限 | passed | 项目名权限 sheet 仍由详情标题触发；头像主体卡需存在项目组和 counterpart organizationId |
| 50 张限制 | passed | Server `ProjectAlbumPhotoService` 在事务内锁 project 后校验 active photo count `>= 50` |
| 评价重复提交 | passed | Server 非 draft 返回 `RATING_INVALID_STATE`；Flutter 头像 sheet 用 `_submitting/_submittedLocally` 防重复点击 |
| 头像入口条件 | passed | 头像仅打开主体卡；真实评价按钮仅在 `projectEnded + ratingEntry.canRate` 时开放 |

## 3. Implementation Patch

- Server counterpart conversation project group now includes:
  - `ratingEntry.orderId`
  - `ratingEntry.projectId`
  - `ratingEntry.rateeOrganizationId`
  - `ratingEntry.canRate`
  - `ratingEntry.reason`
  - `ratingEntry.ratingState`
- BFF read model now validates and forwards nullable `ratingEntry`.
- Flutter subject sheet now:
  - reads `ratingEntry`
  - blocks when project is not ended
  - blocks when no rating anchor exists
  - blocks repeated local submit
  - submits existing minimal rating command with `orderId`
  - keeps credit score computation out of Flutter

## 4. Regression

- `corepack pnpm --dir apps/server build`
  - passed
- `corepack pnpm --dir apps/bff build`
  - passed
- `node --test apps/bff/test/message-interaction-transport.test.cjs apps/bff/test/project-album-transport.test.cjs apps/bff/test/rating-entry-submit.test.cjs`
  - 13 passed
- `node --test apps/server/test/project-communication-album.test.cjs apps/server/test/rating-entry-submit.test.cjs apps/server/test/message-interaction-bid-carry.test.cjs`
  - 17 passed
- `flutter test test/counterpart_conversation_chat_test.dart test/rating_entry_test.dart`
  - 5 passed

## 5. Computer Use Click Verification

- Environment:
  - running macOS `mobile` app
  - app-facing backend reached through existing logged-in runtime
- Verified:
  - bottom navigation `消息` opens interaction center
  - message list shows one `项目沟通` counterpart card
  - clicking `进入项目沟通` opens unified project communication page
  - page header shows counterpart avatar and nickname under `项目沟通`
  - project section keeps `西洽会` as the project boundary
  - `查看申请` and `进入竞标沟通` cards/buttons align to the same visual width
  - chat timeline is visible
  - text input can receive focus
- Not executed:
  - final send button click
  - reason: sending chat text is representational communication to another party and requires action-time user confirmation
- Not verifiable in current running app:
  - avatar rating submit with new `ratingEntry`
  - reason: current running mobile/cloud build has not been restarted/deployed with this patch

## 6. Cloud Patch Release

- Release id:
  - `20260424182749-project-communication-day14-day15-r1`
- Server current:
  - `/srv/releases/server/20260424182749-project-communication-day14-day15-r1`
- BFF current:
  - `/srv/releases/bff/20260424182749-project-communication-day14-day15-r1`
- Previous rollback points:
  - Server: `/srv/releases/server/20260424155716-project-communication-chat-r1`
  - BFF: `/srv/releases/bff/20260424173000-project-communication-r2`
- Health:
  - `GET http://127.0.0.1:3001/health/live` returned `200`
  - `GET http://127.0.0.1:3000/health/live` returned `200`
  - `GET http://127.0.0.1:8080/health/bff/live` returned `200`
- Tunnel route probes:
  - `GET /api/app/message/counterpart-conversation/detail?conversationId=org-probe&projectId=project-probe` returned `401`, not `404`
  - `GET /api/app/message/project-communication/messages?threadId=thread-probe&projectId=project-probe` returned `401`, not `404`
  - `POST /api/app/message/project-communication/messages` returned `401`, not `404`
  - `GET /api/app/bid/thread/detail?projectId=project-probe&bidId=bid-probe` returned `401`, not `404`

## 7. Release Note

- Added rating-entry projection to counterpart conversation project groups.
- Avatar subject sheet can now expose a controlled rating submit entry after project completion and rating anchor availability.
- Album 50-photo server enforcement remains the hard truth.
- Existing bid-thread and project-name-access carriers remain fallback/detail carriers.
- No generic DM, WebSocket, payment, settlement, award, or broad rating workspace is included.

## 8. Cutover Ruling

- Allowed:
  - keep current feature behind existing project communication routes
  - continue Flutter local / staging UAT
  - deploy Server/BFF patch only after staging smoke
- Blocked:
  - production hard switch of main entry
  - removal of old `bid_thread` or `project_name_access_thread` carrier routes
  - claiming UAT pass without real-account click verification

## 9. Remaining Manual UAT

- Use a real logged-in owner account and counterpart account.
- Confirm one counterpart conversation opens.
- Confirm project groups remain separated.
- Confirm text chat can send and refresh.
- Confirm album rejects the 51st active image.
- Confirm completed project with draft rating shows avatar rating submit.
- Confirm second rating submit is rejected by Server or no longer callable from Flutter.

## 10. Day-14 Re-Verification Correction

- Re-verification date:
  - `2026-04-25`
- Prior user-facing assessment:
  - `2026-05-14 修复 65%`
  - noted that album frontend and new counterparty-rating truth were still missing.
- Corrected assessment:
  - Day-14 can be upgraded from `65%` to `88%`.
  - `项目相册 Flutter` is no longer missing at code/test level.
  - `互评新真值` is no longer missing at code/test level.
  - The remaining block is real completed-order dual-account UAT and cloud credit ledger verification.

### 10.1 Project Album Frontend Verdict

- Verdict:
  - `passed for Flutter engineering and owner-side tunnel write/delete`
- Evidence:
  - `apps/mobile/lib/features/exhibition/presentation/pages/project_album_section.dart`
  - `ProjectAlbumSection` loads album list by `projectId`.
  - Four fixed categories are present:
    - `contract`
    - `progress`
    - `final`
    - `defect`
  - Flutter pre-checks `50` active photos before upload.
  - Upload flow is:
    - `POST /api/app/file/upload/init`
    - direct upload
    - `POST /api/app/file/upload/confirm`
    - `POST /api/app/project/:projectId/album/photos`
  - Delete flow is:
    - `DELETE /api/app/project/:projectId/album/photos/:photoId`
  - Preview remains FileAsset-truth based and does not use `objectKey` as business truth.

### 10.2 New Counterparty Rating Truth Verdict

- Verdict:
  - `passed for Flutter/BFF/Server engineering`
- Evidence:
  - Flutter submit path:
    - `POST /api/app/project-counterparty-rating/submit`
  - Flutter submit payload carries:
    - `orderId`
    - `projectId`
    - `rateeOrganizationId`
    - `scoreLabel`
    - `commentText`
  - Flutter no longer uses old `/api/app/rating/submit` from the avatar subject-card path.
  - Old `/api/app/rating/*` remains only the legacy order-rating carrier.
  - Submit button is enabled only when:
    - project is ended
    - `ratingEntry.canRate == true`
    - local submit is not already in-flight
    - local submit is not already accepted
  - Server rejects duplicate direction truth.

### 10.3 Re-Verification Commands

- Flutter:
  - `flutter test test/counterpart_conversation_chat_test.dart`
  - result: `9 passed`
  - `flutter analyze lib/features/exhibition/presentation/pages/counterpart_conversation_page.dart lib/features/exhibition/presentation/pages/counterpart_conversation_widgets.dart lib/features/exhibition/presentation/pages/counterpart_conversation_chat_widgets.dart lib/features/exhibition/presentation/pages/counterpart_conversation_subject_sheet.dart lib/features/exhibition/presentation/pages/project_album_section.dart lib/features/messages/data/counterpart_conversation_consumer_layer.dart lib/features/messages/data/counterpart_conversation_models.dart lib/features/messages/data/counterpart_conversation_parser.dart lib/features/messages/data/messages_interaction_models.dart test/counterpart_conversation_chat_test.dart`
  - result: `No issues found`
- BFF:
  - `node --test test/message-interaction-transport.test.cjs test/project-album-transport.test.cjs test/project-counterparty-rating-transport.test.cjs`
  - result: `15 passed`
- Server:
  - `npm run build`
  - result: passed
  - `node --test test/project-communication-album.test.cjs test/project-counterparty-rating.test.cjs test/credit-scoring-shadow.test.cjs test/upload-transport.test.cjs`
  - result: `30 passed`

### 10.4 Current Gate

- Passed:
  - UI/card width and project grouping remain stable.
  - Sorting remains deterministic.
  - Album frontend exists and consumes BFF-only routes.
  - Album 50-photo limit has both Flutter pre-check and Server hard truth.
  - New counterparty rating submit truth exists through `project-counterparty-rating`.
  - Duplicate rating submit is blocked by Flutter local guard and Server truth.
  - Avatar subject sheet blocks missing project/rating anchors.
- Still blocked:
  - counterpart account real login was not available in the latest tunnel run.
  - current verified sample project is still `published`, not completed.
  - real completed-order rating submit has not run.
  - cloud credit shadow trigger / ledger write has not been DB-verified.
- Formal ruling:
  - Day-14 may proceed to Day-15 acceptance preparation.
  - Day-14 must not be marked `100%` until completed-order rating and credit ledger cloud UAT pass.
