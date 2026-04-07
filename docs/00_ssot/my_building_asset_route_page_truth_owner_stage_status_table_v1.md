---
owner: Codex 总控
status: frozen
purpose: 逐项登记“我的楼”主线当前资产、路由、页面归属、truth owner、阶段状态与禁止误判点，避免把已存在资产写丢或把占位页误写成 fully open。
layer: L0 SSOT
freeze_date_local: 2026-04-05
inputs_canonical:
  - docs/00_ssot/new_workflow_v3_takeover_declaration.md
  - docs/00_ssot/seven_role_organization_freeze_v3.md
  - docs/00_ssot/my_building_effective_truth_baseline_ruling_v1.md
  - docs/00_ssot/my_building_effective_truth_mother_file_v1.md
  - docs/00_ssot/my_building_mainline_v1_three_column_ruling.md
  - docs/00_ssot/my_building_round1_increment_dispatch.md
  - docs/00_ssot/my_building_next_unique_action.md
---

# 《我的楼当前资产 / 路由 / 页面 / truth owner / 阶段状态总表 V1》

## 1. 状态口径

- 本总表只做：
  - 当前现有资产、route owner、page owner、truth owner、阶段状态登记
- 本总表不做：
  - 三栏裁决改写
  - Round 1 派工边界改写
  - implementation unlock authoring
- `已存在资产`：
  - 仓库中已有代码 / 页面 / 路由 / 源码模块，必须纳入当前基线
- `受控占位`：
  - 页面或入口已存在，但当前仍明确不是完整 happy path
- `语义待补齐`：
  - 已有实现存在，但仍需按上位真源补齐或校正业务语义
- `docs-frozen`：
  - 真源或 contracts 已冻结，但该项不自动等于 fully open

## 2. 总表

