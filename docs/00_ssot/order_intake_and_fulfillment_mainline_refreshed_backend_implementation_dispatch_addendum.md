---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the authored refreshed backend implementation dispatch prompt for
  `订单承接与履约承接主链` so the cloud Server execution handoff text stays
  inside the already-frozen post-cleanup continuation scope, while real
  implementation dispatch issuance remains blocked by the current stage veto
  and Phase 0 guardrail.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_refreshed_truth_boundary_freeze_addendum.md
  - docs/01_contracts/order_intake_and_fulfillment_mainline_refreshed_contract_freeze_addendum.md
  - docs/02_backend/order_intake_and_fulfillment_mainline_refreshed_backend_truth_persistence_freeze_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_refreshed_implementation_dispatch_stage_gate_checklist_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_refreshed_bounded_implementation_dispatch_bundle_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_phase0_implementation_exception_review_conclusion_addendum.md
  - docs/02_backend/audit_log_spec.md
  - docs/01_contracts/openapi.yaml
---

# 《订单承接与履约承接主链 refreshed backend implementation dispatch》

## 1. 当前阶段

- 主对象：
  - `订单承接与履约承接主链`
- 子阶段：
  - `refreshed backend implementation dispatch authoring`
- 当前只允许处理：
  - `Server` 侧 continuation read corridor 的最小闭合
  - `POST /server/milestone/submit`
    的最小 shell / handoff truth position
  - `POST /server/inspection/submit`
    的最小 shell / handoff truth position
  - `workbench`
    的 `activeOrderId / activeMilestoneId`
    continuation projection
  - upload 三段式与 `Evidence -> FileAsset`
    的最小复用
  - `MilestoneSubmitted / InspectionSubmitted`
    的最小审计留痕
- 当前必须明确：
  - 这份文书只是在 author 后端派工口令
  - 当前仍然不是 `real backend implementation dispatch issuance`
  - 当前仍不得直接发送给 `后端 Agent`

## 2. 当前唯一动作

- 供后续使用的 `后端 Agent` 执行口令如下。
- 当前口令已 author 完成，但在 `real backend implementation dispatch issuance`
  veto 单独解除前不得发送。

## 3. 后端 Agent 口令正文

