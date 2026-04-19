---
owner: Codex 总控
status: frozen
purpose: Freeze the app-facing contract changes needed to decouple Logo-only shell acquisition from application draft creation.
layer: L1 Contracts
freeze_date_local: 2026-04-17
inputs_canonical:
  - docs/00_ssot/enterprise_display_trust_repair_round9_logo_only_contract_truth_ruling_addendum.md
  - docs/01_contracts/enterprise_hub_v1_fields_states_api_contract_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/bff/src/routes/enterprise_hub/enterprise-hub.service.ts
---

# Enterprise Display Trust Repair Round 11 Logo-only Contract Freeze

## 1. Contract Objective

- 把 `Logo-only` 与基础资料首次维护所需的 `enterprise shell acquisition` 从 `createApplication` 中分离。
- 保持 submit-chain 既有 `application` 语义不被稀释。

## 2. New App-facing Route

### POST `/api/app/exhibition/enterprise-hub/enterprises/ensure-shell`

Request:
- `boardType`

Response:
- `enterpriseId`
- `boardType`
- `shellStatus`
  - `created`
  - `existing`

Error codes:
- `AUTH_SESSION_INVALID`
- `ENTERPRISE_HUB_INVALID_BOARD_TYPE`
- `ENTERPRISE_HUB_PERMISSION_DENIED`
- `ENTERPRISE_HUB_ENTERPRISE_SHELL_UNAVAILABLE`

## 3. Existing Route Semantic Narrowing

### POST `/api/app/exhibition/enterprise-hub/applications`

当前 contract 继续保留：
- `applyBoardType`
- `applicantName`
- `applicantMobile`

但其正式语义改写为：
- `create or refresh application draft under an existing or ensure-able listing shell`
- 不再承担 `Logo-only` / `basic save` 的首次 shell acquisition 入口

Response 保持：
- `applicationId`
- `enterpriseId`
- `applicationStatus`

## 4. No Contract Change In This Round

以下 route 本轮不改 path，不改字段：
- `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/basic`
- `POST /api/app/exhibition/enterprise-hub/applications/{applicationId}/submit`
- 现有 case/profile 路由

## 5. Contract Rule

- `ensure-shell` 不得要求：
  - `applicantName`
  - `applicantMobile`
  - `contactName`
  - `contactMobile`
- `createApplication` 仍然要求：
  - `applicantName`
  - `applicantMobile`
- `submit` 仍然必须在受控阶段校验：
  - contact minimum
  - profile minimum
  - case minimum
  - certification minimum

## 6. Anti-revert

- 不得继续让 `Logo-only` 走 `POST /applications`。
- 不得把 `ensure-shell` 做成 application alias。
- 不得把 `applicantName / applicantMobile` 从 `application` contract 中口头废止但实现未改。

## 7. Formal Conclusion

- 当前 app-facing contract 正式增加一条：
  - `ensure-shell`
- 当前 `createApplication` contract 正式收窄为：
  - `application draft route`
  - 不再兼任 `shell-acquisition route`
