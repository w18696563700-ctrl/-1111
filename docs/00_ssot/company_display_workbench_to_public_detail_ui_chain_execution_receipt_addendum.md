---
owner: Codex 总控
status: frozen
layer: L0 SSOT
scope: company display workbench to public detail Flutter UI chain execution receipt
created_at: 2026-05-05
---

# Company Display Workbench To Public Detail UI Chain Execution Receipt Addendum

## Verdict

`PASS` for the approved Flutter-only UI refinement scope.

This receipt closes the three-day execution slice for:

- Exhibition home company recommendation card simplification.
- Company display workbench homepage restructuring.
- Public company detail page restructuring.
- Scoped Flutter tests and Computer Use visual verification.

## Boundary

This execution did not modify BFF, Server, OpenAPI, database, migrations, cloud runtime, Nginx, deployment scripts, or app-facing contracts.

This execution did not add fake company fields, fake cases, fake qualifications, fake analytics, fake latest dynamics, fake data-board values, fake publish capability, fake review capability, fake certification capability, fake contact permissions, or fake map truth.

`workbench`, `preview`, and `public detail` remain separated:

- Workbench consumes management data and current-change / draft-facing projections where already admitted.
- Preview may show live / current-change comparison through existing paths only.
- Public detail consumes public live detail only and must not display workbench internal state.

## Implemented

### Exhibition Home Company Recommendation

- Removed the visible `优秀公司` badge from company recommendation cards.
- Kept the company recommendation card actionable by making the whole card clickable.
- Removed the visible `查看公司详情` CTA text from the company card visual surface.
- Preserved visible detail CTA behavior for factory / supplier recommendation cards, avoiding cross-channel regression.

### Company Display Workbench

- Reordered the company workbench homepage into:
  - Information completeness.
  - Company display preview.
  - Public display summary.
  - Real quick entries.
  - Grouped module entries.
  - Company display status.
- Kept detailed fields behind module entries instead of flattening all fields on the homepage.
- Marked information completeness as display-layer derived from existing readiness context, not business truth.
- Kept bottom operations tied to existing real capabilities only.

### Public Company Detail

- Reordered the company detail public display into:
  - Hero.
  - Trust summary.
  - Company introduction.
  - Address and service area.
  - Core advantages.
  - Public cases.
  - Qualifications and reputation.
  - Basic information.
  - Contact.
- Removed public-detail exposure of workbench-internal status and technical review copy.
- Kept contact and case display constrained to data returned by the public detail surface.

## Field Mapping

| Workbench information | Public company detail presentation | Rule |
| --- | --- | --- |
| Logo / cover / album | Hero visual surface | Logo remains identity display; cover / album remains public visual display; no mixing with case images. |
| Company name | Hero title | Must come from the existing enterprise display data path. |
| Company intro | Company introduction section | Long text is summarized first and can expand. |
| Main business / tags / service capability | Hero tags and core advantages | Only show returned values; no fake capability labels. |
| Province / city / address / service area | Address and service area card | Only show returned location fields and admitted map projection. |
| Qualifications / certification / reputation summary | Qualifications and reputation section | No fake certification or fake review summary. |
| Cases | Public case carousel | Only data returned by public detail is shown; no draft-case mixing. |
| Team size / scale / project scale | Trust summary / basic information | Only show returned fields. |
| Contacts | Contact section | Existing visibility and permission semantics are preserved. |
| Workbench status / current change status | Workbench status only | Public detail must not display internal workbench state. |

## Verification

### Static Checks

Command:

```sh
cd apps/mobile && env PATH="/opt/homebrew/share/flutter/bin/cache/dart-sdk/bin:/opt/homebrew/share/flutter/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Applications/Codex.app/Contents/Resources" /opt/homebrew/share/flutter/bin/flutter analyze lib/features/exhibition/presentation/exhibition_home_recommendation_section.dart lib/features/exhibition/presentation/exhibition_home_enterprise_panels.dart lib/features/exhibition/presentation/enterprise_hub_workbench_page_company_homepage.dart lib/features/exhibition/presentation/enterprise_hub_workbench_page_company_modules.dart lib/features/exhibition/presentation/enterprise_hub_detail_company_sections.dart lib/features/exhibition/presentation/enterprise_hub_detail_company_support_widgets.dart lib/features/exhibition/presentation/enterprise_hub_detail_relayout_surface.dart lib/features/exhibition/presentation/enterprise_hub_detail_surface_widgets.dart test/enterprise_hub_routes_test.dart test/enterprise_hub_workbench_stage1_relayout_test.dart test/enterprise_hub_trust_repair_stage1_test.dart test/exhibition_home_test.dart
```

Result:

```text
No issues found.
```

### Flutter Tests

Command:

```sh
cd apps/mobile && env PATH="/opt/homebrew/share/flutter/bin/cache/dart-sdk/bin:/opt/homebrew/share/flutter/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Applications/Codex.app/Contents/Resources" /opt/homebrew/share/flutter/bin/flutter test test/enterprise_hub_workbench_stage1_relayout_test.dart test/enterprise_hub_routes_test.dart test/enterprise_hub_trust_repair_stage1_test.dart test/exhibition_home_test.dart
```

Result:

```text
90 tests passed.
```

### Visual Evidence

Computer Use was run against a logged-in local Flutter app window after user confirmation.

Screenshots:

- `docs/04_frontend/screenshots/company_display_ui_chain_20260505/home_company_recommendation.png`
- `docs/04_frontend/screenshots/company_display_ui_chain_20260505/company_detail_hero.png`
- `docs/04_frontend/screenshots/company_display_ui_chain_20260505/company_workbench_home.png`
- `docs/04_frontend/screenshots/company_display_ui_chain_20260505/company_workbench_modules.png`
- `docs/04_frontend/screenshots/company_display_ui_chain_20260505/company_workbench_narrow_bottom.png`

Visual observations:

- Company recommendation no longer shows `优秀公司`.
- Company recommendation card enters company detail by whole-card click.
- Company detail first screen shows public detail sections, not workbench internals.
- Company workbench first screen is reduced to completeness, preview, summary, real entries, and grouped management modules.
- Bottom navigation does not block the visible workbench module and status content in the captured narrow screen.

## Residual Risk

- The current worktree contains unrelated dirty files from parallel workstreams. They were not reverted, cleaned, or included as this receipt's implementation scope.
- The existing `enterprise_hub_detail_surface_widgets.dart` file remains over the default handwritten file-length limit from prior structure. This round avoided expanding it further by adding dedicated company detail section/support files.
- This is a local Flutter visual and widget-test receipt. It is not a cloud release receipt and does not claim BFF / Server runtime deployment.

## Closure

The requested slice is complete under the approved boundary:

- SSOT and frontend surface were frozen.
- Flutter-only implementation was completed.
- Scoped analyze and widget tests passed.
- Computer Use visual screenshots were captured.
- BFF, Server, OpenAPI, database, cloud runtime, and business truth remained unchanged.
