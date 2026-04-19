---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the L0 ruling for round-1 frontend-only splitting of the publish
  workbench, making my-project the primary owner continuation entry while
  downgrading workbench into a compatibility shell without deleting its route
  or breaking create eligibility checks.
layer: L0 SSOT
freeze_date_local: 2026-04-14
based_on:
  - AGENTS.md
  - docs/00_ssot/project_publish_workbench_split_round1_frontend_stage_gate_checklist_addendum.md
  - docs/00_ssot/project_publish_workbench_split_round1_frontend_executable_change_table_addendum.md
  - docs/00_ssot/project_detail_document_zone_and_public_resource_download_ruling_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_ruling_addendum.md
  - apps/mobile/lib/features/profile/presentation/profile_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_page.dart
  - apps/server/src/modules/exhibition_workbench/exhibition-workbench.query.service.ts
---

# 《发布项目工作台拆分第一轮前端总裁决补充单》

## 1. Scope

- 本冻结单只覆盖：
  - `apps/mobile` 中 owner-facing 入口
  - owner 公域详情 CTA
  - 创建页与 bid guard 文案/去向
  - workbench 兼容壳
- 本冻结单不进入：
  - route 删除
  - `Server/BFF/contracts`
  - 文书区和公共资源区实现

## 2. 总冻结结论

- 当前 owner continuation 主入口正式固定为：
  - `我的项目`
- 当前 `发布项目工作台` 在第一轮正式降级为：
  - `compatibility shell`
  - 不是 owner-facing 一级入口
  - 不是文书区/公共资源区主面

## 3. 入口与可见性 Freeze

- profile 中当前正式移除：
  - `发布项目工作台` 一级入口
- 首页空态当前正式移除：
  - `回到发布项目工作台`
  作为空态按钮
- owner 公域详情当前正式移除：
  - `打开发布项目工作台`
  次按钮

## 4. 文案与导流 Freeze

- 当前 owner-facing 文案统一收口为：
  - 继续处理进入 `我的项目`
  - 创建资格查看当前创建资格 / 认证状态 / 组织状态
- 当前 bid guard 文案统一要求：
  - 不再把供应商侧错误导流到发布方 workbench
  - 按 blocker 类型回到：
    - 登录
    - 组织承接
    - 认证状态
    - 项目详情
    - 项目展示
    - 我的项目

## 5. Compatibility-shell Freeze

- `/exhibition/workbench` 当前第一轮必须保留：
  - route
  - title registration
  - summary query dependence
- 但当前第一轮必须降成：
  - 最小兼容壳
  - 不再渲染四容器说明墙
  - 不再渲染重讲解 copy
  - 仅保留最小续接入口和刷新承接

## 6. Hard Boundary

- 当前第一轮不得改：
  - `project_create_page.dart` 读取 `canCreateProject`
  - `exhibition_workbench.query.service.ts`
  - `我的项目详情` 中 `项目详情文书区`
  - `我的项目详情` 中 `公共资源下载区`

## 7. 当前唯一优先级

- 只要问题落在：
  - workbench owner 一级入口拆分
  - workbench 文案降级
  - workbench 薄兼容壳
  - owner/bid/create 的去向收口
- 当前唯一最高优先级文书固定为：
  - `docs/00_ssot/project_publish_workbench_split_round1_frontend_ruling_addendum.md`
