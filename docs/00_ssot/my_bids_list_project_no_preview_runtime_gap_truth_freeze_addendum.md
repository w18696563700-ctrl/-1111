---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the runtime-gap truth for the `MyBidsList` project number and proposal
  preview fields after the Flutter contract gate exposed a BFF shaping drift.
layer: L0 SSOT
freeze_date_local: 2026-04-29
based_on:
  - docs/00_ssot/my_bids_and_bid_submission_snapshot_truth_freeze_addendum.md
  - docs/00_ssot/my_bids_list_contract_drift_stage_gate_checklist_addendum.md
---

# 《我的竞标列表项目编号与方案预览 Runtime Gap Truth Freeze》

## 1. 结论

`MyBidsList` 当前正式保留 `projectNo` 与 `proposalSummaryPreview`：

- `projectNo` 是项目编号展示字段，真源来自 Server project truth。
- `proposalSummaryPreview` 是竞标方案摘要的列表预览字段，真源来自 Server bid truth。
- BFF 只允许校验透传，不得重算。
- Flutter 继续严校验，不得本地补字段。

## 2. 当前最小闭环

1. Server 根据当前 bidder organization 查询 bid。
2. Server 关联 project，输出 `projectNo / projectTitle`。
3. Server 根据 bid proposal summary 输出 `proposalSummaryPreview`。
4. BFF 透传字段到 `/api/app/my/bids`。
5. Flutter 使用 `projectNo` 展示项目编号，使用 `proposalSummaryPreview` 展示卡片说明。

## 3. 需要保留但暂不开通

- 暂不开通完整竞标工作台。
- 暂不开通 compare board / loser board。
- 暂不开通 award action。
- 暂不开通 post-award detail center。
- 暂不开通从 `我的竞标` 直接展开完整 `BidSubmissionSnapshot`，该入口另行冻结。

## 4. 后续扩展位

- `snapshotReadable` 后续可作为 `我的竞标 -> 竞标摘要` 的受控入口开关。
- `projectNo` 后续可用于订单、合同和资金只读串联，但不能在本轮引入交易状态机。
- `proposalSummaryPreview` 后续可扩为更丰富摘要，但必须由 Server 输出投影。

## 5. 风险裁定

- 当前真实风险不是 Flutter 校验过严，而是 BFF app-facing shape 漏字段。
- 若 Flutter 降级吞错，短期能隐藏报错，长期会污染竞标列表、摘要和审计链。
- 若 BFF 重算 `projectNo` 或摘要，会形成第二真值。

## 6. 策略判断

- 更稳：Server 继续做字段真源，BFF 透传，Flutter 严校验。
- 更省成本：只修 BFF read-model 与测试。
- 更适合当前阶段：先恢复 `我的竞标` 列表显示，不扩入口。
- 风险更大：把本轮扩大到竞标摘要直达、结果工作台或订单转换。
