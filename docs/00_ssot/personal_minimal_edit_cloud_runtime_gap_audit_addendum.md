# Personal Minimal Edit Cloud Runtime Gap Audit

## Scope
- Package: `Personal minimal edit`
- Buildings: `profile`
- Audit target: active cloud runtime only
- Audit date: `2026-04-06`

## Current accepted deployment rule
- `BFF` and `Server` for this package are cloud-hosted.
- Local Docker or local runtime is not an allowed deployment target for current verification.
- Any local runtime attempt must be treated as a mistaken operation and recorded.

## Recorded mistaken local operation
- A local MinIO startup attempt was made during runtime repair investigation.
- That local object-storage attempt has been removed.
- The previous cloud access tunnel `127.0.0.1:8080 -> 47.108.180.198:80` has been restored so current verification remains cloud-facing.
- No business source truth was changed in order to perform that local runtime attempt.

## Cloud runtime facts
- Cloud host `47.108.180.198` has Docker installed.
- Cloud host currently has no active Docker containers for this package.
- Active cloud ingress is still `nginx` on port `80`.
- Active production-like upstream mapping is:
  - `80 -> bff_upstream -> 127.0.0.1:3000`
  - `80 -> server_upstream -> 127.0.0.1:3001`
- A separate staging-smoke path also exists:
  - `127.0.0.1:18080 -> 3100 / 3101`

## Runtime mismatch findings
- Active cloud `BFF :3000` is not running the current local repo implementation for `Personal minimal edit`.
- Active cloud `Server :3001` is not running the current local repo implementation for `Personal minimal edit`.
- Therefore the current cloud app-facing runtime does not match the repo state that already contains:
  - `personal/nickname`
  - `personal/avatar`
  - `profile/avatar` upload binding
  - `avatar_file_asset_id` carrier

## Concrete evidence
- Cloud `POST /api/app/profile/personal/nickname` currently returns raw `404 Cannot POST /bff/profile/personal/nickname`.
- Cloud `POST /api/app/file/upload/init` with `businessType=profile` and `fileKind=avatar` currently returns `400 FILE_UPLOAD_INIT_INVALID` with message `Current upload init only supports businessType=project.`
- Active cloud `BFF :3000` is healthy but still serves an older route family.
- Active cloud `Server :3001` is healthy but still serves the older upload binding rule.
- Current cloud nginx config still points default traffic to `3000 / 3001`, not to a newer release carrying the current repo package.

## Release-level evidence
- Active cloud `BFF :3000` process cwd resolves to:
  - `/srv/releases/bff/20260404160902/apps/bff`
- Active cloud `Server :3001` process cwd resolves to:
  - `/srv/releases/server/20260404013000`
- That active cloud `BFF` release does not contain `personal/nickname` or `personal/avatar` in the routed app-facing profile command controller.
- That active cloud `Server` release still contains the old upload restriction:
  - `Current upload init only supports businessType=project.`
- That active cloud `Server` release does not yet show the `avatar_file_asset_id` carrier in the compiled entity output.

## Audit conclusion
- The current blocker is not local frontend behavior.
- The current blocker is not current repo source completeness.
- The current blocker is a cloud deployment gap:
  - current repo code contains the package
  - active cloud runtime does not
- Therefore `Personal minimal edit` is currently blocked by cloud runtime non-deployment, not by missing bounded source implementation.

## Immediate next action
- Open one bounded cloud-only deployment repair package for:
  - active `BFF :3000`
  - active `Server :3001`
  - cloud object-storage deployment or equivalent cloud upload transport
- Do not reopen local runtime repair.
- Do not reopen package scope.

## Non-goals
- No OCR
- No real-name package
- No certification or review-console expansion
- No local runtime rollout
