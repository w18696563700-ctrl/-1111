---
owner: Codex 总控
status: frozen
purpose: Freeze Day 2 BFF route and read-model shaping boundary for the project communication workbench 10-entry review surface.
layer: L3 BFF
freeze_scope: Route/read-model table only; no BFF implementation in this day.
---

# Project Communication Workbench 10 Entry Review BFF Route Read-Model Day2 Addendum

## 1. 总裁决

`Conditional Pass` for BFF route/read-model freeze.

BFF 后续可以承接项目沟通工作台 10 入口 app-facing read-model 和 8 资料审阅命令转发，但不得拥有确认/反馈真值，不得根据文件存在、中文标题或旧聊天确认卡推断 `confirmed`。

Day 2 不改 BFF 代码，不改 OpenAPI，不改云端。

## 2. BFF Route Table Draft

| App-facing route | Method | Target server-facing route draft | Day 2 decision | BFF role |
| --- | --- | --- | --- | --- |
| `/api/app/message/project-communication/workbench` | GET | `/server/project-communication/workbench` | new route draft | Validate query, forward auth carrier, shape 10-entry read-model. |
| `/api/app/message/project-communication/workbench/material-review` | POST | `/server/project-communication/workbench/material-review` | new route draft | Validate payload envelope, forward command, shape updated entry. |
| `/api/app/project/{projectId}/deal-confirmations` | POST | existing Server deal-confirmation family | canonical for final amount | Existing / future deal confirmation shaping only. |
| `/api/app/project/{projectId}/deal-confirmations/{dealConfirmationId}` | GET | existing Server deal-confirmation family | canonical read target | Existing / future deal confirmation read shaping only. |
| `/api/app/contract/confirm` | POST | existing contract handoff family | not canonical for final amount | Must not be used by `final_confirmed_amount_confirmation`. |

No BFF route for APNs / FCM / vibration is admitted.

## 3. Read-Model Ownership

| Concern | Server | BFF | Flutter |
| --- | --- | --- | --- |
| 10 entry existence | derive from project/thread/bid truth | pass through and validate | render groups |
| 8 material review state | truth owner | pass through only | render state |
| material attachment list | truth owner / read projection | pass through / shape | display and preview |
| feedback text/reasons | truth owner | pass through only | display / submit |
| final confirmed amount | truth owner | shape existing deal confirmation fields | render / navigate |
| payment charge | truth owner | shape read-only result only | render only |

Hard rule:

- BFF must not calculate `reviewState` from `attachmentCount`.
- BFF must not persist any review state in memory, Redis, database, or local files.
- BFF must not downgrade unknown states to `pending_review`.

## 4. Query Handling

### `GET /api/app/message/project-communication/workbench`

BFF accepts:

| Query | Required | BFF validation |
| --- | --- | --- |
| `projectId` | yes | non-empty string |
| `threadId` | yes | non-empty string |
| `counterpartOrganizationId` | no | non-empty string if present |
| `bidId` | no | non-empty string if present |

BFF forwards:

- authenticated session / actor carrier.
- query fields exactly after normalization.

BFF must not accept client-controlled `viewerRole`, `publisherOrganizationId`, `bidderOrganizationId`, or `reviewerOrganizationId`.

## 5. Workbench Read-Model Shape

Target BFF output:

```ts
type ProjectCommunicationWorkbenchView = {
  projectId: string;
  threadId: string;
  viewerRole: 'publisher' | 'bidder' | 'unknown';
  entries: ProjectCommunicationWorkbenchEntry[];
  generatedAt: string;
};
```

`entries` target count:

- exactly 10 for readable project/thread after Server support lands.
- if Server returns a blocked/unavailable state, BFF may preserve Server error or shape a controlled unavailable response only if contracts explicitly allow it.

Required entry fields:

