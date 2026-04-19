---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the BFF execution prompt for the public resource download zone,
  limiting BFF work to the single app-facing mapping, shaping, normalization,
  and directly associated tests only.
layer: L0 SSOT
freeze_date_local: 2026-04-14
based_on:
  - AGENTS.md
  - docs/00_ssot/project_public_resource_download_zone_bounded_implementation_dispatch_bundle_addendum.md
  - docs/03_bff/project_public_resource_download_zone_bff_surface_addendum.md
  - docs/01_contracts/project_public_resource_download_zone_contract_freeze_addendum.md
---

# 《公共资源下载区 BFF implementation dispatch》

## 1. Dispatch Objective

- 当前 BFF 执行只允许：
  - 落地 `GET /api/app/project/public-resources`
  - 映射到 `GET /server/projects/public-resources`
  - 做最小 response shaping 和 controlled error normalization
  - 更新直接相关 BFF tests

## 2. Allowed Directories

- `apps/bff/src/routes/project/**`
- `apps/bff/src/routes/file/**` 中直接相关最小复用文件
- `apps/bff/test/**` 中直接相关测试

## 3. Explicit No-Go

- 不得改：
  - `apps/bff/src/routes/admin/**`
  - `apps/bff/src/routes/exhibition_workbench/**`
- 不得新增：
  - `/api/app/project/public-resources/download`
  - `/api/app/public/resources`
  - 任意 template-config proxy path
- 不得把 BFF 写成：
  - 资源目录真值 owner
  - 第二下载系统 owner

## 4. Acceptance Rule

- app-facing path 成立
- 只返回 contract freeze 允许的字段
- 错误归一受控
- 直接相关 BFF build 和 tests 通过

## 5. Current Dispatch Meaning

- 当前允许：
  - 在 backend receipt 通过后进入 bounded BFF implementation
- 当前不意味着：
  - frontend 可先于 BFF 发送
  - result verification 已开始
