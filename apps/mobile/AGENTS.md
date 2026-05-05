# Flutter App AGENTS

## Scope
- Own the Flutter App only.
- Build one shared shell and five building skeletons.
- Consume `BFF` contracts and view models.

## Allowed
- Shell, routing, guards, feature visibility handling
- Presentation, application flow, repository consumption, upload client flow
- Hidden building placeholders for `renovation` and `custom_furniture`
- Messages and profile building skeletons

## Forbidden
- Calling `Server` directly
- Writing business truth, state machines, permissions, or audit rules
- Inventing DTOs, enums, or status semantics outside frozen contracts
- Bypassing upload init or confirm
- Authoring `docs/01_contracts/**`
- Silently swallowing unknown state names, unknown error codes, or unknown critical fields in mapper, consumer, or page logic

## Required Directories
- `lib/shell`
- `lib/features/exhibition`
- `lib/features/renovation`
- `lib/features/custom_furniture`
- `lib/features/messages`
- `lib/features/profile`
- `lib/core`
- `lib/shared`

## File Length and Responsibility Gate
- Default handwritten business source limit: `450` lines per file.
- Warning line: `400`.
- Default handwritten function or method limit: `80` lines.
- Forced-refactor candidate line: `120`.
- One file must keep one primary responsibility.
- Do not mix page widget logic, API client logic, route assembly, and state translation in one oversized file.
- Route registry files and explicit constant maps may follow separate registered rules.
- No exemption is valid unless it is recorded in formal truth.

## Universal Gate Execution
- `docs/00_ssot/gate_register_v1.md` is the canonical gate register.
- Flutter App work may start only after Codex 总控 issues a stage gate checklist and marks the stage as allowed.
- Frontend consumes contracts read-only and must stop on any contract gap.
- Unknown state names, unknown error codes, and unknown critical fields must enter controlled failure or explicit reporting paths; fallback must not hide contract drift.

## Public Capability Reuse
- First registered baseline: commit `6535092 feat: add shared Flutter public capability foundation`.
- Existing pages are not required to migrate all at once. When adding new features, fixing bugs, doing local optimization, or touching related pages, first reuse the registered public capabilities below.
- File opening must prefer `FileOpenCoordinator`. Do not duplicate direct `open_filex` wrappers inside pages.
- Attachment display must prefer `AttachmentTile / FileTile`. Pages may pass actions and display data, but must not make the tile own business attachment truth.
- Money display must prefer `MoneyFormatter`. Do not hand-roll amount formatting in pages.
- Loading / empty / error / retry display must prefer `AppPageStateView` when the page needs a shared state shell.
- Form double-submit protection must prefer `SubmitGuard`. It is frontend click protection only and does not replace backend idempotency.
- Status badge display must prefer `StatusBadgePolicy`. Do not create page-local status badge wording tables unless the state wording is page-private and explicitly not reusable.
- Public capability work must not be used as a reason to modify `BFF`, `Server`, `OpenAPI`, or generated types.

### Public Capability Boundaries
- `FileOpenCoordinator` only coordinates file and external URI opening. It does not own `file/access`, authorization, `objectKey`, or `accessUrl` truth.
- `AttachmentTile / FileTile` only render attachment rows and action entry points. They do not own `FileAsset`, `Evidence`, visibility, deletion, or business binding truth.
- `MoneyFormatter` only formats display amounts. It must not calculate 200 yuan earnest money truth, 4000 yuan bid service fee preauthorization, final platform service fee, membership discount, or payment state.
- `StatusBadgePolicy` only owns display tone and unknown fallback. It must not define a business state machine or introduce new business states.
- `SubmitGuard` only prevents repeated frontend taps while a submit action is running. It must not replace backend idempotency, validation, authorization, or audit.
- `AppPageStateView` only renders loading / empty / error / retry states. It must not swallow real error codes, unknown states, or contract drift.
