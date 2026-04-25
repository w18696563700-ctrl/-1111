---
owner: Codex 总控
status: frozen
layer: L0 task record
scheduled_days:
  - 2026-06-01
  - 2026-06-02
recorded_at_local: 2026-04-25
purpose: Record the next Server-stage tasks for completed-order counterparty rating gating and credit shadow/ledger closure.
---

# Project Transaction Lifecycle Day32-Day33 Rating / Credit Server Task Record

## 1. Conclusion

This is a formal task record only.

No new Server/BFF/Flutter implementation is executed in this record. The next execution round must treat the current repository evidence as a baseline, not as production completion.

Current decision:

- 2026-06-01 can start only as a Server-side hardening round for `ProjectCounterpartyRating` gating.
- 2026-06-02 can start only after Day32 proves completed-order-only, boundary-only, and duplicate-direction rejection.
- Full acceptance remains blocked until two valid business accounts and a completed `ProjectOrder` fixture are available through the 8080 tunnel.

## 2. Scheduled Work

| Date | Owner | Task | Deliverable | Acceptance |
|---|---|---|---|---|
| 2026-06-01 周一 | Server | 加固双方互评：只允许 completed order；一方对另一方一次 | `ProjectCounterpartyRating` gating | 非 completed order 被拒绝；订单外组织被拒绝；同一 `orderId + raterOrganizationId + rateeOrganizationId` 重复提交被拦截。 |
| 2026-06-02 周二 | Server | 信用 bridge 正式闭环：rating truth -> shadow recompute/ledger | credit trigger / ledger | 提交评价后可查到 `organization_shadow_credit_recompute_triggers` 和 `organization_shadow_credit_ledgers` 对应触发。 |

## 3. Current Baseline From Existing Truth

Frozen truth already states:

- `ProjectCounterpartyRating` must carry `orderId / projectId / raterOrganizationId / rateeOrganizationId / raterUserId`.
- Rating eligibility requires `ProjectOrder.state = completed`.
- Unique direction is `orderId + raterOrganizationId + rateeOrganizationId`.
- Credit bridge consumes `ProjectCounterpartyRating` truth only.
- No chat, album, BFF DTO, or Flutter local flag may trigger credit directly.

Existing code/test scan shows a baseline implementation exists for:

- completed-order entry logic
- submit persistence and audit
- reverse direction allowance
- duplicate direction rejection
- outside order boundary rejection
- credit shadow bridge invocation after submit

This baseline is useful, but it does not close Day32/Day33 by itself because cloud real-session and DB ledger verification remain unproven.

## 4. Day32 Required Server Hardening

Day32 must verify or add the following without widening scope:

- `GET /server/project-counterparty-rating/entry`
  - requires `orderId / projectId / rateeOrganizationId`
  - returns `canRate=false` with controlled reason when order is not completed
  - returns `canRate=false` with controlled reason when the same direction already has a submitted rating
- `POST /server/project-counterparty-rating/submit`
  - rejects missing anchors with `PROJECT_COUNTERPARTY_RATING_INVALID`
  - rejects non-completed order with `PROJECT_COUNTERPARTY_RATING_UNAVAILABLE`
  - rejects ratee outside `buyerOrganizationId / sellerOrganizationId` boundary with `PROJECT_COUNTERPARTY_RATING_FORBIDDEN`
  - rejects duplicate direction with `PROJECT_COUNTERPARTY_RATING_DUPLICATE`
  - writes exactly one submitted truth row for the allowed direction
  - records audit event `ProjectCounterpartyRatingSubmitted`

No-Go:

- Do not reuse old one-way `/rating/submit` as proof of the new counterparty-rating truth.
- Do not allow rating before `ProjectOrder.state = completed`.
- Do not create a BFF-side rating state machine.
- Do not make Flutter infer rating eligibility locally.

## 5. Day33 Required Credit Bridge Closure

Day33 must verify or add the following:

- `ProjectCounterpartyRatingService.submit` triggers credit recompute for `rateeOrganizationId`.
- Bridge payload must include:
  - `organizationId = rateeOrganizationId`
  - `sourceType = project_counterparty_rating`
  - `sourceOrderId = orderId`
  - `sourceRatingId = ratingId`
  - `triggeredAt`
- `CreditScoringShadowAggregationService` must consume `project_counterparty_ratings` as formal rating input.
- `project_counterparty_ratings.score_value` must not be treated directly as a 0-100 credit score.
- The engine must append / update:
  - `organization_shadow_credit_recompute_triggers`
  - `organization_shadow_credit_ledgers`
  - `organization_shadow_credit_aggregates`

Cloud acceptance must prove the DB side, not only service return payload.

## 6. Minimum Acceptance Probe Packet

Required real or seeded data:

- Buyer organization account with valid app session.
- Seller organization account with valid app session.
- One `ProjectOrder` with:
  - `state = completed`
  - matching `projectId`
  - matching `buyerOrganizationId`
  - matching `sellerOrganizationId`
- Two ratee targets:
  - buyer -> seller
  - seller -> buyer

Minimum successful sequence:

1. Buyer reads rating entry for seller and sees `canRate=true`.
2. Buyer submits rating for seller.
3. Duplicate buyer -> seller submit is rejected with `PROJECT_COUNTERPARTY_RATING_DUPLICATE`.
4. Seller reads rating entry for buyer and sees `canRate=true`.
5. Seller submits rating for buyer.
6. DB query proves both direction truth rows exist.
7. DB query proves credit recompute trigger and ledger row exist for each ratee organization.

Minimum rejection sequence:

1. Active/non-completed order submit is rejected.
2. Outside organization submit is rejected.
3. Missing `orderId/projectId/rateeOrganizationId` is rejected.

## 7. Relationship To Day31 Blocker

Day31 is still a blocker for full production acceptance because the second available app instance resolved to `demo-user` and did not have a valid project communication conversation.

Day32/Day33 Server hardening can still be prepared and locally tested, but the final 100% closure requires:

- two valid logged-in business actors
- the same completed `ProjectOrder`
- 8080 tunnel route access
- DB-level credit trigger / ledger verification

## 8. Current Minimum Closure / Retained Future Work

Current minimum closure for the next execution round:

- lock rating eligibility to completed order
- lock rating direction uniqueness
- lock credit bridge to rating truth
- prove DB trigger / ledger after submit

Need to retain but not open in this slice:

- public credit score exposure
- moderation / appeal workflow
- rating history list
- credit penalty/reward actioning
- settlement, invoice, wallet, or guarantee deposit linkage

Future extension points:

- rating history read model
- dispute / appeal attachment
- admin moderation queue
- public credit profile projection
- richer score dimensions after the one-direction truth is stable

## 9. Stability / Cost / Stage Fit

- More stable: keep `ProjectOrder` as the only completion gate and `ProjectCounterpartyRating` as the only rating truth.
- More cost-efficient: first harden Server gates and DB proof, then let BFF/Flutter consume existing routes.
- More suitable for the current stage: Server-only verification plus cloud DB proof before adding UI surfaces.
- Higher risk: claiming credit bridge completion from old `/rating/submit`, from unauthenticated route probes, or from local mocks without real DB ledger rows.
