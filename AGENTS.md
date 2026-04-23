# Root AGENTS

## Scope
- This monorepo contains `Flutter App`, `Admin`, `BFF`, `Server`, tooling packages, SSOT docs, contracts, and infra baselines.
- `Flutter App` is the only mobile client.
- `Admin` is a minimal operations console and uses controlled `Server` Admin APIs, not `BFF`.
- `BFF` is the only app-facing aggregation layer.
- `Server` is the only business truth owner.

## Frozen Stack
- Flutter App: Flutter
- Admin: Next.js
- BFF: NestJS
- Server: NestJS modular monolith
- Database: PostgreSQL
- Cache / idempotency / queue: Redis
- Object storage: S3-compatible OSS, MinIO for dev and test
- Reverse proxy: Nginx
- Cloud shape: one host, two processes, two ports, Nginx in front

## Non-negotiable Rules
- One shell, five buildings: exhibition, renovation, custom_furniture, messages, profile.
- First release exposes only exhibition, messages, profile.
- `renovation` and `custom_furniture` stay pre-embedded and hidden.
- `Flutter App` only talks to `BFF`.
- `BFF` does auth consolidation, aggregation, upload signing, response shaping, light idempotency, and visibility trimming only.
- `BFF` never owns business truth or a second state machine.
- `Server` owns business truth, state machines, audit, review, risk, and admin governance.
- File upload is always a three-step flow: init -> direct upload -> confirm.
- `objectKey` is never business truth; `FileAsset` and `Evidence` are.
- Template, rule, permission, inspection, and state snapshots freeze on instance creation.
- Live, geo, and map capabilities are platform pre-embeds only in Phase 0 and stay flag-off by default.

## File Length and Responsibility Gate
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

## Change Order
1. Update SSOT and contracts.
2. Update backend truth and persistence specs.
3. Update BFF aggregation specs.
4. Update Flutter App and Admin consumption specs.
5. Implement code only after the relevant truth is frozen.

## Universal Gate Execution
- `docs/00_ssot/gate_register_v1.md` is the canonical gate register.
- Codex 总控 must submit a 《阶段门禁核查表》 before any new stage prompt bundle.
- The checklist must state:
  - passed gates
  - failed gates
  - veto gates
  - whether the next stage is allowed
- Any failed veto gate blocks the stage directly.

## Ownership
- `apps/mobile`: Frontend Agent
- `apps/admin`: Backend Agent by default
- `apps/bff`: Backend Agent
- `apps/server`: Backend Agent
- `docs/**`: Codex control-led

## Phase 0 Guardrail
- No business pages by default.
- The current bounded exceptions are:
  - the forum board after the formal unlock in
    `docs/00_ssot/forum_implementation_unlock_addendum.md`
  - `messages interaction center and bidder carry` after the formal unlock in
    `docs/00_ssot/messages_interaction_center_and_bidder_carry_implementation_unlock_addendum.md`
- No trading flow implementation by default.
- The current bounded trading exception applies only to:
  - `message interactions`
  - `my bids`
  - `bid submission snapshot`
  - bounded `system_seed` supplement on `bid thread detail`
  - `participant-card minimum`
  - matching `Server`, `BFF`, and Flutter implementation needed to support the
    approved surfaces above
- Retained non-goals for the bounded trading exception:
  - generic DM / group chat
  - compare / award / post-award bridge
  - payment / billing / settlement
  - `formal-info` full-page takeover
- Outside the explicit forum exception and the explicit bounded trading
  exception, only groundwork, truth docs,
  skeletons, env baselines, and platform pre-embed scaffolding are allowed.
