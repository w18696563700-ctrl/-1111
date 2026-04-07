---
owner: 总控文书冻结执行位
status: frozen
purpose: Record the dispatch gate decision for whether the next bounded Backend Agent remediation prompt may enter apps/server for Package 1A only.
layer: L0 SSOT
decision_date_local: 2026-04-02
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/exhibition_trade_governance_four_documents_backend_package1_implementation_dispatch_gate_checklist_addendum.md
  - docs/00_ssot/exhibition_trade_governance_four_documents_backend_package1_implementation_independent_review_addendum.md
  - docs/00_ssot/exhibition_trade_governance_four_documents_backend_d1_truth_gap_planning_addendum.md
  - docs/00_ssot/account_identity_board_closure_plan_addendum.md
  - docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md
  - docs/03_bff/account_and_enterprise_certification_rules_v1_bff_surface_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/server/src/shared/request-context.ts
  - apps/server/src/modules/organization/current-actor-eligibility.service.ts
  - apps/server/src/modules/profile/profile-certification-write.service.ts
  - apps/server/src/modules/review/organization-review-write.service.ts
  - apps/server/src/core/core.module.ts
  - apps/server/src/main.ts
  - apps/server/src/core/migrations/migrations.ts
  - apps/server/src/modules/upload/entities/file-asset.entity.ts
---

# 展览项目发布-竞标-履约治理四文书
# Backend Package 1A Remediation Dispatch Gate Checklist Addendum

## 1. Scope

- 本文件只裁定两件事：
  - 当前是否允许发出一条 Backend Agent remediation prompt
  - 且该 remediation prompt 是否只能针对 Package 1A 已识别缺口
- 本文件明确不裁定：
  - `apps/bff` unlock
  - Package 2 / 3 / 4 unlock
  - migration unlock
  - release-prep
  - release execution
- 本文件是 remediation dispatch gate，不是实现口令，不是 BFF 放行文书，不是上线说明。

## 2. Gate Basis

### 2.1 实际依据的门禁与总控文书

- [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md)
- [gate_register_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/gate_register_v1.md)
- [exhibition_trade_governance_four_documents_backend_package1_implementation_dispatch_gate_checklist_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_backend_package1_implementation_dispatch_gate_checklist_addendum.md)
- [exhibition_trade_governance_four_documents_backend_package1_implementation_independent_review_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_backend_package1_implementation_independent_review_addendum.md)
- [exhibition_trade_governance_four_documents_backend_d1_truth_gap_planning_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_backend_d1_truth_gap_planning_addendum.md)
- [account_identity_board_closure_plan_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/account_identity_board_closure_plan_addendum.md)

### 2.2 实际依据的 frozen truth / surface / contract

- [account_and_enterprise_certification_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md)
- [account_and_enterprise_certification_rules_v1_bff_surface_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/account_and_enterprise_certification_rules_v1_bff_surface_addendum.md)
- [openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)

### 2.3 实际依据的 `Server` 代码证据

- [request-context.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/shared/request-context.ts)
- [current-actor-eligibility.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/organization/current-actor-eligibility.service.ts)
- [profile-certification-write.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/profile/profile-certification-write.service.ts)
- [organization-review-write.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/review/organization-review-write.service.ts)
- [core.module.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/core/core.module.ts)
- [main.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/main.ts)
- [migrations.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/core/migrations/migrations.ts)
- [file-asset.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/upload/entities/file-asset.entity.ts)

## 3. Failed Review Summary

- 当前 Package 1A 首轮实现已经存在，但独立复核结论是 `FAIL`，证据见 [exhibition_trade_governance_four_documents_backend_package1_implementation_independent_review_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_backend_package1_implementation_independent_review_addendum.md)。
- 当前 `No-Go` 的直接原因不是 BFF，而是 `Server` 自身仍有安全与运行边界缺口；因此当前仍不能给 BFF 发 consumption prompt。

### 3.1 安全缺口

- `current-session` 语义错误：
  - [request-context.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/shared/request-context.ts) 不携带 current-session id / token 语义。
  - [current-actor-eligibility.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/organization/current-actor-eligibility.service.ts) 当前按“该用户任意 valid session”放行，而不是校验“当前请求绑定的 session”。
- reviewer 授权边界错误：
  - [request-context.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/shared/request-context.ts) 直接读取 `x-actor-role`。
  - [current-actor-eligibility.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/organization/current-actor-eligibility.service.ts) 只要 header 里角色命中 reviewer 集合就可直接放行。
  - [core.module.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/core/core.module.ts) 与 [main.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/main.ts) 未见可信全局 guard / middleware / auth filter 兜底证据。

