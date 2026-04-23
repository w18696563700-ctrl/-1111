---
owner: Codex 总控
status: frozen
purpose: >
  Assess whether `Trading IM participant-card minimum` may qualify as a Phase 0
  bounded implementation exception candidate, while granting neither exception
  unlock nor implementation permission.
layer: L0 SSOT
freeze_date_local: 2026-04-23
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/trading_im_round_a_truth_freeze_addendum.md
  - docs/00_ssot/trading_im_round_a_result_verification_and_closure_addendum.md
  - docs/00_ssot/trading_im_participant_card_minimal_package_level_implementation_unlock_assessment_addendum.md
  - docs/00_ssot/trading_im_participant_card_minimal_g0b_reentry_stage_gate_checklist_addendum.md
  - docs/00_ssot/trading_im_participant_card_minimal_truth_freeze_addendum.md
  - docs/01_contracts/trading_im_participant_card_minimal_contract_freeze_addendum.md
  - docs/02_backend/trading_im_participant_card_minimal_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/trading_im_participant_card_minimal_bff_surface_freeze_addendum.md
---

# 《Trading IM participant-card minimum Phase 0 implementation exception assessment》

## 1. 评估对象

- 当前评估对象仅限：
  - `Trading IM participant-card minimum`
- 当前评估粒度仅限：
  - `Phase 0 implementation exception assessment`
- 本文不是：
  - `Phase 0 implementation exception unlock`
  - implementation unlock
  - Server/BFF implementation dispatch
  - runtime alignment execution
  - integration / `release-prep` / release

## 2. 当前已成立基础

- `participant-card minimum` 的 docs-only 冻结链已形成：
  - `G0B reentry stage gate`
  - `L0 truth freeze`
  - `L2 contract freeze`
  - `L3 backend truth freeze`
  - `L4 BFF surface freeze`
- 当前对象边界已冻结为：
  - `Trading IM Round A` 的 bounded read-only child object
  - 只读合作方名片
  - 只服务于 `bid thread` 内头像 / 公司名点击后的受控摘要查看
- 当前路径与真相 owner 已冻结：
  - app-facing path 仅限
    `GET /api/app/exhibition/trading/participant-card`
  - `Server` 仍是唯一 truth owner
  - `BFF` 仍非 truth owner

## 3. 当前为什么仍被 Phase 0 挡住

- `AGENTS.md` 仍明写：
  - `No trading flow implementation`
- Root 文书当前显式写出的 bounded implementation exception 仍是 forum；
  `participant-card minimum` 不会因为挂在既有 `Round A` 下就自动继承例外资格。
- `Trading IM Round A` 的已接受 closure 只覆盖原冻结对象：
  - project public clarification
  - project-bid private work thread
  - minimum confirmation card
  - messages-building reminder and jump-back
- 上述 closure 不包含 `participant-card minimum`；因此：
  - 旧 closure 不能替代本对象自己的 exception legality
  - 旧 closure 不能替代新的 implementation unlock
- 另外，当前 live `formal-info` path 仍表现为 router `404`。
  - 这不是当前 legality judgment 的核心根据。
  - 但它说明：即使未来给出 exception，当前对象也仍未到 runtime-ready。

## 4. 允许评估的最小 exception 范围

- 本次 exception assessment 只允许围绕以下最小候选范围展开：
  - `participant-card minimum` 的只读 query projection
  - `projectId + bidId + participantOrganizationId` 三元锚点
  - admitted thread participant visibility judgment
  - enterprise summary
  - bounded review summary
  - bounded formal-info summary
  - 既有 `formal-info` canonical path continuity
- 上述允许范围必须同时满足：
  - 不新增新 building
  - 不新增通用 profile center
  - 不新增 public credit scoring surface
  - 不新增 write command / lifecycle / audit family
  - 不把 `messages` building 升格为 truth owner

## 5. 保留 Veto

- `No trading flow implementation`
- forum 之外没有自动例外
- `Server` is the only business truth owner
- `BFF` never owns business truth
- `Flutter App -> BFF only`
- docs-frozen != implementation unlocked
- old Round A closure != new child-object legality grant
- live `formal-info` gap != already-runtime-closed

## 6. Exception Blocker List

- blocker 1：
  - root `Phase 0 Guardrail` 仍明确：
    - `No trading flow implementation`
- blocker 2：
  - 当前对象虽然是 read-only child object，但仍直接挂在交易主链的
    `project + bid + participant` 关系上，不属于 forum 类轻对象。
- blocker 3：
  - 当前 `package-level implementation unlock assessment` 已明确：
    - `package-level implementation unlock = No-Go`
    - `Server/BFF dispatch = No-Go`
- blocker 4：
  - 当前还没有 package-specific
    `Phase 0 implementation exception independent review`
    与 `review conclusion`
- blocker 5：
  - 当前尚无 package-specific `Phase 0 implementation exception unlock`
    文书本体
- blocker 6：
  - 当前 live `formal-info` 仍未形成 package-required runtime closure
  - 该项当前只作为 operational readiness gap，不单独承担 legality 裁决

## 7. Pass Conditions

- 若未来要把本评估从当前阻断态转为 `Pass for exception candidacy`，至少需要同时满足：
  1. 书面证明为何 `participant-card minimum` 可被视为
     forum 之外但仍足够有界的 `Phase 0` 例外候选
  2. 书面确认 exception scope 严格锁死在第 4 节
  3. 书面确认 `participant-card` 继续只是 query projection，不新增写入对象
  4. 书面确认 `messages / profile / enterprise_hub` 不升格为 participant-card
     truth owner
  5. 书面确认既有 `formal-info` canonical path 只做 continuity / alignment，
     不重造并行 route family
  6. 对本 assessment 形成独立复核，且复核没有新增 veto failure
  7. 后续若继续推进，必须再由总控单独出具
     `Phase 0 implementation exception unlock`

## 8. 当前评估结论

- 当前评估结论：
  - `No-Go for Phase 0 implementation exception candidacy`
- 当前结论含义：
  - 当前对象已具备进入 exception assessment 链的 docs 前提
  - 但尚不具备被写成 `Phase 0` 例外候选通过态的条件
- 当前结论不代表：
  - `apps/server` 可直接实现
  - `apps/bff` 可直接实现
  - runtime alignment 可直接执行
  - 当前已经进入 implementation unlock

## 9. 下一步唯一动作

- 下一步唯一动作：
  - 输出《Trading IM participant-card minimum Phase 0 implementation exception independent review》

## 10. Formal Conclusion

- 当前正式结论如下：
  - 本文只完成 `Trading IM participant-card minimum` 的
    `Phase 0 implementation exception assessment`
  - 当前正式裁决仍是：
    - `No-Go for Phase 0 implementation exception candidacy`
