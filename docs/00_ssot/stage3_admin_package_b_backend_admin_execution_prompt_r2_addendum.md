---
owner: Codex 总控
status: frozen
purpose: Freeze the corrective execution-dispatch prompt for stage3 package B after result verification found that the admin transport file exceeded the repo-wide handwritten source limit without a formal exemption.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/stage3_admin_package_b_result_verification_conclusion_addendum.md
  - docs/00_ssot/stage3_admin_package_b_backend_admin_execution_prompt_addendum.md
  - apps/admin/src/core/server/admin-api-client.ts
---

# 《阶段3 package B backend/admin execution prompt R2》

## 1. 角色与目标

- 你现在继续是：
  - `阶段 3｜Admin 最小运营与治理闭环`
  - `package B backend/admin owner`
- 你的唯一任务不是重做 package B。
- 你的唯一任务是：
  - 收掉 `apps/admin/src/core/server/admin-api-client.ts` 的长度/职责 gate
  - 在不改变 package-B 已通过语义的前提下，让 admin-side transport 重新满足仓内 file-length rule

## 2. 当前唯一 blocker

- verifier 已确认：
  - `Server` report-cases 最小实现成立
  - `Admin` `/project_review` seat 成立
  - bounded tests 可独立复现
- 但 verifier 同时确认：
  - [admin-api-client.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/admin/src/core/server/admin-api-client.ts) 当前达到 `554` 行
  - 超过 [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md) 冻结的 handwritten business source limit `450`
  - 当前未见任何 formal exemption truth 为该文件豁免
- 因此当前 blocker 不是业务逻辑，而是：
  - admin transport 文件长度/职责 gate

## 3. 本轮只做

- 本轮只允许做：
  - `apps/admin/src/core/server/admin-api-client.ts` 的 bounded split / export reorganization
  - 与该 split 直接相关的最小 import 调整
  - 与该 split 直接相关的最小测试入口调整

## 4. 本轮不做

- 本轮明确不做：
  - report-cases 业务语义重写
  - review / penalties / appeals 行为改写
  - project_review 页面重写
  - `template_config`
  - `audit`
  - `ticketing`
  - `apps/server/**` 新功能改动
  - `apps/mobile`
  - `apps/bff`
  - `release / deploy`

## 5. 允许修改范围

- 只允许修改：
  - `apps/admin/src/core/server/**`
  - `apps/admin/test/admin-api-client.test.cjs`
  - `apps/admin/test/admin-project-review.test.cjs`
  - `apps/admin/tsconfig.admin-tests.json`
  - 如确有必要，可做最小 `apps/admin/package.json` 测试入口调整
- 不允许修改：
  - `apps/server/**`
  - `apps/admin/src/modules/project_review/**` 的业务语义
  - `apps/admin/src/modules/template_config/**`
  - `apps/admin/src/modules/audit/**`
  - `apps/admin/src/modules/ticketing/**`

## 6. 你必须完成

1. 把 `admin-api-client.ts` 收回到 `450` 行以内。
2. 不得通过口头“这是 transport 汇总文件”来规避 gate。
3. 若采用拆分方案，必须保持 package-B 已通过语义不变：
   - review transport
   - penalties transport
   - appeals transport
   - report-cases transport
   - session-carrier verification probe
4. 推荐做法是：
   - 提取 report-cases family 到独立 client file
   - 或按 domain family 做最小 split
   - 保持 shared runtime / request helper 在最小公共 carrier 中
5. 拆分后，当前 workspace 下以下命令仍须独立通过：
   - `cd apps/admin && npm run test:admin-side`
   - `cd apps/admin && npm run build`
   - `cd apps/admin && ./node_modules/.bin/tsc --noEmit`
   - `cd apps/admin && ./node_modules/.bin/eslint ...`

## 7. 你必须遵守

1. 不得改 package-B 的 active object。
2. 不得把 `/project_review` 重新写回“项目审核状态机”。
3. 不得顺手扩写 package-B 业务范围。
4. 不得引入第二真源。
5. 不得把 file-length 问题转嫁成 formal exemption，除非总控另行 author。

## 8. 完成标准

- `admin-api-client.ts` 或其等价拆分后的当前主文件回到 gate 内。
- package-B 既有 build / test 证据保持通过。
- package-B 业务语义不发生变化。

## 9. 交付回执要求

1. 修改文件清单
2. 为什么当前 `admin-api-client.ts` 触发了 gate
3. 当前如何拆分 transport family 且不改业务语义
4. 拆分后的文件行数
5. 新增或更新的测试结果
6. 仍未覆盖的非目标清单
