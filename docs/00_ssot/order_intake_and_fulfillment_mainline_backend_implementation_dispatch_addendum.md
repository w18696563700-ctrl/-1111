---
owner: Codex 总控
status: frozen
purpose: Freeze the authored backend implementation dispatch prompt for `订单承接与履约承接主链` so the cloud Server execution handoff text stays inside the already-frozen continuation scope, while real implementation dispatch issuance remains blocked by the current stage veto.
layer: L0 SSOT
freeze_date_local: 2026-04-11
based_on:
  - docs/00_ssot/order_intake_and_fulfillment_mainline_implementation_dispatch_stage_gate_checklist_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_bounded_implementation_dispatch_bundle_addendum.md
  - docs/02_backend/order_intake_and_fulfillment_mainline_backend_truth_persistence_freeze_addendum.md
  - docs/01_contracts/order_intake_and_fulfillment_mainline_contract_freeze_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_truth_boundary_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《订单承接与履约承接主链 backend implementation dispatch》

## 当前阶段

- 主对象：
  - `订单承接与履约承接主链`
- 子阶段：
  - `backend implementation dispatch authoring`
- 当前只允许处理：
  - `Server` 侧 continuation read corridor 的最小闭合
  - 首轮 `milestone/submit` submit truth entry
  - 首轮 `inspection/submit` submit truth entry 的冻结范围内实现准备
  - `workbench` 的 `activeOrderId / activeMilestoneId` continuation projection
  - upload 三段式与 `evidence / file_asset` 的最小复用
- 当前必须明确：
  - 这份文书只是在 author 后端派工口令
  - 当前仍然不是 `real implementation dispatch issuance`
  - 当前仍不得直接发送给 `后端 Agent`

## 当前唯一动作

- 供后续使用的 `后端 Agent` 执行口令如下。
- 当前口令已 author 完成，但在 `real implementation dispatch issuance` veto 单独解除前不得发送。

```text
你是后端 Agent（仅云端），本轮不是重做整个交易链，而是只实现《订单承接与履约承接主链》在 Server 侧已经冻结好的最小 continuation 范围。

【一、唯一目标】
你这轮只完成 5 件事：
1. 闭合当前已冻结的 continuation read corridor：
   - `GET /server/order/detail`
   - `GET /server/contract/detail`
   - `GET /server/milestone/list`
   - `GET /server/inspection/detail`
2. 落地当前已冻结的首轮 `milestone/submit` truth entry：
   - 只允许沿用 `POST /server/milestones/{milestoneId}/submit`
3. 在不发明新 path family 的前提下，落地 `inspection-bound minimal submit truth`：
   - 不得把它写成 `POST /server/inspection/submit`
   - 如果 concrete route naming gap 成为阻断项，必须 fail-closed 返回 blocker，不得猜
4. 让 `server/exhibition/workbench` 只输出最小 continuation anchor projection：
   - `activeOrderId`
   - `activeMilestoneId`
5. 保持 upload 三段式与 `evidence / file_asset` 复用成立：
   - `objectKey` 继续不是真值

【二、强制阅读】
- docs/00_ssot/order_intake_and_fulfillment_mainline_truth_boundary_freeze_addendum.md
- docs/01_contracts/order_intake_and_fulfillment_mainline_contract_freeze_addendum.md
- docs/02_backend/order_intake_and_fulfillment_mainline_backend_truth_persistence_freeze_addendum.md
- docs/00_ssot/order_intake_and_fulfillment_mainline_bounded_implementation_dispatch_bundle_addendum.md
- docs/01_contracts/openapi.yaml

【三、只允许处理的范围】
- apps/server/src/modules/trading_read_corridor/**
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
- 不得把 `workbench` 写成 truth owner
- 不得把 `inspection/submit` 写成 `POST /server/inspection/submit`
- 不得把 `objectKey` 写成业务真值
- 不得把 `page shell / placeholder / route presence` 当成后端完成证据

【五、必须落实的真义】
1. order / contract / milestone / inspection continuation read
- 只允许承接当前最小字段：
  - `orderId / orderNo / projectId / bidId / state / summary`
  - `contractId / orderId / state / summary`
  - `milestoneId / orderId / sequenceNo / title / amount / state / summary`
  - `inspectionId / milestoneId / state / summary / rectificationCount / recheckCount`
- controlled unavailable / invalid-state / missing-anchor 继续由 `Server` 决定
- 不得把 route presence 写成 runtime 闭环完成

2. milestone submit truth
- 只允许实现最小 request / accepted response 所需 truth：
  - `milestoneId`
  - `submissionNote`
  - `state`
  - `summary`
- 如涉及补充凭证：
  - 只能复用 `evidences + file_assets`
  - 只能复用 `init -> direct upload -> confirm`
  - 不得把 upload schema 反客为主

3. inspection submit truth
- 只允许实现最小 request / accepted response 所需 truth：
  - `inspectionId`
  - `milestoneId`
  - `state`
  - `summary`
- 当前不纳入：
  - `inspection/recheck`
  - `passed / archived` 最终闭环
- 若 concrete server route 未冻结导致无法安全落地：
  - 必须返回 blocker
  - 不得猜 route 名

4. workbench continuation projection
- `workbench.order_chain` 只继续承载：
  - `activeOrderId`
- `workbench.fulfillment_chain` 只继续承载：
  - `activeMilestoneId`
- 不得把 `workbench` 写成：
  - detail owner
  - truth owner
  - 控制台 owner

5. audit / evidence boundary
- 当前必须补齐最小 must-audit 动作：
  - `MilestoneSubmitted`
  - `InspectionSubmitted`
- 若现有 allowed directories 内无法安全补齐审计落点：
  - 返回 blocker
  - 不得偷扩到无关对象

【六、完成标准】
- `trading_read_corridor` 读链在当前冻结字段内可跑
- `milestone/submit` 在当前冻结字段内可跑，且不引入第二状态机
- `inspection/submit` 要么在当前冻结边界内可跑，要么给出 fail-closed blocker
- `exhibition_workbench` 只返回最小 continuation anchor
- upload 三段式未被破坏
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
4. submit truth 结果：
   - `milestone/submit`
   - `inspection/submit`
5. `workbench` continuation anchor 结果
6. upload / evidence 复用结果
7. 审计落点结果
8. 当前剩余阻断项
9. 是否可移交 `BFF Agent`

【八、输出禁令】
- 不要写“应该可以”
- 不要猜 `inspection/submit` route 名
- 不要把 blocker 包装成 success
- 不要扩到 `my_project`
- 不要扩到 rating / dispute / recheck
- 只给真实代码修改与真实 smoke 结果
```
