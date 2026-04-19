---
owner: Codex 总控
status: frozen
purpose: Freeze the BFF runtime artifact baseline required by enterprise display field alignment V1 revision so that Gate 4 release retries do not omit generated contracts runtime dependencies.
layer: L3 BFF
freeze_date_local: 2026-04-18
inputs_canonical:
  - docs/00_ssot/enterprise_display_field_alignment_v1_revision_bff_runtime_artifact_baseline_stage_gate_checklist_addendum.md
  - apps/bff/src/shared/contracts.ts
  - apps/bff/dist/apps/bff/src/shared/contracts.js
---

# Enterprise Display Field Alignment V1 Revision BFF Runtime Artifact Baseline

## 1. Observed Runtime Fact

- Active BFF runtime resolves generated contract modules from:
  - `dist/packages/contracts/src/generated/app-api.types.js`
  - `dist/packages/contracts/src/generated/error-codes.js`
- `dist/apps/bff/src/shared/contracts.js` requires these modules through relative runtime paths.

## 2. Root Cause Of The Gate 4 Failure

- The failed Gate 4 retry copied only the `apps/bff` subtree into the new release.
- That omitted the sibling runtime subtree:
  - `packages/contracts`
- After current switch, BFF started from:
  - `dist/apps/bff/src/main.js`
- Node then failed when `shared/contracts.js` required generated contract modules that were no longer present inside the new release root.

## 3. Frozen Baseline

- A valid BFF runtime release artifact must preserve the release-root structure, not just `apps/bff`.
- Minimum required carrying shape:
  - `<release-root>/apps/bff/**`
  - `<release-root>/packages/contracts/src/generated/**`
- For this ticket family, a bounded runtime release may update only:
  - `apps/bff/dist/apps/bff/src/routes/enterprise_hub/enterprise-hub.read-model.*`
  - any directly corresponding source/test files used for artifact verification
- But it must not drop the existing runtime-generated contracts subtree.

## 4. Allowed Repair Strategy

- Copy the whole active BFF release root to a new release root.
- Keep `packages/contracts` intact.
- Overlay only the enterprise-hub bounded runtime files.
- Rebuild inside the preserved release-root shape when possible.
- If source rebuild is skipped, runtime carrying files must still be updated in-place under the preserved root.

## 5. Forbidden Strategy

- Do not copy only `apps/bff` into a fresh release root.
- Do not re-point runtime requires to ad-hoc absolute paths.
- Do not patch business code to hide missing generated-contract runtime files.

## 6. Retry Admission Rule

- Gate 4 may be retried only after the new release root satisfies:
  - `dist/apps/bff/src/main.js` exists
  - `dist/apps/bff/src/shared/contracts.js` exists
  - `dist/packages/contracts/src/generated/app-api.types.js` exists
  - `dist/packages/contracts/src/generated/error-codes.js` exists
