---
owner: Codex 总控
status: frozen
purpose: >
  Record the bounded execution receipt for removing the retained publish-
  workbench refresh residual from the BidAward bridge support layer, without
  touching project-create fallback or retained workbench route/API families.
layer: L0 SSOT
freeze_date_local: 2026-04-14
based_on:
  - AGENTS.md
  - docs/00_ssot/project_publish_workbench_final_cleanup_dependency_inventory_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/presentation_support/bid_award_support.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/exhibition_status_messages.dart
---

# 《发布项目工作台 BidAward 残留刷新清理执行回执》

## 1. 本轮目标

- 只清：
  - `BidAward bridge / workbench refresh residual`
- 不清：
  - `project_create_page.dart` 的 workbench fallback
  - retained route `/exhibition/workbench`
  - retained app-facing API `GET /api/app/exhibition/workbench`

## 2. 实际修改

- 已从
  [bid_award_support.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/presentation_support/bid_award_support.dart)
  移除成功后对 `loadWorkbench(forceRefresh: true)` 的刷新。
- `BidAward` 成功后当前只刷新：
  - `project detail`
  - `my project list`
  - `onRefreshAccepted()` 回调
- 已把
  [exhibition_status_messages.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/widgets/exhibition_status_messages.dart)
  中 `BidAward` 专属的成功文案、duplicate 文案、order-conversion / contract-seed 失败文案
  从“会刷新工作台”收口为只指向 `项目详情 / 我的项目`。

## 3. 静态核验结果

- `bid_award_support.dart` 中已不再出现：
  - `loadWorkbench(`
- `flutter analyze` 已通过：
  - `apps/mobile/lib/features/exhibition/presentation/presentation_support/bid_award_support.dart`
  - `apps/mobile/lib/features/exhibition/presentation/widgets/exhibition_status_messages.dart`

## 4. 当前未处理项

- 当前没有同时修：
  - `project_create_page.dart` 的 workbench fallback
  - retained route / API
- 当前也没有把旧的
  `bid_award_bridge_test.dart`
  升格成本轮验收基线。
  原因是该测试仍假定 `我的项目详情` 直接暴露定标入口，
  已不适合作为当前这轮“只删残留刷新”的唯一验收标准。

## 5. 当前结论

- `BidAward bridge / workbench refresh residual cleanup = passed`
- `项目发布工作台` 的最终技术清理，当前还剩：
  - `project create fallback`
  - `retained route + API`
