---
owner: Codex 总控
status: frozen
purpose: Formally freeze the backend and BFF implementation boundary for the current publish experience optimization, confirming that the stage remains Server/BFF-level no-op and does not widen behavior, carriers, or unrelated boards.
layer: L0 SSOT
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/current_publish_experience_optimization_truth_freeze_addendum.md
  - docs/00_ssot/current_publish_experience_optimization_contract_freeze_addendum.md
  - docs/00_ssot/current_publish_experience_optimization_persistence_freeze_addendum.md
  - 当前发布体验问题优先级排序 v1（已审核通过）
freeze_date_local: 2026-04-04
---

# 当前发布体验优化 backend-BFF implementation 冻结单

## 1. Scope

- 本冻结单只覆盖 `当前发布体验优化 backend-BFF implementation freeze`。
- 本冻结单只覆盖已经冻结的 6 项体验优化：
  - 发布失败原因提示改准
  - 发布成功态改成明确业务成功
  - 发布成功后增加“已发布项目预览”
  - 公域项目展示列表提密度、减解释
  - 公域项目详情继续去掉边界型噪音
  - 统一“我的项目 / 项目工作台 / 发布工作台”用户语言
- 本冻结单只裁定：
  - 本轮 backend / BFF implementation 是否整体 no-op
  - 是否允许改动 `apps/server/**`
  - 是否允许改动 `apps/bff/**`
- 本冻结单不进入：
  - Flutter 实现
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

## 2. Backend / BFF Implementation Freeze Conclusion

- 本轮 backend / BFF implementation freeze 的正式结论是：
  - `整体 no-op`
- 这 6 项体验优化全部不需要：
  - Server 改动
  - BFF 改动
  - 新增 route / controller / service / mapper / presenter / module wiring
  - 新增任何 backend / BFF 文案 carrier
- 因此本轮实现层的真实结论是：
  - `apps/server/**` 不改
  - `apps/bff/**` 不改
  - 后续唯一允许进入实现的方向是 Flutter 消费层

## 3. 发布失败提示相关 Backend / BFF 结论

- “失败原因说准”只依赖 Flutter 对现有：
  - load result
  - page state
  - message
  的正确消费。
- 本轮正式不需要：
  - Server 新错误码
  - BFF 新错误码
  - Server 新 blocked reason shaping
  - BFF 新 blocked reason shaping
- 当前正式写死：
  - 这是消费层解释修正
  - 不是后端改义

## 4. 发布成功态与成功后预览相关 Backend / BFF 结论

- 成功后项目预览只复用现有 create 成功结果与现有 list / detail 字段。
- 本轮正式不需要：
  - Server 新 preview endpoint
  - BFF 新 preview endpoint
  - Server 新 preview shaping
  - BFF 新 preview shaping
  - Server/BFF success-only carrier
- 当前正式写死：
  - 这只是 Flutter 页面内的结果复用
  - 不是后端功能扩展

## 5. 公域列表 / 公域详情相关 Backend / BFF 结论

- 列表密度优化完全不改：
  - `GET /api/app/project/list`
  - `GET /server/projects`
- 详情降噪完全不改：
  - `GET /api/app/project/detail`
  - `GET /server/projects/{projectId}`
- 当前正式写死：
  - 这些优化都只发生在 Flutter 展示层
  - 不改 Server / BFF 行为真义
  - 不改 response shaping 逻辑

## 6. `我的项目 / 项目工作台 / 发布工作台` 语言关系相关 Backend / BFF 结论

- 三者用户语言统一完全不需要改：
  - `GET /api/app/my/projects`
  - `GET /api/app/my/projects/{projectId}`
  - `GET /api/app/exhibition/workbench`
  - `POST /api/app/project/create`
  及其对应 server 实现。
- 当前正式写死：
  - 只改页面标题
  - 只改入口文案
  - 只改导流说明
  - 不改 backend / BFF

## 7. `exhibition_page_frames` 相关 Backend / BFF 结论

- 弱化框架“讲解感”完全不触碰 backend / BFF。
- 本轮正式不改：
  - retry
  - fallback
  - recovery route
  - controlled state
  的 backend / BFF 承接逻辑。
- 当前正式写死：
  - 这是前端框架语气调整
  - 不是中后端逻辑调整

## 8. 明确继续排除在本轮 Backend / BFF Implementation 外的范围

- 正式附件列表
- richer 私域状态真相
- `奖励金额`
- `单位平方面积金额`
- 搜索 / 地域分类页面 / 地图
- forum / 消息
- 订单平台化后台 / 合同后台 / 履约治理后台
- 其他无关板块

## 9. Allowed / Forbidden Implementation Conclusion

### 9.1 正式允许结论

- 本轮正式允许的实现推进方向只有：
  - Flutter 消费层

### 9.2 正式禁止结论

- 当前正式禁止为了“体验更顺”而在 BFF / Server 添加任何：
  - 临时字段
  - 临时 message
  - 临时 endpoint
  - preview 专用 carrier
  - error 专用 carrier
  - frame 专用 carrier

## 10. Explicit Guardrails

- 本轮 backend / BFF implementation freeze 的默认结论正式写死为：
  - `整体 no-op`
- 当前正式禁止：
  - 借本轮新增任何 Server / BFF 路由或字段
  - 借本轮改变任何现有 response 语义
  - 借本轮添加任何 preview / error / frame 专用 server / bff carrier
  - 借本轮影响任何无关板块 backend / BFF
  - 借本轮为后续 Flutter 实现便利而偷扩 backend / BFF

## 11. Stage Conclusion

- 当前结论：
  - `Go` for entering the `当前发布体验优化 frontend consumption freeze` stage
  - `No-Go` for直接进入 Flutter 实现
- 原因已正式冻结为：
  - 本轮体验优化在 backend / BFF implementation 层是否 no-op 已正式写清
  - 所有排除范围继续被写死
  - 未借机扩大 backend / BFF 变化面
  - 下一步应先进入 frontend consumption freeze，把 Flutter 页面消费边界与允许改动面正式冻结

## 12. 修订记录

- `v1.0` `2026-04-04`
  - 首版冻结“当前发布体验优化” backend-BFF implementation 边界。
  - 正式确认本轮 Server / BFF 实现层整体 no-op。
  - 正式确认 `apps/server/**` 与 `apps/bff/**` 本轮不应改动。
