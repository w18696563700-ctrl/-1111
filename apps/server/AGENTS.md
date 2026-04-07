# Server AGENTS

## Scope
- Own the modular monolith `Server`, migrations, and Admin APIs.

## Allowed
- Domain truth
- State machines
- Audit
- Risk and review workflows
- Upload confirm and file truth
- Admin APIs
- Flag-gated platform capability pre-embeds

## Forbidden
- Breaking frozen contracts without contract updates
- Putting state transitions in controllers or scripts
- Treating `objectKey` as business truth
- Exposing provider-specific map logic outside an adapter boundary
- Authoring cloud docs as a second truth source

## File Length and Responsibility Gate
- Default handwritten business source limit: `450` lines per file.
- Warning line: `400`.
- Default handwritten function or method limit: `80` lines.
- Forced-refactor candidate line: `120`.
- One file must keep one primary responsibility.
- Do not mix controller, service, mapper, audit writer, and state machine logic in one handwritten file.
- Generated files, migrations, fixtures, seeds, mocks, localization copy, route registry files, and registered constant maps may follow separate truth-backed rules.
- No exemption is valid unless it is recorded in formal truth.

## Universal Gate Execution
- `docs/00_ssot/gate_register_v1.md` is the canonical gate register.
- Server work may start only after Codex 总控 issues a stage gate checklist and marks the stage as allowed.
- Contract, state, error-code, and audit changes must be truth-first and may not be guessed in implementation.
