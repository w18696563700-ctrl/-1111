---
title: Forum Report P0 Cloud Runtime Alignment Review
status: reviewed
owner: Control
scope: docs-only
created_at: 2026-04-07
---

# Forum Report P0 Cloud Runtime Alignment Review

## A. Current Review Object

This review covers the `Forum Report P0` cloud-only runtime alignment receipt.

This review does not open:

- `Block P0`
- `Admin Review P0`
- AI runtime
- OCR / QR detection
- forum precheck
- automatic hide or takedown
- penalty / appeal
- payment / billing / V2.3
- release-prep / launch approval

## B. Current Review Scope

This is a control-led verification and recording round.

No implementation thread is unlocked by this document.

The review focuses on whether the latest `Forum Report P0` runtime proof is now cloud-shaped:

- cloud nginx `:80`
- BFF `:3000`
- Server `:3001`
- active release artifacts under `/srv/releases/**`
- no local Node ingress shim
- no local BFF / Server runtime as acceptance proof

## C. Input Baseline

Canonical upstream inputs:

- `forum_report_p0_freeze_addendum.md`
- `forum_report_p0_implementation_unlock_judgment_addendum.md`
- `forum_report_p0_implementation_independent_review_addendum.md`
- `forum_report_p0_comment_report_truth_gap_judgment_addendum.md`
- `forum_report_p0_comment_target_truth_correction_review_addendum.md`
- `forum_report_p0_runtime_environment_drift_review_addendum.md`
- `forum_report_p0_runtime_environment_acceptance_judgment_addendum.md`
- `content_safety_capability_tracking_table_v1.md`
- `source_of_truth_map.md`

The immediate prior blocker was runtime-environment drift: previous proof was produced through a local Node ingress shim rather than the accepted cloud-shaped path.

## D. Cloud Runtime Proof

Control independently verified that cloud runtime is now aligned.

Verified cloud runtime facts:

- nginx is active on `:80`
- active BFF listener is `:3000`
- active Server listener is `:3001`
- BFF active symlink resolves to `/srv/releases/bff/20260407113018/apps/bff`
- Server active symlink resolves to `/srv/releases/server/20260407113018`
- nginx health through cloud `localhost:80` returns BFF live health with `service=exhibition-bff` and `port=3000`
- nginx health through cloud `localhost:80` returns Server live health with `service=exhibition-server-isolated` and `port=3001`
- no-auth report submit through nginx returns controlled `401 AUTH_SESSION_INVALID`
- direct BFF `:3000` no-auth report submit returns controlled `401 AUTH_SESSION_INVALID`
- direct Server `:3001` no-auth report submit returns controlled `401 AUTH_SESSION_INVALID`

Local `127.0.0.1:8080` was not treated as the only acceptance source. It is only acceptable when it is an SSH tunnel to cloud nginx `:80`, not a local Node shim.

During this review, local `:8080` was later observed as an SSH listener and returned nginx health / controlled no-auth report errors. The stronger acceptance proof remains the direct cloud-side `localhost:80 -> nginx -> BFF -> Server` verification.

## E. Artifact Proof

Control independently verified cloud artifact presence.

BFF active artifact contains:

- `app-forum.controller.js` with `Post('report/submit')`
- `forum.service.js` with app path `/api/app/forum/report/submit`
- `forum.service.js` forwarding to `/server/forum/report/submit`

Server active artifact contains:

- `forum.controller.js` with `Post('report/submit')`
- `ForumCommentEntity`
- `ForumReportTicketEntity`
- `ForumReportService`
- a `command.targetType === 'comment'` branch
- forum comment table migration artifact

This closes the previous raw route-missing blocker.

## F. Active Ingress Live Proof

Control independently reran active ingress proof through cloud nginx `:80`.

Authenticated smoke login returned a valid app session.

Live report submit results:

| Probe | Result |
| --- | --- |
| no-auth report submit | controlled `401 AUTH_SESSION_INVALID` |
| legal comment report | `202 Accepted`, ticket `f0880f88-5772-46eb-936d-a655eb657853` |
| legal post report | `202 Accepted`, ticket `4ffd1c9f-2082-4824-b09f-857784d8b85a` |
| invalid comment target | controlled `404 FORUM_POST_UNAVAILABLE` |

The verified legal comment target was:

