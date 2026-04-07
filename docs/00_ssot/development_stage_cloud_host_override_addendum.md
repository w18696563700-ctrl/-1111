---
owner: Codex 总控
status: draft
purpose: Freeze the temporary development-stage cloud host and tunnel override so execution may continue on the currently approved development runtime without waiting for the former formal-host gate.
layer: L0 SSOT
---

# 开发阶段云主机与隧道临时覆盖单

## 1. Scope
- This addendum freezes a development-stage override only.
- It applies to:
  - local validation during active development
  - cloud write work during active development
  - BFF and Server implementation rounds currently blocked by former host drift
  - independent verification and integration that explicitly target development
    runtime only
- It does not by itself:
  - define production release topology
  - redefine the release host forever
  - authorize writing secrets into docs or receipts

## 2. Total-control Development Override
- Effective immediately for the active development stage:
  - the approved development execution and validation host becomes:
    - `47.108.180.198`
  - the approved development local tunnel becomes:
    - `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`
  - the approved local development access address becomes:
    - `http://127.0.0.1:8080`
- This override exists because the previous host gate was blocking active
  development execution and repeated tunnel instability was preventing normal
  progress.

## 3. Development-stage Meaning
- During the active development stage:
  - Frontend Agent may validate against `http://127.0.0.1:8080`
  - BFF Agent may implement and verify on `47.108.180.198`
  - Backend Agent may implement and verify on `47.108.180.198`
  - result verification may accept `47.108.180.198 / 8080` evidence as the
    current development-runtime evidence
- This removes the previous development-stage gate that forced all work to wait
  on `47.108.140.84`.

## 4. Relationship To Previous Formal-host Docs
- Previous host-drift and formal-host unlock documents remain part of project
  history.
- But for the current active development stage, this addendum takes precedence
  over the earlier blocked-host execution rule.
- Therefore:
  - `47.108.180.198` is no longer treated as witness-only for current
    development execution
  - it is the approved current development runtime
- A later release-stage or production-stage freeze may still redefine the final
  formal release host separately.

## 5. Password And Secret Handling Rule
- The operator has explicitly approved password-based development access for the
  current development stage.
- Even so:
  - passwords must remain manual-entry only
  - passwords must not be written into SSOT docs
  - passwords must not be copied into receipts or logs
  - secrets must not be committed into repo files

## 6. Current Verified Development Evidence
- The current development tunnel is already reachable locally when active:
  - `127.0.0.1:8080`
- The current development runtime has proven at least:
  - `GET /health/bff/live` returns `200`
  - `GET /health/server/live` returns `200`
  - `GET /api/app/exhibition/home` returns `200` on the approved development
    runtime

## 7. Dispatch Rule Going Forward
- Until a later release-stage override is issued:
  - all current development execution may use:
    - host `47.108.180.198`
    - local tunnel `8080 -> 80`
  - BFF and Server agents may now continue cloud implementation work there
  - independent verification may now use this development runtime as the valid
    current runtime baseline

## 8. Non-goals
- This addendum does not:
  - declare production release readiness
  - settle the final release host forever
  - eliminate the need for rollback evidence
  - eliminate the need for gate checks in later release rounds

## 9. Dispatch Conclusion
- The previous host-entry block is lifted for the active development stage.
- The current approved development runtime is:
  - `47.108.180.198`
- The current approved local development tunnel is:
  - `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`
- The current approved local development validation address is:
  - `http://127.0.0.1:8080`
