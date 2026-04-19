---
owner: Codex 总控
status: frozen
purpose: Freeze the bounded app-facing and Server-side contract family for CS-030 my-appeal-history list/detail without reopening a full governance center.
layer: L2 Contracts
---

# CS-030 我的申诉记录 P2-A Contracts Addendum

## 1. 范围

本文件只冻结 `CS-030` 当前最小 contract：

- `GET /api/app/profile/governance/appeals`
- `GET /api/app/profile/governance/appeals/{appealCaseId}`

以及对应的 Server canonical route family：

- `GET /server/profile/governance/appeals`
- `GET /server/profile/governance/appeals/{appealCaseId}`

## 2. 当前包角色

- `Server` 是唯一 truth owner
- `BFF` 只做 app-facing shaping
- `Flutter` 只消费当前 actor 的最小申诉记录 list/detail

## 3. 当前 list contract

`GET /api/app/profile/governance/appeals`

当前最小 query 只允许：

- `page`
- `pageSize`
- `status`（可选）

最小响应必须包含：

- `items`
- `pagination`

单个 list item 至少包含：

- `appealCaseId`
- `penaltyId`
- `penaltyType`
- `penaltyStatus`
- `status`
- `reasonSummary`
- `submittedAt`

## 4. 当前 detail contract

`GET /api/app/profile/governance/appeals/{appealCaseId}`

最小 detail 响应至少包含：

- `appealCaseId`
- `penaltyId`
- `penaltyType`
- `penaltyStatus`
- `status`
- `reason`
- `reasonSummary`
- `submittedAt`

可选最小字段：

- `evidenceFileAssetIds`
- `decision`
- `decisionNote`
- `decidedAt`
- `effectiveFrom`
- `effectiveUntil`

## 5. 当前 actor 边界

- 只允许返回 `submittedBy = currentSession.userId` 的 appeal case
- 不允许通过手输 id 查看他人 appeal detail
- detail 不可见时必须返回受控 unavailable，而不是空成功

## 6. 当前明确不纳入项

- user-side appeal submit 新 contract
- user-side penalty history list/detail
- user-side whitelist / permanent-ban history
- appeal chat / negotiation
- multi-round appeal workflow
- admin appeal list/detail/decide 变更

## 7. 与既有治理 contract 的关系

本文件是对：

- `blacklist_whitelist_and_permanent_ban_rules_v1_contracts_addendum.md`

的 bounded 增量补充。

此前“no user-side appeal history center”的非目标在当前 `CS-030 P2-A` 边界内被有界打开，但仅限：

- current actor
- appeal list/detail
- read-only

## 8. 错误族

本包继续只允许使用既有治理错误族，不新增新命名空间：

- `GOVERNANCE_APPEAL_RESOURCE_UNAVAILABLE`
- `AUTH_SESSION_INVALID`

## 9. Formal Conclusion

当前 `CS-030 P2-A` contract 已冻结。

该冻结只允许后续进入 bounded implementation prompt authoring，不等于 implementation 已放开。
