---
owner: 总控文书冻结
status: frozen
purpose: Freeze the S2 BFF aggregation controller review spec bundle on top of the already-verified server truth carriers, without unlocking implementation or execution.
layer: L0 SSOT
freeze_date_local: 2026-04-09
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/stage2_stage_gate_checklist_addendum.md
  - docs/00_ssot/s2_trading_mainline_minimal_transport_closure_controller_review_spec_bundle_addendum.md
  - docs/00_ssot/s2_order_contract_fulfillment_read_corridor_minimal_transport_closure_result_verification_receipt_addendum.md
  - docs/00_ssot/s2_order_contract_fulfillment_read_corridor_minimal_transport_closure_result_verification_conclusion_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/server/src/app.module.ts
  - apps/server/src/modules/trading_read_corridor/trading-read-corridor.controller.ts
  - apps/server/src/modules/trading_read_corridor/trading-read-corridor.module.ts
  - apps/server/src/modules/trading_read_corridor/trading-read-corridor.presenter.ts
  - apps/server/src/modules/trading_read_corridor/trading-read-corridor.query.service.ts
  - apps/bff/src/routes/project/app-project.controller.ts
  - apps/bff/src/routes/project/project.controller.ts
  - apps/bff/src/routes/project/project.module.ts
  - apps/bff/src/routes/project/project.service.ts
  - apps/bff/src/routes/my_project/my-project.controller.ts
  - apps/bff/src/routes/my_project/my-project.service.ts
  - apps/bff/src/routes/exhibition_workbench/app-exhibition-workbench.controller.ts
  - apps/bff/src/routes/exhibition_workbench/exhibition-workbench.module.ts
  - apps/bff/src/routes/exhibition_workbench/exhibition-workbench.service.ts
  - apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart
  - apps/mobile/lib/features/messages/data/messages_registered_entry_registry.dart
---

# 《S2 BFF order-contract-fulfillment read corridor aggregation controller review spec bundle》

## 1. review 目标

- 本轮 review 目标固定为：
  - 判断下一轮是否应锁定为：
    - `S2 BFF order-contract-fulfillment read corridor aggregation`
- 本轮只做 controller review。
- 本轮不做 implementation。
- 本轮不做 execution prompt。

## 2. review 对象范围

- 本轮 review 对象范围至少覆盖：
  - `/api/app/order/detail`
  - `/api/app/contract/detail`
  - `/api/app/milestone/list`
  - `/api/app/inspection/detail`
  - `apps/bff/src/routes/project/**`
  - `apps/bff/src/routes/exhibition_workbench/**`
  - 当前 BFF app-facing route group 缺口
  - 当前 Server 新增的 4 条 upstream carrier
- 当前 route-gap 事实必须被 review 明确承接：
  - `docs/01_contracts/openapi.yaml` 与 `apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart` 已冻结上述 4 条 app-facing canonical path。
  - `apps/mobile/lib/features/messages/data/messages_registered_entry_registry.dart` 已把 `contract.confirm`、`contract.amend`、`inspection.submit`、`dispute.open`、`dispute.withdraw` 继续锚定到这些 read path。
  - 当前 `apps/bff/src/routes` 内尚无 `api/app/order`、`api/app/contract`、`api/app/milestone`、`api/app/inspection` 对应 controller group；因此 gap 位于 BFF aggregation，而不是 backend truth 缺失。

## 3. 必须基于的冻结事实

- `S2` 第一对象 backend truth carrier 已形成并通过独立校验。
- 下一步不应重做 backend truth。
- 下一步应判断 BFF aggregation 如何最小闭环承接这 4 条 upstream。
- 当前 Server 上游已有独立 read corridor：
  - `GET /server/order/detail`
  - `GET /server/contract/detail`
  - `GET /server/milestone/list`
  - `GET /server/inspection/detail`
- 当前 BFF 既有壳仍保持边界：
  - `project/**` 仍承接 project list / create / detail，不是 fulfillment detail corridor。
  - `my_project/**` 仍承接 owner-scoped private-progress regroup summary，不是四条细读 carrier。
  - `exhibition_workbench/**` 仍承接 summary / entry posture，不是 order-contract-fulfillment detail surface。
- command family 仍然保持 frozen：
  - `bid`
  - `rating`
  - `dispute`
  - `order/create`
  - `contract/confirm`
  - `contract/amend`
  - `inspection/recheck`

## 4. review 输出必须至少包含

- 本轮 review 输出必须至少包含：
  - 当前 `S2` 下一对象的真实目标
  - 为什么它应是 BFF aggregation，而不是继续 backend 扩写
  - 应先聚合哪 4 条 app-facing path
  - 与 `project / workbench` 现有 BFF 壳如何边界分离
  - 是否 `Go for execution-dispatch` 或 `No-Go`
  - 若 Go，第一执行角色是谁
  - 若 No-Go，卡在哪个 gate
- 本轮 review 还必须回答以下控制问题：
  - 这 4 条 app-facing path 是否应进入一个独立的 aggregation controller family，而不是回填到 `project` 或 `workbench` summary 壳
  - BFF 在最小闭环内只应做 header forwarding、error normalization、read-model adaptation 到什么程度
  - 是否允许在不解冻 command family 的前提下，仅先闭环四条 read path

## 5. 当前禁止进入

- 当前禁止进入必须写死为：
  - `stage2 implementation`
  - `release-prep`
  - `launch`
  - `payment / billing`
  - `V2.3`
  - `个人实名`
  - 完整 trading command family

## 6. 下一步唯一动作

- 当前下一步唯一动作必须写死为：
  - `由总控依据本 spec 发起 S2 BFF aggregation controller review`

## 7. Formal Conclusion

- `S2 BFF order-contract-fulfillment read corridor aggregation controller review spec bundle` 已冻结。
- 当前正式口径已写死为：
  - `S2` 下一轮只允许 review `BFF aggregation`，不允许重做 backend truth
  - 本轮 review 只讨论 4 条 app-facing read path 的最小闭环承接
  - 本轮 review 不得偷换成 `stage2 implementation`
  - 在 review 形成正式 Go / No-Go 之前，`stage2 implementation / release-prep / launch / payment / billing / V2.3 / 个人实名 / 完整 trading command family` 一律不得进入
