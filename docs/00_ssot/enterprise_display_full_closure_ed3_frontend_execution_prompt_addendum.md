---
owner: Codex 总控
status: frozen
purpose: Provide the frontend execution prompt for ED-3 of the enterprise-display full-closure mainline, so Flutter can consume application create/submit/status on top of the stabilized app-facing transport.
layer: L0 SSOT
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/enterprise_display_full_closure_dispatch_master_addendum.md
  - docs/00_ssot/enterprise_display_full_closure_ed3_bff_result_verification_conclusion_addendum.md
  - docs/00_ssot/enterprise_hub_v1_app_aligned_freeze_addendum.md
  - docs/04_frontend/enterprise_display_workbench_v1_frontend_surface_addendum.md
---

# 《enterprise display full closure ED-3 frontend execution prompt》

## 1. 当前唯一任务

- 你现在是：
  - `enterprise display full closure mainline`
  - `ED-3 frontend execution owner`
- 你的唯一目标是：
  - 把 enterprise-display 的 `application create / submit / status / continue` 消费面对齐到已冻结的 app-facing transport
  - 让 Flutter 侧申请动作与状态页形成最小闭环
- 这一步只做：
  - `/exhibition/enterprise/apply`
  - `/exhibition/enterprise/application-status`
  - application create / submit / status 的页面消费、跳转与错误反馈
- 这一步不做：
  - workbench truth 扩写
  - admin review/publish
  - public recommendation/list/detail
  - 新增第二入口
  - release / deploy

## 2. 当前阶段前提

- 当前前提固定为：
  - `ED-2` 已 closure
  - `ED-3 BFF` 已 closure
- 当前前端要解决的不是：
  - 推导业务状态
  - 发明第二套申请状态机
- 当前前端要解决的是：
  - 只消费既有 `/api/app/*` application transport
  - 把提交动作、状态回跳和错误反馈表达正确

## 3. 允许修改范围

- 只允许修改：
  - `apps/mobile/lib/features/exhibition/**`
  - `apps/mobile/test/**`
- 不允许修改：
  - `apps/server/**`
  - `apps/bff/**`
  - `apps/admin/**`

## 4. 你必须完成

1. `提交入驻申请` 必须只调用：
   - `POST /api/app/exhibition/enterprise-hub/applications/{applicationId}/submit`
2. 提交成功后必须进入：
   - `/exhibition/enterprise/application-status`
3. 状态页必须真实消费：
   - `GET /api/app/exhibition/enterprise-hub/applications/{applicationId}`
4. 对以下错误语义必须稳定消费并反馈：
   - `AUTH_SESSION_INVALID`
   - `ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS`
   - `ENTERPRISE_HUB_PERMISSION_DENIED`
   - `ENTERPRISE_HUB_APPLICATION_NOT_FOUND`
   - `ENTERPRISE_HUB_PROFILE_NOT_COMPLETED`
   - `ENTERPRISE_HUB_CONTACT_REQUIRED`
   - `ENTERPRISE_HUB_CASE_REQUIRED`
   - `ENTERPRISE_HUB_CERTIFICATION_REQUIRED`
   - `ENTERPRISE_HUB_INVALID_STATE_TRANSITION`
5. `continue/status` handoff 必须留在既有入口链：
   - `我的楼 / 我的资产 -> 企业展示入驻 -> workbench -> application status`
6. 不得让 Flutter 直打 `/server/*`。

## 5. 你必须遵守

1. 不得在前端推导 `submitReady`。
2. 不得在前端发明第二套 application 状态机。
3. 不得在前端伪造 organization/certification truth。
4. 不得提前扩到 admin review/publish。
5. 不得提前扩到 public list/detail。

## 6. 完成标准

- 结果必须证明：
  - submit 成功后可以进入 status 页
  - status 页消费的是 app-facing application truth
  - submit blocked / not found / permission denied 等错误可被稳定消费
  - Flutter 仍然只访问 `/api/app/*`
- 这一步不要求你证明：
  - admin review/publish 已成功
  - public recommendation/list/detail 已成功
  - 首页卡片已成功

## 7. 交付回执要求

- 你完成后必须给出：
  1. 修改文件清单
  2. 页面行为变化摘要
  3. 新增/更新的测试结果
  4. 仍未覆盖的非目标清单

## 8. 当前下一步

- 当前阶段完成度：
  - `dispatch 完成`
- 当前下一步唯一动作：
  - 在 `ED-3 BFF` closure 后发出本口令给 `前端`
- 下一步执行角色：
  - `前端`
- 下一步进入条件：
  - application family 的 app-facing transport 已稳定，且页面层必须开始消费 submit/status 真实业务态
