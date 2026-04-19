---
owner: Codex 总控
status: frozen
purpose: >
  Record the remote BFF cloud-runtime alignment receipt for the public resource
  download zone, freezing that the app-facing catalog path is now aligned on
  `47.108.180.198:3201` while the actual shared file-access download proof
  remains blocked upstream on the remote Server side.
layer: L0 SSOT
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_public_resource_download_zone_bff_cloud_runtime_alignment_dispatch_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_server_cloud_runtime_alignment_receipt_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_cloud_runtime_integration_validation_review_conclusion_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_bff_execution_receipt_addendum.md
  - docs/03_bff/project_public_resource_download_zone_bff_surface_addendum.md
  - docs/01_contracts/project_public_resource_download_zone_contract_freeze_addendum.md
---

# 《公共资源下载区 BFF Cloud Runtime Alignment 回执单》

## 1. Current Scope

- 当前回执对象：
  - `公共资源下载区`
  - `remote BFF cloud runtime alignment`
- 当前远端目标固定为：
  - host:
    - `47.108.180.198`
  - runtime root:
    - `/srv/workspaces/exhibition-infra-monorepo/apps/bff`
  - active port:
    - `3201`

## 2. Exact Root Cause

- 当前根因固定为：
  - remote active `3201` 先前绑定的是旧 skeleton dist：
    - `node dist/main`
  - active process 并未使用已存在的较新 `current`
  - `.isolated/bff-3201.pid` 先前指向死 pid，导致 `active process / dist / current / pid` 漂移
  - 切到 `node current/main.js` 的第一次尝试又被旧版 generated contracts 阻断：
    - `Frozen app api path missing from generated contracts: /api/app/order/create`
  - 为保持 shared reuse 不变，remote BFF app-facing 侧还补上了：
    - `GET /api/app/file/access`

## 3. Runtime Alignment Result

- 当前已对齐结果固定为：
  - remote active `3201` 已切到：
    - `node current/main.js`
  - active pid 已对齐：
    - `483135`
  - `current` 已指向：
    - `/srv/workspaces/exhibition-infra-monorepo/apps/bff/dist/apps/bff/src`
  - 启动日志已映射：
    - `POST /api/app/auth/otp/send`
    - `POST /api/app/auth/otp/login`
    - `GET /api/app/project/public-resources`
    - `GET /api/app/file/access`

## 4. Response Proof

- 当前 app-facing route proof 已成立：
  - no-token:
    - `GET http://127.0.0.1:3201/api/app/project/public-resources = 401 AUTH_SESSION_INVALID`
    - 当前已不再是 raw `Cannot GET`
  - with-token:
    - `GET http://127.0.0.1:3201/api/app/project/public-resources = 200`
- 当前最小 shaping 已成立：
  - `resourceId`
  - `resourceCategory`
  - `title`
  - `summary`
  - `fileAssetId`
  - `fileName`
  - `mimeType`
  - `visibility`
  - `sortOrder`
  - `publishedAt`
- 当前还已证明：
  - `visibility=app_shared`
  - `objectKey` 未泄露
  - actual upstream 命中：
    - `GET /server/projects/public-resources`

## 5. Residual Blocker

- 当前仍保留一个 server-side 残留阻断：
  - `GET /server/file/access` 当前仍是 raw `404`
  - 因此 `/api/app/file/access` 当前只能证明：
    - shared `file/access` reuse path retained
  - 当前仍不能写成：
    - remote actual download proof passed
- 当前还保留一个次级残留：
  - `POST /api/app/auth/otp/send = 503 AUTH_RESOURCE_UNAVAILABLE`
  - 它不阻断当前 BFF catalog path receipt，但说明远端 auth provider material 仍不完整

## 6. Formal Receipt Conclusion

- 当前正式回执结论固定为：
  - `BFF cloud runtime alignment = PASS`
  - `remote active 3201 catalog path proof = PASS`
  - `remote app-facing minimum shaping proof = PASS`
  - `shared file/access reuse retained = PASS`
- 当前不等于：
  - remote actual file download proof passed
  - remote cloud integration validation passed
  - `release-prep`

## 7. Next Unique Action

- 下一轮唯一动作：
  - 先进入《公共资源下载区｜Server shared file-access cloud runtime alignment》
  - 只有在该 receipt 通过后，才允许重做远端 `cloud runtime integration validation`
