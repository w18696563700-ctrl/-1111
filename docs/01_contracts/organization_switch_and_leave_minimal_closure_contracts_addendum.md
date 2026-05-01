# Organization Switch And Leave Minimal Closure Contracts Addendum

layer: L2 Contracts
status: frozen
owner: Codex Control
date: 2026-05-01
depends_on:
  - docs/00_ssot/organization_switch_and_leave_minimal_closure_boundary_freeze_addendum.md
  - docs/01_contracts/identity_permission_minimum_contracts.yaml
  - docs/01_contracts/openapi.yaml
  - docs/01_contracts/error_codes.yaml

## Scope

This addendum freezes the minimum contract needed to close organization switch and current-organization self-leave in the Flutter App.

The active app-facing organization switch contract remains:

- `GET /api/app/profile/organization/mine`
- `POST /api/app/profile/organization/switch`

The newly admitted self-leave contract is:

- App-facing: `POST /api/app/profile/organization/current/leave`
- Server-facing: `POST /server/profile/organization/current/leave`

## Current Minimum Closure

- Flutter reads joined organizations from `GET /api/app/profile/organization/mine`.
- Flutter switches current organization through `POST /api/app/profile/organization/switch`.
- Flutter leaves only the current organization through `POST /api/app/profile/organization/current/leave`.
- BFF forwards and shapes the leave command only; it must not own membership truth.
- Server owns membership status, current session organization rebinding, last-admin blocking, and audit truth.

## Non-Goals

- Do not delete an organization.
- Do not cancel a company entity.
- Do not merge organizations.
- Do not transfer ownership.
- Do not clear certification records.
- Do not delete projects, bids, messages, files, orders, or historical audit data.
- Do not turn Admin into the proxy owner for ordinary App self-leave.
- Do not use local fake BFF or Server as production truth.

## App-Facing Contract

### POST /api/app/profile/organization/current/leave

Request body:

```yaml
reason?: string
```

Response body:

```yaml
leftOrganizationId: string
nextOrganizationId: string | null
shellBootstrapState: authenticated | no_organization
traceId: string
```

Rules:

- Request body is optional.
- `reason` is audit context only and must not change business truth.
- Success means the current user's current organization membership was marked `removed`.
- `nextOrganizationId` is the next active app-facing organization selected by Server, or `null` when none exists.
- `shellBootstrapState=authenticated` means App should reload shell/context and continue under the next organization.
- `shellBootstrapState=no_organization` means App should reload shell/context and show create/join organization entry.

## Server-Facing Contract

### POST /server/profile/organization/current/leave

Server must:

- Verify current session exists.
- Verify current session has `organizationId`.
- Verify the current actor has active membership under the current organization.
- Block leave when the actor is the last active administrator of the organization.
- Mark the current membership as `removed`.
- Write `OrganizationMemberLeft` audit.
- Rebind all valid sessions for the same user that still point to the left organization to the next active app-facing organization; if none exists, set them to no organization.
- Return `leftOrganizationId`, `nextOrganizationId`, `shellBootstrapState`, and `traceId`.

## Error Boundary

The controlled error family is:

- `ORG_SCOPE_REQUIRED`
- `ORG_MEMBER_UNAVAILABLE`
- `ORG_MEMBER_LEAVE_INVALID`
- `ORG_LAST_ADMIN_LEAVE_BLOCKED`

BFF may map these errors to App-facing copy, but BFF must not reinterpret the membership state, last-admin rule, or next organization selection as its own business truth.

## Acceptance

- Existing organization switch remains backward compatible.
- Flutter never calls `/server/*` directly.
- Leave current organization is not implemented by reusing member disable.
- Leave current organization does not delete organization, certification, projects, messages, files, orders, or audit history.
- All generated contracts are refreshed from `docs/01_contracts/openapi.yaml` and `docs/01_contracts/error_codes.yaml`.

