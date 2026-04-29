---
title: project_exit_and_breach_governance_phase1_contracts_addendum
owner: Codex 总控
status: frozen
layer: L2 Contracts
updated_at: 2026-04-29
purpose: Freeze app-facing and server-facing contracts for project exit and breach governance phase 1 before implementation.
inputs_canonical:
  - docs/00_ssot/project_exit_and_breach_governance_phase1_rule_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
  - packages/contracts/src/generated/app-api.types.ts
  - packages/contracts/src/generated/error-codes.ts
---

# 项目退出与违约治理第一期 L2 Contracts 冻结单

## 0. 总裁决

- 当前是否修改 `openapi.yaml`：`No，本轮只冻结 addendum`
- 当前是否允许进入 L3 Server truth：`Go`
- 当前是否允许 Flutter 先行实现：`No-Go`
- 当前 contract 原则：新增动作必须由 Server 产出最终状态；BFF 与 Flutter 不得传入或伪造状态结果。

## 1. 现有 Contract 复核

| 现有接口 | 当前语义 | 本期处理 |
|---|---|---|
| `DELETE /api/app/my/projects/{projectId}` | draft-only delete | 不扩大为预发布/竞标中/进行中删除 |
| `POST /api/app/project/withdraw` | `submitted -> draft` | 保持，不复用为竞标中撤回 |
| `POST /api/app/project/archive` | `submitted -> archived` | 可作为预发布作废删除的 Server 真相 |
| `POST /api/app/project/close` | `published -> archived` | 保留为下架关闭，不作为撤回到预发布 |

## 2. 新增 App-facing Routes

### 2.1 竞标中撤回到预发布

```yaml
POST /api/app/project/withdraw-published
```

用途：

- 只承接 `published -> submitted`。
- 用户可见为“撤回到预发布”。
- 同步下架公域展示。

Request:

```ts
type ProjectWithdrawPublishedRequest = {
  projectId: string;
  reasonCode: 'content_needs_revision' | 'schedule_changed' | 'budget_changed' | 'published_by_mistake' | 'other';
  reasonText?: string;
  publicDelistConfirmed: true;
  bidHistoryRetainedConfirmed: true;
  authorizationReleaseAwarenessConfirmed: true;
  idempotencyKey: string;
};
```

Accepted response:

```ts
type ProjectWithdrawPublishedAcceptedResponse = {
  projectId: string;
  previousState: 'published';
  state: 'submitted';
  action: 'withdraw_published_to_submitted';
  affectedBidCount: number;
  affectedAuthorizationCount: number;
  exitCaseId?: string | null;
};
```

### 2.2 预发布作废删除

```yaml
POST /api/app/project/discard-submitted
```

用途：

- 用户可见可叫“删除预发布项目”或“作废删除”。
- Server 真相固定为 `submitted -> archived`。
- 不复用 draft hard delete。

Request:

```ts
type ProjectDiscardSubmittedRequest = {
  projectId: string;
  reasonCode: 'no_longer_needed' | 'duplicate_project' | 'published_by_mistake' | 'other';
  reasonText?: string;
  archiveInsteadOfHardDeleteConfirmed: true;
  idempotencyKey: string;
};
```

Accepted response:

```ts
type ProjectDiscardSubmittedAcceptedResponse = {
  projectId: string;
  previousState: 'submitted';
  state: 'archived';
  action: 'discard_submitted';
  exitCaseId?: string | null;
};
```

### 2.3 进行中发起取消

```yaml
POST /api/app/project/cancellation/request
```

Request:

```ts
type ProjectCancellationRequest = {
  projectId: string;
  orderId?: string | null;
  contractId?: string | null;
  reasonCode: 'mutual_change' | 'publisher_reason' | 'factory_reason' | 'force_majeure' | 'other';
  reasonText?: string;
  noAutomaticPenaltyConfirmed: true;
  idempotencyKey: string;
};
```

Accepted response:

```ts
type ProjectCancellationRequestedResponse = {
  projectId: string;
  exitCaseId: string;
  projectState: 'awarded' | 'converted_to_order' | string;
  caseStatus: 'requested';
  action: 'request_cancellation';
  initiatedByOrganizationId: string;
  counterpartyOrganizationId: string;
};
```

### 2.4 进行中取消响应

```yaml
POST /api/app/project/cancellation/respond
```

Request:

```ts
type ProjectCancellationResponseRequest = {
  projectId: string;
  exitCaseId: string;
  decision: 'accept' | 'reject';
  reasonText?: string;
  noAutomaticPenaltyConfirmed: true;
  idempotencyKey: string;
};
```

Accepted response:

```ts
type ProjectCancellationRespondedResponse = {
  projectId: string;
  exitCaseId: string;
  projectState: 'awarded' | 'converted_to_order' | 'archived' | string;
  caseStatus: 'accepted' | 'rejected';
  action: 'accept_cancellation' | 'reject_cancellation';
};
```

### 2.5 记录发布方违约

```yaml
POST /api/app/project/breach/record-publisher
```

Request:

