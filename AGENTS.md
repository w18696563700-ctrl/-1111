# Root AGENTS

## 0. Purpose

This is the root rule file for Codex work in this repository. It defines durable project boundaries, truth hierarchy, execution gates, command safety, and cross-layer responsibilities.

The project is a platform-level app: `展览装修之家 / 展览定制之家`.

It is not a demo, not a pure frontend prototype, and not a one-off script repository. The default goal is to protect the smallest shippable loop, stage gates, frozen truth docs, contract consistency, and runtime verification.

## 1. Repository Scope

- This monorepo contains `Flutter App`, `Admin`, `BFF`, `Server`, tooling packages, SSOT docs, contracts, generated contract types, and infra baselines.
- `Flutter App` is the only mobile client.
- `Admin` is a minimal operations console and uses controlled `Server` Admin APIs, not `BFF`.
- `BFF` is the only app-facing aggregation layer.
- `Server` is the only business truth owner.

## 2. Current Runtime Truth

- Flutter / App frontend: local development and local debugging.
- Admin frontend: local development and local debugging.
- BFF: deployed on Alibaba Cloud.
- Server / backend: deployed on Alibaba Cloud.
- Cloud active runtime takes precedence over local inference for any runtime claim.
- Do not assume local `apps/bff` or local `apps/server` is the active runtime.
- Default local tunnel to cloud:
  - `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`
- Default local integration base URL:
  - `http://127.0.0.1:8080`
- Default read-only health checks:
  - `curl -i http://127.0.0.1:8080/health/bff/live`
  - `curl -i http://127.0.0.1:8080/health/server/live`

Runtime rules:

- A local controller, service, route, test, or generated type does not prove cloud availability.
- Cloud availability must be verified by current health, active artifact, process path, or endpoint smoke evidence.
- If the tunnel is unavailable, mark cloud runtime as `未验证` or `Cloud Runtime Unknown`; do not infer success from local code.

## 3. Frozen Stack

- Flutter App: Flutter
- Admin: Next.js
- BFF: NestJS
- Server: NestJS modular monolith
- Database: PostgreSQL
- Cache / idempotency / queue: Redis
- Object storage: S3-compatible OSS, MinIO for dev and test
- Reverse proxy: Nginx
- Cloud shape: one host, separate BFF / Server / Admin processes, Nginx in front

## 4. Truth Layers

Always distinguish these layers:

1. SSOT docs
2. OpenAPI contracts
3. Generated types
4. Local source code
5. Cloud active runtime
6. Test mock / visual demo / test doubles
7. Temporary receipt / candidate / dispatch bundle / `.tmp` artifact

Product / business truth priority:

1. Frozen SSOT
2. OpenAPI
3. generated types
4. source code

Runtime availability truth priority:

1. current cloud runtime smoke
2. active artifact / process path
3. Nginx upstream / deployment evidence
4. local source code only as supporting evidence

Hard rules:

- SSOT docs define product and business truth only when frozen and registered by the current source-of-truth chain.
- OpenAPI / generated types define interface contracts; they do not prove runtime availability.
- Local code existence does not prove cloud deployment.
- When judging whether something is online or cloud-available, cloud runtime evidence takes precedence over local source code.
- Doc existence does not prove implementation completion.
- Receipt existence does not prove runtime pass.
- Mock, fake transport, visual demo, and test doubles cannot be used as evidence that a real feature is complete.
- `.tmp`, release artifacts, rollback notes, candidate docs, and dispatch bundles are not long-term truth.
- Tests and receipts are supporting evidence only.

## 5. Non-Negotiable Product Rules

- One shell, five buildings: `exhibition`, `renovation`, `custom_furniture`, `messages`, `profile`.
- First release exposes only `exhibition`, `messages`, and `profile`.
- `renovation` and `custom_furniture` stay pre-embedded and hidden until separately frozen.
- `Flutter App` only talks to `BFF`.
- `Admin` only talks to controlled `Server` Admin APIs.
- `BFF` never owns business truth or a second state machine.
- `Server` owns business truth, state machines, audit, review, risk, governance, permissions, and admin APIs.
- File upload is always a three-step flow: init -> direct upload -> confirm.
- `objectKey` is never business truth; `FileAsset` and `Evidence` are.
- Template, rule, permission, inspection, and state snapshots freeze on instance creation.
- Live, geo, and map capabilities are platform pre-embeds only in Phase 0 and stay flag-off by default unless separately unlocked.

