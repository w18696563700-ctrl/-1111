---
owner: Codex 总控
status: frozen
purpose: Freeze the materialization contract for the existing forum interaction inbox route without changing the OpenAPI schema family.
layer: L2 Contracts
---

# Forum Interaction Inbox Materialization Contract Addendum

## Contract Decision
- The canonical app-facing route remains:
  - `GET /api/app/forum/interaction/inbox`
- The canonical server-facing route for this repair is:
  - `GET /server/forum/interaction/inbox`
- Query parameters:
  - `tab`: required, enum `replies | likes | follows`
  - `cursor`: optional date-time cursor string
  - `pageSize`: optional positive integer, maximum `50`
- Response shape remains the existing OpenAPI `ForumInteractionInboxResponse`.

## Item Contract
- Every item must contain:
  - `notificationId`
  - `tab`
  - `actor`
  - `targetType`
  - `targetId`
  - `title`
  - `createdAt`
  - `unread`
- Optional fields remain:
  - `preview`
  - `canQuickReply`

## Tab Semantics
- `replies`: forum comments or replies derived from existing comment truth.
- `likes`: forum post likes derived from existing like truth.
- `follows`: existing follow truth carried only through an already-frozen source target type.

## Error Semantics
- Missing or illegal `tab` must fail with a controlled bad-request error.
- Missing or invalid current-session carrier must fail with the existing authentication error.
- Empty result is a successful response with:
  - `items: []`
  - `page.hasMore: false`
  - `page.nextCursor: null`

## Non-goals
- No contract schema change.
- No new `forum_author` target type in this repair.
- No message-owned route alias.
- No unread/read-cursor contract.
