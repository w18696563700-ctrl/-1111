---
owner: Codex 总控
status: superseded
purpose: Historical draft sidecar for the my-building asset/route/page/truth-owner/stage matrix. Kept as retained project asset only after the canonical V1 table moved to `my_building_asset_route_page_truth_owner_stage_status_table_v1.md`.
layer: L0 SSOT
inputs_canonical:
  - docs/00_ssot/my_building_effective_truth_mother_file_v1.md
  - docs/00_ssot/current_active_implementation_candidate_inventory_addendum.md
  - docs/00_ssot/profile_my_building_compact_hub_boundary_addendum.md
  - docs/04_frontend/profile_my_building_compact_hub_frontend_surface_addendum.md
  - docs/04_frontend/flutter_screen_map.md
  - docs/00_ssot/account_and_enterprise_certification_rules_v1_package_level_implementation_unlock_assessment_addendum.md
  - docs/00_ssot/account_and_enterprise_certification_rules_v1_phase0_implementation_exception_review_conclusion_addendum.md
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_frontend_consumption_freeze_addendum.md
  - docs/00_ssot/forum_author_profile_and_profile_linkage_boundary_addendum.md
freeze_date_local: 2026-04-05
---

# 我的楼当前资产 / 路由 / 页面 / truth owner / 阶段状态总表 V1

> 本文件保留为历史 draft sidecar。
> 当前现行 canonical 文书改为 `docs/00_ssot/my_building_asset_route_page_truth_owner_stage_status_table_v1.md`。
> 本文件不再作为当前派工、门禁或主线裁决的优先引用依据。

## 1. 使用规则

- 本总表只写当前状态。
- `building owner` 只表示：
  - shell 内入口或页面归属
- `route owner` 只表示：
  - canonical path family 或 local route family 归属
- `page owner` 只表示：
  - 页面消费责任归属
- `truth owner` 只表示：
  - 业务真相归属
- 以上四者不得互相替代。

## 2. 资产 / 页面 owner 总表

| 对象 | 当前 building owner | 当前 page owner | 当前 truth owner | 当前阶段状态 | 当前不代表 |
|---|---|---|---|---|---|
| `我的楼` 首层 compact hub | `profile` | `我的楼` | `Server` 持有 account / session / organization / certification truth；`profile` 只做聚合消费 | compact-hub boundary + frontend surface 已冻结 | 不代表第二论坛首页，不代表第二工作台，不代表 public author homepage |
| 顶部个人资料 handoff | `profile` | personal profile | `Server.user` + `Server.organization` 摘要真相 | bounded handoff 已冻结 | 不代表 person-first 新 identity system |
| `我的公司` | `profile` | company detail | `Server.organization` + certification 摘要真相 | bounded detail 已冻结；Package 1 仍为 docs-only | 不代表公司治理后台，不代表 admin console |
| 认证 / 设备安全 | `profile` | certification + device-security page family | `Server.session` + `Server.organization` + `Server.certification` + `Server.devices` | Package 1 docs-frozen；implementation No-Go | 不代表 runtime fully open，不代表 `apps/mobile` / `apps/admin` 可直接实现 |
| `我的项目` 首层入口 | `profile` | `我的楼` entry slot | `Server.project` + downstream trade canonical truths | entry handoff 已冻结 | 不代表 `profile` 成为 project truth owner，不代表替代 `项目工作台` |
| `我的项目` 列表 / 单项目 | 当前仅冻结为从 `我的楼` handoff；Flutter local building 归属待独立 route freeze 显式补挂 | `我的项目` list/detail | `Server.project` + order / contract / fulfillment / acceptance / dispute / rating truths | truth / contract / persistence / backend-BFF implementation freeze / frontend consumption freeze 已形成；`Go` for entering bounded implementation stage | 不代表整个 `我的楼` implementation unlock，不代表正式附件列表已纳入 |
| `项目工作台` | `exhibition` | workbench summary | `Server` 私域摘要投影 | workbench summary baseline 已冻结 | 不代表“我的全部项目”，不代表 `我的项目` 别名 |
| `我的论坛` | `profile` | forum asset second-level surface | `Server.forum` | first-level handoff + bounded me-assets chain 已冻结 | 不代表 forum public truth 迁入 `profile` |
| `设置` | `profile` | settings page family | 当前只允许 app-native bounded settings consumption | bottom-anchored entry rule 已冻结 | 不代表 full governance center，不代表 IM-only settings |
| forum public author profile | `exhibition/forum` | public author profile | `Server.forum` public truth + bounded avatar projection | future boundary only | 不代表当前已在 `profile` 落成，不代表当前可实现 |

