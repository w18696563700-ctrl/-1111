---
owner: Codex 总控
status: frozen
purpose: Freeze the latest enterprise-display runtime rescan after user-side completion progress and reroute the mainline away from stale submit-prep assumptions into post-submit disposition closure.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/enterprise_display_submit_chain_user_side_real_completion_runbook_addendum.md
  - docs/00_ssot/enterprise_display_full_closure_dispatch_master_addendum.md
  - apps/server/src/modules/enterprise_hub/enterprise-hub-workbench.query.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-workbench.presenter.ts
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart
---

# 《enterprise display runtime 重扫与阶段改判单》

## 1. 裁决结论

- 旧的《enterprise display submit chain 用户侧真实补齐操作单》当前已过期。
- 当前 enterprise-display 主线不再停留在：
  - `submit 前补资料`
- 当前真实所处位置已经推进到：
  - `application 已 approved`
  - `listing 已 published + visible`
- 因此当前第一主线必须改判为：
  - `post-submit disposition closure`

## 2. 最新 runtime 事实

### 2.1 上游与工作台前置已成立

- `organization.city truth` 已成立：
  - `510000 | 510100`
- 当前 organization certification 已重新成立且为：
  - `approved`
- listing `basic` 已成立：
  - `name = 重庆坤特工厂样本`
  - `shortIntro = 展台制作与木作工厂样本`
  - `cityCode = 500100`
  - `address = 重庆市渝北区金开大道 1 号`
  - `foundedAt = 2020-04-09`
- `factory profile` 已成立：
  - 当前 count = `1`
- `case` 已成立：
  - 当前 count = `1`
- `contact` 已成立：
  - 当前存在 primary contact

### 2.2 application / publish 状态已前进

- 当前 listing 下 application 不是“只有 draft”：
  - 存在一条较新的 `approved`
  - 仍残留一条较旧的 `draft`
- 当前最新 application：
  - `c1e83c6f-4637-407f-8d41-5c1413821874`
  - `applicationStatus = approved`
- 当前 listing：
  - `enterpriseStatus = published`
  - `displayStatus = visible`
  - `publishedAt` 已成立

### 2.3 公域链已部分成立

- app-facing list 已可见当前工厂实体：
  - `GET /api/app/exhibition/enterprise-hub/enterprises?boardType=factory`
  - 返回当前 `重庆坤特工厂样本`
- app-facing detail 已可见当前工厂详情：
  - `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}?boardType=factory`
  - header/basicInfo/boardProfile/contact/certification 已返回
- 当前 recommendation 仍为空：
  - `GET /api/app/exhibition/enterprise-hub/recommendations?boardType=factory`
  - `items = []`

## 3. 当前真实问题

- 用户看到“提交入驻申请一直灰色”，当前已不是因为 submit 前置没补齐。
- 当前更真实的问题是：
  - workbench 仍按 `submit-ready / blockers` 逻辑渲染提交区
  - 但 runtime 已经进入 `approved / published` 之后的状态
  - 因而页面继续展示灰 submit 会产生错误任务感

## 4. 当前为什么必须改判

- 如果继续沿用旧 runbook，控制链会误以为当前还缺：
  - 注册城市
  - 企业认证
  - basic
  - profile
  - case
- 这与当前 cloud runtime 真相已经冲突。
- 继续按旧 runbook 推进，只会重复用户已做过的动作，浪费主线。

## 5. 当前唯一主线

- 当前 enterprise-display 主线改判为：
  - `ED-3/ED-4 之后的 post-submit disposition closure`
- 当前唯一目标是：
  - 把 workbench 从“灰 submit + blocker”错误心智
  - 收口到“已通过/已上架后的正确后续动作”

## 6. 当前下一步唯一动作

- 当前阶段完成度：
  - `judgment 完成`
- 当前下一步唯一动作：
  - 发出 `enterprise display post-submit disposition frontend execution prompt`
- 下一步执行角色：
  - `前端`
- 下一步进入条件：
  - runtime 已确认 `approved + published + visible`
  - 当前问题已收敛为 workbench 提交区的 post-submit 呈现问题
