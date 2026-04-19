---
owner: Codex 总控
status: active
purpose: Freeze the execution prompt for Package C verification so enterprise-display three-board independence can prove the repaired historical case/media rows are aligned with runtime truth before any next-stage discussion begins.
layer: L0 SSOT
freeze_date_local: 2026-04-19
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/enterprise_display_three_board_independence_server_data_repair_stage_gate_checklist_addendum.md
  - docs/00_ssot/enterprise_display_three_board_independence_server_data_repair_dispatch_bundle_addendum.md
  - apps/server/scripts/enterprise_hub_case_media_repair_readonly_audit.sql
  - apps/server/scripts/enterprise_hub_case_media_post_release_smoke.sh
  - apps/server/test/enterprise-hub-media-ownership-truth.test.cjs
  - apps/server/test/enterprise-hub-case-continuation.test.cjs
  - apps/server/test/enterprise-hub-published-change-governance.test.cjs
  - apps/server/test/enterprise-hub-public-read-closure.test.cjs
  - apps/server/test/enterprise-hub-workbench-closure.test.cjs
---

# 《enterprise display three-board independence Package C verification execution prompt》

## 1. 当前阶段

- 主线：
  - `enterprise display / three-board independence`
- 子阶段：
  - `Stage C / Server data repair`
- 当前包：
  - `Package C / verification`

## 2. 前置条件

- 本 prompt 只有在以下条件同时成立时才可执行：
  - `Package B` receipt 已落盘
  - 总控已明确把 `Package C` 从 authored 状态升为 executable
- 若没有上述两项：
  - 当前 prompt 仅可阅读，不得执行

## 3. 唯一目标

- 你这轮只负责证明 repair 结果成立。
- 你这轮只允许做四件事：
  1. 复跑 readonly audit
  2. 跑 targeted server tests
  3. 跑 post-repair smoke
  4. 输出 verification receipt

## 4. 强制阅读

- `docs/00_ssot/enterprise_display_three_board_independence_server_data_repair_dispatch_bundle_addendum.md`
- `docs/00_ssot/enterprise_display_three_board_independence_server_data_repair_script_execution_receipt_addendum.md`
- `apps/server/scripts/enterprise_hub_case_media_repair_readonly_audit.sql`
- `apps/server/scripts/enterprise_hub_case_media_post_release_smoke.sh`

## 5. 你必须完成

### 5.1 SQL truth verification

- 必须重跑：
  - `Q2`
  - `Q3`
  - `Q4`
  - `Q6`
  - `Q7`
- 对目标企业预期固定为：
  - `0` 行

### 5.2 runtime verification

- 必须跑：
  - `enterprise-hub-media-ownership-truth.test.cjs`
  - `enterprise-hub-case-continuation.test.cjs`
  - `enterprise-hub-published-change-governance.test.cjs`
  - `enterprise-hub-public-read-closure.test.cjs`
  - `enterprise-hub-workbench-closure.test.cjs`
- 必须跑：
  - `enterprise_hub_case_media_post_release_smoke.sh`

### 5.3 final judgment

- 必须明确回答：
  - 是否还有 cross-board case/media 泄漏
  - `caseImageUrlMap` / `showcaseImageUrlMap` 是否仍保持完整
  - 是否可以移交下一轮 `BFF / Flutter` 或 release judgment 讨论

## 6. 完成标准

- 不允许只报“页面看起来正常”。
- 必须同时满足：
  - SQL truth 复跑通过
  - tests 通过
  - smoke 通过

## 7. 回执要求

- 回执必须单独落盘为：
  - `docs/00_ssot/enterprise_display_three_board_independence_server_data_verification_execution_receipt_addendum.md`
- 回执至少必须包含：
  1. SQL 复跑结果
  2. test 结果
  3. smoke 结果
  4. residual risks
  5. 是否允许进入下一轮讨论

## 8. 输出禁令

- 不要以单接口成功替代整组验证
- 不要跳过 SQL truth 复跑
- 不要把验证通过直接写成 release-ready
- 只给真实证据、真实结论、真实残余风险
