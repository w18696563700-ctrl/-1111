---
owner: Codex 总控
status: frozen
purpose: 裁决“我的楼”主线当前有效真源、可沿用实现资产与历史 closure 背景，防止把旧资产抹掉或把历史主线误当当前主线。
layer: L0 SSOT
freeze_date_local: 2026-04-05
---

# 《当前有效真源基线裁决单》

## 1. 裁决范围

- 本裁决单只回答当前 `我的楼专项开发主线` 的基线问题：
  - 哪些是当前有效真源
  - 哪些是实现资产
  - 哪些是历史 closure 背景
- 本裁决单不直接发 implementation unlock。

## 2. 当前有效真源

| 真源对象 | 当前效力 | 核心结论 |
|---|---|---|
| `我的楼 compact hub` | 当前有效真源 | `我的楼` 是 compact current-user hub，不是第二论坛首页、第二工作台 dashboard、public author homepage 或 generic IM container；`设置` 保持首层底部；`我的发票抬头` 已被 `我的公司` 替代 |
| Package 1 `账户与企业认证` | 当前有效真源 | 当前 identity / qualification 仍是 organization-centered；`Server` 是唯一 truth owner；`BFF` 只做 shaping；`profile / 我的楼` 是当前 account / organization / certification / device-security 的 primary building；现有 freeze 链有效，但不自动等于新的 implementation unlock |
| `我的项目` 私域承接主线 | 当前有效真源 | `我的楼 -> 我的项目` 已成立；`项目工作台` 只是摘要 / 导流页；`我的项目` 首层分组为 `进行中 / 历史项目`；单项目必须拆为 `publicProject + privateProgress`；`plannedEndAt` 不等于正式完结 |
| `flutter_screen_map` | 当前有效真源 | visible buildings 仍只允许 `exhibition / messages / profile`；hidden buildings 仍为预埋；route owner 与 page owner 不能代替 truth owner |
| `source_of_truth_map` | 当前有效真源 | formal truth 只在 `docs/`；`apps/**` 是实现层；`packages/**` 是投影层；任何生成件不得反向改写上位真源 |
| `gate_register_v1` 与拓扑文书 | 当前有效真源 | 阶段派工前必须门禁核查；本地前端、云端 BFF/后端、隧道访问规则继续成立 |

## 3. 当前应纳入基线的实现资产

| 资产对象 | 当前状态 | 裁决 |
|---|---|---|
| `apps/mobile/lib/features/profile/**` | 已存在 `我的楼`、个人资料、我的公司、我的论坛、设置、登录、组织承接、认证状态、会话中心页面 | 全部纳入当前基线；禁止重做同语义页面 |
| `apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart` | 已存在 `ExhibitionRoutes.myProjectList` 与 `ExhibitionRoutes.myProjectDetail` | 视为现有 route 资产，继续沿用 |
| `apps/mobile/lib/features/exhibition/presentation/pages/my_project_list_page.dart` | 已存在 `我的项目` 列表页 | 纳入基线；禁止把它改义成 `项目工作台` |
| `apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart` | 已存在 `我的项目详情` 页 | 纳入基线；禁止把私域进度区与公域信息区混成一个无边界大页 |
| `apps/server/src/modules/my_project/**` | 已存在 server-side `my-project` read family 源码 | 纳入基线；后续只允许在冻结 truth 内补齐语义，不得推倒重写 |
| `apps/bff/src/routes/my_project/**` | 已存在 app-facing `my-project` route family 源码 | 纳入基线；继续以 shaping 为边界 |
| `packages/contracts/src/generated/app-api.types.ts` | 当前生成投影未包含 `/api/app/my/projects` 两个路径 | 视为投影滞后资产；不得反向否定 `openapi.yaml` 与上位真源 |
| `apps/bff/dist/packages/contracts/src/generated/app-api.types.d.ts` | 当前 dist 生成投影同样未包含 `/api/app/my/projects` | 视为历史生成件滞后；只可被修复，不可拿来改写 truth |

## 4. 当前仅作为历史 closure 背景的文书

| 文书 | 当前定位 | 不再作为现行依据的部分 |
|---|---|---|
| `docs/00_ssot/new_workflow_v2_takeover_declaration.md` | 历史接管背景 | 旧角色结构、旧阶段口径 |
| `docs/00_ssot/team_organization_freeze_round0.md` | 历史组织编制背景 | 六角色结构、`Round 0` 盘点轮定义 |
| `docs/00_ssot/current_active_implementation_candidate_inventory_addendum.md` | 历史主线盘点背景 | `enterprise_hub V1 = 当前唯一主 implementation candidate` 的旧主线裁决 |
| `docs/00_ssot/enterprise_hub_v1_primary_implementation_increment_dispatch_addendum.md` | 历史派工背景 | `enterprise_hub V1` 作为默认下一轮派工对象的旧结论 |

## 5. 当前明确的三类误判

- 以下文书属于 `当前有效真源`，不是仅供参考：
  - `docs/00_ssot/profile_my_building_compact_hub_boundary_addendum.md`
  - `docs/00_ssot/account_and_enterprise_certification_rules_v1_app_aligned_freeze_addendum.md`
  - `docs/00_ssot/my_project_entry_and_single_project_private_carry_truth_freeze_addendum.md`
  - `docs/04_frontend/flutter_screen_map.md`
  - `docs/00_ssot/source_of_truth_map.md`
- 以下对象属于 `实现资产`，不是 primary truth：
  - `apps/mobile/**`
  - `apps/bff/src/**`
  - `apps/server/src/**`
  - `packages/contracts/src/generated/**`
  - `apps/bff/dist/**`
- 以下对象属于 `历史 closure 背景`，不能继续主导当前主线：
  - V2 workflow takeover / round0 organization / enterprise_hub old dispatch chain

## 6. 当前主线基线裁决

- `我的楼 compact hub`、Package 1、`我的项目`、`flutter_screen_map`、`source_of_truth_map` 共同构成当前 `我的楼` 主线的正式基线。
- 当前主线的实现不是从零开始，必须吸收并沿用：
  - 现有前端 profile / my-project 资产
  - 现有 BFF / Server `my_project` 源码
- 当前主线同时必须识别并修复：
  - 生成投影落后于 `openapi.yaml`
  - 已有页面存在但仍是受控占位的部分
  - 已有实现存在但语义仍需按上位真源补齐的部分

## 7. Formal Conclusion

- 当前正式结论如下：
  - `我的楼 compact hub`、Package 1、`我的项目`、`flutter_screen_map`、`source_of_truth_map` 均为当前有效真源
  - `apps/mobile`、`apps/bff/src`、`apps/server/src` 中的相关页面与源码均为现有项目资产，必须纳入基线
  - 旧 V2 workflow / enterprise_hub 主派工链只保留为历史背景，不再主导当前主线
  - 任何生成投影滞后都只能被视为 projection drift，不能反向改写上位真源
