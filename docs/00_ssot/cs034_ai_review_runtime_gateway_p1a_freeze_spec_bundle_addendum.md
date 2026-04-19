---
title: CS-034 AI Review Runtime Gateway P1-A Freeze Spec Bundle
status: frozen
owner: Codex Control
scope: docs-only-freeze-spec
created_at: 2026-04-08
---

# CS-034 AI 审核服务统一接入层 P1-A 冻结与规格包

## A. 当前判断对象

当前判断对象为：

`CS-034 AI 审核服务统一接入层 P1-A`

本包是 `CS-034` 的第一段 bounded docs-only freeze/spec 切片。

## B. 当前目标

本包当前目标只冻结：

- `Server`-owned AI review runtime gateway 的最小接入契约
- 最小 truth carrier 与 provider-normalization 边界
- `BFF / Flutter` 非 owner、非 raw-output surface 边界

本包不直接放开 implementation unlock。

## C. 当前直接纳入项

| 能力编号 | 当前冻结语义 |
| --- | --- |
| `CS-034` | 只冻结 AI review runtime gateway 的最小统一接入边界。 |

## D. 当前明确不纳入项

- `CS-019` / `Block P0-B`
- `CS-020` / `CS-021` / `CS-022`
- penalty / appeal full desk 扩写
- AI runtime 自动处罚
- public app-facing AI console
- 多包自动 implementation unlock
- `release-prep / launch approval`

## E. 当前上游依赖

本包建立在以下已完成或已冻结资产之上：

- `content_safety_p0_runtime_dependency_judgment_addendum.md`
- `forum_publish_ai_review_gate_boundary_addendum.md`
- `forum_publish_ai_review_gate_contracts_addendum.md`
- `forum_publish_ai_review_gate_truth_addendum.md`
- `forum_publish_ai_review_gate_bff_surface_addendum.md`
- `forum_publish_ai_review_gate_frontend_surface_addendum.md`

## F. 当前路径家族冻结

本包不新增 app-facing 或 BFF-facing route family。

本包只冻结 `Server` 内部 AI gateway contract / truth family，不把它暴露成：

- `/api/app/*` AI runtime route
- `/server/admin/*` AI console route
- 裸 `/ai/*` public route

## G. 当前最小 gateway 语义

当前 `CS-034 P1-A` 只允许把统一接入层理解为：

- `Server` 对多类 AI review provider 的统一调用边界
- provider request/response 的最小 normalization truth
- 业务包只消费 `Server` materialized final decision，不直连 provider

当前不允许把它写成：

- AI runtime 已正式开放
- app-facing AI review console
- 自动处罚状态机
- 全站治理中心

## H. 当前阶段门禁核查表

### 已通过门禁

- reserved-carrier 门禁：`CS-034` 已在内容安全母版与运行时裁决中保留为 P1 carrier。
- 上游边界门禁：forum AI review gate 的 L0/L2/L3/Frontend 边界已存在，可作为当前统一 gateway 的最小落点样例。
- 架构门禁：`Server` 继续为唯一 truth owner；`BFF / Flutter` 不得拥有 AI review truth。

### 当前需补齐但本轮已冻结承接的门禁

- contracts 门禁：已由 `docs/01_contracts` 冻结 AI gateway normalized envelope。
- backend truth 门禁：已由 `docs/02_backend` 冻结 gateway carrier 与 provider normalization truth。
- BFF surface 门禁：已由 `docs/03_bff` 冻结 no-direct-gateway surface。
- frontend surface 门禁：已由 `docs/04_frontend` 冻结 no-direct-gateway UI surface。

### 一票否决条件

以下任一成立，则本包 implementation 仍为 `No-Go`：

- 将 gateway 写成 public app-facing AI console
- 将 gateway 写成自动处罚引擎
- 将 gateway 写成 penalty / appeal full desk
- 在 `BFF` 中持有 AI review truth
- 在 Flutter 暴露 raw model output

### 当前门禁结论

`Go only for later implementation-unlock judgment authoring under the bounded CS-034 P1-A package.`

本文件本身不是 implementation unlock。

## I. 当前允许目录

本轮 freeze/spec authoring 允许触达：

- `docs/00_ssot/**`
- `docs/01_contracts/**`
- `docs/02_backend/**`
- `docs/03_bff/**`
- `docs/04_frontend/**`

## J. 当前禁止目录

本轮不得触达：

- `apps/server/**`
- `apps/bff/**`
- `apps/mobile/**`
- `apps/admin/**`
- `packages/**`

## K. Anti-Omission Check

- `CS-034` 已登记并由本轮形成完整 freeze/spec bundle。
- `content_safety_p0_runtime_dependency_judgment` 与 forum AI review gate 上游文书已被承接，未被改写为本包 runtime pass。
- 本轮没有回收或删除任何既有内容安全能力点。
- 本轮没有把 implementation unlock、penalty/appeal full desk、release-prep、launch approval 偷带入 `CS-034`。

Anti-omission conclusion:

- 无未登记
- 无未承接
- 无未回收
- 无默认删除
- 无越界实施

## L. 当前阶段结论

`CS-034 AI 审核服务统一接入层` 从当前轮开始进入：

- `P1-A`
- `已冻结`

但仍未进入 implementation unlock。

## M. 下一轮唯一动作

返回总控，输出：

`CS-034 AI Review Runtime Gateway P1-A implementation unlock judgment`

且只允许按本轮已冻结边界继续下一层 docs authoring。
