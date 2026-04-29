---
owner: Codex 总控
status: draft
purpose: >
  Freeze the non-effective bounded implementation dispatch draft for the
  current platform pricing rebaseline so future execution may start only within
  the admitted package order, write scopes, and verification order after a
  later dispatch-send gate passes.
layer: L0 SSOT
freeze_date_local: 2026-04-29
version: V1
inputs_canonical:
  - docs/00_ssot/platform_pricing_implementation_unlock_addendum.md
  - docs/00_ssot/platform_pricing_runtime_drift_register_v1.md
  - docs/00_ssot/platform_pricing_rebaseline_gate_review_conclusion_addendum.md
  - docs/01_contracts/platform_pricing_contracts_master_v1.md
  - docs/02_backend/platform_pricing_backend_truth_master_v1.md
  - docs/03_bff/platform_pricing_bff_surface_master_v1.md
  - docs/04_frontend/platform_pricing_frontend_consumption_master_v1.md
---

# 《平台收费规则 bounded implementation dispatch draft》

## 1. 当前唯一对象

- `平台收费重基线 implementation packages`

## 2. 当前唯一执行范围

- Server：
  - pricing kernel and additive migration normalization
  - `200 publish gate`
  - `4000 bid gate`
  - `deal confirmation / charge / exit governance`
  - bounded `message interaction pricing carry`
- BFF：
  - pricing route family core
  - publish / withdraw-published gate alignment
  - bid participation + bid submit handoff alignment
  - bounded message pricing carry
- Flutter：
  - pricing consumer base cutover
  - publish `200` gate handoff
  - bid `4000` gate handoff
  - read-only pricing summary replacement
- Verification：
  - local build / lint / test evidence
  - dispatch receipts
  - later ali-cloud tunnel smoke after a separate gate

## 3. 明确禁止

- 不得扩到 generic payment center / wallet / billing / settlement / invoice
- 不得把 `membership direct purchase`、`performance deposit`、`credit_constraints`
  混入当前对象
- 不得 revive 旧 `trade-task / inquiry-deposit / 3%` 为现行 authority
- 不得在当前 draft 阶段发送真实实现 prompt
- 不得把当前 draft 写成 runtime acceptance 或 release-ready

## 4. 唯一 admitted execution order

| Order | Package | Owner | Depends On | Allowed Write Scope | Local Acceptance |
|---|---|---|---|---|---|
| `1` | `SP-1 Server Pricing Kernel & Persistence Normalization` | Server | docs chain only | `apps/server/src/modules/p0_pay/**`, `apps/server/src/core/migrations/migrations.ts` | build + targeted tests |
| `2` | `P1 BFF pricing route family core` | BFF | `SP-1` | `apps/bff/src/routes/exhibition_p0_pay/**` | build + route tests |
| `3` | `FP1 Flutter pricing consumer base cutover` | Flutter | `P1` | pricing consumer base files only | analyze + widget/consumer tests |
| `4` | `SP-2 Server Project Publish Gate / 200 Corridor` | Server | `SP-1` | `project-write.service.ts`, bounded `p0_pay` inquiry deposit corridor | build + targeted tests |
| `5` | `P2 BFF publish / withdraw-published gate alignment` | BFF | `SP-2` | bounded `apps/bff/src/routes/project/**` | build + publish gate route tests |
| `6` | `FP2 Flutter publish 200 gate handoff` | Flutter | `P2` | `project_create_page.dart` only | analyze + widget tests |
| `7` | `SP-3 Server 4000 Gate / Bid Corridor` | Server | `SP-1` | bounded `p0_pay`, `bid`, `bid_participation_request` | build + targeted tests |
| `8` | `P3 BFF bid participation + bid submit handoff alignment` | BFF | `SP-3` | bounded `bid_participation_request/**`, `bid/**` | build + route tests |
| `9` | `FP3 Flutter 4000 gate and bid-submit handoff` | Flutter | `P3` | `bid_submit_page.dart` and bounded support files | analyze + widget tests |
| `10` | `SP-4 Server deal / charge / exit governance` | Server | `SP-2`, `SP-3` | bounded `p0_pay` confirmation/charge files, `project-exit-governance.service.ts` | build + targeted tests |
| `11` | `FP4 Flutter read-only pricing summary replacement` | Flutter | `P1`, `SP-4` | bounded `project_detail_page.dart`, summary parser | analyze + widget tests |
| `12` | `SP-5 Server surface / message carry cutover` | Server | `SP-2`, `SP-3`, `SP-4` | bounded `p0_pay.controller.ts`, `message_interaction/**` carry files | build + targeted tests |
| `13` | `P4 BFF message interaction pricing carry` | BFF | `SP-5` | bounded `message_interaction/**` | build + route tests |
| `14` | `Verification Pack` | Result verification | all prior packages | no code writes | receipt review + later tunnel smoke |

## 5. 执行顺序解释

- `Server` 必须先于 `BFF`，因为当前 canonical truth 与错误族都在 `Server`
  侧。
- `BFF` 必须先于 Flutter，因为 Flutter 只允许消费 `BFF /api/app/*`。
- `message interaction pricing carry` 必须最后切，因为它只能承接稳定后的
  pricing truth，不得倒逼 upstream 改写。
- `Verification Pack` 当前只允许编写和冻结验证要求，不允许在本轮宣称云端
  通过。

## 6. 当前 draft 的 formal meaning

- 当前 draft 已冻结：
  - future implementation package order
  - future write scopes
  - future verification order
- 当前 draft 未冻结：
  - real implementation dispatch send
  - runtime acceptance
  - cloud deployment result

## 7. Next Unique Action

- 下一步唯一动作：
  - 以当前 draft 为基础，重提 `implementation dispatch send` 阶段门禁
