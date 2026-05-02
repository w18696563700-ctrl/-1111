---
owner: Codex 总控
status: frozen
purpose: Freeze additive Day 2 contract field table and route draft for the project communication workbench 10-entry review surface.
layer: L2 Contracts
freeze_scope: Field table and route draft only; no openapi.yaml mutation in this day.
---

# Project Communication Workbench 10 Entry Review Contract Field Table Day2 Addendum

## 1. 总裁决

`Conditional Pass` for Day 2 contract freeze.

本文件只冻结字段表、route 草案和合同漂移登记，不直接修改 `docs/01_contracts/openapi.yaml`，不生成 contracts，不进入 BFF / Server / Flutter 实现。

允许进入第 3 天 Server truth freeze 的条件：

- 10 个 `entryKey` 固定。
- 资料审阅状态固定为 `未提交 / 待确认 / 已确认 / 需补充`。
- BFF 不持有确认真值。
- `最终成交金额确认` 不混用旧 `/api/app/contract/confirm`。

## 2. Current Minimum Contract Loop

新增一个项目沟通工作台读模型草案：

```text
GET /api/app/message/project-communication/workbench
```

新增一个资料审阅命令草案：

```text
POST /api/app/message/project-communication/workbench/material-review
```

本 Day 2 不新增正式 OpenAPI path，只冻结后续同步到 `openapi.yaml` 的目标形态。

## 3. Entry Key Enum

Target enum: `ProjectCommunicationWorkbenchEntryKey`.

| entryKey | Group | Label | Source truth |
| --- | --- | --- | --- |
| `publisher_effect_image_review` | `publisher_materials` | `效果图确认` | `project_attachments.effect_image` |
| `publisher_construction_doc_review` | `publisher_materials` | `尺寸图 / 施工图确认` | `project_attachments.construction_doc` |
| `publisher_material_sample_review` | `publisher_materials` | `材质图 / 材料样板确认` | `project_attachments.material_sample` |
| `publisher_equipment_material_list_review` | `publisher_materials` | `设备物料清单确认` | `project_attachments.equipment_material_list` |
| `publisher_service_list_review` | `publisher_materials` | `服务清单确认` | `project_attachments.service_list` |
| `bid_project_understanding_review` | `bid_materials` | `项目理解确认` | `bids.projectUnderstandingFileAssetId` |
| `bid_quote_sheet_review` | `bid_materials` | `报价表确认` | `bids.quoteSheetFileAssetId` |
| `bid_schedule_plan_review` | `bid_materials` | `进度安排确认` | `bids.schedulePlanFileAssetId` |
| `contract_confirmation` | `deal_confirmation` | `合同确认` | Server deal / contract confirmation truth |
| `final_confirmed_amount_confirmation` | `deal_confirmation` | `最终成交金额确认` | `ContractConfirmation.finalConfirmedAmount` |

Deprecated UI labels:

| Deprecated | Canonical replacement |
| --- | --- |
| `报价确认` | `报价表确认` |
| `排期确认` | `进度安排确认` |
| `工艺材质确认` | `项目理解确认` |

## 4. `ProjectCommunicationWorkbenchEntry`

Target read-model item:

| Field | Type | Required | Rule |
| --- | --- | --- | --- |
| `entryKey` | `ProjectCommunicationWorkbenchEntryKey` | yes | One of the 10 fixed keys. |
| `group` | `"publisher_materials" | "bid_materials" | "deal_confirmation"` | yes | Drives UI grouping only. |
| `label` | `string` | yes | Must match the canonical Chinese labels in this file. |
| `summary` | `string | null` | yes | Display-only guidance; not truth. |
| `projectId` | `string` | yes | Current project anchor. |
| `threadId` | `string` | yes | Current project communication thread anchor. |
| `bidId` | `string | null` | yes | Required for bid-material and deal-confirmation entries when available. |
| `viewerRole` | `"publisher" | "bidder" | "unknown"` | yes | Derived by Server from current organization relation, not client supplied. |
| `subjectOwnerRole` | `"publisher" | "bidder" | "platform"` | yes | Identifies whose material or deal object is being reviewed. |
| `availabilityState` | `"unsubmitted" | "readable" | "unavailable"` | yes | Whether the source material / deal object can be opened. |
| `reviewState` | `ProjectCommunicationMaterialReviewState | null` | yes | Non-null only for the 8 material review entries. |
| `actionState` | `"enabled" | "readonly" | "blocked"` | yes | Whether current viewer can act on this entry. |
| `attachmentCount` | `number` | yes | Count of source files; `0` for not submitted or non-material entries. |
| `latestFeedbackText` | `string | null` | yes | Latest persisted feedback summary for material entries. |
| `latestFeedbackAt` | `string | null` | yes | ISO timestamp of latest persisted feedback. |
| `reviewedAt` | `string | null` | yes | ISO timestamp of latest persisted confirmation. |
| `routeTarget` | `ProjectCommunicationWorkbenchRouteTarget | null` | yes | App navigation target for detail/open actions. |
| `truthAnchor` | `ProjectCommunicationWorkbenchTruthAnchor` | yes | Structured truth owner anchor; Flutter must not parse copy. |

