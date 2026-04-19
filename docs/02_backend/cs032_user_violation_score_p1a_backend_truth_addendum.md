---
owner: Codex 总控
status: frozen
purpose: Freeze the bounded Server-owned truth and derivation boundary for CS-032 user violation score.
layer: L2 Backend Truth
---

# CS-032 用户违规累计分 P1-A Backend Truth Addendum

## 1. 当前包范围

本文件只冻结 `CS-032` 当前最小 Server truth/read-model 承接：

- current actor governance summary 中的 `violationScoreSnapshot`
- current actor governance summary 中的 `violationScoreUpdatedAt`

## 2. 当前真值归属

当前仍沿用既有 truth carrier：

- `governance_penalties`
- `governance_appeal_cases`

`Server` 继续是唯一 score truth owner。

本包不新增新的 score truth table。

## 3. 当前 derivation 规则

当前 violation score 只允许由 `Server` 基于已生效处罚记录派生。

当前最小权重表冻结为：

- `warning` = `1`
- `watchlist` = `2`
- `restrict_publish` = `3`
- `restrict_bid` = `3`
- `blacklist` = `5`

当前最小派生规则固定为：

- 只统计已进入 `effective_from <= now` 的处罚记录
- 只统计当前 subject set 上的治理处罚记录
- `active / lifted / expired` 均视为已生效记录，允许纳入累计分
- 已被申诉裁决撤销或改写失效的处罚，不得继续贡献原始分值

## 4. 当前 read-model 规则

- `GET /api/app/profile/governance/status` 仍是 derived read model
- `violationScoreSnapshot` 只是当前治理摘要上的补充字段
- 不允许创建单独的 `violation_score_snapshots` 或类似 summary truth table
- `violationScoreUpdatedAt` 必须由当前 score snapshot 的最近一次有效派生时点给出

## 5. 当前 bounded truth 语义

- 当前 score 只反映治理处罚记录累计分
- 当前 score 不是 identity truth
- 当前 score 不是 permission truth
- 当前 score 不是 BFF truth
- 当前 score 不是自动处罚触发器

## 6. 当前明确不纳入项

- 自动处罚 truth
- penalty history center truth
- appeal center 扩写 truth
- whitelist / permanent-ban history truth
- 存量复扫 truth
- AI 审核统一接入 truth
- `CS-019`
- `CS-033`
- `CS-034`

## 7. 当前审计结论

本包只冻结派生 truth/read-model 边界。

当前不新增 must-audit action，继续沿用既有：

- `GovernancePenaltyApplied`
- `GovernanceAppealDecided`

作为 score derivation 的上游证据来源。

## 8. 当前 Formal Conclusion

`CS-032 P1-A` 的 Server truth/read-model 边界已冻结：

- `Server` 继续是唯一 truth owner
- 只允许在既有治理 truth 上派生 bounded score snapshot
- 不得新增第二 score truth
- 不得越界打开自动处罚、处罚历史中心、申诉中心扩写或更大治理中心
