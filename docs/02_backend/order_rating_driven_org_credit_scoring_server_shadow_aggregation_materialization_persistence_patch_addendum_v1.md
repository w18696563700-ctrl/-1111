---
owner: Codex 总控
status: frozen
purpose: Patch the backend-only shadow aggregation materialization and persistence freeze for `订单评价驱动的组织信用评分主线` so the frozen L3 truth matches the currently admitted Server-only shadow aggregation implementation shape without widening any unlock scope.
layer: L3 Backend
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/02_backend/order_rating_driven_org_credit_scoring_server_shadow_aggregation_materialization_persistence_freeze_addendum_v1.md
  - docs/00_ssot/order_rating_driven_org_credit_scoring_current_v21_non_pollution_verification_addendum_v1.md
  - docs/00_ssot/order_rating_driven_org_credit_scoring_backend_only_implementation_unlock_addendum_v1.md
  - docs/00_ssot/source_of_truth_map.md
---

# 订单评价驱动的组织信用评分主线 Server Shadow Aggregation Materialization / Persistence Patch Addendum V1

## 1. Formal Positioning

- This addendum is a narrow backend truth patch only.
- This addendum does not create a new mainline stage.
- This addendum does not widen any unlock boundary.
- This addendum exists only because the current backend-only implementation shape has already proven narrower-risk and more executable than the earlier cursor-only aggregate wording.

## 2. Patch Scope

- This patch supersedes only:
  - the aggregate carrier boundary wording in the prior materialization / persistence freeze
  - the current-round mandatory reason-code minimum wording in the same freeze
- All other boundaries remain unchanged:
  - no current app-facing route family change
  - no `current V2.1` truth rewrite
  - no contract unlock
  - no `BFF` unlock
  - no frontend unlock
  - no integration
  - no release-prep

## 3. Aggregate Carrier Boundary Patch

- In the current backend-only round, `organization_shadow_credit_aggregates` is formally admitted as a snapshot-bearing shadow aggregate carrier rather than a cursor-only register.
- The current backend-only aggregate carrier may hold:
  - `organization_id`
  - `aggregation_mode`
  - `sample_status`
  - `rated_completed_order_count`
  - `very_satisfied_count`
  - `satisfied_count`
  - `passable_count`
  - `negative_count`
  - `positive_rate`
  - `negative_rate`
  - `recent_consecutive_negative_count`
  - `last20_rated_negative_rate`
  - `base_score`
  - `raw_score`
  - `effective_score`
  - `public_score`
  - `tier_code`
  - `risk_posture`
  - `tier_reason_codes`
  - `posture_reason_codes`
  - `reason_summary`
  - `version`
  - `last_rated_order_id`
  - `last_rated_at`
  - `updated_at`
- This carrier still remains:
  - Server-internal only
  - shadow-only by meaning
  - non-authoritative for current `V2.1`
  - forbidden from becoming a current app-facing read model

## 4. Cursor Boundary Reinterpretation

- The earlier cursor-oriented wording is now reinterpreted as a reserve direction, not as the only admissible backend-only shape.
- `last_completed_order_cursor` and `last_formal_rating_event_cursor` remain:
  - valid future reserve fields
  - optional later evolution points
  - not mandatory for backend-only pass in the current round
- `version` plus `last_rated_order_id` and `last_rated_at` are sufficient for the current backend-only replay-safe shadow snapshot discipline.

## 5. Reason-code Family Patch

- In the current backend-only round, the mandatory minimum reason-code family is patched from abstract normalization buckets to the concrete executable shadow codes already used by the admitted implementation.
- The current mandatory minimum code set is:
  - `SAMPLE_INSUFFICIENT`
  - `RATING_SCORE_60_69`
  - `RATING_SCORE_70_79`
  - `RATING_SCORE_80_89`
  - `RATING_SCORE_90_100`
  - `POSITIVE_RATE_BELOW_80`
  - `NEGATIVE_RATE_AT_LEAST_20`
  - `CONSECUTIVE_NEGATIVE_2`
  - `CONSECUTIVE_NEGATIVE_3`
  - `LAST20_NEGATIVE_RATE_AT_LEAST_30`
  - `RATING_ONLY_MODE_ACTIVE`
- The earlier broader families:
  - legitimacy acceptance
  - legitimacy rejection
  - rating admission
  - rating rejection
  - anti-abuse hold
  - manual review hold
  - recompute source reason
  remain future reserve normalization categories and are not required for backend-only pass in the current round.

## 6. Ledger And Trigger Boundary Remains Unchanged

- `organization_shadow_credit_ledgers` remains append-only by meaning.
- `organization_shadow_credit_recompute_triggers` remains internal Server-side control truth only.
- Neither carrier may become:
  - current route truth
  - `BFF` truth
  - Flutter truth
  - current `V2.1` posture truth

## 7. Non-pollution Boundary Remains Unchanged

- This patch does not admit any read path from current `credit_constraints` carriers into shadow aggregation.
- This patch does not admit any read path from shadow aggregation into:
  - `GET /api/app/profile/credit-and-constraints/status`
  - `GET /api/app/profile/credit-and-constraints/explanation`
  - `GET /api/app/profile/credit-and-constraints/handoff`
- This patch does not admit any change to `packages/contracts/**`, `apps/bff/**`, or `apps/mobile/**`.

## 8. Formal Conclusion

- The current backend-only implementation shape is now formally absorbed into L3 backend truth.
- The aggregate carrier is authoritatively recognized as a snapshot-bearing shadow aggregate for the current round.
- The current mandatory reason-code minimum is authoritatively recognized as the concrete shadow scoring / posture / source code family listed above.
- Backend-only result verification must use this patch together with the prior freeze.
- Current round remains:
  - `Go` for backend-only result verification rerun
  - `No-Go` for contract unlock
  - `No-Go` for `BFF` unlock
  - `No-Go` for frontend unlock
  - `No-Go` for integration
  - `No-Go` for release-prep
