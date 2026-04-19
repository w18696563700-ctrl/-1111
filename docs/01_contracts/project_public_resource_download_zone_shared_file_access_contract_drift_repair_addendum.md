---
owner: Codex 总控
status: frozen
purpose: >
  Repair the public resource download zone contract drift by formalizing the
  shared app-facing `GET /api/app/file/access` path and its minimum response
  schema directly in `openapi.yaml`, so the release-prep gate no longer relies
  on descriptive mentions alone.
layer: L2 Contracts
freeze_date_local: 2026-04-14
inputs_canonical:
  - docs/00_ssot/project_public_resource_download_zone_release_prep_gate_review_conclusion_addendum.md
  - docs/01_contracts/project_public_resource_download_zone_contract_freeze_addendum.md
  - docs/01_contracts/forum_published_attachment_access_contracts_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/bff/src/routes/file/app-file-upload.controller.ts
  - apps/bff/src/routes/file/file.service.ts
---

# 《公共资源下载区 shared file-access contract drift repair》

## 1. Current Repair Scope

- 本修复只覆盖：
  - `GET /api/app/file/access`
  - `fileAssetId + mode` query authority
  - 最小下载访问响应 schema
- 本修复不扩到：
  - 新下载协议
  - upload family 改写
  - Admin 资源治理
  - 其它对象链

## 2. Drift Statement

- 当前 drift 已确认为：
  - contract freeze 和 frontend/bff/runtime 都要求实际下载复用：
    - `GET /api/app/file/access`
  - 但 `openapi.yaml` 先前未显式登记该 path definition
- 当前 drift 不是：
  - route 不存在
  - runtime proof 不存在
  - 第二下载系统需求

## 3. Repaired Authority

- 当前正式补齐的 canonical path 为：
  - `GET /api/app/file/access`
- 最小 query 参数固定为：
  - `fileAssetId`
  - `mode`
- 当前 `mode` 至少承认：
  - `download`
- 最小响应 authority 固定为：
  - `fileAssetId`
  - `mode`
  - `accessUrl`
  - `fileName`
  - `mimeType`
  - `expiresAt`
  - optional `contentLengthBytes`
- 当前仍明确禁止：
  - `objectKey` 成为 contract truth

## 4. Relation To Public Resource Zone

- `公共资源下载区` 当前继续只拥有：
  - `GET /api/app/project/public-resources`
    for catalog truth
- 实际下载继续只复用：
  - `GET /api/app/file/access`
- 当前不新增：
  - `/api/app/project/public-resources/download`
  - 第二 file-access family

## 5. Formal Conclusion

- 当前 contract drift repair 已完成：
  - `openapi.yaml` 现已补齐 `GET /api/app/file/access` path authority
  - `release-prep gate` 先前基于该缺口形成的 veto basis 已被修复
- 当前下一步唯一动作：
  - 重做《公共资源下载区 release-prep gate judgment》
