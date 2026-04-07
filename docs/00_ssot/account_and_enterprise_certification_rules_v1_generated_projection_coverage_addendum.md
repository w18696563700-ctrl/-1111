---
owner: Codex 总控
status: draft
purpose: Clarify the generated projection coverage boundary for Package 1 L2 contracts freeze so app-only outputs are not misread as missing admin contracts.
layer: L0 SSOT
---

# 《账户与企业认证规则 V1》第一包 Generated Projection Coverage 说明单

## 1. Scope
- This addendum applies only to:
  - `账户与企业认证规则 V1`
  - Package 1
  - current `L2 contracts freeze` closure and review
- This addendum is for:
  - generated projection coverage clarification
  - review evidence interpretation
  - truth-versus-projection boundary clarification
- This addendum is not:
  - implementation unlock
  - release-prep unlock
  - release approval

## 2. Upstream Basis
- Current interpretation is aligned to:
  - [source_of_truth_map.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/source_of_truth_map.md)
  - [codegen_policy.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/codegen_policy.md)
  - [account_and_enterprise_certification_rules_v1_truth_closure_review_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/account_and_enterprise_certification_rules_v1_truth_closure_review_addendum.md)
  - [openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)
  - [error_codes.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/error_codes.yaml)
  - [README.md](/Users/wangweiwei/Desktop/展览装修之家总控/packages/contracts/README.md)
  - [contracts_generation_lib.rb](/Users/wangweiwei/Desktop/展览装修之家总控/packages/contracts/scripts/contracts_generation_lib.rb)

## 3. Formal Rule
- Formal contract truth for this package still starts in:
  - `docs/01_contracts/openapi.yaml`
  - `docs/01_contracts/error_codes.yaml`
- `packages/contracts/**` remains:
  - derived projection only
  - not primary truth
  - not a place for contract invention

## 4. Projection Coverage Clarification
- Current generated outputs do not carry the same coverage responsibility:
  - `packages/contracts/openapi/openapi.bundle.json`
    - is the bundled projection of the full `openapi.yaml`
    - carries both current app-facing and admin-facing path families when they exist in `openapi.yaml`
  - `packages/contracts/src/generated/app-api.types.ts`
    - is an app-facing path projection only
    - intentionally contains only paths under `/api/app/*`
    - does not carry `/server/admin/*` by design
  - `packages/contracts/src/generated/error-codes.ts`
    - is the shared error-code projection of `error_codes.yaml`
  - `packages/contracts/src/generated/index.ts`
    - is a barrel export only
- Current generator rule is explicit:
  - `contracts_generation_lib.rb` builds `APP_API_PATHS` by selecting only `openapi.paths` keys that start with `/api/app/`

## 5. Review Interpretation Rule
- Therefore:
  - absence of `/server/admin/*` in `app-api.types.ts` is not by itself a contract omission
  - admin route completeness must be checked against:
    - `docs/01_contracts/openapi.yaml`
    - `packages/contracts/openapi/openapi.bundle.json`
  - app-facing route completeness may be checked against:
    - `docs/01_contracts/openapi.yaml`
    - `packages/contracts/openapi/openapi.bundle.json`
    - `packages/contracts/src/generated/app-api.types.ts`
- Reviewers must not assume one generated file covers all route families.

## 6. Current Stage Meaning
- Current meaning remains:
  - `Go for docs-only L2 contracts freeze`
  - `No-Go for implementation / release`
- This addendum does not allow:
  - backend implementation
  - bff implementation
  - frontend implementation
  - admin implementation
  - release-prep
  - release execution

## 7. Current Conclusion
- For Package 1, the generated projection coverage question is now fixed as an interpretation rule:
  - full route-family review anchors to `openapi.yaml` plus `openapi.bundle.json`
  - app-only route-family review may additionally anchor to `app-api.types.ts`
- This conclusion only clarifies projection coverage.
- It does not convert `L2 contracts freeze` into implementation approval.
