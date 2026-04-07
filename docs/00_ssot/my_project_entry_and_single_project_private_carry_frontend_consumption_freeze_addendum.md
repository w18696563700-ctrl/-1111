---
owner: Codex 总控
status: frozen
purpose: Freeze the Flutter App consumption boundary for my-project entry and single-project private carry, limited to entry handoff, list consumption, single-project public-vs-private consumption, status-language mapping, and non-owner boundaries.
layer: L0 SSOT
gate_basis:
  - AGENTS.md
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_truth_freeze_addendum.md
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_contract_freeze_addendum.md
  - docs/02_backend/my_project_entry_and_single_project_private_carry_persistence_truth_addendum.md
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_persistence_migration_freeze_addendum.md
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_backend_bff_implementation_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/04_frontend/flutter_screen_map.md
  - apps/mobile/lib/features/profile/navigation/profile_routes.dart
  - apps/mobile/lib/features/profile/presentation/profile_page.dart
  - apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/project_list_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_contract_mapper.dart
freeze_date_local: 2026-04-04
---

# 我的项目入口与单项目私域承接前端消费冻结单

## 1. Scope

- 本冻结单只覆盖 `我的项目入口与单项目私域承接 frontend consumption freeze`。
- 本冻结单只围绕以下私域 read family 冻结 Flutter 消费边界：
  - `GET /api/app/my/projects` -> `MyProjectListResponse`
  - `GET /api/app/my/projects/{projectId}` -> `MyProjectDetailReadModel`
- 本冻结单只冻结 Flutter 的：
  - `我的楼 -> 我的项目` 入口承接
  - `我的项目` 列表页消费
  - 单项目页消费
  - `formalCompletionStatus / evaluationStatus` 用户语言承接
  - 与公域展示 / 发布工作台 / 项目工作台的导流边界
- 本冻结单不进入：
  - Flutter 实现代码
  - backend / BFF 实现代码
  - 正式附件列表 UI
  - 搜索界面
  - 地域分类页面
  - 地图 / 经纬度
  - 其他板块

## 2. Frontend Consumption Conclusion

- `我的项目` 现正式冻结为 `我的楼` 下的独立私域入口。
- `我的项目` 列表页现正式冻结为双分组消费面：
  - `进行中`
  - `历史项目`
- Flutter 列表 item 必须同时承接：
  - `publicProject`
  - `privateSummary`
- Flutter 单项目页必须同时承接：
  - `publicProject`
  - `privateProgress`
- `provinceCode / cityCode / districtCode` 继续只作内部 standardized carrier，不直接展示给终端用户。
- `formalCompletionStatus / evaluationStatus` 必须转换为用户语言，但不得改动其真义。
- 正式附件列表继续不进入本主线 Flutter 消费。

## 3. `我的楼 -> 我的项目` 入口 Consumption Freeze

### 3.1 入口承接形态

- `我的项目` 现正式冻结为 `我的楼` 下的正式入口卡片 / 列表项 / 导流按钮之一。
- 当前入口文案必须明确表达：
  - 当前组织的项目资产
  - 私域项目继续处理
- 当前正式禁止：
  - 把 `我的项目` 与 `项目工作台` 混同
  - 把 `我的项目` 写成公域项目浏览入口

### 3.2 入口摘要边界

- `我的项目` 入口当前允许展示聚合摘要，但前提是：
  - 只来自已返回的 `MyProjectListResponse`
  - 例如：
    - `ongoingProjects.length`
    - `historicalProjects.length`
- 当前正式禁止：
  - 在真源未加载或未稳定时伪造数量
  - 用 `recentProjectId` 或 `project_chain.hasProjects` 冒充“我的项目数量”
- 因此当前正式冻结为：
  - 入口可显示中性导语
  - 计数摘要是可选增强，不是首批必须项

## 4. `我的项目` 列表页 Consumption Freeze

### 4.1 列表分组结构

- Flutter 列表页现正式采用双分组列表 UI：
  - `进行中`
  - `历史项目`
- 用户可见分组文案当前正式冻结为：
  - `进行中`
  - `历史项目`
- 当前正式禁止：
  - 把 `历史项目` 直接渲染为“已完成”
  - 把 `历史项目` 直接渲染为“已评价”

### 4.2 `publicProject` 的直接展示字段

- 列表页当前允许直接展示以下 `publicProject` 字段：
  - `title`
  - `buildingType`
  - `budgetAmount`
  - `state`
  - `summary`
  - `areaSqm`
  - `provinceName`
  - `cityName`
- 当前只作内部承接、不要求直接展示：
  - `provinceCode`
  - `cityCode`

### 4.3 `privateSummary` 的最小可见承接

- `privateSummary` 当前允许被压缩展示为最小私域摘要，不要求原样堆满一行字段。
- 当前允许的用户可见压缩来源只限：
  - `hasAcceptedOrder`
  - `orderStatus`
  - `contractStatus`
  - `fulfillmentStatus`
  - `acceptanceStatus`
  - `afterSalesOrDisputeStatus`
  - `formalCompletionStatus`
  - `evaluationStatus`
- 当前正式冻结为：
  - 可以收口成状态条、状态标签、摘要 chip、或一行受控私域摘要
  - 不要求把所有原始字段逐个裸展示
  - 若某项真相为空，不得伪造完成态或正常态

### 4.4 列表页显式排除

- 列表页当前正式禁止展示：
  - 正式附件列表
  - `奖励金额`
  - `单位平方面积金额`
  - 平台治理状态细节
  - 搜索 / 地域分类页面能力

## 5. 单项目页 Consumption Freeze

### 5.1 双区页面结构

