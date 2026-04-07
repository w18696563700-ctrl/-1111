---
owner: Codex 总控
status: draft
purpose: Freeze the BFF-side aggregation and shaping boundary for fake-project report submit handoff, target-context normalization, controlled restricted-state copy, and app-facing unavailable handling under the current App truth system without creating a second report, restriction, or adjudication owner.
layer: L3 BFF
---

# 假项目举报与裁决规则 V1 BFF Surface Addendum

## Scope
- This addendum applies only to the second dedicated `docs/03_bff` package for:
  - fake-project report submit handoff
  - actor and organization context normalization for report submit
  - target-anchor normalization for allowed report objects
  - accepted-submit acknowledgement shaping
  - duplicate-active-case acknowledgement shaping
  - restricted-state or unavailable copy shaping consumed by the current trade-side read families
- This addendum does not by itself:
  - unlock `apps/bff` implementation
  - unlock `apps/server` implementation
  - approve a user-side report center
  - approve a user-side report history or report detail center
  - approve any admin review, adjudication, appeal, penalty, blacklist, whitelist, or permanent-ban path through `BFF`

## Alignment Basis
- This addendum is aligned against:
  - [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md)
  - [bff_ssot.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/bff_ssot.md)
  - [bff_routes.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/bff_routes.md)
  - [fake_project_report_and_adjudication_rules_v1_app_aligned_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/fake_project_report_and_adjudication_rules_v1_app_aligned_freeze_addendum.md)
  - [fake_project_report_and_adjudication_rules_v1_contracts_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/fake_project_report_and_adjudication_rules_v1_contracts_addendum.md)
  - [fake_project_report_and_adjudication_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/fake_project_report_and_adjudication_rules_v1_backend_truth_addendum.md)
  - [review_ticket_risk_governance_baseline_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/review_ticket_risk_governance_baseline_addendum.md)
  - [dispute_entry_minimal_governance_action_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/dispute_entry_minimal_governance_action_addendum.md)
  - [project_publish_board_boundary_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/project_publish_board_boundary_freeze_addendum.md)

## Addendum Role
- Current `L0`, `L2`, and `L3 Backend` documents have already frozen:
  - fake-project report semantics
  - the current app-facing and admin path families
  - the report-case truth carrier
  - the temporary restriction overlay owner
  - adjudication and escalation truth ownership
- This addendum upgrades that package into a dedicated `BFF`-surface package for:
  - allowed app-facing route-group coverage
  - allowed submit shaping responsibilities
  - allowed blocked or unavailable copy shaping
  - cross-family consumption boundaries for restricted objects
- This addendum must not be read as:
  - approval for a second report-case state machine in `BFF`
  - approval for a second dispute path
  - approval for a user-side adjudication dashboard
  - approval for admin governance handling through `BFF`

## Current BFF Route-group Surface
- The only current `BFF` route groups relevant to this package are:
  - `exhibition`
  - `project`
  - `bid`
  - `contract`
  - `inspection`
- The only current dedicated fake-project report submit path in this round is:
  - `POST /api/app/exhibition/report/submit`
- Current trade-side read or entry families may later consume restricted-state copy only through their already-frozen path families.
- This package does not open any new public route family for:
  - report list
  - report detail
  - governance dashboard
  - adjudication progress center
  - appeal submit

## Current Aggregation Role
- `BFF` may do only:
  - request-id and trace-id propagation
  - current actor-context normalization
  - current organization-scope normalization where the target object requires transaction-side scope
  - allowed target-anchor normalization
  - submit-envelope shaping
  - duplicate-active acknowledgement shaping
  - restricted-state or unavailable copy shaping on already-existing read families when upstream truth already provides the relevant restriction signal
  - controlled error-envelope normalization into the current app-facing response format
- `BFF` must not do:
  - report-case lifecycle progression
  - restriction apply or lift decisions
  - adjudication-result decisions
  - escalation decisions
  - evidence final verification
  - downstream penalty or blacklist handling

## Non-owner Boundary
- `BFF` must not own:
  - `exhibition_report_cases`
  - `review_tasks`
  - governance ticket truth
  - `temporary_restriction_state`
  - `adjudication_result`
  - reporter legitimacy truth
  - target-object lifecycle truth
  - evidence linkage truth
- `BFF` must not persist:
  - report submit truth
  - report restriction truth
  - adjudication truth
  - a second report-summary store
  - a local restricted-object cache treated as business truth

## Submit Handoff Boundary
- `POST /api/app/exhibition/report/submit` remains the only current app-facing handoff path in this package.
- `BFF` may normalize only the frozen minimum submit fields:
  - `targetType`
  - `targetId`
  - `reasonCode`
  - optional `reasonDetail`
  - optional `evidenceFileAssetIds`
- `BFF` may also normalize:
  - current session actor
  - current organization scope
  - current idempotency or trace metadata where already allowed by the baseline
- `BFF` may shape only:
  - accepted new report-case acknowledgement
  - accepted equivalent-active-case acknowledgement
  - controlled invalid, forbidden, unavailable, or invalid-state responses
- `BFF` must not:
  - silently accept a missing target anchor
  - silently accept a scope-less transaction-side report
  - locally decide that the target exists when `Server` has not confirmed it
  - convert report submit into dispute-open
  - expose internal review-task or governance-ticket progression through the submit response

## Target-anchor Boundary
- `BFF` may forward fake-project report submit only for the currently frozen target family:
  - `project`
  - `project_profile`
  - `bid`
  - `contract`
  - `inspection`
