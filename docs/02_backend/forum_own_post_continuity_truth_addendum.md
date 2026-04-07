---
owner: Codex 总控
status: draft
purpose: Freeze the Server-side truth boundary for forum own-post continuity, including edit re-entry through the existing draft corridor, archive-style delete semantics, and the bounded relationship among forum public truth, profile private management entry, author profile projections, attachments, governance carriers, and publish AI gate.
layer: L3 Backend
---

# Forum Own-post Continuity Truth Addendum

## Scope
- This addendum applies only to the current backend truth refinement for:
  - `forum own-post continuity`
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- It freezes only:
  - the `Server` ownership split for own-post edit/delete continuity
  - the minimum edit re-entry truth flow
  - the minimum delete truth flow
  - the bounded relation to existing draft, publish, attachment, governance,
    author-profile, and my-building projections
- It does not by itself:
  - approve implementation completion
  - approve integration release
  - approve closure
  - rewrite the forum domain baseline

## Server Ownership Stays Unchanged
- `Server` remains the only truth owner for:
  - `ForumPost` truth
  - own-post permission truth
  - own-post edit-entry truth
  - own-post delete truth
  - final continuity materialization truth
- `BFF` and frontend remain non-owners of:
  - post truth
  - permission truth
  - delete truth
  - edit truth

## Minimum Permission Boundary
- The minimum owner anchor remains:
  - current actor vs `ForumPost.author_actor_id`
- Current organization context may participate only as:
  - a bounded `Server`-side consistency constraint against
    `author_organization_id`
  - not a client-owned permission source
- Final permission decision remains:
  - `Server` only
- Therefore:
  - `BFF` must not self-decide final permission
  - frontend must not self-decide final permission

## Edit Re-entry Truth Flow
- The minimum edit continuity flow is frozen as:
  1. current actor selects edit on an owned published post
  2. `Server` validates ownership, current state, and governance boundary
  3. `Server` materializes or resumes a draft corridor anchored to the existing
     post
  4. later edits continue through existing `forum_draft_save`
  5. later republish continues through existing `forum_publish`
- The minimum existing anchor for this flow is:
  - `forum_drafts.target_post_id`
- Current meaning:
  - no second edit state machine is required
  - no direct client-side mutation of the published post is approved

## Edited Publish Materialization Rule
- When an edit draft later re-enters publish successfully:
  - `Server` materializes the updated published-post truth
  - the continuity target remains the same post identity
  - the original public post is updated rather than duplicated into a second
    public post by default
- The current minimum package does not approve:
  - full historical version storage for end users
  - public version timeline
  - multi-version branch management
- Append-only audit remains required.

## Draft And Publish Relationship
- Own-post edit continuity must reuse the existing:
  - `draft/save -> publish`
- Current package does not rewrite:
  - draft truth ownership
  - publish truth ownership
  - publish command family
- If republish is blocked:
  - the edit draft remains editable under `Server` control
  - the already published public post remains unchanged

## Relationship To Publish AI Gate
- If the publish AI gate package is active:
  - republish from an edit draft must pass through the same `Server`
    materialized publish gate decision corridor
- Current meaning:
  - edit continuity does not bypass the existing publish AI gate
  - own-post continuity does not create a second moderation or review path

## Relationship To Attachment Packages
- Edit continuity may later reuse the existing attachment packages only through
  already frozen truth:
  - confirmed `FileAsset`
  - forum draft attachment binding
  - publish-time final `forum_post_attachments` binding
- Current package does not reopen:
  - rich media truth
  - file / PDF truth
  - forum-owned upload truth

## Delete Truth Flow
- The minimum delete continuity flow is frozen as:
  1. current actor selects delete on an owned published post
  2. `Server` validates ownership, current state, and governance boundary
  3. `Server` materializes a post-state transition
  4. the post leaves the public visible browse chain
- The minimum preferred semantic is:
  - archive-style state transition
  - not physical hard delete
- This direction is grounded by the existing audit baseline:
  - `ForumPostArchived`

## Public Visibility After Delete
- After the archive-style delete transition:
  - public feed must no longer treat the post as active visible content
  - public author profile must no longer treat the post as active visible
    public content
  - public post detail may later resolve through controlled unavailable
    semantics
- Current minimum package does not require:
  - recycle bin
  - restore flow
  - public tombstone rendering

## Governance Carrier And Report Boundary
- Delete does not mean:
  - wiping `ForumReport`
  - wiping `ForumRiskFlag`
  - wiping `ForumModerationCase`
  - wiping `ReviewTask` linkage
- Existing governance carriers remain preserved for:
  - audit
  - risk attribution
  - controlled review history
- Current package therefore does not approve:
  - physical purge as default
  - governance carrier deletion as a side effect of user delete

## Author Profile And My-building Projection Boundary
- `profile / 我的楼` may consume bounded own-post continuity projections only.
- Public author profile may consume only public visible posts.
- Therefore:
  - delete/archive removes the post from public author profile active public
    projections
  - `profile` remains the private management entry for my posts
  - neither surface becomes the truth owner

## Current Explicit Non-goals
- No comment edit/delete truth
- No comment attachment truth
- No author follow or DM truth
- No avatar edit truth
- No moderation console
- No report history center
- No automatic location truth
- No AI gate expansion
- No second publish path

## Formal Conclusion
- Current formal conclusion:
  - `Server` is the only owner of own-post continuity truth and permission
  - editing a published post must reuse the existing draft corridor anchored by
    `forum_drafts.target_post_id`
  - republish from an edit draft updates the existing post truth rather than
    defaulting to a second public post
  - deleting a post must materialize a `Server`-controlled archive-style state
    transition rather than default hard delete
  - public feeds and public author profile stop showing archived content as
    active visible posts
  - governance carriers remain preserved

## Next Unique Action
- After this truth package is frozen, dispatch backend Agent first to land:
  - edit-entry draft re-entry
  - archive-style post delete materialization
  - continuity-safe projections for public and private surfaces
