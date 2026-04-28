---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Flutter consumption stance for the repaired `GET /api/app/my/bids`
  project number and proposal preview fields.
layer: L5 Frontend
freeze_date_local: 2026-04-29
based_on:
  - docs/01_contracts/my_bids_list_project_no_preview_contract_refinement_addendum.md
  - docs/03_bff/my_bids_list_project_no_preview_bff_surface_refinement_addendum.md
---

# 《我的竞标列表 projectNo / proposalSummaryPreview Frontend Consumption Note》

## 1. 结论

Flutter 当前严校验保持不变：

- `projectNo` 必填，用于 `项目编号`。
- `proposalSummaryPreview` 必填，用于竞标卡片说明。
- Flutter 不本地生成项目编号。
- Flutter 不从完整方案说明中截断摘要。
- Flutter 不为云上 BFF 漏字段降级显示 `未提供`。

## 2. Current Minimum Loop

1. `MyProjectListPage` 切到 `我的竞标`。
2. Flutter 调用 `ExhibitionConsumerLayer.loadMyBidList()`。
3. contract validation 通过后渲染列表。
4. 卡片使用：
   - `projectTitle` 作为标题
   - `proposalSummaryPreview` 作为说明
   - `projectNo` 作为项目编号
   - `quoteAmount` 作为报价金额

## 3. Frontend No-Go

- 不把 `projectNo` 改成选填。
- 不吞掉 contract drift。
- 不新增竞标摘要 CTA。
- 不新增 compare / award / order 工作台。
- 不 direct-to-Server。

## 4. Acceptance

- BFF 字段完整时，Flutter 列表正常显示。
- BFF 缺字段时，Flutter 继续显示受控 contract drift，而不是假成功。
- 本轮 Flutter 只做回归验证，不改 UI 结构。

## 5. Strategy Judgment

- 更稳：保持 Flutter contract gate。
- 更省成本：无需改 Flutter。
- 更适合当前阶段：把漂移修在 BFF。
- 风险更大：前端降级导致接口漂移继续进入生产。
