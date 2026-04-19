---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Server truth boundary for the public resource download zone,
  introducing a single read-only catalog carrier while keeping Admin authoring
  and shared file-access transport clearly separated.
layer: L3 Backend truth specs
freeze_date_local: 2026-04-14
inputs_canonical:
  - docs/00_ssot/project_public_resource_download_zone_ruling_addendum.md
  - docs/01_contracts/project_public_resource_download_zone_contract_freeze_addendum.md
  - docs/02_backend/stage3_admin_package_d_template_config_backend_truth_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/server/src/modules/template_config
  - apps/server/src/modules/upload
---

# 《公共资源下载区 backend truth freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `公共资源下载区` 的 Server read truth
  - 资源目录 truth 与 file access transport 的分层
- 本冻结单不进入：
  - Admin write-side implementation
  - migration
  - Flutter implementation

## 2. Server Canonical Truth Family

- 当前 `公共资源下载区` 的唯一合法 Server read 路由固定为：
  - `GET /server/projects/public-resources`
- 当前路径只服务于：
  - project publish domain
  - app-shared resource catalog
  - read-only continuation support

## 3. Truth Carrier Freeze

- 当前唯一合法业务 carrier 固定为：
  - `project_public_resources`
- 当前最小 canonical 字段固定为：
  - `resource_id`
  - `resource_category`
  - `title`
  - `summary`
  - `file_asset_id`
  - `file_name`
  - `mime_type`
  - `visibility`
  - `sort_order`
  - `published_at`
  - `published_by`
- `visibility` 当前固定为：
  - `app_shared`

## 4. Ownership Split Freeze

- `Server` 是当前资源目录 truth 的唯一 owner。
- `file_asset` 继续是文件资产 truth。
- 二者关系固定为：
  - `project_public_resources` 持有资源目录与分类语义
  - `file_asset` 持有实际文件访问锚点
- 当前不得把 `file_asset` 单独当成资源目录 truth。

## 5. Template-config Boundary

- `template_config` 当前继续只是：
  - 模板/规则快照治理 truth
- `template_config` 当前不是：
  - `project_public_resources` carrier
  - App 目录 read model
- 若未来资源由 Admin 发布，
  也必须通过单独治理链把发布结果 materialize 到
  `project_public_resources`，不得直接把 template version row 透传给 App。

## 6. Download Boundary

- 当前资源下载继续复用 shared file access protocol。
- `GET /server/projects/public-resources` 只返回目录 truth，
  不直接返回 binary，不直接下发 `objectKey`。
- 当前实际文件下载必须走：
  - shared file access

## 7. Current No-Go

- 当前不得 author：
  - app write-side delete/archive
  - project-specific resource binding
  - workbench-owned resource truth
- 当前不 author migration 和 implementation，只冻结唯一 truth 模型。

## 8. Formal Conclusion

- 当前 `公共资源下载区` 的 Server truth authority 正式冻结为：
  - `GET /server/projects/public-resources`
  - `project_public_resources` as the unique catalog carrier