## 3. 路由 owner / stage 总表

| 路由或 route family | 当前 route owner | 当前服务对象 | 当前 truth owner | 当前阶段状态 | 当前不代表 |
|---|---|---|---|---|---|
| `/api/app/profile/*` | Package 1 app-facing `profile` family | account / organization / certification / device-security app consumption | `Server` | docs-only freeze chain 已形成；implementation No-Go | 不代表 bare `/me/*` 或 direct `Server` 调用开放 |
| `/server/admin/reviews/organizations*` + `/server/admin/security-events` | `Server` admin family | admin review | `Server` | docs-only freeze chain 已形成；implementation No-Go | 不代表 app actors 可直接消费 |
| `/api/app/my/projects` | `my/projects` private app-facing family | `我的项目` 列表 | `Server.project` + downstream trade truths，经 `BFF` shaping | contract 已冻结；frontend consumption 已冻结；bounded implementation stage 可进入 | 不代表复用公域 `project/list` |
| `/api/app/my/projects/{projectId}` | `my/projects` private app-facing family | `我的项目` 单项目 | `Server.project` + downstream trade truths，经 `BFF` shaping | contract 已冻结；frontend consumption 已冻结；bounded implementation stage 可进入 | 不代表复用公域 `project/detail` |
| `/server/my/projects` | `my/projects` private server family | `我的项目` 列表内部 truth read | `Server.project` + downstream trade truths | backend-BFF implementation freeze 已冻结 | 不代表新增 my-project-only table 或 snapshot |
| `/server/my/projects/{projectId}` | `my/projects` private server family | `我的项目` 单项目内部 truth read | `Server.project` + downstream trade truths | backend-BFF implementation freeze 已冻结 | 不代表 `plannedEndAt = formal completion` |
| Flutter local `我的项目` route family | 当前只在 frontend consumption freeze 中冻结为应独立存在；尚未在 `flutter_screen_map` 单独列出 | `我的项目` list/detail handoff | 无独立 truth owner；只消费 canonical app-facing truth | local route explicit map 仍待补挂 | 不代表可擅自复用 `workbench` / public `projectList` / public `projectDetail` |

## 4. 阶段状态总览

| 子链 | 当前状态 | 当前结论 |
|---|---|---|
| `我的楼 compact hub` | boundary freeze + frontend surface freeze | 可作为入口聚合基线引用；不构成 implementation unlock |
| Package 1 | docs-only freeze chain + Phase 0 exception `No-Go` | 可作为 `我的楼` 账户/组织/认证引用底座；implementation No-Go |
| `我的项目` | truth -> contract -> persistence migration -> backend-BFF implementation freeze -> frontend consumption freeze | 当前可进入 bounded implementation stage，但只限 `我的项目` 子链 local readiness，不外溢，也不自动改写全仓 active candidate inventory |
| forum public author profile | future boundary only | 只作战略区分与 owner 边界引用，不作当前实施依据 |

## 5. 当前必须防止的误读

- 不得把 `building owner = truth owner`。
- 不得把 `我的楼` 的 entry handoff 写成 project truth ownership。
- 不得把 Package 1 docs-only freeze 写成 implementation unlock。
- 不得把 `我的项目` bounded implementation stage 写成整个 `我的楼` 已可实现。
- 不得把本总表写成对 [current_active_implementation_candidate_inventory_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/current_active_implementation_candidate_inventory_addendum.md) 的替代。
- 不得把 Flutter local route 待补挂写成 route family 已全部闭环。

## 6. Next Unique Action

- 下一轮唯一动作：
  - 冻结《我的楼专项主线 V1：本轮必做 / 本轮冻结占位 / 战略保留 三栏裁决表》
- 该动作只允许：
  - 把当前主线对象按三栏拆开
  - 把 freeze placeholder 与战略保留分清
- 该动作不得：
  - 借三栏表扩 scope
  - 借三栏表发 implementation unlock
