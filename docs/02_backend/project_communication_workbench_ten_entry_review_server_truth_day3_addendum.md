---
owner: Codex 总控
status: frozen
purpose: Freeze the Server truth model and migration boundary for the 8 material review entries inside the project communication workbench 10-entry surface.
layer: L3 Backend truth
freeze_scope: Server truth model and migration boundary only; no Server implementation, migration execution, BFF implementation, Flutter implementation, or cloud change in this day.
---

# Project Communication Workbench 10 Entry Review Server Truth Day3 Addendum

## 1. 总裁决

`Conditional Pass` for Day 3 Server truth freeze.

Server 是 8 项资料审阅确认和反馈的唯一业务真值 owner。BFF 只能转发和塑形，Flutter 只能渲染、提交命令和刷新状态。

Day 3 不写 Server 代码，不创建 migration，不改 BFF，不改 Flutter，不触碰云端。

允许进入第 4 天 Flutter UI 施工图的条件：

- 8 项资料审阅记录的锚点、状态、权限、版本策略已经冻结。
- 明确需要 additive migration。
- 明确不能用聊天消息、确认卡、Flutter 本地状态替代审阅真值。

## 2. Existing Truth Sources

| Material family | Existing truth carrier | Current status |
| --- | --- | --- |
| 发布方 5 份报价依据资料 | `project_attachments` | 已有资料业务绑定真值。 |
| 竞标方 3 份竞标提交资料 | `bids.project_understanding_file_asset_id`, `bids.quote_sheet_file_asset_id`, `bids.schedule_plan_file_asset_id` | 已有附件槽位真值。 |
| 合同确认 / 最终成交金额 | `contract_confirmations` | 已有 P0-Pay truth family，但可能触发平台服务费 charge，Day 8 前不得混入资料审阅实现。 |

缺口：

- 当前没有 8 项资料逐项审阅确认 / 反馈持久化真值。
- 当前聊天确认卡和项目沟通消息不能承载这 8 项正式状态。

## 3. Review Scope

本 Server truth 只覆盖以下 8 个资料审阅 entry：

| entryKey | Subject type | Source carrier | Reviewer |
| --- | --- | --- | --- |
| `publisher_effect_image_review` | `publisher_quote_basis_material` | `project_attachments.effect_image` | 竞标方组织 |
| `publisher_construction_doc_review` | `publisher_quote_basis_material` | `project_attachments.construction_doc` | 竞标方组织 |
| `publisher_material_sample_review` | `publisher_quote_basis_material` | `project_attachments.material_sample` | 竞标方组织 |
| `publisher_equipment_material_list_review` | `publisher_quote_basis_material` | `project_attachments.equipment_material_list` | 竞标方组织 |
| `publisher_service_list_review` | `publisher_quote_basis_material` | `project_attachments.service_list` | 竞标方组织 |
| `bid_project_understanding_review` | `bid_submission_material` | `bids.project_understanding_file_asset_id` | 发布方组织 |
| `bid_quote_sheet_review` | `bid_submission_material` | `bids.quote_sheet_file_asset_id` | 发布方组织 |
| `bid_schedule_plan_review` | `bid_submission_material` | `bids.schedule_plan_file_asset_id` | 发布方组织 |

不在本 Server truth 范围内：

- `contract_confirmation`
- `final_confirmed_amount_confirmation`
- APNs / FCM / 震动
- 平台服务费扣费、结算、发票、退款

## 4. Persistence Carrier

Day 5 implementation target requires a new additive table:

```text
project_communication_material_reviews
```

Reason:

- 8 项资料审阅状态必须按项目、竞标、审阅组织和资料项独立持久化。
- `project_communication_messages` 是沟通消息真值，不能扩写为业务审阅状态机。
- `project_attachments` 和 `bids` 是资料来源真值，不能承载对方审阅状态。

Migration decision:

- `Required`.
- Additive only.
- No destructive change.
- No backfill required for initial launch.
- Cloud migration execution must wait for Day 9/Day 10 gate.

## 5. Canonical Review Record

Target entity: `ProjectCommunicationMaterialReview`.

