---
owner: Codex 总控
status: draft
layer: L0 SSOT
scope: project_communication_four_entry_deploy_and_uat_preflight
created_at: 2026-05-05
---

# Project Communication Four Entry Deploy And UAT Preflight Plan Addendum

## 0. Verdict

This addendum freezes the pre-deployment plan and UAT sample-preparation boundary for the project-communication four-entry closure round.

Current decision:

- Deployment planning: Go.
- UAT sample preparation: Go.
- Actual Server deploy: No-Go until this plan is reviewed and explicitly confirmed.
- Actual BFF deploy: No-Go until Server deployment and Server smoke pass, unless the review concludes BFF is already aligned and does not need redeploy.
- Write smoke: No-Go until explicitly confirmed after this plan.
- Cloud restart: No-Go until explicit deployment authorization.
- Push: No-Go.

This document does not reopen the upstream project create-to-publish mainline and does not change payment, service-fee charge, settlement, wallet, invoice, fulfillment, acceptance, dispute, or rating truth.

## 1. Current Runtime Baseline

Read-only runtime alignment on 2026-05-05 confirmed:

| Layer | Active runtime path |
|---|---|
| Server | `/srv/releases/server/20260505130047-material-review-bidid-reopen` |
| BFF | `/srv/releases/bff/20260505120428-message-business-state-v1` |

Systemd process cwd matched the active symlinks:

| Service | Runtime cwd |
|---|---|
| `exhibition-server` | `/srv/releases/server/20260505130047-material-review-bidid-reopen` |
| `exhibition-bff` | `/srv/releases/bff/20260505120428-message-business-state-v1` |

Health checks passed through the local tunnel:

- `GET http://127.0.0.1:8080/health/bff/live` returned `200`.
- `GET http://127.0.0.1:8080/health/server/live` returned `200`.

## 2. Local Commit Baseline

The current local four-entry closure commits are:

| Commit | Meaning |
|---|---|
| `1364fde` | Freeze project communication four entries. |
| `ecf072b` | Align generated project album contracts. |
| `6f48213` | Allow project album photo previews. |
| `32f17c2` | Tighten project communication four-entry UI. |

Pre-deployment review must compare the cloud active release against these commits before deciding whether a Server or BFF deployment is still necessary.

## 3. Deployment Decision Matrix

| Layer | Current evidence | Deployment decision before confirmation |
|---|---|---|
| Server | Active release already exposes `businessTodoSummary`, `chatAvailability`, workbench `badgeCount / disabledReason`, project album service, and `project_album_photo` preview hooks. | Conditional. Deploy only if diff review proves local Server commit `6f48213` is not already represented in active runtime. |
| BFF | Active release already exposes counterpart detail business todo, workbench chat availability, workbench entry badges, and project album routes/read-models. | Conditional. Deploy only if diff review proves route/read-model mismatch. |
| Flutter | Local app needs authenticated visual UAT; deployment is not part of this cloud Server/BFF gate. | Local联调 only. App store/static rollout is out of scope. |

## 4. Frozen Deployment Order

If deployment is approved after this plan, the order is fixed:

1. Server deployment.
2. Server health check.
3. Server field smoke.
4. BFF deployment.
5. BFF health check.
6. BFF field smoke.
7. Flutter local integration with base URL `http://127.0.0.1:8080`.
8. Authenticated read-only smoke.
9. Separately approved write smoke only when required.

BFF must not be deployed before the Server field smoke passes when the BFF read-model is strict about new Server fields.

## 5. Rollback Points

The pre-deployment rollback anchors are the current active runtime paths:

| Layer | Rollback anchor |
|---|---|
| Server | `/srv/releases/server/20260505130047-material-review-bidid-reopen` |
| BFF | `/srv/releases/bff/20260505120428-message-business-state-v1` |

Rollback procedure, if later authorized:

1. Restore the relevant `/srv/apps/*/current` symlink to the rollback anchor.
2. Restart only the affected service.
3. Run health check.
4. Run authenticated read-only smoke for the affected route family.

No database rollback is part of this plan.

## 6. Read-Only Smoke Requirements

The post-plan read-only smoke must verify:

