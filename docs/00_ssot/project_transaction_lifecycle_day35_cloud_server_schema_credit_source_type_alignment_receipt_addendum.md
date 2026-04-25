---
owner: Codex 总控
status: frozen
layer: L0 cloud release / schema alignment receipt
scheduled_day: 2026-06-04
execution_recorded_at_local: 2026-04-25
purpose: Record the Aliyun Server/schema alignment for Day32-Day34 counterparty rating credit source typing.
---

# Project Transaction Lifecycle Day35 Cloud Server Schema Credit Source Type Alignment Receipt

## 1. Conclusion

Cloud Server/schema alignment for Day32-Day34 is complete at the route/schema gate.

This receipt records:

- Aliyun Server current was switched from `/srv/releases/server/20260425161006-p0-pay-day20-message-carry` to `/srv/releases/server/20260425185954-day32-day34-credit-source-type-align`.
- Only a white-listed Server patch was released: `project_counterparty_rating`, `credit_scoring_shadow`, `rating.write`, and `core/migrations`.
- Cloud DB now has `source_type varchar(64) NOT NULL DEFAULT 'order_rating'` on both credit shadow trigger and ledger tables.
- Cloud DB now has source indexes on `(source_type, source_rating_id)`.
- `server_schema_migration` now contains `20260602_credit_shadow_source_type_truth`.
- Server route `GET /server/project-counterparty-rating/entry` is reachable and auth-gated.
- BFF / Nginx app route `GET /api/app/project-counterparty-rating/entry` is reachable through port `80` and local tunnel `8080`, returning controlled `401 AUTH_SESSION_INVALID`.

This receipt does not claim:

- a real completed-order dual-account rating submit has been executed;
- a new `project_counterparty_ratings` row has been written in production data;
- a real credit recompute trigger / ledger row has been produced from a submitted counterparty rating;
- production acceptance is complete.

## 2. Release Scope

| Item | Value |
|---|---|
| Previous Server current | `/srv/releases/server/20260425161006-p0-pay-day20-message-carry` |
| New Server current | `/srv/releases/server/20260425185954-day32-day34-credit-source-type-align` |
| Server service | `exhibition-server.service` |
| Final Server state | `active` |
| Final Server PID | `1066053` |
| Final Server cwd | `/srv/releases/server/20260425185954-day32-day34-credit-source-type-align` |
| BFF service | `exhibition-bff.service` |
| Final BFF state | `active` |
| Final BFF cwd | `/srv/releases/bff/20260425154325-day29-bff-runtime-routes/apps/bff` |

White-listed release payload:

- `dist/src project_counterparty_rating`
- `dist/src credit_scoring_shadow` source-type bridge files
- `dist/src rating.write.service`
- `dist/src core/migrations`

No full Server tree overwrite was performed.

## 3. Migration Gate

Before release, cloud ledger comparison showed:

| Check | Result |
|---|---:|
| New release migration key count | `48` |
| Cloud applied key count before patch | `57` |
| Missing key from new release | `20260602_credit_shadow_source_type_truth` only |

The first service start attempted to apply that single migration through the application DB user, but failed with:

`must be owner of table organization_shadow_credit_recompute_triggers`

Resolution:

- stopped `exhibition-server.service`;
- applied the exact minimal schema change through PostgreSQL owner/superuser;
- inserted `20260602_credit_shadow_source_type_truth` into `server_schema_migration`;
- restarted `exhibition-server.service`.

Final Server bootstrap then logged:

- `server_schema_migration snapshot count=58`
- `20260602_credit_shadow_source_type_truth` present
- `migration reconciliation complete; appliedThisBoot=none`
- `Nest application successfully started`

## 4. Schema Gate

Cloud DB final schema:

| Table | Column | Type | Default | Nullable |
|---|---|---|---|---:|
| `organization_shadow_credit_ledgers` | `source_type` | `varchar(64)` | `'order_rating'` | No |
| `organization_shadow_credit_recompute_triggers` | `source_type` | `varchar(64)` | `'order_rating'` | No |

Cloud DB final indexes:

| Index | Definition |
|---|---|
| `idx_org_shadow_credit_ledgers_source` | `ON organization_shadow_credit_ledgers (source_type, source_rating_id)` |
| `idx_org_shadow_credit_triggers_source` | `ON organization_shadow_credit_recompute_triggers (source_type, source_rating_id)` |

