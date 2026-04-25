---
owner: Codex 总控
status: frozen
layer: L0 cloud data cleanup receipt
execution_recorded_at_local: 2026-04-25
purpose: Record the confirmed cleanup of P0PAY/E2E/UAT test projects before rerunning dual-account project/order UAT.
---

# Project Transaction Lifecycle Test Project Cleanup Receipt

## 1. Conclusion

The confirmed cloud test-project cleanup is complete.

Deleted scope:

- 30 `P0PAY / E2E / UAT` test projects.
- Directly associated test bids, orders, bid threads, project communication threads, payment test rows, contract / milestone / inspection test rows, and audit rows.

Preserved scope:

- Real organizations and real accounts were not deleted.
- The manual project `EXH-2026-DD93A8 / 西洽会 - 泸州` was preserved.
- A DB backup schema was created before deletion:
  - `cleanup_backup_20260425_test_project_purge`

Final result:

- `public.project` now has exactly 1 row.
- Remaining project is `EXH-2026-DD93A8 / 西洽会 - 泸州`.
- Remaining test-project count is 0.
- Checked associated test rows all returned 0 after cleanup.

## 2. Confirmation Boundary

User confirmed deletion after the candidate list and risk were presented.

Confirmed deletion wording:

`确认`

Operational interpretation:

- delete the 30 `P0PAY/E2E/UAT` test projects and their associated test data;
- preserve `EXH-2026-DD93A8 / 西洽会 - 泸州`;
- do not delete real accounts, real organizations, or certification data.

## 3. Backup Snapshot

Before deletion, a backup schema was created:

| Backup schema | Purpose |
|---|---|
| `cleanup_backup_20260425_test_project_purge` | Snapshot of the 30 candidate test projects and associated rows before deletion. |

Backup guard:

| Check | Result |
|---|---:|
| Candidate project backup count | 30 |
| `EXH-2026-DD93A8` in candidate backup | 0 |

## 4. Deleted Data

The deletion ran in one transaction and committed successfully.

Deleted row counts:

| Table | Deleted |
|---|---:|
| `project` | 30 |
| `bids` | 29 |
| `orders` | 9 |
| `bid_private_threads` | 8 |
| `bid_thread_messages` | 8 |
| `project_communication_threads` | 2 |
| `payment_orders` | 47 |
| `payment_transactions` | 46 |
| `payment_callback_events` | 36 |
| `payment_idempotency_records` | 76 |
| `platform_service_fee_authorizations` | 28 |
| `platform_service_fee_charges` | 6 |
| `contract_confirmations` | 6 |
| `contracts` | 9 |
| `inspections` | 7 |
| `milestones` | 7 |
| `inquiry_quote_deposits` | 8 |
| `audit_logs` | 49 |

Zero-count associated tables were also checked and included in the cleanup transaction, including:

- `project_counterparty_ratings`
- `ratings`
- `disputes`
- `bid_awards`
- `bid_seats`
- `project_communication_messages`
- `project_communication_read_cursors`
- `project_album_photos`
- `project_name_access_requests`
- `project_attachments`
- `project_clarifications`
- `organization_shadow_credit_recompute_triggers`
- `organization_shadow_credit_ledgers`

## 5. Post-Cleanup Verification

Post-cleanup project table:

| Check | Result |
|---|---:|
| Remaining project count | 1 |
| Remaining test-project count | 0 |
| Formal project count for `EXH-2026-DD93A8` | 1 |

Remaining project:

| Field | Value |
|---|---|
| `id` | `c788eaff-6243-4e97-8be3-c4e174ee7944` |
| `project_no` | `EXH-2026-DD93A8` |
| `title` | `西洽会 - 泸州` |
| `exhibition_name` | `西洽会` |
| `brand_name` | `泸州` |
| `state` | `published` |
| `organization_id` | `e6bf4567-016e-45f9-9420-9c950237690e` |

Associated test residual check:

| Associated family | Residual |
|---|---:|
| bids | 0 |
| orders | 0 |
| bid private threads | 0 |
| bid thread messages | 0 |
| project communication threads | 0 |
| payment orders | 0 |
| payment transactions | 0 |
| payment callback events | 0 |
| payment idempotency records | 0 |
| fee authorizations | 0 |
| fee charges | 0 |
| contract confirmations | 0 |
| contracts | 0 |
| inspections | 0 |
| milestones | 0 |
| audit logs | 0 |

## 6. Stage Gate Checklist

| Gate | Result | Notes |
|---|---:|---|
| User confirmed destructive cleanup | Pass | Confirmation received before deletion. |
| Candidate list excluded formal project | Pass | `EXH-2026-DD93A8` candidate count was 0. |
| Backup snapshot created | Pass | `cleanup_backup_20260425_test_project_purge`. |
| Deletion ran in one transaction | Pass | Transaction committed successfully. |
| Formal project preserved | Pass | Exactly one formal project remains. |
| Test residual check | Pass | Direct associated families returned 0. |

## 7. Next Action

The project list is now clean enough to rerun Day31 / Day35-Day36 real dual-account UAT on an actual manually created project.

Required next setup:

- one app window logged in as the project publisher / buyer side;
- one app window logged in as the bidder / supplier side;
- both windows must operate against the same real project, not a deleted P0PAY/UAT fixture.

## 8. Stability / Cost / Stage Fit

- More stable: purge test fixtures first, then rerun UAT on the user-created project.
- More cost-efficient: keep real accounts and organizations, only remove project-scoped test data.
- More suitable for the current stage: preserve a DB backup schema and avoid touching account/certification truth.
- Higher risk: running dual-account UAT while stale P0PAY/UAT projects remain mixed into the message/project list.
