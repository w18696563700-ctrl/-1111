---
title: project_exit_and_breach_governance_phase1_server_truth_and_persistence_addendum
owner: Codex 总控
status: frozen
layer: L3 Server Truth and Persistence
updated_at: 2026-04-29
purpose: Freeze Server truth, state transitions, persistence, audit, and migration plan for project exit and breach governance phase 1.
inputs_canonical:
  - docs/00_ssot/project_exit_and_breach_governance_phase1_rule_freeze_addendum.md
  - docs/01_contracts/project_exit_and_breach_governance_phase1_contracts_addendum.md
  - apps/server/src/modules/project/project-lifecycle.service.ts
  - apps/server/src/modules/project/project-write.service.ts
  - apps/server/src/modules/p0_pay/p0-pay-state-action.service.ts
  - apps/server/src/modules/credit_scoring_shadow/**
---

# 项目退出与违约治理第一期 L3 Server Truth 与 Persistence 冻结单

## 0. 总裁决

- 当前是否允许进入实现：`Conditional Go after 总控确认 Day4`
- 当前是否允许自动扣钱：`No-Go`
- 当前是否需要 migration：`Conditional Go`
- 当前 Server owner：`Server` 是唯一 project exit、cancellation、breach、audit 真相 owner。
- 当前实现原则：新增职责必须落入 dedicated service，不继续堆进现有超长 project service。

## 1. Server 模块边界

建议新增 dedicated service：

| 文件 / 模块 | 职责 |
|---|---|
| `project-exit-governance.service.ts` | 竞标中撤回、预发布作废、进行中取消、违约记录的入口协调 |
| `project-exit-case.entity.ts` | 取消/违约/撤回/作废的最小持久化 case |
| `project-exit-governance.presenter.ts` | 最小 accepted response shaping |
| `project-exit-governance.controller.ts` 或扩展 `project.controller.ts` | 挂载新增 Server routes |
| `project-exit-governance.errors.ts` | 新增错误码映射 |

禁止：

- 不把所有新增逻辑继续写进 `project-lifecycle.service.ts`。
- 不让 `BFF` 生成状态。
- 不让 `Flutter` 传入目标状态。

## 2. 状态机 Truth

| 动作 | 前置状态 | 后置状态 / 结果 | Server 规则 |
|---|---|---|---|
| draft delete | `draft` | `deleted` | 复用现有 delete；仅 draft |
| discard submitted | `submitted` | `archived` | 预发布作废删除，不硬删 |
| withdraw published | `published` | `submitted` | 下架公域，保留竞标历史 |
| request cancellation | `awarded / converted_to_order` | `cancellation_requested` exit case | project 主状态可保持 active，case 承接待确认 |
| accept cancellation | `cancellation_requested` case | `mutually_cancelled` case | 不回 submitted；订单/合同保留 |
| reject cancellation | `cancellation_requested` case | `rejected` case，项目继续 active | 保留协商失败记录 |
| record publisher breach | `awarded / converted_to_order` | `breach_recorded` case | 不扣钱 |
| record factory breach | `awarded / converted_to_order` | `breach_recorded` case | 可触发 P0-Pay hold，但不扣钱 |

说明：

- `cancellation_requested / mutually_cancelled / breach_recorded` 第一阶段可由 `project_exit_cases.status` 表达，不强制写入 `project.state`。
- 若后续产品要求在列表中按这些状态筛选，再进入 read-side projection 扩展。

## 3. Persistence 冻结

### 3.1 继续复用

| carrier | 用途 |
|---|---|
| `project.state` | `draft/submitted/published/archived/awarded/converted_to_order` 主生命周期 |
| `project.published_at` | 公域可见性辅助 truth |
| `project.summary` | 最小摘要与状态说明 |
| `project_publish_audit_log` / audit service | append-only 审计 |

### 3.2 新增最小表：`project_exit_cases`

建议新增表，避免把双方取消和违约塞进 `project.summary`。

字段冻结：

| 字段 | 类型建议 | 说明 |
|---|---|---|
| `id` | varchar(64) PK | exit case id |
| `project_id` | varchar(64) | 项目 |
| `order_id` | varchar(64) nullable | 有订单时绑定 |
| `contract_id` | varchar(64) nullable | 有合同时绑定 |
| `exit_type` | varchar(48) | `published_withdrawal/submitted_discard/mutual_cancellation/publisher_breach/factory_breach` |
| `status` | varchar(48) | `recorded/requested/accepted/rejected/cancelled` |
| `initiator_organization_id` | varchar(64) | 发起方 |
| `counterparty_organization_id` | varchar(64) nullable | 对方 |
| `breach_party` | varchar(32) nullable | `publisher/factory` |
| `reason_code` | varchar(64) | 原因码 |
| `reason_text` | text nullable | 原因说明 |
| `credit_impact_candidate` | boolean | 仅候选，不直接扣分 |
| `no_automatic_penalty_confirmed` | boolean | 第一阶段必须为 true |
| `requested_at` | timestamptz nullable | 发起时间 |
| `responded_at` | timestamptz nullable | 响应时间 |
| `closed_at` | timestamptz nullable | 关闭时间 |
| `request_id` | varchar(64) | 请求追踪 |
| `trace_id` | varchar(64) | trace |
| `created_at` | timestamptz | 创建时间 |
| `updated_at` | timestamptz | 更新时间 |

索引建议：

- `(project_id, created_at desc)`
- `(project_id, status)`
- `(initiator_organization_id, created_at desc)`
- `(counterparty_organization_id, created_at desc)`

### 3.3 旧数据兼容

- 旧 `draft/submitted/published/archived/awarded/converted_to_order` 不回填。
- 没有 exit case 的旧项目继续按原生命周期展示。
- 旧 `published -> archived` close 记录不反向改成撤回。

## 4. 竞标中撤回 Server Truth

事务内必须执行：

1. 验证当前 actor 是 project owner。
2. 验证 project.state 是 `published`。
3. 验证未进入 `awarded / converted_to_order`。
4. 查询 bid / authorization 影响范围。
5. 对 P0-Pay authorization 做安全处理：
   - 无支付订单的 pending authorization：取消或失效。
   - authorized / pending_contract_confirm：释放。
   - charged / final charge：fail closed。
6. 将 project.state 改为 `submitted`。
7. 清理 `publishedAt`。
8. 写 `project_exit_cases`，`exit_type=published_withdrawal`。
9. 写 append-only audit：`project_published_withdrawn_to_submitted`。
10. 返回 `state=submitted` 与 affected counts。

## 5. 预发布作废删除 Server Truth

事务内必须执行：

1. 验证 owner。
2. 验证 project.state 是 `submitted`。
3. 不调用 hard delete。
4. 将 project.state 改为 `archived`。
5. 清理 `publishedAt`。
6. 写 `project_exit_cases`，`exit_type=submitted_discard`。
7. 写 audit：`project_submitted_discarded`。
8. 返回 `state=archived`。

## 6. 进行中取消 Server Truth

### 6.1 request

事务内必须执行：

1. 验证当前项目处于 `awarded / converted_to_order` 或等价 active continuation。
2. 验证当前组织是项目双方之一。
3. 查找是否已有 open exit case；如有则 fail closed 或 idempotent return。
4. 新建 `project_exit_cases`：
   - `exit_type=mutual_cancellation`
   - `status=requested`
   - `credit_impact_candidate=false`
5. 不改 order/contract 终态。
6. 不扣款。

### 6.2 respond accept

1. 验证 responder 是 counterparty。
2. 验证 case.status 是 `requested`。
3. 将 case.status 改为 `accepted`。
4. 写 audit：`project_mutual_cancellation_accepted`。
5. 保留 order / contract / P0-Pay 历史。
6. 不回 `submitted`。

### 6.3 respond reject

1. 验证 responder 是 counterparty。
2. 验证 case.status 是 `requested`。
3. 将 case.status 改为 `rejected`。
4. 项目继续 active。
5. 写 audit：`project_mutual_cancellation_rejected`。

## 7. 违约记录 Server Truth

### 7.1 发布方违约

- 新建 `project_exit_cases`：
  - `exit_type=publisher_breach`
  - `status=recorded`
  - `breach_party=publisher`
  - `credit_impact_candidate=true`
- 不自动扣款。
- 可调用 P0-Pay release/hold 只在安全边界内执行；否则记录 Evidence Missing 并 fail closed。

### 7.2 工厂违约

- 新建 `project_exit_cases`：
  - `exit_type=factory_breach`
  - `status=recorded`
  - `breach_party=factory`
  - `credit_impact_candidate=true`
- 可进入已有 P0-Pay `breach_hold`，但不能默认扣服务费或保证金。
- 不直接改信用分。

## 8. P0-Pay 边界

| 场景 | 第一阶段规则 |
|---|---|
| 竞标中撤回且授权未支付 | 取消/失效 |
| 竞标中撤回且预授权已成功 | 释放，不扣罚 |
| 竞标中撤回且已经 final charge | fail closed |
| 发布方违约 | 可释放或记录 hold，不能扣罚 |
| 工厂违约 | 可 breach_hold，不能扣罚 |

## 9. Credit 边界

- 当前 repo 已有 `credit_scoring_shadow` 预埋。
- 第一阶段只写 `credit_impact_candidate=true` 与 audit。
- 不直接写 `organization_shadow_credit_ledgers`，除非后续单独冻结 credit integration 包。

## 10. Audit Events

新增候选 audit event：

| eventType | 场景 |
|---|---|
| `project_submitted_discarded` | 预发布作废删除 |
| `project_published_withdrawn_to_submitted` | 竞标中撤回到预发布 |
| `project_cancellation_requested` | 发起取消 |
| `project_cancellation_accepted` | 同意取消 |
| `project_cancellation_rejected` | 拒绝取消 |
| `project_publisher_breach_recorded` | 发布方违约 |
| `project_factory_breach_recorded` | 工厂违约 |

每条 audit 至少包含：

- `previousState`
- `nextState` 或 case status
- `projectId`
- `exitCaseId`
- `initiatorOrganizationId`
- `counterpartyOrganizationId` 如有
- `reasonCode`
- `noAutomaticPenalty=true`

## 11. Migration Plan

| 迁移项 | 是否需要 | 说明 |
|---|---:|---|
| `project_exit_cases` | 是 | 双方取消和违约记录需要独立 carrier |
| `project.state` enum/约束 | 否 | 当前 varchar 可继续承载既有主状态 |
| `payment` 相关表 | 否 | 第一阶段不扣款，不新增支付字段 |
| `credit` 相关表 | 否 | 第一阶段不直接写信用 ledger |
| backfill | 否 | 旧数据不回填 |

Rollback：

- migration 回滚只能删除尚未正式使用的新表。
- 一旦云端已写入 `project_exit_cases`，回滚必须保留表并停用 route，不允许删除历史 case。

## 12. 实现门禁

进入代码实现前必须满足：

1. L0/L2/L3 三份冻结单均存在。
2. 不修改费用扣罚逻辑。
3. 不把进行中直接回退到预发布。
4. 不删除 order/contract/bid/payment/audit。
5. 新增接口有幂等键。
6. Server tests 覆盖：
   - submitted discard
   - published withdraw
   - active cancellation request/respond
   - publisher breach record
   - factory breach record
   - charged authorization fail closed

## 13. 下一步唯一动作

经总控确认后进入 Day 4 Server 实现退出通道：

- 先实现 `submitted discard` 与 `published withdraw to submitted`。
- 同步补 Server tests。
- 不实现自动扣罚。
