---
owner: Codex 总控
status: draft
purpose: Record the historical Phase 2.4 per-object closed-round baseline before later dedicated object addenda superseded some current ceilings.
layer: L0 SSOT
---

# Phase 2.4 单对象决策表

## Stage Rule
- Phase 2.4 allows truth clarification and truth freeze only.
- Phase 2.4 does not allow any implementation development.
- After Phase 2.4, the next implementation round may unlock at most one object.
- This file now serves as a historical closed-round baseline record only.
- It must not override any later dedicated object addendum that supersedes a
  current object ceiling.

## Current Decision
- `Inspection`, `Rating`, and `Dispute` have completed their currently approved rounds and are closed with evidence.
- `Contract` is the only object currently eligible for `Phase 3` planning.
- `Contract` is not unlocked for implementation by this table alone.
- For any object whose current ceiling is later re-frozen by a dedicated
  addendum, this table no longer defines the current ceiling.
- For `Rating`, the current effective ceiling is governed only by
  `docs/00_ssot/rating_entry_minimal_action_contract_permission_addendum.md`.

## Contract
| Item | Decision |
|---|---|
| 业务语义 | Minimum self-contained contract workflow after `Order.active`; this includes detail read, first confirm handoff, and one minimum amendment handoff only |
| 最小前置条件 | `Order.state = active`; a valid `orderId` exists; current contract entry state is `pending_confirm` |
| 下一阶段只放到哪一层 | `full workflow` for `Contract` only, but not unlocked for implementation by this table alone |
| 允许的 app-facing path | `GET /api/app/contract/detail`, `POST /api/app/contract/confirm`, `POST /api/app/contract/amend` |
| 明确不允许的 path | `POST /api/app/contract/create`, `GET /api/app/contract/clauses`, `POST /api/app/contract/sign`, `GET /api/app/contract/history`, `GET /api/app/contract/list`, `POST /api/app/contract/legal-review` |
| 是否接受 GET 惰性创建 | `No` for next-stage canonical semantics. Phase 2.3 runtime behavior is tolerated as transitional implementation only and must not become product semantics or contract truth. See `docs/00_ssot/contract_object_decision_addendum.md`. |
| 最小审计动作 | `ContractConfirmed`, `ContractAmended` |
| 前端页面类型 | `read-only` for detail, `minimal action` for confirm and amend |

## Inspection
| Item | Decision |
|---|---|
| 业务语义 | Minimum closed-loop acceptance workflow after `Milestone.submitted`; this includes one first decision, at most one rectification, and at most one recheck, but not list/history/governance expansion |
| 最小前置条件 | `Milestone.state = submitted`; a valid `milestoneId` exists; new materialized inspection truth starts at `draft`; one `milestoneId` maps to at most one current effective inspection truth |
| 下一阶段只放到哪一层 | `full workflow` for `Inspection` only, but not unlocked for implementation by this table alone |
| 允许的 app-facing path | `GET /api/app/inspection/detail`, `POST /api/app/inspection/submit`, `POST /api/app/inspection/recheck` |
| 明确不允许的 path | `POST /api/app/inspection/create`, `POST /api/app/inspection/approve`, `POST /api/app/inspection/reject`, `GET /api/app/inspection/history`, `GET /api/app/inspection/list`, `POST /api/app/inspection/review` |
| 是否接受 GET 惰性创建 | `No` for canonical product semantics. Phase 2.3 runtime behavior is transitional only. See `docs/00_ssot/inspection_object_decision_addendum.md`. |
| 最小审计动作 | `InspectionSubmitted`, `InspectionDecisionChanged`, `InspectionRecheckSubmitted`, plus `MilestoneCompleted` / `OrderCompleted` when the pass path reaches the upstream completion boundary |
| 前端页面类型 | `read-only` for detail, `minimal action` for submit and recheck |

