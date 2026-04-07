---
owner: Codex 总控
status: pre_frozen
purpose: Pre-freeze the mainline boundary for my-project entry and single-project private carry, limited to my-building entry structure, project list layering, public-vs-private single-project composition, and rating-eligibility boundary.
layer: L0 SSOT
gate_basis:
  - AGENTS.md
  - docs/00_ssot/profile_my_building_compact_hub_boundary_addendum.md
  - docs/00_ssot/exhibition_workbench_summary_baseline_addendum.md
  - docs/00_ssot/project_showcase_publish_alignment_frontend_consumption_freeze_addendum.md
  - docs/04_frontend/flutter_screen_map.md
  - docs/01_contracts/openapi.yaml
freeze_date_local: 2026-04-04
---

# 我的项目入口与单项目私域承接预冻结单

## 1. Scope

- 本预冻结单只覆盖 `我的项目入口与单项目私域承接 pre-freeze`。
- 本预冻结单只服务于以下主线：
  - `我的楼`
  - `我的项目`
  - 项目列表
  - 单项目公域 + 私域承接
  - 项目完结与评价准入边界
- 本预冻结单不进入：
  - truth freeze
  - contract freeze
  - persistence freeze
  - backend / BFF / Flutter 实现
- 本预冻结单不扩到：
  - forum
  - 消息
  - 地图
  - 搜索界面
  - 地域分类页面
  - 企业库
  - 订单平台化后台
  - 合同后台
  - 履约治理后台

## 2. Current Blocker Diagnosis

- 当前 `项目工作台` 只是私域四容器摘要页，不是“我的全部项目”管理面。
- 当前 `project_chain` 只冻结：
  - `hasProjects`
  - `recentProjectId`
  - `recentProjectTitle`
  - `canCreateProject`
  - `canOpenProjectPool`
- 这说明：
  - `project_chain` 只能承载最近项目上下文与导流动作
  - 不能承载公司级多项目管理
  - 不能承载项目分组、项目状态层、项目私域进度层
- 一家公司不可能只有一个项目，因此：
  - `recentProjectId` 不能承担“我的项目”主入口
  - `项目工作台` 也不能替代“我的项目列表”

## 3. Entry Structure Pre-freeze

### 3.1 入口结论

- `我的楼` 后续应新增正式入口：
  - `我的项目`
- `项目工作台` 继续保留，但只承担：
  - 总摘要
  - 当前导流
  - 最近项目上下文
- 当前正式预冻结结论：
  - `我的楼 -> 我的项目` 与 `项目工作台` 不得混同
  - `项目工作台` 不是“我的全部项目”
  - `我的项目` 才是后续正式项目管理入口

### 3.2 结构关系

- `我的楼`
  - `我的项目`
- `项目工作台`
  - 继续作为摘要/导流页存在
  - 允许保留 `recentProjectId` 快速进入最近项目
  - 但不得替代 `我的项目` 列表

## 4. Project List Structure Pre-freeze

### 4.1 列表而非单实例

- `我的项目` 点击进入后，后续正式承接形态应为：
  - 项目列表
- 当前正式预冻结为：
  - 不采用单实例承接
  - 不采用仅最近项目承接

### 4.2 第一层状态分组

- `我的项目` 首层状态分组当前预冻结为：
  - `进行中`
  - `历史项目`
- 当前不直接冻结为：
  - `已完成`
- 原因是：
  - `已完成` 容易被误绑定到 `plannedEndAt`
  - 当前还没有冻结“业务正式完结”的统一真相
  - `历史项目` 是更稳健的过渡分层

### 4.3 后续细化边界

- `历史项目` 后续可以再细化，但本轮不越级冻结：
  - 已正式完结
  - 待评价
  - 已评价
  - 已关闭争议 / 售后
- 当前只先冻结：
  - `进行中`
  - `历史项目`

## 5. Single-project Public And Private Carry Boundary

### 5.1 单项目必须双区承接

