---
owner: Codex 总控
status: frozen
purpose: Freeze the legacy compatibility-removal plan for enterprise-display three-board independence after local BFF and Flutter cutovers completed but before cloud board-scoped family exposure and authenticated positive smoke are closed.
layer: L0 SSOT
freeze_date_local: 2026-04-19
inputs_canonical:
  - docs/00_ssot/enterprise_display_three_board_independence_bff_execution_receipt_addendum.md
  - docs/00_ssot/enterprise_display_three_board_independence_flutter_execution_receipt_addendum.md
  - docs/00_ssot/enterprise_display_three_board_independence_integration_verification_execution_receipt_addendum.md
  - docs/01_contracts/enterprise_display_three_board_independence_bff_board_family_contract_concretization_addendum.md
  - docs/04_frontend/enterprise_display_three_board_independence_frontend_surface_addendum.md
---

# 《enterprise display three-board independence legacy compatibility removal plan》

## 1. Scope

- 本计划只覆盖：
  - enterprise-display three-board private chain 的 legacy compatibility surfaces
  - Flutter old shared route aliases
  - BFF old shared app-facing family
- 本计划不覆盖：
  - `public-cases/{caseId}`
  - shared `cases/{caseId}` carrier
  - `formal-info`
  - `location/resolve`
  - deploy / release

## 2. Current Legacy Surface Inventory

- Flutter legacy route aliases：
  - `/exhibition/enterprise/apply?boardType=company|factory|supplier`
  - `/exhibition/enterprise/cases/editor?...`
  - `/exhibition/enterprise/application-status?...`
- BFF shared compatibility family：
  - `GET /api/app/exhibition/enterprise-hub/workbench?boardType=...`
  - `GET /api/app/exhibition/enterprise-hub/enterprises?boardType=...`
  - `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}?boardType=...`
  - `GET /api/app/exhibition/enterprise-hub/recommendations?boardType=...`
  - `POST /api/app/exhibition/enterprise-hub/enterprises/ensure-shell`
  - `POST /api/app/exhibition/enterprise-hub/applications`

## 3. Compatibility Bridges To Keep For Now

- 当前必须保留 Flutter legacy route aliases。
- 当前必须保留 BFF shared compatibility family。
- 保留原因固定为：
  - 当前轮没有 authenticated positive smoke 证明新 family 已可承接正式私有流量
  - 当前轮还没有 company / factory / supplier 三板块 private canonical chain 的真实登录态回执

## 4. Proposed Removal Order

1. 先用有效 access token 跑一轮 authenticated smoke，要求 company / factory / supplier 三板块至少覆盖：
   - workbench
   - recommendations
   - enterprises list
   - enterprise detail
   - published-change status probe
2. 再确认 mobile 私有主线路径已完全命中新 family，没有 hidden fallback 仍依赖 shared bridge。
3. 先开 `Flutter legacy route bridge removal gate`，删除 old shared UI route aliases。
4. 跑一轮 app-side regression，确认 deep link、status、case editor 没有回退。
5. 再开 `BFF shared compatibility bridge removal gate`，删除 board-sensitive shared private family。
6. 再跑一轮 authenticated smoke 与 targeted regression。
7. 对仍然允许 shared 的 carriers 单独保留或另开后续 gate，不与当前 three-board private chain 强行捆绑。

## 5. Removal Preconditions

- 至少存在一组有效登录态，能拿到 positive `Authorization: Bearer <accessToken>` smoke 证据。
- company / factory / supplier 三板块各自完成至少一轮 positive private chain smoke。
- shared compatibility bridge 已从 canonical path 降级为真正 unused 或只剩明确白名单 consumer。
- 已有独立 removal gate、独立 rollback judgment、独立 execution receipt。

## 6. Earliest Removal Gate

- 最早 removal 时点不是当前轮。
- 最早只能在：
  - authenticated positive smoke 已通过
  - 新 family 已完成至少一轮 regression
  之后，再单独开 `legacy bridge removal gate`。

## 7. Explicit No-Go This Round

- 本轮 `No-Go for Flutter legacy route alias deletion`
- 本轮 `No-Go for BFF shared compatibility bridge deletion`
- 本轮 `No-Go for deploy / restart / rollback`
- 本轮 `No-Go for release-prep`
- 本轮 `No-Go for production release`

## 8. Formal Conclusion

- 当前 compatibility-removal plan 已形成。
- 当前 plan 的结论不是“现在可以删桥”。
- 当前 plan 的 formal meaning 只有：
  - bridge deletion sequence 已冻结
  - bridge deletion preconditions 已冻结
  - 本轮 bridge deletion 明确 blocked
