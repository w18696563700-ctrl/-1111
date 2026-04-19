---
owner: Codex 总控
status: frozen
purpose: Freeze the consolidated corrective frontend execution prompt for ED-3 of the enterprise-display full-closure mainline after result verification found submit contract drift and workbench truth-field UI semantic drift.
layer: L0 SSOT
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/enterprise_display_full_closure_ed3_frontend_execution_prompt_addendum.md
  - docs/00_ssot/enterprise_display_full_closure_ed3_frontend_execution_prompt_r2_addendum.md
  - docs/00_ssot/enterprise_display_workbench_v1_truth_freeze_addendum.md
  - docs/04_frontend/enterprise_display_workbench_v1_frontend_surface_addendum.md
  - apps/mobile/lib/features/exhibition/data/enterprise_hub_consumer_layer.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart
  - apps/mobile/lib/core/location/china_region_picker.dart
  - apps/bff/src/routes/enterprise_hub/enterprise-hub.service.ts
---

# 《enterprise display full closure ED-3 frontend execution prompt R3》

## 1. 当前唯一任务

- 你现在继续是：
  - `enterprise display full closure mainline`
  - `ED-3 frontend execution owner`
- 本口令直接覆盖上一版 `ED-3 frontend R2`。
- 你的唯一任务是：
  - 修正 submit request body 与当前 BFF contract 的漂移
  - 修正 `ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS` 在 submit/status 面的错误文案消费
  - 修正 workbench 中 `注册城市 / 详细地址 / 成立日期` 三处字段的 UI 语义错误

## 2. 当前 blocker

- verifier 已确认以下 5 个问题：

1. `submitApplication()` 当前不再发送 body。
2. 当前 `BFF` 明确要求：
   - `confirm === true`
3. 当前 `ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS` 被前端统一显示成：
   - `当前申请仍缺少必填资料，请先回到工作台补齐后再提交。`
4. `注册城市` 当前被渲染成：
   - 带必填星号的锁定输入框
   - 缺值时显示 `当前还没有同步到注册城市真值`
   - 但用户在当前页无法修改
   - 且 `_saveBasic()` 会直接 fail-closed
5. `成立日期` 与 `详细地址` 当前也存在伪输入框/伪二级框语义：
   - `成立日期` 看起来像可点的日期输入，但实际只读
   - `详细地址` 下方的 `用当前位置回填` 在视觉上像是输入框内嵌第二层框

## 3. 这次只允许修改

- `apps/mobile/lib/features/exhibition/data/enterprise_hub_consumer_layer.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart`
- `apps/mobile/lib/core/location/china_region_picker.dart`
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
5. 把 `注册城市` 从“必填锁定输入框”改成明确的只读真值展示态：
   - 必须让用户一眼看懂“当前字段来源于我的公司真值”
   - 缺值时必须明确提示修复入口在 `我的公司`
   - 不得继续伪装成当前页可编辑的表单输入框
6. 把 `成立日期` 从“像日期选择器的只读框”改成明确的只读真值展示态：
   - 不得继续使用会让用户误判为可点击输入的表现
7. 保留 `详细地址` 为真实可编辑输入，但重新安排 `用当前位置回填` 的层级：
   - 必须看起来像辅助动作，不得像输入框内部第二层盒子
8. 不得新增第二套城市选择器。
9. 不得新增第二套成立日期输入源。
10. 至少补一条测试覆盖：
    - submit request body 含 `confirm: true`
11. 至少补一条测试覆盖：
    - `ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS` 的可见文案不再误导成 profile/basic blocker
12. 至少补一条测试覆盖：
    - `注册城市 / 成立日期` 当前为只读真值展示而非可编辑伪输入

## 6. 你必须遵守

1. 不得在前端推导 `submitReady`。
2. 不得在前端发明第二套 application 状态机。
3. 不得改成 Flutter 直打 `/server/*`。
4. 不得顺手扩到 admin review/publish 或 public list/detail。
5. 不得为了“视觉好看”去掩盖当前真值缺失问题。

## 7. 完成标准

- 结果必须证明：
  - submit request body 与当前 BFF contract 对齐
  - submit confirm 语义可被前端正确消费
  - `注册城市 / 成立日期` 不再伪装成可编辑输入框
  - `详细地址 -> 用当前位置回填` 的层级语义清楚
  - 不会再把确认问题误导成资料未完成

## 8. 交付回执要求

1. 修改文件清单
2. 为什么之前 submit body 与当前 BFF contract 漂移
3. 为什么之前 `MISSING_REQUIRED_FIELDS` 会误导成资料缺项
4. 为什么这三个框子之前构成了错误表单语义
5. 新增或更新的测试结果
6. 仍未覆盖的非目标清单