| 能力项 | 首层入口归属 | 路由 / 页面归属 | Truth owner | 当前阶段状态 | 现有资产 / 依据 | 禁止误判点 |
|---|---|---|---|---|---|---|
| `我的楼` 首层聚合 | `profile` 首层 | `ProfilePage` | `Server` 经 `BFF` shaping | 已存在资产；Round 1 以语义对齐为主 | `apps/mobile/lib/features/profile/presentation/profile_page.dart`；`docs/00_ssot/profile_my_building_compact_hub_boundary_addendum.md` | 不得误判成第二论坛首页或第二工作台 dashboard |
| 顶部个人摘要 -> 个人资料 | 顶部摘要区 | `ProfilePersonalPage` / `ProfileRoutes.personal` | `Server` | 已存在资产 | `apps/mobile/lib/features/profile/navigation/profile_routes.dart`；`apps/mobile/lib/features/profile/presentation/profile_detail_pages.dart` | 不得误判成 public profile |
| `我的公司` | `我的楼` 首层常用入口 | `ProfileCompanyPage` / `ProfileRoutes.company` | `Server` organization / certification truth | 已存在资产；属于 Package 1 bounded consumption | `apps/mobile/lib/features/profile/presentation/profile_page.dart`；`apps/mobile/lib/features/profile/presentation/profile_detail_pages.dart` | 不得误判成企业管理后台、admin review desk 或第二 truth root |
| `认证与成员身份` | `我的楼` 首层常用入口 | `CertificationStatusPage` / `ProfileIdentityRoutes.certificationCurrent` | `Server` | 已存在资产；当前以 current-state consumption 为主 | `apps/mobile/lib/features/profile/presentation/profile_identity_access_pages.dart`；Package 1 上游真源链 | 不得把 docs-frozen / current page 误判成完整 submit/resubmit 中心已 fully open |
| 登录入口 | Package 1 下游页，不单列首层按钮 | `LoginEntryPage` / `ProfileIdentityRoutes.login` | `Server` session truth，经 `BFF` shaping | 已存在资产 | `apps/mobile/lib/features/profile/presentation/profile_identity_access_pages.dart` | 不得把当前 OTP 最小闭环误写成完整账户系统已全部落成 |
| 组织承接 | Package 1 下游页 | `OrganizationHandoffPage` / `ProfileIdentityRoutes.organizationHandoff` | `Server` organization truth | 已存在资产；当前受控只读消费 | `apps/mobile/lib/features/profile/presentation/profile_organization_pages.dart` | 不得把组织摘要页误写成完整 create / join / switch happy path |
| 创建组织 | 无首层直达 | `OrganizationCreatePage` / `ProfileIdentityRoutes.organizationCreate` | `Server` | 页面存在，但当前是受控占位 | `apps/mobile/lib/features/profile/presentation/profile_organization_pages.dart` | 不得误判成创建组织已接通 |
| 加入组织 | 无首层直达 | `OrganizationJoinPage` / `ProfileIdentityRoutes.organizationJoin` | `Server` | 页面存在，但当前是受控占位 | `apps/mobile/lib/features/profile/presentation/profile_organization_pages.dart` | 不得误判成加入组织已接通 |
| 会话与设备 | `设置 -> 账号与安全` | `SessionCenterPage` / `ProfileIdentityRoutes.sessionCenter` | `Server` session / device-security truth | 页面存在，但当前是受控占位 | `apps/mobile/lib/features/profile/presentation/profile_identity_access_pages.dart` 明确写明 `security devices` 待开放 | 不得误判成 `/api/app/profile/security/devices*` 已 fully open |
| `我的项目` 入口 | `我的楼` 首层常用入口 | `ProfilePage` 中 handoff 到 `ExhibitionRoutes.myProjectList` | `Server.project` 与下游既有业务真相，经 `BFF` shaping | 已存在资产；当前主线必做 | `apps/mobile/lib/features/profile/presentation/profile_page.dart` | 不得把入口 owner 写成 truth owner；不得写成 `项目工作台` |
| `我的项目` 列表 | `我的楼 -> 我的项目` | `MyProjectListPage` / `ExhibitionRoutes.myProjectList` | `Server` | 已存在资产；语义待补齐与联调验证 | `apps/mobile/lib/features/exhibition/presentation/pages/my_project_list_page.dart`；`apps/bff/src/routes/my_project/**`；`apps/server/src/modules/my_project/**`；`docs/01_contracts/openapi.yaml` | 不得把 `历史项目` 直接写成 `已完成` 或 `已评价`；不得改义成公域展示页 |
| `我的项目` 详情 | `我的楼 -> 我的项目` | `MyProjectDetailPage` / `ExhibitionRoutes.myProjectDetail` | `Server` | 已存在资产；语义待补齐 | `apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart`；`apps/server/src/modules/my_project/my-project.presenter.ts` 当前仍输出默认 `privateProgress` | 不得把 `plannedEndAt` 当正式完结；不得把默认占位 privateProgress 写成真实业务闭环已完成 |
| `我的论坛` | `我的楼` 首层常用入口 | `ProfileForumPage` / `ProfileRoutes.forum` | `Server` forum truth | 已存在资产；边界已清晰 | `apps/mobile/lib/features/profile/presentation/profile_forum_pages.dart` | 不得误判成第二论坛首页；只承接 me-assets |
| `设置` | `我的楼` 首层底部入口 | `ProfileSettingsPage` / `ProfileRoutes.settings` | `Server` bounded account/security truth + client grouping | 已存在资产 | `apps/mobile/lib/features/profile/presentation/profile_detail_pages.dart` | 不得误判成 IM-only settings、audio-call settings 或治理后台 |
| `my-project` server read family | 无首层入口 | `apps/server/src/modules/my_project/**` | `Server` | 已存在资产；当前 presenter 仍偏最小占位，需要 Round 1 补齐 | `MyProjectController`、`MyProjectQueryService`、`MyProjectPresenter` | 不得误判成私域进度 read 已 fully aligned 上游 truth |
| `my-project` BFF shaping family | 无首层入口 | `apps/bff/src/routes/my_project/**` | `BFF` 只做 shaping | 已存在资产；需按 contracts 与错误归一复核 | `MyProjectController`、`MyProjectService` | 不得误判成 `BFF` 拥有 `my-project` truth |
| contracts generated projection | 无首层入口 | `packages/contracts/src/generated/app-api.types.ts` 与 `apps/bff/dist/packages/contracts/src/generated/app-api.types.d.ts` | 无 truth owner；仅 projection | 存在 projection drift | 生成投影当前未包含 `/api/app/my/projects*` | 不得拿 projection drift 反向否定 `openapi.yaml` 与 `my-project` 上位真源 |

## 3. 当前总表结论

- `我的楼` 主线当前不是空白盘面，而是：
  - 上位真源已冻结
  - profile / my-project 现有页面已存在
  - BFF / Server `my_project` 源码已存在
- 当前真正需要区分的是三类状态：
  - `可沿用的现有资产`
  - `页面存在但仍属受控占位`
  - `实现存在但语义仍需补齐`
- 当前真正需要保持不变的是两条边界：
  - [my_building_mainline_v1_three_column_ruling.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_mainline_v1_three_column_ruling.md) 的三栏裁决不被本表改写
  - [my_building_round1_increment_dispatch.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_round1_increment_dispatch.md) 的执行边界不被本表改写

## 4. Formal Conclusion

- 当前正式结论如下：
  - `我的楼`、Package 1、`我的项目` 的关键页面与路由资产都已存在
  - `我的项目` 的 app-facing 与 server-side family 已有源码，不得被误写成“尚未开始”
  - `会话与设备`、`组织 create/join` 仍属受控占位，不得被误写成 fully open
  - generated projection drift 只是 projection 问题，不是 truth 问题
  - 本总表现已完成正式版收口，但它仍然只是登记文书，不是三栏裁决替代文书，也不是 Round 1 派工替代文书
