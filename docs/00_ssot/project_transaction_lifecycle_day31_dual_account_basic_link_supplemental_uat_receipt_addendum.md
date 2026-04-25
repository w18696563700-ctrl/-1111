---
owner: Codex 总控
status: frozen
layer: L0 supplemental UAT receipt
scheduled_day: 2026-05-31
execution_recorded_at_local: 2026-04-25
purpose: Record the Day31 supplemental dual-account basic-link UAT attempt on the current post-Day35 cloud baseline.
---

# Project Transaction Lifecycle Day31 Dual-Account Basic Link Supplemental UAT Receipt

## 1. Conclusion

Day31 supplemental UAT is **not passed**.

Current result:

- Cloud Server / BFF / Nginx are active.
- Current runtime is not rolled back to Day29.
- Current Server and BFF are on the later order-detail patch baseline:
  - Server: `/srv/releases/server/20260425204500-order-detail-projectid-cloud-patch`
  - BFF: `/srv/releases/bff/20260425204500-order-detail-projectid-cloud-patch/apps/bff`
- The runtime still contains Day32-Day34 counterparty-rating / credit `source_type` capability.
- The 8080 tunnel can reach message interaction, counterpart conversation, and order-detail routes.
- Computer Use found two `mobile` app processes and both can show the same project communication / order card chain.
- However, both app processes are logged in as the same person and same current organization:
  - person: `江北嘴嘴帅`
  - current organization: `重庆展宏展览展示有限公司`
- The order under test requires two sides:
  - buyer: `重庆坤特展览展示有限公司`
  - supplier: `重庆展宏展览展示有限公司`

Therefore, this run proves only the supplier-side / single-organization entry path. It does not prove the buyer + supplier dual-account basic link.

## 2. Scope

This receipt covers only:

- Day31 supplemental Computer Use UAT attempt;
- current cloud baseline check;
- 8080 route materialization check;
- project communication / order-card visual anchor check;
- account / organization identity check.

This receipt does not claim:

- buyer-side project communication entry passed;
- seller request / buyer confirm completion passed;
- completed-order rating passed;
- production acceptance passed.

## 3. Cloud Runtime Baseline

| Item | Result |
|---|---|
| Server current | `/srv/releases/server/20260425204500-order-detail-projectid-cloud-patch` |
| BFF current | `/srv/releases/bff/20260425204500-order-detail-projectid-cloud-patch/apps/bff` |
| `exhibition-server.service` | `active` |
| `exhibition-bff.service` | `active` |
| `nginx.service` | `active` |

Baseline decision:

- Do not roll back to Day29.
- Treat this as the current post-Day35 cloud baseline because it retains the order route surface and Day32-Day34 rating / credit source-type capability.

## 4. Day35 Capability Retention Check

Runtime code / DB proof:

| Check | Result |
|---|---:|
| Server release contains `20260602_credit_shadow_source_type_truth` | Pass |
| Server release contains `sourceType: 'project_counterparty_rating'` | Pass |
| `organization_shadow_credit_recompute_triggers.source_type` exists | Pass |
| `organization_shadow_credit_ledgers.source_type` exists | Pass |
| `server_schema_migration` contains `20260602_credit_shadow_source_type_truth` | Pass |

Meaning:

- This run is not using the old Day29-only release.
- It is safe to continue later Day32-Day34 rating / credit verification on the current runtime.

## 5. 8080 Route Probe

Unauthenticated route probes:

| Route | Result | Meaning |
|---|---|---|
| `GET /api/app/order/detail?orderId=day31-probe` | `401 AUTH_SESSION_INVALID` | Route mounted and auth-gated. |
| `GET /api/app/message/interactions?lane=project_communication` | `401 AUTH_SESSION_INVALID` | Route mounted and auth-gated. |
| `GET /api/app/message/counterpart-conversation/detail?...` | `401 AUTH_SESSION_INVALID` | Route mounted and auth-gated. |

These probes only prove route materialization. They do not prove dual-account business success.

## 6. Computer Use Evidence

