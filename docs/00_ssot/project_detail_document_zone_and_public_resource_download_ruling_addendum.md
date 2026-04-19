---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the current authority for the project-detail document zone and the
  public-resource download zone under the same project-publish object cluster,
  formally reusing the existing owner-private attachment corridor while
  formally keeping the public-resource zone at future-handoff-only status.
layer: L0 SSOT
freeze_date_local: 2026-04-14
based_on:
  - AGENTS.md
  - docs/00_ssot/project_detail_document_zone_and_public_resource_download_stage_gate_checklist_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_authority_refresh_addendum.md
  - docs/00_ssot/project_publish_workbench_post_publish_materials_corridor_v1_truth_freeze_addendum.md
  - docs/00_ssot/project_publish_prepublish_relabel_and_confirmation_ruling_addendum.md
  - docs/01_contracts/project_publish_workbench_post_publish_materials_corridor_v1_contract_freeze_addendum.md
  - docs/01_contracts/stage3_admin_package_d_template_config_contracts_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/presentation_support/project_attachment_support.dart
  - apps/server/src/modules/template_config/template-config-admin.controller.ts
---

# 《项目详情文书区与公共资源下载区总裁决补充单》

## 1. Scope

- 本冻结单只覆盖：
  - `项目详情文书区`
  - `公共资源下载区`
- 本冻结单只服务于：
  - 当前项目发布对象簇内部的 owner-facing detail continuation
  - authority 归属
  - 可直接沿用资产
  - 当前未成形能力的 formal boundary
- 本冻结单不进入：
  - implementation
  - 新附件种类
  - 新资源目录 path
  - Admin 治理台 implementation

## 2. 总冻结结论

- `项目详情文书区` 当前正式锁定为：
  - 既有 same-object `owner-private post-publish attachment corridor`
  - 不是新对象
  - 不是 public detail 文件墙
- `公共资源下载区` 当前正式锁定为：
  - `future handoff only`
  - 当前 repo 中尚未形成 app-facing truth、BFF surface、Server resource catalog、Flutter consumption
  - 不是已实现 capability

## 3. 项目详情文书区 Authority

- 当前唯一 authority 固定为：
  - `docs/00_ssot/project_detail_document_zone_and_public_resource_download_ruling_addendum.md`
- 当前直接沿用的下层真源固定为：
  - `project_publish_workbench_post_publish_materials_corridor_v1_*`
    freeze chain
- 当前 `项目详情文书区` 的正确语义固定为：
  - owner 在 `我的项目详情` 中读取、补充、删除当前项目的正式私域文书资料
  - create success 与 project edit 继续只是 handoff / re-entry
  - public `project/detail` 不获得该区权限

## 4. 文书区最小语义 Freeze

- 当前文书区的唯一业务 carrier 继续固定为：
  - `project_attachments`
- 当前最小正式文书种类继续固定为：
  - `效果图`
  - `施工图`
  - `其他资料`
- 其中：
  - `展馆和展位图`
  - `展商手册`
  当前只允许作为 `其他资料` 的用户侧解释文案存在，
  不获得新的 truth kind、schema 字段或 path family。

## 5. 公共资源下载区 Freeze

- 当前 repo 中，`公共资源下载区` 不得被写成以下任一能力：
  - App 公共资源列表
  - BFF app-facing 资源目录
  - Server 公共资源 catalog truth
  - 已开放下载按钮集合
- 当前 `template_config` 的正式归属继续是：
  - `Admin -> Server Admin API` 模板与规则快照治理
  - 不是 Flutter App 公共资源下载区
- 当前 shared `GET /api/app/file/access` 的存在只说明：
  - 共享文件访问协议存在
  - 不说明当前对象已具备资源目录、列表、曝光范围、下载权限语义

## 6. 当前允许与禁止

### 6.1 当前允许

- 可以把 `我的项目详情` 里的正式附件区称为：
  - `项目详情文书区`
- 可以把 `效果图 / 施工图 / 其他资料` 的 owner-private 正式附件消费继续沿用
- 可以在后续单独 author 一个 `公共资源下载区` 专门 truth chain

### 6.2 当前禁止

- 不得把 `公共资源下载区` 直接写成：
  - 由 `template_config` 驱动
  - 由 `file/access` 单独驱动
  - 已在 Flutter App 中可下载
- 不得把 `项目详情文书区` 扩写成：
  - public attachment center
  - 公域资料下载区
  - 第二附件系统

## 7. 正式降级项

- 任何把 `展馆和展位图 / 展商手册` 直接写成独立 attachment truth kind 的旧讨论，
  当前一律降级为历史讨论，不具 authority。
- 任何把 `template_config` 或 shared `file/access` 直接解释成
  `公共资源下载区已具备` 的口头判断，
  当前一律降级为错误口径。

## 8. 当前唯一优先级

- 只要问题落在：
  - `项目详情文书区` 的归属
  - `其他资料` 与 `展馆和展位图 / 展商手册` 的关系
  - `公共资源下载区` 是否已存在
  - `template_config` 是否可以直接当作 App 资源中心
- 当前唯一最高优先级文书固定为：
  - `docs/00_ssot/project_detail_document_zone_and_public_resource_download_ruling_addendum.md`
