---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the stage gate for round-2 frontend-only retitling of the retained
  publish-workbench compatibility shell, allowing only bounded Flutter
  retitle/copy cleanup while route deletion, backend changes, and any movement
  of document/resource zones remain blocked.
layer: L0 SSOT
freeze_date_local: 2026-04-14
based_on:
  - AGENTS.md
  - docs/00_ssot/project_publish_workbench_split_round1_frontend_ruling_addendum.md
  - docs/04_frontend/project_publish_workbench_split_round1_frontend_consumption_addendum.md
  - docs/00_ssot/project_detail_document_zone_and_public_resource_download_ruling_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_ruling_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/exhibition_page.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model.dart
  - apps/mobile/lib/shell/navigation/app_router.dart
  - apps/mobile/lib/features/profile/presentation/profile_identity_access_pages.dart
---

# 《发布项目工作台拆分第二轮兼容壳改名前端阶段门禁核查表》

## 1. 当前轮范围

- 本轮只覆盖：
  - workbench retained route 的用户主体验名
  - workbench loading/title/banner/copy 的兼容壳命名
  - 与 `canCreateProject` 相关的少量用户侧说明文案
- 本轮不覆盖：
  - route path 删除
  - `Server/BFF/contracts`
  - `项目详情文书区`
  - `公共资源下载区`

## 2. Passed Gates

- `对象连续性门禁` 通过：
  - 当前仍是同一对象的前端续拆，不是新对象切换。
- `真值稳定门禁` 通过：
  - `canCreateProject` 依赖仍保持在既有 workbench summary。
- `前端独立实施门禁` 通过：
  - 当前改动只落 `apps/mobile`，不要求中后端联动。
- `区位保护门禁` 通过：
  - `项目详情文书区` 与 `公共资源下载区` 当前都已冻结在 `我的项目详情`，本轮只保留 no-touch。

## 3. Failed Non-veto Gates

- `全量测试清洁门禁` 当前不作为通过条件：
  - profile 大套件仍存在本轮无关的既有漂移，不能作为本轮 veto。

## 4. Veto Gates

- `route 删除门禁` 未触发：
  - 本轮不允许删 `/exhibition/workbench`。
- `真值回流门禁` 未触发：
  - 本轮不允许把文书区或公共资源区迁回 workbench。
- `中后端漂移门禁` 未触发：
  - 本轮不允许改 `apps/bff`、`apps/server`、contracts。

## 5. Gate Conclusion

- 当前 veto gates 均未阻断。
- 当前轮结论固定为：
  - `Go for docs-only freeze authoring and bounded Flutter implementation`

