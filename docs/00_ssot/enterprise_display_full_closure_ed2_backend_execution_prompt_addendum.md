---
owner: Codex 总控
status: frozen
purpose: Provide the next backend execution prompt for ED-2 of the enterprise-display full-closure mainline after ED-1 blocker repair passes verification.
layer: L0 SSOT
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/enterprise_display_full_closure_dispatch_master_addendum.md
  - docs/00_ssot/enterprise_display_workbench_v1_truth_freeze_addendum.md
  - docs/00_ssot/enterprise_display_workbench_v1_current_runtime_blocker_verdict_addendum.md
  - docs/00_ssot/enterprise_display_workbench_v1_truth_repair_dispatch_addendum.md
  - docs/00_ssot/enterprise_display_full_closure_mainline_ruling_addendum.md
---

# 《enterprise display full closure ED-2 backend execution prompt》

## 1. 当前唯一任务

- 你现在是：
  - `enterprise display full closure mainline`
  - `ED-2 backend execution owner`
- 你的唯一目标是：
  - 收口企业展示工作台的 Server truth
  - 让 `basic / boardProfile / case / readiness` 成为真实可验收闭环
- 这一步只做：
  - `enterprise_hub` workbench read/write/readiness
  - 与 workbench 必填和回读直接相关的最小 truth carrier
- 这一步不做：
  - application submit/status
  - admin review/publish
  - public recommendation/list/detail
  - mobile/BFF 扩写
  - release / deploy

## 2. 当前阶段前提

- ED-1 的上游真值阻断已通过本地验证：
  - `organization` 不再接受 `000000`
  - `certification.address/establishedAt` 已进入同一真源
  - workbench 可从 certification truth 回读 `address/foundedAt`
- 当前还没完成的，是 workbench 自身闭环：
  - `basic` 保存后必须真实回读
  - `boardProfile` 三板块最小必填必须稳定
  - `case` 创建与回读必须稳定
  - `readiness/blockers` 必须只由 Server 真值判断

## 3. 允许修改范围

- 只允许修改：
  - `apps/server/src/modules/enterprise_hub/**`
  - 必要时最小 entity import wiring
- 不允许修改：
  - `apps/mobile/**`
  - `apps/bff/**`
  - `apps/admin/**`
  - `organization/profile` 这轮已通过的 ED-1 主修复逻辑

## 4. 你必须完成

1. 确认 `GET /server/exhibition/enterprise-hub/workbench` 的 read model 与当前冻结 truth 一致。
2. 确认 `PUT basic` 后，`basic` 区字段能被 workbench 回读到统一真值：
   - `name`
   - `shortIntro`
   - `provinceCode/provinceName`
   - `cityCode/cityName`
   - `address`
   - `foundedAt`
3. 确认三个板块的 profile minimum 与 `readiness.profileCompleted` 一致：
   - `company`
   - `factory`
   - `supplier`
4. 确认 `case create` 后：
   - case 列表可回读
   - `caseCoverFileAssetId` 与 `caseMediaFileAssetIds` 规则不漂移
5. 确认 `readiness/blockers` 只来自 Server truth，不允许前端猜测替代。
6. 对当前 workbench 返回面补最小定向测试，覆盖：
   - `basic` 保存后回读
   - `profile minimum -> profileCompleted`
   - `case create -> hasCase`
   - `readiness/blockers` 与字段真值一致

## 5. 你必须遵守

1. 不得把 `submitReady` 放松成前端可推导状态。
2. 不得在 workbench 中发明第二套 organization/certification 真源。
3. 不得提前扩到 application submit/status。
4. 不得提前扩到 admin review/publish。
5. 不得把 workbench 改成第二个企业后台。

## 6. 完成标准

- 结果必须证明：
  - `basic` 保存后的 workbench 回读稳定
  - `boardProfile` 最小必填与 `profileCompleted` 一致
  - `case` 创建后 `hasCase` 能反映真实状态
  - `blockers` 与真实缺项一致
- 这一步不要求你证明：
  - submit 已成功
  - admin review/publish 已成功
  - public list/detail 已出现真实实体

## 7. 交付回执要求

- 你完成后必须给出：
  1. 修改文件清单
  2. workbench truth 收口说明
  3. 新增/更新的测试结果
  4. 仍未覆盖的非目标清单

## 8. 当前下一步

- 当前阶段完成度：
  - `dispatch 完成`
- 当前下一步唯一动作：
  - 发出本口令给 `后端`
- 下一步执行角色：
  - `后端`
- 下一步进入条件：
  - ED-1 verifier blocker 已关闭，且本轮不引入新的上游真值回退
