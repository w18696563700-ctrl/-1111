---
owner: Codex 总控
status: frozen
purpose: Freeze the result-verification prompt for ED-7 so the enterprise-display mainline can be verified end to end from profile-side entry to public home reflection using one real organization and one real published listing.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/enterprise_display_full_closure_dispatch_master_addendum.md
  - docs/00_ssot/enterprise_display_ed6_home_reflection_frontend_result_verification_conclusion_addendum.md
  - docs/00_ssot/enterprise_display_runtime_rescan_and_stage_reroute_addendum.md
---

# 《enterprise display ED-7 全链结果校验执行口令》

你现在是：
- enterprise display full closure mainline
- ED-7 result verification owner

你的唯一目标是：
- 用同一个真实 organization / enterprise / application / published listing
  做一次 enterprise-display 全链 through-chain 验收
- 输出明确的 `passed / failed / residual risk` 结论

这一步只做：
- 结果校验
- runtime smoke
- through-chain 证据整理

这一步不做：
- 不改 `apps/mobile/**`
- 不改 `apps/bff/**`
- 不改 `apps/server/**`
- 不改 `apps/admin/**`
- 不补功能
- 不做 release / deploy

当前已冻结事实：
1. 当前组织与 enterprise-display 对象链已存在真实 active runtime。
2. workbench truth 已成立。
3. application submit/status 已成立。
4. review/publish 已成立。
5. public list/detail/recommendation 已成立。
6. home `company_factory_recommendations` 已成立。

建议统一使用当前真实对象：
- `organizationId = e6bf4567-016e-45f9-9420-9c950237690e`
- `enterpriseId = bf5ff83a-26e7-4138-8157-042fb38a5f46`
- `approved applicationId = c1e83c6f-4637-407f-8d41-5c1413821874`

你必须完成：
1. 依次验证：
   - `我的楼 -> 企业展示入驻`
   - `boardType 选择 / workbench`
   - `application status`
   - `admin review / publish` 证据
   - `enterprise-hub recommendation / list / detail`
   - `home company_factory_recommendations`
2. 对每一环给出：
   - 当前证据
   - 是否通过
   - 是否存在 runtime 漂移
3. 最终只输出一个 through-chain 结论：
   - `pass`
   - 或 `not pass`
4. 如未通过，只允许指出当前最短唯一路径 blocker；
   - 不得重新摊开多条并行主线

你必须遵守：
1. 不得把局部 slice 通过误判成全链通过。
2. 不得把本地代码状态替代 active runtime。
3. 不得把历史旧文书结论当成当前结果。
4. 不得在本轮结果校验里顺手开新 implementation。

完成标准：
- 产出一份完整 through-chain 验收结论
- 明确 enterprise-display 主线是否已 full closure
- 如果未 full closure，明确唯一下一步是什么

交付回执要求：
1. 验证对象
2. 分环节证据
3. 通过 / 未通过结论
4. 残余风险
5. 当前下一步唯一动作
