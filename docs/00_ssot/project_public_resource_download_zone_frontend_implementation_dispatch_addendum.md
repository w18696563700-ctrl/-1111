---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the frontend execution prompt for the public resource download zone,
  limiting Flutter work to my-project-detail consumption, download CTA
  handling, and directly associated tests only.
layer: L0 SSOT
freeze_date_local: 2026-04-14
based_on:
  - AGENTS.md
  - docs/00_ssot/project_public_resource_download_zone_bounded_implementation_dispatch_bundle_addendum.md
  - docs/04_frontend/project_public_resource_download_zone_frontend_consumption_addendum.md
  - docs/01_contracts/project_public_resource_download_zone_contract_freeze_addendum.md
---

# 《公共资源下载区 frontend implementation dispatch》

## 1. Dispatch Objective

- 当前 frontend 执行只允许：
  - 在 `我的项目详情` 落地 `公共资源下载区`
  - 分类展示 `合同模板 / 流程图与说明 / 公共资料`
  - 通过 shared file-access 处理下载 CTA
  - 更新直接相关 Flutter tests

## 2. Allowed Directories

- `apps/mobile/lib/features/exhibition/data/**`
- `apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/**` 中直接相关最小支撑文件
- `apps/mobile/test/**` 中直接相关测试

## 3. Explicit No-Go

- 不得改：
  - `apps/mobile/lib/features/exhibition/presentation/exhibition_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_*`
  - public `项目展示详情` 相关文件
- 不得新增：
  - 上传按钮
  - 删除按钮
  - template-config 直出文案
  - 本地硬编码伪资源卡

## 4. Acceptance Rule

- `我的项目详情` 出现 `公共资源下载区`
- `项目详情文书区` 与 `公共资源下载区` 分区清楚
- 空态、失败态、下载态受控
- 直接相关 Flutter analyze / test 通过

## 5. Current Dispatch Meaning

- 当前允许：
  - 在 BFF receipt 通过后进入 bounded Flutter implementation
- 当前不意味着：
  - 联动发布批准
  - production release
