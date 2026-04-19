---
owner: Codex 总控
status: frozen
purpose: Freeze the bounded BFF app-facing shaping boundary for CS-030 my-appeal-history list/detail.
layer: L3 BFF
---

# CS-030 我的申诉记录 P2-A BFF Surface Addendum

## 1. 当前范围

本文件只冻结：

- `GET /api/app/profile/governance/appeals`
- `GET /api/app/profile/governance/appeals/{appealCaseId}`

## 2. 当前 BFF 角色

`BFF` 只允许：

- 转发 current actor appeal-history list/detail 请求
- 整形 app-facing envelope
- 保留受控 unavailable / auth 错误

`BFF` 不允许：

- 创建或持有 `governance_appeal_cases` 真相
- 创建或持有 `governance_penalties` 真相
- 维护 appeal state machine
- 新增 admin governance shim

## 3. 当前上游依赖

`BFF` 只允许调用：

- `GET /server/profile/governance/appeals`
- `GET /server/profile/governance/appeals/{appealCaseId}`

## 4. 当前 shaping 边界

list app-facing item 只允许整形为：

- `appealCaseId`
- `penaltyId`
- `penaltyType`
- `penaltyStatus`
- `status`
- `reasonSummary`
- `submittedAt`

detail app-facing payload 只允许整形为：

- `appealCaseId`
- `penaltyId`
- `penaltyType`
- `penaltyStatus`
- `status`
- `reason`
- `reasonSummary`
- `submittedAt`
- optional `evidenceFileAssetIds`
- optional `decision`
- optional `decisionNote`
- optional `decidedAt`
- optional `effectiveFrom`
- optional `effectiveUntil`

## 5. 当前明确不纳入项

- app-facing appeal submit
- penalty history center
- governance summary rewrite
- admin appeal list/detail/decide
- whitelist / permanent-ban history
- chat / negotiation surface

## 6. 当前 Formal Conclusion

`CS-030 P2-A` 的 BFF surface 已冻结：

- 只允许 bounded list/detail shaping
- 不得持有第二真相
- 不得误开 admin 或 full governance center
