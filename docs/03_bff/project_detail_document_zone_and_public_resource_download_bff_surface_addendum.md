---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the BFF-side surface boundary for the project-detail document zone and
  the public-resource download zone, keeping only the existing owner-private
  attachment mapping while explicitly forbidding any BFF-composed public
  resource center or template-config proxy for the current object cluster.
layer: L4 BFF
freeze_date_local: 2026-04-14
inputs_canonical:
  - docs/00_ssot/project_detail_document_zone_and_public_resource_download_ruling_addendum.md
  - docs/03_bff/project_publish_workbench_post_publish_materials_corridor_v1_bff_surface_freeze_addendum.md
  - docs/01_contracts/stage3_admin_package_d_template_config_contracts_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/bff/src/routes/my_project
  - apps/bff/src/routes/file
---

# 《项目详情文书区与公共资源下载区 BFF surface freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `项目详情文书区` 的 BFF app-facing 映射
  - `公共资源下载区` 的 BFF 禁止扩写边界
- 本冻结单不进入：
  - implementation
  - 新 path
  - BFF 第二目录系统

## 2. 项目详情文书区 BFF Surface

- 当前唯一合法 BFF app-facing 映射继续固定为：
  - `GET /api/app/my/projects/{projectId}/attachments`
  - `POST /api/app/my/projects/{projectId}/attachments`
  - `DELETE /api/app/my/projects/{projectId}/attachments/{attachmentId}`
- BFF 当前继续只做：
  - path mapping
  - payload shaping
  - error normalization
- BFF 当前继续不拥有：
  - attachment truth
  - attachment state machine

## 3. 公共资源下载区 BFF Boundary

- 当前对象簇下，BFF 不得新增：
  - `/api/app/project/resources`
  - `/api/app/project/public-resources`
  - `/api/app/template*`
  - 任何以静态拼装、硬编码、Admin 转发方式形成的伪资源目录
- BFF 当前不得把 shared `file/access` 包装成：
  - 资源列表
  - 资源下载区
  - 公共资源目录

## 4. Template-config Proxy Prohibition

- BFF 当前不得代理：
  - `/server/admin/config/templates*`
  到 App 侧
- BFF 当前不得把 Admin template/version/grouping 数据
  重写成 Flutter 可消费的公共资源下载列表。

## 5. Error Surface Boundary

- `项目详情文书区` 继续沿用既有 owner-private attachment error normalization。
- `公共资源下载区` 当前不 author 新的 BFF error family，
  因为当前没有合法 app-facing capability。

## 6. Formal Conclusion

- 当前 `项目详情文书区` 的 BFF surface authority 继续沿用既有
  `my-project attachment` mapping family。
- 当前 `公共资源下载区` 的 BFF surface authority 结论固定为：
  - `absent in current BFF`
  - `future handoff only`