- `targetType=comment`
- `targetId=forum-comment-report-cloud-smoke-20260407`

The verified legal post target was:

- `targetType=post`
- `targetId=05e575ef-95a9-438d-b893-e44320a37bce`

No raw `Cannot POST`, raw Express 404, or local shim-only success was accepted.

## G. Snapshot And Audit Carrier Proof

Control independently verified DB-backed carrier rows for the rerun tickets.

Verified rows include:

| Ticket | Target | Status | Snapshot | Audit |
| --- | --- | --- | --- | --- |
| `f0880f88-5772-46eb-936d-a655eb657853` | `comment` | `submitted` | `forum_report_ticket` snapshot with `content_type=forum_comment` | `forum_report_submitted`, `engine_type=manual`, `decision=submitted` |
| `4ffd1c9f-2082-4824-b09f-857784d8b85a` | `post` | `submitted` | `forum_report_ticket` snapshot with `content_type=forum_post` | `forum_report_submitted`, `engine_type=manual`, `decision=submitted` |

Carrier counts at rerun time:

- `content_safety_rules` with `engine_type=rule`: `9`
- `content_safety_rules` with `engine_type=ai`: `0`
- `content_safety_audit_logs` with `engine_type=ai`: `0`
- `forum_report_ticket`: `6`
- `content_safety_snapshots` for `forum_report_ticket`: `6`
- `content_safety_audit_logs` for `forum_report_ticket`: `6`

## H. Capability Closure Check

| Capability | Result | Review Note |
| --- | --- | --- |
| `CS-010` post report entry | PASS | Post report can be submitted through active cloud ingress and persists a ticket / snapshot / audit. |
| `CS-011` comment report entry | PASS | Comment report can be submitted through active cloud ingress and persists a ticket / snapshot / audit. |
| `CS-012` report-ticket truth and status flow | PASS | Server owns report-ticket truth; BFF forwards / shapes; DB carrier rows and manual audit rows exist. |
| `CS-013` minimum report viewing ability | PENDING | `ForumReportQueryService` exists as a read-model preparation, but no active app/admin route was verified in this review. This remains tied to the later `Admin Review P0` boundary and must not be claimed as a completed Admin surface. |

## I. Runtime Boundary Check

P0 runtime boundary remains intact:

- `rule` seed count is `9`
- AI rule count is `0`
- AI audit count is `0`
- report submit audit uses `engine_type=manual`

The review found no evidence that AI runtime, OCR, QR detection, automatic takedown, penalty, or appeal entered this package.

## J. AGENTS Length Gate Check

The cloud runtime alignment layer passes, but final package completion still cannot be granted.

Current source line-count check found:

- `apps/bff/src/routes/forum/forum-command-error.service.ts`: `508` lines

This file is handwritten BFF business logic, not generated code, migration, fixture, localization copy, route registry, or a formally registered constant lookup table. Current SSOT already records this file as a non-exempt file-length blocker in `file_length_governance_blocker_closure_assessment_addendum.md`.

Therefore, `Forum Report P0` cannot receive final completion signoff until this length-gate item is corrected or formally exempted by SSOT. Verbal waiver is not allowed.

## K. Review Decision

`Forum Report P0 cloud-only runtime alignment`: PASS.

The prior cloud-shape runtime blocker is closed:

- no local Node shim is required
- nginx `:80 -> BFF :3000 -> Server :3001` is live
- post report is live
- comment report is live
- ticket / snapshot / audit truth exists
- AI runtime remains absent

`Forum Report P0 final package completion`: PENDING / NO-GO.

Remaining blockers:

1. `forum-command-error.service.ts` exceeds the root AGENTS handwritten source `450` line limit without formal exemption.
2. `CS-013` minimum report viewing ability is not yet verified as an active Admin / app viewing surface and remains tied to later `Admin Review P0` boundaries.

## L. Next Unique Action

`Forum Report P0 AGENTS length gate correction`

The next action must only address the BFF file-length / responsibility gate for Forum Report P0 touched code, especially `apps/bff/src/routes/forum/forum-command-error.service.ts`.

It must not open:

- `Block P0`
- `Admin Review P0`
- AI runtime
- OCR / QR detection
- precheck
- automatic takedown
- penalty / appeal
- release-prep / launch approval

