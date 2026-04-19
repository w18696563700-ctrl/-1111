---
owner: 后端 Agent
status: frozen
purpose: Record the bounded backend execution receipt for S1-R05 governance appeals BFF-server route alignment after landing the current-actor profile read family in Server.
layer: execution receipt
freeze_date_local: 2026-04-09
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/s1_r05_governance_appeals_bff_server_route_alignment_controller_review_conclusion_addendum.md
  - docs/00_ssot/s1_r05_governance_appeals_bff_server_route_alignment_backend_execution_dispatch_spec_bundle_addendum.md
  - docs/01_contracts/cs030_my_appeal_history_p2a_contracts_addendum.md
  - docs/00_ssot/cs030_my_appeal_history_p2a_completion_filing_addendum.md
  - docs/00_ssot/stage1_repair_dispatch_master_addendum.md
---

# S1-R05 backend execution-dispatch receipt

## 1. S1-R05 backend execution-dispatch receipt

- `S1-R05 governance appeals BFF-server route alignment backend execution` 已完成。
- 本轮唯一目标已完成到 bounded backend repair：
  - `/server/profile/governance/appeals`
  - `/server/profile/governance/appeals/{appealCaseId}`
  已成为 `BFF` 现有 `/api/app/profile/governance/appeals*` target 的真实 canonical upstream。

## 2. changed files

- [profile.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/profile/profile.controller.ts)
- [profile-query.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/profile/profile-query.service.ts)
- [profile.presenter.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/profile/profile.presenter.ts)
- [block-p0a-profile-block.test.cjs](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/test/block-p0a-profile-block.test.cjs)

## 3. profile-route landing summary

- `/server/profile/governance/appeals` 已通过 [profile.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/profile/profile.controller.ts#L72) 落地到 `ProfileQueryService.getGovernanceAppeals()`
- `/server/profile/governance/appeals/{appealCaseId}` 已通过 [profile.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/profile/profile.controller.ts#L80) 落地到 `ProfileQueryService.getGovernanceAppealDetail()`
- `ProfileQueryService` 已在 [profile-query.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/profile/profile-query.service.ts#L98) 和 [profile-query.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/profile/profile-query.service.ts#L130) 落地 current-actor bounded read 逻辑
- `ProfilePresenter` 已输出可被现有 `BFF` 直接消费的 list/detail 形状：
  - list 顶层返回 `appealCaseId / penaltyId / penaltyType / penaltyStatus / status / reasonSummary / submittedAt / decidedAt / effectiveFrom / effectiveUntil`
  - detail 同时返回 top-level bounded fields 与 nested `penalty` summary，满足现有 `BFF` read-model
- 本轮未修改 `BFF`，修复后 `BFF` 现有 `/server/profile/governance/appeals*` upstream target 可直接命中真实路由

## 4. current-actor filtering summary

- current actor bounded filtering 已固定为：
  - 先经 `requireVerifiedCurrentSessionContext(...)` 验证 current session
  - 再经 `CurrentActorEligibilityService.requireAuthenticatedActor(...)` 验证当前 actor 有效
  - list 仅查询 `submittedBy = currentSession.userId`
  - detail 仅允许 `id = appealCaseId` 且 `submittedBy = currentSession.userId`
- current actor 读取他人 `appealCaseId` 时 fail-closed：
  - 返回 `GOVERNANCE_APPEAL_RESOURCE_UNAVAILABLE`
  - 不暴露 reviewer/admin 侧资源存在性

## 5. admin-vs-profile boundary summary

- `profile` family 与 `/server/admin/governance/appeals*` 已保持边界分离：
  - `profile` family 只提供 current-actor bounded read-only list/detail
  - `admin` family 继续保留 reviewer/admin list/detail/decide 语义
  - 本轮没有把 `GovernanceAppealService` 的 reviewer/admin 语义挪成 current-actor 语义
  - 本轮没有改动 admin decide flow，也没有让 `profile` family 继承 reviewer gate
- 结论：
  - current actor bounded list/detail 与 admin reviewer list/detail 已分离
  - `BFF` 不需要做伪兜底，也不需要改 route name 才能直连真实 upstream

## 6. build and test

- `npm run build` = PASS
- `node --test test/block-p0a-profile-block.test.cjs` = PASS `9/9`
- `node --test test/cs028-governance-appeal.test.cjs` = PASS `5/5`
- `node --test test/*.test.cjs` = PASS `49/49`

## 7. bounded smoke

- bounded smoke 以当前 bounded route landing 和 read-path validation 为准
- `current actor 可读取 own list` = PASS
- `current actor 可读取 own detail` = PASS
- `current actor 读取他人 detail fail-closed` = PASS
- `admin reviewer list/detail 仍可工作` = PASS
- `BFF target 所需 upstream 路径真实存在` = PASS

## 8. forbidden-scope confirmation

- 未改 `apps/bff/**`
- 未改 `apps/mobile/**`
- 未改 `apps/admin/**`
- 未改 `docs/**`，仅写入本 receipt
- 未扩到 appeal submit
- 未扩到 admin decide flow
- 未扩到 penalties / whitelist / permanent-ban center
- 未扩到 `S1-R06`
- 未扩到 `阶段2`
- 未改 `payment / billing`
- 未改 `V2.3`

## 9. blockers

- `none`

## 10. written file paths

- [profile.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/profile/profile.controller.ts)
- [profile-query.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/profile/profile-query.service.ts)
- [profile.presenter.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/profile/profile.presenter.ts)
- [block-p0a-profile-block.test.cjs](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/test/block-p0a-profile-block.test.cjs)
- [s1_r05_governance_appeals_bff_server_route_alignment_backend_execution_dispatch_receipt_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/s1_r05_governance_appeals_bff_server_route_alignment_backend_execution_dispatch_receipt_addendum.md)