### 3.2 Runtime blocker

- 当前实现只能判为 compile-level ready，不能判为 runtime-ready。
- [migrations.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/core/migrations/migrations.ts) 当前只覆盖 `enterpriseHubMigrations` 与 `projectPublishCorridorMigrations`，未覆盖 Package 1A 新依赖的 canonical tables。
- 因此 runtime schema blocker 仍存在，且当前 migration 仍未被放开。

### 3.3 Naming drift

- frozen truth 使用 `file_assets` 作为 canonical family 名称，证据见 [account_and_enterprise_certification_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md)。
- 当前代码与 schema 仍使用单数 `file_asset`，证据见 [file-asset.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/upload/entities/file-asset.entity.ts) 与 [migrations.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/core/migrations/migrations.ts)。
- 该问题已被识别，但当前不应借 remediation prompt 越权扩成命名重构或 schema 变更。

### 3.4 已正确实现的部分

- required 10 条 internal/admin truth path 已在 controller / module 层 compile-level 接线完成，证据见 [exhibition_trade_governance_four_documents_backend_package1_implementation_independent_review_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_backend_package1_implementation_independent_review_addendum.md)。
- 当前实现仍基本落在 Package 1A carrier 范围内，未扩到 Package 2 / 3 / 4，未发明第二套 identity / organization / certification truth。
- certification submit / resubmit、approve / reject、organization activation coupling、`licenseFileId -> FileAsset` 绑定等主干规则总体与 frozen truth 基本一致，问题集中在安全边界与 runtime blocker，不在 truth family 漂移。

## 4. Remediation-target Findings

### 4.1 必须进入下一条 remediation prompt 的问题

- current-session semantics
  - 结论：必须进入 remediation prompt。
  - 性质：安全缺口。
  - 口径：必须把“effective current session”校验收回到当前请求绑定语义，不能继续用“同 user 任意 valid session”替代。

- reviewer authorization boundary
  - 结论：必须进入 remediation prompt。
  - 性质：安全缺口。
  - 口径：必须去掉对裸 `x-actor-role` header 的直接信任，reviewer 资格必须回到可信 membership / platform reviewer attribution 边界。

### 4.2 必须记录但不在本轮 remediation prompt 里修的问题

- runtime schema blocker
  - 结论：本轮只记录，不在 remediation prompt 里修。
  - 原因：当前 migration 仍明确禁止放开；该 blocker 必须继续作为 runtime signoff 和后续 BFF unlock 的前置阻断项保留，不能在本轮偷换成“以后再说”。

- `file_assets` vs `file_asset` naming drift
  - 结论：本轮只记录，不在 remediation prompt 里修。
  - 原因：该 drift 一旦进入实体、表名或 migration 级修复，就会越权扩大为 schema / naming 重构；当前 remediation gate 不批准此类扩修。

## 5. Passed Gates

- Package 1A 的 frozen truth、dispatch gate、独立复核链已经形成，足以支撑一条“只修已识别缺口”的 bounded remediation prompt，证据见 [exhibition_trade_governance_four_documents_backend_package1_implementation_dispatch_gate_checklist_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_backend_package1_implementation_dispatch_gate_checklist_addendum.md) 与 [exhibition_trade_governance_four_documents_backend_package1_implementation_independent_review_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_backend_package1_implementation_independent_review_addendum.md)。
- 独立复核已经把失败项压缩到明确、可枚举、可边界化的问题集，不再处于“问题不清、无法 author remediation prompt”的状态。
- `gate_register_v1.md` 要求的“先出新的阶段门禁核查表，再发下一条 prompt”条件已由本文件满足，且本文件未绕过 veto 规则。

## 6. Failed Gates

### 6.1 当前未通过、但不直接阻断 remediation prompt 的门

- BFF consumption unlock 仍未通过。
- Flutter / Admin 仍未通过。
- Package 2 / 3 / 4 implementation unlock 仍未通过。
- migration unlock 仍未通过。
- Package 1A runtime-ready signoff 仍未通过。
- Package 1A naming consistency signoff 仍未通过。

### 6.2 当前未通过、且会直接阻断 remediation prompt 的门

- 本轮未发现“在严格限定为 Package 1A only、`apps/server` only、无 migration、无 BFF/Flutter/Admin、只修安全缺口”的前提下，仍会直接阻断 remediation prompt 的剩余 failed gate。
- 但若下一条 prompt 出现以下任一越权行为，本轮结论立即失效并回退为 `No-Go`：
  - 把 remediation 扩大成 Package 1 全量重做
  - 把 remediation 扩大成四包整体 implementation unlock
  - 试图顺手放开 BFF / Flutter / Admin
  - 试图顺手 author migration
  - 试图把 runtime blocker 或 naming drift 一并扩大成 schema 改造