## 6. Mandatory Stage Gates

Every task must pass the relevant gates before implementation. Do not skip gates because a file or API appears to already exist.

### Gate 0: Read-Only Scan

Input:

- User task
- Current worktree state
- Relevant AGENTS files
- Relevant SSOT / contracts / source paths

Output:

- What exists
- What is missing
- Current dirty worktree risk
- Whether this stage only needs docs, contracts, frontend, BFF, Server, Admin, runtime, or a combination
- Go / No-Go decision

No-Go conditions:

- Required truth source is missing
- User asks for implementation but gate requires frozen docs first
- Runtime must be verified but tunnel or health is unavailable
- Scope would require forbidden file changes
- Sensitive information would need to be exposed

### Gate 1: Truth And Contract Freeze

Input:

- Current SSOT
- `docs/01_contracts/openapi.yaml`
- Generated contract expectations
- Existing code and runtime evidence only as verification

Output:

- Frozen SSOT addendum or confirmation
- Contract update or confirmation
- Explicit interface names, paths, states, enums, and boundaries
- No-Go list for implementation

No-Go conditions:

- Business truth is ambiguous
- Contract names conflict
- New state, path, enum, or query parameter is introduced without contract freeze
- Payment, wallet, deposit, settlement, or credit semantics are requested without separate freeze

### Gate 2: Implementation

Input:

- Gate 1 pass
- File scope
- Allowed commands
- Existing dirty worktree risk

Output:

- Minimal code changes
- No unrelated formatting
- No unrelated cleanup
- No forbidden layer bypass

No-Go conditions:

- Required files are outside allowed scope
- Implementation would create second truth in Flutter, Admin, or BFF
- Implementation would require database write, migration, deployment, or runtime restart without explicit approval

### Gate 3: Independent Verification

Input:

- Changed files
- Relevant tests
- Relevant contract checks
- Relevant static checks

Output:

- Commands run
- Results
- Failures and residual risk

No-Go conditions:

- Tests cannot run and no reason is reported
- Failures are hidden or reframed as success
- Local tests are used to claim cloud runtime pass

### Gate 4: Runtime / Integration Receipt

Input:

- Current tunnel or approved runtime access
- Read-only health checks by default
- Explicitly approved write-smoke only when task requires it

Output:

- Runtime evidence with command and status
- Whether BFF and Server active runtime match expected behavior
- Whether frontend is actually consuming cloud APIs

No-Go conditions:

- Tunnel unavailable and runtime is required
- Endpoint returns 401 / 404 / 5xx and task requires availability
- Cloud artifact cannot be verified but conclusion depends on deployment
- Any validation would require unsafe business writes without explicit approval

## 7. Layer Responsibilities

### Flutter App

Allowed:

- Mobile UI, shell, routing, guards, presentation state, feature visibility, repository consumption, upload client flow.
- Consuming BFF `/api/app/*` contracts and BFF-shaped view models.

Forbidden:

- Calling `Server` directly.
- Calling Admin APIs.
- Direct database access.
- Writing business truth, permissions, state machines, audit rules, or review rules.
- Inventing DTOs, enums, status semantics, or error codes outside frozen contracts.
- Treating mock, fake transport, visual demo, or test doubles as runtime evidence.
- Silently swallowing unknown state names, unknown error codes, or unknown critical fields.

### Admin

Allowed:

- Minimal operations console.
- Review, governance, audit, template, membership, and controlled admin surfaces.
- Direct use of controlled `Server` Admin APIs.

Forbidden:

- Going through `BFF`.
- Direct database writes that bypass `Server`.
- Client-only review, audit, governance, permission, or role truth.
- Treating UI page existence as proof of operational closure.
- Treating `x-actor-*` header hints as final permission truth.

### BFF

Allowed:

