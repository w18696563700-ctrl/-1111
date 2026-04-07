---
owner: Codex 总控
status: draft
purpose: Freeze the minimum formal SSH entry-condition request package required to unblock cloud write work on the currently approved formal host.
layer: L0 SSOT
---

# 正式主机 SSH 入场条件请求单

## 1. Scope
- This addendum freezes the minimum request package required to unblock cloud
  write work on the currently approved formal host.
- It applies to:
  - BFF cloud implementation work
  - Server cloud implementation work
  - Docker host-baseline work
  - any later formal environment mutation on the approved formal host
- It does not:
  - switch the formal host
  - grant credentials by itself
  - authorize witness-host write work
  - redefine the current runtime topology

## 2. Current Frozen Position
- The current formal host remains:
  - `47.108.140.84`
- The current formal local verification tunnel remains:
  - `ssh -N -L 28790:127.0.0.1:8443 root@47.108.140.84`
- The currently reachable witness host remains:
  - `47.108.180.198`
- `47.108.180.198` may provide runtime observation only and must not replace the
  formal host without an explicit total-control approval.

## 3. Current Blocked Tasks
- The following tasks remain blocked on the formal host until entry conditions
  are supplied:
  - identity-permission `BFF` cloud write implementation
  - identity-permission `Server` cloud write implementation that must run on the
    formal host
  - Docker host-baseline installation on the formal host
  - any formal release mutation or environment mutation

## 4. Minimum Entry-condition Package Required
- To unblock Path A on the formal host, the operator must provide a usable entry
  condition package that clearly names all of the following:
  - target host IP:
    - `47.108.140.84`
  - SSH login user
  - access mode:
    - password
    - key
    - bastion-mediated
    - or another explicit approved method
  - if bastion or jump-host is required:
    - the exact approved path
  - whether the execution side may open an interactive shell
  - whether read-only confirmation is allowed first
- Secrets themselves must still be handled manually.
- Passwords, keys, and secret material must not be written into docs, logs, or
  receipts.

## 5. Minimum Read-only Confirmation Required Immediately After Unlock
- After entry conditions are supplied, execution must still begin with read-only
  confirmation only:
  - host identity
  - running release identity
  - current `systemd` service status
  - health endpoint status
  - current writable working directory identity
- No write action may occur before that read-only confirmation is recorded.

## 6. Witness Findings Accepted But Non-authoritative
- Witness-host findings from `47.108.180.198` may still be used as:
  - current asset inventory
  - current runtime observation
  - drift diagnosis
- They may not be used as:
  - formal write authorization
  - formal environment mutation evidence
  - formal release-cutover evidence
  - formal host-baseline completion evidence

## 7. Current BFF-stage Interpretation
- The current `BFF` identity-permission round is not blocked by missing design
  truth.
- It is blocked by missing formal-host entry conditions.
- Witness-host inventory may continue to inform planning, but implementation
  write actions must wait for formal-host access or formal host re-designation.

## 8. Required Output From The Access Owner
- The access owner must provide one of the following:

### 8.1 Path A: formal-host entry package
- a usable SSH entry condition for `47.108.140.84`
- read-only confirmation is allowed
- the execution side may then continue on the formal host

### 8.2 Path B: explicit formal-host re-designation
- a total-control approval that changes the formal host from `47.108.140.84` to
  another host
- the approval must include:
  - new formal host
  - new canonical tunnel or access path
  - whether the witness host and new formal host are the same runtime or a
    replacement runtime

## 9. Dispatch Conclusion
- Until one of the two paths above is formally satisfied:
  - the current host-access block remains valid
  - witness-host planning may continue
  - witness-host write execution remains forbidden
