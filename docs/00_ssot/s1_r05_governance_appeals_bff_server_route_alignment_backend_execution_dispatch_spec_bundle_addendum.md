---
owner: 总控文书冻结
status: frozen
purpose: Freeze the backend execution-dispatch spec bundle for S1-R05 governance appeals BFF-server route alignment, limiting execution to the missing server-side current-actor bounded read family.
layer: L0 SSOT
freeze_date_local: 2026-04-09
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/s1_r05_governance_appeals_bff_server_route_alignment_controller_review_conclusion_addendum.md
  - docs/00_ssot/s1_r05_governance_appeals_bff_server_route_alignment_controller_review_spec_bundle_addendum.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/01_contracts/openapi.yaml
  - apps/bff/src/routes/profile/profile-governance-appeals.service.ts
---

# 《S1-R05 governance appeals BFF-server route alignment backend execution-dispatch spec bundle》

## 1. 第一执行角色

- 本轮第一执行角色固定为：
  - `后端 Agent`

## 2. execution 目标

- 本轮 execution 目标固定为：
  - 在 `Server` 落地 current-actor bounded read canonical family：
    - `GET /server/profile/governance/appeals`
    - `GET /server/profile/governance/appeals/{appealCaseId}`
  - 保证其语义不同于 admin reviewer list/detail
  - 为 BFF 现有 `/api/app/profile/governance/appeals*` target 提供真实 upstream

## 3. 允许改动范围

- 本轮允许改动范围固定为：
  - `apps/server/**` 中与以下对象直接相关的最小闭环：
    - profile-side governance appeals read controller / query / presenter
    - current-session scoped current-actor filtering
    - appeal list/detail projection for current actor
    - 必要时复用现有 governance appeal entity/service 的最小抽取
    - 必要时最小 server-side tests
  - 允许最小 shared read-model split
  - 但不得扩成 governance center 重构

## 4. 禁止改动范围

- 本轮禁止改动范围固定为：
  - 不得改 `apps/bff/**`
  - 不得改 `apps/mobile/**`
  - 不得改 `apps/admin/**`
  - 不得改 `docs/**`
  - 不得扩到 appeal submit
  - 不得扩到 admin decide flow
  - 不得扩到 penalties / whitelist / permanent-ban center
  - 不得扩到 `S1-R06`
  - 不得扩到 `阶段2`
  - 不得做 `payment / billing / V2.3`

## 5. execution 完成后必须交付

- execution 完成后必须交付：
  - 变更文件清单
  - `/server/profile/governance/appeals*` 如何落地
  - current actor bounded filtering 如何成立
  - 与 `/server/admin/governance/appeals*` 如何边界分离
  - build / test 结果
  - bounded smoke 结果
  - 唯一 receipt 路径

## 6. 唯一 receipt 路径

- 本轮唯一 receipt 路径必须写死为：
  - [s1_r05_governance_appeals_bff_server_route_alignment_backend_execution_dispatch_receipt_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/s1_r05_governance_appeals_bff_server_route_alignment_backend_execution_dispatch_receipt_addendum.md)

## 7. 下一步唯一动作

- 当前下一步唯一动作必须固定为：
  - 由总控向 `后端 Agent` 发出 execution-dispatch 口令

## 8. 当前禁止进入

- 当前明确不得进入：
  - `S1-R06`
  - `阶段2`
  - `release-prep`
  - `launch`

## 9. Formal Conclusion

- `S1-R05 governance appeals BFF-server route alignment backend execution-dispatch spec bundle` 已冻结。
- 当前正式口径已写死为：
  - 第一执行角色只能是 `后端 Agent`
  - execution 目标是补齐 `Server` current-actor bounded read canonical family，而不是改写 `BFF` canonical target
  - 允许改动只限 `apps/server/**` 中与 profile-side governance appeals bounded read 直接相关的最小闭环
  - 不得扩到 appeal submit、admin decide flow、penalties center、`S1-R06`、`阶段2`、`payment / billing / V2.3`
  - execution 完成后必须回交变更文件、canonical route 落地说明、bounded filtering 说明、admin/profile 边界分离说明、build/test/smoke 与唯一 receipt 路径
