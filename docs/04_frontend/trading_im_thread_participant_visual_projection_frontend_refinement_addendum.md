# Trading IM Thread Participant Visual Projection Frontend Refinement Addendum

## Frontend refinement
- `BidThreadPage` participant tiles may consume `participants[].displayName` and `participants[].avatarUrl` directly from thread detail.
- `participant-card minimum` remains admitted as a secondary handoff, not a prerequisite for showing avatar on the participant tile.

## Consumption rule
- Preferred tile avatar source:
  1. `participants[].avatarUrl`
  2. `participant-card.enterpriseSummary.logoUrl`
  3. initials fallback

## Non-goal
- This refinement does not change the participant-card sheet contract.