- App-facing APIs.
- Auth carrier consolidation.
- Aggregation.
- Server transport.
- Field shaping.
- Error normalization.
- Upload signing / confirm orchestration.
- Light idempotency.
- Visibility trimming.

Forbidden:

- Owning business truth.
- Defining a second state machine.
- Persisting business decisions as truth.
- Creating Admin-only APIs.
- Owning `Project`, `Order`, `Milestone`, `Review`, payment, membership, credit, governance, or audit truth.
- Hiding provider logic in business routes.
- Treating legacy or internal paths as canonical App-facing surfaces.

### Server

Allowed and required:

- Business truth.
- Database ownership.
- State machines.
- Session and role gates.
- Permissions.
- Audit.
- Review.
- Risk.
- Governance.
- Admin APIs.
- Migrations.
- `FileAsset` / `Evidence` truth.

Forbidden:

- Breaking frozen contracts without truth and contract updates.
- Putting state transitions in controllers or scripts.
- Treating `objectKey` as business truth.
- Exposing provider-specific map, SMS, OCR, payment, or storage logic outside adapter boundaries.
- Outputting secrets in logs, receipts, or chat.

## 8. Core Module Guardrails

- Auth: current App-facing login mainline is OTP login unless a newer frozen truth says otherwise.
- Messages: must not expand into a generic chat center. Keep to frozen interaction center, project communication, and bounded trading surfaces only.
- Payment / wallet / balance / coins / deposit / formal service-fee charging / settlement / refund / invoice: must be separately frozen and gated. Do not implement them opportunistically.
- Membership: do not mix organization membership, paid membership, quota snapshots, orders, and display state. Each must follow frozen truth and Server ownership.
- Credit: freeze score rules, score sources, increments, deductions, constraints, recovery, appeal, and Admin intervention boundaries before implementation.
- Enterprise Hub: distinguish public live snapshot from current draft / change snapshot. Workbench is an editing entry, not the public live view.
- Project / Bid / Order / Contract / Milestone / Inspection: prioritize smallest closed loop and read corridor. Do not expand into a full trading and fulfillment system without freeze.
- File Upload: must follow init -> direct upload -> confirm. Business truth is `FileAsset` / `Evidence`, not `objectKey`.
- Admin / Governance: Server owns permission, audit, review, risk, and governance truth.

## 9. Phase 0 Guardrail

- No business pages by default outside the approved Phase 0 scope.
- The current bounded exceptions are:
  - forum board only after formal unlock
  - messages interaction center and bidder carry only after formal unlock
  - bounded trading exception only for approved interaction, bid, snapshot, system seed, participant card, and matching implementation surfaces
- Retained non-goals unless separately frozen:
  - generic DM / group chat
  - compare / award / post-award bridge beyond frozen scope
  - payment / billing / settlement
  - `formal-info` full-page takeover
  - new IM mainline
  - renovation public entry
  - custom furniture public entry
  - building-material marketplace public entry

## 10. Command Execution Rules

### Default Allowed Read-Only Commands

These are generally allowed when relevant:

- `git status --short`
- `git diff -- <path>`
- `git diff --check -- <path>`
- `rg -n "<pattern>" <path>`
- `find <path> -maxdepth <n> -type f`
- `sed -n '<range>p' <file>`
- `nl -ba <file>`
- `wc -l <file>`
- `ls`
- read-only `curl -i http://127.0.0.1:8080/health/bff/live`
- read-only `curl -i http://127.0.0.1:8080/health/server/live`

### Task-Related Commands Only

Run these only when the task scope justifies them:

- Flutter scoped checks:
  - `cd apps/mobile && flutter analyze <scope>`
  - `cd apps/mobile && flutter test <target>`
- Admin checks:
  - `cd apps/admin && npm run lint`
  - `cd apps/admin && npm run test:admin-side`
  - `cd apps/admin && npm run build`
- BFF checks:
  - `cd apps/bff && npm run build`
  - targeted `node --test test/<file>.cjs`
- Server checks:
  - `cd apps/server && npm run build`
  - `cd apps/server && npm run test:upload-transport`
  - targeted `node --test test/<file>.cjs`
