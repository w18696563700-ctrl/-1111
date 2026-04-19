---
owner: Codex 总控
status: frozen
purpose: Formally rule the unified permission, state, visibility, and owner-carry boundary for `项目工作台 / 发布项目 / 项目展示`, limited to publish eligibility truth, project-review-state existence, `state/publishedAt/future visibility` duty split, and the owner-vs-private-carry relation boundary.
layer: L0 SSOT
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_publish_board_boundary_freeze_addendum.md
  - docs/00_ssot/exhibition_workbench_summary_baseline_addendum.md
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_truth_freeze_addendum.md
  - docs/00_ssot/owner_aware_project_detail_surface_pre_freeze_addendum.md
  - docs/00_ssot/my_building_round1_viewer_project_relation_runtime_alignment_review_conclusion_addendum.md
  - docs/00_ssot/account_and_enterprise_certification_rules_v1_app_aligned_freeze_addendum.md
  - docs/00_ssot/exhibition_showcase_bid_flow_v11_upgrade_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md
  - docs/02_backend/my_project_entry_and_single_project_private_carry_persistence_truth_addendum.md
  - apps/server/src/modules/project/project-write.service.ts
  - apps/server/src/modules/project/project-query.service.ts
  - apps/server/src/modules/exhibition_workbench/exhibition-workbench.query.service.ts
  - apps/server/src/modules/my_project/my-project.query.service.ts
---

# 《项目权限与状态统一裁决单》

## 1. Scope

- 本裁决单只覆盖三条主线：
  - `项目工作台`
  - `发布项目`
  - `项目展示`
- 本裁决单只裁决 4 件事：
  - 项目发布资格的唯一真源
  - 当前是否存在项目审核状态机
  - `project.state`、`publishedAt`、未来 `visibility/displayStatus` 的职责分工
  - `viewerProjectRelation`、`my/projects`、`workbench`、`project/detail` 的边界关系
- 本裁决单不进入：
  - 支付 / 押金 / 佣金
  - 组织角色体系重做
  - 项目审核后台实现
  - 代码实现修改

## 2. Final Ruling Conclusion

- 当前 `项目展示 / 发布项目 / 项目工作台 / 我的项目` 已形成一条最小可解释主线，但仍属于：
  - `创建即发布`
  - `公域展示`
  - `owner relation 分流`
  - `私域继续处理`
- 本裁决单正式写死以下结论：
  1. 项目发布资格的唯一业务判断真源必须是：
     - `verified current session`
     - `current organization scope`
     - `buyer-side allowed role`
     - `approved certification`
  2. 当前不存在独立的“项目审核状态机”。
  3. 当前项目链路只能表述为：
     - `创建即发布`
     - 不允许表述成：
       - `创建 -> 待审核 -> 审核通过 -> 发布`
       - `review-before-display default model`
  4. `project.state` 负责项目公开生命周期语义。
  5. `publishedAt` 负责当前公域可见性准入。
  6. 未来 `visibility` / `displayStatus` 若要引入，只能作为独立新 carrier；
     当前阶段不得偷实现、不得借文案或布尔开关冒充。
  7. `viewerProjectRelation` 只负责“当前 viewer 与该项目的关系”。
  8. `project/detail` 是公域 detail truth read。
  9. `my/projects` 是组织 scope 下的私域项目资产与私域进度 read family。
  10. `workbench` 只允许做私域摘要与导流，不得成为第二项目状态机或第二项目资产真源。

## 3. Ruling A: Publish Eligibility Single Source Of Truth

### 3.1 Final Eligibility Rule

- 项目发布资格现正式裁定为必须同时满足：
  - 当前请求已完成 `current session` 验证
  - 当前 actor 拥有有效 `organization scope`
  - 当前 actor 拥有 buyer-side allowed role
  - 当前 organization `certificationStatus = approved`
- 当前不允许改写为以下任何弱化版本：
  - 只要登录即可发布
  - 只要有 organization scope 即可发布
  - 只要 `buyer_admin` 即可发布
  - 只要 organization lifecycle 为 `active` 即可发布

### 3.2 Final Truth-owner Placement

- 最终业务判断必须落在：
  - `Server`
- 更具体地说：
  - DB truth 提供：
    - current-session backing truth
    - organization membership truth
    - role truth
    - certification truth
  - `CurrentActorEligibilityService` 及其同层 policy 负责把这些 DB truths 组装成 eligibility judgement
  - `ProjectWriteService` 负责在项目创建命令处消费该 eligibility judgement
- `App` 不得成为最终发布资格判断 owner。
- `BFF` 不得成为最终发布资格判断 owner。
- `workbench.canCreateProject` 只可作为 app-facing 导流 projection；
  它不是最终资格真源。

### 3.3 Current Drift Ruling