- `BFF` must not accept:
  - a free-floating text complaint with no target object
  - forum content as a fake-project target through this package
  - message-thread abuse report through this package
  - a synthetic `order`-level target when the frozen contract has not opened it
- Current hard rule:
  - target normalization may only map a client-side anchor into the existing upstream object truth
  - target normalization may not invent a second object namespace in `BFF`

## Evidence-ref Boundary
- `BFF` may forward only current `fileAsset` references through:
  - `evidenceFileAssetIds`
- `BFF` may normalize:
  - empty evidence list
  - bounded duplicate refs
  - obvious client-side shape errors into controlled invalid responses
- `BFF` must not:
  - accept raw URL as evidence truth
  - accept `objectKey` as evidence truth
  - store a `BFF`-local evidence blob
  - claim evidence validation success without `Server` confirmation

## Accepted-submit Acknowledgement Boundary
- The current accepted-submit acknowledgement remains bounded to:
  - `reportCaseId`
  - `targetType`
  - `targetId`
  - `status`
  - `acceptMode`
  - `traceId`
- `BFF` may shape only:
  - a user-facing accepted summary
  - a duplicate-active accepted summary
  - a controlled next-step hint such as:
    - 举报已提交
    - 当前已有处理中举报
- `BFF` must not shape:
  - final adjudication copy
  - final penalty copy
  - blacklist or permanent-ban copy

## Restricted-state Copy Boundary
- `BFF` may consume `Server`-owned restriction truth and shape only bounded read-side copy such as:
  - 当前对象正在核查中
  - 当前对象暂不可继续相关操作
  - 当前对象已受限，请等待核查结果
- `BFF` may expose only bounded restriction-consumption hints through already-existing read families.
- `BFF` must not:
  - create a second `governanceState`
  - overwrite `project.status`, `bid.status`, `contract.state`, or `inspection.state`
  - locally hide an object as a final governance decision
  - claim a target has been materially established as fake before `Server` final adjudication
- If any detail carrier needs new fields to render restriction hints, that field change must return through separate contract freeze for that specific family.

## Cross-family Consumption Boundary
- `exhibition` remains the only current report-entry family.
- `project`, `bid`, `contract`, and `inspection` may only consume the resulting restriction overlay through their already-existing read or entry carriers.
- This package does not by itself reopen:
  - bid implementation
  - contract implementation
  - inspection implementation
  - downstream dispute governance expansion
- If any interpretation conflicts with the active publish-board freeze, the active board freeze wins.

## Forbidden Admin-surface Boundary
- The following paths remain outside `BFF` and must stay `Server Admin` only:
  - `GET /server/admin/exhibition/report-cases`
  - `GET /server/admin/exhibition/report-cases/{reportCaseId}`
  - `POST /server/admin/exhibition/report-cases/{reportCaseId}/request-explanation`
  - `POST /server/admin/exhibition/report-cases/{reportCaseId}/decide`
  - `POST /server/admin/exhibition/report-cases/{reportCaseId}/escalate`
- `BFF` must not proxy, reshape, or alias those admin paths into any app-facing family.

## Error-shaping Boundary
- `BFF` may normalize only the current frozen fake-project report error family into the unified app envelope:
  - `REVIEW_REPORT_INVALID`
  - `REVIEW_REPORT_RESOURCE_UNAVAILABLE`
  - `REVIEW_REPORT_INVALID_STATE`
  - `REVIEW_REPORT_REQUEST_EXPLANATION_INVALID`
  - `REVIEW_REPORT_DECIDE_INVALID`
  - `REVIEW_REPORT_ESCALATE_INVALID`
- For the current app-facing submit path, `BFF` may project only the subset relevant to ordinary app actors.
- `BFF` must not invent:
  - a second report-local error namespace
  - hidden local success after upstream failure
  - admin-only adjudication errors exposed as ordinary app guidance unless already normalized by the frozen envelope

## Cross-building Boundary
- `exhibition` owns the current fake-project report entry.
- `project`, `bid`, `contract`, and `inspection` own only the consumption of current restricted or unavailable state.
- `profile` does not become a fake-project report center in this package.
- `message` does not become a fake-project adjudication center in this package.
- `forum` is outside the scope of this package.

## Controlled Unavailable Boundary
- `BFF` may shape only bounded unavailable explanations such as:
  - 当前需先登录
  - 当前需先完成组织承接
  - 当前对象暂不支持举报
  - 当前对象不可继续相关操作
  - 当前举报入口暂不可用
- `BFF` must not expose:
  - raw internal table names
  - raw review-task internals
  - raw governance-ticket references
  - implementation-specific stack or persistence failure details

## Explicit Non-goals
- This package does not approve:
  - user-side report list
  - user-side report detail
  - user-side report history
  - reporter-side adjudication timeline center
  - appeal submit
  - penalty status center
  - blacklist status center
  - permanent-ban status center
  - message-center notification payload freeze
  - `apps/bff` implementation

## Current Freeze Conclusion
- Current `BFF` fake-project governance surface is frozen only as:
  - one app-facing report-submit handoff under `exhibition`
  - bounded context normalization for allowed target objects
  - bounded accepted acknowledgement shaping
  - bounded restricted or unavailable copy consumption through existing trade-side read families
- All report truth, restriction truth, adjudication truth, escalation truth, and admin handling truth remain `Server`-owned.
