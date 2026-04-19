---
owner: Codex 总控
status: frozen
purpose: Freeze the corrected ED-7 through-chain verification conclusion after reconciling the result-verification receipt with current active runtime, backend home reflection truth, and Flutter home location-scope behavior.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/enterprise_display_ed6_home_reflection_backend_result_verification_conclusion_addendum.md
  - docs/00_ssot/enterprise_display_ed6_home_reflection_frontend_result_verification_conclusion_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/exhibition_home_page.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_home_support.dart
  - apps/server/src/modules/exhibition_home/exhibition-home.query.service.ts
---

# 《enterprise display ED-7 全链结果校验结论单》

## 1. 裁决结论

- enterprise-display 主线当前仍然：
  - `not pass`
- 但当前失败点必须纠正：
  - 不是“home backend reflection 仍未成立”
  - 而是“home 自动请求的省份 scope handoff 仍未闭合”

## 2. 为什么原 `not pass` 回执需要纠正

- 结果校验回执里把：
  - `GET /api/app/exhibition/home -> company_factory_recommendations.items = []`
  直接判成：
  - `home reflection failed`
- 这个结论不够精确，因为当前 active runtime 已证明：
  - `GET /api/app/exhibition/home?provinceName=重庆市`
  - `company_factory_recommendations.items` 已返回真实 factory entity
- 这说明：
  - backend reflection 已成立
  - frontend section 渲染也已成立
- 当前真正没闭合的是：
  - 首页自动初始请求没有把 province scope 带到 `home` 读链

## 3. 当前已通过环节

- `我的楼 -> 企业展示入驻`
- `boardType 选择 / workbench`
- `application status`
- `admin review / publish`
- `enterprise-hub recommendation / list / detail`
- `home company_factory_recommendations` 的 backend truth
- `home company_factory_recommendations` 的 frontend section consumption

## 4. 当前唯一 blocker

### 4.1 现象

- 当前 active runtime：
  - `GET /api/app/exhibition/home`
  - `company_factory_recommendations.items = []`
- 当前 active runtime：
  - `GET /api/app/exhibition/home?provinceName=重庆市`
  - `company_factory_recommendations.items` 已返回真实 entity

### 4.2 根因

- Flutter 首页首次请求来源于：
  - `apps/mobile/lib/features/exhibition/presentation/exhibition_home_page.dart`
  - `_refreshWholePage() -> _homeLocationContextFromSnapshot(locationSnapshot)`
- 当前 `_homeLocationContextFromSnapshot(...)` 只透传：
  - `latitude`
  - `longitude`
  - `locationPermissionState`
- 当前没有透传：
  - `provinceCode`
  - `provinceName`
  - `cityName`
- 而当前 `apps/server/src/modules/exhibition_home/exhibition-home.query.service.ts`
  只按：
  - `provinceCode`
  - 或 `provinceName`
  做当前 recommendation province scope 过滤，
  不会从 `latitude/longitude` 反解 province。

### 4.3 结论

- 当前 through-chain 未闭合的唯一原因是：
  - `home automatic request -> province scope handoff` 未成立
- 不是：
  - recommendation slot truth 缺失
  - home backend 仍固定空 section
  - home frontend 仍固定 placeholder

## 5. 当前主线改判

- 当前 enterprise-display 主线正式改判为：
  - `home location scope handoff closure`
- 当前第一执行角色应为：
  - `前端`

## 6. 当前下一步唯一动作

- 当前阶段完成度：
  - `ED-7 result verification not pass`
- 当前下一步唯一动作：
  - 发出 `enterprise display home location scope handoff frontend execution prompt`
- 下一步执行角色：
  - `前端`
- 下一步进入条件：
  - backend reflection 与 frontend section rendering 已通过
  - 唯一剩余 blocker 已收窄为首页自动请求的 province scope handoff
