---
owner: Codex 总控
status: draft
purpose: Record Day 8.1 UAT patch for ordinary file attachment and App-local contact soft prompt verification.
layer: L0 SSOT
---

# Project Conversation Workbench V1 Day 8.1 UAT Patch Receipt

## Scope

This is a UAT-only patch receipt. It does not change code, contracts, database schema, release pointers, or cloud runtime.

The patch closes the two Day 8 residual verification gaps:

- Ordinary `file` attachment end-to-end UAT.
- Contact soft prompt visual UAT.

## Runtime Boundary

| Item | Result |
| --- | --- |
| Code changes | None |
| Contract changes | None |
| Server / BFF release switch | None |
| DB migration | None |
| Cloud service restart | None |
| Existing runtime retained | `20260501013500-project-conversation-workbench-v1` |

## Ordinary File Attachment UAT

The UAT used the two user-provided test accounts. Passwords and tokens are intentionally not recorded.

| Item | Result |
| --- | --- |
| Run marker | `day8_1_file_1777572878719` |
| Project id | `6883586a-c8a3-47f4-aded-96450fe8c3fe` |
| Thread id | `8039f87b-e735-49fd-98d5-21b7c55c300b` |
| Test file name | `day8_1_file_1777572878719.txt` |
| MIME type | `text/plain` |
| Size | `184` bytes |
| SHA-256 | `6b7e2906a9a052457866dd94931e64091790202f78fffd7fac98bb5958da76e4` |
| Upload kind | `project_communication_attachment` |
| Upload init | `200` |
| Direct upload | `200` |
| Upload confirm | `200` |
| Confirmed fileAssetId | `9afe012e-4e4c-4ce5-bbbd-a12da2fcd348` |
| Send file message | `202` |
| File message id | `fa698cdd-eec2-43c8-a57c-d564e68128a9` |
| Counterpart read | `200` |
| Counterpart observed messageKind | `file` |
| Counterpart observed fileAssetId | `9afe012e-4e4c-4ce5-bbbd-a12da2fcd348` |
| Counterpart observed anchor | Same `projectId + threadId` |

Conclusion: ordinary file attachment completed the real `init -> direct upload -> confirm -> send file message -> counterpart read` chain.

## Contact Soft Prompt Visual UAT

Visual evidence:

- `docs/00_ssot/evidence/20260501013500-project-conversation-workbench-v1-day8-1-contact-soft-prompt.png`

Observed result:

| Step | Result |
| --- | --- |
| App opened local macOS build against current cloud runtime | Passed |
| Test account logged in | Passed |
| Entered project communication page | Passed |
| Entered contact-like content in composer | Passed |
| Tapped send | Soft prompt appeared before send |
| Prompt title | `建议优先在平台内继续沟通` |
| Prompt body | `平台内沟通更便于留存关键记录，报价、材质、排期等事项建议优先保留在项目沟通中。` |
| Prompt actions | `返回修改` and `继续发送` |
| Chosen action | `返回修改` |
| Contact-like content sent | No |

Conclusion: contact handling remains App-local soft prompting. It does not block, punish, or create Server governance.

## Cleanup

- The local temporary UAT file under `.tmp/uat/` was deleted after this receipt was recorded.
- The uploaded cloud file and file message remain in the test project/thread as UAT evidence.
- The local macOS App process was shut down after screenshot capture. No local `flutter run` / `frontend_server` / `mobile.app` process remained from this UAT patch.

## Go / No-Go Update

The Day 8 residual verification gaps are closed.

Updated bounded-scope completion estimate: `98% - 100%`.

This does not open:

- Generic IM.
- System push, sound, vibration, lock-screen notification, or complex notification settings.
- Confirmation-card connection to order, contract, fulfillment, payment, or settlement state machines.
