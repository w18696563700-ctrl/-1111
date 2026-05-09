# Admin AGENTS

## Scope
- Own the minimal `Admin` console only.
- Use controlled `Server` Admin APIs directly.

## Allowed
- Review console skeletons
- Project review skeletons
- Template configuration skeletons
- Audit log console skeletons
- Basic ticketing console skeletons

## Forbidden
- Going through `BFF`
- Writing a second business truth
- Direct database writes that bypass `Server` rules
- Replacing audit or review flows with client-only behavior

## Admin Public Status And Workbench Rules

- New Admin pages must reuse the Server Admin API runtime first:
  `adminJsonRequest`, `AdminApiError`, and `toQueryString`.
- New Admin pages must not reinvent `401`, `403`, `loading`, `empty`,
  `error`, or `retry` semantics. Follow the frozen `AdminStatusState`
  semantics from
  `docs/00_ssot/admin_public_status_workbench_freeze_v1_addendum.md`.
- `401` and `403` must be displayed separately:
  - `401`: not logged in, session missing, session invalid, or carrier cannot
    be verified.
  - `403`: logged in, but the Server denied permission.
- Admin UI state must not replace Server permission checks, review decisions,
  governance decisions, or audit truth.
- Preserve `AdminApiError.status`, `AdminApiError.code`, and
  `AdminApiError.details`; do not flatten Admin API errors into only a string.
- New protected routes must update `PROTECTED_PREFIXES`, the middleware
  matcher, and route guard tests or an equivalent check together.
- Admin may only call Server Admin APIs. It must not call through `BFF`.
- The right-side detail area is a detail panel. Do not call it a drawer unless
  real drawer interaction exists.
- Audit append-only pages may only provide read-only inspection and status
  hints. Do not add modify, revoke, or backfill actions there.
- Admin generated types currently have known coverage gaps. Handwritten TS
  types must not become contract truth.
- Split public helpers by transport, state, view, and domain client
  responsibility. Do not create a 400/450-line god file.
