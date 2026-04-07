---
title: Forum Report P0 AGENTS Length Gate Correction Review
status: reviewed
owner: Control
scope: implementation-correction-review
created_at: 2026-04-07
---

# Forum Report P0 AGENTS Length Gate Correction Review

## A. Current Review Object

This review covers the `Forum Report P0 AGENTS length gate correction`.

This correction only targets the BFF forum error-normalization file-length / responsibility gate.

It does not open:

- `Block P0`
- `Admin Review P0`
- AI runtime
- OCR / QR detection
- forum precheck
- automatic hide or takedown
- penalty / appeal
- payment / billing / V2.3
- release-prep / launch approval

## B. Changed Files

The correction touched only BFF forum module files:

- `apps/bff/src/routes/forum/forum-command-error.service.ts`
- `apps/bff/src/routes/forum/forum-command-error.types.ts`
- `apps/bff/src/routes/forum/forum-draft-command-error-message.service.ts`
- `apps/bff/src/routes/forum/forum-report-command-error-message.service.ts`
- `apps/bff/src/routes/forum/forum-interaction-command-error-message.service.ts`
- `apps/bff/src/routes/forum/forum-own-post-command-error-message.service.ts`
- `apps/bff/src/routes/forum/forum.module.ts`

No Server, Flutter, Admin, docs-before-review, Forum Report runtime scope, Block P0, Admin Review P0, AI, OCR, QR, penalty, or appeal implementation was opened.

## C. Split Responsibility Map

| File | Responsibility |
| --- | --- |
| `forum-command-error.service.ts` | Facade that normalizes upstream errors through `ErrorNormalizerService`, delegates message translation, and preserves the existing public API. |
| `forum-command-error.types.ts` | Shared type aliases for forum interaction / own-post error surfaces. |
| `forum-draft-command-error-message.service.ts` | Draft-save, publish, and draft-open user-facing message translation. |
| `forum-report-command-error-message.service.ts` | Forum report-submit user-facing message translation. |
| `forum-interaction-command-error-message.service.ts` | Forum comment / like / bookmark read-write interaction message translation. |
| `forum-own-post-command-error-message.service.ts` | Own-post list/edit/delete message translation. |
| `forum.module.ts` | DI registration for the split translator services. |

The split preserves a single BFF error-normalization facade and moves message tables / branch translation into smaller responsibility-focused services.

## D. Line Count Proof

Post-correction line counts:

| File | Lines |
| --- | ---: |
| `forum.service.ts` | `407` |
| `forum-own-post-continuity.service.ts` | `228` |
| `forum-author-profile.service.ts` | `186` |
| `forum-command-error.service.ts` | `175` |
| `forum-interaction-command-error-message.service.ts` | `153` |
| `forum-draft-delete.service.ts` | `132` |
| `forum-command-context.service.ts` | `120` |
| `forum-draft-command-error-message.service.ts` | `114` |
| `forum-draft-open.service.ts` | `105` |
| `forum-own-post-command-error-message.service.ts` | `79` |
| `forum-publish-result.service.ts` | `64` |
| `forum.controller.ts` | `61` |
| `app-forum.controller.ts` | `61` |
| `forum-report-command-error-message.service.ts` | `44` |
| `forum.module.ts` | `28` |
| `forum-command-error.types.ts` | `3` |

No checked handwritten BFF forum source file remains above the root AGENTS hard gate of `450` lines.

## E. Retained Behavior

This correction retains:

- existing BFF public API on `ForumCommandErrorService`
- existing BFF forum routes
- existing app-facing error codes
- existing user-facing Chinese message semantics
- existing response body shape from the normalizer
- BFF as forwarding / shaping layer only

It does not add business truth, state machines, report decisions, AI runtime, takedown actions, penalty, or appeal behavior.

## F. Verification

Verification performed:

- line-count check for `apps/bff/src/routes/forum/*.ts`
- provider registration check in `forum.module.ts`
- `cd apps/bff && npm run build`

Result:

- BFF build passed.
- Line gate passed.

## G. Review Decision

`Forum Report P0 AGENTS length gate correction`: PASS at local source / build level.

The previous local BFF AGENTS length-gate blocker around `forum-command-error.service.ts` is closed.

This is not yet final `Forum Report P0` completion because the current cloud active BFF artifact still needs to be aligned to the split source and the final active-ingress rerun still needs to confirm behavior after deployment.

## H. Remaining Blockers

Remaining blockers before final `Forum Report P0` package signoff:

1. Cloud BFF artifact must be aligned to the split BFF source.
2. Active ingress must be rerun after BFF artifact alignment.
3. `CS-013` minimum report viewing boundary must be explicitly adjudicated in the final Forum Report review: either count only the Server read-model preparation as sufficient for this package, with Admin UI deferred to `Admin Review P0`, or keep final package signoff pending.

## I. Next Unique Action

`Forum Report P0 final cloud artifact alignment and result verification rerun`

This next action may only:

- deploy / align the current BFF artifact containing the length-gate split
- rerun cloud nginx `:80 -> BFF :3000 -> Server :3001`
- verify post / comment report submit still works
- verify ticket / snapshot / audit carriers
- verify AI runtime remains absent
- explicitly decide the `CS-013` viewing-boundary status

It must not open:

- `Block P0`
- `Admin Review P0`
- AI runtime
- OCR / QR detection
- precheck
- automatic takedown
- penalty / appeal
- release-prep / launch approval

