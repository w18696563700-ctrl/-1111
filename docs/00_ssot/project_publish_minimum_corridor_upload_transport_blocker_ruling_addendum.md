---
owner: Codex 总控
status: frozen
purpose: Freeze the total-control ruling for the upload transport blocker discovered during development-stage integration validation of the project publish minimum corridor.
layer: L0 SSOT
alignment_basis:
  - docs/00_ssot/project_publish_minimum_corridor_integration_validation_receipt.md
  - docs/00_ssot/project_publish_minimum_corridor_internal_truth_contracts_freeze_addendum.md
  - AGENTS.md
freeze_date_local: 2026-04-02
---

# 项目发布最小走廊上传 transport 阻断裁决单

## 1. Current Blocking Fact

- The current minimum corridor has passed:
  - `POST /api/app/project/create`
  - `GET /api/app/project/detail`
  - `POST /api/app/file/upload/init`
  - `POST /api/app/file/upload/confirm`
- But the current corridor has failed at the mandatory transport step:
  - direct upload

## 2. Root-cause Split

- The current blocker is not a single bug. It is a two-part transport failure:

### 2.1 Host reachability failure

- `directUpload.url` currently returns:
  - `http://127.0.0.1:9000/...`
- Under local tunnel validation, that host resolves to the operator machine, not
  the cloud host.
- External check against:
  - `http://47.108.180.198:9000/minio/health/live`
  currently cannot connect.
- Therefore the current direct-upload host is not an externally reachable
  development upload endpoint.

### 2.2 Signing / authorization / truth-coupling failure

- The current Server source generates `directUploadUrl` by string concatenation
  only.
- It does not currently generate a signed PUT URL.
- The integration receipt also proves that cloud-local PUT against the same URL
  returns:
  - `403 AccessDenied`
- In addition, current `confirm` issues:
  - `200 + fileAssetId`
  even when transport PUT has failed.

## 3. Total-control Ruling

- The current blocker is classified as:
  - `upload transport blocker`
- It is narrow enough to stay inside the current project-publish minimum
  corridor mainline.
- It does not justify reopening:
  - auth board
  - shell board
  - workbench board
  - corridor expansion

## 4. Mandatory Repair Scope

- The next repair round must include both of the following in the same narrow
  Server track:

### 4.1 Direct upload endpoint repair

- `directUpload.url` must become:
  - development-host reachable
  - usable by the local test operator
  - S3/MinIO-authorized for PUT

### 4.2 Confirm truth repair

- `POST /server/uploads/confirm` must not create `FileAsset` truth unless the
  upload transport truth has actually been verified.
- `objectKey` remains storage location only.
- `FileAsset` truth may exist only after confirmed transport success.

## 5. Explicit Rejection

- The following are explicitly rejected as insufficient:
  - only replacing `127.0.0.1` with another host string
  - only opening port `9000` but keeping unsigned PUT
  - only fixing signed URL generation but leaving `confirm` transport-blind
  - only documenting the risk without repairing the truth coupling

## 6. Next-stage Meaning

- The next stage is not a full new corridor round.
- The next stage is:
  - `项目发布最小走廊 / Server upload transport repair round`
- It remains a minimum-scope repair inside the current mainline.

## 7. Close Condition

- This blocker may be marked closed only when all of the following are true:
  - `upload init` returns a reachable direct-upload URL
  - the URL is authorized for real PUT
  - local operator direct upload succeeds through the approved development path
  - `confirm` returns `200 + fileAssetId` only after transport truth is present
  - forced negative-path validation proves `confirm` no longer succeeds after a
    failed or skipped PUT

## 8. Dispatch Conclusion

- Current stage decision:
  - `No-Go` for corridor closeout
  - `Go` for a narrow `Server upload transport repair round`
