# Trading IM Thread Participant Visual Projection Backend Refinement Addendum

## Backend refinement
- `bid thread detail` may project participant visual identity directly from:
  - participant organization name
  - participant user avatar
- The projection is read-only and computed at query time.

## Admitted sources
- `project.creatorUserId`
- `bid.userId`
- `organizations.name`
- `users.avatar_url`

## Persistence rule
- No new table.
- No backfill job.
- No mutation of `Bid`, `Project`, or profile truth.
