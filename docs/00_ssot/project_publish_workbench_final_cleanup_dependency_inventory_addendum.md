---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the final compatibility dependency inventory and delete order for the
  retained publish-workbench technical cleanup, after owner-facing split has
  already completed.
layer: L0 SSOT
freeze_date_local: 2026-04-14
based_on:
  - AGENTS.md
  - docs/00_ssot/project_publish_workbench_final_cleanup_stage_gate_checklist_addendum.md
  - docs/00_ssot/project_publish_workbench_split_round1_frontend_ruling_addendum.md
  - docs/00_ssot/project_publish_workbench_split_round2_compat_shell_retitle_ruling_addendum.md
  - docs/00_ssot/project_create_eligibility_shell_projection_decouple_ruling_addendum.md
  - docs/00_ssot/project_detail_document_zone_and_public_resource_download_ruling_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_closure_conclusion_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/presentation_support/bid_award_support.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart
  - apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart
  - apps/mobile/lib/shell/navigation/app_router.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart
  - apps/bff/src/routes/exhibition_workbench/app-exhibition-workbench.controller.ts
  - apps/server/src/modules/exhibition_workbench/exhibition-workbench.controller.ts
---

# 《发布项目工作台最终技术清理兼容依赖盘点表》

## 1. 当前总判断

- `项目发布工作台` 的 owner-facing 拆分已经完成。
- 当前未完成的，不是用户侧拆分，而是最后一轮技术清理。
- 当前不得一刀切删除 workbench。
- 最合理的顺序固定为：
  1. 先清 `BidAward bridge` 的 workbench 刷新残留
  2. 再清 `project_create_page.dart` 的 workbench fallback
  3. 最后再删 retained route / API / tests

## 2. 当前不再属于 workbench authority 的区域

- `我的项目`
- `我的项目详情`
- `项目详情文书区`
- `公共资源下载区`
- `预发布列表 / 发布确认主面`

这些区域都已经有独立真源或独立 frontend authority，不得回流到 workbench。

## 3. 最终兼容依赖盘点表

| 依赖块 | 文件 | 当前为什么还依赖 | 删除顺序 | 风险级别 | 是否需要联调 | 是否影响测试 |
| --- | --- | --- | --- | --- | --- | --- |
| `BidAward bridge / refresh residual` | `apps/mobile/lib/features/exhibition/presentation/presentation_support/bid_award_support.dart` | 成功后仍会 `loadWorkbench(forceRefresh: true)`，把 workbench 当旧摘要同步对象 | 第 1 步 | 低到中 | 否 | 是；`bid_award_bridge_test.dart` 及其直接桥接断言 |
| `BidAward bridge / scope note` | `docs/04_frontend/bid_award_bridge_frontend_consumption_freeze_addendum.md` | 该对象链本来就不是 workbench truth；当前只剩刷新残留，不应把页面 authority 再迁回 workbench | 第 1 步配套复核 | 低 | 否 | 间接影响 `bid` 家族测试的旧文案和旧入口假设 |
| `project create fallback` | `apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart` | 当前 primary carrier 已是 `shellContext.projectCreateEligibility`，但 shell 缺失时仍 fallback 到 `loadWorkbench()` 读取 `canCreateProject` | 第 2 步 | 中 | 建议真人冒烟 | 是；`project_showcase_filter_create_refactor_test.dart`、`exhibition_mainline_flow_test.dart`、`shell_app_test.dart` |
| `project create compatibility helper` | `apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart` 中 `_canCreateProjectFromWorkbench(...)` | 该 helper 只服务兼容轮 fallback，不是最终 authority | 第 2 步 | 中 | 否 | 是；同创建链测试 |
| `retained route key` | `apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart` | `ExhibitionRoutes.workbench` 仍为兼容壳 route key | 第 3 步 | 中 | 否 | 是；所有 route/导航旧断言 |
| `retained route registration` | `apps/mobile/lib/shell/navigation/app_router.dart` | route 仍挂在 shell router 下，当前用户侧名为 `项目续接` | 第 3 步 | 中 | 否 | 是；`exhibition_home_test.dart`、`shell_app_test.dart`、导航测试 |
| `retained compatibility shell` | `apps/mobile/lib/features/exhibition/presentation/exhibition_page.dart` | 当前仍是最小兼容壳，承接 old route 进入 | 第 3 步 | 中 | 建议真人冒烟 | 是；workbench 页面测试、home fallback 测试 |
| `retained shell source` | `apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_source.dart` | 当前仍消费 `GET /api/app/exhibition/workbench` summary，给兼容壳投影 | 第 3 步 | 中 | 是，删 API 前必须核一遍 | 是；workbench source / shell tests |
| `retained canonical path` | `apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart` | 当前仍登记 `/api/app/exhibition/workbench` | 第 3 步 | 中 | 是 | 是；mock path 断言广泛存在 |
| `retained app-facing API` | `apps/bff/src/routes/exhibition_workbench/app-exhibition-workbench.controller.ts` | 仍暴露 `GET /api/app/exhibition/workbench` 给兼容壳与旧测试使用 | 第 3 步 | 中到高 | 是 | 是；BFF route tests / mobile mock contracts |
| `retained truth route` | `apps/server/src/modules/exhibition_workbench/exhibition-workbench.controller.ts` | 仍暴露底层 summary truth 给 BFF | 第 3 步 | 中到高 | 是 | 是；Server/BFF/runtime smoke |

## 4. 当前直接删除的风险判断

### 4.1 现在直接删 `BidAward bridge` workbench refresh

- 风险：低到中
- 原因：
  - 这已经不是 authority 依赖
  - 更像旧摘要同步残留
- 结论：
  - 适合作为下一轮最小技术清理目标

### 4.2 现在直接删创建页 fallback

- 风险：中
- 原因：
  - shell context 已是 primary carrier
  - 但 fallback 仍是兼容兜底
- 结论：
  - 只能放在 `BidAward bridge` 清完之后

### 4.3 现在直接删 route + API

- 风险：中到高
- 原因：
  - route / API / tests 仍形成兼容闭环
  - 一刀切会把导航、mock、旧断言一起打断
- 结论：
  - 必须放在最后一步

## 5. 推荐删除顺序

1. `BidAward bridge residual cleanup`
   - 删 `bid_award_support.dart` 中的 `loadWorkbench(forceRefresh: true)`
   - 同步修正其桥接测试
2. `project create fallback cleanup`
   - 删 `project_create_page.dart` 中 fallback 到 workbench 的读取
   - 只保留 `shellContext.projectCreateEligibility`
   - 同步清 `_canCreateProjectFromWorkbench(...)`
3. `retained route + API cleanup`
   - 删 `ExhibitionRoutes.workbench`
   - 删 `app_router.dart` 注册
   - 删 mobile canonical path
   - 删 BFF `GET /api/app/exhibition/workbench`
   - 删 Server exhibition-workbench truth route
   - 最后统一收测试

## 6. 下一轮建议

- 下一轮唯一建议目标固定为：
  - `BidAward bridge residual cleanup`
- 不建议下一轮直接进入：
  - `project create fallback cleanup`
  - `retained route + API cleanup`

## 7. 当前裁决

- `项目发布工作台` 在业务承接意义上已经拆分完成。
- 当前最后残留的是技术兼容依赖，不是 owner-facing authority。
- 立即硬删 `workbench` 仍然过早。
- 下一轮应先清：
  - `BidAward bridge / workbench refresh residual`
