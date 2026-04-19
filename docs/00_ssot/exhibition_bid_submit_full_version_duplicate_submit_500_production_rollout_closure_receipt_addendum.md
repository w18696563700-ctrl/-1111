---
owner: Codex 总控
status: frozen
purpose: >
  Record the bounded production rollout and closure evidence for the
  exhibition bid-submit duplicate-submit residual fix only, freezing the
  exact server release switch, migration registration, and production
  app-facing A/B smoke results without expanding scope into a broader
  production release.
layer: L0 SSOT
freeze_date_local: 2026-04-15
based_on:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/exhibition_bid_submit_full_version_duplicate_submit_500_residual_defect_sheet_addendum.md
  - docs/00_ssot/exhibition_bid_submit_full_version_duplicate_submit_500_residual_fix_closure_receipt_addendum.md
  - docs/00_ssot/exhibition_bid_submit_full_version_duplicate_submit_500_production_release_gate_checklist_addendum.md
  - docs/02_backend/exhibition_bid_submit_full_version_backend_truth_addendum.md
  - docs/03_bff/exhibition_bid_submit_full_version_bff_surface_addendum.md
---

# 《竞标提交页满分版重复提交 500 production rollout 收口回执》

## 1. Current Object

- defect id:
  - `EXH-BID-FULL-RESIDUAL-001`
- current scope:
  - `apps/server/**` bounded production rollout
  - production app-facing duplicate-submit smoke
- current no-go:
  - `apps/mobile/**`
  - production `apps/bff/**` rebuild
  - whole-repo production release

## 2. Production Rollout Execution

- verified host:
  - `47.108.180.198`
- bounded rollout path:
  - previous server current:
    - `/srv/releases/server/20260414235030`
  - target server release:
    - `/srv/releases/server/20260415114930`
  - active server current after rollout:
    - `/srv/releases/server/20260415114930`
- production BFF remained unchanged:
  - `/srv/releases/bff/20260414235030/apps/bff`
  - current BFF runtime already carried:
    - `409 -> BID_DUPLICATE_SUBMISSION`
    - `当前项目已提交过投标，请勿重复提交。`
- current service and health evidence:
  - `exhibition-server = active`
  - `ActiveEnterTimestamp = Wed 2026-04-15 12:09:38 CST`
  - `GET http://127.0.0.1:3001/health/live -> 200`

## 3. Migration And Runtime Evidence

- production migration registration:
  - `server_schema_migration.migration_key = 20260415_bid_duplicate_submission_controlled_repair`
  - count:
    - `1`
- rollout-time journal evidence:
  - `applied migration 20260415_bid_duplicate_submission_controlled_repair`
  - `migration reconciliation complete; appliedThisBoot=20260415_bid_duplicate_submission_controlled_repair`
- post-rollout journal guard:
  - `journalctl -u exhibition-server --since '2026-04-15 12:09:38'`
  - no `23505`
  - no `bids_bid_no_key`

## 4. Production App-Facing Smoke

- execution entry:
  - `http://127.0.0.1:80 -> nginx -> exhibition-bff:3000 -> exhibition-server:3001`
- smoke target selection rule frozen for this round:
  - app-facing smoke target must come from active `project` truth
  - legacy `projects` sample rows are not treated as app-facing bid-submit targets in this receipt
- current smoke project:
  - `project_id = 97779e2d-50a0-4038-a0d8-1ee3b4d9d122`
  - `project_no = EXH-2026-8AC90B`
  - `state = published`
  - pre-smoke bid count:
    - `1`
- current smoke supplier identity chain:
  - `organization_id = 890856dc-56b7-476d-a73d-26962bb869e8`
  - `user_id = f7ec58d8-dc1d-4411-b654-414506ccfdb1`
  - `session_id = fae95582-0f3d-4489-bfff-199148e5a6c4`

### 4.1 Scenario A

- first app-facing submit:
  - `POST /api/app/bid/submit -> 202 Accepted`
  - `bidId = 1c13d7bb-6c97-4fd7-bb0e-303950a2a7b6`
- new bid row evidence:
  - `bid_no = BID-EXH-2026-8AC90B-1C13D7BB6C97`
  - `quote_amount = 3888.00`
  - `bidder_organization_id = 890856dc-56b7-476d-a73d-26962bb869e8`

### 4.2 Scenario B

- same supplier + same project second submit:
  - `POST /api/app/bid/submit -> 409 Conflict`
  - `code = BID_DUPLICATE_SUBMISSION`
  - message:
    - `当前项目已提交过投标，请勿重复提交。`

### 4.3 Project-Level Coexistence Evidence

- project bid count after smoke:
  - `2`
- current project bid rows:
  - existing row:
    - `BID-EXH-2026-8AC90B | 5564ecfa-0ef2-4545-a15c-bf1b66458d2a | 308440a8-7881-48a6-bc1b-821a108581e4`
  - new row:
    - `BID-EXH-2026-8AC90B-1C13D7BB6C97 | 890856dc-56b7-476d-a73d-26962bb869e8 | 1c13d7bb-6c97-4fd7-bb0e-303950a2a7b6`
- current meaning:
  - production now proves second supplier same-project coexistence
  - production now proves same supplier duplicate submit is controlled at `409`, not leaked as `500`

## 5. Scope Boundary

- this receipt covers only:
  - duplicate-submit residual fix rollout
  - migration registration
  - production app-facing bid-submit A/B smoke
- this receipt does not newly certify:
  - production upload corridor revalidation
  - production mobile release
  - broader exhibition write-chain closure

## 6. Formal Conclusion

- `EXH-BID-FULL-RESIDUAL-001` 当前正式结论固定为：
  - `production rollout completed`
  - `production duplicate-submit residual defect closed`
- current authoritative proof now covers:
  - bounded server-only production rollout
  - production migration registration
  - production same-project multi-supplier coexistence
  - production same-supplier duplicate rejection at `409/BID_DUPLICATE_SUBMISSION`
- if work continues after this receipt, the only valid next stage is:
  - a separately raised production gate for any broader bid-submit corridor revalidation
