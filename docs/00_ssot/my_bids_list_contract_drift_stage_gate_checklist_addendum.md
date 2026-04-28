---
owner: Codex 总控
status: frozen
purpose: >
  Record the Day-1 stage-gate finding for the `GET /api/app/my/bids`
  contract drift that blocks the Flutter `我的竞标` list.
layer: Stage Gate
freeze_date_local: 2026-04-29
based_on:
  - docs/00_ssot/my_bids_and_bid_submission_snapshot_truth_freeze_addendum.md
  - docs/01_contracts/my_bids_and_bid_submission_snapshot_contract_freeze_addendum.md
  - docs/03_bff/messages_interaction_center_and_bidder_carry_bff_surface_freeze_addendum.md
---

# 《我的竞标列表 Contract Drift 第 1 天阶段门禁核查表》

## 1. 当前最小闭环

本轮只修复 `我的项目 -> 我的竞标` 中 `GET /api/app/my/bids` 的字段漂移：

1. Server 读取当前 bidder 的 bid truth。
2. Server 输出 `MyBidsList` read projection。
3. BFF 校验并透传 app-facing list item。
4. Flutter 严格校验后渲染 `我的竞标` 列表。

本轮不新增业务入口、不重做竞标工作台、不改 bid 状态机。

## 2. 字段差异表

| 字段 | 旧 contract | Server 本地输出 | BFF 当前输出 | Flutter 当前要求 | 第 1 天裁定 |
| --- | --- | --- | --- | --- | --- |
| `bidId` | 必填 | 有 | 有 | 必填 | 保持 |
| `projectId` | 必填 | 有 | 有 | 必填 | 保持 |
| `projectNo` | 未列明 | 有 | 漏透传 | 必填 | 补成 app-facing 必填字段 |
| `projectTitle` | 必填 | 有 | 有 | 必填 | 保持 |
| `quoteAmount` | 必填 | 有 | 有 | 必填 | 保持 |
| `proposalSummaryPreview` | 未列明 | 有 | 漏透传 | 必填 | 补成 app-facing 必填字段 |
| `submittedAt` | 必填 | 有 | 有 | 必填 | 保持 |
| `outcomeState` | 必填 | 有 | 有 | 必填 | 保持 |
| `canOpenBidThread` | 必填 | 有 | 有 | 必填 | 保持 |
| `canOpenBidResult` | 必填 | 有 | 有 | 必填 | 保持 |
| `snapshotReadable` | 必填 | 有 | 有 | 暂未消费 | 保持为 BFF 必填透传字段 |

## 3. 缺口定位

- `apps/server/src/modules/my_bid/my-bid.query.service.ts` 当前已组装：
  - `projectNo`
  - `proposalSummaryPreview`
  - `snapshotReadable`
- `apps/server/src/modules/my_bid/my-bid.presenter.ts` 当前 list item 类型已包含上述字段。
- `apps/bff/src/routes/my_bid/my-bid.read-model.ts` 当前只校验透传旧字段，漏掉：
  - `projectNo`
  - `proposalSummaryPreview`
- `apps/mobile/lib/features/exhibition/data/services/my_bid_contract_validation.dart` 当前要求：
  - `projectNo`
  - `proposalSummaryPreview`
- `apps/mobile/lib/features/exhibition/presentation/presentation_support/my_bid_workspace_support.dart` 当前实际展示：
  - `项目编号 = projectNo`
  - `description = proposalSummaryPreview`

## 4. Passed Gates

- 已确认本轮不需要新增接口路径。
- 已确认 Server 本地代码已经具备字段真源。
- 已确认 Flutter 严校验不是误判；它在保护列表 contract。
- 已确认 BFF 是最小修复点。

## 5. Failed Gates

- 旧 L2 contract 与 L4 BFF surface 未列明 `projectNo / proposalSummaryPreview`。
- BFF read-model 与 Flutter consumption 不一致。

## 6. Veto Gates

- 不允许 Flutter 本地补 `projectNo` 或把字段改成选填来绕过漂移。
- 不允许 BFF 重算项目编号或方案摘要。
- 不允许把 `我的竞标` 列表扩成 compare / award / post-award 工作台。

## 7. 是否允许进入下一天

允许进入第 2 天。

进入条件：

- 只允许补 SSOT / contract / BFF surface / frontend consumption 文书。
- 第 2 天不得改代码。
- 第 3 天只允许改 BFF read-model 和对应 BFF 测试。

## 8. 策略判断

- 更稳：补正式字段冻结后修 BFF 透传。
- 更省成本：只改 BFF read-model，不动 Server。
- 更适合当前阶段：保持 Flutter contract gate，修 BFF 漏透传。
- 风险更大：前端降级吞错，导致云上 Server/BFF 漂移长期隐藏。
