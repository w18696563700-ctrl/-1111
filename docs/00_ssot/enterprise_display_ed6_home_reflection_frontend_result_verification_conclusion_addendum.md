---
owner: Codex 总控
status: frozen
purpose: Freeze the result verification conclusion for ED-6 frontend after confirming the exhibition home now consumes real company/factory recommendation items instead of a static placeholder section.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/enterprise_display_ed6_home_reflection_frontend_execution_prompt_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/exhibition_home_page.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_home_recommendation_section.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_home_support.dart
  - apps/mobile/test/exhibition_home_test.dart
---

# 《enterprise display ED-6 home reflection frontend 结果验收结论单》

## 1. 裁决结论

- `ED-6 frontend home reflection` 通过。
- Flutter 首页当前已经不再把 `本省优秀公司与工厂` 固定渲染成 placeholder。
- 当前 enterprise-display 主线正式进入：
  - `ED-7 full-chain result verification`

## 2. 验收证据

### 2.1 页面接线成立

- `apps/mobile/lib/features/exhibition/presentation/exhibition_home_page.dart`
  - 当前已从 home aggregation payload 读取：
    - `company_factory_recommendations`
  - 当前已用 `_HomeCompanyFactoryRecommendationSection` 取代原写死的：
    - `_HomePlaceholderRecommendationSection(title: '3. 本省优秀公司与工厂', ...)`

### 2.2 section 消费成立

- `apps/mobile/lib/features/exhibition/presentation/exhibition_home_support.dart`
  - 当前已解析：
    - `itemType`
    - `entityId`
    - `title`
    - `summary`
    - `badgeLabel`
- 当前 route handoff：
  - `company + entityId -> company detail`
  - `factory + entityId -> factory detail`
  - `缺 entityId -> 回退 board list`

### 2.3 recommendation section 渲染成立

- `apps/mobile/lib/features/exhibition/presentation/exhibition_home_recommendation_section.dart`
  - 当前 `items` 非空时渲染真实 recommendation cards
  - 当前 `items` 为空时才回退 placeholder
- 这满足：
  - 真实态和空态边界清晰
  - 首页不再固定显示“持续完善中”

### 2.4 定向测试成立

- 通过：
  - `flutter test test/exhibition_home_test.dart --plain-name "exhibition home renders real company factory recommendation items from aggregation section"`
  - `flutter test test/exhibition_home_test.dart --plain-name "exhibition home keeps controlled placeholder when company factory recommendation items are empty"`
  - `flutter test test/exhibition_home_test.dart --plain-name "exhibition home company factory recommendation item opens existing enterprise detail route"`
- 当前 3 条目标用例全部通过

## 3. 当前仍未覆盖的部分

- 这轮没有重写：
  - `project_recommendations`
  - `forum_hot_posts`
  - `worker_team_recommendations`
- 这轮也没有重跑整份 `exhibition_home_test.dart` 全量 suite；
  - 已知仍有一条无关既有失败：
    - `exhibition showcase keeps showcase semantics separate from workbench`
- 上述残余风险不阻断当前 enterprise-display 主线过门。

## 4. 当前主线改判

- enterprise-display 当前主线不再停留在：
  - `ED-6 home reflection`
- enterprise-display 当前唯一主线改判为：
  - `ED-7 full-chain result verification`

## 5. 当前下一步唯一动作

- 当前阶段完成度：
  - `ED-6 frontend closure 完成`
- 当前下一步唯一动作：
  - 发出 `ED-7 full-chain result verification prompt`
- 下一步执行角色：
  - `结果校验`
- 下一步进入条件：
  - 私域 workbench
  - application submit/status
  - admin review/publish
  - public recommendation/list/detail
  - home reflection
  当前都已至少形成最小运行态证据
