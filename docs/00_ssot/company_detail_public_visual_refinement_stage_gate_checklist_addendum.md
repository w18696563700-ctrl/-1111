---
owner: Codex 总控
status: active
purpose: Stage-gate checklist for the Flutter-only public company detail and home recommendation visual refinement.
layer: L0 SSOT
based_on:
  - docs/00_ssot/company_detail_public_visual_refinement_truth_freeze_addendum.md
freeze_date_local: 2026-05-05
---

# 《公司详情页公开展示与首页公司推荐卡视觉精修 stage gate checklist》

## Gate 0: Read-only Scan

Result: `PASS`

Read-only findings:

- 首页公司推荐卡来源为 `EnterpriseHubListItem`，当前可用 `logoUrl / name / provinceName / cityName / shortIntro / certificationLabel / caseCount / avgScore / boardHighlights`。
- 公司列表卡已有头像展示逻辑，来源为 `EnterpriseCard -> _EnterpriseCardLogo -> _buildEnterpriseCardLogoImage`。
- 公司详情页来源为 `EnterpriseHubDetailData`，可用 `header / visualGallery / basicInfo / location / boardProfile / serviceAreas / cases / certifications / reviewSummary / contacts`。
- 当前本地工作区存在并行线程未跟踪文件，本轮不得 stage / 修改 / 清理。

## Gate 1: Truth And Surface Freeze

Result: `PASS`

Required frozen decisions:

- 本轮只改 Flutter 展示层、docs、Flutter tests、截图回执。
- 首页公司推荐卡头像来源为 `EnterpriseHubListItem.logoUrl`，fallback 为现有首字占位。
- 公司详情页只消费 public live `EnterpriseHubDetailData`。
- 无评分 / 无评价 / 无经验 / 无案例 / 无资质 / 无联系人时，不伪造目标图示例字段。
- Computer Use 截图必须在用户热启动并登录后执行。

## Gate 2: Implementation Scope

Allowed:

- `apps/mobile/lib/features/exhibition/presentation/exhibition_home_recommendation_section.dart`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_home_enterprise_panels.dart`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_home_channel_support.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_relayout_surface.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_relayout_sections.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_relayout_support.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_company_*.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_shared.dart` only if a shared display helper must be reused without changing route semantics.
- Targeted tests under `apps/mobile/test/`.

Blocked:

- `apps/bff/**`
- `apps/server/**`
- `docs/01_contracts/**`
- `packages/contracts/**`
- migrations, seeds, runtime, cloud deployment, Nginx, database.

## Gate 3: Verification

Required checks:

- Scoped `flutter analyze` for changed Flutter files and targeted tests.
- Targeted widget tests:
  - `test/exhibition_home_test.dart`
  - `test/enterprise_hub_routes_test.dart`
  - `test/enterprise_hub_trust_repair_stage1_test.dart`
- `git diff --check` for changed files.
- Screenshot files under `docs/04_frontend/screenshots/company_detail_public_visual_refinement_20260505/`.

## Gate 4: Runtime / Visual Receipt

Runtime boundary:

- No cloud deploy.
- No cloud write smoke.
- Computer Use is local visual verification only.

Screenshot checklist:

- 首页公司推荐头像卡。
- 公司详情 Hero + 信任指标首屏。
- 公司详情地址 / 案例 / 资质区。
- 公司详情底部联系区 or contact section.
- 窄屏 bottom-nav non-overlap.

## Overall Gate Decision

`GO` for Day 2 Flutter implementation after this checklist is registered.

`NO-GO` for BFF, Server, contracts, DB, cloud, fake metrics, fake reviews, fake cases, and fake qualifications.