Migration ledger:

| Migration key | Result |
|---|---:|
| `20260602_credit_shadow_source_type_truth` | Present |

## 5. Runtime Code Fingerprint

Cloud running release contains:

| Code proof | Result |
|---|---:|
| `dist/core/migrations/migrations.js` contains `20260602_credit_shadow_source_type_truth` | Pass |
| `dist/core/migrations/migrations.js` contains credit `source_type varchar(64)` migration | Pass |
| `credit-scoring-shadow.bootstrap.service.js` creates `source_type varchar(64)` for fresh installs | Pass |
| `project-counterparty-rating.service.js` submits credit bridge with `sourceType: 'project_counterparty_rating'` | Pass |

Meaning:

- old order rating remains `sourceType = order_rating`;
- new mutual counterparty rating is traceable as `sourceType = project_counterparty_rating`;
- both source families share the existing credit shadow trigger / ledger infrastructure.

## 6. Route Probe

Unauthenticated probes are expected to return controlled `401`, not business data.

| Probe | Result | Meaning |
|---|---|---|
| `GET http://127.0.0.1:3001/server/project-counterparty-rating/entry?...` | `401 AUTH_SESSION_INVALID` | Server route reachable and auth-gated. |
| `GET http://127.0.0.1/api/app/project-counterparty-rating/entry?...` on cloud Nginx | `401 AUTH_SESSION_INVALID` | BFF / Nginx app route reachable. |
| `GET http://127.0.0.1:8080/api/app/project-counterparty-rating/entry?...` through local tunnel | `401 AUTH_SESSION_INVALID` | Local tunnel reaches cloud BFF route. |

During verification, `exhibition-bff.service` was found inactive and Nginx returned `502`. The BFF service was started and returned to `active`; the final app-facing route probe returned controlled `401`.

## 7. Stage Gate Checklist

| Gate | Passed | Failed | Veto | Next Stage |
|---|---:|---:|---:|---|
| Cloud Server release contains Day32-Day34 source-type code | Yes | No | No | Allowed. |
| Cloud credit shadow schema contains `source_type` | Yes | No | No | Allowed. |
| Cloud migration ledger contains `20260602_credit_shadow_source_type_truth` | Yes | No | No | Allowed. |
| App tunnel route is reachable and auth-gated | Yes | No | No | Allowed. |
| Completed-order dual-account rating submit | No | Yes | No | Blocks production acceptance only. |
| Real credit trigger / ledger proof from rating submit | No | Yes | No | Blocks production acceptance only. |

Next stage is allowed only for dual-account UAT and DB proof, not for declaring production acceptance.

## 8. Current Minimum Loop

Minimum loop completed:

1. build local Server package;
2. create Aliyun Server release from current;
3. overlay only white-listed Day32-Day34 Server files;
4. align credit `source_type` schema;
5. switch Server current;
6. restart Server and BFF;
7. verify DB columns, indexes, migration ledger, route probes, and tunnel reachability.

## 9. Retained But Not Opened

Retained:

- legacy `/api/app/rating/*`;
- existing credit shadow trigger / ledger tables;
- existing BFF route shape;
- rollback target `/srv/releases/server/20260425161006-p0-pay-day20-message-carry`.

Not opened:

- direct DB mutation to create completed orders;
- direct DB mutation to create ratings;
- internal actor-hint write tests;
- production acceptance claim without real dual-account UI execution.

## 10. Expansion Slots

Next allowed execution package:

1. find or create a real completed order through the app flow;
2. submit `ProjectCounterpartyRating` from both real accounts;
3. verify `project_counterparty_ratings.source` anchors by `orderId / projectId / rater / ratee`;
4. verify credit recompute trigger with `source_type = project_counterparty_rating`;
5. verify credit ledger row with `source_type = project_counterparty_rating`;
6. record a full Day35-Day36 dual-account UAT receipt.

## 11. Stability / Cost / Stage Fit

- More stable: white-listed Server release plus schema ledger alignment, not a full dirty tree deploy.
- More cost-efficient: reuse current credit shadow tables and add `source_type`, not a new credit bridge table.
- More suitable for the current stage: unblock cloud schema and route gates before touching real account business data.
- Higher risk: treating unauthenticated `401` route probes as production UAT, or bypassing app flow by writing completed orders / ratings directly into DB.