- 当前仓库实现中：
  - `ProjectWriteService` 已校验 current session + organization scope
  - 但尚未把 approved certification 纳入最终 create judgement
  - `workbench.canCreateProject` 当前也只体现 buyer-side role，没有体现 certification
- 本裁决正式认定：
  - 这是实现漂移
  - 不是文书待定
  - 后续实现必须回到本裁决

## 4. Ruling B: Project Review State Machine Existence

### 4.1 Final Ruling

- 当前明确不存在独立的“项目审核状态机”。
- 当前项目链路的正式表述只能是：
  - `创建即发布`

### 4.2 Meaning

- `POST /project/create` 当前 materialize 的是：
  - `state = published`
  - `publishedAt = now`
- 当前不存在以下任一已冻结真源：
  - `project.reviewStatus`
  - `project.publishStatus`
  - `project.pendingReviewAt`
  - `project.reviewDecision`
  - `project.displayApprovedAt`
- 当前 `project_publish_audit_log` 只是 append-only audit evidence。
- 当前 `project_publish_audit_log` 不是：
  - 项目审核状态机
  - 审核结果 carrier
  - 发布前审查流程 carrier

### 4.3 Hard Prohibition

- 当前正式禁止以下模糊表述：
  - “项目处于审核中”
  - “项目审核通过后发布”
  - “当前发布默认先进入审核”
  - “项目有 review-before-display 默认主线”
- 若未来要引入项目审核，必须：
  - 单独冻结 truth family
  - 单独冻结 contract family
  - 单独冻结 visibility and lifecycle split
- 在那之前，任何项目审核语义都不得被暗示为当前已存在。

## 5. Ruling C: `state` vs `publishedAt` vs Future `visibility`

### 5.1 `project.state`

- `project.state` 现正式负责：
  - 项目公开生命周期语义
- 当前已冻结最小集合为：
  - `published`
  - `bidding_closed`
  - `awarded`
  - `converted_to_order`
- `project.state` 当前不负责：
  - 是否已经进入公域 list/detail 的展示准入
  - 是否对 owner 可见
  - 是否对当前组织可继续处理
  - 审核通过与否

### 5.2 `publishedAt`

- `publishedAt` 现正式负责：
  - 当前公域可见性准入
- 当前 public `project/list` 与 `project/detail` 的准入边界继续以：
  - `publishedAt is not null`
  为准。
- `publishedAt` 当前不负责：
  - 生命周期阶段标签
  - owner relation
  - 私域继续处理资格
  - 项目审核结论

### 5.3 Future `visibility` / `displayStatus`

- 未来若要支持：
  - 公域下架
  - 公域隐藏
  - 受控展示
  - 已成单但不继续公域可见
  等需求，只能引入独立 carrier，例如：
  - `visibility`
  - `displayStatus`
- 当前阶段对此的正式裁决是：
  - 可作为未来预留语义讨论
  - 当前不得提前偷实现
  - 当前不得用：
    - summary 文案
    - BFF 布尔开关
    - Flutter 本地 UI state
    - `state` 的偷改名
    来冒充 `visibility/displayStatus`

### 5.4 Duty Split Summary

- 当前职责分工正式写死为：
  - `state` = 生命周期
  - `publishedAt` = 公域可见性准入
  - future `visibility/displayStatus` = 若以后需要更细展示控制，必须独立冻结后引入

## 6. Ruling D: Owner Relation And Private Carry Boundary

### 6.1 `viewerProjectRelation`

- `viewerProjectRelation` 现正式定义为：
  - 当前 viewer 与该项目的关系 carrier
- 它只允许表达：
  - `owner`
  - `non_owner`
- 它不允许表达：
  - 项目生命周期
  - 项目可见性
  - 管理动作矩阵
  - 组织真源明细
  - creator/raw organization fields

### 6.2 `project/detail`

- `project/detail` 现正式定义为：
  - 公域 detail read surface
  - 可选登录态 owner-aware 分流 surface
- 它可以承接：
  - shared `ProjectReadModel`
  - `viewerProjectRelation`
- 它不可以承接：
  - 私域进度 truth
  - `my/projects` 资产分组 truth
  - `workbench` 摘要 truth
  - owner capability matrix

### 6.3 `my/projects`

- `my/projects` 现正式定义为：
  - 当前 organization scope 下的私域项目资产 family
- 它必须承接：
  - `publicProject`
  - `privateSummary/privateProgress`
- 它不允许被解释为：
  - 公域项目展示 family
  - workbench 摘要 family
  - 第二条 `project/detail`

### 6.4 `workbench`

- `workbench` 现正式定义为：
  - 私域摘要与导流页
- 它只允许承接：
  - recent project context
  - create entry gate
  - current downstream continuation entry booleans
