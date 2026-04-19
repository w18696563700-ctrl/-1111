---
owner: Codex 总控
status: frozen
purpose: Freeze the rerun prompt for ED-7 after the final known blocker moved from home reflection to frontend province-scope handoff and has now been corrected locally.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/enterprise_display_ed7_full_chain_result_verification_execution_prompt_addendum.md
  - docs/00_ssot/enterprise_display_home_location_scope_handoff_frontend_result_verification_conclusion_addendum.md
---

# 《enterprise display ED-7 全链结果校验重跑口令》

你现在是：
- enterprise display full closure mainline
- ED-7 result verification owner

你的唯一目标是：
- 在最新修正后的前端/后端基线下，重新执行一次 enterprise-display through-chain 验收
- 给出最新唯一结论：
  - `pass`
  - 或 `not pass`

这一步只做：
- 重跑结果校验
- active runtime / app-facing / frontend-consumption 证据复核

这一步不做：
- 不改 `apps/mobile/**`
- 不改 `apps/bff/**`
- 不改 `apps/server/**`
- 不改 `apps/admin/**`
- 不补功能
- 不做 release / deploy

当前已冻结更新：
1. `company_factory_recommendations` backend reflection 已成立。
2. Flutter 首页 recommendation section 已成立。
3. 首页自动 location handoff 现在已具备透传 `provinceCode / provinceName` 的能力。
4. 旧 `ED-7 not pass` 结论里关于 “home reflection failed” 的失败点已过期。

建议统一验证对象：
- `organizationId = e6bf4567-016e-45f9-9420-9c950237690e`
- `enterpriseId = bf5ff83a-26e7-4138-8157-042fb38a5f46`
- `approved applicationId = c1e83c6f-4637-407f-8d41-5c1413821874`

你必须完成：
1. 重新验证：
   - `我的楼 -> 企业展示入驻`
   - `boardType 选择 / workbench`
   - `application status`
   - `admin review / publish`
   - `enterprise-hub recommendation / list / detail`
   - `home company_factory_recommendations`
2. 当前 home 环节不得再只用无参 `GET /api/app/exhibition/home` 直接下结论；
   - 必须结合当前首页自动 location handoff 的真实 carrier 能力一起判断
3. 最终只输出一个 through-chain 结论。
4. 如仍未通过，只允许指出唯一最短 blocker。

完成标准：
- 输出最新 enterprise-display 主线是否 full closure
- 不再沿用已过期的 `home reflection failed` 旧结论

交付回执要求：
1. 验证对象
2. 分环节证据
3. 通过 / 未通过结论
4. 残余风险
5. 当前下一步唯一动作
