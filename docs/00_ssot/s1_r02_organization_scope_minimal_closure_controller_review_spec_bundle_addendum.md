---
owner: 总控文书冻结
status: frozen
purpose: Freeze the controller-review spec bundle for S1-R02 organization scope minimal closure, limiting the next step to control-led review only and blocking implementation or execution prompts.
layer: L0 SSOT
freeze_date_local: 2026-04-09
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/s1_r01_option_a_acceptance_and_controller_review_release_conclusion_addendum.md
  - docs/00_ssot/stage1_repair_dispatch_master_addendum.md
---

# 《S1-R02 organization scope minimal closure controller review spec bundle》

## 1. review 目标

- 本轮 review 目标固定为：
  - 判断 `S1-R02` 是否具备进入 `execution-dispatch` 的条件
- 本轮只允许做：
  - controller review
- 本轮明确不做：
  - implementation
  - execution prompt
  - execution dispatch

## 2. review 对象范围

- 本轮 review 对象范围只允许围绕：
  - organization scope 最小闭环所需的真实前置
  - `Server truth / BFF aggregation / mobile consumption` 之间的最小边界
  - 当前与 organization 作用域相关的：
    - route
    - contract
    - actor
    - eligibility
    - visibility trimming
    - scope ownership
- 本轮只允许围绕 `S1-R02`，不得扩到：
  - `S1-R03` certification
  - `S1-R04` admin ops
  - `S1-R05` appeals
  - `S1-R06` messages
  - `阶段2`

## 3. 当前 S1-R02 的真实目标

- `S1-R02` 的真实目标固定为：
  - 稳定 `/server/shell/context`
  - 稳定 `/server/profile/organization/create|join-by-code|switch`
  - 稳定 `/api/app/profile/organization/mine`
  - 确保以下最小字段与作用域承接可稳定消费：
    - `organizationId`
    - `roleKeys`
    - `certificationStatus`
    - `membershipStatus`
    - `visibleBuildings`

## 4. S1-R02 解决什么，不解决什么

- `S1-R02` 解决：
  - organization scope 最小闭环是否真实成立
  - actor 在 `Server -> BFF -> mobile` 间的最小承接是否一致
  - scope ownership 与 visibility trimming 是否具备最小真源边界
- `S1-R02` 不解决：
  - certification 上传 / 提交 / 重提闭环
  - admin 审核运营闭环
  - appeals 路由对齐
  - messages active object 裁决
  - 任何 `阶段2` 对象

## 5. review 输出必须至少包含

- 本轮 review 输出至少必须包含：
  - 当前 `S1-R02` 的真实目标
  - `S1-R02` 解决什么，不解决什么
  - `S1-R02` 前置是否成立
  - 当前主阻塞
  - 是否 `Go for execution-dispatch` 或 `No-Go`
  - 若 `Go`，先派给哪个角色
  - 若 `No-Go`，卡在哪个 gate
- 若 review 结论为 `Go`，当前默认第一执行角色应固定优先评估为：
  - `后端 Agent`
- 理由固定为：
  - organization scope 的 truth ownership 在 `Server`

## 6. review 参与角色

- 本轮 review 参与角色固定为：
  - `总控`：主判
  - `总控文书冻结`：只负责收口
- 本轮明确不得：
  - 直接向前端发 implementation 口令
  - 直接向 `BFF` 发 implementation 口令
  - 直接向后端发 implementation 口令

## 7. 当前禁止进入

- 当前明确不得进入：
  - `S1-R02 execution`
  - `S1-R03+`
  - `阶段2`
  - `release-prep`
  - `launch`

## 8. 下一步唯一动作

- 当前下一步唯一动作必须固定为：
  - 由总控依据本 spec 发起 `S1-R02 controller review`

## 9. Formal Conclusion

- `S1-R02 organization scope minimal closure controller review spec bundle` 已冻结。
- 当前正式口径已写死为：
  - 本轮只做 controller review
  - 本轮不做 implementation
  - 本轮不做 execution prompt
  - 当前不得直接进入 `S1-R02 execution / S1-R03+ / 阶段2 / release-prep / launch`