Rules:

- BFF may type-check and shape these fields but must not derive business state.
- Flutter must not infer `reviewState` from `attachmentCount`.
- Missing or unknown `entryKey` must be treated as contract drift.

## 5. Material Review State

Target enum: `ProjectCommunicationMaterialReviewState`.

| Value | Chinese | Color | Rule |
| --- | --- | --- | --- |
| `unsubmitted` | `未提交` | gray | Source material is missing or not readable. |
| `pending_review` | `待确认` | orange | Source material exists and awaits counterpart review. |
| `confirmed` | `已确认` | green | Counterpart organization confirmed the material in Server truth. |
| `needs_supplement` | `需补充` | red | Counterpart organization submitted a persisted supplement request. |

Compatibility:

- Old runtime with no review truth may expose `pending_review` only when source material exists.
- Old runtime must not expose `confirmed` or `needs_supplement` unless Server has persisted truth.

## 6. Truth Anchor

Target schema: `ProjectCommunicationWorkbenchTruthAnchor`.

| Field | Type | Required | Rule |
| --- | --- | --- | --- |
| `truthOwner` | `"server"` | yes | Server is the only owner. |
| `subjectType` | `"publisher_quote_basis_material" | "bid_submission_material" | "deal_confirmation"` | yes | Object family. |
| `projectId` | `string` | yes | Project anchor. |
| `threadId` | `string` | yes | Communication anchor. |
| `bidId` | `string | null` | yes | Required for bid material and deal confirmation when selected bid exists. |
| `subjectOwnerOrganizationId` | `string | null` | yes | Publisher or bidder organization owning the subject. |
| `reviewerOrganizationId` | `string | null` | yes | Organization allowed to confirm or request supplement. |
| `materialKind` | `ProjectQuoteBasisMaterialKind | null` | yes | For the 5 publisher material entries. |
| `bidMaterialSlot` | `"project_understanding" | "quote_sheet" | "schedule_plan" | null` | yes | For the 3 bid material entries. |
| `dealConfirmationId` | `string | null` | yes | For deal-confirmation entries if available. |

## 7. Route Target

Target schema: `ProjectCommunicationWorkbenchRouteTarget`.

| Field | Type | Required | Rule |
| --- | --- | --- | --- |
| `actionKey` | `string` | yes | Stable app action token. |
| `canonicalPath` | `string` | yes | Template path, not interpolated raw URLs. |
| `params` | `object` | yes | Project/thread/bid/entry identifiers. |

Required action keys:

| Entry family | actionKey | canonicalPath |
| --- | --- | --- |
| 8 material entries | `project_communication_material_review.open` | `/api/app/message/project-communication/workbench/material-review-detail` |
| `contract_confirmation` | `project_deal_confirmation.open` | `/api/app/project/{projectId}/deal-confirmations` |
| `final_confirmed_amount_confirmation` | `project_deal_confirmation.final_amount.open` | `/api/app/project/{projectId}/deal-confirmations` |

No-Go:

- `/api/app/contract/confirm` must not be used as `final_confirmed_amount_confirmation`.
- Raw OSS URLs must not be route targets.

## 8. Workbench Read Request / Response Draft

### `GET /api/app/message/project-communication/workbench`

Query:

