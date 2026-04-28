---
owner: Codex 总控
status: frozen
purpose: >
  Refine the BFF shaping rule for `GET /api/app/my/bids` so project number and
  proposal preview are validated and preserved from Server.
layer: L4 BFF
freeze_date_local: 2026-04-29
based_on:
  - docs/01_contracts/my_bids_list_project_no_preview_contract_refinement_addendum.md
  - docs/03_bff/messages_interaction_center_and_bidder_carry_bff_surface_freeze_addendum.md
---

# 《我的竞标列表 projectNo / proposalSummaryPreview BFF Surface Refinement》

## 1. 结论

BFF `GET /api/app/my/bids` 必须继续只做 app-facing shaping：

- 从 Server `/server/my/bids` 读取 list。
- 校验并透传 `projectNo`。
- 校验并透传 `proposalSummaryPreview`。
- 保持 `snapshotReadable` 必填。
- 不重算项目编号。
- 不重算方案摘要。

## 2. Allowed Output Fields

`items[]` 当前只允许：

- `bidId`
- `projectId`
- `projectNo`
- `projectTitle`
- `quoteAmount`
- `proposalSummaryPreview`
- `submittedAt`
- `outcomeState`
- `canOpenBidThread`
- `canOpenBidResult`
- `snapshotReadable`

## 3. BFF No-Go

- 不新增 BFF persistence。
- 不新增 route。
- 不改错误族。
- 不把 upstream 缺字段伪装成成功空列表。
- 不在 BFF 拼接 `projectNo`。
- 不在 BFF 从 `proposalSummary` 截断生成 `proposalSummaryPreview`。

## 4. Acceptance

- upstream 缺 `projectNo` 时，BFF read-model 必须失败。
- upstream 缺 `proposalSummaryPreview` 时，BFF read-model 必须失败。
- upstream 字段完整时，BFF 响应必须保留字段。
- unknown extra fields must still be trimmed.

## 5. Strategy Judgment

- 更稳：BFF 严格校验并透传 Server projection。
- 更省成本：只改 read-model 与测试。
- 更适合当前阶段：恢复 Flutter `我的竞标` 列表，不扩展业务。
- 风险更大：BFF 容错补值，导致 Server 真值缺口被隐藏。
