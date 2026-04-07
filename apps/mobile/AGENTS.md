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
