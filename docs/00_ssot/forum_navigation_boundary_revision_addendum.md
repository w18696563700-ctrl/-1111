---
owner: Codex 总控
status: draft
purpose: Freeze the current revision of the forum first-level navigation hierarchy, including the demotion of topic into internal taxonomy, the demotion of search and publish into tool actions, and the move of personal forum assets into profile, without approving contracts or implementation.
layer: L0 SSOT
---

# 论坛导航边界修订冻结单

## Scope
- This addendum applies only to the current navigation-layer revision for the
  forum module.
- It freezes only:
  - why the current forum first-level content navigation is revised
  - what the revised first-level navigation now is
  - why topic is demoted into internal taxonomy
  - why search and publish are demoted into tool actions
  - why personal forum assets move into `profile`
  - what this revision does not approve
- It does not by itself:
  - approve implementation
  - approve `L2 Contracts`
  - approve `L3 BFF truth`
  - approve `L3 Frontend truth`
  - approve `messages` or `profile` completion

## Current Revision Target
- The current revision changes the forum first-level content navigation from:
  - `广场 / 本地 / 关注 / 话题`
- To:
  - `广场 / 本地 / 关注`

## Why This Revision Is Needed
- The current revision is needed because:
  - the forum first-level navigation needs fewer parallel entry points
  - the forum container should feel cleaner and more direct
  - users should be less likely to treat taxonomy, tools, and personal assets
    as the same layer as content browsing
- The current total-control judgment is:
  - too many first-level peers make the forum harder to scan
  - topic, search, publish, and personal assets do not belong to the same
    content-navigation layer as `广场 / 本地 / 关注`

## Why Topic Becomes Internal Taxonomy
- `话题` is demoted to the internal classification system because:
  - forum becomes more focused when the first layer shows only content
    perspectives
  - users are less likely to get lost when taxonomy is treated as filtering and
    classification rather than a peer home view
  - topic still remains structurally important for:
    - posting classification
    - post display labeling
    - list filtering
- The current revision therefore freezes:
  - topic is required at publish time
  - topic must appear in front of the post title
  - topic may be used for internal list filtering
- The current revision does not freeze:
  - topic as a first-level forum navigation entry
  - topic-detail implementation

## Why Search And Publish Become Tool Actions
- `搜索` becomes the top-right magnifier tool because:
  - search is a utility action, not a content perspective
  - it should remain instantly reachable without competing with the main
    browse views
- `发帖` becomes the bottom-right `+` main action because:
  - publish is the main forum action, not a browse dimension
  - it should remain highly visible but not consume a first-level content slot
- This current revision therefore treats:
  - search as a tool action
  - publish as a main action
  - neither as a first-level content view

## Why Personal Forum Assets Move Into Profile
- Personal forum assets and drafts move into `profile` because:
  - they are personal assets, not public forum browsing perspectives
  - they belong to personal management and collection semantics
  - keeping them out of the forum main container reduces first-level clutter
- The current personal asset set moved into `profile` is:
  - `我的帖子`
  - `我的评论`
  - `我的收藏`
  - `我的关注`
  - `草稿`
- This move does not mean:
  - `profile` becomes the forum browse mainline
  - `profile` is completed

## What This Revision Does Not Approve
- This current revision belongs only to:
  - forum navigation-level revision
- It is not:
  - implementation approval
  - contract approval
  - `messages` implementation approval
  - `profile` implementation approval
  - `messages` or `profile` completion approval

## Formal Conclusion
- Current formal conclusion:
  - the forum first-level content navigation is now revised to
    `广场 / 本地 / 关注`
  - `话题` is demoted to the forum internal classification system
  - `搜索` is demoted to the top-right tool entry
  - `发帖` is demoted to the bottom-right `+` main action
  - personal forum assets and drafts are moved into `profile`
- Current revision type:
  - forum navigation-layer boundary revision only
- Current non-approved meaning:
  - no implementation
  - no contracts
  - no `messages` or `profile` completion approval

## Next Unique Action
- Continue only with later downstream forum truth refinement that respects this
  revised navigation boundary.
