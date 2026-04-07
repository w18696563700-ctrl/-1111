---
owner: 联调发布 Agent
status: draft
purpose: Record the bounded enterprise_hub V1 integration-with-risk result on the formal runtime chain without implying release-prep, release approval, or release success.
layer: L0 SSOT
---

# Enterprise Hub V1 Integration With Risk Receipt Addendum

## Current Object
- Current object:
  - `enterprise_hub V1`
- Current stage:
  - `integration with risk`
- Current non-allowed meaning:
  - this does not approve `release-prep`
  - this does not approve `release`
  - this does not mean released or delivered

## Integration Basis
- This round only relies on:
  - `docs/00_ssot/enterprise_hub_v1_implementation_result_verification_conclusion_addendum.md`
  - `docs/00_ssot/enterprise_hub_v1_primary_implementation_increment_dispatch_addendum.md`
  - `docs/00_ssot/enterprise_hub_v1_real_account_context_dependency_freeze_addendum.md`
- This round only verifies the formal access chain:
  - local tunnel `http://127.0.0.1:8080`
  - cloud `80 -> 3000 -> 3001`

## Integration Access Chain
- Formal access chain used in this round:
  - local `127.0.0.1:8080`
  - tunneled to cloud `127.0.0.1:80`
  - cloud Nginx forwards app-facing traffic to `3000`
  - BFF forwards truth traffic to `3001`
- Current meaning:
  - this is real formal-chain integration evidence
  - this is not local fake full-stack closure

## Tunnel Verification Result
- Verification time:
  - `2026-04-02`
- Verification result:
  - `GET http://127.0.0.1:8080/health/bff/live` -> `200`
  - returned body key points:
    - `status=ok`
    - `service=exhibition-bff`
- Current interpretation:
  - local tunnel to formal `80` remained reachable during this round
  - this round therefore entered formal-chain integration rather than local-only validation

## Mainline Use-case Result
### 1. Home entry and three-card exposure
- `GET http://127.0.0.1:8080/api/app/exhibition/home` -> `200`
- Returned body confirms the home module order still carries:
  - `moduleKey=excellent_company`
  - `moduleKey=excellent_factory`
  - `moduleKey=excellent_supplier`
- Current home-state meaning:
  - three-card exposure is still present on the home payload
  - all three cards are currently placeholder entries:
    - `enabled=false`
    - `placeholder=true`
  - this round therefore confirms entry exposure, not actual clickable live-card completion

### 2. Recommendations
- `GET http://127.0.0.1:8080/api/app/exhibition/enterprise-hub/recommendations?boardType=company` -> `200`
- Returned body key points:
  - `boardType=company`
  - `items=[]`
- Current interpretation:
  - app-facing recommendation route is alive on the formal chain
  - current state is controlled empty-state, not route failure

### 3. Enterprise list
- `GET http://127.0.0.1:8080/api/app/exhibition/enterprise-hub/enterprises?boardType=company&page=1&pageSize=1` -> `200`
- Returned body key points:
  - `recommended=[]`
  - `items=[]`
  - `pagination.total=0`
- Current interpretation:
  - app-facing enterprise list route is alive on the formal chain
  - current state is controlled empty-state, not route failure

### 4. Missing-entity detail
- `GET http://127.0.0.1:8080/api/app/exhibition/enterprise-hub/enterprises/nonexistent-enterprise?boardType=company` -> `404`
- Returned body key points:
  - `code=ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND`
  - `source=server`
- Current interpretation:
  - detail route is no longer route-level `404`
  - missing entity now returns business-layer `404`
  - this confirms `list -> detail` runtime handoff exists at the formal chain

### 5. Controlled risk-state exposure
- `GET http://127.0.0.1:8080/api/app/exhibition/enterprise-hub/applications/nonexistent-application` -> `401`
- Returned body key points:
  - `code=AUTH_SESSION_INVALID`
  - `source=bff`
- `POST http://127.0.0.1:8080/api/app/exhibition/enterprise-hub/applications` with empty body and no auth -> `400`
- Returned body key points:
  - `code=ENTERPRISE_HUB_INVALID_BOARD_TYPE`
  - `source=bff`
- Current interpretation:
  - `401 / 400 / empty-state / business 404` are currently real exposed middle states
  - these must be preserved as integration risks rather than rewritten as release success

## Mainline Integration Conclusion
- Current chain status:
  - `home entry -> enterprise list` is reachable on the formal chain
  - `list -> detail` is verified through controlled missing-entity business `404`
- Current boundary:
  - because current list response is empty and home cards are placeholder-disabled, this round does not claim that an existing real enterprise entity was fully walked from home card into a populated detail page
  - this round only claims that the formal integration path exists and the runtime now exposes business responses instead of route absence

## Risk Retention Items
- Current retained risks:
  - home three-card entries are still placeholder-disabled, not active live cards
  - list and recommendation routes currently expose empty-state
  - no real enterprise entity was available in this round to prove a populated detail rendering chain
  - application-side write flow still depends on real account and organization context
  - `401 / 400 / 404 / empty-state` remain expected visible middle states under the current dependency freeze

## Current Formal Decision
- Current integration decision:
  - `allowed with risk`
- Current release-prep decision:
  - `not allowed`
- Current release decision:
  - `not allowed`
- Mandatory explicit statement:
  - `release-prep` remains blocked and is still not allowed in this round

## Next Single Action
- The next single action is:
  - keep `enterprise_hub V1` in bounded `integration with risk` while waiting for real entity data and real organization-context prerequisites before any future `release-prep` gate review
