---
owner: Codex 总控
status: frozen
purpose: >
  Record the stage-gate checklist for Trading-scoped IM Round A after the L0,
  L2, L3, L4, and L5 freeze chain and generated contract check, confirming
  that implementation remains blocked until the cloud implementation
  prerequisite gate passes.
layer: L0 SSOT
freeze_date_local: 2026-04-16
based_on:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/trading_im_round_a_truth_freeze_addendum.md
  - docs/01_contracts/trading_im_round_a_contracts_addendum.md
  - docs/02_backend/trading_im_round_a_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/trading_im_round_a_bff_surface_freeze_addendum.md
  - docs/04_frontend/trading_im_round_a_frontend_consumption_freeze_addendum.md
  - docs/00_ssot/trading_im_round_a_cloud_implementation_prerequisite_freeze_addendum.md
  - docs/00_ssot/s1_r06_messages_single_active_object_truth_ruling_controller_review_conclusion_addendum.md
  - docs/00_ssot/s1_c01_message_index_minimal_closure_execution_dispatch_receipt_addendum.md
  - docs/00_ssot/exhibition_app_full_function_register_v1.md
---

# 《交易场景 IM Round A 阶段门禁核查表》

## 1. Stage Objective

- 当前目标固定为：
  - complete L0 truth freeze
  - complete L2 contracts freeze
  - complete L3 backend truth / persistence freeze
  - complete L4 BFF surface freeze
  - complete L5 Flutter consumption freeze
  - verify generated contracts
  - stop at cloud implementation prerequisite gate
  - preserve Change Order before implementation
- 当前明确非目标：
  - Server implementation
  - BFF implementation
  - Flutter implementation
  - cloud runtime alignment
  - integration
  - release-prep

## 2. Passed Gates

- `范围门禁` 通过：
  - 当前对象只限交易对象内工作沟通 Round A。
  - 已排除 forum DM、stranger DM、group chat、audio/video、realtime
    transport、read receipt、typing、online status、push。
- `active-owner 盘点门禁` 通过：
  - 仓库未找到 `project public clarification` active owner。
  - 仓库未找到 `project-bid private thread` active owner。
  - 当前不得把 `forum interaction inbox` 或 `/api/app/message/index`
    placeholder 当作交易 IM runtime。
- `架构边界门禁` 通过：
  - Flutter continues to consume BFF only。
  - BFF does not own business truth or second state machine。
  - Server remains business truth owner。
- `上传门禁` 通过：
  - Round A must reuse `init -> direct upload -> confirm`。
  - confirmed `FileAsset` is the business file reference。
  - `objectKey` remains non-business truth。
- `消息楼边界门禁` 通过：
  - `messages` building is reminder and jump target only。
  - It must not become general chat center。
- `contracts 门禁` 通过：
  - Round A app-facing paths, schemas, attachment schema, participant /
    availability projections, and error codes are frozen in L2.
  - `openapi.yaml` and `error_codes.yaml` have been updated.
  - `packages/contracts/**` generated projections have been regenerated and
    verified.
- `backend truth 门禁` 通过：
  - L3 freeze keeps Server as the unique truth owner for clarification, thread,
    message, confirmation card, attachment binding, permission, and audit.
- `BFF surface 门禁` 通过：
  - L4 freeze limits BFF to transport, normalization, shaping, visibility
    trimming, and error mapping.
- `frontend consumption 门禁` 通过：
  - L5 freeze limits Flutter to BFF consumption and local UI surfaces without
    business truth, permission truth, thread state, or audit.

## 3. Failed Gates

- `云端实施前提门禁` 尚未完成：
  - The formal Stage 4 evidence record is
    `docs/00_ssot/trading_im_round_a_cloud_implementation_prerequisite_freeze_addendum.md`.
  - SSH read-only login to `47.108.180.198` is available.
  - Cloud workspace path `/srv/workspaces/exhibition-infra-monorepo` exists, but
    it is not a git repository in the current probe and therefore cannot support
    a confirmed cloud branch strategy.
  - Active runtime services are present:
    - `nginx`
    - `exhibition-bff`
    - `exhibition-server`
  - Active runtime working directories are:
    - `/srv/apps/bff/current`
    - `/srv/apps/server/current`
  - Candidate cloud build/test commands are discoverable from package scripts:
    - `cd /srv/workspaces/exhibition-infra-monorepo/apps/server && pnpm build`
    - `cd /srv/workspaces/exhibition-infra-monorepo/apps/server && pnpm test:upload-transport`
    - `cd /srv/workspaces/exhibition-infra-monorepo/apps/bff && pnpm build`
    - `cd /srv/workspaces/exhibition-infra-monorepo/apps/bff && pnpm test`
  - Minimum health smoke against cloud Nginx is available:
    - `GET http://127.0.0.1/health/bff/live`
    - `GET http://127.0.0.1/health/server/live`
  - Missing implementation prerequisites:
    - confirmed cloud git branch strategy
    - confirmed code-change return mechanism from cloud to formal repository
    - current-round restart permission for `exhibition-bff` / `exhibition-server`
    - current-round deploy/release artifact update procedure

