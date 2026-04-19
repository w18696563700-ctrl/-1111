---
owner: Codex 总控
status: frozen
purpose: Provide the prepared frontend execution prompt for ED-2 of the enterprise-display full-closure mainline, so Flutter-side workbench consumption can start immediately after the backend truth gate passes.
layer: L0 SSOT
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/enterprise_display_full_closure_dispatch_master_addendum.md
  - docs/00_ssot/enterprise_display_workbench_v1_truth_freeze_addendum.md
  - docs/04_frontend/enterprise_display_workbench_v1_frontend_surface_addendum.md
  - docs/04_frontend/my_company_enterprise_display_entry_frontend_surface_addendum.md
  - docs/01_contracts/enterprise_display_workbench_v1_contract_freeze_addendum.md
---

# 《enterprise display full closure ED-2 frontend execution prompt》

## 1. 当前唯一任务

- 你现在是：
  - `enterprise display full closure mainline`
  - `ED-2 frontend execution owner`
- 你的唯一目标是：
  - 把 Flutter workbench 消费面对齐到已经冻结的 Server truth
  - 让 workbench 的 `basic / boardProfile / case / readiness / blockers` 在页面层真实可用
- 这一步只做：
  - workbench 页面
  - workbench consumer layer
  - workbench 本地交互与 after-save refresh
- 这一步不做：
  - application submit/status 闭环扩写
  - admin review/publish
  - public recommendation/list/detail
  - 新增第二入口
  - release / deploy

## 2. 当前阶段前提

- 当前前提固定为：
  - `ED-2 backend` 已通过 gate
  - workbench `basic/profile/case/readiness` truth 已在 Server 侧稳定
- 当前前端要解决的不是“猜测真值”，而是：
  - 只消费既有 app-facing truth
  - 把 blocker / disabled / refresh 行为表达正确

## 3. 允许修改范围

- 只允许修改：
  - `apps/mobile/lib/features/exhibition/**`
  - `apps/mobile/test/**`
- 不允许修改：
  - `apps/server/**`
  - `apps/bff/**`
  - `apps/admin/**`
  - `apps/mobile/lib/features/profile/**` 中与入口 owner 无关的范围

## 4. 你必须完成

1. workbench 首屏必须真实消费：
   - `basic`
   - `boardProfile`
   - `cases`
   - `certification`
   - `readiness`
2. `保存基础资料 / 保存画像 / 新增案例` 成功后，页面必须刷新 workbench 真值，不允许靠本地假状态继续渲染。
3. 提交按钮的可用/不可用状态必须完全由 Server `readiness.submitReady` 与 `blockers` 决定。
4. 无 blocker 时，不得额外本地拦截。
5. 有 blocker 时，必须直接展示中文 blocker 列表，不允许只给灰按钮不解释。
6. `注册城市` 与 `成立日期` 继续只读消费：
   - 不得发明第二套城市选择器
   - 不得发明第二套成立日期输入源
7. `case` 面必须保持：
   - 最多 6 张
   - `caseCoverFileAssetId` 首图兜底规则与后端一致
8. 保持 `我的楼 / 我的资产 -> 企业展示入驻 -> workbench` handoff 不变，不新增第二入口。

## 5. 你必须遵守

1. 不得在前端推导 `submitReady`。
2. 不得在前端伪造 organization/certification truth。
3. 不得为了“先让页面顺”而绕过 Server blocker。
4. 不得提前扩到 application status。
5. 不得把 workbench 改成第二个企业后台。

## 6. 完成标准

- 结果必须证明：
  - workbench 页面真实反映 `readiness/blockers`
  - 保存后刷新能看到最新 Server truth
  - 无 case / 无 profile / 无 basic / 无 certification 时，页面表达与 Server blockers 一致
  - 有完整 truth 时，不会被前端额外错误拦截
- 这一步不要求你证明：
  - submit 已成功
  - admin review/publish 已成功
  - public list/detail 已成功

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
  - 在 `ED-2 backend` gate 通过后发出本口令给 `前端`
- 下一步执行角色：
  - `前端`
- 下一步进入条件：
  - workbench Server truth 已通过 ED-2 gate，且不再存在 read/write 主语义漂移
