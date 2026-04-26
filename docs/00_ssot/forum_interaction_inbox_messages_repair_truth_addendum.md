---
owner: Codex 总控
status: frozen
purpose: Freeze the repair truth for the forum-derived interaction inbox consumed by the messages building, without creating a second forum home or a general message center.
layer: L0 SSOT
---

# Forum Interaction Inbox Messages Repair Truth Addendum

## Repair Truth
- `forum interaction inbox` is the `messages` building notification entrance for forum-derived events only.
- It is not a second forum homepage.
- It is not a generic message center.
- It must not replace `exhibition/forum` as the owner of forum browsing, post detail, comment tree, or forum write actions.

## Current Minimum Closed Loop
- Flutter continues to consume:
  - `GET /api/app/forum/interaction/inbox?tab=replies`
  - `GET /api/app/forum/interaction/inbox?tab=likes`
  - `GET /api/app/forum/interaction/inbox?tab=follows`
- `BFF` materializes the app-facing route and forwards it to `Server`.
- `Server` materializes a read-only projection at:
  - `GET /server/forum/interaction/inbox`
- The projection reads existing forum truth only:
  - replies from existing comments
  - likes from existing post likes
  - follows from existing author follows, carried by an existing source-object target

## Non-negotiable Boundary
- No new table.
- No migration.
- No BFF-owned forum truth.
- No BFF business stitching beyond transparent route transport.
- No Flutter fallback fake data.
- No expansion into forum feed, forum post detail, or profile assets under `messages`.
- No generic DM, chat thread, or project-communication reuse in this route.

## Follows Tab Carrier Rule
- Current OpenAPI target types are limited to:
  - `forum_post`
  - `forum_comment`
  - `forum_topic`
- Because `forum_author` is not yet a frozen target type, the `follows` tab must not add a new schema shape in this repair.
- The bounded implementation may carry a follow notification through an existing published source object owned by the followed author.
- If no safe source object is available, the `follows` tab returns an empty paged collection.

## Read State Rule
- This repair does not create read-receipt truth.
- The required `unread` field remains a response projection field only.
- Any later unread state, read cursor, or notification audit requires a separate SSOT and contract freeze.

## Stage Gate Checklist
| Gate | Result | Notes |
|---|---|---|
| SSOT repair truth frozen | PASS | Forum-derived notification entrance only |
| Contract path already frozen | PASS | OpenAPI contains `/api/app/forum/interaction/inbox` |
| Server ownership retained | PASS | Server owns read projection |
| BFF truth ownership blocked | PASS | BFF forwards only |
| New persistence blocked | PASS | No table, no migration |
| Generic message center expansion blocked | PASS | Route stays under `/forum/interaction/inbox` |

## Formal Conclusion
- The current allowed work is a bounded route-materialization repair.
- The most stable path is:
  - Server read-only projection
  - BFF transparent forwarding
  - no Flutter information-architecture change
- The lower-cost path is the same because Flutter already consumes the frozen route.
- The path most suitable for the current stage is to restore the existing contract instead of inventing a new messages API.
- The higher-risk path is expanding `messages` into a second forum homepage or adding unread persistence without a separate freeze.
