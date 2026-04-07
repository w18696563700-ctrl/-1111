---
title: 黑白名单与永久封禁规则 V1 App 对齐冻结稿
doc_type: ssot_addendum
status: draft
owner: Codex 总控
updated_at: 2026-04-01
purpose: Freeze the App-aligned governance rules for whitelist, watchlist, blacklist, permanent-ban, penalty, and appeal semantics without inventing a second permission truth, a second identity truth, or a second organization state machine.
---

# 1. Scope

This addendum freezes the App-aligned baseline for:

- whitelist semantics
- watchlist and blacklist semantics
- permanent-ban semantics
- penalty and appeal governance semantics
- visibility and permission interaction rules

This addendum does not:

- approve implementation by itself
- freeze a new route family end to end
- define a second role system
- define a second identity or organization truth
- override current active board freeze or active app-facing contracts

# 2. Upstream references

This addendum is subordinate to and aligned with:

- [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md)
- [account_login_identity_permission_minimum_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/account_login_identity_permission_minimum_freeze_addendum.md)
- [permission_matrix.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/permission_matrix.md)
- [platform_capability_unified_baseline_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/platform_capability_unified_baseline_addendum.md)
- [review_ticket_risk_governance_baseline_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/review_ticket_risk_governance_baseline_addendum.md)
- [project_publish_board_boundary_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/project_publish_board_boundary_freeze_addendum.md)
- [identity_permission_minimum_contracts.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/identity_permission_minimum_contracts.yaml)
- [openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)
- [exhibition_trade_governance_four_documents_app_aligned_freeze_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_app_aligned_freeze_v1.md)

# 3. Current App truth alignment

The current repo already freezes the following truth owners:

- identity and account access truth
- `organization` and `organization_members` truth
- `roleKeys` truth
- `certificationStatus` truth
- `permission_matrix.md` as formal permission mapping baseline
- `Server` as the only owner of governance truth
- `BFF` as app-facing aggregation only

Therefore this document must not:

- turn blacklist or whitelist into a replacement for `roleKeys`
- turn penalty state into a replacement for `certificationStatus`
- turn permanent ban into a fake replacement for `organization` disabled truth
- turn `BFF` into the owner of penalty, ban, or appeal state

# 4. Governance object position

Whitelist, watchlist, blacklist, permanent ban, penalty, and appeal are frozen
here as governance overlays.

They are not:

- identity truth
- role truth
- organization truth
- route-family truth by themselves

They are governance overlays that may affect:

- visibility
- eligibility summary
- action blocking
- admin review and adjudication
- audit and evidence handling

# 5. Product-layer labels versus backend truth

The product-language concepts below may exist:

- trusted enterprise
- watchlisted subject
- blacklisted subject
- permanently banned subject
- under appeal

These labels are presentation or governance labels only.

They must not be persisted as a hidden replacement for:

- `buyer_admin`
- `supplier_admin`
- platform review roles
- organization active or disabled state
- certification lifecycle state

# 6. Whitelist rule

The whitelist in this document means a governance-recognized high-trust or
special-exposure label only.

It may later support:

- exposure boost
- higher display weight
- controlled feature-entry widening
- operator-reviewed special exposure

It must never:

- bypass `permission_matrix.md`
- grant a forbidden transaction action without the required role
- override active certification failure
- override an active severe penalty
- become a plaintext production backdoor

If a future round uses whitelist-based narrowing or widening, it must remain
subordinate to:

- approved config control
- approved exposure scope
- current permission truth
- current organization and certification truth

# 7. Watchlist and blacklist rule

Watchlist and blacklist are frozen as governance classifications.

Watchlist means:

- observation state
- higher review sensitivity
- possible exposure reduction
- possible qualification recheck

Blacklist means:

- explicit governance restriction state
- one or more action blocks are active
- additional review may be required before recovery

Neither watchlist nor blacklist may directly mutate business truth by shortcut.

Any effective restriction must still be consumed through formal `Server`
governance action, review action, or controlled permission gate wiring.

# 8. Permanent-ban rule

Permanent ban is reserved for severe malicious cases only.

Examples that may qualify in future governed rounds:

- forged enterprise identity
- fake-project fraud confirmed by governance
- forged contract or acceptance evidence
- repeated account or organization circumvention after penalty
- severe harassment, extortion, or threat confirmed by governance

Permanent ban must not be:

- a convenience flag used for ordinary quality issues
- a shortcut replacement for suspended review
- a hidden substitute for organization disablement

Permanent ban must always carry:

- clear governed object reference
- reason classification
- evidence reference set
- operator attribution
- decision timestamp
- appeal availability or explicit no-appeal policy if later formally frozen

# 9. Appeal rule

Appeal is frozen as a governance right-path concept where punishment exists.

This document accepts the necessity of:

- appeal entry
- appeal review
- appeal result attribution
- appeal audit trail

But this document does not yet freeze:

- a dedicated exhibition transaction appeal route family
- user-facing appeal page contracts
- admin appeal detail contracts

