---
owner: Codex 总控
status: frozen
purpose: Freeze the bounded Server-owned truth and read-model boundary for CS-030 my-appeal-history list/detail.
layer: L2 Backend Truth
---

# CS-030 我的申诉记录 P2-A Backend Truth Addendum

## 1. 当前包范围

本文件只冻结 `CS-030` 当前最小 Server truth/read-model 承接：

- current actor 的 appeal history list
- current actor 的 appeal history detail

## 2. 当前真值归属

当前仍沿用既有 truth carrier：

- `governance_appeal_cases`
- `governance_penalties`

本包不新增新的 history truth table。

## 3. 当前 Server canonical route

本包冻结的 Server route 只有：

- `GET /server/profile/governance/appeals`
- `GET /server/profile/governance/appeals/{appealCaseId}`

## 4. 当前 read-model 规则

- list 和 detail 都必须基于 `currentSession.userId`
- `governance_appeal_cases.submitted_by` 是当前 actor 过滤主键
- `penaltyType / penaltyStatus / reasonSummary / effectiveFrom / effectiveUntil` 允许从 `governance_penalties` 派生
- 不允许创建单独的 `appeal_history_summaries` 或类似缓存真相表

## 5. 当前 list 语义

list 只允许：

- page / pageSize / optional status filtering
- `submitted_at DESC` 排序
- current actor 自有记录

## 6. 当前 detail 语义

detail 只允许：

- current actor 自有 `appealCaseId`
- 当前 appeal case 最小明细
- bounded penalty summary join

detail 不允许：

- 直接暴露 audit log
- 直接暴露 admin-only reviewer note 全量原文
- 直接暴露他人处罚对象上下文

## 7. 当前明确不纳入项

- 新增 submit truth
- appeal decision truth 改造
- penalty lifecycle 改造
- permanent-ban appeals
- whitelist lifecycle
- violation score
- historical rescan
- AI / OCR / QR

## 8. 当前审计结论

本包为只读历史回显。

当前不新增新的 must-audit action，继续沿用：

- `GovernanceAppealSubmitted`
- `GovernanceAppealDecided`

作为上游证据来源。

## 9. 当前 Formal Conclusion

`CS-030 P2-A` 的 Server truth/read-model 边界已冻结：

- `Server` 继续是唯一 truth owner
- 只允许在既有治理 truth 上派生 current-actor list/detail
- 不得新增第二 history truth
- 不得越界打开处罚中心或申诉中心
