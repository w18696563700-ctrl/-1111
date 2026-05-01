---
owner: Codex 总控
status: accepted
purpose: Submit Day-1 stage gate checklist for Project Conversation Workbench V1 construction truth and contracts.
layer: L0 SSOT
---

# 《项目沟通工作台 V1 Day-1 阶段门禁核查表》

## 1. Gate Result

Day-1 gate result: Pass for entering Day 2 Server data-model and migration planning.

## 2. Passed Gates

| Gate | Result | Evidence |
| --- | --- | --- |
| L0 truth freeze | Pass | `docs/00_ssot/project_conversation_workbench_v1_truth_freeze_addendum.md` |
| L2 contract freeze | Pass | `docs/01_contracts/project_conversation_workbench_v1_contract_addendum.md` |
| Project/thread binding | Pass | All message types remain bound to `projectId + threadId`. |
| Message type whitelist | Pass | `text`, `image`, `file`, `confirmation_card`. |
| Confirmation type whitelist | Pass | `quote`, `material_process`, `schedule`. |
| FileAsset truth | Pass | Attachments/images must bind `fileAssetId`; `objectKey` is not App business truth. |
| Dedicated upload kind | Pass | Project communication files use `project_communication_attachment`; do not reuse project album or owner-private project attachment semantics. |
| Upload flow reuse | Pass | Reuse existing `init -> direct upload -> confirm`. |
| App soft reminder boundary | Pass | Contact prompt is App-local; no blocking, punishment, or Server governance in V1. |
| BFF responsibility | Pass | BFF validates shape and forwards; it does not own business truth. |
| Flutter scope | Pass | Workbench UI and client interactions only; bottom tab structure stays unchanged. |

## 3. Veto Gates

| Veto Gate | Status |
| --- | --- |
| Generic IM expansion | Not triggered |
| Message building total frame chat | Not triggered |
| System push / sound / vibration / lock-screen notification | Not triggered |
| Confirmation card mutates order/contract/fulfillment state | Not triggered |
| OSS `objectKey` exposed as project communication truth | Not triggered |
| Server-side contact blocking or punishment | Not triggered |

## 4. Known Implementation Checks For Day 2

Day-2 Server work must first verify the live entity and migration state:

- `project_communication_messages` already has `message_kind` and `body`.
- It does not currently carry a structured `payload` column.
- The lowest-risk likely migration is adding nullable JSON payload storage while preserving existing text rows.
- No new upload table is allowed.
- No new message thread table is allowed.

## 5. Allowed Day-2 Work

Day 2 may proceed only with:

1. Server data-model inspection.
2. Minimal migration if required for message payload.
3. Entity and presenter extension for `payload`.
4. Targeted Server tests for old text compatibility and new payload storage.

## 6. Blocked Day-2 Work

Day 2 must not implement:

- Flutter UI
- BFF App route changes
- cloud runtime alignment
- confirmation-card state workflow
- file online preview
- contact governance
- notification system

## 7. Next Stage Decision

Allowed to enter Day 2: Yes.

Reason: construction truth, App-facing contracts, and implementation veto boundaries are now formally frozen.
