---
owner: Codex 总控
status: frozen
phase_day: 第 1 天
layer: L0 SSOT
purpose: >
  Freeze the bounded scope, field truth, derived-count rules, and acceptance
  gates for the Flutter-only refinement of the My Project list page.
---

# 《我的项目列表 UI 精修｜第 1 天真源与边界冻结补充单》

## 1. 本轮最小闭环

本轮只优化 `我的楼 -> 我的项目` 的 Flutter 列表页展示层：

- 页面更短、更紧凑。
- 信息层级先看状态、分类、阶段和下一步动作。
- 项目卡弱化长说明和重复字段。
- 统计只允许从已读取 payload 做展示层派生。
- 底部导航不得遮挡最后一张项目卡。

本轮不是项目状态机、发布流程、竞标流程、待办中心或项目工作台接口改造。

## 2. 本轮只做什么

1. 保留 AppBar 返回与标题 `我的项目`。
2. 保留 bottom nav 路由，不新增、不删除 tab。
3. 在列表页新增轻量状态总览卡：
   - `当前展示：已接通内容`
   - `我的发布` 数量
   - `我的竞标` 数量
4. 将 `我的发布 / 我的竞标` 改为更紧凑的展示层 segmented control。
5. 将项目阶段改为横向可滑动 chips：
   - `全部`
   - `草稿`
   - `预发布列表`
   - `竞标中`
   - `进行中`
   - `已归档`
6. 将 `草稿 / 已归档` 同时保留为低频入口，但只能做小型入口，不占主内容大块。
7. 精简项目卡：
   - 项目名称最多两行。
   - 展示真实状态 badge。
   - 展示地区、类型、面积、预算 chips。
   - 展示当前阶段和下一步动作的一行摘要。
   - 主按钮、次按钮必须复用现有真实路由或真实能力。
8. 弱化项目编号、完整长动作说明、重复字段。
9. 增加列表底部安全留白，避免 bottom nav 视觉遮挡。

## 3. 本轮不做什么

1. 不修改 BFF。
2. 不修改 Server。
3. 不修改 contracts / OpenAPI。
4. 不修改数据库、migration、云端配置。
5. 不修改项目状态机、发布规则、竞标规则、草稿/归档规则。
6. 不新增接口字段。
7. 不新增生产 mock。
8. 不新增假统计、假待办、假入口。
9. 不新增无真实路由的筛选、说明、操作指引入口。
10. 不把 `我的项目` 改义成公域项目列表或第二个工作台 truth owner。
11. 不重构 `我的项目详情`，除非后续另行冻结。

## 4. 当前入口、路由和文件

| 对象 | 当前真相 |
|---|---|
| 我的楼入口 | `ProfilePage` 中 `我的项目` 入口 |
| Flutter 路由 | `ExhibitionRoutes.myProjectList` / `/exhibition/my/projects` |
| 列表页 | `apps/mobile/lib/features/exhibition/presentation/pages/my_project_list_page.dart` |
| 详情页入口 | `ExhibitionRoutes.myProjectDetailWithProjectId(projectId)` |
| 草稿编辑入口 | `ExhibitionRoutes.projectEditWithProjectId(projectId)` |
| 分类支持 | `apps/mobile/lib/features/exhibition/presentation/presentation_support/my_project_workspace_support.dart` |
| 阶段支持 | `apps/mobile/lib/features/exhibition/presentation/presentation_support/my_project_stage_support.dart` |

## 5. 字段真源

### 5.1 我的发布

`我的发布` 继续消费：

- `GET /api/app/my/projects`

成功响应的合同级字段为：

- `ongoingProjects`
- `historicalProjects`

列表单项合同级字段为：

- `publicProject`
- `privateSummary`

`publicProject` 继续承接项目展示摘要字段，例如：

- `projectId`
- `projectNo`
- `title`
- `state`
- `buildingType`
- `areaSqm`
- `budgetAmount`
- `provinceName`
- `cityName`
- `districtName`

`privateSummary` 继续承接私域最小进度摘要字段：

- `hasAcceptedOrder`
- `orderStatus`
- `contractStatus`
- `fulfillmentStatus`
- `acceptanceStatus`
- `afterSalesOrDisputeStatus`
- `formalCompletionStatus`
- `evaluationStatus`

### 5.2 我的竞标

`我的竞标` 继续消费：

- `GET /api/app/my/bids`

当前 Flutter 只允许展示既有 read model 字段，例如：

- `bidId`
- `projectId`
- `projectNo`
- `projectTitle`
- `quoteAmount`
- `proposalSummaryPreview`
- `submittedAt`
- `outcomeState`
- `canOpenBidThread`
- `canOpenBidResult`

本轮不新增 `snapshotReadable` 直达能力；如后续需要，必须另行冻结。

## 6. 阶段映射

