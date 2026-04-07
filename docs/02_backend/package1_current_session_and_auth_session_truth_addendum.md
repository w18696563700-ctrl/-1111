---
owner: Codex 总控
status: draft
purpose: Freeze the Package 1 backend truth boundary for current-session and auth-session across transport, persistence, verification, BFF forwarding, and Server verification without guessing token internals.
layer: L3 Backend
---

# Package 1 Current-session And Auth-session Truth Addendum

## 1. Scope
- This addendum covers only Package 1 current-session and auth-session truth.
- It freezes:
  - transport carrier boundary
  - persistence truth boundary
  - protected-request verification target
  - header trust boundary
  - BFF forwarding boundary
  - Server verification boundary
  - reviewer authorization boundary
- It does not freeze:
  - full auth family
  - JWT design
  - token payload or signature structure
  - SSO
  - Package 2 / 3 / 4
  - any implementation unlock by itself

## 2. Transport vs Persistence vs Verification

### 2.1 Transport carrier
- raw `authorization` is the only current-round ordinary protected-request carrier candidate visible in the repo.
- raw `authorization` is:
  - transport carrier only
- raw `authorization` is not:
  - verified current-session truth
  - final actor truth
  - final authorization truth

### 2.2 Persistence truth
- `sessions.refresh_token_hash` is current-round refresh-session persistence truth.
- The `sessions` family may also hold:
  - `status`
  - `expires_at`
  - `revoked_at`
  - `device_id`
- Current-round persistence meaning:
  - this truth supports refresh-token session truth
  - this truth does not by itself prove raw access authorization
  - this truth does not by itself prove the current protected request is authenticated

### 2.3 Verification target
- The protected-request verification target is:
  - verified current-session context
- This target is the Server-side verified conclusion for:
  - who the actor is
  - whether the current request is authenticated
  - what the verified current organization scope is when required
  - what authorization truth may be released to guards and handlers
- Current-round hard rule:
  - transport carrier and persistence truth must not be collapsed into the verification target

## 3. Header Trust Boundary

- `authorization`
  - role: access transport carrier only
  - may be used for: forwarding and entry into verification
  - must not directly decide: authenticated actor, current session validity, final authz

- `x-actor-id`
  - role: forwarding hint only
  - may be used for: bounded correlation hint after verification succeeds
  - must not directly decide: actor identity, reviewer identity, final authz

- `x-user-id`
  - role: forwarding hint only and legacy alias input
  - may be used for: alias normalization into `x-actor-id`
  - must not directly decide: user identity, current session validity, final authz

- `x-organization-id`
  - role: requested scope hint only
  - may be used for: expressing desired organization scope for later verification
  - must not directly decide: membership truth, scope ownership, final authz

- `x-actor-role`
  - role: forwarding hint only
  - may be used for: trace or debug attribution after verification succeeds
  - must not directly decide: reviewer role, platform role, final authz

- `x-request-id`
  - role: trace attribution only
  - may be used for: request correlation and append-only audit linkage
  - must not directly decide: authn or authz

- `x-trace-id`
  - role: trace attribution only
  - may be used for: cross-layer tracing and append-only audit linkage
  - must not directly decide: authn or authz

## 4. BFF Boundary
- `BFF` may only:
  - forward raw `authorization`
  - forward bounded hints
  - keep `x-request-id` and `x-trace-id`
  - normalize header names
  - map `Server`-owned auth failures into controlled app-facing envelopes
- `BFF` must not:
  - verify current session
  - certify reviewer role
  - synthesize actor truth
  - synthesize session truth
  - synthesize authorization truth
  - issue a second auth truth root

## 5. Server Boundary
- `Server` must:
  - own current-session verification
  - derive verified actor/session/authz from trusted truth
  - derive protected-request guard outcomes from verified truth
  - fail-closed when truth is insufficient
- `Server` must not:
  - promote raw header hints into auth truth
  - promote raw `authorization` into verified current-session truth without verification
  - infer current session from “same user has any valid session”
  - infer reviewer authorization from raw `x-actor-role`

## 6. Reviewer Authorization Boundary
- Reviewer authorization requires all of the following together:
  - verified actor identity
  - active membership truth
  - role key in `platform_reviewer | platform_super_admin`
  - platform organization truth
- raw `x-actor-role` is never enough.
- raw `x-actor-id` or `x-user-id` is never enough.
- reviewer authorization therefore remains:
  - DB-backed
  - Server-verified
  - fail-closed when verification cannot be completed

## 7. Current Operational Meaning
- Current remediation must now be read as:
  - safe but fail-closed
  - not runtime-ready
  - not BFF-consumable yet
- The current stage therefore means:
  - high-risk bypasses are closed
  - authenticated happy path is not yet reopened
  - downstream consumption remains blocked until the verification boundary is both frozen and later implemented

## 8. Next Required Implementation/Truth Prerequisites
- Before fail-closed can become authenticated happy path, the project still needs:
  - contracts that explicitly separate transport carrier, refresh-session persistence truth, and verified current-session context
  - backend truth that explicitly binds eligibility and reviewer authorization to Server-side verified current-session context
  - a later bounded implementation round that consumes those frozen boundaries without guessing token internals
  - a separate runtime schema and migration decision, which remains outside this addendum
  - independent verification after implementation, before any BFF consumption unlock
- This addendum does not itself authorize any of the steps above.
