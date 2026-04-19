# Profile Factory Display Entry Published Change Routing Truth Ruling Addendum

## Bound
- Scope is limited to `apps/mobile` profile asset entry routing.
- Only `我的工厂展示` entry behavior is adjusted.
- Public `优秀工厂` detail truth, server read models, and BFF contracts stay unchanged.

## Frozen Truth
- `我的工厂展示` remains an asset entry under `我的资产`.
- When the factory workbench already resolves a real `enterpriseId` and the latest application is in a post-submit state, the profile entry should prefer the published-change corridor over the generic workbench corridor.
- Post-submit states are:
  - `submitted`
  - `under_review`
  - `approved`
  - `revision_required`
  - `rejected`
- If the published-change status corridor is unavailable, the entry must fall back to the existing generic factory workbench route.

## Non-goals
- Do not alter public factory detail truth.
- Do not merge live approved cases with current-change draft cases.
- Do not change server case filtering or published-change persistence.