| Field | BFF handling |
| --- | --- |
| `entryKey` | strict enum validation; unknown fails target tests. |
| `group` | strict enum validation. |
| `label` | pass through canonical label; do not translate from old copy. |
| `projectId` / `threadId` / `bidId` | pass through; must not be generated from route copy. |
| `viewerRole` / `subjectOwnerRole` | pass through; no display-text inference. |
| `availabilityState` | strict enum validation. |
| `reviewState` | strict enum validation for 8 material entries; null for deal entries. |
| `actionState` | strict enum validation. |
| `attachmentCount` | non-negative integer. |
| `latestFeedbackText` / `latestFeedbackAt` / `reviewedAt` | nullable pass through. |
| `routeTarget` | pass through canonical path and params after structural validation. |
| `truthAnchor` | pass through; required to prevent Flutter copy parsing. |

Compatibility:

- Before Server support, BFF must not synthesize a 10-entry success response and call it runtime pass.
- A compatibility/default fixture is acceptable only in tests explicitly marked old-runtime fallback.

## 6. Material Review Command Forwarding

### `POST /api/app/message/project-communication/workbench/material-review`

BFF validates payload envelope:

| Field | Rule |
| --- | --- |
| `projectId` | required non-empty string |
| `threadId` | required non-empty string |
| `bidId` | optional non-empty string |
| `entryKey` | required first 8 material entry keys only |
| `reviewAction` | `confirm` or `request_supplement` |
| `feedbackReasonCodes` | array of strings; BFF may trim but not interpret business meaning |
| `feedbackText` | nullable string; BFF may length-check only after contract freeze |
| `sourceVersionToken` | nullable string |
| `idempotencyKey` | required non-empty string |

BFF forwards:

- the normalized payload.
- current auth/session carrier.

BFF must not:

- choose reviewer organization from client payload.
- replace missing feedback with a canned reason.
- emit chat `confirmation_card`.
- write project communication messages as a side effect.

## 7. Canonical Deal Confirmation Boundary

For workbench entries:

| Entry | Canonical routeTarget | BFF decision |
| --- | --- | --- |
| `contract_confirmation` | `/api/app/project/{projectId}/deal-confirmations` | Use deal-confirmation family where bid-linked final amount is relevant. |
| `final_confirmed_amount_confirmation` | `/api/app/project/{projectId}/deal-confirmations` | Only this family may carry `finalConfirmedAmount`. |

Non-canonical:

| Route | Reason |
| --- | --- |
| `/api/app/contract/confirm` | No `finalConfirmedAmount`; belongs to existing order/contract handoff. |
| `/api/app/exhibition/trade-tasks/{taskId}/contract-confirmations` | Existing P0-Pay route family exists, but the workbench canonical app-facing route must not mix route families without a new contract decision. |

Day 8 must re-check runtime and choose only the canonical route approved by contracts and Server truth.

## 8. Error Boundary

Recommended normalized errors for future implementation:

| Condition | BFF behavior |
| --- | --- |
| Missing `projectId` / `threadId` | 400 normalized invalid request |
| Unknown `entryKey` | 400 normalized invalid request |
| Deal entry sent to material-review command | 400 normalized invalid request |
| Server permission denied | pass through normalized forbidden |
| Server state conflict | pass through normalized conflict |
| Server route missing on old runtime | controlled unavailable; do not claim feature pass |

No new error-code family is frozen in Day 2; Day 3/Day 5 may require one.

## 9. Test Requirements For Day 6

Target BFF tests must cover:

- GET workbench forwards `projectId + threadId + bidId`.
- GET workbench exposes exactly 10 entries from Server response.
- BFF rejects unknown `entryKey`.
- BFF does not infer `confirmed` from `attachmentCount > 0`.
- POST material-review forwards `confirm`.
- POST material-review forwards `request_supplement` with feedback.
- POST material-review rejects deal entries.
- `final_confirmed_amount_confirmation` routeTarget never uses `/api/app/contract/confirm`.

## 10. Explicit Non-Goals

- No BFF persistence.
- No BFF business truth.
- No Redis or local cache review state.
- No generated OpenAPI update in Day 2.
- No Flutter implementation.
- No Server implementation.
- No APNs / FCM / vibration.
- No payment charge, payment callback, settlement, invoice, or refund route.

## 11. Day 3 Handoff

Day 3 Server truth freeze must provide:

- canonical Server entity/table for 8 material review records.
- exact unique key.
- permission model.
- source material version strategy.
- controlled error family if needed.
- whether BFF can expose old-runtime unavailable state before Server route lands.