- 它不允许承接：
  - 多项目资产 truth
  - 单项目完整私域进度 truth
  - 第二项目状态机
  - 第二 dashboard

### 6.5 Four-object Relation Finalized

- 四者关系现正式裁定为：
  - `viewerProjectRelation`
    - relation carrier only
  - `project/detail`
    - public detail + owner-aware handoff
  - `my/projects`
    - private asset and private progress family
  - `workbench`
    - private summary and routing family
- 当前正式禁止以下混用：
  - 用 `viewerProjectRelation` 代替私域资产归属 truth
  - 用 `workbench` 代替 `my/projects`
  - 用 `project/detail` 代替 `my/projects/{projectId}`
  - 用 `my/projects` 反向重写公域 detail 真义

## 7. Single Truth Ownership Table

| Decision object | Current single truth owner | Read/consume owner | Not allowed to own |
|---|---|---|---|
| project publish eligibility final judgement | `Server` eligibility layer + create command boundary | `BFF` and Flutter may only consume blocked/allowed result | `App`, `BFF`, local UI guards |
| session validity | `Server` current-session verification + DB-backed session truth | `BFF`, Flutter | local header inference |
| organization scope | `Server` organization membership truth | `BFF`, Flutter | `workbench`, `my-project`, frontend cache |
| buyer-role eligibility | `Server` membership role truth | `BFF`, Flutter | `workbench` booleans as final truth |
| certification eligibility | `Server` certification truth | `BFF`, Flutter | organization lifecycle, frontend shell copy |
| project lifecycle | `project.state` in `Server.project` | `BFF`, Flutter | `summary.stateLabel`, workbench summary |
| public visibility admission | `project.publishedAt` in `Server.project` | public list/detail query | `state` rename, frontend hide/show logic |
| owner relation | `Server` read-time relation calculation | `BFF`, Flutter | DB column, frontend local guess |
| private project asset scope | `project.organization_id` + current org scope | `my/projects` family | workbench recentProject carrier |
| private project progress | downstream trade truths read-time projection | `my/projects` family | project/detail, workbench |
| workbench action summary | `Server` summary projection only | `BFF`, Flutter | any business truth family |
| project review state | currently none | none | audit log, certification state, UI copy |
| future visibility/display status | currently none | none | `state`, `publishedAt`, summary copy |

## 8. Prohibited Mixing List

- 禁止把 `organization_certifications.certification_status` 误写成 `project review status`。
- 禁止把 `organizations.status` 误写成项目发布资格。
- 禁止把 `workbench.canCreateProject` 误写成最终发布资格真源。
- 禁止把 `summary.stateLabel` 误写成生命周期主状态。
- 禁止把 `publishedAt` 误写成完整生命周期。
- 禁止把 `state` 误写成公域可见性唯一 carrier。
- 禁止把 `viewerProjectRelation` 误写成项目资产 owner truth。
- 禁止把 `project/detail` 误写成 `my/projects/{projectId}`。
- 禁止把 `my/projects` 误写成 workbench 摘要扩面。
- 禁止把 append-only `project_publish_audit_log` 误写成项目审核状态机。
- 禁止在当前阶段偷实现 `visibility` / `displayStatus` 并宣称已冻结。
- 禁止用 Flutter UI state、BFF response shaping、或文案 copy 代替新的业务真源。

## 9. Minimum Implementation Follow-up Patch List

- `P0`
  - 在 `Server` 项目创建命令处补齐 approved certification gate，使其与已冻结 publish eligibility 规则一致。
  - 在 `workbench` 的 `canCreateProject` projection 中补齐 certification 影响，避免导流与最终命令判定分叉。
  - 清理任何会让当前链路被误解为“项目审核中 / 审核通过后发布”的用户文案或控制文案。
- `P1`
  - 收紧 `my-project BFF` 对缺失 `viewerProjectRelation` 的默认 `owner` fallback，避免掩盖上游 carrier 缺失。
  - 在后续统一裁决中继续处理 `historicalProjects` 语义冲突，但本裁决单不直接改写该结论。
- `P2`
  - 为未来 `visibility/displayStatus` 预留独立议题与命名空间，但当前不落实现。

## 10. Stage Meaning

- 本裁决单通过后，以下结论正式固定：
  - 当前 publish eligibility 的唯一真义已明确
  - 当前不存在项目审核状态机的结论已明确
  - `state/publishedAt/future visibility` 的职责分工已明确
  - owner relation 与私域承接边界已明确
- 本裁决单不等于：
  - 已完成代码修复
  - 已进入支付 / 押金 / 佣金主线
  - 已完成更细 visibility policy freeze

## 11. Next Single Action

- 下一步唯一动作：
  - 进入第二份文书裁决，专门裁定 `historicalProjects / formalCompletionStatus / evaluationStatus / archive grouping` 的统一语义
