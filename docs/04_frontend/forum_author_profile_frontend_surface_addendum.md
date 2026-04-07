---
owner: Codex 总控
status: draft
purpose: Freeze the Flutter-side surface boundary for public forum author profile and its relationship to the current profile building without turning profile into a public homepage or reopening other unapproved capabilities.
layer: L3 Frontend
---

# Forum Author Profile Frontend Surface Addendum

## Scope
- This addendum applies only to the current frontend truth refinement for:
  - `论坛作者主页与我的楼联动`
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- It freezes only:
  - the formal handoff direction from author avatar or author name
  - the page-family boundary of public author profile
  - the bounded relationship between public author profile and `profile`
  - the current non-goals
- It does not by itself:
  - approve implementation completion
  - approve avatar edit
  - approve author follow
  - approve DM

## Formal Handoff Direction
- Clicking author avatar or author name from:
  - forum feed
  - post detail
  - comment chain
- must hand off to:
  - a forum-owned public author profile surface
  - still inside the existing `exhibition/forum` family
- The formal handoff direction is therefore:
  - forum public content -> public author profile
- It must not hand off directly to:
  - `profile` as the default public author homepage
  - `messages`
  - a second forum home tree

## Public Author Profile vs My Building
- Public author profile means:
  - 看别人
  - 或看自己的公共论坛形象
- `profile` means:
  - 我自己的资产与身份中心
- The relationship between the two is frozen as:
  - public author profile = forum public surface
  - `profile` = my private or semi-private asset and identity center
- `profile` must not be rewritten as:
  - a public author homepage
  - the truth owner of public author data

## Minimum Public Author Page Tree
- The current minimum public author page tree discusses only:
  - header summary
  - public post list
- No extra segmented content is required by this round.
- If a bounded segmented control later proves truly necessary, it may only stay
  inside the same public author page and remain limited to:
  - public summary
  - public posts
- It must not automatically expand into:
  - a second forum homepage
  - private assets
  - DM panel
  - follow panel

## Self-opening Rule
- If the current actor opens their own public author profile, future frontend
  behavior may allow only:
  - a bounded handoff back to `profile`
- This current rule does not allow:
  - turning `profile` into the public author page itself
  - skipping public author profile and treating `profile` as the same surface

## Avatar Consumption Discipline
- Frontend may consume only:
  - avatar projection from `BFF`
- Frontend must not assume:
  - forum owns avatar truth
  - public author profile includes avatar edit
  - avatar upload belongs to this capability package

## Current Explicit Non-goals
- No avatar edit
- No author follow
- No DM
- No private-profile details
- No rich-publish media upload in this package
- No automatic post-location truth in this package
- No AI review gate in this package
- No own-post edit or delete in this package
- No second forum homepage

## Frontend Consumption Discipline
- Frontend continues to consume `BFF` output only.
- Frontend must not call `Server` directly.
- Frontend must not build:
  - a second forum state machine
  - a second profile-owned public-author tree

## Current Truth Meaning
- This addendum belongs only to:
  - public author-profile frontend surface truth
- It is:
  - frontend truth
- It is not:
  - implementation completion
  - avatar-edit approval
  - author-follow approval
  - DM approval

## Formal Conclusion
- Current formal conclusion:
  - public author profile belongs to the forum public surface
  - clicking author avatar or author name must hand off into the forum-owned
    public author profile surface
  - `profile` remains my asset and identity center only
  - forum cannot own avatar truth and may consume avatar projection only
- Current meaning:
  - L3 frontend truth for public author profile and my-building linkage only

## Next Unique Action
- After backend and `BFF` surfaces are ready, dispatch frontend Agent third to
  implement the frozen public-author handoff and bounded page tree above.