- 单项目页后续必须同时承接：
  - 公域项目信息区
  - 私域项目进度区
- 当前正式禁止：
  - 把公域和私域全部混成一个失控大页

### 5.2 公域信息区

- 单项目公域信息区后续应复用项目展示主线已冻结的公域信息：
  - 项目标题
  - 建筑类型
  - 预算金额
  - 项目面积
  - 标准化地点
  - 地址与范围
  - 计划时间
  - 说明文案
- 公域信息区的职责是：
  - 稳定复用已发布项目的公共展示信息
  - 不重新发明第二套项目基础真相

### 5.3 私域进度区

- 单项目私域进度区至少应预留以下承接维度：
  - 是否已接单
  - 订单状态
  - 合同状态
  - 履约进度
  - 验收状态
  - 争议 / 售后状态
  - 评价准入状态
- 当前这些私域项只做主线边界预冻结：
  - 说明单项目页必须有私域区
  - 但本轮不 author 其真字段清单与状态机 contract

## 6. Completion And Rating-entry Boundary

### 6.1 `plannedEndAt` 不是正式完结

- 当前正式预冻结：
  - `plannedEndAt` 只代表计划结束时间
  - 不能直接等同于项目业务正式完结
- 原因是：
  - 计划时间只是日程真值
  - 正式完结必须以后续交易/履约链的业务条件判定

### 6.2 业务正式完结边界

- 后续必须单独冻结“项目正式完结”的业务判定真源。
- 在该真源冻结前，当前正式禁止：
  - 用 `plannedEndAt` 推断“已完成”
  - 用计划时间到期自动切换“历史项目 -> 已完成”

### 6.3 评价准入边界

- 评价系统后续应定义为：
  - 项目达到正式完结条件后
  - 进入 `待评价状态`
- 当前正式预冻结：
  - 不是“自动直接评价”
  - 不是“计划结束即评价”
  - 不是“订单一存在就评价”
- 评价主线当前仍只准入：
  - `待评价`
  - `已评价`
  这类准入/完成边界概念，不在本轮 author 评分模型

## 7. Formal Attachment-list Boundary

- 正式附件列表当前继续排除在本主线之外。
- 当前正式预冻结结论：
  - 不把正式附件列表混入 `我的项目` 入口结构
  - 不把正式附件列表混入单项目公域/私域承接主线
- 若后续推进，仍必须继续拆为独立子议题：
  - `project showcase detail attachment read truth`

## 8. Explicit Non-goals

- 不 author：
  - “我的项目” truth
  - “我的项目” contract
  - “我的项目” persistence
  - “我的项目”实现
- 不扩到：
  - forum
  - 消息
  - 地图
  - 搜索界面
  - 地域分类页面
  - 企业库
  - 订单平台化后台
  - 合同后台
  - 履约治理后台
- 不把：
  - `plannedEndAt`
  - 正式完结
  - `待评价`
  - `已评价`
  混成一个字段或一个状态

## 9. Stage Conclusion

- 当前结论：
  - `Go` for entering the `我的项目入口与单项目私域承接 truth freeze` stage
  - `No-Go` for直接进入 contract / persistence / implementation
- 本预冻结单的真实含义是：
  - 新主线入口结构已预冻结
  - 项目列表分层与单项目公域/私域承接边界已预冻结
  - 完结 / 评价准入边界已被区分清楚
  - 正式附件列表继续被排除在本主线之外

## 10. 修订记录

- `v1.0` `2026-04-04`
  - 首版冻结 `我的项目入口与单项目私域承接` 主线预冻结边界。
  - 正式确认 `我的楼 -> 我的项目` 的入口方向。
  - 正式确认项目列表首层先分为 `进行中` 与 `历史项目`。
  - 正式确认单项目必须拆分公域信息区与私域进度区。
  - 正式确认 `plannedEndAt` 不等于正式完结，评价应在正式完结后进入 `待评价状态`。
