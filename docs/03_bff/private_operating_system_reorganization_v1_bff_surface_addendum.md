---
owner: 总控文书冻结
status: frozen
purpose: Freeze the first dedicated L3 BFF surface for `我的楼 V2.3 私域操作系统整理`, including only bounded profile-index shaping, shell-context projection shaping, regrouping or ordering or corridor projection shaping, explanation projection, controlled-error, and dependency-reference shaping without widening into cross-building navigation runtime, governance surface, dashboard surface, or implementation unlock.
layer: L3 BFF
freeze_date_local: 2026-04-06
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/my_building_v23_private_operating_system_reorganization_package_boundary_judgment_addendum.md
  - docs/00_ssot/my_building_v23_private_operating_system_reorganization_rules_freeze_addendum.md
  - docs/00_ssot/my_building_v23_private_operating_system_reorganization_contracts_judgment_addendum.md
  - docs/01_contracts/private_operating_system_reorganization_v1_contracts_addendum.md
  - docs/00_ssot/my_building_v23_private_operating_system_reorganization_backend_truth_judgment_addendum.md
  - docs/02_backend/private_operating_system_reorganization_v1_backend_truth_addendum.md
  - docs/00_ssot/my_building_v23_private_operating_system_reorganization_bff_surface_judgment_addendum.md
---

# 我的楼 V2.3 私域操作系统整理 BFF Surface Addendum

## A. Current Object

- This addendum applies only to the first dedicated `docs/03_bff` package for:
  - `我的楼 V2.3 私域操作系统整理`
  - bounded profile-index shaping
  - bounded shell-context projection shaping
  - bounded regrouping / entry-order / corridor projection shaping
  - controlled explanation projection
  - controlled error family
  - bounded dependency-reference shaping
- This addendum does not by itself:
  - unlock `apps/bff` implementation
  - unlock frontend surface freeze
  - unlock implementation
  - approve cross-building navigation runtime, governance surface, dashboard surface, or implementation runtime

## B. Current BFF-surface Meaning

- This BFF-surface package freezes only:
  - read-only app-facing shaping layer
  - normalize layer
  - controlled error-family layer
  - explanation projection layer
  - dependency-reference projection layer
- `BFF` in this package may do only:
  - forward
  - normalize
  - shape
  - bounded profile-index summary projection
  - bounded shell-context projection
- `BFF` in this package must not own:
  - `V2.0 / V2.1 / V2.2` business truth
  - regrouping truth as business truth
  - governance truth
- This addendum must not be read as:
  - approval for cross-building runtime rewrite
  - approval for dashboard surface
  - approval for governance surface
  - approval for implementation unlock

## C. Allowed BFF Surface Families

- Current package freezes only the following bounded app-facing surface families:
  - bounded profile-index shaping
  - bounded shell-context projection shaping
  - bounded regrouping / entry-order / corridor projection shaping
  - controlled explanation projection
  - controlled error family
  - dependency-reference shaping family
- Current shell / profile side BFF surface may project only:
  - bounded profile index summary
  - bounded shell context summary
  - regrouping projection
  - ordering reference projection
  - corridor visibility projection
  - explanation projection
  - dependency reference projection

## D. Allowed Route Family

- The current route family is frozen as:
  - `/api/app/profile/index`
  - `/api/app/shell/context`
  - necessary bounded profile explanation projection inside the existing profile family
- Current route rules:
  - only existing bounded route families are approved
  - no new bare route family is approved in this round
  - no write commands are approved in this round
- This addendum must not create:
  - bare `/regrouping/*`
  - bare `/corridor/*`
  - bare `/dashboard/*`
  - bare `/governance/*`
- This route family must not drift into:
  - `messages`
  - `exhibition`
  - hidden building

## E. Profile-index Shaping

- `/api/app/profile/index` may shape only the minimum regrouping read model:
  - `regroupingKey`
  - `entryOrderKey`
  - `corridorVisibilityStatus`
  - `groupingExplanationKey`
  - `updatedAt`