Until those are formally frozen, no agent may claim that full appeal runtime
already exists for the exhibition transaction chain.

# 10. Current route-family boundary

Current App truth already uses:

- `/api/app/*` for app-facing APIs
- `/server/admin/*` for admin-governed actions
- `BFF` only for aggregation or shaping

This document therefore freezes the following boundary:

- any future whitelist, blacklist, penalty, or appeal app-facing route must stay
  under `/api/app/*`
- any future admin-side penalty, blacklist, permanent-ban, or appeal operation
  must stay under `/server/admin/*`
- no naked `/risk/*`, `/penalty/*`, `/appeal/*`, `/ban/*`, `/orgs/*`, or
  `/me/*` route family may be invented outside the existing path constitution

Current route-family listing in blueprint or alignment docs is for App
alignment only.

It does not mean the current round auto-unlocks:

- bid implementation
- order implementation
- contract back-chain implementation
- penalty implementation
- appeal implementation

If any route-family interpretation conflicts with an active board freeze, the
active board freeze wins.

# 11. Current profile-building boundary

The current profile building may later surface:

- eligibility summary
- governance summary
- penalty summary
- appeal entry
- rule-center entry

But concretely present truth today remains narrower.

Current concretely present profile-side truth is still centered on:

- login and account access
- organization handoff
- certification current state
- company view
- session center

Therefore agents must not describe the profile building as already having:

- a finished penalty center
- a finished appeal center
- a finished blacklist center
- a finished whitelist governance dashboard

# 12. Current admin-side anchor

The current minimum formal admin anchor relevant to risk and governance remains:

- `GET /server/admin/security-events`

This anchor proves that minimum governance and security review traces exist in
current truth.

It does not by itself prove that full exhibition transaction penalty,
blacklist, or appeal runtime has already been frozen.

# 13. Interaction with permission truth

Penalty, blacklist, and permanent-ban decisions may later affect whether a user
can:

- publish project
- bid
- comment
- message
- upload contract
- submit milestone or inspection actions

But the effect must be expressed through formal eligibility and permission
consumption, not by bypassing the underlying truth model.

That means:

- `permission_matrix.md` remains the formal permission mapping baseline
- `roleKeys` remain the role truth
- `certificationStatus` remains certification truth
- governance restriction remains an overlay consumed by `Server`

# 14. Interaction with fake-project adjudication

This document is downstream of
[fake_project_report_and_adjudication_rules_v1_app_aligned_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/fake_project_report_and_adjudication_rules_v1_app_aligned_freeze_addendum.md).

That means:

- fake-project report handling may trigger temporary stop-loss restriction first
- final blacklist or permanent-ban handling belongs to later governed penalty
  flow, not to the report object itself
- report-case truth must not secretly expand into a complete penalty truth

# 15. Interaction with contract and fulfillment governance

This document is also downstream of
[contract_archive_and_mandatory_fulfillment_chain_rules_v1_app_aligned_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/contract_archive_and_mandatory_fulfillment_chain_rules_v1_app_aligned_freeze_addendum.md).

That means:

- fulfillment quality and archive completeness may later become governance
  evidence
- they may contribute to trust, watchlist, or penalty judgement in future rounds
- but they do not auto-create a live trust-score object in the current round

# 16. Minimum frozen semantics

The following semantics are now frozen:

1. Whitelist is governance or exposure semantics only, not permission truth.
2. Blacklist is governance restriction semantics only, not identity truth.
3. Permanent ban is severe-malice governance semantics only, not a shortcut
   replacement for core organization-state handling.
4. Appeal is required in principle where punishment exists, but its exhibition
   transaction runtime family is not yet fully frozen.
5. `Server` is the only owner of penalty, ban, and appeal truth once later
   implemented.
6. `BFF` may only expose shaped summaries and blocked-action responses.

# 17. Explicit non-goals for this round

This document does not freeze:

- a full trust-score model
- a full whitelist scoring system
- a full exhibition transaction penalty object family
- a full user-facing blacklist detail page
- a full app-facing appeal contract family
- a full admin appeal console contract family
- a permanent-ban recovery workflow beyond future governed exception handling

# 18. Acceptance bar for this document

This document is accepted only as an App-aligned governance freeze when the
following statements remain true:

- no second role or permission truth is introduced
- no second identity or organization truth is introduced
- no naked route family is invented outside `/api/app/*` and `/server/admin/*`
- no agent may claim that whitelist or blacklist runtime is already fully
  implemented in the current repo
- any future implementation must first freeze contracts and stage gates

# 19. Final conclusion

This addendum freezes the current App-aligned baseline for whitelist,
watchlist, blacklist, permanent-ban, penalty, and appeal semantics as
governance overlays only.

It explicitly does not freeze a complete runtime package yet.

The next allowed downstream step is:

- freeze the concrete blacklist, penalty, and appeal contract family against the
  current App truth before any implementation prompt bundle is approved
