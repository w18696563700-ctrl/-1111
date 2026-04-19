---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the contract boundary for the project-detail document zone and the
  public-resource download zone, formally reusing only the existing
  owner-private project-attachment family while explicitly freezing that no
  app-facing public-resource path family exists in the current object cluster.
layer: L2 Contracts
freeze_date_local: 2026-04-14
inputs_canonical:
  - docs/00_ssot/project_detail_document_zone_and_public_resource_download_ruling_addendum.md
  - docs/01_contracts/project_publish_workbench_post_publish_materials_corridor_v1_contract_freeze_addendum.md
  - docs/01_contracts/stage3_admin_package_d_template_config_contracts_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/00_ssot/source_of_truth_map.md
---

# 《项目详情文书区与公共资源下载区 contract freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `项目详情文书区`
  - `公共资源下载区`
- 本冻结单不进入：
  - 新 schema
  - 新 route
  - implementation

## 2. 项目详情文书区 Canonical Contract

- 当前 `项目详情文书区` 唯一合法 app-facing 路由族继续固定为：
  - `GET /api/app/my/projects/{projectId}/attachments`
  - `POST /api/app/my/projects/{projectId}/attachments`
  - `DELETE /api/app/my/projects/{projectId}/attachments/{attachmentId}`
- 当前 contract family 继续只承接：
  - owner-private
  - post-publish
  - project-owned attachment truth
- public `project/detail` 当前不得新增：
  - `/api/app/project/detail/documents`
  - `/api/app/project/detail/attachments`
  - `/api/app/project/public-resources`

## 3. 文书种类 Contract Freeze

- 当前 attachment kind 继续固定为：
  - `effect_image`
  - `construction_doc`
  - `other_material`
- 当前 contract 继续不新增：
  - `booth_layout`
  - `exhibitor_manual`
  - `public_resource`
  - `resource_template`
- `展馆和展位图 / 展商手册` 当前只允许落在：
  - `other_material`
  的用户文案解释层，不进入 contract enum。

## 4. 公共资源下载区 Contract Freeze

- 当前对象簇下，`公共资源下载区` 没有合法 app-facing canonical path。
- 当前正式不成立的 path family 包括：
  - `/api/app/project/resources`
  - `/api/app/project/public-resources`
  - `/api/app/my/projects/{projectId}/resources`
  - 任意 `/api/app/template*`
- `GET /api/app/file/access` 当前不得被单独解释为：
  - 公共资源下载区 contract
  - 资源目录 contract
  - 资源列表 contract

## 5. Admin Contract Boundary

- `template_config` 当前继续只属于：
  - `GET /server/admin/config/templates*`
  - `POST /server/admin/config/templates*`
  的 Admin-only contract family
- 当前明确不开放：
  - app-facing template consumption
  - app-facing resource download family

## 6. Error And Visibility Boundary

- `项目详情文书区` 继续服从既有 owner-private attachment error family。
- `公共资源下载区` 当前不 author 独立错误码，
  因为当前没有可成立的 app-facing capability。
- 当前 visibility freeze 固定为：
  - owner-private attachment != public resource
  - public resource zone != owner-private attachment list

## 7. Formal Conclusion

- 当前 `项目详情文书区` contract authority 继续沿用既有
  `project attachment` canonical family。
- 当前 `公共资源下载区` contract authority 结论固定为：
  - `not materialized in current repo`
  - `future handoff only`
