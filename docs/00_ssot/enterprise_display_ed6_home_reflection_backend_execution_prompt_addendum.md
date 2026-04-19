---
owner: Codex 总控
status: frozen
purpose: Freeze the backend execution prompt for ED-6 so the exhibition home company/factory recommendation section reflects real enterprise recommendation slot truth instead of static empty placeholders.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/enterprise_display_ed5_public_recommendation_runtime_materialization_receipt_addendum.md
  - docs/00_ssot/exhibition_home_ordered_marketplace_unified_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/server/src/modules/exhibition_home/exhibition-home.query.service.ts
  - apps/server/src/modules/exhibition_home/exhibition-home.presenter.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-query.service.ts
---

# 《enterprise display ED-6 home reflection backend 执行口令》

你现在是：
- enterprise display full closure mainline
- ED-6 home reflection backend owner

你的唯一目标是：
- 让 exhibition home 的 `company_factory_recommendations` section 反射真实 enterprise recommendation slot truth
- 收掉首页当前“recommendation section 全空，但 factory recommendation 已真实成立”的漂移

这一步只做：
- `/server/exhibition/home` recommendation section 的 backend truth materialization
- `company_factory_recommendations` section 的 read-model 收口
- 与此 section 直接相关的最小测试

这一步不做：
- 不改 `apps/mobile/**`
- 不改 `apps/bff/**`
- 不改 `apps/admin/**`
- 不重写 weather/location 模块
- 不扩到 `forum_hot_posts`
- 不扩到 `worker_team_recommendations`
- 不扩到新的 ranking / score / feed 逻辑
- 不改 `public list / detail / recommendation` 已通过链路
- 不做 release / deploy

当前已冻结事实：
1. `factory list / detail / recommendation` 已在 active runtime 成立。
2. 当前 active runtime：
   - `GET /api/app/exhibition/enterprise-hub/recommendations?boardType=factory`
   - 已返回 `重庆坤特工厂样本`
3. 当前 active runtime：
   - `GET /api/app/exhibition/home?provinceName=重庆市`
   - `company_factory_recommendations.items = []`
4. 当前 Server home 逻辑仍是静态空 section：
   - `apps/server/src/modules/exhibition_home/exhibition-home.presenter.ts`
5. 当前 BFF home transport 已能透传 `recommendationSections`，不是当前 blocker。

允许修改范围：
- 只允许修改：
  - `apps/server/src/modules/exhibition_home/**`
  - 如确有必要，可做最小 read-only 依赖接线到 enterprise hub query/recommendation carrier
  - 与本轮直接相关的最小测试文件
- 不允许修改：
  - `apps/bff/**`
  - `apps/mobile/**`
  - `apps/admin/**`
  - `apps/server/src/modules/enterprise_hub/**` 中已通过的 recommendation slot / public recommendation 链

你必须完成：
1. 让 `GET /server/exhibition/home` 的 `company_factory_recommendations` section 读取真实 enterprise recommendation carrier，而不是固定 `items: []`。
2. 该 section 只承接：
   - `company`
   - `factory`
   已发布且 `visible` 的 recommendation truth。
3. 该 section 必须保持 province-scoped：
   - 不得变成全国混合推荐流
4. 当前 `project_recommendations` / `forum_hot_posts` / `worker_team_recommendations` 可以继续保持现状；
   - 本轮只收 `company_factory_recommendations`
5. `company_factory_recommendations.items` 的 shape 必须继续对齐现有 home contract；
   - 不得自造第二套 item 字段族
6. 最小测试至少覆盖：
   - 有 active factory/company recommendation carrier 且 province 命中时，home section 返回真实 items
   - 无 recommendation carrier 时，home section 继续返回空 items
   - province 不命中时，不得把外省 recommendation 混入当前首页 section

你必须遵守：
1. 不得把 home 做成第二个 enterprise list 接口。
2. 不得引入 ranking/state machine。
3. 不得因为当前只有 factory 已成立，就把 sectionKey 改名。
4. 不得顺手扩写其他 home recommendation sections。
5. 不得通过伪造静态 item 让测试通过。

完成标准：
- `company_factory_recommendations.items` 在 active runtime 下能反射真实 published recommendation entity
- 首页 section 不再和 `enterprise-hub/recommendations` 的当前真相冲突
- 其他 home section 本轮保持原边界，不被误扩

交付回执要求：
1. 修改文件清单
2. 为什么当前 home section 仍为空
3. 现在如何把 `company_factory_recommendations` 对齐 recommendation slot truth
4. 新增或更新的测试结果
5. 仍未覆盖的非目标清单
