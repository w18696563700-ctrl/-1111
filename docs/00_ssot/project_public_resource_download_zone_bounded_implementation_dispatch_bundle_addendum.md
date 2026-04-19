---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the bounded implementation dispatch bundle for the public resource
  download zone, fixing role order, allowed directories, acceptance rule, and
  retained non-goals before any real role execution prompt is issued.
layer: L0 SSOT
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_public_resource_download_zone_implementation_dispatch_stage_gate_checklist_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_ruling_addendum.md
  - docs/01_contracts/project_public_resource_download_zone_contract_freeze_addendum.md
  - docs/02_backend/project_public_resource_download_zone_backend_truth_addendum.md
  - docs/03_bff/project_public_resource_download_zone_bff_surface_addendum.md
  - docs/04_frontend/project_public_resource_download_zone_frontend_consumption_addendum.md
---

# 《公共资源下载区 bounded implementation dispatch bundle》

## 1. Execution Order

- 当前执行顺序固定为：
  - backend first
  - BFF second
  - frontend third
  - result verification after frontend receipt
- 当前不允许：
  - frontend first
  - BFF before backend
  - release-before-verification

## 2. Allowed Scope

- 当前 bounded implementation 只允许覆盖：
  - read-only resource catalog
  - shared file-access download reuse
  - owner-facing `我的项目详情` consumption
  - 直接相关测试

## 3. Allowed Directories By Role

- backend：
  - `apps/server/src/modules/project/**`
  - `apps/server/src/modules/file/**` 中直接相关最小读侧或下载复用文件
  - `apps/server/src/core/migrations/**` 仅在 carrier 落地确实需要时可最小新增
  - `apps/server/test/**` 中直接相关测试
- BFF：
  - `apps/bff/src/routes/project/**`
  - `apps/bff/src/routes/file/**` 中直接相关最小复用文件
  - `apps/bff/test/**` 中直接相关测试
- frontend：
  - `apps/mobile/lib/features/exhibition/data/**`
  - `apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/**` 中直接相关最小支撑文件
  - `apps/mobile/test/**` 中直接相关测试

## 4. Acceptance Rule

- backend receipt 必须满足：
  - `GET /server/projects/public-resources` 成立
  - resource catalog 与 `file_asset` truth 分层成立
  - 不透出 `objectKey`
- BFF receipt 必须满足：
  - `GET /api/app/project/public-resources` 成立
  - 只做映射、shaping、error normalization
- frontend receipt 必须满足：
  - `我的项目详情` 出现 `公共资源下载区`
  - `项目详情文书区` 与 `公共资源下载区` 分区成立
  - 下载继续复用 shared file access

## 5. Explicit No-Go

- 不得改：
  - `apps/admin/**`
  - `docs/01_contracts/stage3_admin_package_d_template_config_contracts_addendum.md`
  - `template_config` 既有 Admin 治理链
- 不得新增：
  - upload / delete / edit resource action
  - workbench resource entry
  - public detail resource entry
  - second file access protocol

## 6. Current Bundle Meaning

- 当前 bundle 已成立。
- 当前允许：
  - 进入 backend / BFF / frontend role execution prompt
- 当前不意味着：
  - result verification pass
  - integration approval
  - production release
