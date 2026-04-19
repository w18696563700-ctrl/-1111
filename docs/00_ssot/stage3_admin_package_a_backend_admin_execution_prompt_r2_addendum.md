---
owner: Codex 总控
status: frozen
purpose: Freeze the corrective execution prompt for stage3 package A after rejecting closure due to a broken admin-side test harness.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/stage3_admin_package_a_result_verification_conclusion_addendum.md
  - docs/00_ssot/stage3_admin_package_a_backend_admin_execution_prompt_addendum.md
---

# 《阶段3 package A backend/admin execution prompt R2》

## 1. 角色与目标

- 你现在继续是：
  - `阶段 3｜Admin 最小运营与治理闭环`
  - `package A backend/admin owner`
- 你的唯一任务不是重做 package A。
- 你的唯一任务是：
  - 修掉 `apps/admin` 当前不可复现的最小测试证据
  - 让 route-guard / api-client 的 admin-side verification 在当前 workspace 下可独立跑通

## 2. 当前唯一 blocker

- verifier 已确认：
  - `apps/server` 三条定向测试可通过
  - package A 业务范围没有被推翻
- 但 verifier 同时确认：
  - 回执里声称通过的 admin-side 测试命令无法被独立复现
  - 直接运行 `node --test test/admin-route-guard.test.cjs test/admin-api-client.test.cjs` 时，
    测试文件引用的：
    - `../.test-dist/core/auth/route-guard.js`
    - `../.test-dist/core/server/admin-api-client.js`
    当前不能稳定命中可复核产物
- 因此当前 blocker 不是业务逻辑，而是：
  - `apps/admin` 最小测试 harness 失真

## 3. 本轮只做

- 本轮只允许做：
  - `apps/admin` route-guard / api-client 测试 harness 修复
  - 与上述测试 harness 直接相关的最小编译或运行入口整理

## 4. 本轮不做

- 本轮明确不做：
  - `review / penalties / appeals` 业务扩写
  - `project_review`
  - `template_config`
  - `audit`
  - `ticketing`
  - `apps/server` 新功能改动
  - `apps/mobile`
  - `apps/bff`
  - `release / deploy`

## 5. 允许修改范围

- 只允许修改：
  - `apps/admin/test/admin-route-guard.test.cjs`
  - `apps/admin/test/admin-api-client.test.cjs`
  - 若确有必要，可做与测试产物路径直接相关的最小 `apps/admin` 测试编译入口
  - 若确有必要，可做不改变业务语义的最小 `apps/admin/src/core/auth/**` / `apps/admin/src/core/server/**` 导出整理
- 不允许修改：
  - `apps/server/**` 业务逻辑
  - `apps/admin` 业务页面逻辑
  - `project_review / template_config / audit / ticketing`

## 6. 你必须完成

1. 让以下两组测试在当前 workspace 中可独立复现：
   - `admin-route-guard.test.cjs`
   - `admin-api-client.test.cjs`
2. 给出一条当前 workspace 下真实可跑通的最小命令链。
3. 不得再让测试依赖一个总控无法稳定复现的 `.test-dist` 路径假设。
4. 若采用编译产物方案，测试引用路径与产物路径必须严格对齐。
5. 若采用其他最小运行方案，也不得改变业务语义，只允许修测试执行面。

## 7. 你必须遵守

1. 不得顺手改 package A 的业务范围。
2. 不得为了让测试通过而放松 `server_session_carrier_only`、`review`、`penalties`、`appeals` 的真实边界。
3. 不得把问题转嫁成“总控环境问题”。
4. 不得跳过独立可复现的测试证据。

## 8. 完成标准

- `apps/admin` 最小测试证据可由总控独立复现：
  - route guard 行为
  - api-client transport 行为
- 本轮修复后，package A 才允许继续进入 closure 复核

## 9. 交付回执要求

1. 修改文件清单
2. 为什么之前 admin-side tests 不可复现
3. 现在如何保证测试引用路径与产物路径一致
4. 当前 workspace 下真实可跑通的命令
5. 新增或更新的测试结果
6. 仍未覆盖的非目标清单