Computer Use / accessibility observed two running `mobile` processes:

| Process | Window count | Initial project communication evidence |
|---|---:|---|
| `48979` | `1` | Project communication page showed `ProjectOrder` card. |
| `62868` | `1` | Project communication page showed the same `ProjectOrder` card. |

Observed order card anchors:

| Anchor | Value |
|---|---|
| `orderId` | `4dbb4087-1817-4019-bda9-76e8bc9e0f5d` |
| `orderNo` | `ORD-P0PAY-1777106145607-73B72588` |
| `projectId` | `b1078b97-ee44-4b75-8c4d-d9a49cb6c46c` |
| order state | `进行中 / active` |
| completion request state | `未申请完工 / none` |

Observed UI guard:

- The order card shows: `当前账号未能匹配订单双方，只展示订单状态，不开放完成动作。`
- This is consistent with the Day30 missing-anchor guard and does not expose unsafe completion actions.

## 7. Account / Organization Identity Check

Both `mobile` processes were checked through `我的` and `我的公司`.

| Process | Person | Current organization | Result |
|---|---|---|---|
| `48979` | `江北嘴嘴帅` | `重庆展宏展览展示有限公司` | Supplier side only. |
| `62868` | `江北嘴嘴帅` | `重庆展宏展览展示有限公司` | Same supplier side only. |

Cloud DB order truth for the observed order:

| Role | Organization |
|---|---|
| buyer | `重庆坤特展览展示有限公司` |
| supplier | `重庆展宏展览展示有限公司` |

Mismatch:

- The supplier side is visible twice.
- The buyer side `重庆坤特展览展示有限公司` is not logged into either visible `mobile` process.

## 8. Stage Gate Checklist

| Gate | Result | Blocks |
|---|---:|---|
| Current cloud baseline active | Pass | No |
| No rollback to Day29 | Pass | No |
| 8080 app routes reachable | Pass | No |
| Two `mobile` processes visible | Pass | No |
| Both processes can show same order-card chain | Partial Pass | Does not prove dual-account. |
| Two different real accounts visible | Fail | Blocks Day31 pass. |
| Buyer and supplier both visible | Fail | Blocks Day31 pass. |
| Same `projectId/orderId` chain visible on both buyer/supplier | Fail | Blocks Day31 pass. |

## 9. Decision

Day31 supplemental UAT result:

- Single-side project communication / order-card chain: **Pass**.
- Dual-account basic link: **No-Go**.

Reason:

- Both visible app processes are authenticated as the same person and same current organization.
- The order truth requires buyer `重庆坤特展览展示有限公司` plus supplier `重庆展宏展览展示有限公司`.
- This run cannot prove the buyer-side app can enter the same project communication / order chain.

## 10. Required Next Action

To pass Day31, the next run must provide:

1. one app window logged in as buyer-side organization `重庆坤特展览展示有限公司`;
2. one app window logged in as supplier-side organization `重庆展宏展览展示有限公司`;
3. both windows visible or switchable through Computer Use / accessibility;
4. both windows entering the same `projectId=b1078b97-ee44-4b75-8c4d-d9a49cb6c46c` and `orderId=4dbb4087-1817-4019-bda9-76e8bc9e0f5d` chain.

Allowed proof:

- buyer message center -> project communication -> same order card;
- supplier message center -> project communication -> same order card;
- DB read-only check confirming the same order anchors.

Not allowed:

- using two windows that are both supplier-side;
- using route `401` probes as dual-account proof;
- hand-editing DB to create a fake completed order;
- claiming Day31 pass before buyer + supplier are both visible.

## 11. Stability / Cost / Stage Fit

- More stable: keep the current post-Day35 cloud baseline and rerun only the missing buyer-side login proof.
- More cost-efficient: do not re-release or roll back; the blocker is session identity, not Server/BFF route materialization.
- More suitable for the current stage: freeze this as a failed supplemental UAT and require the exact buyer/supplier account setup before rerun.
- Higher risk: treating two processes with the same user/org as dual-account acceptance.
