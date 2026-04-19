---
owner: Codex 总控
status: active
purpose: Freeze the bounded integration-verification dispatch bundle for enterprise-display three-board independence so the current round executes runtime evidence collection and targeted regression against the live tunnel while authoring, but not executing, the legacy compatibility-removal plan.
layer: L0 SSOT
freeze_date_local: 2026-04-19
inputs_canonical:
  - docs/00_ssot/enterprise_display_three_board_independence_integration_verification_stage_gate_checklist_addendum.md
  - docs/00_ssot/enterprise_display_three_board_independence_bff_execution_receipt_addendum.md
  - docs/00_ssot/enterprise_display_three_board_independence_flutter_execution_receipt_addendum.md
  - docs/01_contracts/enterprise_display_three_board_independence_bff_board_family_contract_concretization_addendum.md
  - docs/04_frontend/enterprise_display_three_board_independence_frontend_surface_addendum.md
---

# 《enterprise display three-board independence integration verification dispatch bundle》

## A. 当前轮唯一目标

- 当前轮唯一目标固定为：
  - 用 tunnel 对当前云上 runtime 做 bounded integration evidence collection
  - 明确 private canonical family 与 shared compatibility bridge 的真实上线状态
  - 对 enterprise-display three-board private chain 做 targeted regression
  - 形成 legacy compatibility removal plan

## B. 当前轮明确非目标

- 不做 `apps/server/**`、`apps/bff/**`、`apps/mobile/**` 代码改动
- 不做 deploy / restart / rollback
- 不做 compatibility bridge deletion
- 不做 release-prep / production release
- 不做 broad route-family redesign

## C. 当前轮 canonical inputs

- `docs/00_ssot/enterprise_display_three_board_independence_integration_verification_stage_gate_checklist_addendum.md`
- `docs/01_contracts/enterprise_display_three_board_independence_bff_board_family_contract_concretization_addendum.md`
- `docs/04_frontend/enterprise_display_three_board_independence_frontend_surface_addendum.md`
- `apps/bff/src/routes/enterprise_hub/enterprise-hub-board-scoped.controller.ts`
- `apps/bff/src/routes/enterprise_hub/enterprise-hub.controller.ts`
- `apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart`
- `apps/mobile/lib/features/exhibition/data/enterprise_hub_consumer_layer.dart`
- `apps/mobile/lib/features/exhibition/data/enterprise_hub_workbench_consumer_layer.dart`
- `apps/mobile/lib/features/exhibition/data/enterprise_hub_published_change_consumer_layer.dart`

## D. 当前轮 allowed write set

- `docs/00_ssot/**`
- 当前轮不允许写：
  - `apps/server/**`
  - `apps/bff/**`
  - `apps/mobile/**`
  - deploy / restart / rollback / release artifacts

## E. 当前轮 package split

### E1. Package A | authenticated integration verification

- owner：
  - `Codex 总控`
- unique goal：
  - 用 tunnel 验证 live BFF health、auth entry、private canonical family、shared compatibility bridge 的实时行为
- execution mode：
  - runtime read-only evidence collection
- must do：
  - 记录 health 结果
  - 记录 auth 尝试结果
  - 记录 canonical family 是否 route-visible
  - 记录 shared bridge 是否仍可兜底
- must not do：
  - 假造 token
  - 把 fake actor header 误读成 authenticated pass
  - 做任何写入性业务 mutation

### E2. Package B | targeted regression

- owner：
  - `Codex 总控`
- unique goal：
  - 在当前云上兼容桥仍存活的条件下，验证 public list、public detail、shared recommendations、shared bridge transport 行为没有被三板块独立化意外打断
- execution mode：
  - runtime read-only regression
- must do：
  - 验证 shared list
  - 验证 shared detail
  - 验证 shared recommendations
  - 验证 old shared private carrier 至少不是 route-level 404
- must not do：
  - 把旧 bridge 的继续可用误读成新 family 已部署

### E3. Package C | legacy compatibility removal plan authoring

- owner：
  - `Codex 总控`
- unique goal：
  - 冻结当前 legacy surface inventory、保留条件、删除顺序与最早 removal gate
- execution mode：
  - docs-only
- must do：
  - 明确哪些桥本轮必须保留
  - 明确先删 Flutter 还是先删 BFF
  - 明确 removal preconditions
- must not do：
  - 直接执行 bridge deletion

## F. Concrete integration and regression freeze

- 当前轮 live canonical family 观测对象固定为：
  - `/api/app/exhibition/enterprise-hub/company/**`
  - `/api/app/exhibition/enterprise-hub/factory/**`
  - `/api/app/exhibition/enterprise-hub/supplier/**`
- 当前轮 shared bridge regression 观测对象固定为：
  - `/api/app/exhibition/enterprise-hub/workbench?boardType=...`
  - `/api/app/exhibition/enterprise-hub/enterprises?boardType=...`
  - `/api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}?boardType=...`
  - `/api/app/exhibition/enterprise-hub/recommendations?boardType=...`
- 当前轮 private route freeze 固定为：
  - `/exhibition/company-display/workbench`
  - `/exhibition/factory-display/workbench`
  - `/exhibition/supplier-display/workbench`
  - `/exhibition/company-display/cases/editor`
  - `/exhibition/factory-display/cases/editor`
  - `/exhibition/supplier-display/cases/editor`
  - `/exhibition/company-display/status`
  - `/exhibition/factory-display/status`
  - `/exhibition/supplier-display/status`

## G. 执行顺序

1. 先收 integration gate 与 runtime 路径盘点回执。
2. 先验证 tunnel 与 BFF health。
3. 再尝试 auth entry。
4. 再对 canonical family 做 route-level smoke。
5. 再对 shared compatibility bridge 做 targeted regression。
6. 输出 integration execution receipt。
7. 单独输出 legacy compatibility removal plan。

## H. 当前轮验收标准

- 已有实时证据说明 tunnel 和 BFF live health 正常。
- 已有实时证据说明 shared compatibility bridge 当前仍可返回有效业务响应。
- 已有实时证据说明云上 canonical board-scoped family 当前仍未 route-visible，或相反已 route-visible；不能停留在猜测。
- 已对 authenticated positive-session 是否存在给出明确结论。
- 已形成 standalone legacy compatibility removal plan。

