---
title: historicalProjects 语义裁决单
owner: Codex 总控
status: frozen
layer: L0 SSOT
freeze_date_local: 2026-04-10
purpose: >
  仅围绕 `my/projects` 里的 `ongoingProjects / historicalProjects`，
  裁决 `historicalProjects` 的正式语义，统一 contract、backend truth、
  runtime implementation 与 Flutter App 消费口径。
inputs_canonical:
  - docs/01_contracts/openapi.yaml
  - docs/02_backend/my_project_entry_and_single_project_private_carry_persistence_truth_addendum.md
  - apps/server/src/modules/my_project/my-project.presenter.ts
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_list_page.dart
  - apps/mobile/test/my_project_private_carry_test.dart
  - docs/00_ssot/project_permission_and_state_unified_ruling_addendum.md
---

# historicalProjects 语义裁决单

## 1. 裁决结论

本单正式裁决：

- `historicalProjects` 在当前阶段应正式视为
  `formalCompletionStatus = formally_completed` 的 bucket。
- `ongoingProjects` 在当前阶段应正式视为
  `formalCompletionStatus != formally_completed` 的 bucket。
- `historicalProjects` 当前不再保留“仅为归档分组、且不等于正式完结”的 contract 口径。
- 当前应保留 backend truth 与 runtime implementation 一侧，修正 contract 文字与前端文案说明，使四层一致。

本裁决的理由只有一条核心原则：

- 当前系统已经存在一个可读时派生、可被详情页和列表页共同消费的正式完结真源：
  `formalCompletionStatus`
- 当前系统并不存在另一套独立“归档分组真源”
- 因此 `historicalProjects` 若继续被定义为“不等于正式完结”，就会成为无真源支撑的伪语义

## 2. 为什么当前会冲突

当前冲突来源不是多实现分叉，而是四层定义顺序失配：

- contract 层先把 `historicalProjects` 写成“归档分组，不等于正式完结”
- backend truth 随后把它冻结成“由 `formalCompletionStatus` 派生的读时 bucket”
- runtime presenter 按 backend truth 实现，直接以 `formally_completed` 分桶
- Flutter App 页面与测试又按 runtime 结果消费，于是实际运行口径已经落在“历史项目 = 正式完结 bucket”

结论：

- 现在不是 runtime 偏离 contract 后随机演化
- 而是 contract 没有跟上 backend truth 与 runtime 已冻结的真实口径

## 3. 正式语义定义

### 3.1 `historicalProjects`

- 当前正式定义为：
  - `privateSummary.formalCompletionStatus === 'formally_completed'` 的列表 bucket
- 这是读时分组结果，不新增单独持久化列
- 这是当前 `my/projects` 列表分层的唯一正式判断标准

### 3.2 `ongoingProjects`

- 当前正式定义为：
  - 不属于 `historicalProjects` 的其余项目 bucket
- 在当前实现期内，可视为
  - `privateSummary.formalCompletionStatus !== 'formally_completed'`

### 3.3 非目标

- 本裁决不引入新的 archive truth
- 本裁决不新增 `isArchived`、`historyBucket`、`archivedAt` 等字段
- 本裁决不改变 `formalCompletionStatus` 自身派生规则
- 本裁决不展开支付、押金、佣金、结算类分组

## 4. 四层对照表

