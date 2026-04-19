---
owner: Codex 总控
status: frozen
purpose: Freeze board applicability for the V1.0 revised enterprise display field-alignment package.
layer: L0 SSOT
freeze_date_local: 2026-04-18
inputs_canonical:
  - apps/server/src/modules/enterprise_hub/enterprise-hub-workbench.presenter.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub.presenter.ts
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_board_surface.dart
---

# Enterprise Display Field Alignment V1 Revision Board Applicability Appendix

## 1. Board Labels

- `C` = 优秀公司 / `company`
- `F` = 优秀工厂 / `factory`
- `S` = 优秀供应商 / `supplier`

## 2. Applicability Rules

### 2.1 Common Required

The following remain common required public families for `C/F/S`:

- enterprise identity
- region
- certification state
- short intro
- service item / capability summary
- public contact toggle

### 2.2 Company / Factory Stronger Requirements

The following are frozen as stronger requirements for `C/F` than for `S`:

- public cases: minimum one case
- max project scale / capacity-like summary
- project-delivery style capability summaries

### 2.3 Supplier Differences

- `S` may not blindly inherit `C/F` wording for project scale.
- supplier service-area semantics are interpreted as supply-coverage semantics.
- supplier cases remain optional / selected-open in the current phase.

## 3. Anti-drift Rule

- No field may default to all three boards without explicit applicability.
- If a field is partially shared but wording differs, the wording template must be board-scoped.
