# Contracts Package

Purpose:
- shared schemas
- generated client types
- common enums
- error code exports

Source of truth lives in:
- `docs/01_contracts`

Rules:
- `packages/contracts` is a projection layer, not the primary truth layer.
- Formal truth starts in `docs/01_contracts/*.yaml`.
- Allowed contents: generated types, schema bundles, contract constants, validation helpers derived from frozen contracts.
- Forbidden contents: business rules, runtime truth, ad hoc DTO invention, provider-specific adapter code.
