---
owner: Codex 总控
status: frozen
purpose: Freeze the runtime receipt showing that ED-5 public recommendation/list/detail has materially closed for the current factory listing and reroute the enterprise-display mainline to ED-6 home reflection.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/enterprise_display_full_closure_dispatch_master_addendum.md
  - docs/00_ssot/enterprise_display_runtime_rescan_and_stage_reroute_addendum.md
  - apps/server/src/modules/enterprise_hub/enterprise-hub-admin.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-query.service.ts
  - apps/server/src/modules/exhibition_home/exhibition-home.presenter.ts
---

# 《enterprise display ED-5 公域 recommendation 运行态落地回执单》

## 1. 裁决结论

- `ED-5 public recommendation / list / detail` 对当前 `factory` 板块已经形成真实运行态闭环。
- `list / detail` 先前已成立；本轮总控直接完成了 recommendation slot 的运行态落位。
- 自本回执生效后，enterprise-display 当前第一主线不再是：
  - `submit 前补资料`
  - `ED-5 recommendation 是否还是空态`
- 当前第一主线正式改判为：
  - `ED-6 home recommendation reflection`

## 2. 本轮总控直接执行的运行态动作

### 2.1 受控 slot 落位

- 目标 listing：
  - `enterpriseId = bf5ff83a-26e7-4138-8157-042fb38a5f46`
  - `boardType = factory`
- 总控已直接调用当前 active Server Admin path：
  - `POST /server/admin/exhibition/enterprise-hub/recommendation-slots`
- 受控 payload：
  - `boardType = factory`
  - `slotPosition = 1`
  - `enterpriseId = bf5ff83a-26e7-4138-8157-042fb38a5f46`
  - `startAt = 2026-04-10T18:51:07Z`
  - `endAt = 2026-05-10T18:51:07Z`
  - `sourceType = manual`
- 运行态结果：
  - `201 Created`
  - `{"ok":true,"traceId":"f65aea21-9081-4f10-ae55-bf6ce9f92320"}`

### 2.2 app-facing recommendation 读链验证

- 当前 active runtime：
  - `GET /api/app/exhibition/enterprise-hub/recommendations?boardType=factory`
- 当前返回不再为空：
  - 返回 `重庆坤特工厂样本`
  - `primaryBoardLabel = 优秀工厂`
  - `caseCount = 1`
  - `boardHighlights.factory.factoryName = 重庆坤特工厂`

## 3. 当前已经成立的公域链

### 3.1 list 已成立

- `GET /api/app/exhibition/enterprise-hub/enterprises?boardType=factory`
- 当前 published + visible factory entity 已可见

### 3.2 detail 已成立

- `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}?boardType=factory`
- 当前可回读：
  - header
  - basicInfo
  - boardProfile
  - contacts
  - certifications

### 3.3 recommendation 已成立

- 当前 `factory recommendation` 不再停留在 `items = []`
- recommendation 现在已经命中真实 published factory listing

## 4. 当前仍未成立的部分

- 当前 `home` 仍未把 enterprise recommendation 反射到首页 recommendation section。
- 当前 active runtime：
  - `GET /api/app/exhibition/home?provinceName=重庆市`
- 当前 recommendationSections 仍全部为空：
  - `project_recommendations.items = []`
  - `forum_hot_posts.items = []`
  - `company_factory_recommendations.items = []`
  - `worker_team_recommendations.items = []`
- 这与当前 `factory recommendation` 已经成立的 runtime 真相冲突。

## 5. 为什么当前主线必须切到 ED-6

- `ED-5` 当前已经不再是“没有真实 recommendation entity”。
- 真正未收口的是：
  - 首页 `company_factory_recommendations` 仍是空 carrier
  - 首页 Flutter 仍按 placeholder recommendation block 渲染
- 如果主线继续停留在 `ED-5`，只会重复验证已经成立的 `list / detail / recommendation`，浪费主线。

## 6. 当前唯一主线

- 当前 enterprise-display 唯一主线：
  - `ED-6 home recommendation reflection`
- 当前唯一目标：
  - 让首页 `company_factory_recommendations` 从空占位 section 进入真实 enterprise recommendation reflection

## 7. 当前下一步唯一动作

- 当前阶段完成度：
  - `ED-5 closure 完成`
- 当前下一步唯一动作：
  - 发出 `ED-6 home reflection backend execution prompt`
- 下一步执行角色：
  - `后端`
- 下一步进入条件：
  - 当前 `factory recommendation` 已在 active runtime 命中真实 published listing
  - 首页 `company_factory_recommendations.items` 仍为空，需要由 backend truth 先 materialize
