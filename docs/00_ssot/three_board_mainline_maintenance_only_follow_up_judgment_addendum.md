---
owner: Codex 总控
status: active
purpose: Freeze the post-signoff maintenance-only judgment for the verified three-board mainline so later work cannot silently reopen scope after development-stage integration release review.
layer: L0 SSOT
based_on:
  - docs/00_ssot/three_board_mainline_integration_release_review_conclusion_addendum.md
  - docs/00_ssot/three_board_real_chain_result_verification_rerun_addendum.md
  - docs/00_ssot/gate_register_v1.md
freeze_date_local: 2026-04-10
---

# 《三板块主线 maintenance-only follow-up judgment》

## 1. Judgment

- 当前 `项目发布工作台 / 项目发布 / 项目展示` 三板块主线在完成
  `development-stage 联调发布复签` 后，
  正式进入：
  - `maintenance-only`

## 2. What Is Allowed

- 只允许：
  - 修复当前 verified canonical mainline 的 blocker
  - 做残余风险登记
  - 做 evidence filing
  - 做不改变真义的稳定性维护

## 3. What Is Not Allowed

- 不允许：
  - 借机重开三板块 scope
  - 借机扩到附件公开
  - 借机扩到独立 `visibility / review` state machine
  - 借机扩到交易后链
  - 借机宣称 production release ready

## 4. Retained Vetoes

- `No-Go for production release`
- `No-Go for release-prep pass`
- `No-Go for scope expansion`

## 5. Next Unique Action

- 下一轮唯一动作固定为：
  - `锁定新的唯一 active board，再决定是否提交新的阶段门禁核查表`

