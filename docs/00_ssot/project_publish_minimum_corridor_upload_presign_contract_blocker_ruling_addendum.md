---
owner: Codex 总控
status: frozen
purpose: Freeze the narrowed ruling for the remaining upload blocker after Server transport repair and runtime revalidation, identifying the exact presign-url versus returned-headers contract mismatch as the current blocker.
layer: L0 SSOT
alignment_basis:
  - docs/00_ssot/project_publish_minimum_corridor_upload_transport_repair_receipt.md
  - docs/00_ssot/project_publish_minimum_corridor_upload_transport_revalidation_receipt.md
  - AGENTS.md
freeze_date_local: 2026-04-02
---

# 项目发布最小走廊 presign 契约阻断裁决单

## 1. Current Ruling

- The previous upload transport blocker has been reduced.
- The current remaining blocker is no longer:
  - loopback host
  - public endpoint reachability
  - confirm-side false success after skipped PUT
- The current remaining blocker is now:
  - `presigned PUT URL` and `returned directUpload.headers` are not contract-consistent

## 2. Current Evidence

- Current runtime evidence proves:
  - `directUpload.url` is no longer loopback
  - public OSS endpoint is reachable
  - skipped PUT now keeps `confirm` in `409`
- Current runtime evidence also proves:
  - using the returned `directUpload.headers` causes:
    - `403 SignatureDoesNotMatch`
    - `HeadersNotSigned: X-AMZ-META-*`
- Additional diagnostic evidence proves:
  - using only minimal `Content-Type` can make `PUT -> 200`
  - but `confirm` then fails because metadata truth is missing

## 3. Total-control Interpretation

- The current failure is a contract mismatch, not a topology mismatch.
- The current source repair was directionally correct but still incomplete.
- The exact missing close condition is:
  - the returned upload-header contract must match the actual signed URL contract

## 4. Mandatory Repair Scope

- The next repair round must stay Server-only.
- It must repair one exact issue:
  - either the returned `directUpload.headers` must be exactly the headers signed
    by the presigned URL
  - or the signed upload contract must be redesigned so that the returned
    headers and the confirm-side verification strategy stay fully consistent
- The next repair round must not reopen:
  - BFF
  - Flutter
  - auth
  - shell
  - workbench

## 5. Required Protection Against Regression

- The next repair round must add a source-level regression check that proves:
  - every required returned upload header is actually compatible with the
    generated signed URL contract
- A test that only asserts:
  - URL contains `X-Amz-Signature`
  - returned headers are present
  is no longer sufficient.

## 6. Close Condition

- This blocker may be marked closed only when all of the following are true:
  - using the exact returned `directUpload.headers` yields a successful real PUT
  - `confirm` then returns `200 + fileAssetId`
  - skipped or failed PUT still yields controlled `409`
  - a source-level regression check covers the signed-header contract

## 7. Dispatch Conclusion

- Current stage decision:
  - `No-Go` for corridor closeout
  - `Go` for a narrow `Server upload presign-contract repair round`
