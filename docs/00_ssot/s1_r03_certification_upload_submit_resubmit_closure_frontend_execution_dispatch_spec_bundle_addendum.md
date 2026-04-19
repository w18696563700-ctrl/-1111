---
owner: 总控文书冻结
status: frozen
purpose: Freeze the frontend execution-dispatch spec bundle for S1-R03 certification upload, submit, and resubmit closure, limiting the repair to bounded mobile-side consumption-path closure and blocking unrelated changes.
layer: L0 SSOT
freeze_date_local: 2026-04-09
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/s1_r03_certification_upload_submit_resubmit_closure_controller_review_conclusion_addendum.md
  - docs/00_ssot/stage1_repair_dispatch_master_addendum.md
---

# 《S1-R03 certification upload submit resubmit closure frontend execution-dispatch spec bundle》

## 1. 第一执行角色

- 第一执行角色固定为：
  - `前端 Agent`

## 2. execution 目标

- 本轮 execution 目标固定为：
  - 在 mobile 认证提交 / 重提页接入三步上传：
    - init
    - direct upload
    - confirm
  - 用 confirm 返回的 `fileAssetId` 绑定 submit / resubmit
  - 取消手填 `licenseFileId` 作为 happy-path 主路径

## 3. 允许改动范围

- 本轮只允许改动 `apps/mobile/**` 中与以下对象直接相关的最小闭环：
  - certification submit / resubmit consumer
  - certification submit / resubmit pages
  - upload directive / parser / result models 的最小复用或抽取
  - controlled loading / error / retry states
  - 必要时最小 mobile tests
- 本轮允许：
  - 复用现有 profile personal avatar upload 模式
  - 做最小 shared mobile-side abstraction，但不得扩成大重构

## 4. 禁止改动范围

- 本轮明确禁止改动：
  - `apps/server/**`
  - `apps/bff/**`
  - `docs/**`
  - `S1-R04+`
  - `阶段2`
  - organization scope
  - appeals
  - messages
  - `payment / billing`
  - `V2.3`
- 本轮同时明确禁止：
  - 保留手填 `licenseFileId` 为主 happy path

## 5. execution 完成后必须交付

- execution 完成后必须交付以下内容：
  - 变更文件清单
  - upload init / direct upload / confirm 如何接入认证主路径
  - submit / resubmit 如何消费 confirmed `fileAssetId`
  - 当前是否仍保留手填 `licenseFileId`，若保留只允许作为受控 fallback，不得是主路径
  - controlled error states 说明
  - build / test 结果
  - bounded smoke 结果
  - 唯一 receipt 路径

## 6. 唯一 receipt 路径

- 本轮唯一正式 receipt 路径必须写死为：
  - [s1_r03_certification_upload_submit_resubmit_closure_frontend_execution_dispatch_receipt_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/s1_r03_certification_upload_submit_resubmit_closure_frontend_execution_dispatch_receipt_addendum.md)

## 7. 当前禁止进入

- 当前明确不得放行：
  - `S1-R04+`
  - `阶段2`
  - `release-prep`
  - `launch`

## 8. 下一步唯一动作

- 当前下一步唯一动作必须固定为：
  - 由总控向 `前端 Agent` 发出 execution-dispatch 口令

## 9. Formal Conclusion

- `S1-R03 certification upload submit resubmit closure frontend execution-dispatch spec bundle` 已冻结。
- 当前正式口径已写死为：
  - 第一执行角色为 `前端 Agent`
  - 本轮修复目标是在 mobile 认证主路径接入 `init -> direct upload -> confirm -> submit/resubmit`
  - 本轮只允许最小 `apps/mobile/**` consumption-path 闭环修复
  - 当前不得放行 `S1-R04+ / 阶段2 / release-prep / launch`
