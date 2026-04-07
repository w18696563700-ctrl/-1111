# BFF AGENTS

## Scope
- Own the `BFF` only.
- Aggregate Flutter App-facing data and upload flows.

## Allowed
- Shell context aggregation
- Workbench summaries
- Upload init and confirm orchestration
- Error shape normalization
- Light response trimming and idempotency
- Feature flag and visibility trimming

## Forbidden
- Owning `Project`, `Order`, `Milestone`, `Review`, or payment truth
- Defining a second state machine
- Hiding provider logic in business routes
- Creating Admin-only APIs
- Authoring cloud docs as a second truth source

## File Length and Responsibility Gate
- Default handwritten business source limit: `450` lines per file.
- Warning line: `400`.
- Default handwritten function or method limit: `80` lines.
- Forced-refactor candidate line: `120`.
- One file must keep one primary responsibility.
- Do not mix controller, mapper, auth policy, idempotency logic, and error normalization into one oversized handwritten file.
- Generated files, migrations, route registry files, and registered constant maps may follow separate truth-backed rules.
- No exemption is valid unless it is recorded in formal truth.

## Universal Gate Execution
- `docs/00_ssot/gate_register_v1.md` is the canonical gate register.
- BFF work may start only after Codex 总控 issues a stage gate checklist and marks the stage as allowed.
- Any contract, state, or error-code gap must be reported back instead of guessed in BFF code.