- Current shaping rules:
  - values are app-facing normalized projections only
  - values must come from `Server`-owned reference truth only
  - no business truth ownership change may be projected as current package truth
  - no dashboard payload may be projected as current package truth

## F. Shell-context Projection Shaping

- `/api/app/shell/context` may shape only the minimum shell-context read model:
  - `profileCorridorKey`
  - `profileEntryOrderBucket`
  - `visibleFamilyKeys`
  - `orderingReferenceVersion`
  - `updatedAt`
- Current shaping rules:
  - shell-context shaping remains bounded projection only
  - no cross-building runtime navigation policy may be projected in this package
  - no governance policy field may be projected in this package

## G. Regrouping / Entry-order / Corridor Projection Shaping

- Current projection shaping may carry only:
  - `regrouping`
  - `entryOrder`
  - `corridor`
  - `familyPresence`
  - `orderingReference`
- Current shaping rules:
  - projection remains bounded regrouping and ordering reference
  - no cross-building navigation runtime may be shaped in this package
  - no governance or dashboard runtime payload may be shaped in this package

## H. Controlled Explanation Projection

- Current explanation projection may carry only:
  - `regroupingExplanation`
  - `orderingExplanation`
  - `corridorExplanation`
  - `dependencyExplanation`
- Current hard rules:
  - explanation remains bounded projection only
  - no final IA rewrite truth is approved in this round
  - no second dashboard payload is approved in this round

## I. Dependency Reference Shaping

- All bigger shell rewrite scope remains expressed only as:
  - `future dependency`
  - `strategic hold`
- Current dependency reference shaping may project only:
  - `dependencyFamilyKey`
  - `dependencyRequired`
  - `dependencyExplanationKey`
  - `dependencyHandoffKey`
- This BFF-surface package must not turn dependency reference shaping into:
  - cross-building runtime rewrite shaping
  - governance execution shaping
  - implementation runtime shaping

## J. Controlled Error Family

- The current controlled error family for this package is frozen as:
  - `PROFILE_INDEX_ROUTE_UNAVAILABLE`
  - `SHELL_CONTEXT_ROUTE_UNAVAILABLE`
  - `REGROUPING_REFERENCE_UNAVAILABLE`
  - `ENTRY_ORDER_REFERENCE_UNAVAILABLE`
  - `CORRIDOR_REFERENCE_UNAVAILABLE`
  - `AUTH_PERMISSION_INSUFFICIENT`
  - `AUTH_RESOURCE_UNAVAILABLE`
- `BFF` may only:
  - normalize these failures
  - preserve their app-facing meaning
  - shape them into bounded unavailable or permission-insufficient output
- `BFF` must not:
  - hide regrouping drift behind fake success
  - invent rewrite-ready semantics
  - rewrite dependency-required into runtime shell-ready truth

## K. Drift Guard

- `我的楼` must not drift into:
  - a second dashboard
  - a governance console
  - a cross-building runtime shell rewrite
- `我的项目 / 我的论坛 / 设置` families must not be erased or downgraded.
- `V2.3` remains:
  - bounded regrouping direction only
  - not runtime final IA truth

## L. Retained No-Go

- Current `No-Go` remains:
  - complete IA rewrite surface
  - cross-building runtime rewrite surface
  - dashboard surface
  - governance surface
  - finance backoffice surface
  - payment runtime surface
  - frontend surface freeze
  - implementation unlock
  - runtime implementation
- Current round also does not approve:
  - bare `/regrouping/*`
  - bare `/corridor/*`
  - bare `/dashboard/*`
  - bare `/governance/*`

## M. Formal Conclusion

- `V2.3 私域操作系统整理 BFF surface freeze 已完成`
- `当前可进入 frontend-surface judgment`
- This addendum does not mean:
  - frontend ready
  - implementation ready
  - rewrite ready
  - launch ready

## N. Next Unique Action

- Next unique action:
  - output `《我的楼 V2.3 私域操作系统整理 frontend-surface judgment》`
