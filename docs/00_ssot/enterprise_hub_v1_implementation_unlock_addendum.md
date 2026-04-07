---
owner: Codex 总控
status: draft
purpose: Freeze the bounded implementation unlock for enterprise_hub V1 after the current App-aligned truth and contract package are in place, while preserving all retained veto boundaries.
layer: L0 SSOT
---

# Enterprise Hub V1 Implementation Unlock Addendum

## Scope
- This addendum applies only to:
  - `enterprise_hub V1`
- It freezes only:
  - the current implementation unlock decision
  - the current allowed implementation scope
  - the current retained veto items
- It does not by itself:
  - approve release
  - approve delivery completion
  - unlock other boards

## Current Unlock Object
- Current object:
  - `enterprise_hub V1`

## Current Allowed Scope
- Current implementation is allowed only for:
  - exhibition-home existing three-card upgrade:
    - `优秀公司`
    - `优秀工厂`
    - `优秀供应商`
  - app-facing enterprise-hub V1 surfaces:
    - list
    - detail
    - recommendation
    - application create / edit / submit / status
  - server-admin enterprise-hub V1 surfaces:
    - review
    - publish
    - offline
    - freeze
  - matching BFF aggregation and Server truth needed to support those surfaces
- Known frozen dependency not yet completed (do not treat as release-ready condition):
  - Real account / organization context for enterprise_hub application & detail pages is not fully wired in production runtime.
  - Permission-denied (`ENTERPRISE_HUB_PERMISSION_DENIED`) under no-org-context scenarios is expected in the current stage.

## Retained Veto Gates
- no seventh home container
- no new shell building
- no trading flow
- no IM
- no deep map capability
- no second enterprise identity truth
- no `/bff/*` product contract family
- no drift beyond frozen docs and contracts
- no bypass around `organization / certification / FileAsset` truth

## Current Unlock Conclusion
- Current formal conclusion:
  - bounded implementation unlock is granted for `enterprise_hub V1`
  - release-prep remains not approved
  - release execution remains not approved

## Current Meaning
- Current approved meaning:
  - implementation may start within the frozen current boundary only
- Current non-approved meaning:
  - no release approval
  - no new business surface outside the current package
  - no path-family expansion outside the frozen contract set

## Next Action
- The next single action is:
  - execute bounded implementation dispatch under the current frozen package
