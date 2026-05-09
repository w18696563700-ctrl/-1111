---
owner: Codex 总控
status: frozen
purpose: Freeze the small reopening boundary for bid-submission attachment access, bidder material supplement return-loop, and project-communication material sheet selection behavior.
layer: L0 SSOT
freeze_scope: Minimal reopening only; no OpenAPI/generated changes and no business state-machine expansion.
---

# Bid Submission Attachment And Material Review Return Loop Reopening Addendum

## 1. Verdict

This reopening is allowed only as a bounded repair for three already-admitted project-communication surfaces:

1. `竞标摘要 -> 查看附件` must be able to open the three submitted bid attachments through the existing app-facing `file/access` surface.
2. `bid_materials + needs_supplement` must provide the bidder with a controlled return path to the existing bid-submit page.
3. The project-communication `资料确认单` tool entry must open a bottom sheet selection list before entering a material review detail.

This reopening does not create a new contract path, does not modify generated types, and does not create a second material-review truth in Flutter or BFF.

## 2. Current Minimum Loop

| Surface | Minimum repair | Truth owner |
| --- | --- | --- |
| Bid submission snapshot attachments | Existing `/api/app/file/access` can resolve `bid_project_understanding`, `bid_quote_sheet`, and `bid_schedule_plan` FileAssets for the publisher or the owning bidder. | Server `Bid` + `FileAsset` |
| Bid material supplement return-loop | Bidder seeing `needs_supplement` can return to the existing bid-submit page to replace or resubmit bid materials. | Server bid submission truth |
| Material confirmation entry | The `资料确认单` tool opens a bottom sheet list first; detail review remains the existing material-review page. | Server workbench entries |

## 3. Boundaries

- `/api/app/file/access` remains the only app-facing file access path for this repair.
- BFF may continue to forward `fileAssetId`, `mode`, `projectId`, and `accessScope`; it must not calculate bid attachment permissions.
- Server must verify that the requested FileAsset is one of the three FileAsset ids persisted on the target `Bid`.
- Server must allow only the publisher organization for the project or the bidder organization that owns the bid.
- Flutter must not infer `reviewState`, `actionState`, or badge state.
- Flutter may route the bidder back to the existing bid-submit page when a bid material entry is `needs_supplement`; slot-level focus is a later enhancement.
- The material-review detail page is not converted into a bottom sheet in this repair.

## 4. Non-Goals

- No new OpenAPI path or schema.
- No generated contract update.
- No payment, service-fee, wallet, invoice, settlement, bid-award, order, contract amount, or deal-confirmation change.
- No generic IM expansion.
- No new bid resubmission state machine.
- No objectKey exposure to Flutter or BFF responses.

## 5. Acceptance

- `GET /api/app/file/access?fileAssetId=<bid material fileAssetId>&mode=preview` returns a short-lived `accessUrl` for the publisher and owning bidder.
- Unrelated organizations are rejected before URL signing.
- Missing or drifted FileAsset/Bid truth is rejected before URL signing.
- `项目理解确认（需补充）` for a bidder shows `去补充竞标资料` and returns to the existing bid-submit page.
- `资料确认单` opens a bottom sheet list first and does not inline-expand inside the tool bar.
