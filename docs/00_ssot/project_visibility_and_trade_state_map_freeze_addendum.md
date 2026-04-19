---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the current state, visibility, relation, private-progress, and
  downstream trade-state map around the project mainline so later trade/funds
  work cannot grow from mixed carriers.
layer: L0 SSOT
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_permission_and_state_unified_ruling_addendum.md
  - docs/00_ssot/project_visibility_boundary_freeze_addendum.md
  - docs/00_ssot/historical_projects_semantics_ruling_addendum.md
  - docs/00_ssot/project_transaction_skeleton_freeze_addendum.md
  - docs/00_ssot/contract_phase3_decision_addendum.md
  - docs/00_ssot/inspection_phase3_decision_addendum.md
  - docs/00_ssot/rating_object_decision_addendum.md
  - docs/00_ssot/dispute_object_decision_addendum.md
  - docs/00_ssot/stage2_transport_admin_support_closure_conclusion_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/server/src/modules/project/project.controller.ts
  - apps/server/src/modules/project/project-query.service.ts
  - apps/server/src/modules/my_project/my-project.controller.ts
  - apps/server/src/modules/my_project/my-project.query.service.ts
  - apps/server/src/modules/exhibition_workbench/exhibition-workbench.controller.ts
  - apps/server/src/modules/exhibition_workbench/exhibition-workbench.query.service.ts
  - apps/server/test/historical-projects-semantics.test.cjs
  - apps/bff/test/my-project-viewer-relation.test.cjs
---

# 《项目可见性与交易状态总图冻结单》

## 1. 核心裁决

当前项目主线的状态与可见性总图冻结如下：

- `project.state`
  - 只负责项目公域生命周期语义
- `publishedAt`
  - 只负责项目是否已物化进入公域展示面
- 当前不存在独立：
  - `visibility`
  - `displayStatus`
  - `hidden`
  - `delisted`
  - `frozen_display`
  真源
- 当前不存在独立项目审核状态机
- `viewerProjectRelation`
  - 只负责公域 detail 的最小 owner/non-owner relation handoff
- `my-project privateProgress`
  - 只负责组织 scope 下的私域项目推进、完结与评价资格投影
- `workbench summary`
  - 只负责私域 continuation summary / entry posture
- future `bid / order / contract / fulfillment`
  - 都属于下游交易对象 truth family，不得回写成项目主状态

## 2. 状态与可见性总图

| 对象 | 层级 | 当前 owner | 当前职责 | 当前明确不负责 |
|---|---|---|---|---|
| `project.state` | truth carrier | `Server project` | 公域项目生命周期，如 `published / bidding_closed / awarded / converted_to_order` | 隐藏/下架、审核、私域推进、资金 gate |
| `publishedAt` | truth carrier | `Server project` | 公域展示准入：是否已进入 `project/list` / `project/detail` | 全部 lifecycle、owner relation、资金/风控语义 |
| `viewerProjectRelation` | read projection | `project/detail` + `my/projects/{id}` shared read | `owner / non_owner` 最小 relation handoff | ownership raw truth、权限矩阵、生命周期、可见性 |
| `privateProgress.formalCompletionStatus` | private derived projection | `my/projects/{id}` | 私域正式完结投影与 ongoing/historical bucket 分组基准 | 公域可见性、项目生命周期、支付状态 |
| `privateProgress.evaluationStatus` | private derived projection | `my/projects/{id}` | 评价资格/状态投影 | historical bucket 真值、项目状态真值 |
| `workbench summary containers` | summary projection | `exhibition/workbench` | 私域摘要、route handoff、continuation posture | 项目真值、交易真值、第二工作台状态机 |
| future `bid state` | downstream trade truth | future bid family | 竞标状态 | 项目发布状态、公域可见性 |
| future `order state` | downstream trade truth | order family | 成交后订单状态 | `project.state`、`publishedAt` |
| future `contract state` | downstream trade truth | contract family | 合同 workflow 状态 | 项目生命周期、公域可见性 |
| future `milestone / inspection / fulfillment state` | downstream fulfillment truth | fulfillment family | 履约推进、验收、整体验证状态 | 项目主状态、公域 visibility |
| `summary.stateLabel` 等 UI 文案 | UI wording | consumer/UI | 文案显示 | 任何业务真值 |

## 3. 真值 carrier / 读时投影 / UI 口径分层表

| 分类 | 对象 | 当前允许含义 | 当前禁止含义 |
|---|---|---|---|
| 真值 carrier | `project.state` | 生命周期 | visibility / review / owner permission |
| 真值 carrier | `publishedAt` | 进入公域展示面的物化准入 | 生命周期全语义 |
| 真值 carrier | future `order.state` / `contract.state` / `inspection.state` | 各自下游 trade/fulfillment truth | 项目状态总代表 |
| 读时投影 | `viewerProjectRelation` | 公域 detail handoff | owner 权限真值、管理矩阵 |
| 读时投影 | `privateProgress` | 私域推进、完结、评价资格 | 公域展示与隐藏判断 |
| 读时投影 | `workbench summary` | 私域摘要、入口姿态 | 项目状态机、交易状态机 |
| UI 口径 | `summary.stateLabel`、文案 copy | 说明、标签、引导 | 业务真值与 gate |

