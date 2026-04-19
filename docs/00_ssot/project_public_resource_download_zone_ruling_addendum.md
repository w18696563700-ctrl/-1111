---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the dedicated authority for the public resource download zone under
  the same project-publish object cluster, turning the earlier
  future-handoff-only judgment into a concrete docs-only truth chain while
  keeping the zone separate from owner-private attachments, public showcase
  detail, and Admin template governance.
layer: L0 SSOT
freeze_date_local: 2026-04-14
based_on:
  - AGENTS.md
  - docs/00_ssot/project_public_resource_download_zone_stage_gate_checklist_addendum.md
  - docs/00_ssot/project_detail_document_zone_and_public_resource_download_ruling_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_authority_refresh_addendum.md
  - docs/01_contracts/stage3_admin_package_d_template_config_contracts_addendum.md
  - docs/01_contracts/forum_published_attachment_access_contracts_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《公共资源下载区总裁决补充单》

## 1. Scope

- 本冻结单只覆盖：
  - `公共资源下载区`
- 本冻结单只服务于：
  - owner-facing `我的项目详情`
  - app-shared read-only resource catalog
  - 下载协议与资源目录的分层
- 本冻结单不进入：
  - owner-private 文书区
  - public `项目展示详情`
  - workbench summary
  - Admin write-side implementation

## 2. 总冻结结论

- `公共资源下载区` 当前正式冻结为：
  - `我的项目详情` 下的 bounded read-only zone
  - `app_shared` 共享资源，不是 owner-private
  - download-only first，实际文件下载复用 shared `file/access`
- 当前 `公共` 的正式含义固定为：
  - 对 admitted App actor shared
  - 不是匿名 public-web
  - 不是 public showcase detail

## 3. 位置与入口 Freeze

- 当前 zone 的唯一 owner-facing 主入口固定为：
  - `我的项目详情`
- 当前 zone 不进入：
  - `发布项目工作台`
  - public `项目展示详情`
  - create success 页
  - project edit 页

## 4. 与项目详情文书区的关系

- `项目详情文书区` 继续是：
  - owner-private
  - project-owned
  - attachment truth
- `公共资源下载区` 当前正式不是：
  - attachment truth
  - upload/bind/delete family
  - owner-private 资料区
- 二者当前必须同时成立：
  - 文书区 = 私域项目资料
  - 公共资源区 = app-shared 参考资料下载

## 5. 最小资源分类 Freeze

- 当前资源分类固定为：
  - `合同模板`
  - `流程图与说明`
  - `公共资料`
- 这些分类当前只承接：
  - admin 发布后的共享资源 read truth
  - download-only first 的 Flutter 消费
- 当前不进入：
  - 上传
  - 删除
  - owner edit
  - project-specific binding

## 6. 与 template_config 和 file/access 的关系

- `template_config` 当前继续只是：
  - Admin 模板与规则快照治理
  - 不是 App 公共资源 truth
- shared `GET /api/app/file/access` 当前继续只是：
  - 文件访问协议
  - 不是资源目录 truth
- 当前正式关系固定为：
  - 资源目录 truth 先成立
  - file/access 后用于下载

## 7. 正式降级项

- [project_detail_document_zone_and_public_resource_download_ruling_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/project_detail_document_zone_and_public_resource_download_ruling_addendum.md)
  中关于 `公共资源下载区 = future handoff only` 的条款，
  当前正式降级为更早一轮的 absence-only 结论。
- 上述更早结论在以下问题上不再拥有最高优先级：
  - zone 是否存在
  - zone 的 entry face
  - zone 的 category family
  - zone 的 canonical path family

## 8. 当前唯一优先级

- 只要问题落在：
  - `公共资源下载区` 的存在性
  - 与 `项目详情文书区` 的分层
  - 与 `template_config` 的关系
  - 与 shared `file/access` 的关系
  - owner-facing 入口位置
- 当前唯一最高优先级文书固定为：
  - `docs/00_ssot/project_public_resource_download_zone_ruling_addendum.md`
