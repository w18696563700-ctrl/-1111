---
owner: Codex 总控
status: active
purpose: Freeze the post-signoff maintenance-only judgment for the verified project showcase filter and project create form refactor object so later work cannot silently reopen scope after development-stage integration release review.
layer: L0 SSOT
freeze_date_local: 2026-04-11
based_on:
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_integration_release_review_conclusion_addendum.md
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_result_verification_review_conclusion_addendum.md
---

# 《项目展示筛选与创建表单重构 maintenance-only follow-up judgment》

## 1. Judgment

- 当前 `项目展示筛选与创建表单重构` 在完成
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
  - 借机重开本对象 scope
  - 借机扩到 `my/projects`
  - 借机扩到 workbench
  - 借机扩到附件公开
  - 借机扩到独立 `visibility / review` state machine
  - 借机扩到交易后链
  - 借机宣称 release-prep ready 或 production release ready

## 4. Retained Vetoes

- `No-Go for release-prep`
- `No-Go for production release`
- `No-Go for scope expansion`

## 5. Next Unique Action

- 下一轮唯一动作固定为：
  - 锁定新的唯一 bounded object candidate，再决定是否提交新的《阶段门禁核查表》