## 4. `project.state` 的职责

当前正式写死：

- `project.state` 只负责项目公域生命周期。
- 当前不得让 `project.state` 承担：
  - 公域隐藏/下架
  - 项目审核状态
  - 是否是 owner
  - 是否已具备支付/保证金/信用 gate
  - 是否已经履约完成

特别禁止：

- 把 `converted_to_order` 解释成“项目公域已自动下架”
- 把 `awarded` 解释成“支付已完成”
- 把任何 future funds/risk 语义直接塞进 `project.state`

## 5. `publishedAt` 的职责

当前正式写死：

- `publishedAt` 只负责：
  - 是否已被 materialize 到公域 `project/list` / `project/detail`

当前明确不允许：

- 用 `publishedAt` 冒充完整生命周期
- 用 `publishedAt` 冒充审核通过
- 用 `publishedAt` 冒充 owner 关系
- 用 `publishedAt` 冒充支付/保证金/信用 gate

## 6. 当前不存在的 truth family

当前正式不存在：

- 独立 `visibility` truth
- 独立 `displayStatus` truth
- 独立 `hidden / delisted / frozen_display` truth
- 独立项目审核状态机

因此当前必须禁止：

- 在 `BFF` 或 Flutter 先做隐藏/下架伪状态
- 用 summary 文案或布尔值冒充 visibility truth
- 用 `project_publish_audit_log` 冒充 review state machine

## 7. `viewerProjectRelation` / `privateProgress` / `workbench summary` 的职责分工

### 7.1 `viewerProjectRelation`

- 只回答：
  - 当前 viewer 与该项目的 relation
- 只允许：
  - `owner`
  - `non_owner`
- 不允许回答：
  - 是否可删除
  - 是否可编辑
  - 是否已可成交
  - 是否需保证金

### 7.2 `privateProgress`

- 只回答：
  - 当前组织 scope 下该项目的私域推进
  - `formalCompletionStatus`
  - `evaluationStatus`
  - order/contract/fulfillment 相关私域摘要
- 不允许回答：
  - 公域 list/detail visibility
  - 公域 lifecycle
  - profile 资金 posture

### 7.3 `workbench summary`

- 只回答：
  - 私域 continuation summary
  - 哪条 route 可 handoff
  - 哪个 `recentProjectId / activeOrderId / activeMilestoneId` 可继续
- 不允许回答：
  - 项目真值
  - 项目生命周期真值
  - 交易状态总真值

## 8. future `bid / order / contract / fulfillment` 状态对象边界

| future 对象 | 当前边界结论 | 不得回写的对象 |
|---|---|---|
| `bid` | 未来属于独立交易对象状态族；当前只接受 minimum continuation edge | `project.state` / `publishedAt` |
| `order` | 未来属于 order truth；当前 `S2` 只收口 detail read | `project.state` / `viewerProjectRelation` |
| `contract` | 未来属于 contract workflow truth；当前 `S2` 只收口 detail read | `project.state` / `workbench summary` |
| `milestone / inspection / fulfillment` | 未来属于 fulfillment truth；当前 `S2` 只收口 read corridor | `project.state` / `publishedAt` / profile posture |
| `rating / dispute` | 未来属于 order-bound aftersales/governance edge objects | `privateProgress.formalCompletionStatus` / project visibility |

## 9. 禁止混用清单

- 不得用 `summary.stateLabel` 冒充状态真值。
- 不得用 `publishedAt` 冒充 lifecycle 全部语义。
- 不得用 `viewerProjectRelation` 冒充 owner 权限真值。
- 不得用 profile posture 冒充项目交易 gate。
- 不得用 `privateProgress.formalCompletionStatus` 冒充公域 visibility truth。
- 不得用 `evaluationStatus` 冒充 historicalProjects 分组真值。
- 不得用 `workbench` summary container 冒充项目、订单、合同、履约真值。
- 不得把 future `order/contract/fulfillment` state 回写成 `project.state`。
- 不得把不存在的 `visibility/displayStatus` 用 UI copy、BFF 布尔值或局部判断偷偷实现。
- 不得把 `project_publish_audit_log` 冒充项目审核状态机。

## 10. Formal Conclusion

本单正式写死：

- 当前项目主线的 truth owner 分层仍然清晰有效：
  - `project.state` = 项目生命周期
  - `publishedAt` = 公域准入
  - `viewerProjectRelation` = handoff relation
  - `privateProgress` = 私域推进投影
  - `workbench summary` = 私域摘要/入口姿态
- 当前不存在独立项目 visibility truth，也不存在项目 review state machine。
- 未来交易、资金、风控实现不得基于混用 carrier 展开。
- 若后续需要：
  - 下架 / 隐藏 / 展示冻结
  - review-before-display
  - 资金/风控触发的可见性治理
  都必须先补新的独立 truth carrier，再进入实现排期。
