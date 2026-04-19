---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Stage 4 cloud implementation prerequisite judgment for
  Trading-scoped IM Round A after read-only probing of the cloud host, without
  authorizing Server, BFF, Flutter, integration, release-prep, or closure work.
layer: L0 SSOT
freeze_date_local: 2026-04-16
scope:
  - Trading-scoped IM Round A
  - cloud implementation prerequisite check only
based_on:
  - AGENTS.md
  - docs/00_ssot/trading_im_round_a_truth_freeze_addendum.md
  - docs/00_ssot/trading_im_round_a_stage_gate_checklist_addendum.md
  - docs/01_contracts/trading_im_round_a_contracts_addendum.md
  - docs/02_backend/trading_im_round_a_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/trading_im_round_a_bff_surface_freeze_addendum.md
  - docs/04_frontend/trading_im_round_a_frontend_consumption_freeze_addendum.md
---

# 《交易场景 IM Round A 云端实施前提冻结补充单》

## 1. Scope

- 本补充单只冻结 `Trading-scoped IM Round A` 的云端实施前提。
- 本补充单不授权：
  - Server implementation
  - BFF implementation
  - Flutter implementation
  - result verification
  - integration
  - release-prep
  - Round A closure
- 本补充单不修改云端代码、运行目录、systemd、Nginx、release symlink。

## 2. Read-only Probe Summary

- Cloud host:
  - `47.108.180.198`
- SSH mode used:
  - `ssh -o BatchMode=yes -o ConnectTimeout=8 root@47.108.180.198 ...`
- Probe result:
  - SSH read-only login succeeded.
  - No password was written into command, docs, logs, or receipts.
- Probe time on cloud host:
  - `Thu Apr 16 07:14:43 CST 2026`
- Cloud hostname:
  - `iZ2vcby8q8surr2okzyepzZ`

## 3. Cloud Workspace Location Result

### 3.1 Probed Workspace

- Probed path:
  - `/srv/workspaces/exhibition-infra-monorepo`
- It exists as a directory.
- It contains repository-shaped files such as:
  - `AGENTS.md`
  - `apps/**`
  - `docs/**`
  - `infra/**`
  - `packages/**`
  - `package.json`
- It is not a git repository under the current probe.
- Evidence:
  - `git -C /srv/workspaces/exhibition-infra-monorepo rev-parse --show-toplevel`
    returned:
    - `fatal: not a git repository (or any of the parent directories): .git`
  - `find /srv -maxdepth 4 -type d -name .git` returned no business repo
    `.git` directory.
  - The only `.git` directories found by `/root` / `/home` probe were
    CodeBuddy plugin marketplace folders, not this business repository.

### 3.2 Cloud Git Root Judgment

- 未找到仓库证据：cloud host currently has a business git root for this
  repository.
- 未找到仓库证据：`/srv/workspaces/exhibition-infra-monorepo` can support
  branch checkout, branch commit, git status, git diff, or git push.
- Current judgment:
  - `/srv/workspaces/exhibition-infra-monorepo` is a synced / copied workspace
    mirror or source snapshot, not a valid cloud git development root.
  - It must not be treated as the implementation branch workspace.

### 3.3 Formal Local Git Root

- The formal local repository root is:
  - `/Users/wangweiwei/Desktop/展览装修之家总控`
- Current local branch observed:
  - `codex/1`
- Current local remote observed:
  - `origin ssh://git@github.com/w18696563700-ctrl/-1111.git`
- This local git root does not change the cloud-only implementation rule for
  Server and BFF. It only proves where formal source control currently exists.

## 4. Runtime And Release Topology

### 4.1 Active Runtime Services

- Active services observed:
  - `nginx`
  - `exhibition-bff`
  - `exhibition-server`
- `systemctl is-active` returned:
  - `nginx = active`
  - `exhibition-bff = active`
  - `exhibition-server = active`

### 4.2 Active Working Directories

- `exhibition-bff.service`
  - `WorkingDirectory=/srv/apps/bff/current`
  - `ExecStart=/usr/bin/node dist/main.js`
  - `EnvironmentFile=/srv/apps/bff/.env`
- `exhibition-server.service`
  - `WorkingDirectory=/srv/apps/server/current`
  - `ExecStart=/usr/bin/node dist/main.js`
  - `EnvironmentFile=/srv/apps/server/.env`
- `nginx.service`
  - `ExecReload=/bin/kill -s HUP $MAINPID`

