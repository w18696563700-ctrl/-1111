---
owner: Codex 总控
status: active
purpose: Freeze the bounded next-stage dispatch bundle for enterprise_hub V1 after residual-risk closure is complete, limiting the successor stage to private workbench and submit-chain reassessment instead of reopening already-closed public entity risk or implying release-prep.
layer: L0 SSOT
based_on:
  - docs/00_ssot/enterprise_hub_v1_post_risk_closure_stage_gate_checklist_addendum.md
  - docs/00_ssot/enterprise_hub_v1_integration_risk_closure_review_conclusion_addendum.md
  - docs/00_ssot/exhibition_app_full_function_register_v1.md
  - docs/00_ssot/enterprise_display_full_closure_dispatch_master_addendum.md
  - docs/00_ssot/enterprise_display_workbench_v1_truth_repair_dispatch_addendum.md
  - docs/00_ssot/enterprise_display_submit_chain_user_side_real_completion_runbook_addendum.md
  - docs/00_ssot/enterprise_display_full_closure_ed2_frontend_result_verification_conclusion_addendum.md
  - docs/00_ssot/enterprise_display_full_closure_ed3_bff_result_verification_conclusion_addendum.md
freeze_date_local: 2026-04-10
---

# 《enterprise_hub V1 post-risk-closure bounded next-stage dispatch bundle》

## 1. Scope

- 本派工包只适用于：
  - `enterprise_hub V1`
- 本派工包只冻结：
  - residual-risk closure 完成后的下一阶段唯一目标
  - 当前允许重新进入的子对象
  - 当前执行顺序
  - 当前 retained veto 与非目标
- 本派工包不代表：
  - `release-prep` 放行
  - `production release` 放行
  - enterprise_hub 全包 closure

## 2. Current Next-stage Goal

- 当前下一阶段唯一目标固定为：
  - 只重新进入 `EXH-006A + EXH-006`
    对应的私域链：
    - `企业展示工作台`
    - `application create / submit / status / continue`
- 当前下一阶段的工作含义固定为：
  - 先确认旧 workbench / submit chain blocker 在 current active runtime 上是否仍然真实存在
  - 若仍存在，只做 bounded reassessment 和定点修正
  - 若已不存在，不重复做已经有效完成的工作

## 3. Explicitly Re-opened Object

- 当前只重新进入以下 enterprise_hub 子对象：
  - `EXH-006A 企业展示工作台`
  - `EXH-006 企业入驻申请状态/续办`
- 当前明确不重新进入：
  - `EXH-002 / EXH-003 / EXH-004 / EXH-005`
    对应的 public entity risk
  - 原因：
    - 当前 residual-risk closure review 已独立确认：
      - `home card -> real list entity -> real detail`
      - authenticated `application-status approved`
      - `apps/bff` full build
      已关闭

## 4. Historical Inputs And Their Meaning

- 以下旧文书当前只作为历史输入，不自动等于“继续沿用旧派工单原文”：
  - [enterprise_display_full_closure_dispatch_master_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_full_closure_dispatch_master_addendum.md)
  - [enterprise_display_workbench_v1_truth_repair_dispatch_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_workbench_v1_truth_repair_dispatch_addendum.md)
  - [enterprise_display_submit_chain_user_side_real_completion_runbook_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_submit_chain_user_side_real_completion_runbook_addendum.md)
  - [enterprise_display_full_closure_ed2_frontend_result_verification_conclusion_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_full_closure_ed2_frontend_result_verification_conclusion_addendum.md)
  - [enterprise_display_full_closure_ed3_bff_result_verification_conclusion_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_full_closure_ed3_bff_result_verification_conclusion_addendum.md)
- 当前对这些历史输入的唯一允许用法是：
  - 提供 workbench / submit chain 的背景边界
  - 提供旧 blocker 的来源
  - 提供旧 runbook 的顺序参考
- 当前不允许：
  - 直接把历史 `ED-1 ~ ED-7` dispatch 当成现在的自动放行依据
  - 在不复核 current active runtime 的情况下重复照搬旧 correction