## Rating
| Item | Decision |
|---|---|
| 当前效力 | Historical closed-round baseline only. This section no longer defines the current `Rating` ceiling or current `rating submit` boundary. Current effective ceiling truth is defined only by `docs/00_ssot/rating_entry_minimal_action_contract_permission_addendum.md`. |
| 业务语义 | Historical Phase 2.4 baseline: rating entry visibility only; this is an `order`-level entry object; users may see whether rating entry exists or is available, but may not complete the rating workflow yet |
| 最小前置条件 | Historical Phase 2.4 baseline: a valid `orderId` exists; `Order` first enters `completed` as the unique upstream gate event; before that event, missing truth must not be auto-created by GET; after that event, persisted rating truth must still exist or the entry remains controlled unavailable |
| 历史关闭轮次 ceiling | Historical Phase 2.4 closed-round ceiling only: `entry/read`; this row must not be read as the current `Rating` ceiling |
| 历史关闭轮次允许的 app-facing path | Historical Phase 2.4 allowed path only: `GET /api/app/rating/entry` |
| 历史关闭轮次明确不允许的 path | Historical Phase 2.4 forbidden path only: `POST /api/app/rating/submit`, `GET /api/app/rating/detail`, `GET /api/app/rating/history` |
| 是否接受 GET 惰性创建 | `No` for canonical product semantics. Entry read may not be described as object creation. See `docs/00_ssot/rating_object_decision_addendum.md`. This readability semantics remains governed by later dedicated Rating truth and is not rolled back by this historical table. |
| 最小审计动作 | Historical Phase 2.4 baseline only: `RatingSubmitted` remained an internal audit boundary only and was not yet an app-facing action in that closed round |
| 前端页面类型 | Historical Phase 2.4 baseline only: `read-only` |

## Dispute
| Item | Decision |
|---|---|
| 业务语义 | `order`-level explicit dispute entry; the already-closed historical round froze `dispute/open` only, and the next planned round may add only `withdraw existing opened dispute` as the minimum governance action, not negotiation, platform review, escalation, or resolution workflow |
| 最小前置条件 | historical open preconditions remain: a valid `orderId` exists; `Order.state` is dispute-open-eligible (`active` or `completed`); dispute truth is created explicitly only when the canonical open command succeeds. Next planned withdraw preconditions must follow `docs/00_ssot/dispute_entry_minimal_governance_action_addendum.md`. |
| 下一阶段只放到哪一层 | `entry+minimal action` but not unlocked for the current round |
| 允许的 app-facing path | historical round: `POST /api/app/dispute/open`; next planned round, if separately unlocked, may add only `POST /api/app/dispute/withdraw` |
| 明确不允许的 path | `POST /api/app/dispute/create`, `GET /api/app/dispute/detail`, `GET /api/app/dispute/list`, `POST /api/app/dispute/resolve`, `POST /api/app/dispute/escalate`, `POST /api/app/dispute/review`, `GET /api/app/dispute/history` |
| 是否接受 GET 惰性创建 | `No`. Dispute creation must remain explicit through `POST /api/app/dispute/open`; no proactive materialize, GET lazy create, or alternate create path is accepted as product semantics. See `docs/00_ssot/dispute_object_decision_addendum.md`. |
| 最小审计动作 | historical round: `DisputeOpened`; next planned round, if separately unlocked, may add only `DisputeWithdrawn` |
| 前端页面类型 | `minimal action` |

## Next-round Unlock Rule
- No new implementation round is unlocked by this table alone.
- The currently planned object and range must follow the latest approved stage gate and object decision addendum.
- For the current planning line, `Dispute` is limited to `entry + minimal governance action` only and remains implementation-locked until a new stage gate explicitly approves it.

## Non-goals
- No four-object parallel implementation unlock.
- No full workflow expansion for `Rating` or `Dispute`.
- No silent unlock of `Contract` implementation before a dedicated Phase 3 gate.
- No silent conversion of transitional runtime behavior into formal product semantics.
