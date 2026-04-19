---
owner: 总控文书冻结
status: frozen
purpose: Freeze the backend execution-dispatch spec bundle for S1-R02 organization scope minimal closure, limiting the repair to bounded server-side truth alignment and blocking unrelated changes.
layer: L0 SSOT
freeze_date_local: 2026-04-09
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/s1_r02_organization_scope_minimal_closure_controller_review_conclusion_addendum.md
  - docs/00_ssot/stage1_repair_dispatch_master_addendum.md
---

# 《S1-R02 organization scope minimal closure backend execution-dispatch spec bundle》

## 1. 第一执行角色

- 第一执行角色固定为：
  - `后端 Agent`

## 2. execution 目标

- 本轮 execution 目标固定为：
  - 把 current organization scope 从 hint-compatible 修到 truth-compatible
- 必须保证 switch 后以下读取在后续访问中指向一致的 current scope truth：
  - `/server/shell/context`
  - `/server/profile/index`
  - `/server/profile/organization/mine`
  - `/server/profile/organization/members`

## 3. 允许改动范围

- 本轮只允许改动 `apps/server/**` 中与以下对象直接相关的最小闭环：
  - current session verification
  - access carrier / session-bound organization scope
  - organization switch truth handoff
  - current actor eligibility
  - shell context query
  - profile organization read surfaces
- 必要时允许补最小 server-side tests。

## 4. 禁止改动范围

- 本轮明确禁止改动：
  - `apps/mobile/**`
  - `apps/bff/**`
  - certification submit/resubmit body
  - admin review
  - appeals
  - messages
  - `stage2`
  - `payment / billing`
  - `V2.3`
  - unrelated docs

## 5. execution 完成后必须交付

- execution 完成后必须交付以下内容：
  - 明确说明 organization switch 如何落真源
  - 明确说明 `shell/context` 与 `profile/index` 如何读取同一 current scope
  - 明确说明是否仍依赖 `x-organization-id` hint
  - build / test 结果
  - bounded smoke 结果
  - 唯一 receipt 路径

## 6. 唯一 receipt 路径

- 本轮唯一正式 receipt 路径必须写死为：
  - [s1_r02_organization_scope_minimal_closure_backend_execution_dispatch_receipt_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/s1_r02_organization_scope_minimal_closure_backend_execution_dispatch_receipt_addendum.md)

## 7. 当前禁止进入

- 当前明确不得放行：
  - `S1-R03+`
  - `阶段2`
  - `release-prep`
  - `launch`

## 8. 下一步唯一动作

- 当前下一步唯一动作必须固定为：
  - 由总控向 `后端 Agent` 发出 execution-dispatch 口令

## 9. Formal Conclusion

- `S1-R02 organization scope minimal closure backend execution-dispatch spec bundle` 已冻结。
- 当前正式口径已写死为：
  - 第一执行角色为 `后端 Agent`
  - 本轮修复目标是把 organization scope 从 hint-compatible 修到 truth-compatible
  - 本轮只允许最小 `apps/server/**` 真源闭环修复
  - 当前不得放行 `S1-R03+ / 阶段2 / release-prep / launch`