| Field | Required | Rule |
| --- | --- | --- |
| `id` | yes | Server generated id. |
| `projectId` | yes | Current project anchor. |
| `threadId` | yes | Project communication thread anchor. |
| `bidId` | yes | Selected bid anchor. Required for all 8 review entries because publisher-material review is reviewed by a concrete bidder. |
| `entryKey` | yes | One of the first 8 workbench entry keys. Deal entries are forbidden. |
| `subjectType` | yes | `publisher_quote_basis_material` or `bid_submission_material`. |
| `materialKind` | nullable | Required for the 5 publisher material entries. |
| `bidMaterialSlot` | nullable | Required for the 3 bid material entries. |
| `subjectOwnerOrganizationId` | yes | Organization that uploaded / owns the material. |
| `reviewerOrganizationId` | yes | Counterpart organization allowed to confirm or request supplement. |
| `reviewState` | yes | `pending_review`, `confirmed`, or `needs_supplement`. `unsubmitted` is derived, not stored. |
| `feedbackReasonCodes` | yes | JSON array, empty for confirmed. |
| `feedbackText` | nullable | Required for supplement when reason codes are insufficient. |
| `sourceVersionToken` | yes | Hash / token derived from current source material ids and update timestamps. |
| `confirmedByUserId` | nullable | Set only for `confirmed`. |
| `confirmedAt` | nullable | Set only for `confirmed`. |
| `feedbackByUserId` | nullable | Set only for `needs_supplement`. |
| `feedbackAt` | nullable | Set only for `needs_supplement`. |
| `requestId` | yes | Idempotency / audit correlation. |
| `traceId` | yes | Request trace. |
| `createdAt` | yes | Server timestamp. |
| `updatedAt` | yes | Server timestamp. |

Derived read state:

- If source material is missing or unreadable, expose `unsubmitted`; do not create a review row.
- If source material exists and no matching review row exists, expose `pending_review`.
- If source material exists and matching review row token equals current `sourceVersionToken`, expose the persisted `reviewState`.
- If source material token changed after confirmation or feedback, expose `pending_review` and preserve old row for audit/reference until implementation defines history behavior.

## 6. Unique Key And Indexes

Canonical active uniqueness:

```text
project_id + bid_id + reviewer_organization_id + entry_key
```

Target unique index:

```text
idx_project_communication_material_reviews_active_unique
```

Recommended supporting indexes:

| Index | Purpose |
| --- | --- |
| `idx_project_communication_material_reviews_project_bid` | Build 10-entry workbench read-model quickly. |
| `idx_project_communication_material_reviews_reviewer` | Reviewer-side filtering and permission checks. |
| `idx_project_communication_material_reviews_state` | Future admin / dispute filtering. |

No unique key may omit `reviewerOrganizationId`, because publisher and bidder have opposite review responsibilities.

## 7. Source Version Token

`sourceVersionToken` is required in the first durable implementation.

Recommended derivation:

| Entry family | Token input |
| --- | --- |
| 发布方 5 份资料 | Sorted active `project_attachments` rows for `projectId + attachmentKind`: `attachmentId`, `fileAssetId`, `createdAt`, `updatedAt` if available. |
| 竞标方 3 份资料 | `bidId`, slot name, slot `fileAssetId`, bid `updatedAt`. |

Rules:

- Token is generated by Server, not Flutter or BFF.
- Client may echo `sourceVersionToken` in write commands to prevent stale confirm/feedback.
- If echoed token differs from current Server token, reject with conflict.
- Token is not a security secret and must not contain raw OSS URLs.

## 8. Permission Model

Base permission:

- Current actor must belong to an authenticated organization.
- Organization must be a participant of the target project communication thread.
- `projectId`, `threadId`, and `bidId` must be mutually consistent.

Publisher material review:

- Subject owner is publisher organization.
- Reviewer is the bidder organization bound to `bidId`.
- Publisher can view review result and feedback, but cannot confirm its own publisher materials.
- Other bidder organizations cannot review a bid-unrelated publisher-material row.

Bid material review:

- Subject owner is bidder organization bound to `bidId`.
- Reviewer is publisher organization.
- Bidder can view review result and feedback, but cannot confirm its own bid materials.
- Other publishers / organizations cannot review.

Forbidden:

- Cross-project review.
- Cross-thread review.
- Cross-bid review.
- Client-supplied reviewer or owner organization override.
- Deal entries sent to material-review command.

## 9. Commands

Server command family:

```text
GET  /server/project-communication/workbench
POST /server/project-communication/workbench/material-review
```

`GET /server/project-communication/workbench`:

- Derives 10 entries from project, thread, selected bid, attachments, bid slots, deal-confirmation read state, and material review rows.
- Does not create rows as a side effect.
- Returns exactly 10 entries when project/thread is readable and selected bid context is available.

