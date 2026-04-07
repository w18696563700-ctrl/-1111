---
owner: Codex 总控
status: draft
purpose: Freeze the formal unlock order for resolving the current production-host drift and re-enabling cloud environment work on the approved formal host.
layer: L0 SSOT
---

# 正式主机口径解锁单

## 1. Scope
- This addendum freezes the formal unlock order for the current cloud-host drift.
- It applies to:
  - formal host confirmation
  - access-condition confirmation
  - when cloud environment work may resume
  - how to treat the currently reachable witness host
- It does not by itself:
  - switch the formal host
  - grant credentials
  - authorize environment write actions
  - redefine runtime topology

## 2. Current Frozen Position
- The current formal host remains:
  - `47.108.140.84`
- The current formal local verification tunnel remains:
  - `ssh -N -L 28790:127.0.0.1:8443 root@47.108.140.84`
- The currently reachable witness host remains:
  - `47.108.180.198`
- `47.108.180.198` is witness runtime only and must not replace the formal host
  without an explicit total-control approval record.

## 3. Current Block Condition
- Cloud environment write work is blocked because:
  - the formal host is fixed as `47.108.140.84`
  - but the execution side does not yet have usable entry conditions for that
    host
- Therefore:
  - cloud write work on the formal host is paused
  - cloud write work on the witness host is forbidden

## 4. Formal Unlock Conditions
- The block is lifted only when one of the following is formally satisfied:

### 4.1 Path A: formal host access is restored
- `47.108.140.84` remains the formal host
- the execution side obtains usable entry conditions for `47.108.140.84`
- the total control role confirms that environment work may resume on that host

### 4.2 Path B: formal host is explicitly re-designated
- total control issues an explicit approval that changes the formal host from
  `47.108.140.84` to another host
- that approval must name:
  - the new formal host
  - the new canonical tunnel or access route
  - whether the witness host and the new formal host are the same runtime or
    a replacement runtime
- before such approval exists, no one may infer that the witness host has become
  formal

## 5. Minimum Evidence Required To Unlock Path A
- At minimum, all of the following must be present:
  - the formal host IP remains `47.108.140.84`
  - a usable SSH entry condition exists
  - the operator can reach the formal host without inventing a second host path
  - the operator can perform read-only confirmation first
- The unlock does not require secrets to be written into any doc, log, or
  receipt.
- Passwords and secret material remain manual-entry only.

## 6. Minimum Read-only Confirmation Before Any Write Action
- Even after Path A is unlocked, execution must start with read-only
  confirmation:
  - host identity
  - active runtime identity
  - current release evidence
  - health evidence
- No environment write action may occur before that read-only confirmation is
  recorded.

## 7. Witness-host Handling Rule
- `47.108.180.198` may be used only for:
  - runtime observation
  - current witness evidence
  - drift diagnosis
- It may not be used for:
  - formal Docker installation
  - formal environment mutation
  - formal release change
  - formal rollback execution
- unless total control later re-designates it as the formal host in writing

## 8. Forbidden Shortcuts
- No one may:
  - install Docker on the witness host and report it as the formal host result
  - use a reachable witness host as a silent replacement for the formal host
  - redefine the formal tunnel by habit or convenience
  - start write operations on both hosts in parallel

## 9. Unlock Completion Signal
- The formal-host drift is considered unlocked only when total control can state
  both:
  - the formal host is confirmed
  - the execution side has a usable entry condition on that host

## 10. Dispatch Conclusion
- Until unlock completion, cloud environment work stays blocked.
- After unlock completion, the blocked environment task may resume from:
  - read-only host confirmation
  - then environment plan
  - then controlled write actions
