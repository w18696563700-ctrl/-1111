---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Server truth boundary for the project-detail document zone and the
  public-resource download zone, confirming that only the existing
  `project_attachments` truth family is active while no Server-side public
  resource catalog truth exists for the current object cluster.
layer: L3 Backend truth specs
freeze_date_local: 2026-04-14
inputs_canonical:
  - docs/00_ssot/project_detail_document_zone_and_public_resource_download_ruling_addendum.md
  - docs/02_backend/project_publish_workbench_post_publish_materials_corridor_v1_backend_truth_persistence_freeze_addendum.md
  - docs/02_backend/stage3_admin_package_d_template_config_backend_truth_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/server/src/modules/project
  - apps/server/src/modules/template_config
---

# 《项目详情文书区与公共资源下载区 backend truth freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `项目详情文书区` 的 Server 真值归属
  - `公共资源下载区` 的 Server 缺位边界
- 本冻结单不进入：
  - migration
  - implementation
  - Admin 页面改写

## 2. 项目详情文书区 Server Truth

- 当前 `项目详情文书区` 的唯一业务真值 carrier 继续固定为：
  - `project_attachments`
- 当前 `Server` 继续是以下真值的唯一 owner：
  - attachment create
  - attachment list
  - attachment delete
  - owner-private visibility
- 当前 `file_asset` 继续只是上传资产真值，
  不能替代 `project_attachments`。

## 3. 公共资源下载区 Server Boundary

- 当前 repo 中不存在以下任一 Server truth family：
  - `project_public_resources`
  - `app_resource_catalog`
  - `resource_download_registry`
  - `project_detail_public_downloads`
- 当前对象簇下不存在：
  - 公共资源列表 query truth
  - 公共资源上下架 command truth
  - 公共资源下载授权 truth

## 4. Template-config Boundary

- `template_config` 当前真值继续只服务于：
  - 模板与规则快照治理
  - Admin-only 管理视角
- `template_config` 当前不是：
  - Flutter App 资源目录真值
  - 项目详情公共资源下载真值
  - owner-facing 文书区真值

## 5. Shared File-access Boundary

- 即便 shared file access protocol 存在，
  当前也不能推出 `公共资源下载区` 已成立。
- 原因固定为：
  - 缺少当前对象下的资源目录 carrier
  - 缺少当前对象下的资源列表 read truth
  - 缺少当前对象下的资源曝光与权限真值

## 6. Current No-Go

- 当前不得在 Server 侧假定：
  - `template_config version` = 可下载公共资源
  - `project_attachments` = 公共资源区
  - `fileAssetId` 单独存在 = 资源下载区已可用

## 7. Formal Conclusion

- 当前 `项目详情文书区` 后端真值继续沿用既有
  `project_attachments` truth family。
- 当前 `公共资源下载区` 的后端真值结论固定为：
  - `no active Server truth family in current repo`
