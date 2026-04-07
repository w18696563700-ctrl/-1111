# Tooling Package

Purpose:
- repo tooling
- build helpers
- generation helpers
- narrow non-domain utilities with explicit owner

Forbidden:
- business truth
- state machine rules
- provider-specific adapters
- becoming a catch-all bucket for Flutter App and NestJS runtime logic
- becoming a cross-language shared runtime code dump

Boundary:
- `packages/tooling` may contain only owner-known tooling and helper code that does not define domain meaning.
- It must not be treated as a shared runtime source of truth between Flutter App and NestJS.
