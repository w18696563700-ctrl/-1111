---
title: CS-030 My Appeal History P2-A Freeze Spec Bundle
status: frozen
owner: Codex Control
scope: docs-only-freeze-spec
created_at: 2026-04-08
---

# CS-030 我的申诉记录 P2-A 冻结与规格包

## A. 当前判断对象

当前判断对象为：

`CS-030 我的申诉记录 P2-A`

本包是 `CS-030` 的第一段 bounded 用户侧只读切片。

## B. 当前目标

本包当前目标只冻结：

- 当前登录用户的申诉记录列表
- 当前登录用户的申诉记录详情
- 围绕现有 `governance_appeal_cases` 与 `governance_penalties` 的最小只读回显

本包不直接放开 implementation。

## C. 当前直接纳入项

| 能力编号 | 当前冻结语义 |
| --- | --- |
| `CS-030` | 只冻结用户侧 `我的申诉记录` list/detail 最小只读包。 |

## D. 当前明确不纳入项

- `CS-028` user-side appeal submit completion acceptance
- 用户侧处罚历史中心
- 全量治理中心
- 白名单 / 永久封禁用户侧历史
- 多轮申诉
- 申诉聊天 / 谈判回路
- 处罚申诉联动自动化
- `CS-032` 用户违规累计分
- `CS-033` 存量内容复扫
- `CS-034` AI 审核服务统一接入层
- `CS-019` / Block P0-B
- `Admin Review P0` completion
- `release-prep / launch approval`

## E. 当前上游依赖

本包建立在以下已完成资产之上：

- `CS-027 Governance Penalty P1-A` completed
- `CS-028 Governance Appeal P1-A` completed
- `CS-029 我的举报记录` completed

本包继续沿用以下真源，不得重建：

- `content_safety_governance_master_v1_control_package_positioning_addendum.md`
- `content_safety_governance_master_v1_usage_rules_addendum.md`
- `content_safety_capability_tracking_table_v1.md`
- `source_of_truth_map.md`
- `admin_review_p0_freeze_addendum.md`
- `cs027_governance_penalty_p1a_result_verification_pass_addendum.md`
- `cs028_governance_appeal_p1a_completion_filing_addendum.md`
- `docs/01_contracts/blacklist_whitelist_and_permanent_ban_rules_v1_contracts_addendum.md`
- `docs/02_backend/blacklist_whitelist_and_permanent_ban_rules_v1_backend_truth_addendum.md`
- `docs/03_bff/blacklist_whitelist_and_permanent_ban_rules_v1_bff_surface_addendum.md`

## F. 当前路径家族冻结

本包新增并冻结以下最小路径家族：

- `GET /api/app/profile/governance/appeals`
- `GET /api/app/profile/governance/appeals/{appealCaseId}`
- `GET /server/profile/governance/appeals`
- `GET /server/profile/governance/appeals/{appealCaseId}`

本包明确不新增：

- `POST /api/app/profile/governance/appeals` 之外的 submit 新语义
- 裸 `/appeal/*`
- 裸 `/penalty/*`
- `/api/app/profile/governance/penalties*`
- 任意 Admin 路由经 BFF 代理

## G. 当前阶段门禁核查表

### 已通过门禁

- 真源门禁：当前包继续只以 `docs/**` 为正式真源。
- 架构边界门禁：Flutter -> BFF -> Server 不变；Admin 不进入本包。
- 阶段控制门禁：当前目标单一，非目标明确，允许目录明确。
- 审计门禁：本包为只读历史回显，不新增 must-audit 动作。

### 当前需补齐但本轮已冻结承接的门禁

- 契约门禁：已由 `docs/01_contracts` 冻结当前 list/detail contract。
- Backend truth 门禁：已由 `docs/02_backend` 冻结当前 Server-owned read model boundary。
- BFF surface 门禁：已由 `docs/03_bff` 冻结当前 app-facing shaping boundary。
- Frontend surface 门禁：已由 `docs/04_frontend` 冻结当前 Flutter consumption boundary。

### 一票否决条件

以下任一成立，则本包 implementation 仍为 `No-Go`：

- 将本包扩成用户侧处罚历史中心
- 将本包扩成治理总控台
- 直接打开白名单 / 永久封禁 history
- 在 `BFF` 中持有第二套 appeal truth
- 绕过 `BFF` 让 Flutter 直连 `Server`
- 在无当前 actor 过滤的情况下暴露他人 appeal detail

### 当前门禁结论

`Go only for later implementation prompt authoring under the bounded CS-030 P2-A package.`

本文件本身不是 implementation prompt。

## H. 当前允许目录

本轮 freeze/spec authoring 允许触达：

- `docs/00_ssot/**`
- `docs/01_contracts/**`
- `docs/02_backend/**`
- `docs/03_bff/**`
- `docs/04_frontend/**`

## I. 当前禁止目录

本轮不得触达：

- `apps/server/**`
- `apps/bff/**`
- `apps/mobile/**`
- `apps/admin/**`
- `packages/**`

## J. 当前阶段结论

`CS-030 我的申诉记录` 不再维持“未开包”状态。

从当前轮开始，它进入：

- `P2-A`
- `已冻结`

但仍未进入 implementation。

## K. 下一轮唯一动作

返回总控，输出：

`CS-030 My Appeal History P2-A implementation prompt bundle`

且只允许按本轮已冻结边界派发 `Server -> BFF -> Flutter` 的 bounded implementation。
