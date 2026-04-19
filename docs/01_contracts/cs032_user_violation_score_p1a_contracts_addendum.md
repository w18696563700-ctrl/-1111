---
owner: Codex 总控
status: frozen
purpose: Freeze the bounded app-facing contract supplement for CS-032 user violation score under the existing governance-status summary family.
layer: L2 Contracts
---

# CS-032 用户违规累计分 P1-A Contracts Addendum

## 1. 范围

本文件只冻结 `CS-032` 当前最小 contract 补充：

- `GET /api/app/profile/governance/status`

本文件不新增新的独立 score route。

## 2. 当前包角色

- `Server` 是唯一 violation score truth owner
- `BFF` 只做现有 governance-status shaping
- `Flutter` 只消费当前 actor 的最小 score snapshot

## 3. 当前 contract 补充字段

`GET /api/app/profile/governance/status`

在既有响应基础上，当前最小新增字段只允许：

- `violationScoreSnapshot`
- `violationScoreUpdatedAt`

字段语义固定为：

- `violationScoreSnapshot`: 基于已生效治理处罚记录派生出的当前最小累计分快照
- `violationScoreUpdatedAt`: 当前累计分快照的最近一次派生时间

## 4. 当前读取边界

- 当前 contract 只允许 current actor 读取自己的治理累计分摘要
- 当前 contract 不得要求客户端访问任何 score history
- 当前 contract 不得引入新的 query 参数
- 当前 contract 不得引入新的 user-side write action

## 5. 当前派生边界

- score snapshot 只允许来自已生效 `governance_penalties`
- score snapshot 必须受既有 appeal 决定后的最终有效处罚结果约束
- whitelist / permanent-ban 不在当前 score contract 中单独成为 score source

## 6. 当前明确不纳入项

- 自动处罚 contract
- penalty history center contract
- appeal center 扩写 contract
- whitelist / permanent-ban history contract
- 存量复扫 contract
- AI 审核统一接入 contract
- `CS-019`
- `CS-033`
- `CS-034`
- release-prep / launch approval

## 7. 与既有治理 contract 的关系

本文件是对：

- `blacklist_whitelist_and_permanent_ban_rules_v1_contracts_addendum.md`

的 bounded 增量补充。

此前“no full trust score”的非目标继续保留；当前只冻结：

- bounded score snapshot
- bounded updated-at field
- existing governance-status summary family

## 8. 错误族

本包继续只允许使用既有治理错误族，不新增 score 专属命名空间：

- `GOVERNANCE_STATUS_UNAVAILABLE`
- `AUTH_SESSION_INVALID`

## 9. Formal Conclusion

当前 `CS-032 P1-A` contract 已冻结。

该冻结只允许后续进入 bounded implementation-unlock judgment authoring，不等于 implementation 已放开。
