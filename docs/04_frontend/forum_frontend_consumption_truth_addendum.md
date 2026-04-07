---
owner: Codex 总控
status: draft
purpose: Freeze the Flutter-side forum consumption truth before implementation, preserving the revised first-level forum navigation, the messages interaction-center boundary, and the profile forum-assets boundary.
layer: L3 Frontend
---

# Forum Frontend Consumption Truth Addendum

## Scope
- This addendum applies only to the current pre-implementation Flutter-side
  forum consumption refinement.
- It freezes only:
  - `exhibition/forum` container-home consumption boundary
  - first-level content-view consumption
  - tool and classification consumption
  - detail and comment-chain consumption
  - `messages` and `profile` split consumption
- It does not by itself:
  - approve implementation
  - approve a second client forum state machine
  - approve a sixth building
  - approve a new bottom tab

## Exhibition Forum Container-home Boundary
- `exhibition/forum` remains inside the `exhibition` building.
- The forum container home consumes only three first-level content views:
  - `广场`
  - `本地`
  - `关注`
- Frontend must not consume:
  - `话题` as a first-level content view
  - `搜索` as a first-level content view
  - `发帖` as a first-level content view

## First-level Content-view Consumption
- `广场` consumes the public forum square feed.
- `本地` consumes the local forum feed.
- `关注` consumes the follow-based forum feed.
- The three first-level views are the only current main browsing perspectives.
- Frontend must keep them as peer content views only and must not mix them
  with:
  - tools
  - taxonomy
  - personal asset management

## Tool And Taxonomy Consumption
- `搜索` is consumed only as the forum-container top-right tool entry.
- `发帖` is consumed only as the forum-container bottom-right `+` main action.
- `话题` is consumed only as internal classification through:
  - publish-time topic selection
  - post-title topic labeling
  - list-level topic filtering
- Frontend must not consume topic as:
  - a first-level home tab
  - a second forum homepage

## Post-detail And Comment-chain Consumption
- Frontend must consume the forum detail chain through:
  - post detail entry
  - comment list
  - comment interaction flow
  - like and follow action surfaces
- The forum detail chain still belongs to `exhibition/forum`.
- Frontend must not split post-detail browsing into:
  - `messages`
  - `profile`

## Messages Interaction-center Boundary
- `messages` building may consume only:
  - `回复我的`
  - `收到的赞`
  - `新关注`
- `messages` must not become:
  - the second forum homepage
  - the main forum feed entry
  - the forum post-detail browsing building

## Profile Forum-assets Boundary
- `profile` building may consume forum personal assets through bounded entries:
  - `我的帖子`
  - `我的评论`
  - `我的收藏`
  - `我的关注`
  - `草稿箱`
- `profile` may also remain the current-user identity, company, and settings hub under separate frozen profile truth.
- `profile` must not become:
  - the main forum browsing building
  - the forum first-level content navigation carrier

## Frontend Consumption Discipline
- Frontend consumes `BFF` output only.
- Frontend must not call `Server` directly.
- Frontend must not build:
  - a second forum state machine
  - a second moderation state machine
  - a second engagement-truth cache that overrides `BFF`

## Formal Conclusion
- Current frontend conclusion:
  - forum browsing remains centered in `exhibition/forum`
  - `messages` consumes only interaction-center semantics
  - `profile` consumes personal forum asset semantics through bounded entries and remains the current-user hub
  - `广场 / 本地 / 关注` remain the only first-level content views
- Current frontend meaning:
  - L3 consumption truth only
- Current non-approved meaning:
  - no implementation approval
  - no direct `Server` consumption
  - no new building or bottom-tab expansion
