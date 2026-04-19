---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the dedicated app-facing contract for the public resource download
  zone, introducing a single read-only catalog path and reusing shared
  `file/access` for actual downloads without proxying Admin template-config
  semantics into Flutter App.
layer: L2 Contracts
freeze_date_local: 2026-04-14
inputs_canonical:
  - docs/00_ssot/project_public_resource_download_zone_ruling_addendum.md
  - docs/01_contracts/stage3_admin_package_d_template_config_contracts_addendum.md
  - docs/01_contracts/forum_published_attachment_access_contracts_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/00_ssot/source_of_truth_map.md
---

# 《公共资源下载区 contract freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `公共资源下载区` app-facing read contract
  - shared `file/access` download reuse rule
- 本冻结单不进入：
  - Admin write-side path
  - upload family
  - project attachment family

## 2. Canonical App-facing Path Family

- 当前 `公共资源下载区` 唯一合法 app-facing 目录路径固定为：
  - `GET /api/app/project/public-resources`
- 当前 `公共资源下载区` 的实际下载协议固定复用：
  - `GET /api/app/file/access`
    with:
    - `fileAssetId`
    - `mode=download`
- 当前不得新增：
  - `/api/app/project/resources/download`
  - `/api/app/public/resources`
  - 任意 `/api/app/template*`

## 3. List Response Freeze

- `GET /api/app/project/public-resources` 的最小响应固定为：
  - `resources[]`
- 每个 resource item 最小字段固定为：
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
- `visibility` 当前固定返回：
  - `app_shared`

## 4. Resource Category Contract Freeze

- `resourceCategory` 当前固定为：
  - `contract_template`
  - `process_guide`
  - `other_resource`
- 用户侧中文解释固定为：
  - `contract_template` => `合同模板`
  - `process_guide` => `流程图与说明`
  - `other_resource` => `公共资料`

## 5. MIME Boundary

- 当前允许 MIME 固定为：
  - `image/png`
  - `image/jpeg`
  - `image/webp`
  - `application/pdf`
  - `application/msword`
  - `application/vnd.openxmlformats-officedocument.wordprocessingml.document`
- 当前不进入：
  - CAD
  - ZIP
  - 视频
  - 可执行文件

## 6. Template-config Boundary

- `template_config` 当前不得直接暴露为：
  - `GET /api/app/project/public-resources`
    的 response shape
- 当前 contract 只冻结：
  - app-facing read catalog
  - shared file access reuse
- 当前不冻结：
  - Admin 发布/归档路径
  - template version compare

## 7. Hard Boundary

- `公共资源下载区` 不得读取：
  - owner-private `project_attachments`
  - public `project/detail` attachment refs
- `公共资源下载区` 不得成为：
  - 第二 project detail truth family
  - 第二 file access protocol
  - 第二 template governance surface

## 8. Formal Conclusion

- 当前 `公共资源下载区` contract authority 正式冻结为：
  - `GET /api/app/project/public-resources`
  - shared `GET /api/app/file/access` with `mode=download`
