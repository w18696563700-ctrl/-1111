---
owner: Codex 总控
status: accepted
purpose: Record Day-5 runtime alignment, 8080 smoke, dual-account UAT, and visual evidence for counterpart conversation message-building readability.
layer: L0 SSOT
---

# 《消息楼项目沟通可读性 Day-5 Runtime / UAT 回执》

## 1. 回执结论

本轮 Day-1 到 Day-5 最小闭环通过。

- SSOT / contracts 已冻结。
- Server / BFF 已补齐只读投影和透传字段。
- Flutter 已按消息楼总框与项目页业务入口规则消费结构化字段。
- 云上 Server / BFF active runtime 已对齐到包含本轮补丁的新 release。
- 8080 tunnel health 与未登录 auth smoke 通过。
- 双账号 API UAT 覆盖项目列表、项目详情字段、未读聚合和进入项目后已读清除。
- Computer Use 可视化验收确认本地 Flutter 新 UI 已显示发布时间、搜索框、进入沟通、真实申请公司文案和进入审核按钮。

## 2. Runtime Alignment

| Item | Result |
| --- | --- |
| Release id | `20260430234500-counterpart-readability` |
| Previous Server target | `/srv/releases/server/20260430215412-alipay-app-pay` |
| Previous BFF target | `/srv/releases/bff/20260430215412-alipay-app-pay/apps/bff` |
| Active Server target | `/srv/releases/server/20260430234500-counterpart-readability` |
| Active BFF target | `/srv/releases/bff/20260430234500-counterpart-readability/apps/bff` |
| Server service | `exhibition-server`: `active` |
| BFF service | `exhibition-bff`: `active` |
| Nginx service | `active` |
| Server process cwd | `/srv/releases/server/20260430234500-counterpart-readability` |
| BFF process cwd | `/srv/releases/bff/20260430234500-counterpart-readability/apps/bff` |
| Rollback evidence | `/srv/release-receipts/20260430234500-counterpart-readability.rollback` |

## 3. 8080 Tunnel Smoke

Base: `http://127.0.0.1:8080`

| Route | Result |
| --- | --- |
| `GET /health/bff/live` | `200`, `status=ok`, `service=exhibition-bff` |
| `GET /health/bff/ready` | `200`, `status=ready`, `service=exhibition-bff` |
| `GET /health/server/live` | `200`, `status=ok`, `service=exhibition-server` |
| `GET /health/server/ready` | `200`, `status=ready`, `service=exhibition-server` |
| `GET /api/app/shell/context` without session | `401`, `AUTH_SESSION_INVALID` |

## 4. Dual-Account API UAT

账号只在回执中做脱敏标记，不记录密码。

| Scenario | Result |
| --- | --- |
| Account A login | Pass. The no-trailing-dot password variant was accepted; the trailing-dot variant was rejected. |
| Account A `shell/context` | Pass: `unreadSummary.messages = 0`. |
| Account A counterpart conversation list | Pass: returned one counterpart conversation entry. |
| Account A counterpart detail | Pass: returned project groups with `projectPublishedAt`, `projectUpdatedAt`, `projectUnreadCount`, `hasProjectUnread`, `requesterCompanyName`, and `requesterOrganizationId`. |
| Account B login | Pass. |
| Account B `shell/context` before read | Pass: `unreadSummary.messages = 1`. |
| Account B counterpart detail | Pass: one project group had `projectUnreadCount = 1`, `hasProjectUnread = true`, and real requester organization fields. |
| Account B project thread read cursor | Pass: `POST /api/app/message/project-communication/read-cursor` returned `202`; subsequent `shell/context` returned `unreadSummary.messages = 0`. |

## 5. Computer Use Visual UAT

| Surface | Observation |
| --- | --- |
| Message center entry | Pass: `项目沟通` still appears as a lane inside `互动中心`; it is not expanded into a second generic message center. |
| Counterpart total frame | Pass: top card shows `当前沟通对象`, avatar, display name, and certified company. |
| Project list | Pass: total frame only lists project entries; no chat composer, album card, or order card appears on the total-frame page. |
| Project list readability | Pass: search field `搜索项目名称`, relation tabs, project status chip, business-count chip, project title, and `发布时间：2026-04-30 20:30` are visible. |
| Project entry CTA | Pass: CTA is shortened to `进入沟通`, avoiding long text overflow. |
| Project communication page | Pass: page shows `竞标沟通`, concrete project title, real requester company sentence, `进入审核`, `订单状态`, `项目相册`, and project-scoped chat area. |
| Read state | Pass by API UAT; after entering/marking read, bottom message badge is expected to clear and no longer display a number. |

Visual evidence:

- `docs/00_ssot/evidence/20260430234500-counterpart-readability-project-list.png`
- `docs/00_ssot/evidence/20260430234500-counterpart-readability-project-page.png`

## 6. Local Test Evidence

| Layer | Command | Result |
| --- | --- | --- |
| Server | `npm --prefix apps/server run build` | Pass |
| Server | `node --test apps/server/test/message-interaction-bid-carry.test.cjs` | Pass |
| Server | `node --test apps/server/test/project-publish-eligibility.test.cjs` | Pass |
| BFF | `npm --prefix apps/bff run build` | Pass |
| BFF | `node --test apps/bff/test/message-interaction-transport.test.cjs apps/bff/test/shell-context-project-create-eligibility.test.cjs` | Pass |
| Flutter | `flutter test test/counterpart_conversation_chat_test.dart` | Pass |
| Flutter | `flutter test test/shell_app_test.dart --plain-name "messages building shows controlled unreadSummary badge from shell context"` | Pass |
| Flutter | `flutter analyze` on touched counterpart conversation, parser/model, shell-context, and shell-scaffold files | Pass |

Note: full-suite `shell_app_test.dart` still contains unrelated dirty-worktree failures outside this bounded message-building readability change.

## 7. Cleanup

本轮发布 overlay 使用的本地和远端临时 tar 包应在回执保存后清理：

- Local temp workspace: `/tmp/counterpart-readability.*`
- Remote temp overlays: `/tmp/server-overlay.tgz`, `/tmp/bff-overlay.tgz`

## 8. Remaining Risks

| Risk | Status |
| --- | --- |
| Account A password ambiguity | Retained: user-provided trailing-dot password failed; no-dot variant succeeded. Do not persist passwords in repo docs. |
| Future push / sound / vibration expectations | Explicitly out of scope; this round only delivers App-internal badge and project-card unread. |
| Full notification center | Explicitly out of scope; message building remains one shell lane with project communication and forum interaction lanes. |
| Release drift | Recheck `current` symlinks and process cwd before any later release decision. |

## 9. Go / No-Go

| Gate | Result |
| --- | --- |
| SSOT / contracts frozen | Pass |
| Server no migration / no new table | Pass |
| BFF no business-truth ownership | Pass |
| Flutter total-frame hierarchy | Pass |
| Cloud health | Pass |
| 8080 auth smoke | Pass |
| Dual-account UAT | Pass |
| Computer Use visual UAT | Pass |

Conclusion: Go for subsequent release judgment, with the retained risks above.
