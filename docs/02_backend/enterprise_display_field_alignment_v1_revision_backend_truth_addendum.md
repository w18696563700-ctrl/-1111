---
owner: Codex 总控
status: frozen
purpose: Freeze backend truth scope for the V1.0 revised enterprise display field-alignment execution package.
layer: L2 Backend
freeze_date_local: 2026-04-18
inputs_canonical:
  - apps/server/src/modules/enterprise_hub/enterprise-hub-query.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-workbench.presenter.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-published-change-support.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-published-change-live-write.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub.presenter.ts
---

# Enterprise Display Field Alignment V1 Revision Backend Truth

## 1. Backend Truth Objective

- Make owner boundaries explicit for:
  - public list/detail
  - workbench edit
  - published change
  - media semantics

## 2. Current Truth Already Established

- `public list/detail` read from published listing truth through `EnterpriseHubQueryService`.
- `workbench` reads listing + certification + contact + cases + readiness through workbench presenter.
- `published change` already separates:
  - live snapshot
  - current change request
  - editable snapshot payload
- live apply already merges change snapshot into listing/profile/case/contact truth through `EnterpriseHubPublishedChangeLiveWriteService`.

## 3. Backend Rules Frozen In This Round

1. Workbench truth is edit-domain truth, not public live truth.
2. Public list/detail truth is published-domain truth.
3. Published change remains the only post-publish edit corridor.
4. Media owner separation must be enforced at owner level:
   - enterprise logo
   - enterprise cover
   - enterprise gallery
   - case cover / case media
5. Presenter fallback may not permanently mask owner ambiguity.

## 4. Current Drift Explicitly Recorded

- Public detail media still allows display fallback patterns that can blur:
  - cover
  - gallery
  - logo
  - case cover
- That drift is recorded as implementation debt, not accepted truth.

## 5. Allowed Backend Write Set For Gate 2

- `apps/server/src/modules/enterprise_hub/enterprise-hub.presenter.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub-query.service.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub-workbench.presenter.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub-published-change-*.ts`
- board/profile media or projection helpers under the same module

## 6. Anti-revert

- Do not collapse live/change into one carrier.
- Do not let public presenter redefine owner semantics.
- Do not let case media backfill enterprise gallery semantics.