### 4.3 Current Symlinks

- `/srv/apps/bff/current`
  - points to `/srv/releases/bff/20260414235030/apps/bff`
- `/srv/apps/server/current`
  - points to `/srv/releases/server/20260415170000-bid-upload-filekind`
- `/srv/apps/admin/current`
  - points to `/srv/releases/admin/20260412160203`

### 4.4 Ports

- Active mainline ports observed:
  - BFF: `3000`
  - Server: `3001`
  - Admin: `3002`
  - Nginx: `80`
- Additional staging / side ports observed:
  - `3100`
  - `3101`
  - `3201`
  - `3301`
- These side ports are not Round A implementation proof and must not be used as
  formal app-facing acceptance unless a later gate explicitly freezes them.

### 4.5 Nginx

- `nginx -t` passed.
- Current Nginx effective config includes:
  - `bff_upstream -> 127.0.0.1:3000`
  - `server_upstream -> 127.0.0.1:3001`
  - `admin_upstream -> 127.0.0.1:3002`
  - `/api/app/...` locations proxy to BFF upstream.
  - `/server/...` admin/server locations proxy to Server upstream.
- Trading IM Round A does not currently require Nginx route changes because
  frozen app-facing routes are under existing `/api/app/...` family.

## 5. Git Branch Strategy

### 5.1 Existing Cloud Branch Strategy

- 未找到仓库证据：an existing cloud git branch strategy for this Round A.
- 未找到仓库证据：a cloud business git root where a branch can be checked out.
- 未找到仓库证据：current cloud implementation should happen directly in
  `/srv/workspaces/exhibition-infra-monorepo`.

### 5.2 Required Strategy Before Implementation Can Be Dispatched

Before any Server or BFF implementation is dispatched, one of the following
must be explicitly frozen and proven:

1. A real cloud git clone / worktree exists for this repository.
2. The implementation branch name is explicitly frozen.
3. The branch is checked out on cloud.
4. `git status --short` is captured before implementation.
5. The branch has an explicit push / PR / patch-return route back to the formal
   repository.

Until those five facts are proven, this round remains:

- `No-Go for Server implementation`
- `No-Go for BFF implementation`

## 6. Change Return Mechanism

### 6.1 Existing Return Mechanism

- 未找到仓库证据：a fixed cloud-to-formal-repo return mechanism for this Round A.
- 未找到仓库证据：cloud changes should be returned by push, PR, patch, bundle,
  cherry-pick, or any other named mechanism in the current stage.

### 6.2 Required Return Mechanism Before Go

The next prerequisite round must freeze exactly one return mechanism:

- direct push from cloud branch to remote branch
- PR from cloud branch
- patch file generated on cloud and applied by a controlled repo owner
- git bundle generated on cloud and imported by a controlled repo owner
- cherry-pick from a cloud-visible git remote

No implementation prompt may use vague wording such as:

- "sync later"
- "copy back"
- "回头合并"
- "云端改完再说"

## 7. Restart Permission

### 7.1 Current Permission Status

- Current round has not granted restart permission.
- Current user裁决 only grants:
  - `Go` for cloud implementation prerequisite correction / freeze
- Current user裁决 explicitly keeps:
  - `No-Go` for Server implementation
  - `No-Go` for BFF implementation
  - `No-Go` for Flutter implementation
  - `No-Go` for result verification
  - `No-Go` for integration
  - `No-Go` for release / closure

### 7.2 Service-specific Judgment

- `exhibition-server`
  - Restart capability exists through systemd.
  - Current-round restart permission: not granted.
- `exhibition-bff`
  - Restart capability exists through systemd.
  - Current-round restart permission: not granted.
- `nginx`
  - Reload capability exists through systemd.
  - Current-round reload / restart permission: not granted.
  - Nginx change is not expected for Round A because `/api/app/...` routing
    already maps to BFF.

### 7.3 Required Restart Authorization Before Go

Before implementation dispatch, total control must explicitly freeze:

- whether `exhibition-server` may be restarted
- whether `exhibition-bff` may be restarted
- whether `nginx` may be reloaded or restarted
- who authorizes that action
- rollback expectation if a restart fails

## 8. Deploy / Current Artifact Update Procedure

### 8.1 Existing Evidence

Prior cloud receipts show a release/current pattern:

- create a new timestamped release directory under `/srv/releases/server/...`
  or `/srv/releases/bff/...`
