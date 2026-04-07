---
title: Profile Safety Plus Safety Audit P0 Implementation Result Verification Rerun
status: frozen
date: 2026-04-07
---

# Profile Safety P0 + Safety Audit P0 Implementation Result Verification Rerun

## Scope

This document records the control-led rerun for:

- `Profile Safety P0`
- `Safety Audit P0`

This rerun does not open:

- `Forum Report P0`
- `Block P0`
- `Admin Review P0`
- AI runtime
- OCR / QR detection
- penalty / appeal
- release-prep / launch approval

## Active Ingress Rerun

The rerun used the active cloud ingress chain:

- local tunnel `127.0.0.1:8080`
- cloud `nginx :80`
- BFF `:3000`
- Server `:3001`

Evidence:

- no-auth `GET /api/app/profile/personal/safety` returned controlled `401 AUTH_SESSION_INVALID`
- OTP login through `/api/app/auth/otp/login` returned `200` and `shellBootstrapState=authenticated`
- authenticated `GET /api/app/profile/personal/safety` returned `200`
- authenticated `POST /api/app/profile/personal/nickname` returned controlled safety submission responses
- authenticated `POST /api/app/profile/personal/avatar` returned controlled safety submission responses
- authenticated `POST /api/app/profile/personal/bio` returned controlled safety submission responses

There was no raw `Cannot GET` / `Cannot POST` route-missing response in the tested app-facing active ingress chain.

## State Machine Rerun

Nickname:

- baseline approved display name was `云端验收`
- submitting `复核通过` returned `pending_review`
- shell context still displayed old value `云端验收` while the new value was pending
- manual approve through Server `:3001` changed the approved display name to `复核通过`

Avatar:

- current avatar projection was present before submission
- submitting the existing confirmed profile/avatar FileAsset `50ad9588-6473-4c95-83f4-710fa2e127e0` returned `pending_review`
- safety status retained current avatar projection while also exposing pending avatar projection
- invalid FileAsset `00000000-0000-4000-8000-000000000000` returned controlled `404 PERSONAL_AVATAR_FILE_UNAVAILABLE`

Bio:

- baseline approved bio was empty
- submitting `复核简介` returned `pending_review`
- shell context kept the old approved bio empty while the new bio was pending
- manual reject through Server `:3001` returned `rejected` with reason `复核拒绝原因`
- safety status retained the rejection reason
- resubmitting `复核简介重提` returned `pending_review`

State-machine conclusion:

- old approved value remains visible: PASS
- new submission enters pending review: PASS
- approve replaces approved display value: PASS
- reject preserves old value and exposes rejection reason: PASS
- resubmit is accepted after rejection: PASS
- no blank-profile regression was observed in the tested paths: PASS

## Capability Closure

| capability | result | rerun evidence |
| --- | --- | --- |
| `CS-001` nickname hard-rule interception | PASS | nickname `管理员` returned `400 PROFILE_SAFETY_RULE_BLOCKED` with rule `p0_reserved_admin` |
| `CS-002` avatar basic file validation | PASS | confirmed profile/avatar FileAsset was accepted into `pending_review`; invalid FileAsset returned `PERSONAL_AVATAR_FILE_UNAVAILABLE` |
| `CS-003` bio hard-rule interception | PASS | bio `管理员` returned `400 PROFILE_SAFETY_RULE_BLOCKED` with rule `p0_reserved_admin` |
| `CS-004` profile pre-publication review state | PASS | nickname/avatar/bio all entered pending before replacing public values; approve/reject/resubmit paths were verified |
| `CS-005` profile review trace | PASS | `profile_safety_submissions`, snapshots, and audit logs were created in the live carrier tables during smoke |
| `CS-006` avatar rejection feedback surface | CONDITIONAL PASS | backend/BFF expose rejected submission reason and pending/current avatar projections; frontend surface was covered by existing profile tests, but the tested rerun did not manually reject an avatar submission |
| `CS-025` audit logs | PASS | `content_safety_audit_logs` exists and contains rule/manual records |
| `CS-026` content snapshots | PASS | `content_safety_snapshots` exists and smoke increased persisted submission snapshots |
| `CS-031` sensitive/reserved-word rule library | PASS | `content_safety_rules` contains P0 seed rules and blocks reserved word `管理员` |

## Audit Carrier Rerun

Cloud DB carrier proof:

- `profile_safety_submissions`: present
- `content_safety_rules`: present
- `content_safety_snapshots`: present
- `content_safety_audit_logs`: present
- `users.profile_intro`: present
- `users.avatar_file_asset_id`: present

Post-rerun counts:

- `content_safety_rules`: `9`
- `profile_safety_submissions`: `14`
- `content_safety_snapshots`: `14`
- `content_safety_audit_logs`: `48`
- audit engine types: `manual:34, rule:14`

## Runtime Boundary Rerun

P0 runtime boundary:

- `rule_seed=9`
- `ai_engine_rules=0`
- rule engine types: `rule:9`
- audit records use `rule` and `manual`

No AI runtime, OCR, QR detection, penalty, appeal, Forum Report P0, Block P0, or Admin Review P0 was opened in this rerun.

## AGENTS Length Gate Decision

Decision:

- `需要拆分修正`

Rationale:

- `apps/mobile/lib/features/profile/data/profile_personal_edit_consumer_layer.dart`: `777` lines
- `apps/mobile/lib/features/profile/presentation/profile_personal_edit_pages.dart`: `703` lines
- `apps/mobile/lib/features/profile/presentation/profile_detail_pages.dart`: `625` lines
- `apps/server/src/modules/profile/profile-safety.write.service.ts`: `640` lines

These files exceed the root `AGENTS.md` handwritten business source limit of `450` lines. They are not generated files, migrations, fixtures, localization copy, route registries, or registered constant lookup tables. No formal exemption exists in current SSOT.

Therefore the length gate cannot be passed by verbal waiver.

## Final Acceptance Decision

`Profile Safety P0 + Safety Audit P0` implementation result verification rerun:

- active ingress: PASS
- state machine: PASS
- capability closure: PASS with one frontend avatar-reject-feedback surface limitation recorded as conditional
- audit carriers: PASS
- runtime boundary: PASS
- AGENTS length gate: FAIL

Final package acceptance:

- `PENDING / NO-GO`

Remaining blocker:

- AGENTS file length gate must be corrected by bounded refactor or formal SSOT exemption before the first package can receive final completion signoff.

## Next Unique Action

Open only:

`Profile Safety P0 + Safety Audit P0 AGENTS length gate correction`

Allowed purpose:

- split oversized handwritten business files by responsibility, or create a formal SSOT exemption if and only if a split would worsen responsibility boundaries

Still blocked:

- `Forum Report P0`
- `Block P0`
- `Admin Review P0`
- AI runtime
- OCR / QR detection
- penalty / appeal
- release-prep / launch approval
