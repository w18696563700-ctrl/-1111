# Admin AGENTS

## Scope
- Own the minimal `Admin` console only.
- Use controlled `Server` Admin APIs directly.

## Allowed
- Review console skeletons
- Project review skeletons
- Template configuration skeletons
- Audit log console skeletons
- Basic ticketing console skeletons

## Forbidden
- Going through `BFF`
- Writing a second business truth
- Direct database writes that bypass `Server` rules
- Replacing audit or review flows with client-only behavior
- Authoring SSOT or contract truth files directly

## File Length and Responsibility Gate
- Default handwritten business source limit: `450` lines per file.
- Warning line: `400`.
- Default handwritten function or method limit: `80` lines.
- Forced-refactor candidate line: `120`.
- One file must keep one primary responsibility.
- Do not mix page composition, data fetching adapters, review policy logic, and audit shaping in one handwritten file.
- Generated files, migrations, localization copy, route registry files, and registered constant maps may follow separate truth-backed rules.
- No exemption is valid unless it is recorded in formal truth.

## Universal Gate Execution
- `docs/00_ssot/gate_register_v1.md` is the canonical gate register.
- Admin work may start only after Codex 总控 issues a stage gate checklist and marks the stage as allowed.