```text
你是后端 Agent（仅云端），本轮不是重做整个交易链，也不是解除 `Phase 0` 的 trading-flow guardrail。你这轮只在《订单承接与履约承接主链》已经冻结好的 post-cleanup refreshed bounded 范围内，完成 Server 侧最小实现。

【一、唯一目标】
你这轮只完成 6 件事：
1. 闭合当前已冻结的 continuation read corridor：
   - `GET /server/order/detail`
   - `GET /server/contract/detail`
   - `GET /server/milestone/list`
   - `GET /server/inspection/detail`
2. 落地当前已冻结的 `milestone/submit` shell / handoff runtime：
   - 只允许沿用 `POST /server/milestone/submit`
   - minimum request：
     - `milestoneId`
     - `submissionNote` 为可选
   - accepted body 只允许：
     - `milestoneId`
3. 落地当前已冻结的 `inspection/submit` shell / handoff runtime：
   - 只允许沿用 `POST /server/inspection/submit`
   - minimum request：
     - `inspectionId`
   - accepted body 只允许：
     - `inspectionId`
     - `milestoneId`
     - `state`
     - `summary`
4. 让 `server/exhibition/workbench` 只输出最小 continuation anchor projection：
   - `activeOrderId`
   - `activeMilestoneId`
5. 保持 upload 三段式与 `Evidence -> FileAsset` 复用成立：
   - `init -> direct upload -> confirm`
   - `objectKey` 继续不是真值
6. 保持最小业务审计留痕：
   - `MilestoneSubmitted`
   - `InspectionSubmitted`

【二、强制阅读】
- docs/00_ssot/order_intake_and_fulfillment_mainline_refreshed_truth_boundary_freeze_addendum.md
- docs/01_contracts/order_intake_and_fulfillment_mainline_refreshed_contract_freeze_addendum.md
- docs/02_backend/order_intake_and_fulfillment_mainline_refreshed_backend_truth_persistence_freeze_addendum.md
- docs/00_ssot/order_intake_and_fulfillment_mainline_refreshed_bounded_implementation_dispatch_bundle_addendum.md
- docs/02_backend/audit_log_spec.md
- docs/01_contracts/openapi.yaml

【三、只允许处理的范围】
- apps/server/src/modules/trading_read_corridor/**
- apps/server/src/modules/trading_shell_handoff/**
  但只限：
  - `milestone/submit`
  - `inspection/submit`
- apps/server/src/modules/exhibition_workbench/**
- apps/server/src/modules/upload/**
- 与上述冻结对象直接相关的最小 supporting touch

【四、禁止事项】
- 不得改 `apps/server/src/modules/my_project/**`
- 不得重开 `order/create`
- 不得重开 `contract/confirm`
- 不得重开 `contract/amend`
- 不得重开 `inspection/recheck`
- 不得重开 `rating/*`
- 不得重开 `dispute/*`
- 不得新增新 path family
- 不得新增第二状态机
- 不得把 `dispute/open` 写回当前对象
- 不得把 `workbench` 写成 truth owner
- 不得把 `objectKey` 写成业务真值
- 不得把 `milestone/submit`、`inspection/submit`
  写成 truth already advanced
- 不得把 `page shell / placeholder / route presence`
  当成后端完成证据

【五、必须落实的真义】
1. order / contract / milestone / inspection continuation read
- 只允许承接当前最小字段：
  - `orderId / orderNo / projectId / bidId / state / summary`
  - `contractId / orderId / state / summary`
  - `milestoneId / orderId / sequenceNo / title / amount / state / summary`
  - `inspectionId / milestoneId / state / summary / rectificationCount / recheckCount`
- controlled unavailable / invalid-state / missing-anchor
  继续由 `Server` 决定
- 不得把 route presence 写成 runtime 闭环完成

2. milestone submit handoff truth
- `trading_shell_handoff.submitMilestone`
  只允许校验 canonical milestone / order truth
  是否允许继续 handoff
- accepted body 只回：
  - `milestoneId`
- 这不等于 `milestone.state`
  已因当前 path 完成持久化推进
- 如涉及文件补充：
  - 只能复用 `Evidence -> FileAsset`
  - 只能复用 `init -> direct upload -> confirm`
  - 不得把 upload schema 反客为主

3. inspection submit handoff truth
- `trading_shell_handoff.submitInspection`
  只允许校验 canonical inspection / order truth
  是否允许继续 handoff
- accepted body 只承载：
  - `inspectionId`
  - `milestoneId`
  - `state`
  - `summary`
- 这不等于 inspection truth
  已在当前 path 内持久化推进完成
- 当前不纳入：
  - `inspection/recheck`
  - inspection history
  - 最终闭环归档

4. workbench continuation projection
- `workbench.order_chain`
  只继续承载：
  - `activeOrderId`
- `workbench.fulfillment_chain`
  只继续承载：
  - `activeMilestoneId`
- 不得把 `workbench` 写成：
  - detail owner
  - truth owner
  - 控制台 owner

5. audit / evidence boundary
- `audit_logs`
  是当前对象唯一业务审计 carrier
- 当前只允许最小 must-audit 动作：
  - `MilestoneSubmitted`
  - `InspectionSubmitted`
- 当前不扩：
  - `OrderCreated`
  - `ContractConfirmed`
  - `ContractAmended`
  - `InspectionRecheckSubmitted`
  - `DisputeOpened`
  - `InspectionDecisionChanged`

【六、完成标准】
- `trading_read_corridor`
  读链在当前冻结字段内可跑
- `POST /server/milestone/submit`
  在当前冻结字段内可跑，且仍是 shell / handoff
- `POST /server/inspection/submit`
  在当前冻结字段内可跑，且仍是 shell / handoff
- `exhibition_workbench`
  只返回最小 continuation anchor
- upload 三段式未被破坏
- 最小审计落点存在
- 排除项没有被顺手带回

【七、回执要求】
回执必须单独落盘，并给出云端绝对路径。回执至少包含：
1. 当前对象
2. 修改文件清单
3. 读链闭合结果：
   - `order/detail`
   - `contract/detail`
   - `milestone/list`
   - `inspection/detail`
4. shell / handoff 结果：
   - `milestone/submit`
   - `inspection/submit`
5. `workbench` continuation anchor 结果
6. upload / evidence 复用结果
7. 审计落点结果
8. 当前剩余阻断项
9. 是否可移交 `BFF Agent`

【八、输出禁令】
- 不要写“应该可以”
- 不要把 authoring 当成 send
- 不要把 shell / handoff 节点包装成 active command family
- 不要把 blocker 包装成 success
- 不要扩到 `my_project`
- 不要扩到 rating / dispute / recheck
- 只给真实代码修改与真实 smoke 结果
```

## 4. 只允许处理的目录范围

- 只允许写：
  - `apps/server/src/modules/trading_read_corridor/**`
  - `apps/server/src/modules/trading_shell_handoff/**`
    但只限：
    - `milestone/submit`
    - `inspection/submit`
  - `apps/server/src/modules/exhibition_workbench/**`
  - `apps/server/src/modules/upload/**`
  - 与上述冻结对象直接相关的最小 supporting touch
- 不得扩到无关模块。

## 5. 禁止事项

- 不得重开：
  - `order/create`
  - `contract/confirm`
  - `contract/amend`
  - `inspection/recheck`
  - `rating/*`
  - `dispute/*`
- 不得新增新 path family
- 不得新增第二状态机
- 不得把 `dispute/open` 写回当前对象
- 不得把 `workbench` 写成 truth owner
- 不得把 `objectKey` 写成业务真值
- 不得把 shell / handoff 节点写成 runtime write chain 已闭环

## 6. 完成标准

- authoring 完成的标准只限：
  - prompt 文本已形成
  - 作用域已冻结
  - 禁止事项已写死
  - refreshed contract / backend truth 的路径与 accepted body 已对齐
- 当前不得写成：
  - 后端代码已实现
  - 云端已验证通过
  - 可直接移交结果校验

## 7. Formal Conclusion

- `Go for refreshed package-level implementation unlock assessment authoring`
- `No-Go for real backend implementation dispatch issuance`
- `No-Go for direct implementation`
- `No-Go for integration`
- `No-Go for release-prep`
- `No-Go for production release`

## 8. Next Unique Action

- 下一步唯一动作：
  - 输出《订单承接与履约承接主链 refreshed package-level implementation unlock assessment》
