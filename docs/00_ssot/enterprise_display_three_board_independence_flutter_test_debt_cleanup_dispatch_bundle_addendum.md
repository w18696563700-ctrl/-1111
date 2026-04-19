---
owner: Codex 总控
status: active
purpose: Freeze the bounded dispatch bundle for the Flutter enterprise_hub routes test debt cleanup round so Codex can convert stale shared-path fake handlers and drifted assertions to the current board-scoped canonical family while separating true regressions from legacy test noise.
layer: L0 SSOT
freeze_date_local: 2026-04-19
inputs_canonical:
  - docs/00_ssot/enterprise_display_three_board_independence_flutter_test_debt_cleanup_stage_gate_checklist_addendum.md
  - docs/00_ssot/enterprise_display_three_board_independence_flutter_execution_receipt_addendum.md
  - docs/00_ssot/enterprise_display_three_board_independence_integration_verification_execution_receipt_addendum.md
---

# 《enterprise display three-board independence Flutter test debt cleanup dispatch bundle》

## A. 当前轮唯一目标

- 当前轮唯一目标固定为：
  - 清理 `apps/mobile/test/enterprise_hub_routes_test.dart`
  - 让 fake transport handler 与当前 board-scoped canonical family 对齐
  - 让 copy/title/assertion 与当前 Flutter surface 对齐
  - 把真实产品回归与纯测试债分开

## B. 当前轮明确非目标

- 不改 `Server` truth
- 不改 `BFF` canonical path family
- 不删 compatibility bridge
- 不做 authenticated smoke
- 不做 deploy / restart / rollback / release
- 不做新的产品逻辑 authoring

## C. 当前轮 allowed write set

- `docs/00_ssot/**`
- `apps/mobile/test/**`
- 与测试稳定性直接相关的最小 `apps/mobile/lib/**`

## D. 当前轮 package split

### D1. Package A | baseline and grouping

- unique goal：
  - 固化 `enterprise_hub_routes_test.dart` 当前红灯清单
  - 按 `list / detail / status / workbench / published-change` 五组归并
- must do：
  - 标记每组主因：
    - stale shared-path handler
    - copy/title drift
    - suspected real behavior drift
- must not do：
  - 在没有分类前直接大面积改断言

### D2. Package B | list / detail / status cleanup

- unique goal：
  - 先清最机械的 board-scoped handler 迁移
- must do：
  - 列表、推荐、详情、状态测试统一切到 board-scoped canonical path
  - 同步更新最小 query contract 与页面 copy 断言
- must not do：
  - 引入新的 shared-path fallback 作为测试主路径

### D3. Package C | workbench / published-change cleanup

- unique goal：
  - 清 workbench 与 published-change 测试债
- must do：
  - current change workbench、status、basic save、case continuation、submit flow 全部改成当前 board-scoped canonical path
  - 修正标题与治理 copy 断言
- must not do：
  - 为追求整文件全绿而掩盖真实行为回退

### D4. Package D | residual triage and closure

- unique goal：
  - 跑整文件回归并产出 closure receipt
- must do：
  - 区分：
    - 已清测试债
    - 暴露的真实产品 bug
    - 仍需后续拆分的脆弱测试
- must not do：
  - 把 residual risk 留成口头结论

## E. 执行顺序

1. author gate checklist and dispatch bundle
2. 完成 `Package A / baseline and grouping`
3. 完成 `Package B / list / detail / status cleanup`
4. 完成 `Package C / workbench / published-change cleanup`
5. 跑整文件回归
6. 输出 execution receipt 和 residual risk

## F. 当前轮验收标准

- `enterprise_hub_routes_test.dart` 中涉及企业展示的 fake handlers 不再依赖旧 shared path。
- `board-scoped canonical path` 断言与当前 consumer layer 一致。
- 已知 copy/title 漂移断言被收敛到当前真实 surface。
- 真实产品行为变更与测试债被明确分离。
- case editor 套娃问题不会通过历史测试债再次回流。
