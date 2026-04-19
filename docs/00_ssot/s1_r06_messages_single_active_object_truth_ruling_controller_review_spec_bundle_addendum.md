---
owner: 总控文书冻结
status: frozen
purpose: Freeze the controller-review spec bundle for S1-R06 messages single active object truth ruling, forcing a single-active-object decision before any S1-C01 authoring or dispatch.
layer: L0 SSOT
freeze_date_local: 2026-04-09
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/s1_r05_governance_appeals_bff_server_route_alignment_result_verification_conclusion_addendum.md
  - apps/mobile/lib/features/messages/presentation/messages_page.dart
  - apps/mobile/lib/features/messages/data/messages_consumer_layer.dart
  - apps/mobile/lib/features/exhibition/data/forum_consumer_layer.dart
---

# 《S1-R06 messages single active object truth ruling controller review spec bundle》

## 1. review 目标

- 本轮 review 目标固定为：
  - 判断 `messages` building 当前唯一 active object 到底是哪一个
  - 裁掉 `forum interaction inbox` 与 `message/index` 双主线并存
  - 本轮只做 controller review，不做 implementation，不做 execution prompt

## 2. review 对象范围

- 本轮 review 对象范围固定为：
  - `apps/mobile/lib/features/messages/presentation/messages_page.dart`
  - `apps/mobile/lib/features/messages/data/messages_consumer_layer.dart`
  - `messages` building 当前真实消费路径
  - `/api/app/message/index` 的 consumer / routeTarget / contract frozen state
  - BFF / Server 当前是否存在真实 `message/index` truth owner
  - 只允许围绕 `S1-R06`
- 本轮明确不得扩到：
  - `S1-C01` implementation
  - `S1-R06` 之后的 body 扩写
  - `S1-R05 appeals`
  - `S1-C03`
  - `阶段2`

## 3. 当前已知主阻塞

- 当前已知主阻塞必须写死为：
  - `MessagesPage` 当前实际消费的是 `ForumConsumerLayer.loadInteractionInbox(...)`
  - `MessagesConsumerLayer` 当前冻结了 `/api/app/message/index` consumer 和 `instance_todo` contract
  - 当前 `apps/bff/**` 与 `apps/server/**` 中未找到 `message/index` 真实 upstream
  - 因此 `messages` building 当前存在：
    - forum interaction inbox 真实消费线
    - message/index 候选线
    的双主线并存问题

## 4. review 必须显式判断

- 本轮 review 必须显式判断：
  - 当前 active object 是：
    - `forum interaction inbox`
    - 还是 `message/index`
  - 非 active 对象应如何定性：
    - dormant candidate
    - frozen placeholder
    - fail-closed unresolved path
  - 是否允许进入 `S1-C01 message/index minimal closure`
  - 若允许，前提是什么
  - 若不允许，卡在哪个 gate

## 5. review 输出必须至少包含

- 本轮 review 输出必须至少包含：
  - 当前 `S1-R06` 的真实目标
  - `S1-R06` 解决什么，不解决什么
  - 当前唯一 active object 结论
  - 非 active 对象的正式定性
  - 当前主阻塞
  - 是否 `Go for execution-dispatch` 或 `No-Go`
  - 若 Go，下一步进入哪个对象
  - 若 No-Go，卡在哪个 gate
- 这里的 execution-dispatch 仅指进入 `S1-C01` authoring / dispatch 前置，不是直接写 `message/index` body

## 6. review 参与角色

- 本轮 review 参与角色固定为：
  - `总控` 主判
  - `总控文书冻结` 只负责收口
  - 不得直接向 `后端 / BFF / 前端` 发 implementation 口令

## 7. 当前禁止进入

- 当前明确不得进入：
  - `S1-R06 execution`
  - `S1-C01` implementation
  - `S1-R06` 之后的 message body 扩写
  - `阶段2`
  - `release-prep`
  - `launch`

## 8. 下一步唯一动作

- 当前下一步唯一动作必须固定为：
  - 由总控依据本 spec 发起 `S1-R06 controller review`

## 9. Formal Conclusion

- `S1-R06 messages single active object truth ruling controller review spec bundle` 已冻结。
- 当前正式口径已写死为：
  - 本轮只允许做 controller review，不做 implementation，不做 execution prompt
  - 当前 review 主体是 `messages` building 的唯一 active object 裁决，而不是直接补 `message/index` body
  - 已知主阻塞不是单点 consumer 缺字段，而是 `forum interaction inbox` 真实消费线与 `message/index` 候选线并存
  - 当前必须由总控显式判断 active object、非 active 对象定性，以及是否允许进入 `S1-C01` authoring / dispatch 前置
  - 在 review 结论形成前，不得进入 `S1-R06 execution / S1-C01 implementation / 阶段2 / release-prep / launch`
