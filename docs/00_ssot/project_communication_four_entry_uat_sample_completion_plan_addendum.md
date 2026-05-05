---
owner: Codex 总控
status: draft
layer: L0 SSOT
scope: project_communication_four_entry_uat_sample_completion
created_at: 2026-05-05
---

# Project Communication Four Entry UAT Sample Completion Plan Addendum

## 0. Verdict

This addendum freezes the UAT sample-completion plan for the project-communication four-entry closure round.

Current decision:

- UAT sample mapping: Go.
- Album real-preview UAT: Conditional Go, requires separate authorization to upload and bind one test image.
- Deal-confirmation detail UAT: Conditional Go, requires either an existing `dealConfirmationId` or separate authorization to create one test record.
- Deployment: No-Go in this document.
- Cloud restart: No-Go in this document.
- Payment, service-fee charge, settlement, wallet, invoice, fulfillment, acceptance, dispute, and rating: No-Go.

This document does not reopen the upstream project create-to-publish mainline.

## 1. Read-Only Sample Scan Result

Authenticated read-only sample scanning on 2026-05-05 found:

| Item | Result |
|---|---|
| Authorized test accounts | 2 accounts scanned; credentials and tokens are not recorded. |
| Project-communication conversations | Existing samples are readable. |
| Workbench | Existing samples expose 8 material-review entries. |
| Album photos | No existing album photo sample was found in the scanned projects. |
| Deal-confirmation id | No existing `dealConfirmationId` was found in the scanned workbench entries. |

Current primary UAT candidate:

| Field | Value |
|---|---|
| Project id | `f90ec0f1-0fe6-4f98-979e-3fe8a6d750d7` |
| Conversation id | `e6bf4567-016e-45f9-9420-9c950237690e` |
| Reason | The project is visible in the current project-communication sample set and has been used by earlier authenticated read-only smoke. |

The current sample set can cover list/read smoke, but it cannot fully cover album image preview or deal-confirmation detail without additional data.

## 2. Album Real Preview UAT Sample

Album real-preview UAT requires one separately authorized write package:

1. Prepare a clearly marked small test image.
2. Use the existing upload flow: init -> direct upload -> confirm.
3. Bind the confirmed `FileAsset` to `GET/POST /api/app/project/{projectId}/album/photos` scope through the album photo bind endpoint.
4. Read `GET /api/app/project/{projectId}/album/photos`.
5. Open the controlled file preview/access URL for the returned `fileAssetId`.
6. Delete the album photo binding after acceptance if cleanup is authorized.

Required write authorization text before execution:

`允许上传并绑定一张项目相册测试图片到项目 f90ec0f1-0fe6-4f98-979e-3fe8a6d750d7，并在验收后按相册 photoId 删除绑定。`

Acceptance criteria:

- Album `photoCount` increases by 1 during the test.
- The album item returns a stable `photoId` and `fileAssetId`.
- Preview/access returns a displayable image URL or image response.
- No `objectKey` is exposed to Flutter as business truth.
- Album evidence remains a project evidence pool only; it does not open fulfillment, acceptance, dispute, settlement, or invoice behavior.

Rollback / cleanup boundary:

- Cleanup is limited to deleting the album photo binding through the album photo delete endpoint.
- FileAsset physical cleanup is not part of this UAT unless a separate storage cleanup gate is opened.
- If delete fails, the residual image must remain clearly test-scoped and recorded in the UAT receipt.

## 3. Deal-Confirmation Detail UAT Sample

Deal-confirmation detail UAT has two possible paths:

| Path | Decision |
|---|---|
| Find existing `dealConfirmationId` | Preferred if a valid test record exists, because it is read-only. |
| Create one test deal-confirmation record | Allowed only after separate write authorization, because it creates final-amount test truth. |

Before creating a new record, the execution agent must read and confirm:

- The target project is a test/UAT-safe project.
- Required bid/order/contract anchors are available or explicitly created by an approved test flow.
- The request writes only deal-confirmation test data.
- `/api/app/contract/confirm` is not used to carry final amount.
- No service-fee charge, payment, settlement, wallet, invoice, fulfillment, acceptance, dispute, or rating side effect is triggered.

Required write authorization text before creation:

`允许在项目 f90ec0f1-0fe6-4f98-979e-3fe8a6d750d7 上创建一条 deal-confirmation 测试记录，用于读取 detail 验证；不得触发支付、服务费扣费、结算、钱包、发票、履约或评价。`

Acceptance criteria:

- Created or found `dealConfirmationId` can be read through `/api/app/project/{projectId}/deal-confirmations/{dealConfirmationId}`.
- The detail response owns `finalConfirmedAmount` truth when the record reaches the relevant confirmation state.
- Bid amount, order seed amount, chat content, and Flutter local state are not treated as final amount truth.
- `/api/app/contract/confirm` remains outside final amount confirmation.
- If bilateral confirmation is not executed in this UAT, the receipt must state that only detail-read is covered.

Rollback / cleanup boundary:

- If no delete/cancel endpoint is frozen for deal-confirmation records, the created test record is persistent test data.
- Persistent test records must use a clear test memo/idempotency key if the contract supports it.
- If persistence is unacceptable, creation is No-Go and only existing-id read smoke may be used.

## 4. Sample Coverage Matrix

| Capability | Current read-only sample | Completion requirement | Write required |
|---|---|---|---|
| Counterpart detail `businessTodoSummary` | Covered | None | No |
| Thread `chatAvailability` | Covered | None | No |
| Workbench 8 material-review entries | Covered | None | No |
| Workbench badges / disabled reason | Covered | None | No |
| Album list | Covered with empty list | Need one bound test image for preview | Yes |
| Album real image preview | Not covered | Upload + bind one test image | Yes |
| Deal-confirmation detail | Not covered | Existing id or create test record | Maybe |
| Final bilateral amount completion | Not covered | Separate write-smoke gate | Yes |

## 5. Execution Order After Authorization

The sample-completion order is fixed:

1. Re-run authenticated read-only scan to confirm the target project is still available.
2. Prefer finding an existing `dealConfirmationId`.
3. If no deal id exists, ask for explicit creation authorization before writing.
4. Execute album sample upload/bind only after explicit album authorization.
5. Run album list and preview/access readback.
6. Execute deal-confirmation detail readback.
7. Run unchanged checks for workbench material entries and business badges.
8. Record cleanup outcome.

Album and deal-confirmation samples must not be batched into deployment. They are UAT data-preparation writes, not release operations.

## 6. Current Minimum Closed Loop

Current minimum closed loop for this gate:

`read-only sample scan -> prove album sample missing -> prove deal-confirmation id missing -> freeze separate write authorization texts -> wait for confirmation -> execute one bounded sample write at a time -> read-only evidence -> cleanup receipt`

## 7. Retained But Not Opened

The following remain retained but not opened:

- Full bilateral final-amount confirmation.
- Payment or service-fee charge.
- Settlement, wallet, invoice, fulfillment, acceptance, dispute, rating.
- Bulk album import, album review, album evidence dispute, or lifecycle evidence system.
- Contract-signing workflow beyond deal-confirmation detail read.

## 8. Decision Classes

| Question | Judgment |
|---|---|
| More stable | Find an existing `dealConfirmationId` first and upload only one disposable album test image. |
| Lower cost | Skip write UAT and mark album preview / deal detail as sample-data gaps. |
| Best current-stage path | Authorize one album test image and one deal-confirmation test record only if no existing id is found. |
| Highest risk | Creating final-amount records and album evidence while also deploying or changing payment/service-fee logic. |
