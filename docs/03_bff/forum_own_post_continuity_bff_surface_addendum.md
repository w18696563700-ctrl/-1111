---
owner: Codex 总控
status: draft
purpose: Freeze the BFF-side shaping boundary for forum own-post continuity, including edit-entry and delete-entry app-facing shaping, while keeping post truth, permission truth, and delete truth owned by Server.
layer: L3 BFF
---

# Forum Own-post Continuity BFF Surface Addendum

## Scope
- This addendum applies only to the current BFF truth refinement for:
  - `forum own-post continuity`
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- It freezes only:
  - the allowed `BFF` shaping boundary for own-post continuity
  - the relation among forum public surfaces, `profile / 我的楼`, and the
    existing draft corridor
  - the current explicit non-goals
- It does not by itself:
  - approve implementation completion
  - approve release
  - approve closure
  - approve a second post-management state machine

## BFF Responsibility Boundary
- For this package, `BFF` may do only:
  - app-facing shaping
  - auth consolidation
  - visibility trimming
  - Chinese controlled error normalization
  - bounded owner-action affordance shaping when needed
- `BFF` must not own:
  - post truth
  - permission truth
  - delete truth
  - edit truth
  - profile truth

## Minimum Surface Set
- `BFF` may shape only the minimum continuity-related surface set:
  - `GET /api/app/forum/me/posts`
  - `GET /api/app/forum/post/detail`
  - `POST /api/app/forum/post/edit`
  - `POST /api/app/forum/post/delete`
  - existing `draft/save -> publish` continuation shaping
- `BFF` must not create:
  - a second forum path family
  - a `profile`-owned post-truth family
  - a second post-management state machine

## Edit-entry Shaping Boundary
- `BFF` may shape only:
  - accepted edit-entry handoff to a `Server`-owned draft corridor
  - bounded draft anchor cues for the client
  - controlled invalid / invalid-state / permission-denied results
- `BFF` must not:
  - directly mutate published post truth
  - invent local edit success
  - create a second edit workflow outside `draft/save -> publish`

## Delete-entry Shaping Boundary
- `BFF` may shape only:
  - accepted delete-entry result
  - controlled invalid / invalid-state / permission-denied results
  - bounded Chinese user-facing messages
- `BFF` must not:
  - convert delete into local-only hide semantics
  - invent hard-delete success when `Server` did not materialize it
  - drop governance-side consequences on its own

## `Profile` And Public Surface Boundary
- `profile / 我的楼` may consume:
  - bounded own-post management entry semantics
- Forum public surfaces may consume:
  - public post detail and public author projections only
- `BFF` must therefore keep the split frozen as:
  - public post truth stays in forum
  - private management entry stays in `profile`
- `BFF` must not:
  - make `profile` the post-truth owner
  - merge public author page and my-building into one surface

## Current Explicit Non-goals
- No comment edit/delete shaping
- No author follow or DM shaping
- No avatar edit shaping
- No moderation-console shaping
- No report-history shaping
- No automatic-location shaping
- No AI-gate expansion shaping
- No second forum homepage

## Formal Conclusion
- Current formal conclusion:
  - `BFF` only shapes own-post continuity as an app-facing handoff layer
  - `BFF` does not own post, permission, edit, or delete truth
  - `BFF` must not invent a second state machine
  - `BFF` must not let `profile` become a post-truth owner

## Next Unique Action
- After backend truth lands, dispatch `BFF` Agent second to wire edit-entry,
  delete-entry, and bounded continuity shaping under the existing forum family.
