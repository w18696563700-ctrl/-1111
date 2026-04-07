---
owner: Codex 总控
status: draft
purpose: Freeze one upstream mother blueprint for the four governance documents around exhibition project publish, bidding, fulfillment, and disciplinary governance, without yet turning the blueprint into a direct implementation contract.
layer: L0 SSOT
---

# 展览项目发布-竞标-履约治理四文书治理母蓝图 V1

## 1. Scope
- This file is the shared upstream governance blueprint for the following four
  downstream documents only:
  - 《账户与企业认证规则 V1》
  - 《假项目举报与裁决规则 V1》
  - 《合同归档与履约强制入链规则 V1》
  - 《黑白名单与永久封禁规则 V1》
- This file freezes:
  - shared governance goals
  - shared platform principles
  - shared actor, evidence, and enforcement skeleton
  - the common product target state for the four documents
- This file does not by itself:
  - approve implementation
  - approve release
  - override already accepted route or contract truth
  - rename existing backend truth in the current repo

## 2. One-line Goal
- Upgrade the exhibition publish-bid-fulfillment container from a feature set
  into a governed transaction platform with:
  - access qualification
  - evidence retention
  - process traceability
  - report and adjudication ability
  - disciplinary and appeal ability

## 3. Mother Principles
- Light browsing, heavy governance:
  - low-risk browsing stays light
  - high-risk actions must enter qualification, filing, evidence, and audit
- `我的` is not a cosmetic profile page:
  - it is the identity, organization, qualification, and governance hub
- Order first, finance later:
  - V1 focuses on identity, project authenticity, contract filing,
    fulfillment-chain traceability, acceptance, report, and penalty
- Offline construction may happen:
  - but online disappearance is not acceptable after cooperation starts
- Critical actions must be replayable:
  - actor
  - object
  - time
  - state before and after
  - evidence
  - notice
- Rules must be systemic:
  - trigger
  - required evidence
  - system action
  - manual review action
  - result notice
  - appeal entry
  - restore condition
- Permanent ban is exceptional:
  - only for severe malicious or fraudulent conduct
- Personal information remains minimum necessary:
  - no speculative over-collection

## 4. Product Target Structure
- Keep the current main-shell direction:
  - `展览`
  - `消息`
  - `我的`
- Their target governance responsibilities are:
  - `展览`
    - project display
    - project detail
    - publish entry
    - bid entry
    - award continuation
    - fulfillment continuation entry
  - `消息`
    - platform notices
    - transaction notices
    - report progress notices
    - acceptance and dispute notices
  - `我的`
    - account
    - organization
    - certification
    - qualification status
    - risk and penalty status
    - appeal and rules center

## 5. Shared Governance Tiers
- The mother blueprint accepts the following product-layer governance tiers:
  - `U0`
    - visitor
  - `U1`
    - individually verified user
  - `U2`
    - enterprise-certified transaction user
  - `U3`
    - high-trust enterprise
- These tiers are governance labels only in this file.
- They are not yet declared here as:
  - formal backend role keys
  - formal persistence columns
  - formal shell context fields

## 6. Shared Platform Roles
- The mother blueprint accepts the following governance workbench roles:
  - certification reviewer
  - project reviewer
  - risk reviewer
  - adjudicator
  - appeal reviewer
  - auditor
- These roles are governance responsibilities only in this file.
- Formal admin-role mapping must be aligned later against the current repo
  truth.

## 7. Shared Evidence-chain Rule
- All four documents must share one evidence-chain mindset.
- Evidence sources may include:
  - identity materials
  - organization materials
  - project materials
  - bid materials
  - contract materials
  - fulfillment logs
  - acceptance materials
  - payment materials
  - chat records
  - notices
  - system logs
  - report attachments
- All evidence must satisfy:
  - object-bound
  - verifiable origin
  - replayable snapshot

## 8. Common Governance Object Skeleton
- The mother blueprint accepts the following shared object families in concept:
  - identity and organization qualification objects
  - project authenticity and report-case objects
  - contract and fulfillment archive objects
  - risk, trust, penalty, ban, and appeal objects
- The mother blueprint does not yet freeze:
  - final table names
  - final route names
  - final OpenAPI payload shapes

## 9. Document A Target State
- 《账户与企业认证规则 V1》 must answer:
  - who may act
  - who may represent an enterprise
  - how the platform may hold the actor accountable
- Its target layers are:
  - phone-account entry
  - person verification
  - enterprise certification
  - responsible-person or authorized-actor binding
  - business qualification supplements
- Its target result is:
  - qualification gates become enforceable at action time

## 10. Document B Target State
- 《假项目举报与裁决规则 V1》 must answer:
  - how a fake or misleading project is reported
  - how the platform freezes risk before final judgement
  - how the platform adjudicates and notifies
- Its target case flow is:
  - report submitted
  - preliminary review
  - temporary freeze when risk is high
  - explanation window
  - adjudication
  - appeal or closure
- Its target result is:
  - one-step stop-loss for high-risk project objects

## 11. Document C Target State
- 《合同归档与履约强制入链规则 V1》 must answer:
  - how cooperation stops disappearing off-platform after award
  - how contract filing becomes the first evidence anchor
  - how fulfillment records become trust assets
- Its target rule is:
  - offline signing may exist
  - but platform filing and bilateral confirmation remain mandatory
- Its target fulfillment chain is:
  - award
  - contract pending
  - contract uploaded
  - contract confirmed
  - in fulfillment
  - acceptance
  - archive

## 12. Document D Target State
- 《黑白名单与永久封禁规则 V1》 must answer:
  - how trust is promoted
  - how risk is contained
  - how severe malice is permanently removed
  - how appeal remains available for wrongful punishment
- Its target list families are:
  - whitelist
  - gray watchlist
  - blacklist
  - permanent-ban network
- Its target result is:
  - systemic, traceable, appealable discipline

## 13. Shared Engines Required By All Four Documents
- qualification engine
- rule engine
- notice engine
- audit engine
- evidence and file center

## 14. Shared Boundary Rules
- The four documents must not create:
  - a second app shell
  - a second project truth owner
  - a second attachment truth
  - a second permission system
  - a manual-memory-only penalty process
- All governance actions must be:
  - object-linked
  - stateful
  - auditable
  - appeal-aware where punishment exists

## 15. Shared Implementation Order
1. Identity and organization qualification baseline
2. Action-level eligibility interception
3. Project report intake and risk freeze
4. Contract filing and bilateral confirmation
5. Fulfillment logs and acceptance chain
6. Penalty and appeal center
7. Admin workbenches
8. Trust promotion and scoring enhancement

## 16. Execution Constraints For Downstream Agents
- Do not overturn the current shell and building architecture.
- Put the governance main entry under `我的`.
- Let transaction pages own action interception only.
- Build rule mainlines before UI embellishment.
- Every new governance object needs an explicit state family.
- Every penalty action needs an appeal path for wrongful judgement scenarios.

## 17. Conclusion
- This file is the mother blueprint only.
- It freezes direction and shared governance structure.
- It must be followed by:
  - an App-alignment diff
  - an App-aligned freeze
  - later contract and implementation packages
