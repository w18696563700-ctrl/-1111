---
owner: Codex 总控
status: draft
purpose: Freeze the universal gate register and the mandatory stage gate checklist process.
layer: L0 SSOT
---

# 通用门禁总表 v1

## 适用范围
- This register governs every stage after `Phase 2.1`.
- Codex 总控 must run stage gating before issuing new implementation prompts.
- A failed veto gate blocks the stage directly.

## 执行规则
1. Codex 总控先提交《阶段门禁核查表》。
2. 《阶段门禁核查表》必须逐项回答：
   - 哪些门禁通过
   - 哪些门禁未过
   - 哪些是一票否决
   - 是否允许进入下一阶段
3. Any failed veto item blocks the stage.
4. No stage may be advanced with “close enough” or “fix later” language.

## Gate Table

### 1. 真源门禁
- Canonical authoring truth lives only in the local monorepo root under `docs/`.
- Cloud docs are read-only mirrors only.
- `docs/01_contracts` is authored by Codex 总控 unless an explicit truth patch is delegated.
- Frontend agents consume L2 contracts read-only.
- BFF and Server implementation may not redefine truth in code comments, temp docs, or cloud-only files.
- Veto conditions:
  - second truth root
  - cloud-authored docs drift
  - implementation ahead of unfrozen truth

### 2. 目录洁癖门禁
- `src/` and `lib/` may contain only code, tests, and approved generated outputs.
- `docs/` may contain only formal truth or formal norms with owner, status, and purpose.
- `.tmp/`, `tmp/`, `cache/`, `.cache/`, `exports/`, `artifacts/`, and `logs/` are non-truth only.
- Extracted upstream text copies stay only in `.tmp/input_extracts/`.
- Veto conditions:
  - prompts, screenshots, reports, backups, or input copies in source directories
  - ownerless or layerless docs in `docs/`

### 3. 架构边界门禁
- One shell, five buildings remain unchanged.
- First release exposes only `exhibition`, `messages`, and `profile`.
- `renovation` and `custom_furniture` must remain real but hidden.
- Flutter App only talks to BFF.
- Admin uses controlled Server Admin APIs directly.
- BFF does aggregation only and never owns business truth.
- Server owns business truth and state transitions.
- Veto conditions:
  - Flutter App direct-to-Server calls
  - BFF persistent truth or second state machine
  - hidden buildings removed from architecture

### 4. 契约门禁
- External app-facing paths must use canonical paths only.
- New fields, query params, and response semantics must be frozen in `docs/01_contracts/*.yaml` before implementation.
- No new implementation may force clients to consume `/api/app/bff/*`.
- Unknown critical fields may not be silently swallowed by mappers, consumers, or service adapters when they are required for the current stage objective.
- Unknown error codes may not be silently converted into apparent success.
- Veto conditions:
  - guessed fields
  - contract-first order broken
  - canonical path drift

### 5. 状态机门禁
- Complete canonical states remain defined in `docs/00_ssot/lifecycle_state_machine.md`.
- Clients may consume only the stage-approved minimal state subset.
- BFF may not define or persist state progression.
- Server state transitions must stay in domain or application entry points.
- Veto conditions:
  - client-invented transitions
  - controller-level state progression
  - BFF state machine drift

### 6. 数据与上传门禁
- PostgreSQL remains the business truth store.
- File upload is always `init -> direct upload -> confirm`.
- `objectKey` is never business truth.
- `FileAsset` and `Evidence` are the file truth carriers.
- Snapshot-bearing instances freeze template, rule, permission, and inspection context at instance creation.
- Veto conditions:
  - skipping upload confirm
  - treating `objectKey` as truth
  - mutable historical snapshots

### 7. 前端体验门禁
- Happy path must not rely on hand-entered IDs.
- Missing IDs must enter controlled states, not fake content.
- Error states must map to frozen page-state and upload-state names only.
- No fake success to hide backend gaps.
- First-release information architecture stays stable.
- Unknown state names, unknown error codes, and unknown critical fields must enter controlled failure or explicit reporting paths.
- Fallbacks may not hide contract drift.
- Veto conditions:
  - debug path promoted to main path
  - fake success or fake detail rendering
  - hidden building strategy broken

### 8. 审计门禁
- High-risk actions require append-only audit records.
- Required fields and must-audit actions follow `docs/02_backend/audit_log_spec.md`.
- Audit attribution is required for user, admin, and automated actions.
- Veto conditions:
  - missing audit on required action
  - missing required audit fields
  - mutable audit records

### 9. 云上运行门禁
- Cloud host runs BFF and Server via release directories, not source working directories.
- `current` symlinks must point to release directories.
- `health/live` and `health/ready` must pass.
- Nginx canonical paths must remain stable.
- Every smoke or happy path run must start from a new `Project`.
- Every smoke run must generate a new submit-able milestone chain.
- Veto conditions:
  - current symlink points to workspace source
  - services unhealthy
  - cloud-only truth drift
  - reuse of historical project/order chains for acceptance

### 10. 阶段控制门禁
- Every stage needs a single objective, explicit non-goals, allowed directories, and frozen truth inputs.
- Codex 总控 must submit a stage gate checklist before agent prompts.
- Backend-first / frontend-later sequencing applies whenever contract or canonical path truth is being introduced or changed.
- Veto conditions:
  - stage objective drift
  - parallel guessing of fields, states, or error codes
  - new prompts issued before gate checklist approval

### 11. 文件长度与职责门禁
- Default handwritten business source limit: `450` lines per file.
- Warning line: `400`.
- Default handwritten function or method limit: `80` lines.
- Forced-refactor candidate line: `120`.
- One file may carry one primary responsibility only.
- Exempt or separately governed file classes:
  - generated code
  - migrations
  - generated schema or OpenAPI outputs
  - fixtures, seeds, and mock data
  - localization copy
  - route registry files
  - explicitly registered constant lookup tables
- Every exception must be recorded in formal truth.
- Mechanical splitting that worsens responsibility boundaries still fails.
- Veto conditions:
  - handwritten source file `>= 450` lines
  - hidden multi-layer responsibility mixing
  - verbal-only exemption

## 阶段门禁核查表要求
- Codex 总控 must submit this checklist before every new stage prompt bundle.
- The checklist must answer:
  - passed gates
  - failed gates
  - veto gates
  - stage go / no-go decision
- If any veto gate fails, the checklist result is `No-Go`.