| 层 | 当前内容 | 当前含义 | 是否冲突 |
|---|---|---|---|
| contract | `/api/app/my/projects` 描述写明 `historicalProjects` 是 archival grouping，且 must not be treated as a synonym for formally completed or already rated` | 把历史项目定义成“归档组”，并明确否认其等于正式完结 | 是，冲突源头 |
| backend truth | `ongoingProjects / historicalProjects` 冻结为读时分组，且由 `formalCompletionStatus` 派生结果决定 | 把历史项目定义为“正式完结结果驱动的 bucket” | 否 |
| runtime | presenter 中 `formalCompletionStatus === 'formally_completed'` 直接进入 `historicalProjects` | 运行时已经把历史项目当作正式完结 bucket | 否 |
| frontend | 列表页只展示“进行中 / 历史项目”两组；测试数据中 `historicalProjects` 对应 `formalCompletionStatus='formally_completed'` | 前端消费已经默认接受“历史项目 = 正式完结组” | 否 |

## 5. 关键证据

### 5.1 contract

`openapi.yaml` 当前写明：

- `historicalProjects` is an archival grouping
- must not be treated as a synonym for formally completed or already rated

这代表 contract 当前否认“历史项目 = 正式完结 bucket”。

### 5.2 backend truth

backend truth 当前写明：

- `ongoingProjects / historicalProjects` 为读时分组
- 由 `formalCompletionStatus` 派生结果决定

这已经把 bucket 语义绑定到正式完结态。

### 5.3 runtime

`MyProjectPresenter.toListResponse()` 当前实现：

- 若 `item.privateSummary.formalCompletionStatus === 'formally_completed'`
- 则 push 到 `historicalProjects`
- 否则 push 到 `ongoingProjects`

这说明运行态无任何“独立归档规则”。

### 5.4 frontend

Flutter App 当前：

- 页面只消费 `ongoingProjects / historicalProjects` 两组
- 测试样例里 `historicalProjects` 项明确配 `formalCompletionStatus='formally_completed'`

这说明前端语义已与 runtime 对齐，而不是与旧 contract 对齐。

## 6. 应该保哪一边，另一边怎么修

当前应保留：

- backend truth
- runtime implementation
- frontend 当前消费口径

当前应修正：

- contract 描述

原因：

- backend truth 已给出明确可执行真源
- runtime 已稳定落地且与 truth 一致
- frontend 已按该语义消费
- contract 现有“归档分组不等于正式完结”的说法没有对应真源与运行机制支撑

因此本单正式结论是：

- 改 contract
- 不改当前分组实现方向

## 7. 禁止继续保留的模糊表述

- 禁止再写：
  - `historicalProjects` 只是归档分组
  - `historicalProjects` 不等于正式完结
  - `historicalProjects` 与 `formalCompletionStatus` 无直接关系
- 禁止前端文案或测试继续暗示：
  - 历史项目可以包含尚未正式完结项目
- 禁止 backend 后续再引入：
  - 第二套 archive-only 分桶规则，但不更新 contract 与 truth

## 8. 需要改 contract 还是改实现

正式结论：

- 需要改 contract
- 当前不应改 backend truth
- 当前不应改 presenter runtime 分组实现
- 当前前端页面结构不需要为本裁决调整逻辑，只需在 contract 对齐后继续沿用

## 9. 最小修复建议

### P0

- 修改 `openapi.yaml` 对 `/api/app/my/projects` 的 200 描述：
  - 删除 “`historicalProjects` is an archival grouping and must not be treated as a synonym for formally completed or already rated”
  - 改为：
    - `ongoingProjects / historicalProjects` are read-time buckets for the current organization scope
    - `historicalProjects` currently corresponds to projects whose `privateSummary.formalCompletionStatus` is `formally_completed`
    - `evaluationStatus` remains a separate field and must not be inferred from bucket name alone

### P1

- 在 backend truth 文书中补一行交叉引用：
  - 明确本 persistence truth 已被本裁决单提升为 contract-level official semantics

### P1

- 在 Flutter App 的页面文案或测试注释中避免再把“历史项目”解释成模糊 archive 概念
- 若需要说明，应写成：
  - 当前历史项目按正式完结分组

## 10. 最终冻结口径

当前阶段，`my/projects` 的两组正式语义冻结如下：

- `ongoingProjects`
  - 当前组织 scope 下，尚未达到 `formalCompletionStatus = formally_completed` 的项目 bucket
- `historicalProjects`
  - 当前组织 scope 下，已经达到 `formalCompletionStatus = formally_completed` 的项目 bucket

除非未来新增独立 archive truth 并完成新的 SSOT / contract / backend freeze，
否则不得再把 `historicalProjects` 解释为“与正式完结无关的归档分组”。
