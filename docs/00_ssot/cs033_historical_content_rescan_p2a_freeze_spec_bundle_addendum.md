---
title: CS-033 Historical Content Rescan P2-A Freeze Spec Bundle
status: frozen
owner: Codex Control
scope: docs-only-freeze-spec
created_at: 2026-04-08
---

# CS-033 存量内容复扫 P2-A 冻结与规格包

## A. 当前判断对象

当前判断对象为：

`CS-033 存量内容复扫 P2-A`

本包是 `CS-033` 的第一段 bounded docs-only freeze/spec 切片。

## B. 当前目标

本包当前目标只冻结：

- 存量 forum content rescan 的最小 job truth
- 基于既有内容快照、举报/审核结果、规则基线的最小候选选择边界
- 与既有 `Admin Review P0` 复用衔接的最小治理承接面

本包不直接放开 implementation unlock。

## C. 当前直接纳入项

| 能力编号 | 当前冻结语义 |
| --- | --- |
| `CS-033` | 只冻结存量内容复扫的最小 truth/read/admin-handoff slice。 |

## D. 当前明确不纳入项

- 自动处罚
- penalty full desk 扩写
- appeal full desk 扩写
- 用户侧 penalty / appeal history center
- AI 审核统一接入层 runtime 落地
- `CS-019` / `Block P0-B`
- `CS-020` / `CS-021` / `CS-022`
- `P1 / P2` 其他包自动解锁
- `release-prep / launch approval`

## E. 当前上游依赖

本包建立在以下已完成或已冻结资产之上：

- `Forum Report P0` completed
- `Admin Review P0` completed
- `Safety Audit P0` completed
- `content_safety_capability_tracking_table_v1.md`
- `source_of_truth_map.md`

本包继续沿用以下真源，不得重建：

- `forum_report_p0_freeze_addendum.md`
- `admin_review_p0_completion_filing_addendum.md`
- `safety_audit_p0_freeze_addendum.md`

## F. 当前路径家族冻结

本包不新增 app-facing 或 BFF-facing route family。

本包只允许冻结最小 Server/Admin canonical family：

- `POST /server/admin/governance/rescan-jobs`
- `GET /server/admin/governance/rescan-jobs`
- `GET /server/admin/governance/rescan-jobs/{rescanJobId}`

本包同时明确：

- 不新增 `/api/app/*` user-side rescan route
- 不新增裸 `/rescan/*`
- 不新增独立 penalty / appeal center route

## G. 当前最小复扫语义

当前 `CS-033 P2-A` 只允许把存量内容复扫理解为：

- `Server` 对既有内容对象执行的 bounded retroactive candidate selection
- `Server` 对 rescan job 的最小 truth materialization
- 命中项继续通过既有 `review_tasks / admin review` 基线承接

当前不允许把它写成：

- 大规模自动处罚引擎
- 全量治理中心
- 用户侧复扫结果中心
- AI review runtime 已落地

## H. 当前阶段门禁核查表

### 已通过门禁

- 上游承接门禁：`Forum Report P0`、`Admin Review P0`、`Safety Audit P0` 已完成，可作为当前 package 依赖。
- truth 基线门禁：`audit_logs / content snapshots / review_tasks` 已有上游冻结基线。
- 架构门禁：`Server` 继续为唯一 truth owner；`BFF` 与 Flutter 不开启新面。

### 当前需补齐但本轮已冻结承接的门禁

- contracts 门禁：已由 `docs/01_contracts` 冻结最小 rescan-job contract。
- backend truth 门禁：已由 `docs/02_backend` 冻结最小 rescan truth。
- BFF surface 门禁：已由 `docs/03_bff` 冻结 no-new-surface 边界。
- frontend surface 门禁：已由 `docs/04_frontend` 冻结 no-new-surface 边界。

### 一票否决条件

以下任一成立，则本包 implementation 仍为 `No-Go`：

- 将复扫写成自动处罚引擎
- 将复扫写成用户侧 history center
- 将复扫写成 penalty/appeal full desk
- 将复扫写成 AI runtime gateway completion
- 在 `BFF` 中持有第二套 rescan truth
- 新开 app-facing rescan route family

### 当前门禁结论

`Go only for later implementation-unlock judgment authoring under the bounded CS-033 P2-A package.`

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

- `CS-033` 已登记并由本轮形成完整 freeze/spec bundle。
- `Forum Report P0`、`Admin Review P0`、`Safety Audit P0` 已被承接，未被改写为本包 truth。
- 本轮没有回收或删除任何既有内容安全能力点。
- 本轮没有把自动处罚、AI runtime completion、penalty/appeal full desk、release-prep、launch approval 偷带入 `CS-033`。

Anti-omission conclusion:

- 无未登记
- 无未承接
- 无未回收
- 无默认删除
- 无越界实施

## L. 当前阶段结论

`CS-033 存量内容复扫` 从当前轮开始进入：

- `P2-A`
- `已冻结`

但仍未进入 implementation unlock。

## M. 下一轮唯一动作

返回总控，输出：

`CS-033 Historical Content Rescan P2-A implementation unlock judgment`

且只允许按本轮已冻结边界继续下一层 docs authoring。