## 4. Veto Gates

- Any implementation before L0/L2/L3/L4/L5 freeze is vetoed.
- Any BFF or Flutter business truth is vetoed.
- Any objectKey-as-business-truth use is vetoed.
- Any forum route reuse as trading IM truth is vetoed.
- Any WebSocket/SSE/push/typing/online/read-receipt addition is vetoed.
- Any Admin implementation task in Round A is vetoed.

## 5. Stage Decision

- `Go`:
  - Stage 3 control judgment
  - Stage 4 cloud implementation prerequisite check
- `No-Go`:
  - Server implementation
  - BFF implementation
  - Flutter implementation
  - result verification
  - integration
  - release-prep

## 6. Next Unique Action

- 下一步唯一动作：
  - stop implementation dispatch
  - obtain or freeze the missing cloud git branch strategy, change-return
    mechanism, restart permission, and deploy/update procedure
  - rerun this cloud implementation prerequisite gate before dispatching Server
    or BFF code work

## 7. Stage 4 Operator Authorization Rerun

The operator has now frozen the former missing Stage 4 prerequisites:

- Cloud git root:
  - `/srv/git/exhibition-infra-monorepo`
- Implementation branch:
  - `feature/trading-im-round-a`
- Return mechanism:
  - `push + PR`
- PR base:
  - `main`
- Commit policy:
  - direct commits on the implementation branch are allowed
- Prohibited implementation directories:
  - `/srv/workspaces/exhibition-infra-monorepo`
  - `/srv/apps/bff/current`
  - `/srv/apps/server/current`
- Deployment authorization:
  - create new release artifacts under `/srv/releases/server/...` and
    `/srv/releases/bff/...`
  - switch `/srv/apps/server/current` and `/srv/apps/bff/current`
  - restart `exhibition-server` and `exhibition-bff`
  - do not modify, reload, or restart Nginx
  - rollback by restoring the previous `current` symlink and restarting the
    affected service

### 7.1 Rerun Gate

- Definition prerequisites:
  - `Passed`
- Environment prerequisites still requiring live verification:
  - formal remote readability from the cloud host
  - branch checkout at `/srv/git/exhibition-infra-monorepo`
  - push capability for `feature/trading-im-round-a`

### 7.2 Rerun Decision Rule

- If cloud remote read / branch checkout / push check pass:
  - `Go for Server implementation`
- If any of the above fail:
  - `No-Go for implementation`
  - report the failing environment prerequisite as a hard blocker

## 8. Stage 4 Live Rerun Result

- Passed:
  - cloud SSH access
  - cloud git binary availability
- Failed:
  - formal remote read from cloud host
- Failure evidence:
  - `git ls-remote ssh://git@github.com/w18696563700-ctrl/-1111.git HEAD`
    returned `Permission denied (publickey)` from GitHub.

Because the cloud host cannot read the formal remote, Control did not create or
update `/srv/git/exhibition-infra-monorepo`, did not check out
`feature/trading-im-round-a`, did not perform a push probe, and did not enter
Server/BFF/Flutter implementation.

Current gate decision:

- `No-Go for Server implementation`
- `No-Go for BFF implementation`
- `No-Go for Flutter implementation`
- `No-Go for result verification`
- `No-Go for integration`
- `No-Go for Round A closure`

Next unique action:

- Fix cloud GitHub SSH/deploy-key access for the formal remote, then rerun the
  Stage 4 live gate before implementation dispatch.

## 9. Stage 4 Patch-return Supersession

The operator has formally replaced the only accepted return mechanism for this
round.

Superseded for Trading IM Round A:

- `push + PR`
- cloud GitHub remote read as an implementation prerequisite
- cloud GitHub push as an implementation prerequisite
- GitHub SSH / deploy-key access as the current hard blocker

Only accepted return mechanism:

1. Cloud real git workspace implementation.
2. Cloud auditable patch generation.
3. Patch delivery to local formal repository.
4. Local formal repository `apply patch`.
5. Local formal repository final commit.

### 9.1 Updated Stage 4 Gate Checks

- Cloud git workspace:
  - `/srv/git/exhibition-infra-monorepo` must exist or be created as a real git
    workspace.
- Cloud implementation location:
  - implementation must happen in the cloud git workspace, not
    `/srv/workspaces/exhibition-infra-monorepo`, `/srv/apps/bff/current`, or
    `/srv/apps/server/current`.
- Patch generation:
  - the cloud git workspace must be able to produce an auditable patch.
- Local apply reception:
  - the local formal repository must be able to receive and apply the patch.

### 9.2 Updated Stage 4 Decision Rule

- If all four checks pass:
  - `Go for Server implementation`
- If any check fails:
  - `No-Go for implementation`
  - report the failing Stage 4 prerequisite as a hard blocker

## 10. Patch-return Stage 4 Gate Result

- Cloud git workspace:
  - `/srv/git/exhibition-infra-monorepo`
- Branch:
  - `feature/trading-im-round-a`