- build inside the release directory
- switch `/srv/apps/server/current` or `/srv/apps/bff/current` to that release
- restart the corresponding systemd service
- verify health and bounded smoke

Current active cloud state also confirms this pattern:

- `/srv/apps/bff/current -> /srv/releases/bff/20260414235030/apps/bff`
- `/srv/apps/server/current -> /srv/releases/server/20260415170000-bid-upload-filekind`

### 8.2 Current Procedure Status

- 未找到仓库证据：a current-round approved deploy procedure for Trading IM
  Round A implementation.
- 未找到仓库证据：current-round permission to create a new release directory.
- 未找到仓库证据：current-round permission to switch `current` symlinks.
- 未找到仓库证据：current-round permission to restart active services.

### 8.3 Required Procedure Before Go

A later prerequisite pass must freeze the exact deploy path for each role:

- Server:
  - source root
  - build command
  - test command
  - release directory path
  - symlink switch command
  - restart command
  - rollback command
- BFF:
  - source root
  - build command
  - test command
  - release directory path
  - symlink switch command
  - restart command
  - rollback command
- Nginx:
  - `nginx -t`
  - reload command only if config changes are explicitly admitted

## 9. Build / Test Commands Found

Candidate commands are discoverable from cloud package scripts, but they are
not enough to grant implementation by themselves.

- Server build:
  - `cd /srv/workspaces/exhibition-infra-monorepo/apps/server && pnpm build`
- Server focused test:
  - `cd /srv/workspaces/exhibition-infra-monorepo/apps/server && pnpm test:upload-transport`
- BFF build:
  - `cd /srv/workspaces/exhibition-infra-monorepo/apps/bff && pnpm build`
- BFF test:
  - `cd /srv/workspaces/exhibition-infra-monorepo/apps/bff && pnpm test`
- Root smoke candidate:
  - `cd /srv/workspaces/exhibition-infra-monorepo && pnpm smoke:local`

Because the cloud workspace is not git-controlled, these commands are not yet
an implementation-dispatch basis.

## 10. Current Minimum Smoke Check

### 10.1 Health Smoke Available Now

- BFF health:
  - `GET http://127.0.0.1/health/bff/live`
  - current result: `200`
  - response body identifies `service=exhibition-bff`, `port=3000`
- Server health:
  - `GET http://127.0.0.1/health/server/live`
  - current result: `200`
  - response body identifies `service=exhibition-server`, `port=3001`

### 10.2 Round A Route Baseline Now

Current Round A app-facing routes are not implemented in active runtime:

- `GET /api/app/project/clarification/list?projectId=stage4-prereq-check`
  - current result: route-level `404`
  - body includes `Cannot GET /api/app/project/clarification/list...`
- `GET /api/app/bid/thread/detail?projectId=stage4-prereq-check&bidId=stage4-prereq-check`
  - current result: route-level `404`
  - body includes `Cannot GET /api/app/bid/thread/detail...`

This is expected before implementation and must not be treated as a failed
implementation result.

### 10.3 Minimum Smoke Required After Future Implementation

After a future implementation is explicitly dispatched and deployed, the minimum
Round A smoke must include:

- BFF health through Nginx:
  - `GET http://127.0.0.1/health/bff/live`
- Server health through Nginx:
  - `GET http://127.0.0.1/health/server/live`
- Project clarification route existence:
  - `GET /api/app/project/clarification/list?projectId=<controlled-project-id>`
  - must not return route-level `Cannot GET`
  - must return a controlled success or controlled auth/forbidden/unavailable
    error shape
- Bid private thread route existence:
  - `GET /api/app/bid/thread/detail?projectId=<controlled-project-id>&bidId=<controlled-bid-id>`
  - must not return route-level `Cannot GET`
  - must return a controlled success or controlled auth/forbidden/unavailable
    error shape
- Invalid write command guard:
  - `POST /api/app/project/clarification/create` with invalid body
  - `POST /api/app/bid/thread/message/send` with invalid body
  - `POST /api/app/bid/thread/confirmation/create` with invalid body
  - each must return controlled app-facing error shape, not route-level `404`

Full happy-path smoke requires controlled project, bid, actor, organization, and
confirmed `FileAsset` samples. Those samples are not created in this prerequisite
round.

## 11. Formal Stage 4 Decision

- Passed:
  - SSH read-only access exists.
  - Mainline runtime services are active.
  - Active current symlink / release topology is identified.
  - Health smoke is available.
  - Round A route baseline is identified as not yet implemented.
