---
owner: 总控文书冻结
status: frozen
purpose: Freeze the backend execution-dispatch spec bundle for S1-R04 certification minimal review ops closure, limiting the repair to bounded server-side review acceptance closure and blocking unrelated changes.
layer: L0 SSOT
freeze_date_local: 2026-04-09
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/s1_r04_certification_minimal_review_ops_closure_controller_review_conclusion_addendum.md
  - docs/00_ssot/stage1_repair_dispatch_master_addendum.md
---

# 《S1-R04 certification minimal review ops closure backend execution-dispatch spec bundle》

## 1. 第一执行角色

- 第一执行角色固定为：
  - `后端 Agent`

## 2. execution 目标

- 本轮 execution 目标固定为：
  - 把 `server/admin/reviews/organizations` 最小审核链收口到可独立验收状态
- 必须保证以下对象形成单一 bounded backend closure：
  - list
  - detail
  - approve
  - reject
  - reviewer eligibility
  - audit trail
  - profile / shell readback

## 3. 允许改动范围

- 本轮只允许改动 `apps/server/**` 中与以下对象直接相关的最小闭环：
  - `review` module 的 query / write / presenter / controller
  - `organization` eligibility / certification truth projection
  - `profile / shell` 对认证状态回读承接
  - 必要时最小 server-side tests
- 本轮允许：
  - 最小 migration / fixture only if strictly required
- 但不得扩成：
  - review 平台重构

## 4. 禁止改动范围

- 本轮明确禁止改动：
  - `apps/admin/**`
  - `apps/mobile/**`
  - `apps/bff/**`
  - `docs/**`
  - `S1-C03 content-safety/review-tasks`
  - `S1-R05 appeals`
  - `S1-R06 messages`
  - `阶段2`
  - `payment / billing`
  - `V2.3`

## 5. execution 完成后必须交付

- execution 完成后必须交付以下内容：
  - 变更文件清单
  - `list / detail / approve / reject` 如何形成最小审核链
  - reviewer eligibility 如何承接
  - approve / reject 后 audit 如何落地
  - `profile / shell` 如何回读同一认证状态
  - build / test 结果
  - bounded smoke 结果
  - 唯一 receipt 路径

## 6. 唯一 receipt 路径

- 本轮唯一正式 receipt 路径必须写死为：
  - [s1_r04_certification_minimal_review_ops_closure_backend_execution_dispatch_receipt_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/s1_r04_certification_minimal_review_ops_closure_backend_execution_dispatch_receipt_addendum.md)

## 7. 当前禁止进入

- 当前明确不得放行：
  - `S1-R05+`
  - `阶段2`
  - `release-prep`
  - `launch`

## 8. 下一步唯一动作

- 当前下一步唯一动作必须固定为：
  - 由总控向 `后端 Agent` 发出 execution-dispatch 口令

## 9. Formal Conclusion

- `S1-R04 certification minimal review ops closure backend execution-dispatch spec bundle` 已冻结。
- 当前正式口径已写死为：
  - 第一执行角色为 `后端 Agent`
  - 本轮修复目标是把 `server/admin/reviews/organizations` 最小审核链收口到可独立验收状态
  - 本轮只允许最小 `apps/server/**` 真源闭环修复
  - 当前不得放行 `S1-R05+ / 阶段2 / release-prep / launch`