- 单项目页现正式冻结为两大区：
  - 公域信息区
  - 私域进度区
- 当前正式禁止：
  - 把公域与私域信息混成一个无边界大页

### 5.2 公域信息区

- Flutter 单项目页当前允许主展示：
  - 标题
  - 建筑类型
  - 建筑类型备注
  - 预算金额
  - 项目面积
  - 省 / 市 / 区县名称
  - 详细地址
  - 范围说明
  - 计划开始 / 结束
  - 详细时间
  - 状态
  - 摘要
  - 说明文案
- 公域信息区继续复用既有项目展示 detail 的可见真相。
- 当前正式写死：
  - `provinceCode / cityCode / districtCode` 不直接展示给终端用户
  - `provinceName / cityName / districtName` 继续是主显示值
  - `detailAddress` 继续是自由文本展示

### 5.3 私域进度区

- Flutter 单项目页当前允许承接以下私域进度信息：
  - 是否已接单
  - 当前订单状态
  - 合同状态
  - 履约进度
  - 验收状态
  - 争议 / 售后状态
  - 正式完结状态
  - 评价准入状态
- 私域进度区当前正式冻结为：
  - 继续处理信息区
  - 不是平台后台
  - 文案必须使用用户语言，不直接暴露内部枚举值
- 若某项真相当前为空：
  - 可以省略
  - 或展示受控“暂不可用 / 暂未返回”文案
  - 不得伪造为完成态

### 5.4 私域导流边界

- 私域进度区后续可以存在继续处理导流，但前提是：
  - 只导向已经冻结的下游页面或已存在的继续处理面
- 当前本轮只冻结：
  - 消费边界
  - 用户语言边界
- 当前不冻结：
  - 具体 CTA 动作矩阵
  - 新下游页面家族

## 6. `formalCompletionStatus` / `evaluationStatus` 用户语言冻结

### 6.1 `formalCompletionStatus`

- `formalCompletionStatus = not_formally_completed`
  - 前端用户语言应理解为：
    - `进行中`
    - 或 `尚未正式完结`
- `formalCompletionStatus = formally_completed`
  - 前端用户语言应理解为：
    - `已正式完结`
- 当前正式禁止：
  - 用 `plannedEndAt` 暗示“自动已完成”

### 6.2 `evaluationStatus`

- `evaluationStatus = not_eligible`
  - 前端用户语言应理解为：
    - `暂不可评价`
- `evaluationStatus = eligible`
  - 前端用户语言应理解为：
    - `待评价`
  - 其正式真义是：
    - 已达到评价准入
    - 尚未提交评价
- `evaluationStatus = submitted`
  - 前端用户语言应理解为：
    - `已评价`
  - 其正式真义是：
    - 评价动作已完成
- 当前正式禁止：
  - 自动评价文案
  - 把 `eligible` 解释成“已评价”

## 7. 与现有页面的消费关系

- `我的项目` 不替代公域项目展示页。
- `我的项目` 不替代项目发布工作台。
- `我的项目` 不替代项目工作台。
- `项目工作台` 继续是摘要 / 导流页。
- `我的项目` 才是当前组织项目资产列表与单项目承接面。
- 若存在从 `项目工作台` 导到 `我的项目` 的关系，当前正式冻结为：
  - 导流关系
  - 不是职责合并

## 8. 评估但不实现的移动端文件范围

- `apps/mobile/lib/features/profile/presentation/profile_page.dart`
  - 后续承接 `我的楼 -> 我的项目` 入口卡片 / 按钮
- `apps/mobile/lib/features/profile/navigation/profile_routes.dart`
  - 后续补独立 my-project 入口 route key 或 handoff route
- `apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart`
  - 后续补独立 my-project list/detail route family
  - 不得复用现有 `workbench` / `projectList` / `projectDetail`
- `apps/mobile/lib/features/exhibition/presentation/pages/project_list_page.dart`
  - 只可复用公域展示卡片的视觉经验
  - 不得直接重解释为 my-project 私域列表页
- `apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart`
  - 只可复用公域 detail 信息区表达经验
  - 不得直接重解释为 `publicProject + privateProgress` 双区私域页
- `apps/mobile/lib/features/exhibition/data/services/exhibition_contract_mapper.dart`
  - 后续应评估独立 my-project mapper / parser 增量
  - 不应污染现有公域 showcase mapper 真义
- `apps/mobile/lib/features/exhibition/data/services/exhibition_load_service.dart`
  - 后续应评估 my-project list/detail load surface
- 对应测试边界
  - 应新增 my-project list/detail contract mapping、loading、empty/error、status-language 映射测试

## 9. 显式非目标

- 不进入：
  - 正式附件列表
  - `奖励金额`
  - `单位平方面积金额`
  - 搜索界面
  - 地域分类页面
  - 地图 / 经纬度
  - forum / 消息
  - 订单平台化后台
  - 合同后台
  - 履约治理后台
  - 任何无关板块功能
- Flutter 当前正式不得：
  - 自创第二套项目状态真相
  - 展示内部 `code` 字段给终端用户
  - 把 `plannedEndAt` 当作完结状态
  - 把正式附件列表混入单项目页

## 10. Stage Conclusion

- 当前结论：
  - `Go` for entering the `我的项目入口与单项目私域承接 implementation` stage
  - `No-Go` for把正式附件列表混入当前实现
- 本冻结单的真实含义是：
  - `我的项目` 入口、列表、单项目页的 Flutter 消费边界已正式冻结
  - `formalCompletionStatus / evaluationStatus` 的前端承接方式已写清
  - 正式附件列表仍继续被明确排除在本主线外

