---
owner: Codex 总控
status: frozen
purpose: Freeze the Server-side read-only projection boundary for forum interaction inbox materialization.
layer: L3 Backend
---

# Forum Interaction Inbox Read Projection Addendum

## Server Boundary
- `Server` owns `GET /server/forum/interaction/inbox`.
- The route is read-only.
- The route projects existing forum truth into the app-facing inbox contract.

## Allowed Reads
- `forum_comment`
- `forum_posts`
- `forum_post_likes`
- `forum_author_follows`
- existing author and organization projection reads

## Prohibited Work
- No new table.
- No migration.
- No write command.
- No inbox state machine.
- No read cursor persistence.
- No duplicated forum browse tree.

## Projection Rules
- `replies` shows other users' published comments on the current user's published posts, plus replies to the current user's published comments.
- `likes` shows other users' likes on the current user's published posts.
- `follows` shows other users following the current author only when an existing published source object can safely carry the notification.
- Self-generated interactions are filtered out.
- Hidden or unavailable source objects are filtered out.

## Gate
- This backend repair passes only if targeted tests cover:
  - `replies`
  - `likes`
  - `follows`
  - empty list
  - auth failure
  - illegal tab
