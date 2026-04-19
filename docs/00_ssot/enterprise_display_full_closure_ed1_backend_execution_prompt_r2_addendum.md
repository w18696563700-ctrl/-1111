---
owner: Codex 总控
status: frozen
purpose: Provide the corrective backend execution prompt for ED-1 after verification found the organization truth-repair migration was non-deterministic when one organization owns multiple enterprise listings.
layer: L0 SSOT
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/enterprise_display_full_closure_ed1_backend_execution_prompt_addendum.md
  - docs/00_ssot/enterprise_display_workbench_v1_truth_repair_dispatch_addendum.md
  - docs/00_ssot/enterprise_display_full_closure_dispatch_master_addendum.md
  - apps/server/src/core/migrations/migrations.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts
---

# 《enterprise display full closure ED-1 backend corrective prompt R2》

## 1. 当前唯一任务

- 你现在继续是：
  - `enterprise display full closure mainline`
  - `ED-1 backend execution owner`
- 你的唯一任务不是重做 ED-1。
- 你的唯一任务是：
  - 保留 ED-1 已经正确的修复方向
  - 只修掉 `organization truth repair migration` 的不确定回填来源

## 2. 当前 blocker

- 当前 verifier 已确认以下问题：
  - [migrations.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/core/migrations/migrations.ts) 中 `20260410_enterprise_display_org_and_cert_truth_repair` 的 `repair_source`
    直接把 `organizations` 左连到 `enterprise_listing` 与 `enterprise_service_area`
  - 但现有 enterprise-display truth 允许：
    - 同一 organization 按 `primaryBoardType` 拥有多条 listing
  - 因此 migration 回填 `organization.province_code/city_code` 时，可能拿到非唯一来源
- 这会导致：
  - canonical organization truth 可能被不稳定数据污染
  - ED-1 不能放行进入下一阶段

## 3. 这次允许改什么

- 只允许修改：
  - [migrations.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/core/migrations/migrations.ts)
  - 与此 migration 验证直接相关的最小测试文件
- 不允许修改：
  - `apps/mobile/**`
  - `apps/bff/**`
  - `apps/admin/**`
  - ED-1 里已经正确的 `organization/certification/workbench` 主修复逻辑

## 4. 你必须完成

1. 把 `20260410_enterprise_display_org_and_cert_truth_repair` 改成**确定性回填**。
2. 自动回填只能在以下条件同时满足时发生：
   - 当前 organization 的 `province_code/city_code` 仍为待修状态
   - 候选 enterprise-display 注册地来源是有效非占位值
   - 候选来源对该 organization 来说是**唯一且无歧义**的
3. 如果一个 organization 存在多个 candidate source，且省市 code 不一致：
   - 本次 migration 必须跳过该 organization
   - 不得任意选一条写回
4. 你可以采用以下任一安全方案：
   - 先按 organization 聚合 candidate registered_location truth，只对“唯一 distinct 省市组合”的 organization 回填
   - 或只选择一个被 formal truth 明确认定的单来源，并用 SQL 证明对每个 organization 最多一条
5. 必须补一条定向测试，证明：
   - 多 listing 且 candidate 不一致时，不会发生错误自动回填
   - 单一 candidate 时，仍会正确回填

## 5. 你必须遵守

1. 不得回退已经通过 verifier 的这些修复：
   - `000000` 写链拦截
   - certification `address/establishedAt` 持久化
   - workbench 从 certification truth 回读 `address/foundedAt`
2. 不得把 migration 问题转嫁成前端手工修正。
3. 不得因为想“尽快过关”就去放宽 organization truth 的自动修复条件。
4. 不得新增第二真源。

## 6. 完成标准

- 结果必须证明：
  - migration 对每个 organization 的回填来源是确定的
  - 多 listing 冲突时，organization truth 不会被任意值污染
  - 单一有效 candidate 仍能完成受控回填
- 这一步不要求你证明：
  - release/deploy
  - application submit 闭环
  - public list/detail 闭环

## 7. 交付回执要求

- 你完成后必须给出：
  1. 修改文件清单
  2. migration 修正思路
  3. 为什么现在回填来源是确定的
  4. 新增或更新的测试结果
  5. 仍未覆盖的非目标清单

## 8. 当前下一步

- 当前阶段完成度：
  - `verification 中`
- 当前下一步唯一动作：
  - 发出本 R2 corrective prompt 给 `后端`
- 下一步执行角色：
  - `后端`
- 下一步进入条件：
  - 已识别 migration 非确定性问题，且 ED-1 其余修复保持不回退
