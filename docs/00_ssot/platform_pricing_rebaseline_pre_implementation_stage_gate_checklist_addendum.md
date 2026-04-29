---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the pre-implementation stage gate checklist for the 2026-04-29
  platform pricing rebaseline, deciding only whether the work may proceed past
  cross-layer docs freeze into implementation-dispatch authoring while direct
  implementation, cloud write, integration, and release remain blocked.
layer: L0 SSOT
freeze_date_local: 2026-04-29
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/platform_pricing_rules_master_v1.md
  - docs/00_ssot/platform_pricing_rebaseline_impact_register_v1.md
  - docs/00_ssot/platform_pricing_implementation_unlock_assessment_addendum.md
  - docs/00_ssot/platform_pricing_runtime_drift_register_v1.md
  - docs/01_contracts/platform_pricing_contracts_master_v1.md
  - docs/01_contracts/platform_pricing_contracts_companion_patch_v1.md
  - docs/02_backend/platform_pricing_backend_truth_master_v1.md
  - docs/02_backend/platform_pricing_persistence_migration_truth_addendum_v1.md
  - docs/02_backend/platform_pricing_audit_truth_addendum_v1.md
  - docs/03_bff/platform_pricing_bff_surface_master_v1.md
  - docs/04_frontend/platform_pricing_frontend_consumption_master_v1.md
  - apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart
  - apps/mobile/lib/features/exhibition/data/services/p0_pay_consumer_service.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart
  - apps/bff/src/routes/exhibition_p0_pay/app-exhibition-p0-pay.controller.ts
  - apps/bff/src/routes/exhibition_p0_pay/exhibition-p0-pay.service.ts
  - apps/server/src/modules/p0_pay/p0-pay-service-fee.factory.ts
  - apps/server/src/modules/p0_pay/p0-pay-service-fee-rate.policy.ts
  - apps/server/src/modules/p0_pay/p0-pay-contract-confirmation.service.ts
---

# 《平台收费重基线实现前阶段门禁核查表》

## 1. Scope

- 当前对象只限：
  - `2026-04-29 平台收费重基线`
  - `pre-implementation stage gate checklist`
- 本核查表只回答：
  - 当前是否允许从 `L0-L5` 文书冻结进入下一轮 companion-truth completion
  - 当前是否允许直接进入实现派工
- 本核查表明确不是：
  - direct implementation approval
  - cloud write approval
  - integration pass
  - release-prep pass
  - production release pass

## 2. passed gates

- 当前本地单一真源 gate：
  - passed
  - 当前收费唯一母文件与 `L2/L3/L4/L5` 主文书均已落在本地 `docs/`。
- 当前跨层文书链完整性 gate：
  - passed
  - 当前已形成 `L0 -> L2 -> L3 -> L4 -> L5` 的完整重基线文书链。
- 当前 supersede / override 链 gate：
  - passed
  - 旧 `P0-Pay / trade-task / payment MVP / membership purchase` 相关主锚已补 `superseded` 或 override note。
- 当前架构边界 gate：
  - passed
  - 新文书仍保持 `Flutter -> BFF -> Server` 单主通道，没有把 `BFF` 或 Flutter 升成收费真相 owner。
- 当前 no-second-truth gate：
  - passed
  - 当前新主线没有把 `profile/payment-and-billing`、`membership`、`credit/deposit` 或旧 `p0_pay` 读态写成第二真相根。
- 当前 app-facing contract yaml gate：
  - passed
  - `docs/01_contracts/openapi.yaml` 与 `docs/01_contracts/error_codes.yaml` 已通过 companion patch 补齐当前新收费主线 routes、schema 与错误族。
- 当前 backend persistence / migration / audit truth gate：
  - passed
  - 当前已冻结 persistence / migration / audit companion truth，并把旧 `p0_pay` 物理复用边界与 legacy-only 列写死。
- 当前 implementation unlock assessment gate：
  - passed with boundary
  - 当前已完成 implementation unlock assessment，但只允许导向 `implementation dispatch bundle authoring`，不导向 direct implementation。
- 当前 runtime drift inventory gate：
  - passed
  - 当前已形成三端 runtime drift register，并明确了 `must-change blocker / later cleanup / retain`。

## 3. failed gates

- 当前 direct implementation unlock gate：
  - failed
  - `AGENTS.md` 的 Phase 0 guardrail 仍未对当前 bounded pricing implementation 单独开闸。
- 当前 runtime cutover completion gate：
  - failed
  - `apps/mobile`、`apps/bff`、`apps/server` 虽已形成 drift register，但旧 `trade-task / inquiry deposit / 3% / p0-pay-summary` runtime 仍未切除。
- 当前 runtime verification gate：
  - failed
  - 当前没有任何基于新收费主线的云端验证结论。
- 当前 integration / release gate：
  - failed
  - 当前没有 deploy、integration、release-prep、production-release 结论。

## 4. veto gates

- root guardrail veto：
  - `AGENTS.md` 仍明确：
    - bounded trading exception retained non-goals includes `payment / billing / settlement`
- direct-code runtime-gap veto：
  - 不得在 `apps/mobile / apps/bff / apps/server` 仍以旧收费主线运行为默认实现时，把文书冻结误判为可直接编码
- cloud-validation veto：
  - 不得在没有任何新收费主线 deploy / verification 结论时放行 direct implementation 后继阶段

## 5. stage go / no-go decision

- 当前结论：
  - `Go` for implementation dispatch bundle authoring only
  - `No-Go` for direct implementation
  - `No-Go` for cloud write / integration / release
- 当前允许进入的阶段只限：
  - implementation dispatch bundle authoring
  - bounded pricing implementation unlock addendum authoring
  - docs-only verification supplements
- 当前不允许进入的阶段只限：
  - mobile implementation
  - BFF implementation
  - server implementation
  - deploy / restart / rollback
  - tunnel-based runtime verification
  - integration / release-prep / production release

## 6. Current Meaning

- 这份门禁核查表的唯一含义是：
  - 当前收费重基线已经完成 docs freeze 与 companion-truth completion，并取得了进入 `implementation dispatch bundle authoring` 的资格
- 它不意味着：
  - 当前代码可以直接开改
  - 当前云端可以直接切新收费主线
  - 当前 `project_create_page / p0_pay_consumer_service / exhibition_p0_pay.controller / p0-pay-service-fee.factory` 的旧实现已经失效

## 7. Next Action

- 当前唯一下一步固定为：
  - 编写 `implementation dispatch bundle`
  - 补一份 bounded pricing implementation unlock addendum
  - 之后再重提 direct implementation Go / No-Go
- 在 direct implementation 重新放行前：
  - 持续保持 `No-Go for direct implementation`