`POST /server/project-communication/workbench/material-review`:

- Accepts only the first 8 material `entryKey` values.
- Supports `confirm`.
- Supports `request_supplement`.
- Requires idempotency key.
- Performs permission checks before persistence.
- Persists review row with current `sourceVersionToken`.
- Returns updated entry and optionally refreshed entry list.

## 10. State Transitions

| Current derived state | Action | Result | Rule |
| --- | --- | --- | --- |
| `unsubmitted` | any write | reject | Missing source cannot be confirmed or supplemented. |
| `pending_review` | `confirm` | `confirmed` | Set `confirmedByUserId`, `confirmedAt`, clear active feedback fields. |
| `pending_review` | `request_supplement` | `needs_supplement` | Set feedback fields and require reason/text. |
| `needs_supplement` | `confirm` | `confirmed` | Allowed after reviewer accepts current source token. |
| `confirmed` | `request_supplement` | `needs_supplement` | Allowed only if reviewer explicitly submits feedback for current token. |
| any persisted state | source token changes | derived `pending_review` | Current material changed and requires re-review. |

No terminal state is frozen in Day 3. Future dispute / admin intervention must be separately frozen.

## 11. Error Boundary

Recommended Server errors for Day 5 implementation:

| Condition | Suggested code |
| --- | --- |
| Unknown entry key | `PROJECT_COMMUNICATION_WORKBENCH_ENTRY_INVALID` |
| Deal entry sent to material-review | `PROJECT_COMMUNICATION_MATERIAL_REVIEW_ENTRY_REQUIRED` |
| Missing source material | `PROJECT_COMMUNICATION_MATERIAL_UNSUBMITTED` |
| Cross project/thread/bid | `PROJECT_COMMUNICATION_WORKBENCH_SCOPE_MISMATCH` |
| Not participant | `PROJECT_COMMUNICATION_WORKBENCH_FORBIDDEN` |
| Reviewer mismatch | `PROJECT_COMMUNICATION_MATERIAL_REVIEWER_MISMATCH` |
| Source token conflict | `PROJECT_COMMUNICATION_MATERIAL_SOURCE_CONFLICT` |
| Missing supplement reason | `PROJECT_COMMUNICATION_MATERIAL_FEEDBACK_REQUIRED` |

Day 3 freezes names as design targets only. OpenAPI / generated error contracts still require a later contract sync gate.

## 12. Contract And Amount Boundary

`contract_confirmation` and `final_confirmed_amount_confirmation` are visible workbench entries, but not part of the 8 material review table.

Rules:

- `finalConfirmedAmount` remains owned by Server deal / contract confirmation truth.
- Flutter and BFF must not calculate or persist final amount truth.
- Day 5 material-review implementation must not call P0-Pay charge creation.
- Day 8 must separately verify whether the existing deal-confirmation route can be used as a safe entry without triggering real charge.

## 13. Day 5 Implementation Scope

Allowed in Day 5 after Day 4 UI施工图:

- Add `ProjectCommunicationMaterialReview` entity.
- Add additive migration.
- Add review query/service.
- Add workbench read projection.
- Add material-review command handler.
- Add scoped tests for persistence, permissions, source-token conflict, and state transitions.

Not allowed without a separate gate:

- Changing existing `project_attachments` semantics.
- Changing `bids` attachment fields.
- Changing P0-Pay charge behavior.
- Writing payment orders, settlement, invoice, refund, or wallet state.
- Creating APNs / FCM / vibration routes.

## 14. No-Go List

- No-Go if the implementation tries to store review state in Flutter local state.
- No-Go if BFF derives `confirmed` from file existence.
- No-Go if chat messages or confirmation cards become the status carrier.
- No-Go if source material update does not invalidate or conflict with old confirmation.
- No-Go if final amount confirmation is routed through `/api/app/contract/confirm`.
- No-Go if material-review implementation triggers platform service fee charge.

## 15. Day 4 Handoff

`Conditional Go` for Day 4 Flutter UI 施工图.

Day 4 must design the UI against this Server truth:

- 10 workbench entries visible in grouped layout.
- 8 material entries navigate to detail pages with real attachment preview area, confirm button, and feedback form.
- `confirmed` green, `needs_supplement` red, `pending_review` orange, `unsubmitted` gray.
- Publisher and bidder see the same 10 entry names, but detail-page actions are role-specific.
- Bottom chat input remains attachment / image / text / send only; no confirmation主入口.
