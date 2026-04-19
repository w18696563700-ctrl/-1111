---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the L0 lifecycle-correction ruling for my-project, distinguishing
  draft delete, submitted withdraw, submitted archive, published close, and
  the explicit no-implementation boundary for awarded or converted-to-order
  business close.
layer: L0 SSOT
freeze_date_local: 2026-04-13
based_on:
  - AGENTS.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_authority_refresh_addendum.md
  - docs/00_ssot/my_project_four_stage_smooth_flow_rule_freeze_addendum.md
  - docs/00_ssot/lifecycle_state_machine.md
  - docs/01_contracts/openapi.yaml
  - apps/server/src/modules/project/project-write.service.ts
  - apps/server/src/modules/project/project-query.service.ts
  - apps/server/src/modules/my_project/my-project.presenter.ts
  - apps/bff/src/routes/project/app-project.controller.ts
  - apps/bff/src/routes/my_project/my-project.controller.ts
---

# 《我的项目生命周期修正规则第二轮 ruling 补充单》

## 1. Scope

- 本冻结单只覆盖：
  - `我的项目` 生命周期修正主线
  - `draft / submitted / published / awarded | converted_to_order`
    的 owner action boundary
  - `delete / withdraw / archive / close` 的真值区别
- 本冻结单不进入：
  - mobile 页面结构与文案
  - Admin
  - `bid / payment / forum / enterprise_hub`
  - integration
  - release-prep
  - production release

## 2. Freeze Conclusion

- `draft`：
  - 继续允许 `delete`
  - `delete` 只服务 `draft`
  - `delete` 不得继续混用为 `withdraw / archive / close`
- `submitted`：
  - 正式允许 `withdraw to draft`
  - 正式允许 `archive`
  - `withdraw` 与 `archive` 是两个不同动作
- `published`：
  - 不允许 `delete`
  - 正式允许 `close`
  - 用户侧 `下架 / 关闭` 在当前真值层统一收口为：
    - `published -> archived`
    - 并退出 public showcase corridor
- `awarded / converted_to_order`：
  - 当前禁止 `delete`
  - 当前禁止 `withdraw / archive / close`
  - 当前只能走后续 `业务关闭链`
  - 由于当前 repo 中尚无最小 close carrier，本轮只冻结边界，不实施

## 3. State Model Ruling

- `submitted -> draft`：
  - 作为正式动作落地
  - 不新增 persisted state
- `submitted -> 作废 / 归档`：
  - 使用 project 上位状态机中已存在的 `archived`
  - 本轮不发明 `cancelled / invalid / withdrawn_project`
- `published -> 下架 / 关闭`：
  - 当前正式进入既有 terminal state `archived`
  - 本轮不发明 `offline / unpublished / closed_project`
- `awarded / converted_to_order`：
  - 本轮不扩写 state
  - 关闭链留在后续 order / fulfillment / after-sales object

## 4. Read-side Ruling

- public `project/list` 与 public `project/detail`：
  - `archived` 项目必须不可见
- owner-private `my/projects`：
  - `archived` 项目允许继续可读
  - `historicalProjects` 不再只对应
    `formalCompletionStatus = formally_completed`
  - `historicalProjects` 同时允许承接 owner-archived project
- 当前 `workbench`：
  - 不在本轮新增 project close command desk
  - 继续只作为 summary / handoff surface 读取

## 5. Delete Boundary Ruling

- 当前 `DELETE /api/app/my/projects/{projectId}` 与
  `DELETE /server/projects/{projectId}`：
  - 继续只服务 `draft`
  - 不得扩大为 `submitted / published / converted_to_order`
    的统一回收动作

## 6. Audit Ruling

- 当前必须新增并保留 append-only audit：
  - `project_withdrawn_to_draft`
  - `project_archived`
  - `project_closed`
- 当前 audit payload 至少应记录：
  - `previousState`
  - `nextState`
  - `projectId`
  - owner actor attribution

## 7. Migration Ruling

- 当前 round 默认 `No Migration`
- 只有在 docs-only freeze 明确需要新增状态字段、关闭时间字段、
  或数据库约束调整时，才允许 migration
- 当前 round 因只复用已存在的 `state varchar(32)` carrier 与
  `archived` state value，不先引入 migration

