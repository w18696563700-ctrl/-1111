---
owner: Codex 总控
status: frozen
purpose: Freeze the BFF transport boundary for forum interaction inbox materialization.
layer: L3 BFF
---

# Forum Interaction Inbox Transport Addendum

## BFF Boundary
- `BFF` owns app-facing materialization for:
  - `GET /api/app/forum/interaction/inbox`
- `BFF` forwards to:
  - `GET /server/forum/interaction/inbox`

## Allowed Responsibilities
- Build current-session forwarding headers.
- Forward `tab`, `cursor`, and `pageSize`.
- Preserve upstream controlled errors.
- Return Server projection without creating new business truth.

## Prohibited Responsibilities
- No forum notification truth in BFF.
- No inbox state machine.
- No tab-specific business synthesis.
- No fake empty fallback on upstream failure.
- No generic message center route alias.

## Gate
- Targeted BFF tests must prove:
  - app-facing route is materialized
  - all three tabs forward
  - empty responses pass through
  - auth failure preserves upstream code
  - illegal tab preserves upstream code
