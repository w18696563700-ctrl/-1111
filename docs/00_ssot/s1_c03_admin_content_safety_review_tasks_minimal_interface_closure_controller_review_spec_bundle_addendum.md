---
owner: 总控文书冻结
status: frozen
purpose: Freeze the controller-review spec bundle for S1-C03 admin content-safety review-tasks minimal interface closure, requiring a canonical-family ruling before any execution-dispatch.
layer: L0 SSOT
freeze_date_local: 2026-04-09
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/s1_c01_message_index_minimal_closure_result_verification_conclusion_addendum.md
  - apps/admin/src/core/server/admin-api-client.ts
  - docs/00_ssot/stage1_repair_dispatch_master_addendum.md
---

# 《S1-C03 admin content-safety review-tasks minimal interface closure controller review spec bundle》

## 1. review 目标

- 本轮 review 目标固定为：
  - 判断 `S1-C03` 是否具备进入 execution-dispatch 的条件
  - 本轮只做 controller review，不做 implementation，不做 execution prompt

## 2. review 对象范围

- 本轮 review 对象范围固定为：
  - Admin client 当前依赖的：
    - `/content-safety/review-tasks`
    - `/content-safety/review-tasks/{taskId}`
    - `/content-safety/profile-submissions/{submissionId}/approve`
    - `/content-safety/profile-submissions/{submissionId}/reject`
  - 上述 admin-facing family 在 `Server` 是否存在真实 canonical upstream
  - 只允许围绕 `S1-C03`
- 本轮明确不得扩到：
  - 完整 Admin 平台
  - `S1-R04 organizations review`
  - `S1-R05 appeals`
  - `S1-R06 messages`
  - `S1-C02`
  - `阶段2`

## 3. 当前已知主阻塞

- 当前已知主阻塞必须写死为：
  - `apps/admin/src/core/server/admin-api-client.ts` 当前明确依赖 `/content-safety/review-tasks*` 与 `/content-safety/profile-submissions/*`
  - 当前 `apps/server/src/modules/**` 中未见对应 `content-safety/review-tasks` controller family
  - 因此当前是 Admin client 依赖存在，但 `Server` canonical interface 缺失的 orphan API gap

## 4. review 必须显式判断

- 本轮 review 必须显式判断：
  - active canonical family 到底是哪一条
  - 是补齐现有 admin client 依赖的 canonical path
  - 还是做同等 canonical 对齐并同步 client
  - 当前缺口在 `Server` 还是 Admin client
  - 是否 `Go for execution-dispatch` 或 `No-Go`
  - 若 Go，先派给哪个角色
  - 若 No-Go，卡在哪个 gate

## 5. review 输出必须至少包含

- 本轮 review 输出必须至少包含：
  - 当前 `S1-C03` 的真实目标
  - `S1-C03` 解决什么，不解决什么
  - 当前主阻塞
  - active canonical family judgment
  - 是否 `Go for execution-dispatch` 或 `No-Go`
  - 若 Go，先派哪个角色
  - 若 No-Go，卡在哪个 gate

## 6. review 参与角色

- 本轮 review 参与角色固定为：
  - `总控` 主判
  - `总控文书冻结` 只负责收口
  - 不得直接向 `后端 / 前端` 发 implementation 口令

## 7. 当前禁止进入

- 当前明确不得进入：
  - `S1-C03 execution`
  - `S1-C02`
  - `阶段2`
  - `release-prep`
  - `launch`

## 8. 下一步唯一动作

- 当前下一步唯一动作必须固定为：
  - 由总控依据本 spec 发起 `S1-C03 controller review`

## 9. Formal Conclusion

- `S1-C03 admin content-safety review-tasks minimal interface closure controller review spec bundle` 已冻结。
- 当前正式口径已写死为：
  - 本轮只允许做 controller review，不做 implementation，不做 execution prompt
  - 当前 review 主体是 admin client 依赖的 `content-safety` canonical family 与 `Server` active canonical interface 的对齐裁决
  - 当前已知主阻塞不是 review-task 业务规则未定，而是 Admin client 依赖存在、`Server` canonical interface 缺失
  - 本轮必须由总控显式判断 active canonical family、缺口归属以及是否允许进入 execution-dispatch
  - 在 review 结论形成前，不得进入 `S1-C03 execution / S1-C02 / 阶段2 / release-prep / launch`
