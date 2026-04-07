---
owner: Codex 总控
status: frozen
purpose: Formally freeze the persistence boundary for the current publish experience optimization, confirming that the stage remains persistence-level no-op and does not widen business truth, persistence carriers, or migration scope.
layer: L0 SSOT
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/current_publish_experience_optimization_truth_freeze_addendum.md
  - docs/00_ssot/current_publish_experience_optimization_contract_freeze_addendum.md
  - 当前发布体验问题优先级排序 v1（已审核通过）
freeze_date_local: 2026-04-04
---

# 当前发布体验优化 persistence 冻结单

## 1. Scope

- 本冻结单只覆盖 `当前发布体验优化 persistence freeze`。
- 本冻结单只覆盖已经冻结的 6 项体验优化：
  - 发布失败原因提示改准
  - 发布成功态改成明确业务成功
  - 发布成功后增加“已发布项目预览”
  - 公域项目展示列表提密度、减解释
  - 公域项目详情继续去掉边界型噪音
  - 统一“我的项目 / 项目工作台 / 发布工作台”用户语言
- 本冻结单只裁定：
  - 本轮 persistence 是否整体 no-op
  - 是否需要任何新增 persistence truth
  - 是否需要任何 additive migration
- 本冻结单不进入：
  - backend / BFF / Flutter 实现
- 本冻结单继续排除：
  - 正式附件列表 read truth / visibility truth
  - `我的项目` richer 私域状态真相接入
  - 发布资格与认证真相重构
  - `奖励金额`
  - `单位平方面积金额`
  - 搜索界面
  - 地域分类页面
  - 地图 / 经纬度
  - forum / 消息
  - 订单平台化后台
  - 合同后台
  - 履约治理后台
  - 其他无关板块

## 2. Persistence Freeze Conclusion

- 本轮 persistence freeze 的正式结论是：
  - `整体 no-op`
- 这 6 项体验优化全部不需要：
  - 新增 persistence truth
  - 新增列
  - 新增表
  - 新增 snapshot
  - 新增 materialized view
  - 新增任何 additive migration
- 因此本轮在持久化层的真实任务不是扩面，而是：
  - 正式写死 no-op 边界

## 3. 发布失败提示相关 Persistence 结论

- “失败原因说准”完全依赖现有：
  - load result
  - controlled page state
  - response message
  的消费承接。
- 本轮正式不需要任何 DB 层或持久化层支撑变更。
- 当前正式禁止新增：
  - 错误映射持久化真相
  - failure snapshot
  - blocked reason table
  - page-state persistence carrier

## 4. 发布成功态与成功后预览相关 Persistence 结论

- 成功后项目预览完全复用现有已存在字段。
- 本轮正式不需要：
  - preview snapshot
  - success-only persistence carrier
  - success result cache table
  - preview-specific materialized view
- 当前正式禁止为了预览新增任何项目字段。
- 当前正式禁止为了预览新增：
  - 附件 carrier
  - 私域状态 snapshot
  - `奖励金额`
  - `单位平方面积金额`

## 5. 公域列表 / 公域详情相关 Persistence 结论

- 列表密度优化完全不改：
  - `public.project`
  - 及其当前已冻结的 list read truth 来源
- 详情降噪完全不改：
  - shared `ProjectReadModel` 对应的 persistence truth
  - 及其当前已冻结的 detail read truth 来源
- 当前正式写死：
  - 这些都只是消费层表现优化
  - 不动 persistence
  - 不动 read source
  - 不动 underlying truth carrier

## 6. `我的项目 / 项目工作台 / 发布工作台` 语言关系相关 Persistence 结论

- 三者用户语言统一完全不涉及 persistence。
- 本轮正式不新增：
  - 入口级持久化标记
  - 页面关系 snapshot
  - route ownership marker
  - diversion / guidance persistence carrier
- 当前正式冻结为：
  - 只改用户语言
  - 不改任何读写真相

## 7. `exhibition_page_frames` 相关 Persistence 结论

- 弱化“讲解感”完全不触碰 persistence。
- 本轮正式不新增：
  - frame-level persistence carrier
  - frame-specific snapshot
  - frame-specific state cache table
- 本轮正式不改变：
  - controlled state
  - retry
  - fallback
  - recovery route
  背后的持久化真义。
- 当前正式写死：
  - 这轮只弱化“讲解感”
  - 不改任何 persistence behavior

## 8. 明确继续排除在本轮 Persistence 外的范围

- 正式附件列表
- richer 私域状态真相
- `奖励金额`
- `单位平方面积金额`
- 搜索 / 地域分类页面 / 地图
- forum / 消息
- 订单平台化后台 / 合同后台 / 履约治理后台
- 其他无关板块

## 9. Migration 边界结论

- 本轮不需要任何 additive migration。
- 当前正式写死：
  - `0` 条新增 migration
  - `0` 条新增列
  - `0` 张新增表
  - `0` 个新增 snapshot
  - `0` 个新增 materialized view
- 当前正式禁止：
  - 为体验优化便利偷扩 project / my-project / workbench 持久化字段面
  - 为实现便利新增 preview / error / frame 专用持久化载体

## 10. Explicit Persistence Guardrails

- 本轮 persistence freeze 的默认结论正式写死为：
  - `整体 no-op`
- 当前正式禁止：
  - 借本轮新增任何业务真相 carrier
  - 借本轮新增任何 preview / error / frame 专用持久化载体
  - 借本轮扩大 project / my-project / workbench 的持久化字段面
  - 借本轮影响任何无关板块 persistence
  - 借本轮为后续实现便利而偷扩 persistence

## 11. Stage Conclusion

- 当前结论：
  - `Go` for entering the `当前发布体验优化 backend-BFF implementation freeze` stage
  - `No-Go` for直接进入实现
- 原因已正式冻结为：
  - 本轮体验优化在 persistence 层是否 no-op 已正式写清
  - 所有排除范围继续被写死
  - `0 migration / 0 新增列 / 0 新增表 / 0 snapshot` 已被正式写清
  - 下一步若继续推进，应先进入 backend-BFF implementation freeze，明确实现层是否同样保持 no-op 或仅允许前端消费层实施

## 12. 修订记录

- `v1.0` `2026-04-04`
  - 首版冻结“当前发布体验优化” persistence 边界。
  - 正式确认本轮 persistence 层整体 no-op。
  - 正式确认 `0 migration / 0 新增列 / 0 新增表 / 0 snapshot / 0 materialized view`。
