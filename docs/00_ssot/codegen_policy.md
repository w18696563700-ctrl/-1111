---
owner: Codex 总控
status: draft
purpose: Freeze where generated code may live and what the primary truth source must be.
layer: L0 SSOT
---

# Codegen Policy

## Universal Gate Adoption
- `docs/00_ssot/gate_register_v1.md` is the canonical universal gate register.
- This policy owns the generated-output branch of the directory hygiene gate and the file-length gate exemptions for generated artifacts.
- Generated outputs may not be used to bypass truth-first, responsibility, or file-length rules for handwritten code.

## Primary Rule
- Generated code is never the primary truth.
- Truth starts in:
  - `docs/01_contracts/*.yaml`
  - selected SSOT docs in `docs/00_ssot`, `docs/02_backend`, `docs/03_bff`, `docs/04_frontend`, and `docs/05_admin`

## Check-in Rule
- Generated code is not committed by default.
- Local and CI generation is allowed.
- Check-in is whitelist-only.

## Whitelist Exceptions
- Deterministic Flutter generator outputs may be committed when required by the toolchain, for example:
  - `*.g.dart`
  - `*.freezed.dart`
- Each exception must remain controlled by this policy and tied to authored truth upstream.

## Allowed Generated Targets
- local or CI outputs outside git by default
- `packages/contracts/**` only when a reviewed exception is approved
- explicit app-local `generated/` directories only if introduced later with owner approval
- deterministic Flutter outputs only when covered by the whitelist rule above

## Forbidden Generated Targets
- root directory
- random feature folders
- mixed placement inside `src/` or `lib/` without a clear `generated/` segment

## Line-count Gate Interaction
- Generated code is not governed by the default handwritten source hard gate of `450` lines per file.
- Generated schema or OpenAPI projection outputs are not governed by the default handwritten source hard gate.
- Fixtures, seeds, mock data, localization copy, route registry files, and explicitly registered constant lookup tables may follow separate size rules when registered in formal truth.
- Handwritten wrapper files around generated output remain governed by the handwritten source gate.
- Exemptions must be recorded in:
  - `docs/00_ssot/repo_cleanliness_constitution.md`
  - the relevant layer SSOT or contract truth file when a file class needs a separate rule
- Generated output must never be split or retained in a way that obscures ownership or makes handwritten responsibilities less clear.

## Retention Rule
- A generated file may remain in the repo only when:
  - the generator owner is known
  - the regeneration path is documented
  - the upstream truth file is identified
  - the file is allowed by the whitelist or an explicit reviewed exception
- Otherwise it must be gitignored or moved to temp storage.

## Cross-layer Change Order
1. Edit truth docs.
2. Review contracts and specs.
3. Run generation into approved targets.
4. Consume generated outputs in implementation.
