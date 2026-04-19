---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the bounded frontend implementation dispatch for round-1 splitting of
  the publish workbench, limiting execution to apps/mobile entry removal, copy
  cleanup, guard rerouting, compatibility-shell thinning, and directly
  associated test updates only.
layer: L0 SSOT
freeze_date_local: 2026-04-14
based_on:
  - AGENTS.md
  - docs/00_ssot/project_publish_workbench_split_round1_frontend_stage_gate_checklist_addendum.md
  - docs/00_ssot/project_publish_workbench_split_round1_frontend_ruling_addendum.md
  - docs/04_frontend/project_publish_workbench_split_round1_frontend_consumption_addendum.md
  - docs/00_ssot/project_publish_workbench_split_round1_frontend_executable_change_table_addendum.md
---

# 《发布项目工作台拆分第一轮 frontend implementation dispatch》

## 1. Dispatch Objective

- 当前执行只允许：
  - 删除 workbench 一级入口和显性按钮
  - 清理 owner-facing / create / bid guard 文案
  - 把 workbench 收成兼容壳
  - 更新直接相关 Flutter tests

## 2. Allowed Directories

- `apps/mobile/lib/features/profile/presentation/**`
- `apps/mobile/lib/features/exhibition/presentation/**`
- `apps/mobile/lib/features/exhibition/navigation/**`
- `apps/mobile/lib/shell/navigation/**`
- `apps/mobile/test/**` 中直接相关测试

## 3. Explicit No-Go

- 不得改：
  - `apps/bff/**`
  - `apps/server/**`
  - `docs/01_contracts/**`
  - `docs/02_backend/**`
  - `docs/03_bff/**`
- 不得删：
  - `ExhibitionRoutes.workbench`
  - `app_router.dart` workbench route
- 不得改：
  - `我的项目详情` 中 `项目详情文书区`
  - `我的项目详情` 中 `公共资源下载区`

## 4. Acceptance Rule

- 必须满足：
  - profile 不再显示 workbench 一级入口
  - 首页空态不再显示 `回到发布项目工作台`
  - owner 公域详情不再显示 `打开发布项目工作台`
  - create / bid guard 文案和去向收口完成
  - workbench 兼容壳仍能打开且不破坏 `canCreateProject` 依赖
  - 直接相关 Flutter analyze / test 通过

## 5. Current Dispatch Meaning

- 当前 dispatch authoring 已成立。
- 当前允许：
  - 直接进入 bounded Flutter implementation
- 当前不意味着：
  - route final deletion
  - BFF/Server 改写
  - production release
