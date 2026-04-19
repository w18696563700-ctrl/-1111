---
owner: Codex 总控
status: frozen
purpose: Freeze the result verification conclusion for ED-6 backend home reflection after validating code, tests, and active runtime alignment.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/enterprise_display_ed6_home_reflection_backend_execution_prompt_addendum.md
  - apps/server/src/modules/exhibition_home/exhibition-home.presenter.ts
  - apps/server/src/modules/exhibition_home/exhibition-home.query.service.ts
  - apps/server/src/modules/exhibition_home/exhibition-home.module.ts
  - apps/mobile/lib/features/exhibition/presentation/exhibition_home_page.dart
---

# 《enterprise display ED-6 home reflection backend 结果验收结论单》

## 1. 裁决结论

- `ED-6 home reflection backend` 通过。
- 当前 backend 已经把首页 `company_factory_recommendations` 从静态空 section 收到真实 enterprise recommendation carrier。
- 当前 `ED-6` 未完成部分已经不在 backend，而在 Flutter 首页消费面。

## 2. 验收证据

### 2.1 代码证据成立

- `apps/server/src/modules/exhibition_home/exhibition-home.query.service.ts`
  - 已接入：
    - `EnterpriseRecommendationSlotEntity`
    - `EnterpriseListingEntity`
  - 已按当前 location scope 读取 `company/factory` active recommendation carrier
- `apps/server/src/modules/exhibition_home/exhibition-home.presenter.ts`
  - `company_factory_recommendations` 不再固定 `items: []`
  - 已将 backend item 映射到当前 home contract：
    - `itemType`
    - `entityId`
    - `title`
    - `summary`
    - `badgeLabel`
    - `placeholder`
- `apps/server/src/modules/exhibition_home/exhibition-home.module.ts`
  - 已完成最小 repository wiring

### 2.2 定向测试成立

- `npm run build`：
  - 通过
- `node --test test/exhibition-home-recommendation-reflection.test.cjs`：
  - `3/3` 通过
- 当前测试覆盖：
  - 当前省 recommendation 命中时返回真实 items
  - 无 carrier 时返回空 items
  - 外省 recommendation 不混入当前首页

### 2.3 active runtime 成立

- 当前 active runtime：
  - `GET /api/app/exhibition/home?provinceName=重庆市`
- 当前 `company_factory_recommendations` 已返回：
  - `item_count = 1`
  - `itemType = factory`
  - `entityId = bf5ff83a-26e7-4138-8157-042fb38a5f46`
  - `title = 重庆坤特工厂样本`
  - `summary = 展台制作与木作工厂样本`
  - `badgeLabel = 优秀工厂`
- 当前首页 backend truth 已不再和：
  - `GET /api/app/exhibition/enterprise-hub/recommendations?boardType=factory`
  冲突

## 3. 当前仍未通过的部分

- Flutter 首页消费面仍未接这条真实 section。
- 当前 `apps/mobile/lib/features/exhibition/presentation/exhibition_home_page.dart`
  仍把：
  - `3. 本省优秀公司与工厂`
  渲染成 `_HomePlaceholderRecommendationSection`
- 这意味着：
  - backend truth 已成立
  - 首页用户面仍停留在 placeholder

## 4. 当前主线改判

- 当前 enterprise-display 主线不再是：
  - `ED-6 backend`
- 当前唯一主线改判为：
  - `ED-6 frontend home reflection`

## 5. 当前下一步唯一动作

- 当前阶段完成度：
  - `ED-6 backend closure 完成`
- 当前下一步唯一动作：
  - 发出 `ED-6 frontend home reflection execution prompt`
- 下一步执行角色：
  - `前端`
- 下一步进入条件：
  - 首页 backend `company_factory_recommendations.items` 已在 active runtime 返回真实 entity
  - Flutter 首页当前仍是 placeholder，需要消费已冻结 carrier
