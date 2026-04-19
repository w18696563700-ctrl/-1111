---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the L3 Server truth and persistence boundary for Trading-scoped IM
  Round A before implementation, covering the unique Server-owned carriers,
  write commands, attachment binding, audit actions, and explicit No-Go
  boundaries.
layer: L3 Backend
freeze_date_local: 2026-04-16
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/trading_im_round_a_truth_freeze_addendum.md
  - docs/01_contracts/trading_im_round_a_contracts_addendum.md
  - docs/02_backend/audit_log_spec.md
  - docs/02_backend/project_transaction_skeleton_p0_backend_truth_addendum.md
  - apps/server/src/modules/project/project.module.ts
  - apps/server/src/modules/bid/bid.module.ts
  - apps/server/src/modules/upload/upload-write.service.ts
---

# 《交易场景 IM Round A backend truth / persistence freeze》

## 1. Scope

- 本冻结单只覆盖 Server-owned Trading IM Round A truth。
- Server remains the only business truth owner.
- BFF, Flutter, Admin, generated contracts, and tests do not own Round A truth.
- 本冻结单不授权 implementation until the control gate and cloud prerequisite
  gate both pass.

## 2. Server Truth Carriers

Round A requires Server-owned truth carriers for:

- `project_clarifications`
  - public clarification row bound to `projectId`
- `bid_private_threads`
  - private thread row bound to `projectId + bidId`
- `bid_thread_messages`
  - append-only message row bound to a thread
- `bid_thread_confirmation_cards`
  - minimum confirmation-card row bound to a thread

Exact table and entity names may be implemented with existing repository
naming discipline, but they must preserve the four responsibilities above and
must not collapse into forum entities or upload entities.

## 3. Project Clarification Truth

- Business anchor:
  - `projectId`
- Minimum Server capabilities:
  - list clarifications by project
  - create clarification for project
- Minimum stored fields:
  - id
  - project_id
  - author actor / user / organization reference
  - author_role
  - body
  - state
  - created_at
  - updated_at
- Minimum state family:
  - `active`
  - `hidden`
  - `archived`
- Round A commands:
  - create only
- Round A No-Go:
  - hide command
  - archive command
  - edit/delete command
  - moderation workbench

## 4. Project-Bid Private Thread Truth

- Business anchor:
  - `projectId`
  - `bidId`
- Minimum Server capabilities:
  - resolve or materialize thread detail for admitted project-bid relation
  - list messages in detail response
  - send message
- Minimum thread stored fields:
  - id
  - project_id
  - bid_id
  - project_owner_organization_id
  - bidder_organization_id
  - state
  - created_at
  - updated_at
- Minimum state family:
  - `open`
  - `restricted`
  - `archived`
- Round A commands:
  - send message
- Round A No-Go:
  - read receipt
  - typing
  - online presence
  - realtime transport
  - transfer
  - delete/edit message workflow

## 5. Thread Message Truth

- Business anchor:
  - `threadId`
  - `projectId`
  - `bidId`
- Minimum stored fields:
  - id
  - thread_id
  - project_id
  - bid_id
  - sender actor / user / organization reference
  - sender_role
  - body
  - created_at
- Message truth is append-only in Round A.
- Delivery/read state is not admitted.

## 6. Confirmation Card Truth

- Business anchor:
  - `threadId`
  - `projectId`
  - `bidId`
- Minimum confirmation types:
  - `quote`
  - `craft_material`
  - `schedule`
- Minimum stored fields:
  - id
  - thread_id
  - project_id
  - bid_id
  - confirmation_type
  - source_message_id
  - summary
  - creator actor / user / organization reference
  - created_at
- Round A does not admit revoke, void, edit, or confirmation workbench state.
- Later correction is represented by a later confirmation record.

## 7. Attachment Binding Truth

- Round A attachment rows must bind confirmed `FileAssetId` only.
- Server must verify the referenced `FileAsset` exists and is confirmed.
- Server must verify attachment relation matches the target object boundary.
- Server must not expose or store `objectKey` as Round A business truth.
- Upload confirm alone never creates clarification, message, or confirmation
  business truth.

## 8. Permission Truth

- Server owns final permission.
- Project clarification minimum checks:
  - current session is valid
  - project exists and is visible under current project-detail boundary
  - create is allowed only for project owner organization or admitted bidder
    organization under Server rules
- Bid private thread minimum checks:
  - current session is valid
  - project exists
  - bid exists and belongs to the project
  - current organization is either project owner organization or bidder
    organization for the bid
- Confirmation card minimum checks:
  - current actor is an admitted thread participant
  - source message belongs to the same thread

## 9. Audit

Minimum must-audit actions:

- `ProjectClarificationCreated`
- `BidThreadMessageSent`
- `ConfirmationCardCreated`

Audit must be Server-owned and append-only. Failed permission attempts must not
append success audit rows.

## 10. Server No-Go

- No forum module takeover.
- No generic message truth.
- No second upload system.
- No objectKey business truth.
- No BFF-owned or Flutter-owned truth.
- No WebSocket / SSE / push.
- No read receipt / typing / online status.
- No order/contract/dispute full conversation.
- No Admin implementation in Round A.

## 11. Formal Conclusion

- L3 backend truth and persistence boundary is frozen.
- Implementation remains blocked until:
  - Stage 3 total control Go
  - cloud implementation prerequisite gate passes