- Contracts generation or check only in explicit contract tasks:
  - `pnpm contracts:generate`
  - `pnpm contracts:check`
- Cloud SSH read-only inspection only when runtime evidence is required and secrets are not printed.

### Forbidden By Default

Do not run these unless the user explicitly authorizes the exact operation and the current gate allows it:

- `pnpm install`
- `npm install`
- `flutter pub get`
- `pnpm dc:up`
- `pnpm dc:down`
- `cd apps/server && npm run start`
- `cd apps/server && npm run start:dev`
- `cd apps/server && npm run start:prod`
- `cd apps/bff && npm run start`
- `cd apps/bff && npm run start:dev`
- `cd apps/bff && npm run start:prod`
- `cd apps/admin && npm run start`
- `git reset`
- `git clean`
- `git stash`
- `git checkout --`
- migration commands
- deploy / release commands
- service restart
- Nginx reload
- database writes
- POST / PUT / PATCH / DELETE business API calls
- full-repo formatting
- deleting large doc sets
- cleaning `.tmp`
- cleaning `artifacts`
- cleaning `runtime`
- cleaning dirty worktree files
- modifying cloud services
- writing real business data

## 11. Git And Dirty Worktree Rules

- Every task must start with `git status --short`.
- Do not assume dirty files are yours.
- Do not revert, overwrite, delete, format, stash, or clean user changes unless explicitly requested.
- Do not clean `.tmp`, `artifacts`, or `runtime` by default.
- Do not delete release artifacts by default.
- Do not list pre-existing dirty files as this turn's output.
- If dirty files overlap the requested edit scope, inspect carefully and preserve unrelated changes.
- Every final response for code/doc changes must include added, modified, and deleted files for this turn, plus unresolved dirty worktree risk.

## 12. Security And Sensitive Information

Never output, write into docs, or paste into chat:

- real passwords
- tokens
- session cookies
- OTP codes
- private keys
- payment keys
- database passwords
- cloud provider keys
- complete database connection strings
- user private data

If sensitive information is encountered, only write: `发现敏感配置风险`.

Do not print secret values while reading env files, cloud configs, process environments, logs, or deployment scripts.

## 13. File Length And Responsibility Gate

- Default handwritten business source limit: `450` lines per file.
- Warning line: `400`.
- Default handwritten function or method limit: `80` lines.
- Forced-refactor candidate line: `120`.
- One file carries one primary responsibility only.
- Mixing controller, service, mapper, state machine, and audit responsibilities in one handwritten file is forbidden.
- Exempt or separately governed file classes:
  - generated code
  - migrations
  - generated schema or OpenAPI outputs
  - fixtures, seeds, and mock data
  - localization copy
  - route registry files
  - explicitly registered constant lookup tables
- Every exemption must be recorded in formal truth; no verbal waivers.
- Mechanical splitting that worsens responsibility boundaries still fails review.

## 14. Change Order

1. Update or confirm SSOT.
2. Update or confirm OpenAPI contracts.
3. Update or confirm generated types when required.
4. Update backend truth and persistence specs.
5. Update BFF aggregation specs.
6. Update Flutter App and Admin consumption specs.
7. Implement code only after the relevant truth is frozen.
8. Verify locally with scoped checks.
9. Verify runtime only with approved read-only smoke or explicitly approved write-smoke.

## 15. Engineering Closure Model

For substantive code changes, the default engineering closure is:

Gate 0 read-only scan -> Gate 1 truth / contract freeze when needed -> dedicated branch -> change -> local verification -> commit -> push -> pre-merge review -> merge to main -> deploy only when runtime rollout is required -> Gate 4 runtime verification -> real device / page receipt for UI tasks -> closeout receipt.

This is not a requirement that every task must deploy.

Task-specific closure:

- Documentation tasks: freeze or update the doc, verify the diff, and close with a doc receipt. Do not run app builds, tests, deploy, or runtime smoke unless requested.
- Local Flutter / Admin UI tasks: verify contracts and API boundaries, run scoped local checks when relevant, and provide UI evidence when the task changes visible behavior. Deployment is not implied.
- BFF / Server / OpenAPI / generated-contract / runtime-dependent tasks: separate contract freeze, local source verification, cloud deployment, and runtime verification. Do not call the work runtime-complete until cloud evidence exists.
- High-risk deletion tasks: require explicit scope, current owner confirmation, rollback path, and post-delete verification. Never bundle broad cleanup with feature work.

