---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the L5 frontend consumption for round-1 splitting of the publish
  workbench, removing first-level entry exposure and shrinking workbench into
  a compatibility shell while preserving current route, create-eligibility
  dependence, and my-project detail authority.
layer: L5 Frontend
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_publish_workbench_split_round1_frontend_ruling_addendum.md
  - docs/00_ssot/project_detail_document_zone_and_public_resource_download_ruling_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_ruling_addendum.md
  - apps/mobile/lib/features/profile/presentation/profile_page.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_home_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart
  - apps/mobile/lib/features/exhibition/presentation/presentation_support/bid_submit_guard_support.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_page.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model_sections.dart
---

# 《发布项目工作台拆分第一轮 L5 frontend consumption freeze》

## 1. Frontend Freeze Conclusion

- 当前 owner-facing 主入口正式固定为：
  - `我的项目`
- 当前 `发布项目工作台` 在 Flutter 中第一轮正式固定为：
  - route-preserved compatibility shell

## 2. Entry Removal Rule

- `ProfilePage` 当前正式不再展示：
  - `发布项目工作台` 一级入口
- 首页推荐空态当前正式不再展示：
  - `回到发布项目工作台`
- `ProjectDetailPage` owner continuation 当前正式不再展示：
  - `打开发布项目工作台`

## 3. Copy Cleanup Rule

- owner-facing copy 当前正式收口为：
  - `进入我的项目`
  - `返回我的项目`
  - `检查当前创建资格`
- 当前正式降级的旧文案包括：
  - `回到发布项目工作台`
  - `打开发布项目工作台`
  - `当前发布项目工作台资格`

## 4. Bid Guard Rule

- `bid_submit_guard_support.dart` 当前正式不得再把：
  - 供应商角色不符
  - 壳层失败
  - owner 阻断
  统一导向 workbench
- 当前正式要求按 blocker 精确导流。

## 5. Compatibility-shell Rule

- `ExhibitionPage` 当前第一轮只保留：
  - 刷新
  - 最小承接提示
  - 最小可继续入口
- `ExhibitionWorkbenchViewModelSections` 当前正式允许：
  - 隐藏 `边界能力`
  - 无 active order 时隐藏 `订单承接` 空卡
  - 无 active milestone 时隐藏 `履约承接` 空卡
- 当前不得把 workbench 做成：
  - 说明墙
  - 文书区主面
  - 公共资源区主面

## 6. Retained Boundary

- 当前 Flutter 继续保留：
  - `ExhibitionRoutes.workbench`
  - `app_router.dart` 中的 workbench route
  - `ProjectCreatePage` 对 `canCreateProject` 的读取
- 当前 Flutter 不得改动：
  - `我的项目详情` 中 `项目详情文书区`
  - `我的项目详情` 中 `公共资源下载区`

## 7. Current Excluded Family

- 当前正式禁止：
  - 删除 workbench route
  - 改 `Server/BFF/contracts`
  - 将文书区或公共资源区迁回 workbench
