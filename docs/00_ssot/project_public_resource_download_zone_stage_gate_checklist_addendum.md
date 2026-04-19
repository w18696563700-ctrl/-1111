---
owner: Codex 总控
status: frozen
purpose: >
  Submit the formal stage gate checklist for authoring the dedicated public
  resource download zone truth chain under the same project-publish object
  cluster, without collapsing it into owner-private attachments, workbench
  summary, or Admin template governance.
layer: L0 SSOT
freeze_date_local: 2026-04-14
based_on:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/project_detail_document_zone_and_public_resource_download_ruling_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_authority_refresh_addendum.md
  - docs/01_contracts/stage3_admin_package_d_template_config_contracts_addendum.md
  - docs/01_contracts/forum_published_attachment_access_contracts_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/presentation_support/project_attachment_support.dart
  - apps/server/src/modules/template_config/template-config-admin.controller.ts
  - apps/bff/src/routes/file/file.service.ts
---

# 《公共资源下载区阶段门禁核查表》

## 1. Stage Objective

- 当前唯一目标固定为：
  - author `公共资源下载区` dedicated truth chain
  - 明确其与 `项目详情文书区`、`template_config`、shared `file/access` 的边界
  - 冻结当前唯一合法 read-only app-facing 语义
- 当前明确非目标：
  - implementation
  - Admin write-side implementation
  - workbench 改造
  - release-prep
  - production release

## 2. Passed Gates

- `同对象门禁` 通过：
  - 当前对象明确属于既有项目发布对象簇内部的 owner continuation 收口
  - 不构成新 board
- `入口位置门禁` 通过：
  - 当前用户诉求与 repo 现状可收敛为 `我的项目详情` 内的 bounded read-only zone
  - 不要求 public `project/detail` 扩容
- `共享下载协议门禁` 通过：
  - shared `GET /api/app/file/access` 已存在，可作为未来实际下载承接协议
- `Admin 边界门禁` 通过：
  - 当前 repo 已明确 `template_config` 是 Admin-only governance workbench
  - 可以据此正式排除“直接代理到 App”这条错误路径
- `架构边界门禁` 通过：
  - `Flutter App -> BFF -> Server` 单通道不变
  - `BFF` 不拥有第二资源目录真值
  - `Server` 继续是唯一 truth owner

## 3. Failed Gates

- `app-facing list path 门禁` 未冻结：
  - 当前还没有 `公共资源下载区` 的合法 app-facing canonical path
- `Server catalog 门禁` 未冻结：
  - 当前还没有 `公共资源下载区` 的唯一 Server truth carrier
- `BFF surface 门禁` 未冻结：
  - 当前还没有当前对象下的资源列表映射与 error normalization
- `Flutter consumption 门禁` 未冻结：
  - 当前还没有当前对象下的 zone title / category / empty-state / CTA authority
- `previous absence downgrade 门禁` 未冻结：
  - 2026-04-14 早些时候关于“公共资源下载区 = future handoff only”的结论，
    还没有被更晚的 dedicated chain 正式接替

## 4. Veto Gates

- 不得把 `公共资源下载区` 偷换成：
  - `项目详情文书区`
  - owner-private attachment list
  - public showcase attachment wall
- 不得把 `template_config` 偷换成：
  - App 直接消费 truth
  - BFF 代理列表
  - 已开放下载目录
- 不得把 shared `file/access` 偷换成：
  - 资源目录
  - 资源列表
  - App 端现成下载区
- 不得在未冻结前直接 author：
  - 新代码
  - 新下载按钮
  - 新 Admin 路径

## 5. Stage Decision

- `Go`：
  - docs-only truth chain authoring
  - L0 / L2 / L3 / L4 / L5 一次性冻结
- `No-Go`：
  - implementation
  - BFF / Server / Flutter 代码改写
  - Admin write-side authoring

## 6. Next Unique Action

- 下一步唯一动作：
  - 输出《公共资源下载区总裁决补充单》
