---
owner: Codex 总控
status: frozen
purpose: >
  Submit the formal stage gate checklist for freezing the current project-detail
  document zone and public-resource download zone boundary inside the same
  project-publish object cluster, without overclaiming a new app-facing
  resource center or a public attachment surface.
layer: L0 SSOT
freeze_date_local: 2026-04-14
based_on:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_authority_refresh_addendum.md
  - docs/00_ssot/project_publish_workbench_post_publish_materials_corridor_v1_truth_freeze_addendum.md
  - docs/01_contracts/project_publish_workbench_post_publish_materials_corridor_v1_contract_freeze_addendum.md
  - docs/02_backend/project_publish_workbench_post_publish_materials_corridor_v1_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/project_publish_workbench_post_publish_materials_corridor_v1_bff_surface_freeze_addendum.md
  - docs/04_frontend/project_publish_workbench_post_publish_materials_corridor_v1_frontend_consumption_freeze_addendum.md
  - docs/01_contracts/stage3_admin_package_d_template_config_contracts_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/presentation_support/project_attachment_support.dart
  - apps/server/src/modules/template_config/template-config-admin.controller.ts
---

# 《项目详情文书区与公共资源下载区阶段门禁核查表》

## 1. Stage Objective

- 当前唯一目标固定为：
  - 冻结 `项目详情文书区`
  - 冻结 `公共资源下载区`
  - 明确二者在当前项目发布对象簇中的 authority、边界、复用资产与非目标
- 当前明确非目标：
  - implementation
  - integration
  - release-prep
  - production release
  - Admin 模板配置扩写成 App 资源中心

## 2. Passed Gates

- `同对象门禁` 通过：
  - 当前对象明确属于既有 `project_chain` owner continuation 范围内的局部收口
  - 不构成新 board，不构成全仓泛扫
- `附件主链门禁` 通过：
  - 已存在成熟的 owner-private post-publish attachment freeze chain
  - `project_attachments`、`attachmentKind`、owner-private visibility 已有 formal truth
- `架构边界门禁` 通过：
  - `Flutter App -> BFF -> Server` 单通道不变
  - `Server` 继续是唯一 business truth owner
  - `BFF` 不拥有第二附件状态机
- `Admin 边界门禁` 通过：
  - 当前 `template_config` 已正式冻结为 `Admin -> Server Admin API` 治理面
  - 当前合同明确不开放 app-facing template consumption
- `现状识别门禁` 通过：
  - 当前 repo 已确认：
    - `项目详情文书区` 有既有 carrier
    - `公共资源下载区` 没有既有 app-facing list/download family

## 3. Failed Gates

- `项目详情文书区 combined authority 门禁` 未冻结：
  - 当前还没有把“项目详情文书区 = 既有 owner-private 正式附件区”的组合 authority 单独写死
- `公共资源下载区 truth 门禁` 未冻结：
  - 当前还没有把“公共资源下载区尚未形成 app-facing truth family”正式写死
- `跨层 no-overclaim 门禁` 未冻结：
  - 当前还没有把：
    - `template_config != App 公共资源下载区`
    - shared `file/access` != 公共资源目录
    - owner-private attachment != public resource
    正式收口到同一 freeze chain

## 4. Veto Gates

- 不得把 `项目详情文书区` 扩写成：
  - public attachment gallery
  - public project detail 下载中心
  - 第二 project detail truth family
- 不得把 `公共资源下载区` 写成：
  - 已有 app-facing capability
  - 已有 BFF path family
  - 已有 Server resource catalog truth
- 不得把 `template_config` 偷换成：
  - App 公共资源列表真值
  - BFF 可直接代理的下载目录
- 不得把 shared `GET /api/app/file/access` 偷换成：
  - 现成公共资源下载区
  - 现成资源目录 contract

## 5. Stage Decision

- `Go`：
  - 当前对象 docs-only freeze authoring
  - L0 / L2 / L3 / L4 / L5 一次性冻结
- `No-Go`：
  - 直接 implementation
  - 新 path authoring
  - Admin / BFF / Server runtime 改写
  - 公共资源下载区假落地

## 6. Next Unique Action

- 下一步唯一动作：
  - 输出《项目详情文书区与公共资源下载区总裁决补充单》
