---
owner: Codex 总控
status: frozen
purpose: Freeze the bounded BFF surface scope for round-6 enterprise display trust repair after cloud implementation was admitted with limited scope.
layer: L2.5 BFF
freeze_date_local: 2026-04-17
inputs_canonical:
  - docs/00_ssot/enterprise_display_trust_repair_round6_cloud_implementation_admission_judgment_addendum.md
  - docs/03_bff/enterprise_display_workbench_v1_bff_surface_addendum.md
  - docs/03_bff/enterprise_location_capability_v1_bff_surface_addendum.md
  - /srv/git/exhibition-infra-monorepo/apps/bff/src/routes/enterprise_hub/**
---

# Enterprise Display Trust Repair Round 6 BFF Surface Scope

## 1. Scope

- 当前 round-6 `BFF` 只允许处理：
  - 现有 workbench / detail / list 路径对 Server 已有 truth 的消费对齐
  - 现有 save / basic update 路径的错误映射修正
- 当前 round-6 `BFF` 不允许处理：
  - 新增 app-facing contract route
  - `Logo-only` draft carrier 新入口
  - founded-time filter
  - release / deploy / rollback

## 2. Surface Rule

- `BFF` 当前 round-6 必须坚持：
  - 不发明第二套 truth
  - 不把非 location 的 `400` 误映射成 `ENTERPRISE_LOCATION_WRITE_INVALID`
  - workbench / detail / list 只消费 Server 已给出的现有字段
- 若要新增：
  - `draft enterprise` route
  - 新 blocker code family
  - 新 location contract 字段
  本轮必须停下并先补 `docs/01_contracts`

## 3. Allowed Write Set

- 当前 round-6 优先允许：
  - `apps/bff/src/routes/enterprise_hub/enterprise-hub.service.ts`
  - `apps/bff/src/routes/enterprise_hub/enterprise-hub-workbench.read-model.ts`
  - `apps/bff/src/routes/enterprise_hub/enterprise-hub.read-model.ts`
- 仅当现有入口确需修补时，才允许触达：
  - `apps/bff/src/routes/enterprise_hub/enterprise-hub.controller.ts`
  - `apps/bff/src/routes/enterprise_hub/app-enterprise-hub.controller.ts`

## 4. Formal Conclusion

- 当前 round-6 `BFF` surface scope 已冻结为：
  - `mapping correction`
  - `existing truth consumption alignment`
- `Logo-only` 与 `location route` 的新 contract 面不属于本轮最小 BFF 写集合。