## 7. Veto Gates

以下任一项触发即一票否决：

- second truth：发明第二套 identity / organization / certification / governance truth。
- remediation 扩大为 Package 1 重构或四包全开工。
- 越权放开 BFF / Flutter / Admin。
- migration 越权放开。
- 把 compile pass 当 runtime signoff。
- 用 header 信任继续糊 reviewer 权限边界。
- 把 runtime schema blocker 偷换成“先不管，继续往下游放行”。
- 把 `file_assets` vs `file_asset` drift 借机升级成未获批准的 schema / naming 重写。

## 8. Stage Go / No-Go

`Go` for bounded Backend Agent remediation prompt for Package 1A only

原因如下：

- 当前独立复核的 `FAIL` 已明确、集中且局部化，主要落在两个必须修的安全缺口上，适合由一条 bounded remediation prompt 处理。
- 当前 `No-Go` 的直接原因不是 BFF，而是 `Server` 自身安全与运行边界缺口；因此合理的下一动作就是先发 Server 侧 remediation prompt，而不是继续向 BFF 推进。
- frozen truth 与现有 review 证据已经足够支撑 remediation authoring，不需要再补一轮抽象 planning。
- 该 `Go` 只是安全补救放行，不是 Package 1A 完整 signoff，更不是 BFF unlock。

## 9. If Go, Allowed Remediation Range

### 9.1 允许触碰的目录

- 只限 `apps/server`
- 最小允许目录范围只能是：
  - `apps/server/src/shared/**`
  - `apps/server/src/core/**`
  - `apps/server/src/main.ts`
  - `apps/server/src/app.module.ts`
  - `apps/server/src/modules/identity/**`
  - `apps/server/src/modules/organization/**`
  - `apps/server/src/modules/shell/**`
  - `apps/server/src/modules/profile/**`
  - `apps/server/src/modules/review/**`
- 明确不允许触碰：
  - `apps/server/src/core/migrations/**`
  - `apps/bff/**`
  - `apps/mobile/**`
  - `apps/admin/**`

### 9.2 允许修复的缺口

- current-session semantics
  - 只允许修到“当前请求绑定 session”的可信校验边界。
- reviewer authorization boundary
  - 只允许修到 reviewer 权限不再依赖裸 header 信任。
- 为完成上述两项所必需的最小 supporting wiring
  - 例如 request-context、eligibility service、必要的 core/main 级接入与最小 module wiring。

### 9.3 明确禁止修的内容

- 不得把 remediation 扩成 Package 1 全量重构。
- 不得顺手扩到 Package 2 / 3 / 4。
- 不得顺手放开或实现 BFF / Flutter / Admin。
- 不得新增、修改、执行 migration。
- 不得把 compile pass 写成 runtime-ready。
- 不得改写 frozen truth family。
- 不得做 `file_assets` / `file_asset` 表名、实体名、migration 名称统一工程。

### 9.4 runtime blocker 与 naming drift 的本轮处置口径

- runtime schema blocker：
  - 本轮只记录，不在 remediation prompt 里修。
  - 它继续作为后续 runtime signoff 与 BFF unlock 的阻断项存在。
- naming drift：
  - 本轮只记录，不在 remediation prompt 里修。
  - 当前 remediation prompt 不批准任何 table/entity/migration naming 修复。

## 10. If No-Go, Required Prerequisites

- 本轮结论为 `Go`，因此不存在“发 remediation prompt 前必须先补的新文书”。
- 但若后续试图扩大 remediation 范围，则必须重新补门禁，而不能沿用本文件：
  - 若要 author migration，必须先补 migration scope gate
  - 若要推进 BFF consumption，必须先完成 Package 1A remediation、独立复核复验，并另补 BFF dispatch gate
  - 若要进入 Package 2 / 3 / 4，必须分别补各自 dispatch gate

## 11. Next Unique Action

- 下一条允许发给 Backend Agent。
- 但只允许发一个 Package 1A remediation prompt。
- 该下一条 prompt 必须同时写死以下边界：
  - 只限 `apps/server`
  - 只限 Package 1A 已识别安全缺口
  - 不得新增或修改 migration
  - 不得推进 BFF consumption
  - 不得触碰 Flutter / Admin
  - 不得触碰 Package 2 / 3 / 4
  - 必须在回执中继续保留 runtime schema blocker 与 naming drift 为 open blocker
- 若下一条 prompt 不能满足上述条件，则应退回总控重新出 gate，而不是带条件直接开工。

