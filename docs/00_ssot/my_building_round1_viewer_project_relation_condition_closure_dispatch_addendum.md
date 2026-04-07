---
owner: Codex 总控
status: frozen
purpose: Freeze the single bounded correction dispatch required to close the retained `viewerProjectRelation` carrier condition before `我的楼 Round 1` may request any integration-release gate.
layer: L0 SSOT
freeze_date_local: 2026-04-05
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/my_building_round1_increment_dispatch.md
  - docs/00_ssot/my_building_round1_result_verification_review_conclusion_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_contract_freeze_addendum.md
  - apps/server/src/modules/my_project/my-project.presenter.ts
  - apps/server/src/modules/my_project/my-project.query.service.ts
  - apps/server/src/modules/project/project-query.service.ts
---

# 《我的楼 Round 1 viewerProjectRelation 条件闭环增量派工单》

## 1. Scope

- 本派工单只服务于：
  - `我的楼专项开发主线`
  - `我的楼 Round 1` retained condition closure
- 本派工单只解决：
  - `my-project detail` server-side `viewerProjectRelation` carrier 显式对齐
- 本派工单不等于：
  - integration release 放行
  - release-prep 放行
  - closure 放行

## 2. Current Condition

- 当前待闭环条件固定为：
  - `MyProjectDetailReadModel.publicProject` 已冻结复用 `ProjectReadModel`
  - `ProjectReadModel.viewerProjectRelation` 已是 required carrier
  - `my-project detail` server-side 当前尚未显式带出该字段
  - BFF 正在以 fallback 维持形状
- 当前必须写死：
  - BFF fallback 只能视为兼容兜底
  - 不得再把它写成 server-side alignment 已完成

## 3. Allowed Correction Scope

- 当前只允许派给：
  - `后端 Agent`
- 当前只允许改动：
  - [my-project.presenter.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/my_project/my-project.presenter.ts)
  - [my-project.query.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/my_project/my-project.query.service.ts)
- 当前允许的最小目标：
  - 让 `GET /server/my/projects/{projectId}` 返回的 `publicProject` 显式携带 `viewerProjectRelation`
  - 在当前 `my-project` owner-scoped detail family 内，把该 carrier 与 frozen contract 对齐
- 当前允许的最小验证：
  - `apps/server` 本地或云端 `tsc --noEmit`
  - `apps/server` 本地或云端 `nest build`
  - 最小 detail smoke / contract proof，证明 server-side `publicProject.viewerProjectRelation` 已显式存在

## 4. Hard Prohibitions

- 当前严格禁止：
  - 新增 table
  - 新增 snapshot
  - 新增 second state machine
  - 新增 migration
  - 越出 `apps/server/src/modules/my_project/**`
  - 改写 `publicProject + privateProgress` contract
  - 改写 `plannedEndAt` / formal completion 既有真义
  - 改写 BFF / Flutter 边界
  - integration release 口径
  - 发布口径

## 5. Receipt Format

- 回执只允许提交：
  - correction receipt
  - touched paths
  - exact fix summary
  - validation evidence
- 回执必须显式回答：
  - 当前 `viewerProjectRelation` 在 `GET /server/my/projects/{projectId}` 是否由 server-side 显式输出
  - 当前是否仍保持 `my-project` owner-scoped detail family，不扩面为第二 detail family

## 6. Current Go / No-Go

- 当前阶段结论：
  - `Go` for bounded backend condition-closure correction
  - `No-Go` for integration release gate submission
  - `No-Go` for release-prep
  - `No-Go` for closure

## 7. Next Unique Action

- 下一轮唯一动作：
  - 先把本派工单对应的 bounded correction 口令发给 `后端 Agent`
- 只有在以下条件全部满足后，才允许进入下一阶段：
  1. `后端 Agent` 已提交条件闭环 correction receipt
  2. 总控已独立复核 server-side `viewerProjectRelation` carrier 显式存在
  3. 然后才允许重提 `我的楼 Round 1` 结果校验补充复核
