---
owner: Codex 总控
status: frozen
purpose: Freeze the single bounded backend runtime-alignment dispatch required after direct `/server/*` evidence proved that `viewerProjectRelation` is still missing from the active runtime response.
layer: L0 SSOT
freeze_date_local: 2026-04-05
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/my_building_round1_viewer_project_relation_runtime_evidence_failure_addendum.md
  - docs/00_ssot/my_building_round1_viewer_project_relation_condition_closure_dispatch_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/server/src/modules/my_project/my-project.presenter.ts
  - apps/server/src/modules/my_project/my-project.query.service.ts
---

# 《我的楼 Round 1 viewerProjectRelation 运行态对齐增量派工单》

## 1. Scope

- 本派工单只服务于：
  - `我的楼专项开发主线`
  - `我的楼 Round 1` retained runtime-alignment gap
- 本派工单只解决：
  - active Server runtime 的 `/server/my/projects/{projectId}` 仍缺 `publicProject.viewerProjectRelation`
- 本派工单不等于：
  - 新一轮 feature implementation
  - integration release 放行
  - release-prep 放行
  - closure 放行

## 2. Current Problem

- 当前已固定的问题不是 contract 变化，也不是 frontend / BFF 施工问题。
- 当前固定问题是：
  - 仓库代码层已显式补入 `viewerProjectRelation`
  - 但 active runtime response 仍未带出该字段
- 因此当前必须先排查并闭环：
  - deployed source drift
  - dist artifact drift
  - release path drift
  - pm2 running target drift
  - or equivalent runtime-path mismatch

## 3. Allowed Scope

- 当前只允许派给：
  - `后端 Agent`
- 当前只允许改动或操作：
  - 云端 Server 当前 release / workspace / process 对齐链
  - 如确有必要，`apps/server/src/modules/my_project/**` 内的最小修正
- 当前必须优先做：
  - 先查 active runtime 用的源码 / dist / cwd / symlink / process target
  - 确认为何运行态与当前仓库代码不一致
  - 然后做最小重建 / 重启 / 同步修正

## 4. Hard Prohibitions

- 当前严格禁止：
  - 触碰 `apps/bff/**`
  - 触碰 `apps/mobile/**`
  - 新增 table
  - 新增 snapshot
  - 新增 second state machine
  - 新增 migration
  - 扩大到其他板块
  - integration release 口径
  - 发布口径

## 5. Required Receipt

- 回执只允许提交：
  - runtime-alignment correction receipt
  - inspected runtime paths
  - exact root cause
  - touched paths
  - rebuild / restart evidence
  - direct `/server/*` response proof
- 回执必须显式回答：
  - active Server runtime 之前为何缺 `viewerProjectRelation`
  - 当前 active Server runtime 是否已直接返回该字段
  - 证据是否来自 `/server/*`，且不经过 BFF

## 6. Current Go / No-Go

- 当前阶段结论：
  - `Go` for bounded backend runtime-alignment correction
  - `No-Go` for supplemental result verification pass
  - `No-Go` for integration release gate submission
  - `No-Go` for release-prep
  - `No-Go` for closure

## 7. Next Unique Action

- 下一轮唯一动作：
  - 先把本派工单对应的 runtime-alignment correction 口令发给 `后端 Agent`
- 只有在以下条件全部满足后，才允许进入下一阶段：
  1. `后端 Agent` 已提交 runtime-alignment correction receipt
  2. 总控已独立确认直打 `/server/my/projects/{projectId}` 时 `publicProject.viewerProjectRelation` 显式存在
  3. 然后才允许重提 `我的楼 Round 1` 结果校验补充复核