## 5. Fixed Current Runtime Sample

- 当前下一阶段 runtime reassessment 固定样本为：
  - `mobile = 18696563700`
  - `otpCode = 000000`
  - `organizationId = e6bf4567-016e-45f9-9420-9c950237690e`
  - `factory enterpriseId = bf5ff83a-26e7-4138-8157-042fb38a5f46`
  - `factory applicationId = c1e83c6f-4637-407f-8d41-5c1413821874`
- 当前选择 `factory` 作为下一阶段单一样本对象，原因固定为：
  - workbench / submit chain 的既有历史 runbook 与 blocker 文书都围绕该对象收敛
  - 当前不需要同时把三类 boardType 的私域工作台全部并行重开

## 6. Included Scope

### 6.1 Result Verification Included Scope

- 当前必须先由 `结果校验 Agent` 做：
  - `GET /api/app/exhibition/enterprise-hub/workbench?boardType=factory`
  - 真实登录、真实组织切换、真实 application-status 读取
  - current workbench blocker / readiness / save / submit chain 的 runtime reassessment
- 当前只允许核对：
  - 是否仍有：
    - `organization.provinceCode/cityCode = 000000`
    - `certification.establishedAt/address` 缺值
    - `PUT basic` 未真实发出
    - `submitReady=false` 与真实 blocker 不一致
    - submit / continue handoff 漂移

### 6.2 Backend Included Scope

- 只有在 runtime reassessment 证明 blocker 仍存在时，`后端 Agent` 才允许进入：
  - organization / certification truth
  - workbench readiness / submit write gate
  - application state truth
- 当前不允许：
  - 在未复核前重复修旧 blocker

### 6.3 BFF Included Scope

- 只有在 runtime reassessment 证明 current artifact 仍有 transport 漂移时，`BFF Agent` 才允许进入：
  - workbench / application family app-facing normalization
  - current artifact drift 修正
- 当前不允许：
  - 为一个尚未复现的 blocker 先做预防性改动

### 6.4 Frontend Included Scope

- 只有在 runtime reassessment 证明 current mobile consumption 仍有 drift 时，`前端 Agent` 才允许进入：
  - workbench save / blocker / after-save refresh
  - submit / status / continue handoff
  - 当前页可编辑字段与上游真值字段的消费一致性
- 当前不允许：
  - 重做 public list/detail/home
  - 顺手做 enterprise_hub 包外 UI 扩面

## 7. Explicit Non-goals

- 不重开 public entity risk closure
- 不重开首页三卡 public list/detail 闭环
- 不把当前阶段偷换成 `release-prep`
- 不把当前阶段偷换成 `production release`
- 不扩到 admin 平台泛化
- 不扩到交易 / IM / 地图 / forum

## 8. Execution Order

1. `结果校验 Agent`
   - 先做 `EXH-006A + EXH-006` current runtime reassessment
2. `总控`
   - 根据 reassessment 结果判断：
     - 是否无需施工直接进入 review conclusion
     - 或者需要向 backend / BFF / frontend 发出 bounded correction prompt
3. `后端 / BFF / 前端`
   - 只有在被当前 reassessment 明确指向后，才进入定点修正
4. `结果校验 Agent`
   - 对定点修正做 rerun
5. `总控`
   - 出本阶段 review conclusion

## 9. Formal Conclusion

- 当前正式结论如下：
  - `enterprise_hub V1` 在 residual-risk closure 完成后，下一阶段只允许回到 private workbench / submit chain reassessment
  - 当前 public entity risk 已关闭，不得作为下一阶段默认对象继续反复施工
  - 当前仍然：
    - `No-Go for release-prep`
    - `No-Go for production release`

## 10. Next Unique Action

- 下一步唯一动作：
  - 基于本派工包，向 `结果校验 Agent` 发出 `EXH-006A + EXH-006 current runtime reassessment` 执行口令
