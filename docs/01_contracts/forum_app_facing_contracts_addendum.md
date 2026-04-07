---
owner: Codex 总控
status: draft
purpose: Freeze the pre-implementation forum app-facing contract refinement, keeping forum under a single canonical path family and preserving the current browsing, messages, and profile ownership split.
layer: L2 Contracts
---

# Forum App-facing Contracts Addendum

## Scope
- This addendum applies only to the current pre-implementation forum
  app-facing contract refinement.
- It freezes only:
  - the canonical forum path-family boundary
  - the minimum forum contract object families
  - the current building-specific consumption split
  - the current non-approved meaning
- It does not by itself:
  - approve implementation
  - approve `BFF` or frontend implementation dispatch
  - freeze the final returned-field output draft
  - create a second forum path family

## Canonical Path-family Rule
- Current forum app-facing path family remains:
  - `/api/app/forum/*`
- Current forum contract truth must not create:
  - `/api/app/social/*`
  - a second parallel forum path family
  - a `messages`-local forum browsing path family
  - a `profile`-local forum browsing path family

## Current Canonical Path Matrix
- Current forum implementation-facing path matrix may include only:
  - `GET /api/app/forum/feed`
  - `GET /api/app/forum/topic/metadata`
  - `GET /api/app/forum/topic/list`
  - `GET /api/app/forum/topic/detail`
  - `GET /api/app/forum/post/detail`
  - `GET /api/app/forum/post/comments`
  - `POST /api/app/forum/post/comment`
  - `POST /api/app/forum/post/like`
  - `POST /api/app/forum/post/bookmark`
  - `POST /api/app/forum/topic/follow`
  - `POST /api/app/forum/draft/save`
  - `GET /api/app/forum/draft/list`
  - `POST /api/app/forum/draft/delete`
  - `POST /api/app/forum/publish`
  - `GET /api/app/forum/search`
  - `GET /api/app/forum/me/index`
  - `GET /api/app/forum/me/posts`
  - `GET /api/app/forum/me/comments`
  - `GET /api/app/forum/me/bookmarks`
  - `GET /api/app/forum/me/follows`
  - `GET /api/app/forum/interaction/inbox`
- Current path-matrix meaning:
  - one forum family only
  - one app-facing object tree only
  - no second forum family under `messages` or `profile`

## Minimum Contract Object Families
- Current forum app-facing contracts must cover at minimum:
  - forum square feed
  - forum local feed
  - forum following feed
  - topic metadata for classify, select, and filter
  - forum post detail
  - forum post comments
  - forum interaction actions:
    - like
    - comment
    - bookmark
    - follow
  - forum publish
  - forum draft save
  - forum draft list
  - forum draft delete
  - forum me assets:
    - my posts
    - my comments
    - my bookmarks
    - my follows
  - forum interaction inbox:
    - replies
    - likes
    - follows

## Building-specific Consumption Split
- `exhibition/forum` remains the only current main browsing consumer of:
  - feed families
  - post detail
  - comment chain
  - publish and draft entry
  - topic classification and filter metadata
- `messages` interaction center may consume only:
  - interaction inbox class contracts
- `messages` must not take over:
  - forum square feed
  - forum local feed
  - forum following feed
  - forum post detail
  - forum post comments
- `profile` may consume only:
  - my posts
  - my comments
  - my bookmarks
  - my follows
  - draft assets
- `profile` must not take over:
  - forum main browsing contracts
  - forum public feed contracts
  - forum container-home contracts

## Taxonomy Position
- `话题` remains the internal forum classification system only.
- Topic metadata in current contracts serves only:
  - publish-time classification
  - post-title labeling
  - internal list filtering
- Current main forum browse chain is post-centric.
- Current forum feed contracts must therefore carry post-feed items with topic
  labeling, not topic-home carriers.
- Topic must not be re-elevated into:
  - a first-level content navigation contract family

## Current Contract Meaning
- This addendum belongs only to:
  - forum app-facing contract truth refinement
- It is:
  - contract truth
- It is not:
  - implementation approval
  - returned-field final freeze output
  - moderation truth approval
  - review truth approval
  - `messages` completion approval
  - `profile` completion approval

## Formal Conclusion
- Current formal conclusion:
  - forum app-facing contracts remain under `/api/app/forum/*`
  - no `/api/app/social/*` path family is approved
  - no second parallel forum path family is approved
  - `exhibition/forum` remains the current main browsing consumer
  - `messages` consumes only interaction inbox class contracts
  - `profile` consumes only my forum assets class contracts
- Current contract-freeze meaning:
  - forum pre-implementation L2 contract refinement only
