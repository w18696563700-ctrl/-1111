---
owner: Codex 总控
status: frozen
purpose: Freeze the frontend execution prompt for closing the final enterprise-display blocker: the exhibition home automatic request does not yet carry province scope, so the company/factory recommendation section stays empty on default auto-load.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/enterprise_display_ed7_full_chain_result_verification_conclusion_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/exhibition_home_page.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_home_support.dart
  - apps/mobile/lib/core/location/device_location_service.dart
  - apps/server/src/modules/exhibition_home/exhibition-home.query.service.ts
---

# 《enterprise display home location scope handoff frontend 执行口令》

你现在是：
- enterprise display full closure mainline
- home location scope handoff frontend owner

你的唯一目标是：
- 收掉 enterprise-display 当前唯一剩余 blocker：
  - 首页自动请求未携带 province scope，导致 `company_factory_recommendations` 在默认加载时仍为空

这一步只做：
- Flutter 首页自动 location context 的 province-scope handoff
- 与此 handoff 直接相关的最小测试

这一步不做：
- 不改 `apps/server/**`
- 不改 `apps/bff/**`
- 不改 `apps/admin/**`
- 不重写 home recommendation section UI
- 不重写 weather card
- 不扩到 ranking/feed
- 不做 release / deploy

当前已冻结事实：
1. 当前 active runtime：
   - `GET /api/app/exhibition/home`
   - `company_factory_recommendations.items = []`
2. 当前 active runtime：
   - `GET /api/app/exhibition/home?provinceName=重庆市`
   - `company_factory_recommendations.items` 已返回真实 factory entity
3. 当前 Flutter 首页首次自动加载：
   - `_homeLocationContextFromSnapshot(...)`
   只透传：
   - `latitude`
   - `longitude`
   - `locationPermissionState`
4. 当前 home backend 过滤 recommendation scope 只认：
   - `provinceCode`
   - 或 `provinceName`
   不会从 `latitude/longitude` 自动反解 province。
5. 当前 blocker 已不在 backend truth，而在 frontend location scope handoff。

允许修改范围：
- 只允许修改：
  - `apps/mobile/lib/features/exhibition/presentation/exhibition_home_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/exhibition_home_support.dart`
  - `apps/mobile/lib/core/location/device_location_service.dart`
  - 与这条 handoff 直接相关的最小测试文件
- 不允许修改：
  - `apps/server/**`
  - `apps/bff/**`
  - `apps/admin/**`
  - 已通过的 `company_factory_recommendations` section 渲染逻辑

你必须完成：
1. 让首页自动请求在可行时向 home aggregation 传递可用的 province scope：
   - `provinceCode`
   - 或 `provinceName`
2. 不得把当前问题继续留给“只有手动选地区才有推荐”。
3. 若当前平台无法自动拿到 province scope，必须保持受控退化；
   - 但不得伪装成已完成
4. 不得新增第二套 home recommendation 状态机。
5. 最小测试至少覆盖：
   - 自动 location context 带上 province scope 时，首页默认加载就能命中 `company_factory_recommendations`
   - 无可用 province scope 时，仍保持受控空态

你必须遵守：
1. 不得改成首页直打 `/server/*`。
2. 不得伪造本地推荐数据。
3. 不得为了过关而写死 `重庆市` 或任何固定省份。
4. 不得顺手扩写其他 home sections。

完成标准：
- 首页默认自动加载路径在当前真实设备定位上下文里，能把 `company_factory_recommendations` 命中到真实 published listing
- 全链 through-chain 不再只在“手动带 provinceName”时成立

交付回执要求：
1. 修改文件清单
2. 为什么之前自动 home 请求没有带到 province scope
3. 现在如何保证自动路径也能命中 province-scoped recommendation
4. 新增或更新的测试结果
5. 仍未覆盖的非目标清单
