---
owner: Codex 总控
status: active
purpose: Stage-gate checklist for the Flutter-only clean-card refinement of factory and supplier recommendation/list cards.
layer: L0 SSOT
based_on:
  - docs/00_ssot/factory_supplier_clean_card_truth_freeze_addendum.md
freeze_date_local: 2026-05-05
---

# 《工厂 / 供应商清爽版推荐卡与列表卡 stage gate checklist》

## Gate 0: Read-only Scan

Result: `PASS`

Findings:

- 首页推荐卡渲染点为 `_HomeEnterpriseRecommendationCard`。
- 首页推荐卡字段来源为 `EnterpriseHubListItem`。
- 工厂 / 供应商列表页共用 `EnterpriseCard`。
- `EnterpriseCard` 也可能用于公司列表，因此不得直接全局隐藏 chips，必须按 board type 定向启用清爽模式。
- 当前工作区存在并行线程 dirty 文件，本轮不得触碰。

## Gate 1: Truth And Surface Freeze

Result: `PASS`

Frozen decisions:

- 本轮只改 Flutter 展示层、docs、targeted widget tests、screenshots / receipt。
- 首页工厂 / 供应商推荐卡隐藏 badge、chips、文字 CTA。
- 工厂 / 供应商列表卡隐藏 chips 和 badge 类字段。
- 公司列表卡不纳入强制同步，除非单独确认。
- 整卡点击进入详情必须保留。

## Gate 2: Implementation Scope

Allowed:

- `apps/mobile/lib/features/exhibition/presentation/exhibition_home_recommendation_section.dart`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_home_enterprise_panels.dart`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_home_channel_support.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_shared.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_list_pages.dart`
- `apps/mobile/test/exhibition_home_test.dart`
- `apps/mobile/test/enterprise_hub_routes_test.dart`

Blocked:

- `apps/bff/**`
- `apps/server/**`
- `docs/01_contracts/**`
- `packages/contracts/**`
- migrations, deployment, cloud runtime, DB writes.

## Gate 3: Verification

Required:

- Scoped `flutter analyze`.
- Targeted `flutter test`.
- `git diff --check`.
- Computer Use screenshots for home factory, home supplier, factory list, supplier list after user login.

## Gate 4: Runtime / Visual Receipt

Runtime boundary:

- Computer Use is local visual verification only.
- No cloud release claim.
- No tunnel write-smoke.

Overall decision: `GO` for Day 2 Flutter implementation.
