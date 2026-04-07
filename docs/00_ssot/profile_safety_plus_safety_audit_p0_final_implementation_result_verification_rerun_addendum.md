---
title: Profile Safety Plus Safety Audit P0 Final Implementation Result Verification Rerun
status: frozen
date: 2026-04-07
---

# Profile Safety P0 + Safety Audit P0 Final Implementation Result Verification Rerun

## Scope

This document records the final control-led implementation result verification rerun for:

- `Profile Safety P0`
- `Safety Audit P0`

This rerun followed the AGENTS length-gate correction and Server cloud artifact alignment. It does not open:

- `Forum Report P0`
- `Block P0`
- `Admin Review P0`
- AI runtime
- OCR / QR detection
- penalty / appeal
- release-prep / launch approval

## Cloud Artifact Proof

Active Server:

- active release: `/srv/releases/server/20260407040500`
- active symlink: `/srv/apps/server/current -> /srv/releases/server/20260407040500`
- active PID: `1208628`
- active cwd: `/srv/releases/server/20260407040500`

Active split artifact proof:

- `profile-safety-avatar-file.service.js`: present
- `profile-safety-input.parser.js`: present
- `profile-safety-response.presenter.js`: present
- `profile-safety-review.service.js`: present
- `profile-safety-submit.service.js`: present

Cloud source line-count proof:

- `profile-safety-avatar-file.service.ts`: `54`
- `profile-safety-input.parser.ts`: `65`
- `profile-safety-response.presenter.ts`: `77`
- `profile-safety-review.service.ts`: `229`
- `profile-safety-submit.service.ts`: `349`
- `profile-safety.query.service.ts`: `65`
- `profile-safety.write.service.ts`: `40`

AGENTS length gate remains closed after cloud artifact alignment.

## Active Ingress Proof

The rerun used the active app-facing chain:

- local tunnel `127.0.0.1:8080`
- cloud `nginx :80`
- BFF `:3000`
- Server `:3001`

Evidence:

- OTP login returned `200`
- `shellBootstrapState=authenticated`
- authenticated shell context returned approved `displayName`, `profileIntro`, and avatar projection
- no raw `Cannot GET` / `Cannot POST` route-missing response was observed in the tested app-facing routes
- app-facing safety routes returned controlled safety results

## Profile Safety State Machine Rerun

Nickname:

- baseline approved display name: `复核通过`
- submit `终验通过`: returned `pending_review`
- shell context still showed old approved value `复核通过` while pending
- manual approve through Server `:3001`: returned approved
- shell context then showed `displayName=终验通过`
- blocked nickname `管理员`: returned `400 PROFILE_SAFETY_RULE_BLOCKED`, source `server`, reason `reserved_word`, matched `p0_reserved_admin`

Bio:

- baseline approved bio: empty
- submit `终验简介`: returned `pending_review`
- shell context still showed old approved bio while pending
- manual reject through Server `:3001`: returned `rejected`, reason `终验拒绝原因`
- safety status retained the rejection reason
- resubmit `终验简介重提`: returned `pending_review`
- blocked bio `管理员`: returned `400 PROFILE_SAFETY_RULE_BLOCKED`, source `server`, reason `reserved_word`, matched `p0_reserved_admin`

Avatar:

- current avatar projection was present before submission
- submit confirmed profile/avatar FileAsset `50ad9588-6473-4c95-83f4-710fa2e127e0`: returned `pending_review`
- response retained current avatar projection and exposed pending avatar projection
- invalid FileAsset `00000000-0000-4000-8000-000000000000`: returned controlled `404 PERSONAL_AVATAR_FILE_UNAVAILABLE`

State-machine conclusion:

- old approved value remains visible: PASS
- new submission enters pending review: PASS
- approve replaces approved display value: PASS
- reject preserves old value and exposes rejection reason: PASS
- resubmit after rejection is accepted: PASS
- no profile blanking or tested UX regression was observed: PASS

## Capability Closure

| capability | result | evidence |
| --- | --- | --- |
| `CS-001` nickname hard-rule interception | PASS | `管理员` returned `PROFILE_SAFETY_RULE_BLOCKED` with `p0_reserved_admin` |
| `CS-002` avatar basic file validation | PASS | confirmed profile/avatar FileAsset entered pending; invalid FileAsset returned `PERSONAL_AVATAR_FILE_UNAVAILABLE` |
| `CS-003` bio hard-rule interception | PASS | bio `管理员` returned `PROFILE_SAFETY_RULE_BLOCKED` with `p0_reserved_admin` |
| `CS-004` profile pre-publication review state | PASS | nickname/avatar/bio pending behavior plus approve/reject/resubmit were verified |
| `CS-005` profile review trace | PASS | profile safety submissions, snapshots, and audit logs were present and increased in live carriers |
| `CS-006` avatar rejection feedback surface | PASS with bounded evidence | backend/BFF expose current/pending avatar projections and controlled avatar errors; frontend status-card behavior remains covered by the targeted Flutter tests |
| `CS-025` audit logs | PASS | `content_safety_audit_logs` present; post-rerun count `73` |
| `CS-026` content snapshots | PASS | `content_safety_snapshots` present; post-rerun count `23` |
| `CS-031` sensitive/reserved-word rule library | PASS | `content_safety_rules` count `9`; reserved-word rule blocked nickname and bio |

## Audit Carrier Proof

Cloud DB post-rerun counts:

- `content_safety_rules`: `9`
- `profile_safety_submissions`: `23`
- `content_safety_snapshots`: `23`
- `content_safety_audit_logs`: `73`

Audit engine types:

- `manual:50`
- `rule:23`

## Runtime Boundary Proof

P0 runtime boundary:

- `rule_seed=9`
- `ai_engine_rules=0`
- rule engine types: `rule:9`
- no AI runtime was introduced
- no OCR / QR detection was introduced
- no penalty / appeal runtime was introduced
- no `Forum Report P0`, `Block P0`, or `Admin Review P0` runtime was opened

## Verification Notes

During artifact alignment, an initial `rsync` attempt failed because the remote host does not have `rsync`. The active symlink was not switched during that failed attempt. Deployment then used a tar stream, built on cloud, switched `/srv/apps/server/current`, and restarted `exhibition-server.service` successfully.

## Final Acceptance Decision

`Profile Safety P0 + Safety Audit P0`: PASS.

This PASS means:

- first content-safety implementation package is complete at current development-stage acceptance
- active cloud Server artifact is aligned after AGENTS length-gate correction
- active ingress state-machine smoke passes
- P0 rule/manual runtime boundary remains intact

This PASS does not mean:

- `Forum Report P0` is unlocked
- `Block P0` is unlocked
- `Admin Review P0` is unlocked
- AI runtime, OCR, QR detection, penalty, appeal, release-prep, or launch approval is unlocked

## Next Unique Action

Return to content-safety P0 implementation order and author the next-stage judgment for:

`Forum Report P0 implementation unlock judgment`

This is only a judgment-authoring step. It must not directly open implementation until the corresponding boundary and dispatch checks pass.
