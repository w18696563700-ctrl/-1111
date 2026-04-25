# Trading IM Thread Participant Visual Projection Contract Refinement Addendum

## App-facing refinement
- Canonical path remains `GET /api/app/bid/thread/detail`.
- `participants[]` now admits the optional fields:
  - `displayName: string | null`
  - `avatarUrl: string | null`

## Constraints
- Existing required fields remain:
  - `participantRole`
  - `organizationId`
- Missing `displayName` or `avatarUrl` must not fail the whole thread-detail contract.
- `avatarUrl` is bounded display-only payload and may be null.
