---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the L3 backend truth boundary for the prepublish relabel and publish
  confirmation round, keeping Server lifecycle truth unchanged while aligning
  submitted-state read semantics to the later user-facing prepublish wording.
layer: L3 Backend
freeze_date_local: 2026-04-13
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_publish_prepublish_relabel_and_confirmation_ruling_addendum.md
  - docs/01_contracts/project_publish_prepublish_relabel_and_confirmation_contract_freeze_addendum.md
  - apps/server/src/modules/project/project-write.service.ts
  - apps/server/src/modules/project/project.presenter.ts
  - apps/server/src/modules/my_project/my-project.presenter.ts
---

# 《项目发布对象簇｜预发布列表命名与发布确认重排 L3 backend truth freeze》

## Pricing Override Note

自 `2026-04-29` 起，若项目已接入
[platform_pricing_backend_truth_master_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/platform_pricing_backend_truth_master_v1.md)
定义的收费主线，则本文件中关于 `publishProject = submitted -> published` 的旧 backend no-delta 结论只保留为历史最小闭环参考。

当前收费主线下：

1. `publishProject` 仍是 canonical path
2. 但它不再是裸 `submitted -> published`
3. 若当前项目要求 `200 元项目真实性诚意金` 且未满足 `paid`，则 `publishProject` 必须 fail closed

## 1. Truth Ownership

- `Server` 继续是唯一 project lifecycle truth owner。
- 当前 round 不改写 canonical transition：
  - `draft -> submitted`
  - `submitted -> published`
  - `submitted -> draft`
  - `submitted -> archived`
  - `published -> archived`

## 2. Backend No-delta Rule

- 当前正式结论：
  - `No new state`
  - `No new table`
  - `No migration`
  - `No second lifecycle machine`
- `submitProject`
  继续只是：
  - `draft -> submitted`
- 历史最小闭环下，`publishProject`
  继续只是：
  - `submitted -> published`

## 3. Read-side Semantics

- 虽然 canonical state 仍是 `submitted`，
  当前 `Server` 输出给 owner-facing consumption 的 summary / state explanation，
  应当对齐为：
  - `已进入发布前核对阶段`
  - `待最终检查无误后正式发布`
- 当前正式禁止把 `submitted` 的 summary 继续写成
  “已提交但后续承接不明”的弱语义。

## 4. My-project Grouping Boundary

- `my_project` 读取侧当前继续以 raw state 归类：
  - `submitted` 仍留在 active owner list
  - 不进入 `historicalProjects`
- 本轮只改 owner-facing语义，不改 grouping truth carrier。

## 5. Backend Excluded Family

- 当前 backend 不负责：
  - 把 `预发布列表` 当成 persisted state
  - 提供单独 `prepublish queue` query
  - 为编辑页生成第二发布确认命令家族
