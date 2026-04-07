---
owner: Codex 总控
status: draft
purpose: Freeze the implementation-facing Flutter page and route surface for the current forum round so the later frontend prompts can implement the accepted IA without reopening ownership drift.
layer: L3 Frontend
---

# Forum Frontend Implementation Surface Addendum

## Scope
- This addendum applies only to the current forum implementation round.
- It freezes only:
  - the current formal page tree
  - the current route-to-surface consumption split
  - the current interaction and publish entry placement
  - the current cross-building boundaries
- It does not by itself:
  - approve a sixth building
  - approve a new bottom tab
  - approve a second client forum state machine

## Current Formal Page Tree
- Current first-release frontend implementation may include only:
  - `exhibition/forum` container-home
  - `exhibition/forum` feed surfaces:
    - square
    - local
    - following
  - `exhibition/forum` post detail
  - `exhibition/forum` comment interaction surface
  - `exhibition/forum` publish surface
  - `exhibition/forum` search surface
  - `messages` interaction center:
    - replies
    - likes
    - follows
  - `profile` forum assets:
    - my posts
    - my comments
    - my bookmarks
    - my follows
    - drafts

## Current Navigation Rules
- `广场 / 本地 / 关注` remain the only first-level content perspectives.
- `话题` must not appear as a first-level content tab.
- `搜索` remains the forum top-right tool action.
- `发帖` remains the forum bottom-right `+` main action.
- `我的论坛` and `草稿` must not be reintroduced into the forum home as peer
  first-level entries.

## Current Feed Presentation Rule
- The current formal forum browse chain is post-centric.
- Feed cards must present:
  - topic label
  - title
  - excerpt
  - author/time/engagement summary
- Topic classification remains visible but secondary to the feed item itself.

## Current Detail And Interaction Rule
- Post detail and comment interaction remain inside `exhibition/forum`.
- The natural return chain remains:
  - comment interaction
  - post detail
  - feed list
  - forum container
- `messages` must not become the primary detail chain carrier.

## Messages Building Rule
- `messages` may show only the interaction inbox tabs:
  - `回复我的`
  - `收到的赞`
  - `新关注`
- The page must behave as a notification center, not a content home.
- If quick reply is exposed later, it must still write through the same forum
  interaction contract and must not create a second message-owned discussion
  tree.

## Profile Building Rule
- `profile` may show bounded forum personal assets:
  - my posts
  - my comments
  - my bookmarks
  - my follows
  - drafts
- `profile` may also host the current-user hub, company detail entry, identity entry, and settings entry under separate frozen profile truth.
- The page must behave as an asset-management surface, not a browse feed.

## Current Non-goals
- No new shell building
- No new bottom tab
- No topic first-level home tab
- No second client forum state machine
- No duplication of forum browse flow under `messages` or `profile`

## Formal Conclusion
- Current frontend conclusion:
  - the accepted IA may now be implemented on the formal forum surfaces above
  - `广场 / 本地 / 关注` remain the only first-level content views
  - `messages` and `profile` remain bounded consumers, not forum owners
- Current meaning:
  - implementation-facing frontend truth for the current forum round
- Current non-approved meaning:
  - no architecture expansion
  - no second client forum state machine
