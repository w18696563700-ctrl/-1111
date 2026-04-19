---
owner: Codex 总控
status: frozen
purpose: Freeze the bounded Server-side truth scope for round-6 enterprise display trust repair after cloud implementation was admitted with limited scope.
layer: L2 Backend
freeze_date_local: 2026-04-17
inputs_canonical:
  - docs/00_ssot/enterprise_display_trust_repair_round6_cloud_implementation_admission_judgment_addendum.md
  - docs/02_backend/enterprise_display_workbench_v1_backend_truth_addendum.md
  - docs/02_backend/enterprise_location_capability_v1_backend_truth_addendum.md
  - /srv/git/exhibition-infra-monorepo/apps/server/src/modules/enterprise_hub/**
---

# Enterprise Display Trust Repair Round 6 Backend Truth Scope

## 1. Scope

- 当前 round-6 `Server` 只允许处理：
  - `enterprise_listing.basic.name / province* / city*` 的真值自动补齐
  - submit / save 主链的 blocker family 收口与受控分型
- 当前 round-6 `Server` 不允许处理：
  - `Logo-only` carrier 解耦
  - 新增 `ensureListingShell` / `draft enterprise` route
  - founded-time filter
  - release / deploy / rollback

## 2. Truth Rule

- organization 与 certification 仍是上游真值。
- `enterprise_hub` 当前 round-6 只允许把已存在上游真值回填到现有 listing 最低必填字段：
  - `name`
  - `provinceCode`
  - `provinceName`
  - `cityCode`
  - `cityName`
- 当前回填必须保持：
  - 不新增 app-facing contract 字段
  - 不新增第二套 truth carrier

## 3. Blocker Rule

- `Server` 必须继续输出 submit-readiness blocker。
- 当前 round-6 允许做的增强仅限：
  - 让现有 blocker family 更稳定地区分“缺企业名称 / 缺省市真值 / 基础资料未完成”
  - 不得把多类失败全部压成无法执行的笼统 message
- 若增强需要新增 contract code family：
  - 本轮停止
  - 先补 `docs/01_contracts`

## 4. Allowed Write Set

- 当前 round-6 优先允许：
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-certification-sync.service.ts`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-errors.ts`
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-workbench.query.service.ts`
- 只有当现有路由承载不了本轮目标时，才允许触达：
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-truth.controller.ts`

## 5. Formal Conclusion

- 当前 round-6 `Server` 真值 scope 已冻结为：
  - `truth backfill`
  - `readiness blocker clarification`
- `location route` 与 `Logo-only` 真正解耦不属于本轮最小 backend 写集合。
