---
owner: Codex 总控
status: frozen
purpose: >
  对 BidAward bridge 授予对象级、阶段级、后端优先的窄口交易流实现例外，
  仅用于解除 AGENTS.md 中 root guardrail 对当前对象当前阶段的直接阻断，
  不改写全局 Phase 0 护栏，不放开其他交易对象，也不自动放开 BFF、
  前端、集成、发布阶段。
layer: L0 SSOT
freeze_date_local: 2026-04-12
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/bid_award_bridge_root_guardrail_blocker_removal_planning_addendum.md
  - docs/00_ssot/bid_award_bridge_bounded_legality_grant_addendum.md
  - docs/00_ssot/bid_award_bridge_refreshed_package_level_implementation_unlock_review_conclusion_addendum.md
  - docs/00_ssot/bid_award_bridge_backend_implementation_dispatch_addendum.md
  - docs/02_backend/bid_award_bridge_backend_truth_persistence_freeze_addendum.md
---

# 《BidAward bridge root guardrail scoped implementation exception》

## 1. 当前例外对象

- 当前例外只对以下对象生效：
  - `BidAward bridge`
- 当前例外只覆盖以下冻结范围：
  - `BidAward truth`
  - `loser disposition truth`
  - `POST /api/app/bid/award`
  - `GET /api/app/bid/result?projectId={projectId}`
  - `BidAward -> Order conversion`
  - `synchronous contract seed`
  - `Project.state = awarded / converted_to_order`

## 2. 当前例外的唯一目的

- 当前例外只用于解除：
  - root `AGENTS.md`
    中
    `No trading flow implementation`
    对本对象、本阶段的直接阻断
- 当前例外不用于：
  - 改写全局 root guardrail
  - 为其他交易对象开口
  - 为 BFF / 前端 / 集成 / 发布阶段自动放行

## 3. 当前例外的阶段边界

- 当前例外只放行到：
  - `backend-first bounded implementation`
- 当前例外不自动放行：
  - `BFF implementation`
  - `frontend implementation`
  - `integration`
  - `release-prep`
  - `launch`

## 4. 当前例外继续绑定的硬边界

- 当前仍然严格禁止：
  - `seat`
  - `bid package completeness`
  - `payment / split-billing / billing / settlement`
  - `electronic signature`
  - `complex scoring`
  - `heavy risk control`
  - `full compare console`
  - `supplier bid workspace / my bids workspace`
  - 回退到 `/api/app/order/create`
- 当前仍然只允许：
  - backend-first 窄口实现
  - 严格按既有 dispatch 顺序施工

## 5. 当前例外不改变的全局规则

- 当前例外不改变以下全局规则：
  - `Flutter App` 只走 `BFF`
  - `BFF` 不拥有业务真相
  - `Server` 拥有业务真相与状态机
  - `Workbench / My Project / Showcase`
    继续是投影层，不得升格为真相层

## 6. 当前阶段直接放行结论

- 当前正式授予：
  - `BidAward bridge root guardrail scoped implementation exception`
- 当前正式进入：
  - `backend-first bounded implementation`

## 7. 当前仍然不放行的事项

- 当前不等于：
  - 全局交易流实现已解禁
  - BFF 已放行
  - 前端已放行
  - 集成已放行
  - 发布准备已放行

## 8. Formal Conclusion

- 当前对象级 root guardrail 阻断已被窄口解除
- 当前放行只对 `BidAward bridge` 的 backend-first bounded implementation 生效
- `Go for backend continuation`
- `No-Go for BFF implementation`
- `No-Go for frontend implementation`
- `No-Go for integration`
- `No-Go for release-prep`

## 9. Next Unique Action

- 下一步唯一动作：
  - 输出《BidAward bridge backend package-scoped validation baseline ruling addendum》
