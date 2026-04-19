---
owner: Codex 总控
status: frozen
purpose: Freeze the corrective frontend execution prompt for ED-3 of the enterprise-display full-closure mainline after result verification found submit body drift and app-facing error-copy drift.
layer: L0 SSOT
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/enterprise_display_full_closure_ed3_frontend_execution_prompt_addendum.md
  - docs/00_ssot/enterprise_display_full_closure_ed3_bff_result_verification_conclusion_addendum.md
  - apps/mobile/lib/features/exhibition/data/enterprise_hub_consumer_layer.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart
  - apps/bff/src/routes/enterprise_hub/enterprise-hub.service.ts
---

# 《enterprise display full closure ED-3 frontend execution prompt R2》

## 1. 当前唯一任务

- 你现在继续是：
  - `enterprise display full closure mainline`
  - `ED-3 frontend execution owner`
- 你的唯一任务不是重做 ED-3。
- 你的唯一任务是：
  - 修正 submit request body 与当前 BFF contract 的漂移
  - 修正 `ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS` 在 submit/status 面的错误文案消费

## 2. 当前 blocker

- verifier 已确认：
  - 当前 `EnterpriseHubConsumerLayer.submitApplication()` 不再发送 body
  - 但当前 `BFF normalizeSubmitPayload()` 明确要求：
    - `confirm === true`
  - 结果是 Flutter 当前真实 submit 会直接被 BFF fail-closed
- 同时 verifier 还确认：
  - 当前 `enterpriseApplicationVisibleErrorMessage()` 把
    - `ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS`
    统一显示成：
    - `当前申请仍缺少必填资料，请先回到工作台补齐后再提交。`
  - 这会把当前 `submit confirm` 的 app-facing 语义重新改坏
  - 无法正确表达：
    - `请先确认提交入驻申请后再继续。`

## 3. 这次只允许修改

- `apps/mobile/lib/features/exhibition/data/enterprise_hub_consumer_layer.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart`
- 与此问题直接相关的最小测试文件

## 4. 这次不允许修改

- `apps/server/**`
- `apps/bff/**`
- `apps/admin/**`
- `ED-3` 其他已经通过的 status route / handoff 逻辑
- `ED-4/ED-5` 范围

## 5. 你必须完成

1. 让 `submitApplication()` 的 request body 重新满足当前 app-facing contract：
   - `body = { "confirm": true }`
2. 更新对应测试，不得继续把“body 为空”当成正确行为。
3. 让 `ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS` 在 submit/status 面能够稳定表达当前 submit confirm 语义。
4. 不得把 `confirm` 问题继续显示成“资料未完成”。
5. 至少补一条测试覆盖：
   - submit request body 含 `confirm: true`
6. 至少补一条测试覆盖：
   - `ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS` 的可见文案不再误导成 profile/basic blocker

## 6. 你必须遵守

1. 不得在前端推导 `submitReady`。
2. 不得在前端发明第二套 application 状态机。
3. 不得改成 Flutter 直打 `/server/*`。
4. 不得顺手扩到 admin review/publish 或 public list/detail。

## 7. 完成标准

- 结果必须证明：
  - submit request body 与当前 BFF contract 对齐
  - submit confirm 语义可被前端正确消费
  - 不会再把确认问题误导成资料未完成

## 8. 交付回执要求

1. 修改文件清单
2. 为什么之前 submit body 与当前 BFF contract 漂移
3. 为什么之前 `MISSING_REQUIRED_FIELDS` 会误导成资料缺项
4. 新增或更新的测试结果
5. 仍未覆盖的非目标清单
