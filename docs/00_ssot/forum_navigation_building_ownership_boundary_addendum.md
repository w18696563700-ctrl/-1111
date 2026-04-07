---
owner: Codex 总控
status: draft
purpose: Freeze the current building-ownership and revised navigation boundary for the forum module, including the split between exhibition forum, messages interaction center, and profile forum assets, without opening contracts or implementation.
layer: L0 SSOT
---

# 论坛模块楼栋归属与导航边界冻结单

## Scope
- This addendum applies only to the current boundary-freeze round for the
  forum module.
- It freezes only:
  - where forum belongs in the current five-building architecture
  - which building owns the forum mainline
  - which building owns cross-module interaction notifications
  - which building owns personal forum assets
  - the current revised navigation hierarchy for forum
  - the current explicit non-goals
- It does not by itself:
  - freeze app-facing contracts
  - freeze `L3 BFF truth`
  - freeze `L3 Frontend truth`
  - approve backend / `BFF` / frontend implementation

## Building Ownership Boundary
- `forum` remains inside the `exhibition` building.
- `forum` must not become:
  - a sixth shell building
  - a new bottom tab
  - a detached shell-level navigation tree
- `messages` and `profile` may consume forum-related surfaces only through the
  current frozen ownership split below.

## Forum Mainline Ownership
- `exhibition/forum` owns the forum mainline browse chain.
- The forum mainline includes:
  - public browse entry
  - square feed
  - local feed
  - following feed
  - post detail
  - direct comment context
  - direct like / follow interaction context
  - publish main action
  - search tool action
- The forum mainline must remain where users:
  - browse forum content
  - switch among the primary content views
  - enter post detail
  - perform the primary content interaction
  - return to the forum browsing context
- `exhibition/forum` must keep owning forum primary browse semantics.
- `messages` must not become a second forum home.
- `profile` must not become the primary forum content browse building.

## Messages Ownership Boundary
- `messages` owns the future cross-module interaction notification center only.
- `messages` is not:
  - a second forum mainline
  - a second forum browse chain
  - a second post-detail tree
  - a second comment center
- Forum-related notification consumption may later exist in `messages` only as:
  - cross-module interaction reminders
  - source-object jump handoff
  - controlled light interaction handling when later separately approved

## Profile Ownership Boundary
- `profile` owns personal forum assets and management entries only.
- The current frozen personal forum assets under `profile` are:
  - `我的帖子`
  - `我的评论`
  - `我的收藏`
  - `我的关注`
  - `草稿`
- These personal forum assets:
  - belong to `profile` as personal asset entry points
  - no longer belong to the forum main container as first-level entries
- `profile` is not:
  - the forum content browse mainline
  - the forum production mainline
  - a second feed building

## Forum Navigation Hierarchy
- The forum primary navigation hierarchy is now revised to:
  - `1` forum container
  - `3` first-level content views
  - `tool` actions inside the forum container
  - `detail` pages downstream
- The only first-level forum content views are:
  - `广场`
  - `本地`
  - `关注`
- The following are not first-level content views:
  - `话题`
  - `搜索`
  - `发帖`
  - `草稿`
  - `我的论坛资产`

## Topic Internal Classification Boundary
- `话题` is no longer frozen as a first-level content view.
- `话题` is now frozen as:
  - the internal classification system of forum content
  - the taxonomy carrier for post creation
  - the classification carrier for post display
  - the internal filter carrier for list browsing
- The current topic boundary therefore means:
  - posting must choose one topic
  - post titles must show the所属话题 in front of the title
  - list pages may apply internal filtering by topic
- Whether topic detail exists as a later standalone downstream surface may be
  discussed in a later downstream layer only.
- The current round does not freeze topic as a first-level forum navigation
  entry.

## Search And Publish Tool Boundary
- `搜索` is now frozen as:
  - the top-right tool entry inside the forum container
  - not a first-level content navigation view
- `发帖` is now frozen as:
  - the bottom-right `+` main action inside the forum container
  - not a first-level content navigation view
- Search and publish remain:
  - forum-owned actions
  - not shell-level entries
  - not separate first-level content views

## Current Navigation Principles
- Entering forum from `/exhibition` must still land in the forum container and
  remain inside the `exhibition` shell.
- Switching among `广场 / 本地 / 关注` is same-layer navigation, not a stack of
  unrelated top-level routes.
- `话题` is now internal taxonomy, not a fourth peer first-level content
  perspective.
- Search and publish are tool actions, not content-navigation peers.
- Personal forum assets and drafts must return through `profile`, not through
  the forum main container.
- `messages` remains the cross-module interaction notification center only,
  not the place where the forum mainline is rebuilt.

## Current Explicit Non-goals
- No sixth shell building
- No new bottom tab
- No reinterpretation of `messages` as a full forum interaction workbench
- No reinterpretation of `profile` as the forum content browse mainline
- No reinterpretation of `profile` as the forum content-production mainline
- No contract freeze in this round
- No `L3` truth freeze in this round
- No implementation approval in this round
- No Docker migration approval in this round

## Formal Conclusion
- Current formal conclusion is:
  - `forum` remains a feature family inside `exhibition`
  - `exhibition/forum` owns the forum mainline browse chain
  - `messages` owns the future cross-module interaction notification center
    only
  - `profile` owns personal forum assets only
  - the only current first-level forum content views are
    `广场 / 本地 / 关注`
  - `话题` is the forum internal classification system, not a first-level
    navigation entry
  - `搜索` is the top-right tool entry
  - `发帖` is the bottom-right `+` main action
- Current closure type is:
  - building-ownership and navigation-boundary freeze only

## Next Unique Action
- Continue only with later `L2 / L3` forum truth refinement and implementation
  proposals that stay inside this frozen ownership boundary.
