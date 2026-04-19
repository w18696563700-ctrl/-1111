---
owner: 总控文书冻结
status: frozen
purpose: Freeze the controller-review spec bundle for S1-R05 governance appeals BFF-server route alignment, requiring a controller-level ruling on the active canonical family before any execution-dispatch.
layer: L0 SSOT
freeze_date_local: 2026-04-09
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/s1_r04_certification_minimal_review_ops_closure_result_verification_conclusion_addendum.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/cs030_my_appeal_history_p2a_completion_filing_addendum.md
  - docs/00_ssot/cs030_my_appeal_history_p2a_result_verification_pass_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/bff/src/routes/profile/profile-governance-appeals.service.ts
---

# 《S1-R05 governance appeals BFF-server route alignment controller review spec bundle》

## 1. review 目标

- 本轮 review 目标固定为：
  - 判断 `S1-R05` 是否具备进入 execution-dispatch 的条件
  - 本轮只做 controller review，不做 implementation，不做 execution prompt

## 2. review 对象范围

- 本轮 review 对象范围固定为：
  - `BFF <-> Server governance appeals` 路由对齐
  - app-facing canonical family：
    - `/api/app/profile/governance/appeals`
    - `/api/app/profile/governance/appeals/{appealCaseId}`
  - server canonical family 是否真实存在并与 BFF 对齐
  - 只允许围绕 `S1-R05`
- 本轮明确不得扩到：
  - `S1-C03 content-safety/review-tasks`
  - `S1-R06 messages`
  - `阶段2`
  - governance penalties / appeal decide admin desk 全量平台化

## 3. 当前已知主阻塞

- 当前已知主阻塞必须写死为：
  - BFF 当前 `profile-governance-appeals.service.ts` 指向：
    - `/server/profile/governance/appeals*`
  - 当前代码可见的 Server controller 是：
    - `/server/admin/governance/appeals`
  - 因此存在 BFF target 与 Server active controller family 漂移
  - 同时已有旧 SSOT / CS030 文书声称 `/server/profile/governance/appeals*` 已冻结 accepted
  - 本轮 review 必须显式判断：
    - 是代码落后于文书
    - 还是文书落后于代码
    - active canonical family 到底是哪一条

## 4. review 输出必须至少包含

- 本轮 review 输出必须至少包含：
  - 当前 `S1-R05` 的真实目标
  - `S1-R05` 解决什么，不解决什么
  - `S1-R05` 前置是否成立
  - 当前主阻塞
  - 是否 `Go for execution-dispatch` 或 `No-Go`
  - 若 Go，先派给哪个角色
  - 若 No-Go，卡在哪个 gate

## 5. review 参与角色

- 本轮 review 参与角色固定为：
  - `总控` 主判
  - `总控文书冻结` 只负责收口
  - 不得直接向 `后端 / BFF / 前端` 发 implementation 口令

## 6. 当前禁止进入

- 当前明确不得进入：
  - `S1-R05 execution`
  - `S1-R06`
  - `阶段2`
  - `release-prep`
  - `launch`

## 7. 下一步唯一动作

- 当前下一步唯一动作必须固定为：
  - 由总控依据本 spec 发起 `S1-R05 controller review`

## 8. Formal Conclusion

- `S1-R05 governance appeals BFF-server route alignment controller review spec bundle` 已冻结。
- 当前正式口径已写死为：
  - 本轮只允许做 controller review，不做 implementation，不做 execution prompt
  - 当前 review 主体是 `BFF <-> Server governance appeals` canonical family 的对齐裁决
  - 已知主阻塞不是功能页缺失，而是 BFF target、Server active controller family 与旧 SSOT accepted 路由之间存在漂移
  - 本轮必须由总控判断 active canonical family，到底是代码落后于文书，还是文书落后于代码
  - 在 review 结论形成前，不得进入 `S1-R05 execution / S1-R06 / 阶段2 / release-prep / launch`