- Baseline commit:
  - `d9263e7`
- Patch probe:
  - cloud generated `/tmp/trading_im_stage4_patch_probe.diff`
  - cloud workspace returned to clean status
  - local formal repository `git apply --check` accepted the streamed probe
    patch
- Runtime-current protection:
  - implementation workspace is not `/srv/apps/server/current`
  - implementation workspace is not `/srv/apps/bff/current`

Gate result:

- `Passed`

Current裁决:

- `Go for Server implementation`

## 11. Implementation Receipt, Independent Gates, and Closure

The Stage 4 patch-return gate was used for the bounded Trading IM Round A
implementation. The implementation then proceeded through Server, BFF, Flutter,
and implementer-run smoke without opening any excluded conversation family.

The previous self-issued closure wording was withdrawn first. Then Stage 8
independent result verification and Stage 9 independent integration release
verification were both completed.

- Stage 8 independent result verification: `Passed`
- Stage 9 independent integration release verification: `Passed`
- Stage 10 closure: `Accepted within frozen Round A scope`

### 11.1 Implementation Evidence

- Server truth implementation:
  - `apps/server/src/modules/trading_im/**`
  - `apps/server/src/core/migrations/migrations.ts`
  - `apps/server/src/app.module.ts`
- BFF app-facing implementation:
  - `apps/bff/src/routes/trading_im/**`
  - `apps/bff/src/routes/routes.module.ts`
- Flutter consumption implementation:
  - `apps/mobile/lib/features/exhibition/data/trading_im_models.dart`
  - `apps/mobile/lib/features/exhibition/data/trading_im_consumer_layer.dart`
  - bounded project clarification and bid-thread pages
  - messages-building Round A reminder and jump-back registration

### 11.2 Verification Evidence

- `corepack pnpm --filter @exhibition/server build`: `Passed`
- `corepack pnpm --filter @exhibition/bff build`: `Passed`
- `corepack pnpm contracts:check`: `Passed`
- Flutter focused tests:
  - `test/trading_im_round_a_consumption_test.dart`
  - `test/exhibition_read_corridor_closure_test.dart`
  - `test/messages_instance_todo_test.dart`
  - result: `Passed`
- File length spot check:
  - Round A Server/BFF/Flutter primary files remain below the 450-line hard gate.
  - `trading_im_bid_thread_page.dart` is above the 400-line warning line but
    below the hard gate and retains one page responsibility.

`flutter analyze` remains non-clean because of existing mobile workspace issues
outside the new Trading IM files. This is recorded as residual risk, not as a
repo-wide clean-analyze pass.

### 11.3 Cloud Release Evidence

- Server current:
  - `/srv/releases/server/20260416102030-trading-im-round-a`
- First BFF release attempt:
  - `/srv/releases/bff/20260416102030-trading-im-round-a/apps/bff`
  - failed startup due missing `CoreModule` import in `TradingImModule`
  - rolled back to the previous BFF current before correction
- BFF current:
  - `/srv/releases/bff/20260416102334-trading-im-round-a-bff-fix/apps/bff`
- `exhibition-server`: `active`
- `exhibition-bff`: `active`
- Nginx:
  - not modified
  - not reloaded
  - not restarted
- Server migration runner:
  - applied `20260416_trading_im_round_a_truth`

### 11.4 Smoke Evidence

- `GET /health/server/live`: `200`
- `GET /health/bff/live`: `200`
- `GET /api/app/project/clarification/list?projectId=smoke-project`:
  - controlled `401 AUTH_SESSION_INVALID`
  - not route-level `Cannot GET`
- `GET /api/app/bid/thread/detail?projectId=smoke-project&bidId=smoke-bid`:
  - controlled `401 AUTH_SESSION_INVALID`
  - not route-level `Cannot GET`
- `POST /api/app/project/clarification/create` with `{}`:
  - controlled `400 PROJECT_CLARIFICATION_UNAVAILABLE`
  - route mounted and validation controlled

### 11.5 Final Gate Decision

- Stage 4 implementation prerequisite: `Passed`
- Server implementation: `Passed`
- BFF implementation: `Passed`
- Flutter consumption: `Passed`
- Stage 8 independent result verification: `Passed`
- Stage 9 independent integration release verification: `Passed`
- Trading IM Round A closure: `Accepted closed within frozen scope`

Current裁决:

- `Accepted closed within frozen Round A scope after independent result verification and independent integration release verification.`

### 11.6 Independent Evidence Summary

- Stage 8 independent result verification:
  - `PASS`
  - veto findings: `none`
  - recommended Stage 9 entry: `allowed`
- Stage 9 independent integration release verification:
  - `PASS`
  - veto findings: `none`
  - local `127.0.0.1:8080` forward smoke passed
  - Stage 10 entry: `allowed`

Still `No-Go`:

- general chat
- forum private messages
- stranger private messages
- group chat
- realtime transport
- read receipts / typing / online / push
- full order / contract / dispute conversation expansion
- any scope not explicitly frozen by later SSOT and gate