Flutter 展示层继续沿用当前阶段映射：

| Server / read state | 用户侧阶段 |
|---|---|
| `draft` | 草稿 |
| `submitted` | 预发布列表 |
| `published` / `bidding_closed` | 竞标中 |
| `awarded` / `converted_to_order` | 进行中 |
| `archived` | 已归档 |

未知 state 不得创建新阶段；当前展示层按既有兼容逻辑归入草稿，但不得把该兼容逻辑写成新的业务真相。

## 7. 允许前端派生的计数

下列计数只允许作为 Flutter 展示层派生，不写回接口、不写入 Server truth：

| 计数 | 派生规则 | 展示限制 |
|---|---|---|
| 我的发布数 | `ongoingProjects + historicalProjects` 去重后的项目数量 | 仅用于总览卡 |
| 我的竞标数 | `GET /api/app/my/bids` 成功后 `items.length` | 未成功读取时显示 `--` 或弱化，不伪造 |
| 阶段数 | 根据当前已加载 `我的发布` payload 的 `publicProject.state` 映射后计数 | 仅作为 chips 后缀 |
| 全部数 | 当前 `我的发布` payload 去重项目总数 | 仅用于阶段 chips |

## 8. 不允许展示或默认不展示的内容

1. `待处理` 数量当前没有独立真实字段。
   - 默认不展示。
   - 如后续要展示，必须先定义展示层派生规则并在回执中写明。
2. `筛选` 图标当前不得新增。
   - 除非复用已有真实筛选能力并通过前端回执列出入口。
3. `说明` 图标当前不得新增。
   - 除非复用已有真实说明页或已有说明弹层。
4. `操作指引` 入口当前不得新增。
   - 除非复用已有真实路由或真实公共资源入口。
5. 不得把 mock 数字、设计图数字或测试 fixture 数字展示为生产事实。

## 9. 按钮能力冻结

列表页按钮只允许承接现有真实路由：

| 阶段 | 主按钮 | 路由 / 能力 |
|---|---|---|
| 草稿 | 继续编辑 | `ExhibitionRoutes.projectEditWithProjectId(projectId)` |
| 预发布列表 | 补资料后确认发布 | `ExhibitionRoutes.myProjectDetailWithProjectId(projectId)` |
| 竞标中 | 查看详情 | `ExhibitionRoutes.myProjectDetailWithProjectId(projectId)` |
| 进行中 | 查看详情 | `ExhibitionRoutes.myProjectDetailWithProjectId(projectId)` |
| 已归档 | 查看详情 | `ExhibitionRoutes.myProjectDetailWithProjectId(projectId)` |

列表页不得直接新增 `确认发布`、`作废删除`、`撤回到预发布`、`记录违约` 等写动作按钮；这些动作继续留在详情页既有受控动作区。

危险动作不得使用金色实心按钮。

## 10. 展示层弱化规则

列表页不得删除字段真相，但可以做展示层弱化：

- `项目编号`：从主视觉降为小字元信息。
- 完整 `cardNextStep` 长文案：降为一行阶段摘要或详情页承接提示。
- `formalCompletionStatus` / `evaluationStatus`：不再和地区、类型、面积、预算同等抢首屏；可弱化为小字或只在详情页完整查看。
- 重复地点、面积、预算字段：优先使用 chips，避免再次以 detail line 重复。

详情页已有字段不因本轮改动删除。

## 11. 验收标准

1. 本轮 changed files 不包含 BFF、Server、contracts、OpenAPI、数据库、infra。
2. 没有新增生产 mock。
3. 没有新增接口字段。
4. `待处理` 默认不展示；如展示必须是明确展示层派生并写回执。
5. 项目卡高度明显低于当前长卡。
6. 阶段 chips 可以横向滚动，不因窄屏挤压换成大段堆叠。
7. 最后一张项目卡不被 bottom nav 视觉遮挡。
8. `flutter analyze` 通过或只剩明确非本轮旧问题。
9. `apps/mobile/test/my_project_private_carry_test.dart` 通过或给出明确非本轮阻塞。
10. 云端只读联调不要求新增接口成功，但页面不得因字段缺失崩溃。

## 12. 第 1 天门禁结论

- 是否允许进入第 2 天：Go。
- 允许原因：
  - 当前优化对象已冻结为 Flutter 列表展示层。
  - 当前计数可以全部通过已加载 payload 派生。
  - 当前不存在必须新增的 BFF / Server / contracts 字段。
  - 无真实字段的 `待处理`、无真实路由的说明/筛选/操作指引已冻结为默认不展示。
- 当前风险：
  - 仓库已有大量非本轮 dirty files，后续验收必须隔离 changed files。
  - `my_project_list_page.dart` 当前已是 dirty 状态，施工必须基于现状增量修改，不能回滚他人改动。
