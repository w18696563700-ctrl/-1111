---
owner: Codex 总控
status: draft
purpose: Freeze repository hygiene, allowed directory contents, and anti-pollution rules.
layer: L0 SSOT
---

# Repo Cleanliness Constitution

## Universal Gate Adoption
- `docs/00_ssot/gate_register_v1.md` is the canonical universal gate register.
- This constitution owns the directory hygiene gate and the handwritten file-length and responsibility gate.
- No stage may bypass these gates through verbal exceptions.

## `src/` and `lib/` Rules
- Allowed:
  - business code
  - tests
  - explicitly scoped generated code under a clear `generated/` directory
- Forbidden:
  - `.docx`, `.txt`, `.pdf` input copies
  - prompt transcripts
  - temporary analysis reports
  - exported screenshots
  - manual backup files
  - meeting notes
  - ownerless drafts

## File Length and Responsibility Gate
- Default hard gate for handwritten business source files:
  - warning line: `400`
  - blocking line: `450`
- Default hard gate for handwritten functions and methods:
  - warning line: `80`
  - forced-refactor candidate line: `120`
- A single handwritten business source file must carry one primary responsibility only.
- Forbidden responsibility mixing examples:
  - controller + service
  - controller + mapper
  - service + state machine
  - state machine + audit writer
  - controller + audit writer
- Mechanical splitting that only hides line counts while making responsibilities less clear does not pass review.
- Default exempt or separately governed file classes:
  - generated code
  - migrations
  - generated schema or OpenAPI outputs
  - fixtures, seeds, and mock data
  - localization copy
  - route registry files
  - explicitly registered constant lookup tables
- Every exemption must be recorded in formal truth and may not be granted verbally.

## `docs/` Rules
- `docs/` stores formal truth or formal engineering norms only.
- Every file in `docs/` must declare:
  - `owner`
  - `status`
  - `purpose`
- File names must be stable and canonical.
- Forbidden naming patterns:
  - `final_v2`
  - `final_v3`
  - `最终版2`
  - `最新最新版`
- Loose drafts without a layer or owner are forbidden.

## Temp and Export Rules
- Ignored temp-only paths:
  - `.tmp/`
  - `tmp/`
  - `cache/`
  - `.cache/`
  - `exports/`
  - `artifacts/`
  - `logs/`
- These paths are not part of formal truth and are not valid citation targets.

## Generated Artifact Rules
- Default policy: do not commit generated output.
- Allowed to retain only when tied to a clear generation path and owner:
  - `packages/contracts/**`
  - explicit `generated/` subdirectories under app source trees
  - deterministic Flutter outputs allowed by `codegen_policy.md`
- Forbidden:
  - generated output mixed into arbitrary feature directories
  - generated files without regeneration instructions
  - generated outputs that become de facto truth

## Input-copy Rule
- Extracted text copies of upstream source documents are not formal truth.
- They must stay in ignored temp space only, currently `.tmp/input_extracts/`.
- They must never be mixed into `docs/`, `apps/`, `packages/`, or `infra/`.

## Cross-layer Change Order
1. Fix or add the truth doc in `docs/`.
2. Adjust package projection rules if needed.
3. Update implementation under `apps/`.
4. Regenerate outputs only into approved generated locations.
