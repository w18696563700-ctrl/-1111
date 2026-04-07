---
owner: Codex 总控
status: draft
purpose: Record the gap between the four-document governance mother blueprint and the current App truth, so later freezes and implementation do not mistake target-state language for already-frozen repo truth.
layer: L0 SSOT
---

# 四文书治理母蓝图 × 当前 App 对齐差异表 V1

## 1. Scope
- This file compares:
  - the mother blueprint target state
  - the current repo truth already frozen in SSOT, contracts, routes, and
    shell context
- This file does not by itself:
  - approve implementation
  - rewrite contracts
  - replace existing board freezes

## 2. Alignment Summary
- Current overall judgement:
  - direction mostly aligned
  - truth names only partially aligned
  - route families and state ownership must be tightened before implementation
- Practical conclusion:
  - the mother blueprint is usable as upstream intent
  - it is not yet safe as direct construction truth

## 3. Diff Table

| Topic | Mother blueprint target | Current App truth | Alignment ruling |
|---|---|---|---|
| Shell structure | `展览 / 消息 / 我的` jointly hold transaction governance | Current shell already uses `exhibition / messages / profile` and forbids a new building in [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md) | aligned |
| Identity truth | Blueprint describes account, real-name, enterprise, responsible-person layers | Current truth owner is `organization / organization_members / certification` minimum baseline in [account_login_identity_permission_minimum_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/account_login_identity_permission_minimum_freeze_addendum.md) | partially aligned; cannot rename current truth |
| Governance tiers | `U0/U1/U2/U3` product tiers | Current shell/runtime truth does not expose those tiers; it exposes `organizationId`, `roleKeys`, `certificationStatus`, `membershipStatus` | product label only; not storage truth |
| Role system | Blueprint uses reviewer / adjudicator / auditor role labels | Current formal app-facing role keys are frozen in [permission_matrix.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/permission_matrix.md) as `buyer_admin`, `buyer_member(scoped)`, `supplier_admin`, `supplier_member(scoped)`, platform roles | must map to existing role keys, not replace them |
| Publish qualification | Blueprint says enterprise-certified users may publish | Current formal gate is: organization scope + approved certification + matching role/object permission | aligned in intent; must use current guard stack |
| Bid qualification | Blueprint says enterprise-certified users may bid | Current formal gate is: supplier-side role + organization scope + approved certification | aligned in intent; must use current guard stack |
| Profile center | Blueprint upgrades `我的` into account/certification/enterprise/risk/rules hub | Current profile building already has organization, certification, session, company surfaces, but not full risk/appeal center yet | partially aligned |
| Publish entry | Blueprint wants publish entry embedded in existing structure | Current App already routes publish through `/exhibition/projects/create` and workbench/home entry points | aligned |
| Project publish scope | Blueprint is full governance target | Current project publish board is still frozen as the minimum create corridor in [project_publish_board_boundary_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/project_publish_board_boundary_freeze_addendum.md) | current board freeze wins for implementation |
| Bid / order / contract / fulfillment | Blueprint treats them as one governed chain | Current routes and OpenAPI already freeze `bid`, `order`, `contract`, `milestone`, `inspection`, `rating`, `dispute` families in [openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml) | aligned by route presence; not yet fully governed by four-doc rules |
| Report and adjudication | Blueprint proposes full fake-project report and freeze mechanism | Current repo has no frozen `report_case` app-facing/admin path family for exhibition transaction governance | missing |
| Contract archive | Blueprint requires mandatory contract filing before fulfillment | Current repo already has contract/detail/confirm/amend families, but not yet a dedicated “contract archive governance freeze” over the whole chain | partially aligned |
| Fulfillment mandatory chain | Blueprint requires milestones, daily logs, acceptance, archive | Current repo has milestone and inspection families; daily-progress and archive governance are not yet frozen as a document set | partially aligned |
| Risk / ban / whitelist | Blueprint defines penalty, watchlist, whitelist, permanent ban, appeal | Current repo has no frozen exhibition transaction risk-center route family or penalty object family | missing |
| Messages role | Blueprint gives message building a notification and transaction reminder role | Current shell keeps `messages` as touchpoint/continuation, not business truth owner | aligned |
| App-facing paths | Blueprint draft uses generic `/auth`, `/orgs`, `/me` style examples | Current repo freezes app-facing paths under `/api/app/*` only | must rewrite all paths to current family |
| Admin paths | Blueprint draft uses generic `/admin/*` style examples | Current repo freezes admin-facing paths under `/server/admin/*` | must rewrite all admin paths to current family |
| File truth | Blueprint wants evidence and contract files as evidence anchors | Current repo already freezes three-step upload and `FileAsset` truth; `objectKey` is not business truth | aligned; must reuse current file truth |
| Eligibility expression | Blueprint speaks in qualification tiers | Current repo eligibility is currently expressed through shell blocking state, organization scope, certification status, role keys, and object permission | must derive, not replace |
| Real-name person layer | Blueprint expects a person-real-name layer for comments/messages/reports | Current repo does not yet freeze a separate app-facing real-name truth distinct from organization/certification | missing and must not be invented casually |

## 4. Hard Alignment Rulings
- `organization` remains the current business主体 truth.
- `roleKeys` remains the current app-facing role truth.
- `certificationStatus` remains the current qualification-release truth field.
- `permission_matrix.md` remains the current permission truth baseline.
- App-facing governance routes must stay inside `/api/app/*`.
- Admin-facing governance routes must stay inside `/server/admin/*`.
- Existing board freezes still control current implementation corridors.

## 5. Topics Already Reusable Without Renaming
- shell/building structure
- project publish entry model
- bid/order/contract/milestone/inspection/dispute route families
- organization handoff and certification handoff
- FileAsset and upload three-step truth

## 6. Topics That Need App-aligned Re-freeze Before Implementation
- governance-tier mapping to current shell truth
- report/adjudication path family
- risk/penalty/appeal path family
- contract archive governance wording over the already-existing contract family
- fulfillment archive wording over the already-existing milestone/inspection family

## 7. Topics Explicitly Not Safe To Treat As Already Frozen
- `U0/U1/U2/U3` as formal backend keys
- bare `/auth/*`, `/orgs/*`, `/me/*` route families
- a second person-only enterprise action truth
- a second permission system outside `permission_matrix.md`
- a second certification truth outside current organization certification ownership

## 8. Conclusion
- The mother blueprint is accepted in direction.
- The current repo can absorb it only after alignment.
- The next required truth is an App-aligned freeze that:
  - preserves current truth names
  - preserves current route families
  - constrains future governance contracts to the existing App baseline
