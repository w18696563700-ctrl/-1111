---
owner: Codex 总控
status: frozen
purpose: Freeze the frontend execution prompt for ED-6 so the exhibition home page consumes the newly materialized company/factory recommendation section instead of rendering a static placeholder card.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/enterprise_display_ed6_home_reflection_backend_result_verification_conclusion_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/exhibition_home_page.dart
  - apps/mobile/lib/features/exhibition/data/exhibition_home_aggregation_client.dart
  - apps/server/src/modules/exhibition_home/exhibition-home.presenter.ts
---

# 《enterprise display ED-6 home reflection frontend 执行口令》

你现在是：
- enterprise display full closure mainline
- ED-6 home reflection frontend owner

你的唯一目标是：
- 让 Flutter 首页把 `company_factory_recommendations` 从 placeholder 卡切成真实 recommendation section
- 让用户在首页直接看到已发布的 `优秀公司 / 优秀工厂` 实体，而不是“持续完善中”的说明卡

这一步只做：
- `首页 -> 本省优秀公司与工厂` section 的前端消费
- section item 渲染
- 与此 section 直接相关的最小跳转与测试

这一步不做：
- 不改 `apps/server/**`
- 不改 `apps/bff/**`
- 不改 `apps/admin/**`
- 不重写 weather card
- 不重写 `project_recommendations`
- 不重写 `forum_hot_posts`
- 不重写 `worker_team_recommendations`
- 不扩到 ranking/feed
- 不做 release / deploy

当前已冻结事实：
1. 首页 backend 当前已返回：
   - `recommendationSections[].sectionKey = company_factory_recommendations`
   - `items` 不再为空
2. 当前 active runtime 下已存在真实 item：
   - `itemType = factory`
   - `entityId = bf5ff83a-26e7-4138-8157-042fb38a5f46`
   - `title = 重庆坤特工厂样本`
   - `summary = 展台制作与木作工厂样本`
   - `badgeLabel = 优秀工厂`
3. 当前 Flutter 首页仍然把这一段写死为：
   - `_HomePlaceholderRecommendationSection(title: '3. 本省优秀公司与工厂', ...)`
4. 当前 blocker 已不在 backend，而在 Flutter 消费面未切换。

允许修改范围：
- 只允许修改：
  - `apps/mobile/lib/features/exhibition/presentation/exhibition_home_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/exhibition_home_recommendation_section.dart`
  - `apps/mobile/lib/features/exhibition/presentation/exhibition_home_support.dart`
  - `apps/mobile/test/**` 中与首页 section 直接相关的最小测试
- 不允许修改：
  - `apps/server/**`
  - `apps/bff/**`
  - `apps/admin/**`
  - `enterprise-hub` 已通过链路

你必须完成：
1. 把首页 `3. 本省优秀公司与工厂` 从 placeholder section 改成真实 recommendation section。
2. 该 section 只消费：
   - `company_factory_recommendations`
   的当前 contract carrier。
3. 当 `items` 非空时：
   - 渲染真实 item card
   - 用户可点击进入对应 `company` / `factory` 公域详情或列表承接路径
4. 当 `items` 为空时：
   - 才允许回退到当前受控 placeholder / empty 态
5. 不得把这条 section 和模块入口混成同一块。
6. 不得伪造本地推荐数据。
7. 最小测试至少覆盖：
   - `company_factory_recommendations.items` 非空时，首页渲染真实 recommendation item
   - `items` 为空时，首页仍可回退空态
   - 点击真实 item 时进入既有安全承接路径

你必须遵守：
1. 不得顺手扩写其他 recommendation sections。
2. 不得发明新的 item 字段族。
3. 不得改成首页直接打 `/server/*`。
4. 不得把首页 section 重写成第二个完整企业列表页。
5. 不得掩盖当前空态与真实态的边界。

完成标准：
- 首页 `本省优秀公司与工厂` 不再固定显示“持续完善中”
- 当前 active runtime 下能直接看到真实 `factory/company` item
- 空态和真实态边界清晰
- 跳转继续承接既有公域路径

交付回执要求：
1. 修改文件清单
2. 为什么之前首页仍是 placeholder
3. 现在如何消费 `company_factory_recommendations`
4. 新增或更新的测试结果
5. 仍未覆盖的非目标清单
