---
title: CS-032 User Violation Score P1-A Freeze Spec Bundle
status: frozen
owner: Codex Control
scope: docs-only-freeze-spec
created_at: 2026-04-08
---

# CS-032 用户违规累计分 P1-A 冻结与规格包

## A. 当前判断对象

当前判断对象为：

`CS-032 用户违规累计分 P1-A`

本包是 `CS-032` 的第一段 bounded 只读切片。

## B. 当前目标

本包当前目标只冻结：

- 基于已生效治理处罚记录的用户违规累计分最小真相
- 当前 actor 在既有 `profile/governance/status` 摘要上的最小读取面
- 与 `CS-027`、`CS-028`、`Admin Review P0` 的最小衔接边界

本包不直接放开 implementation unlock。

## C. 当前直接纳入项

| 能力编号 | 当前冻结语义 |
| --- | --- |
| `CS-032` | 只冻结基于已生效治理处罚记录的最小累计分 truth/read slice。 |

## D. 当前明确不纳入项

- 自动处罚
- 申诉中心扩写
- penalty history center
- 存量复扫
- AI 审核统一接入层
- `CS-019`
- `CS-033`
- `CS-034`
- `P1 / P2` 其他包自动解锁
- `release-prep / launch approval`

## E. 当前上游依赖

本包建立在以下已完成资产之上：

- `CS-027 Governance Penalty P1-A` completed
- `CS-028 Governance Appeal P1-A` completed
- `Admin Review P0` completed

本包继续沿用以下真源，不得重建：

- `content_safety_capability_tracking_table_v1.md`
- `source_of_truth_map.md`
- `admin_review_p0_completion_filing_addendum.md`
- `cs027_governance_penalty_p1a_result_verification_pass_addendum.md`
- `cs028_governance_appeal_p1a_completion_filing_addendum.md`
- `docs/01_contracts/blacklist_whitelist_and_permanent_ban_rules_v1_contracts_addendum.md`
- `docs/02_backend/blacklist_whitelist_and_permanent_ban_rules_v1_backend_truth_addendum.md`
- `docs/03_bff/blacklist_whitelist_and_permanent_ban_rules_v1_bff_surface_addendum.md`

## F. 当前路径家族冻结

本包不新增独立 score route family。

本包只允许在既有 bounded path family 上冻结最小读取面：

- `GET /api/app/profile/governance/status`

本包同时明确：

- 不新增裸 `/score/*`
- 不新增裸 `/governance/score/*`
- 不新增新的 user-side penalty history path
- 不新增新的 appeal center path

## G. 当前最小累计分语义

当前 `CS-032 P1-A` 只允许把用户违规累计分理解为：

- `Server` 基于已生效 `governance_penalties` 计算出的 bounded score snapshot
- current actor 在当前 subject set 下的最小只读摘要字段
- 与现有 `governanceStatus / currentPenalty / appealEntryState` 并列的补充摘要

当前不允许把它写成：

- 完整 trust-score engine
- 自动处罚触发器
- 用户侧处罚历史中心
- 更大治理中心入口

## H. 当前阶段门禁核查表

### 已通过门禁

- 上游承接门禁：`CS-027`、`CS-028`、`Admin Review P0` 已完成并可作为当前 package 依赖。
- 读取面门禁：既有 `GET /api/app/profile/governance/status` 已存在，可承接最小 score snapshot。
- 架构门禁：`Server` 继续为唯一 truth owner，`BFF` 只做 shaping，Flutter 只做 bounded consumption。

### 当前需补齐但本轮已冻结承接的门禁

- contracts 门禁：已由 `docs/01_contracts` 冻结 score snapshot 只读 contract。
- backend truth 门禁：已由 `docs/02_backend` 冻结 score derivation truth。
- BFF surface 门禁：已由 `docs/03_bff` 冻结 bounded shaping。
- frontend surface 门禁：已由 `docs/04_frontend` 冻结 bounded read-only consumption。

### 一票否决条件

以下任一成立，则本包 implementation 仍为 `No-Go`：

- 将累计分写成自动处罚引擎
- 将累计分写成 penalty history center
- 将累计分写成 appeal center expansion
- 将累计分写成 AI 审核统一接入层
- 在 `BFF` 中持有第二套 score truth
- 新开独立 `/score/*` 路由族

### 当前门禁结论

`Go only for later implementation-unlock judgment authoring under the bounded CS-032 P1-A package.`

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

- `CS-032` 已登记并由本轮形成完整 freeze/spec bundle。
- `CS-027`、`CS-028`、`Admin Review P0` 已被承接，未被改写为本包 truth。
- 本轮没有回收或删除任何既有治理能力点。
- 本轮没有把 appeal center、penalty history、AI、release-prep、launch approval 偷带入 `CS-032`。

Anti-omission conclusion:

- 无未登记
- 无未承接
- 无未回收
- 无默认删除
- 无越界实施

## L. 当前阶段结论

`CS-032 用户违规累计分` 从当前轮开始进入：

- `P1-A`
- `已冻结`

但仍未进入 implementation unlock。

## M. 下一轮唯一动作

返回总控，输出：

`CS-032 User Violation Score P1-A implementation unlock judgment`

且只允许按本轮已冻结边界继续下一层 docs authoring。