- Failed:
  - Cloud business git root not found.
  - Cloud branch strategy not found.
  - Cloud change return mechanism not found.
  - Current-round restart permission not granted.
  - Current-round deploy / current artifact update procedure not granted.

## 12. Three-thread Review Closure

Total control opened and recovered three prerequisite review threads in the same
Stage 4 boundary:

1. Cloud git root / branch strategy review.
2. Change return mechanism review.
3. Restart authorization / deploy-update procedure review.

All three reviews reached the same gate judgment:

- `No-Go`

The consolidated hard blockers are:

- Cloud business git root / branch strategy is not proven.
- Cloud-to-formal-repo return mechanism is not proven.
- Current-round restart / reload authorization and deploy-current update
  permission are not granted.

These blockers are independent; any one of them is sufficient to block Server or
BFF implementation dispatch.

## 13. Formal Conclusion

- `Trading-scoped IM Round A` remains blocked before implementation.
- Current裁决:
  - `Go` only for fixing / freezing the missing cloud implementation
    prerequisites.
  - `No-Go` for Server implementation.
  - `No-Go` for BFF implementation.
  - `No-Go` for Flutter implementation.
  - `No-Go` for result verification.
  - `No-Go` for integration.
  - `No-Go` for release-prep and closure.

## 14. Operator Authorization Closure

Current-round operator authorization has now closed the three former external
prerequisite blockers. These rules are formal execution rules for Trading IM
Round A and are no longer open candidates.

### 14.1 Cloud Git Root / Branch Strategy

- Authorized cloud git root:
  - `/srv/git/exhibition-infra-monorepo`
- Authorized implementation branch:
  - `feature/trading-im-round-a`
- The cloud agent may create a real git clone or worktree at the authorized
  cloud git root.
- The cloud agent may commit directly on `feature/trading-im-round-a`.
- The cloud agent must not implement in:
  - `/srv/workspaces/exhibition-infra-monorepo`
  - `/srv/apps/bff/current`
  - `/srv/apps/server/current`

### 14.2 Cloud-to-formal-repository Return Mechanism

- The only accepted return mechanism for this round is:
  - `push + PR`
- Implementation branch:
  - `feature/trading-im-round-a`
- PR base branch:
  - `main`
- Copy-back, later sync, "implement first and merge later", or any other
  ambiguous return mechanism is not accepted.
- If the cloud host cannot access the formal remote or cannot push the
  implementation branch, the round must stop at a new hard blocker.

### 14.3 Restart / Deploy / Current Update Authorization

- The current round may create new release artifacts under:
  - `/srv/releases/server/...`
  - `/srv/releases/bff/...`
- The current round may switch:
  - `/srv/apps/server/current`
  - `/srv/apps/bff/current`
- The current round may restart:
  - `exhibition-server`
  - `exhibition-bff`
- The current round must not modify Nginx configuration.
- The current round must not reload or restart Nginx.
- Deployment/update mode is:
  - release directory creation
  - `current` symlink switch
  - systemd restart
  - smoke check
- If deployment fails, the default rollback is to restore the previous
  `current` symlink and restart the affected service.

## 15. Stage 4 Gate Rerun

The former definition blockers are closed by operator authorization. Stage 4 is
now reduced to a real-environment validation gate:

1. The cloud host must be able to read the formal remote.
2. The cloud host must be able to create or update
   `/srv/git/exhibition-infra-monorepo`.
3. The cloud host must be able to check out
   `feature/trading-im-round-a` from `main`.
4. The cloud branch must be able to push to the formal remote.

Gate result:

- `Go for Server implementation` only if all four environment checks pass.
- `No-Go for implementation` if any remote, branch, or push check fails.

This section does not authorize scope expansion, Nginx changes, Server/BFF
implementation outside the frozen Round A contracts, or any Flutter direct
Server access.

## 16. Stage 4 Rerun Result

Control reran the live cloud implementation prerequisite gate after operator
authorization.

### 16.1 Passed Checks

- SSH access to the cloud host works:
  - `ssh -o BatchMode=yes root@47.108.180.198`
- Cloud git binary is available:
  - `/usr/bin/git`
  - `git version 2.43.7`

### 16.2 Failed Check

- Formal remote read from the cloud host failed:
  - Command intent:
    - `git ls-remote ssh://git@github.com/w18696563700-ctrl/-1111.git HEAD`
  - Failure:
    - `git@github.com: Permission denied (publickey).`
    - `fatal: Could not read from remote repository.`

