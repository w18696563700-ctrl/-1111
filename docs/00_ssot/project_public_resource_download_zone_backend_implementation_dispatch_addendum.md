---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the backend execution prompt for the public resource download zone,
  limiting Server work to the read-only catalog truth, download reuse, and
  directly associated tests only.
layer: L0 SSOT
freeze_date_local: 2026-04-14
based_on:
  - AGENTS.md
  - docs/00_ssot/project_public_resource_download_zone_bounded_implementation_dispatch_bundle_addendum.md
  - docs/02_backend/project_public_resource_download_zone_backend_truth_addendum.md
  - docs/01_contracts/project_public_resource_download_zone_contract_freeze_addendum.md
---

# 《公共资源下载区 backend implementation dispatch》

## 1. Dispatch Objective

- 当前 backend 执行只允许：
  - 落地 `GET /server/projects/public-resources`
  - 落地 `project_public_resources` read truth carrier
  - 复用 shared file-access download 锚点
  - 更新直接相关 Server tests

## 2. Allowed Directories

- `apps/server/src/modules/project/**`
- `apps/server/src/modules/file/**` 中直接相关最小读侧或下载复用文件
- `apps/server/src/core/migrations/**` 仅在 carrier 落地确实需要时可最小新增
- `apps/server/test/**` 中直接相关测试

## 3. Explicit No-Go

- 不得改：
  - `apps/server/src/modules/template_config/**`
  - `apps/server/src/modules/exhibition_workbench/**`
  - `apps/server/src/modules/upload/**` 中与本对象无关的路径
- 不得把：
  - `template_config`
  - `file_asset`
  直接偷换成目录 truth
- 不得为当前对象 author：
  - upload
  - delete
  - archive
  - anonymous public read

## 4. Acceptance Rule

- `GET /server/projects/public-resources` 成立
- 只返回 contract freeze 允许的最小字段
- 资源目录 truth 与下载协议分层成立
- 直接相关 Server build 和 tests 通过

## 5. Current Dispatch Meaning

- 当前允许：
  - 直接进入 bounded backend implementation
- 当前不意味着：
  - BFF 可先于 backend 发送
  - frontend 可在 backend receipt 前开始
