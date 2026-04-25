# Trading IM Thread Participant Visual Projection Refinement Addendum

## Scope
- bounded object: `bid thread detail`
- stage: Phase 0 bounded trading exception refinement

## Decision
- `bid thread detail.participants[]` is refined to admit bounded read-only visual identity projection.
- Each participant item may carry:
  - `displayName`
  - `avatarUrl`
- This refinement is limited to existing admitted `bid thread detail` consumption inside the approved `messages interaction center and bidder carry` chain.

## Truth Rules
- `participants[].displayName` is a display projection only, not business truth ownership.
- `participants[].avatarUrl` is a display projection only.
- Preferred projection source for `avatarUrl` is the admitted participant personal avatar already owned by profile truth.
- This addendum does not create a new chat state machine, a new avatar truth owner, or a new participant-card truth family.

## Non-goals
- no generic DM or group chat
- no new participant profile object
- no mutation of profile avatar truth from Trading IM