Terminology:

- `commit` saves a snapshot on the current branch.
- `push` uploads the branch to the remote.
- `merge` integrates the branch into `main`.
- `deploy` publishes a build to cloud runtime.
- `runtime verification` proves the cloud runtime behaves as expected.

Hard distinctions:

- Commit is not merge.
- Merge is not deploy.
- Deploy is not runtime verification.
- No task is closed without a final receipt.

## 16. Testing And Acceptance Rules

### Pure Documentation Tasks

- Required: read relevant docs and current AGENTS.
- Recommended: `git diff --check -- <doc-path>`.
- Do not run app builds, tests, contracts generation, or runtime commands unless requested.

### Flutter / App Tasks

- Required: inspect contracts and BFF consumption paths.
- Recommended: scoped `flutter analyze` and targeted `flutter test`.
- Runtime claim requires tunnel smoke or explicit cloud evidence.

### Admin Tasks

- Required: confirm Admin uses Server Admin APIs.
- Recommended: `npm run lint`, targeted admin tests, or build if task scope requires it.
- Do not route Admin through BFF.

### BFF Tasks

- Required: confirm contract and Server path.
- Recommended: build and targeted BFF tests.
- Do not claim cloud runtime pass from local BFF tests.

### Server Tasks

- Required: confirm SSOT, contract, migration risk, and domain truth.
- Recommended: build and targeted Server tests.
- Do not start Server by default because startup may reconcile migrations.

### Runtime Tasks

- Required by default: read-only health checks.
- Endpoint smoke must report method, path, status, and whether it is read-only.
- Any write-smoke requires explicit approval and a rollback-aware plan.

## 17. Decision Standard

- `PASS`: truth, contract, implementation, verification, and runtime evidence match the requested stage.
- `CONDITIONAL PASS`: safe to proceed only with listed limits, missing checks, or explicit deferred risks.
- `NO-GO`: stop immediately; report blockers only. Do not implement, patch around, or fake local truth.

## 18. Final Receipt Format

Final responses for substantive tasks must include:

- 总裁决
- 本轮完成内容
- 本轮未完成内容
- 风险与边界
- 验收证据
- 变更摘要
- 下一步建议

For simple tasks, keep the same information compressed, but do not omit real risks or unrun checks.

## 19. Ownership

- `apps/mobile`: Frontend Agent
- `apps/admin`: Admin Agent; UI belongs to Admin frontend, permission and data truth belongs to Server
- `apps/bff`: BFF Agent; app-facing aggregation only, no business truth
- `apps/server`: Server Agent; business truth, permissions, state machines, audit, governance
- `docs/**`: Codex control-led truth and contract work
- `packages/contracts/**`: contract tooling projection; do not hand-edit generated files unless explicitly targeted

## 20. Default Execution Strategy

Prefer the safest path that preserves the current minimum closed loop.

Default priorities:

1. Protect root AGENTS rules.
2. Protect the current minimum P0 loop.
3. Resolve Admin / docs / contracts / runtime inconsistencies before adding new surfaces.
4. Keep BFF and Server runtime truth separate from local source assumptions.
5. Avoid broad refactors unless they are required by a gate.

Default deferrals:

- formal payment funds flow
- wallet / balance / coins
- deposit / guarantee
- settlement
- refund
- invoice
- new IM mainline
- renovation public entry
- custom furniture public entry
- building-material marketplace public entry
- dirty worktree cleanup
- large-scale refactor

The more stable option is to freeze truth and verify runtime before implementation. The lower-cost option is to update root rules before changing subdirectory rules. The current-stage option is to protect boundaries and close existing drift before expanding features. The highest-risk option is to continue adding product surfaces while docs, contracts, local source, and cloud runtime are not clearly aligned.

Root AGENTS.md only stores durable repo-wide rules. Detailed layer-specific rules should be moved to the closest subdirectory AGENTS.md when repeated mistakes appear.
