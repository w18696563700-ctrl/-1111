# Project Exit And Breach Governance Phase 1 Day10B Runtime Receipt

## 0. Verdict

- Gate: Day10B accepted cancellation closeout
- Result: Pass
- Final rule: accepted mutual cancellation is not trace-only. It closes the active order and returns the project to `submitted`.
- Payment rule: no automatic penalty, no payment initialization, no charge, no platform service fee authorization.

## 1. Frozen Closeout Truth

| Item | Runtime result |
|---|---|
| Cancellation request | created `project_exit_cases` row with `status=requested` |
| Cancellation acceptance | updated case to `status=accepted` |
| Project closeout | `converted_to_order -> submitted` |
| Public visibility | `published_at` cleared |
| Order closeout | `active -> cancelled` |
| Payment behavior | no payment order created |
| Platform fee behavior | no authorization created |
| Audit behavior | request and acceptance audit events recorded |

## 2. Release Evidence

| Item | Evidence |
|---|---|
| Server release | `20260429121720-project-exit-day10b-closeout` |
| Previous release rollback pointer | `/srv/shared/rollback-server-before-20260429121720-project-exit-day10b-closeout.txt` |
| Migration | none required; runtime log showed `appliedThisBoot=none` |
| Server health | `GET /health/server/live` returned 200 |
| BFF health | `GET /health/bff/live` returned 200 |
| Server tests | `node --test apps/server/test/project-lifecycle-correction.test.cjs`: 10 passed |
| BFF tests | `node --test apps/bff/test/project-lifecycle-correction.test.cjs`: 5 passed |

## 3. Controlled Runtime Sample

| Field | Value |
|---|---|
| Runtime stamp | `day10b-1777436477923` |
| Project ID | `4faacb53-2431-4eac-9635-4177ca2c6a1c` |
| Order ID | `985122a3-64fa-4218-a049-de4521f55a6d` |
| Exit case ID | `1a182d6c-84ed-4b47-b4d4-0a07dd9e99c5` |
| Request actor organization | `e6bf4567-016e-45f9-9420-9c950237690e` |
| Acceptance actor organization | `bdfb4523-aeb7-4b56-89a1-992170fb5d98` |

## 4. DB Verification

| Check | Result |
|---|---|
| `project.state` | `submitted` |
| `project.published_at` | `null` |
| `orders.state` | `cancelled` |
| `project_exit_cases.exit_type` | `mutual_cancellation` |
| `project_exit_cases.status` | `accepted` |
| `project_exit_cases.no_automatic_penalty_confirmed` | `true` |
| `payment_orders` count for runtime stamp | `0` |
| `platform_service_fee_authorizations` count for runtime stamp | `0` |

## 5. Audit Verification

| Event | Payload evidence |
|---|---|
| `project_cancellation_requested` | case status `requested`; project state `converted_to_order`; no automatic penalty |
| `project_cancellation_accepted` | previous project state `converted_to_order`; next project state `submitted`; previous order state `active`; next order state `cancelled`; no automatic penalty |

## 6. Residual Risk

- Existing order detail read corridor currently treats only `active` and `completed` orders as visible. After accepted cancellation, the closed order may need a read-only cancelled-order detail surface if product wants users to review the cancelled order from messages or history.
- Flutter "My Projects" should refresh into the prepublish/submitted bucket after acceptance. If UX needs a clearer "cancelled order returned to prepublish" banner, that belongs to Day10C read-side carry.

## 7. Next Unique Action

Day10C read-side carry: add the minimum read-only handling for cancelled order state in order detail, messages, and my projects, without reopening payment or penalty logic.
