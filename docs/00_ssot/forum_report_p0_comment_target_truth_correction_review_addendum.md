---
title: Forum Report P0 Comment Target Truth Correction Review
status: frozen
date: 2026-04-07
owner: Codex Control
scope: docs-only-review
---

# Forum Report P0 Comment Target Truth Correction Review

## Scope

This document reviews the receipt for:

`Forum Report P0 comment-target truth carrier correction`

This review is limited to the `Forum Report P0` comment-target truth gap. It does not open `Block P0`, `Admin Review P0`, AI runtime, OCR / QR detection, precheck, automatic takedown, penalty, appeal, release-prep, or launch approval.

## Local Source Review

Local source now contains the minimum comment target truth carrier:

- `apps/server/src/modules/forum/entities/forum-comment.entity.ts`
- `apps/server/src/modules/forum/forum-report.service.ts`
- `apps/server/src/core/migrations/migrations.ts`

The Server-side report service now contains a `targetType=comment` branch that loads a published comment and verifies the parent post remains `published`.

Line-count check:

- `apps/server/src/modules/forum/forum-report.service.ts`: `277`
- `apps/server/src/modules/forum/entities/forum-comment.entity.ts`: `37`
- `apps/server/src/modules/forum/entities/forum-report-ticket.entity.ts`: `46`
- `apps/bff/src/routes/forum/forum.service.ts`: `407`
- `apps/bff/src/routes/forum/app-forum.controller.ts`: `61`

No hard AGENTS length-gate veto is triggered in the reviewed files. `apps/bff/src/routes/forum/forum.service.ts` remains above the warning line but below the `450` hard gate.

## Local Build Rerun

Control reran:

- `cd apps/server && npm run build`: PASS
- `cd apps/bff && npm run build`: PASS

## Active Ingress Probe

Control probed the current active app-facing ingress:

`127.0.0.1:8080 -> cloud nginx :80 -> active BFF`

Request:

`POST /api/app/forum/report/submit`

Payload:

```json
{
  "targetType": "comment",
  "targetId": "forum-comment-report-smoke-20260407",
  "reasonCode": "spam_or_flood",
  "reasonDetail": "route probe"
}
```

Observed response:

```text
HTTP/1.1 404 Not Found
{"message":"Cannot POST /bff/forum/report/submit","error":"Not Found","statusCode":404}
```

This is a raw route-missing failure at the active ingress path. It is not a controlled `AUTH_SESSION_INVALID`, not a controlled `FORUM_REPORT_INVALID`, and not a successful `submitted` report response.

## Findings

1. Local source correction appears present.

The local Server source now has `ForumCommentEntity`, migration carrier, and a comment-report validation branch. This closes the prior local-source gap in principle.

2. Local Server and BFF builds pass.

The correction compiles locally for both Server and BFF.

3. Active cloud ingress is not aligned with the corrected BFF route.

The active app-facing route still returns raw `Cannot POST /bff/forum/report/submit`. That means the currently active ingress path is not serving the corrected BFF artifact for `Forum Report P0`.

4. Final package completion is still blocked.

Because active ingress is route-missing, the claimed live proof cannot be accepted as final control evidence for `Forum Report P0`.

## Decision

`Forum Report P0 comment-target truth carrier correction`: `PENDING / NO-GO`.

Accepted at local source/build level:

- minimum comment target truth carrier exists in source
- Server comment report branch exists in source
- local Server build passes
- local BFF build passes

Rejected at active runtime level:

- active ingress route still misses `/api/app/forum/report/submit`
- no final active-ingress comment report proof is accepted

## Next Unique Action

Execute:

`Forum Report P0 cloud BFF/Server artifact alignment correction`

The next correction must:

- align active BFF artifact so `/api/app/forum/report/submit` no longer raw-404s
- align active Server artifact and DB carrier for `forum_comment` and `forum_report_ticket`
- run the active ingress chain through `127.0.0.1:8080 -> cloud :80 -> BFF :3000 -> Server :3001`
- prove legal comment report creates a `forum_report_ticket`
- prove invalid comment target returns controlled app-facing failure
- prove post report remains non-regressed
- prove `content_safety_snapshots` and `content_safety_audit_logs` receive report evidence
- prove AI runtime remains absent

Until that correction passes, do not open:

- `Block P0`
- `Admin Review P0`
- AI runtime
- OCR / QR detection
- forum precheck
- automatic takedown
- penalty / appeal
- release-prep / launch approval