```ts
type ProjectPublisherBreachRecordRequest = {
  projectId: string;
  orderId?: string | null;
  contractId?: string | null;
  reasonCode: 'publisher_cancelled' | 'publisher_unreachable' | 'publisher_changed_scope' | 'other';
  reasonText?: string;
  noAutomaticPenaltyConfirmed: true;
  idempotencyKey: string;
};
```

Accepted response:

```ts
type ProjectBreachRecordedResponse = {
  projectId: string;
  exitCaseId: string;
  projectState: 'awarded' | 'converted_to_order' | string;
  caseStatus: 'recorded';
  breachParty: 'publisher' | 'factory';
  action: 'record_publisher_breach' | 'record_factory_breach';
  creditImpactCandidate: true;
};
```

### 2.6 记录工厂违约

```yaml
POST /api/app/project/breach/record-factory
```

Request:

```ts
type ProjectFactoryBreachRecordRequest = {
  projectId: string;
  orderId?: string | null;
  contractId?: string | null;
  reasonCode: 'factory_refused_signing' | 'factory_refused_fulfillment' | 'factory_unreachable' | 'other';
  reasonText?: string;
  noAutomaticPenaltyConfirmed: true;
  idempotencyKey: string;
};
```

Response:

- 复用 `ProjectBreachRecordedResponse`。

## 3. Server-facing Routes

| App-facing | Server-facing | BFF 职责 |
|---|---|---|
| `POST /api/app/project/withdraw-published` | `POST /server/projects/withdraw-published` | 转发 + 错误整形 |
| `POST /api/app/project/discard-submitted` | `POST /server/projects/discard-submitted` | 转发 + 错误整形 |
| `POST /api/app/project/cancellation/request` | `POST /server/projects/cancellation/request` | 转发 + 错误整形 |
| `POST /api/app/project/cancellation/respond` | `POST /server/projects/cancellation/respond` | 转发 + 错误整形 |
| `POST /api/app/project/breach/record-publisher` | `POST /server/projects/breach/record-publisher` | 转发 + 错误整形 |
| `POST /api/app/project/breach/record-factory` | `POST /server/projects/breach/record-factory` | 转发 + 错误整形 |

## 4. Error Codes

新增候选错误码：

| code | 语义 |
|---|---|
| `PROJECT_WITHDRAW_PUBLISHED_INVALID` | 竞标中撤回请求缺字段或确认项不完整 |
| `PROJECT_SUBMITTED_DISCARD_INVALID` | 预发布作废删除请求缺字段或确认项不完整 |
| `PROJECT_CANCELLATION_REQUEST_INVALID` | 取消申请缺字段或确认项不完整 |
| `PROJECT_CANCELLATION_RESPONSE_INVALID` | 取消响应缺字段或状态不匹配 |
| `PROJECT_BREACH_RECORD_INVALID` | 违约记录请求缺字段或责任方不合法 |
| `PROJECT_EXIT_INVALID_STATE` | 当前项目状态不允许本动作 |
| `PROJECT_EXIT_RESOURCE_UNAVAILABLE` | 项目、订单、合同或退出 case 不可用 |

错误码原则：

- 状态不允许优先返回 `409 / PROJECT_EXIT_INVALID_STATE`。
- 缺字段优先返回 `400 / 对应 INVALID`。
- 鉴权不通过沿用 `AUTH_SESSION_INVALID / AUTH_PERMISSION_INSUFFICIENT`。

## 5. Field Ownership

| 字段 | Owner |
|---|---|
| `projectId` | request input，Server 校验归属 |
| `previousState` | Server |
| `state` | Server |
| `projectState` | Server |
| `caseStatus` | Server |
| `affectedBidCount` | Server |
| `affectedAuthorizationCount` | Server |
| `exitCaseId` | Server |
| `creditImpactCandidate` | Server |
| `noAutomaticPenaltyConfirmed` | Flutter 收集，Server 校验 |
| `idempotencyKey` | Flutter 生成，Server 幂等持有 |

## 6. 不进入 Contract 的内容

- 不新增 fee penalty 字段。
- 不新增 automatic charge 字段。
- 不新增 guarantee/deposit deduction 字段。
- 不新增 arbitration verdict 字段。
- 不新增 admin decision 字段。
- 不让 Flutter 传入目标状态。

## 7. 验收标准

| 验收项 | 标准 |
|---|---|
| 竞标中撤回 | 明确 `published -> submitted`，不复用旧 `withdraw` |
| 预发布作废 | 明确 `submitted -> archived`，不扩大 hard delete |
| 进行中取消 | 必须 request/respond 双步 |
| 违约记录 | 只记录，不扣钱 |
| BFF | 只转发，不计算 |
| Flutter | 只提交原因与确认，不提交状态结果 |

## 8. 下一步唯一动作

进入 L3 Server truth 与 persistence 冻结：

- 冻结状态机。
- 冻结是否新增 `project_exit_cases`。
- 冻结 audit、idempotency、旧数据兼容。
- 冻结 P0-Pay release/hold fail-closed 边界。