| Field | Type | Required | Rule |
| --- | --- | --- | --- |
| `projectId` | `string` | yes | Current project. |
| `threadId` | `string` | yes | Current project communication thread. |
| `counterpartOrganizationId` | `string` | no | Optional disambiguation for grouped conversation. |
| `bidId` | `string` | no | Optional selected bid; Server may derive where unambiguous. |

Response:

| Field | Type | Required | Rule |
| --- | --- | --- | --- |
| `projectId` | `string` | yes | Echo Server-resolved project. |
| `threadId` | `string` | yes | Echo Server-resolved thread. |
| `viewerRole` | `"publisher" | "bidder" | "unknown"` | yes | Derived relation. |
| `entries` | `ProjectCommunicationWorkbenchEntry[]` | yes | Exactly 10 entries in canonical order when project is readable. |
| `generatedAt` | `string` | yes | Server timestamp. |

## 9. Material Review Command Draft

### `POST /api/app/message/project-communication/workbench/material-review`

Payload:

| Field | Type | Required | Rule |
| --- | --- | --- | --- |
| `projectId` | `string` | yes | Must match subject project. |
| `threadId` | `string` | yes | Must belong to project. |
| `bidId` | `string` | no | Required for bid-material entries. |
| `entryKey` | first 8 `ProjectCommunicationWorkbenchEntryKey` values | yes | Deal entries are not accepted here. |
| `reviewAction` | `"confirm" | "request_supplement"` | yes | Material review action. |
| `feedbackReasonCodes` | `string[]` | no | Required for selected quick reasons when supplementing. |
| `feedbackText` | `string | null` | no | Required for `request_supplement` unless reason codes fully explain the issue. |
| `sourceVersionToken` | `string | null` | no | Optional target for later version invalidation. |
| `idempotencyKey` | `string` | yes | Required write idempotency key. |

Response:

| Field | Type | Required | Rule |
| --- | --- | --- | --- |
| `entry` | `ProjectCommunicationWorkbenchEntry` | yes | Updated entry. |
| `entries` | `ProjectCommunicationWorkbenchEntry[]` | no | Optional refreshed 10-entry list. |

Validation:

- Current organization must be the reviewer for the selected item.
- Current organization must not confirm its own material.
- Cross-project, cross-thread, cross-bid, and unknown entry writes must be rejected.

## 10. `BidSubmitRequest` Drift Register

Contracts drift found during Day 1 discovery:

| Source | Current state |
| --- | --- |
| Frozen bid-submit docs / BFF / Server truth | Three confirmed attachment fields are expected: `projectUnderstandingFileAssetId`, `quoteSheetFileAssetId`, `schedulePlanFileAssetId`. |
| `docs/01_contracts/openapi.yaml` | Current `BidSubmitRequest` only shows `projectId`, `quoteAmount`, `proposalSummary`. |

Day 2 decision:

- Register this as an OpenAPI drift.
- Do not edit `openapi.yaml` in Day 2.
- Day 5+ implementation must not rely on incomplete generated contract types until drift is reconciled.

## 11. Deal Confirmation Canonical Route Decision

Canonical app-facing route family for `final_confirmed_amount_confirmation`:

```text
POST /api/app/project/{projectId}/deal-confirmations
GET  /api/app/project/{projectId}/deal-confirmations/{dealConfirmationId}
```

Reason:

- These routes carry `DealConfirmationCreateRequest.finalConfirmedAmount`.
- They represent bid-linked dual confirmation and platform pricing context.

Explicitly not canonical for final amount:

```text
POST /api/app/contract/confirm
```

Reason:

- It confirms an existing contract/order object and does not carry `finalConfirmedAmount`.

## 12. Explicit Non-Goals

- No `openapi.yaml` mutation in Day 2.
- No generated type update.
- No Flutter implementation.
- No BFF / Server implementation.
- No migration.
- No cloud deploy.
- No APNs / FCM / vibration.
- No payment-charge write smoke.

## 13. Day 3 Admission

`Conditional Go` for Day 3 Server truth freeze.

Day 3 must decide:

- Dedicated material review persistence table or equivalent.
- Exact review record unique key.
- Permission model.
- Migration need and risk.
- Whether `sourceVersionToken` is required in first implementation.