Because the cloud host cannot currently read the formal remote, Control did not
create or update `/srv/git/exhibition-infra-monorepo`, did not check out
`feature/trading-im-round-a`, did not perform a push probe, and did not start
Server/BFF/Flutter implementation.

### 16.3 Formal Rerun Decision

- `No-Go for Server implementation`
- `No-Go for BFF implementation`
- `No-Go for Flutter implementation`
- `No-Go for result verification`
- `No-Go for integration`
- `No-Go for Round A closure`

Hard blocker:

- The cloud host must receive working GitHub deploy-key / SSH-key access, or
  another formally approved credential path, so that it can read and later push
  `feature/trading-im-round-a` to the formal remote.

## 17. Patch Return Mechanism Supersession

The operator has formally changed the only accepted return mechanism for this
round.

This section supersedes the earlier `push + PR` return-mechanism requirement for
Trading IM Round A only. GitHub remote read / push access from the cloud host is
no longer a prerequisite for this round and is no longer a current blocker.

### 17.1 Only Accepted Return Chain

The only accepted return chain is now:

1. Implement in a real cloud git workspace.
2. Generate an auditable patch from that cloud git workspace.
3. Transfer / deliver the patch to the local formal repository.
4. Apply the patch in the local formal repository.
5. Make the final formal local commit from the local formal repository.

The local formal repository is the final commit truth for this round.

### 17.2 Patch Return Rules

- Cloud implementation must not edit runtime `current` directories directly.
- Cloud implementation must happen in a real git workspace.
- Cloud implementation must generate an auditable patch after completion.
- The patch must be apply-able in the local formal repository.
- The local formal repository is the final commit truth.
- Before patch return is completed and applied locally, the round must not claim
  the code has formally landed in repository truth.
- No alternate return mechanism is retained for this round.

### 17.3 Still-active Deployment Authorization

The following deployment authorization remains active:

- The round may create new release artifacts under:
  - `/srv/releases/server/...`
  - `/srv/releases/bff/...`
- The round may switch:
  - `/srv/apps/server/current`
  - `/srv/apps/bff/current`
- The round may restart:
  - `exhibition-server`
  - `exhibition-bff`
- The round must not modify, reload, or restart Nginx.
- Failed deploy/update rolls back by restoring the previous `current` symlink
  and restarting the affected service.

### 17.4 Updated Stage 4 Gate

Stage 4 now checks:

1. A real cloud git workspace exists or can be created at
   `/srv/git/exhibition-infra-monorepo`.
2. Implementation can occur in that git workspace rather than a runtime
   `current` directory.
3. A standards-compliant patch can be generated from the cloud git workspace.
4. The local formal repository can receive and apply patches.

`Go for Server implementation` is allowed only if all four checks pass.

## 18. Patch-return Stage 4 Live Gate Result

Control reran Stage 4 under the new patch-return mechanism.

### 18.1 Cloud Git Workspace

- Cloud git workspace:
  - `/srv/git/exhibition-infra-monorepo`
- Branch:
  - `feature/trading-im-round-a`
- Baseline commit:
  - `d9263e7`
- Workspace status after baseline:
  - clean
- macOS AppleDouble metadata check:
  - `find . -name "._*" | wc -l = 0`
- Runtime-current protection check:
  - `/srv/apps/server/current` is not the cloud git workspace.
  - `/srv/apps/bff/current` is not the cloud git workspace.

### 18.2 Patch Generation

- Cloud patch generation probe:
  - created staged probe file in the cloud git workspace
  - generated `/tmp/trading_im_stage4_patch_probe.diff`
  - reset and removed the probe file
  - cloud workspace returned to clean status
- Patch size:
  - `226` bytes

### 18.3 Local Apply Reception

- Local formal repository:
  - `/Users/wangweiwei/Desktop/展览装修之家总控`
- Local patch reception probe:
  - cloud-generated probe patch streamed back to the local formal repository
  - `git apply --check` returned `0`

### 18.4 Gate Decision

- `Passed`:
  - real cloud git workspace exists
  - implementation location is not a runtime `current` directory
  - auditable cloud patch generation works
  - local formal repository patch apply check works
- `Veto` retained:
  - no direct runtime-current source edits
  - no Nginx config change / reload / restart
  - no scope expansion beyond frozen Round A
  - no claim of formal code landing before patch return is applied locally

Formal decision:

- `Go for Server implementation`
