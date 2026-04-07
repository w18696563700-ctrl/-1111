---
owner: Codex 总控
status: frozen
purpose: Formally freeze the contract boundary for the current publish experience optimization, confirming that the stage remains contract-level no-op and does not widen business meaning, schemas, or paths.
layer: L0 SSOT
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/current_publish_experience_optimization_truth_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
  - 当前发布体验问题优先级排序 v1（已审核通过）
freeze_date_local: 2026-04-04
---

# 当前发布体验优化 contract 冻结单

## 1. Scope

- 本冻结单只覆盖 `当前发布体验优化 contract freeze`。
- 本冻结单只覆盖已经冻结的 6 项体验优化：
  - 发布失败原因提示改准
  - 发布成功态改成明确业务成功
  - 发布成功后增加“已发布项目预览”
  - 公域项目展示列表提密度、减解释
  - 公域项目详情继续去掉边界型噪音
  - 统一“我的项目 / 项目工作台 / 发布工作台”用户语言
- 本冻结单只裁定：
  - 本轮 contract 是否整体 no-op
  - 哪些 path / schema 明确保持 no-op
  - 哪些体验项只允许作为消费层表达优化
- 本冻结单不进入：
  - persistence freeze
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

## 2. Contract Freeze Conclusion

- 本轮 contract freeze 的正式结论是：
  - `整体 no-op`
- 这 6 项体验优化原则上全部属于：
  - 消费表达层优化
  - 页面文案与结果承接优化
  - 信息密度与说明型文案优化
  - 页面关系语言收口
- 本轮正式不需要：
  - 新增 path
  - 新增 schema
  - 修改现有 request / response 字段真义
  - 新增 preview 专属 schema
  - 新增 error 专属 schema
- 因此本轮 contract 层的真实任务不是扩面，而是：
  - 正式写死 no-op 边界

## 3. 发布失败提示相关 Contract 结论

- 本轮“失败原因说准”继续依赖现有：
  - load result
  - controlled page state
  - response message
  的承接能力。
- 本轮正式不新增：
  - 专门错误 contract
  - 新的 failure code
  - 新的 blocked schema
- 当前正式冻结为：
  - 只允许在消费层对已有 `message / state` 做正确映射
  - 不改接口真义
- 这意味着：
  - `POST /api/app/project/create`
  - `GET /api/app/exhibition/workbench`
  - 相关现有受控状态 contract
  继续保持 no-op

## 4. 发布成功态与成功后预览相关 Contract 结论

- 成功后项目预览完全复用现有创建结果与现有 detail / list 字段。
- 本轮正式不新增：
  - preview 专属 schema
  - create-success 专属 path
  - success-only read model
- 当前正式冻结为：
  - Flutter 只允许用现有字段做“列表卡片式预览”
  - contract 层不产生任何新增字段
- 当前正式禁止：
  - 为预览新增字段
  - 为预览引入附件、私域状态、奖励金额、单位平方面积金额

## 5. 公域列表 / 公域详情相关 Contract 结论

- 列表密度优化完全不改：
  - `GET /api/app/project/list`
  - `GET /server/projects`
  的 contract 真义。
- 详情降噪完全不改：
  - `GET /api/app/project/detail`
  - `GET /server/projects/{projectId}`
  的 contract 真义。
- 当前正式冻结为：
  - 这些页面优化都只是消费层重排、弱化说明文案、收缩卡片
  - 不动 response schema
  - 不动字段 owner
  - 不动字段 meaning

## 6. `我的项目 / 项目工作台 / 发布工作台` 语言关系相关 Contract 结论

- 本轮完全不改：
  - `GET /api/app/my/projects`
  - `GET /api/app/my/projects/{projectId}`
  - `GET /api/app/exhibition/workbench`
  - `POST /api/app/project/create`
  的 contract 真义。
- 当前正式冻结为：
  - 只在页面标题、入口文案、导流说明层统一用户语言
  - 不新增任何新的中间承接 contract
  - 不新增任何新的 response carrier

## 7. `exhibition_page_frames` 相关 Contract 结论

- 弱化页面框架“讲解感”完全不触碰 contract 层。
- 本轮正式不新增：
  - frame-specific contract
  - frame-specific page state schema
  - frame-specific result schema
- 本轮正式不改变：
  - retry
  - fallback
  - recovery route
  - controlled state
  的承接 contract。
- 当前正式写死：
  - 这轮只弱化“讲解感”
  - 不改框架行为 contract

## 8. 明确继续排除在本轮 Contract 外的范围

- 正式附件列表
- richer 私域状态真相
- `奖励金额`
- `单位平方面积金额`
- 搜索 / 地域分类页面 / 地图
- forum / 消息
- 订单平台化后台 / 合同后台 / 履约治理后台
- 其他无关板块

## 9. `openapi.yaml` 评估结论

### 9.1 本轮明确保持 no-op 的 path

- `POST /api/app/project/create`
- `GET /api/app/project/list`
- `GET /api/app/project/detail`
- `GET /api/app/my/projects`
- `GET /api/app/my/projects/{projectId}`
- `GET /api/app/exhibition/workbench`
- `POST /server/projects`
- `GET /server/projects`
- `GET /server/projects/{projectId}`
- `GET /server/my/projects`
- `GET /server/my/projects/{projectId}`

### 9.2 本轮明确保持 no-op 的 schema

- `ProjectCreateRequest`
- `ProjectShowcaseListItemReadModel`
- `ProjectReadModel`
- `MyProjectListResponse`
- `MyProjectListItemReadModel`
- `MyProjectPrivateProgressSummaryReadModel`
- `MyProjectDetailReadModel`
- `MyProjectPrivateProgressReadModel`

### 9.3 结论

- 本轮不更新 `docs/01_contracts/openapi.yaml`。
- 原因已正式冻结为：
  - 当前优化项全部属于消费层表达优化
  - 任何 schema/path 变更都会错误放大为业务 contract 扩面
  - 当前不存在需要 contract 显式承载的新对象、新字段、新路径或新错误族

## 10. Explicit Contract Guardrails

- 本轮 contract freeze 的默认结论正式写死为：
  - `体验优化优先为消费层 no-op`
- 当前正式禁止：
  - 借本轮新增业务字段
  - 借本轮修改 response 字段真义
  - 借本轮新增 preview 专属 schema
  - 借本轮新增 error 专属 schema
  - 借本轮新增 attachment / reward / unit-price 等任何扩展字段
  - 借本轮扩大 contract 变化面以服务实现便利

## 11. Stage Conclusion

- 当前结论：
  - `Go` for entering the `当前发布体验优化 persistence freeze` stage
  - `No-Go` for直接进入实现
- 原因已正式冻结为：
  - 本轮体验优化在 contract 层是否 no-op 已正式写清
  - 已排除范围继续被写死
  - 未借机扩大 contract 变化面
  - 下一步如需继续推进，应在 persistence freeze 阶段继续正式确认这轮优化是否同样保持 persistence no-op

## 12. 修订记录

- `v1.0` `2026-04-04`
  - 首版冻结“当前发布体验优化” contract 边界。
  - 正式确认本轮 contract 层整体 no-op。
  - 正式确认不更新 `openapi.yaml`，所有相关 path/schema 保持 no-op。
