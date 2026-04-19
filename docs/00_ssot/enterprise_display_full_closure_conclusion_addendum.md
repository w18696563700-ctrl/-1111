---
owner: Codex 总控
status: frozen
purpose: Freeze the final enterprise-display full-closure conclusion after correcting the stale ED-7 rerun receipt and reconciling active runtime evidence with frontend location-scope handoff validation.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/enterprise_display_ed7_full_chain_result_verification_conclusion_addendum.md
  - docs/00_ssot/enterprise_display_home_location_scope_handoff_frontend_result_verification_conclusion_addendum.md
  - docs/00_ssot/enterprise_display_ed6_home_reflection_backend_result_verification_conclusion_addendum.md
  - docs/00_ssot/enterprise_display_ed6_home_reflection_frontend_result_verification_conclusion_addendum.md
  - docs/00_ssot/enterprise_display_runtime_rescan_and_stage_reroute_addendum.md
---

# 《enterprise display full closure 结论单》

## 1. 最终裁决

- enterprise-display 主线当前：
  - `full closure passed`
- 旧的 `ED-7 rerun not pass` 回执当前不得作为最终结论继续沿用。

## 2. 为什么旧 `not pass` 结论被推翻

### 2.1 旧失败点是什么

- 旧回执唯一失败点写的是：
  - `home company_factory_recommendations`
  - 无参首页 `items = []`
  - 带 `provinceName` 或 `provinceCode + provinceName` 的首页请求 `400`

### 2.2 当前 active runtime 复核结果

- 在同一 active 版本：
  - `BFF = /srv/releases/bff/20260410233019/apps/bff`
  - `Server = /srv/releases/server/20260410233019`
- 总控直接复核得到：
  - `GET /api/app/exhibition/home -> 200`
    - `company_factory_recommendations.items = []`
  - `GET /api/app/exhibition/home?provinceName=重庆市 -> 200`
    - `company_factory_recommendations.items` 命中真实 factory entity
  - `GET /api/app/exhibition/home?provinceCode=500000&provinceName=重庆市 -> 200`
    - `company_factory_recommendations.items` 同样命中真实 factory entity
- 因此旧回执中的：
  - “带 carrier 的 home 请求直接 400”
  当前已被 active runtime 直接否定。

### 2.3 当前正确解释

- 无参首页返回空 recommendation section，是当前系统默认地区 carrier 的受控空态；
  这本身不是 through-chain 失败。
- 带省域 carrier 的首页请求已经可以反射：
  - 当前 published factory listing
- 同时，Flutter 首页自动 location handoff 的本地前端定向测试已通过，
  证明当前 app 代码在可行时已经会把 `provinceCode / provinceName` 带入默认首页加载。

## 3. 全链通过依据

### 3.1 `我的楼 -> 企业展示入驻`

- verifier 证据：
  - `profile/index` 返回当前 organization 与 approved certification
- 通过

### 3.2 `boardType 选择 / workbench`

- verifier 证据：
  - factory workbench 返回同一 enterprise/application
  - readiness truth 成立
- 通过

### 3.3 `application status`

- verifier 证据：
  - approved application 可回读
- 通过

### 3.4 `admin review / publish`

- verifier 证据：
  - approved application 与 published listing 连续成立
- 通过

### 3.5 `enterprise-hub recommendation / list / detail`

- verifier 证据：
  - recommendation / list / detail 全命中同一 `enterpriseId`
- 通过

### 3.6 `home company_factory_recommendations`

- 总控复核 active runtime：
  - 带 `provinceName` 或 `provinceCode + provinceName` 的首页请求均返回 `200`
  - `company_factory_recommendations` 已命中真实 factory entity
- 前端定向测试：
  - 自动 location handoff 会在可行时携带 `province scope`
  - 无 province scope 时保持受控空态
- 通过

## 4. enterprise-display 主线 closure 结论

- 从：
  - `我的楼入口`
  - `workbench`
  - `application`
  - `review/publish`
  - `public recommendation/list/detail`
  - `home reflection`
  当前已经形成同一真实对象链的 through-chain。

## 5. 当前残余风险

- 当前仍存在的只是非阻断残余：
  - 无参首页会保持系统默认地区的空 recommendation section
  - 这属于当前 location carrier 设计边界，不再属于 enterprise-display 主线未闭合
- 当前不再存在 enterprise-display 主线级 blocker。

## 6. 当前下一步唯一动作

- 当前阶段完成度：
  - `ED-7 closure 完成`
- 当前下一步唯一动作：
  - 交回总控，切换 enterprise-display 之外的下一条平台主线裁决
- 下一步执行角色：
  - `总控`
- 下一步进入条件：
  - enterprise-display full closure 结论已冻结
