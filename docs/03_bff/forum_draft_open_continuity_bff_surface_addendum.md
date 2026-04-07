---
owner: Codex 总控
status: draft
purpose: Freeze the BFF-side shaping boundary for forum draft-open continuity, ensuring BFF only shapes the app-facing draft detail open path and does not own draft truth or invent a second draft state machine.
layer: L3 BFF
---

# Forum Draft-open Continuity BFF Surface Addendum

## Scope
- This addendum applies only to the current BFF truth refinement for:
  - `forum draft-open continuity`
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- It freezes only:
  - BFF shaping boundary for draft-open
  - relation to existing draft/save -> publish surfaces
  - explicit non-goals
- It does not by itself:
  - approve implementation
  - approve release
  - approve closure

## BFF Responsibility Boundary
- `BFF` may do only:
  - app-facing shaping for `draft/detail` open
  - auth consolidation
  - Chinese controlled error normalization
  - visibility trimming
- `BFF` must not own:
  - draft truth
  - draft-open truth
  - publish eligibility truth

## Minimum Surface Set
- `BFF` may shape only:
  - `GET /api/app/forum/draft/list`
  - `GET /api/app/forum/draft/detail`
  - `POST /api/app/forum/draft/save`
  - `POST /api/app/forum/publish`
- `BFF` must not create:
  - a second draft-open path family
  - a profile-owned draft corridor
  - a second draft state machine

## Draft-open Shaping Boundary
- `BFF` may shape only:
  - draft-open payload for app consumption
  - controlled invalid / not-found / permission-denied / unavailable results
- `BFF` must not:
  - invent missing draft fields
  - fake attachment confirmations
  - treat `draftId` alone as content restore

## Explicit Non-goals
- No second draft system
- No profile-owned draft truth
- No local fake restore
- No rich media protocol changes
- No AI gate expansion

## Formal Conclusion
- `BFF` only shapes the draft-open app-facing surface.
- `BFF` does not own draft truth and must not invent a second draft state
  machine.

## Next Unique Action
- After backend truth lands, dispatch `BFF` Agent second to wire
  `draft/detail` shaping under the existing forum family.
