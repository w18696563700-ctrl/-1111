---
owner: Codex 总控
status: frozen
purpose: Freeze the BFF app-facing surface for the Logo-only shell/application decoupling round.
layer: L2.5 BFF
freeze_date_local: 2026-04-17
inputs_canonical:
  - docs/01_contracts/enterprise_display_trust_repair_round11_logo_only_contract_freeze_addendum.md
  - docs/00_ssot/enterprise_display_trust_repair_round9_logo_only_contract_truth_ruling_addendum.md
  - apps/bff/src/routes/enterprise_hub/enterprise-hub.service.ts
---

# Enterprise Display Trust Repair Round 11 Logo-only BFF Surface Scope

## 1. Surface Objective

- 为 app 侧显式提供一条 `ensure-shell` route。
- 保持 `createApplication` 的语义只指向 application draft。

## 2. New Surface

- 当前 round-11 `BFF` 必须新增：
  - `POST /api/app/exhibition/enterprise-hub/enterprises/ensure-shell`
- request normalize 只允许：
  - `boardType`
- response shape 只允许：
  - `enterpriseId`
  - `boardType`
  - `shellStatus`

## 3. Existing Surface Narrowing

- 当前 `createApplication()` 继续存在，但：
  - normalize payload 仍要求 `applicantName / applicantMobile`
  - 错误文案与 transport code 继续按 `application draft` 语义输出
- `ensure-shell` 不得复用：
  - “申请信息不完整，请补齐申请人姓名、联系电话和申请板块后再试”

## 4. Error Surface

- 当前 round-11 `BFF` 新增受控 error code family：
  - `ENTERPRISE_HUB_ENTERPRISE_SHELL_UNAVAILABLE`
- 当前允许映射：
  - `400 -> ENTERPRISE_HUB_INVALID_BOARD_TYPE`
  - `401 -> AUTH_SESSION_INVALID`
  - `403 -> ENTERPRISE_HUB_PERMISSION_DENIED`
  - `503 -> ENTERPRISE_HUB_ENTERPRISE_SHELL_UNAVAILABLE`
- 当前不允许：
  - 把 shell fail 继续压到 `ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS`
  - 把 shell fail 文案写成联系人缺失

## 5. Allowed Write Set

- 当前 round-11 `BFF` 优先允许：
  - `apps/bff/src/routes/enterprise_hub/app-enterprise-hub.controller.ts`
  - `apps/bff/src/routes/enterprise_hub/enterprise-hub.controller.ts`
  - `apps/bff/src/routes/enterprise_hub/enterprise-hub.service.ts`
- 若需要独立 read-model / dto，允许新增：
  - `apps/bff/src/routes/enterprise_hub/*shell*.ts`

## 6. Anti-revert

- 不得继续让 app 侧通过 `createApplication` 偷拿 `enterpriseId`。
- 不得把新 route 做成第二套 business state machine。
- 不得让 `BFF` 自行决定联系人何时变成强制项。

## 7. Formal Conclusion

- round-11 `BFF` surface 已冻结为：
  - `new ensure-shell transport`
  - `existing createApplication semantic narrowing`
- `BFF` 只承接 transport and shaping，不承接新的业务状态机。