| Target | Required evidence |
|---|---|
| Counterpart detail | `projectGroups[].businessTodoSummary` exists with all five count fields. |
| Thread | `chatAvailability` exists with `canSendMessage`, `lockReasonCode`, `lockReasonText`, and `requiredNextAction`. |
| Workbench | `businessTodoSummary`, `chatAvailability`, and `entries[].badgeCount / disabledReason` exist. |
| Workbench entries | Exactly 8 material-review entries remain the `资料确认单` truth; deal-confirmation entries stay outside material-review commands. |
| Deal confirmation | Only `/api/app/project/{projectId}/deal-confirmations/{dealConfirmationId}` is detail-read capable when a real id exists; collection `GET` is not required by V1. |
| Album list | `/api/app/project/{projectId}/album/photos` returns `photoCount` and `items`. |
| Album preview | Requires at least one real active album photo FileAsset; otherwise mark as `not covered by current sample data`, not failed. |

## 7. UAT Sample Preparation Boundary

UAT sample preparation may proceed in parallel with deployment planning, but it must not perform write operations before explicit confirmation.

Allowed now:

- Identify test project, counterpart conversation, thread, and existing workbench state.
- Confirm whether an existing album photo sample exists.
- Confirm whether an existing deal confirmation id exists.
- Confirm whether the current local Flutter app has an authenticated session.
- Prepare the exact write-smoke checklist for later approval.

Not allowed now:

- Upload or bind a new album photo.
- Create or update material-review records.
- Send project communication messages.
- Create deal-confirmation records.
- Trigger bid submit, service-fee authorization, payment, settlement, invoice, wallet, or fulfillment operations.
- Restart cloud services.

## 8. Current UAT Sample Candidate

The current authenticated read-only smoke found one project-communication sample:

| Field | Value |
|---|---|
| Project id | `f90ec0f1-0fe6-4f98-979e-3fe8a6d750d7` |
| Conversation id | `e6bf4567-016e-45f9-9420-9c950237690e` |
| Project groups | `11` |
| Workbench entries | `10` |
| Material-review entries | `8` |
| Album list | reachable, `photoCount = 0` in the current sample |

Because the album has no photo sample, real image preview UAT requires a separately approved write step to upload and bind a test image.

Because no workbench entry currently carries a deal-confirmation id, deal-confirmation detail UAT requires either:

1. Finding another existing project with a real `dealConfirmationId`, or
2. A separately approved write step to create a test deal-confirmation record.

## 9. Acceptance Criteria Before Actual Deployment

Actual deployment may start only when all are true:

- This addendum is reviewed and confirmed.
- Current dirty worktree risks are acknowledged and excluded from deployment artifacts.
- Server/BFF artifact contents are explicitly mapped to the intended commits or release source.
- Rollback anchors are still readable.
- Health checks are green.
- A smoke account/session plan exists without writing credentials into docs or logs.
- The first post-deploy action is read-only.

## 10. Current Minimum Closed Loop

Current minimum closed loop for this gate:

`freeze deploy plan -> prepare UAT sample map -> confirm deploy necessity -> deploy Server only if needed -> Server read-only smoke -> deploy BFF only if needed -> BFF read-only smoke -> Flutter local authenticated UAT -> separate write-smoke approval`

## 11. Retained But Not Opened

The following are retained but not opened by this plan:

- Album photo upload/bind write smoke.
- Deal-confirmation creation write smoke.
- Final amount bilateral confirmation completion.
- Payment and service-fee charge.
- Settlement, wallet, invoice, fulfillment, acceptance, dispute, rating.
- App-store or production mobile binary release.

## 12. Decision Classes

| Question | Judgment |
|---|---|
| More stable | Freeze this deployment/UAT plan first, then deploy only the layer that is proven stale. |
| Lower cost | Skip deployment if active runtime already carries the required Server/BFF behavior; do Flutter local UAT only. |
| Best current-stage path | Parallelize deployment-plan review and UAT sample mapping, but serialize actual deploy and write smoke. |
| Highest risk | Deploying Server/BFF and running write smoke together without proving whether active runtime already has the feature. |
