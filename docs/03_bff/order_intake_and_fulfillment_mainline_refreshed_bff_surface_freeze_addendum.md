---
owner: Codex 总控
status: active
purpose: >
  Freeze the refreshed BFF app-facing transport, read-corridor vs
  shell-handoff split, adjacent dispute boundary, and reuse/normalization
  boundary for `订单承接与履约承接主链` after the post-cleanup backend refresh.
layer: L4 BFF
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_refreshed_truth_boundary_freeze_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_fresh_asset_inventory_refresh_addendum.md
  - docs/01_contracts/order_intake_and_fulfillment_mainline_refreshed_contract_freeze_addendum.md
  - docs/02_backend/order_intake_and_fulfillment_mainline_refreshed_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/order_intake_and_fulfillment_mainline_bff_surface_freeze_addendum.md
  - docs/03_bff/bff_ssot.md
  - docs/03_bff/bff_routes.md
  - docs/01_contracts/openapi.yaml
  - apps/bff/src/routes/routes.module.ts
  - apps/bff/src/routes/trading_read_corridor/app-trading-read-corridor.controller.ts
  - apps/bff/src/routes/trading_read_corridor/trading-read-corridor.service.ts
  - apps/bff/src/routes/trading_read_corridor/trading-read-corridor.read-model.ts
  - apps/bff/src/routes/trading_read_corridor/trading-read-corridor.error.service.ts
  - apps/bff/src/routes/trading_shell_handoff/app-trading-shell-handoff.controller.ts
  - apps/bff/src/routes/trading_shell_handoff/trading-shell-handoff.service.ts
  - apps/bff/src/routes/trading_shell_handoff/trading-shell-handoff.error.service.ts
  - apps/bff/src/routes/exhibition_workbench/exhibition-workbench.service.ts
  - apps/bff/src/routes/my_project/my-project.service.ts
  - apps/bff/src/routes/my_project/my-project.read-model.ts
---

# 《订单承接与履约承接主链 refreshed BFF surface freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `订单承接与履约承接主链`
- 本冻结单只服务于：
  - 当前对象 app-facing transport / shaping boundary
  - 当前对象 read-corridor vs shell-handoff 的 BFF surface 区分
  - 当前对象 server-facing forward binding
  - 当前对象 controlled unavailable / invalid-state / missing-anchor normalization
  - 当前对象 workbench / my-project continuation reuse boundary
  - 当前对象 upload signing / error envelope / route-drift fallback 最小边界
- 本冻结单不进入：
  - `apps/bff/**` 实现扩写
  - frontend 文书
  - integration
  - release-prep
  - production release

## 2. Refreshed BFF Freeze Conclusion

- 本轮 refreshed BFF freeze 不是 `no-op`。
- 本轮只冻结当前对象纳入范围内的最小 BFF app-facing family。
- 与旧版
  [order_intake_and_fulfillment_mainline_bff_surface_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/order_intake_and_fulfillment_mainline_bff_surface_freeze_addendum.md)
  相比，当前必须收正 5 件事：
  1. `BFF` 当前 active source 已正式分成两组 module family：
     - `trading_read_corridor`
     - `trading_shell_handoff`
  2. `milestone/submit`
     当前 accepted body 只冻结到：
     - `milestoneId`
     不再沿用旧版 `state / summary` 口径。
  3. `inspection/submit`
     当前继续是 concrete shell / handoff runtime，
     但仍然不是 active command family fully closed。
  4. `dispute/open`
     当前确实存在于 `BFF` app-facing runtime，
     但只作为邻接 shell / handoff runtime 记录，
     不纳入本对象 included BFF surface family。
  5. 当前 `BFF` read-model 比上游 contract / backend truth 更窄：
     - `milestone/list` 当前不把 `sequenceNo`
       作为 BFF 本地必备 projection
     - `inspection/detail` 当前不把
       `rectificationCount / recheckCount`
       作为 BFF 本地必备 projection
- 本轮不允许借 refreshed BFF freeze 把以下对象重新带回：
  - `order/create`
  - `contract/confirm`
  - `contract/amend`
  - `inspection/recheck`
  - `rating/*`
  - `dispute/*`
  - payment / billing / settlement / tax

## 3. Active BFF Module Family Freeze

- 当前对象在 `BFF` 侧只承认以下 active module family：
  - `exhibition_workbench`
  - `my_project`
  - `trading_read_corridor`
  - `trading_shell_handoff`
- 其中：
  - `trading_read_corridor`
    是当前对象 read-only continuation carrier
  - `trading_shell_handoff`
    是当前对象 shell / handoff carrier
  - `exhibition_workbench`
    只承担 summary + handoff exposure
  - `my_project`
    只承担 private carry reuse

### 3.1 Hard Boundary

- 当前不得把 `BFF` 路由分组重新写回：
  - `order`
  - `contract`
  - `inspection`
  - `rating_dispute`
    的旧抽象主语义
- 当前对象的真实 active source 仍以：
  - `trading_read_corridor`
  - `trading_shell_handoff`
    为准。

## 4. BFF Responsibility Boundary

- `BFF` 只允许做：
  - auth consolidation
  - app-facing transport
  - query / command handoff
  - response shaping
  - controlled unavailable / invalid-state / missing-anchor normalization
  - route-drift fallback normalization
  - continuation anchor projection
  - upload signing reuse
- `BFF` 不得做：
  - truth owner
  - 第二状态机
  - 本地 `pass / complete / archived / withdrawable / rateable` 推导
  - 本地 dispute eligibility 推导
  - 本地 inspection final-pass 判定
  - 本地补全上游未给出的业务字段
- `Server` 仍是唯一 truth owner。
- `workbench` / `my-project` 不是 `BFF` truth owner。

## 5. Canonical App-facing Path Family Freeze

- 当前 BFF surface 只允许冻结以下 included app-facing path family：
  - `GET /api/app/order/detail`
  - `GET /api/app/contract/detail`
  - `GET /api/app/milestone/list`
  - `GET /api/app/inspection/detail`
  - `POST /api/app/milestone/submit`
  - `POST /api/app/inspection/submit`

### 5.1 Included Server-facing Forward Binding

- included app-facing path 当前只允许绑定到：
  - `GET /server/order/detail`
  - `GET /server/contract/detail`
  - `GET /server/milestone/list`
  - `GET /server/inspection/detail`
  - `POST /server/milestone/submit`
  - `POST /server/inspection/submit`
- 当前不得擅自发明新的 server-facing path。

### 5.2 Adjacent But Excluded Runtime

- `POST /api/app/dispute/open`
  当前确实存在于 `BFF` runtime，
  且当前只允许绑定到：
  - `POST /server/dispute/open`
- 但当前必须明确：
  - 这是邻接 shell / handoff runtime
  - 不是当前对象 included BFF surface family

### 5.3 Explicitly Excluded Path Family

- 当前必须明确禁止把以下 path 纳入本轮：
  - `POST /api/app/order/create`
  - `POST /api/app/contract/confirm`
  - `POST /api/app/contract/amend`
  - `POST /api/app/inspection/recheck`
  - `GET /api/app/rating/entry`
  - `POST /api/app/rating/submit`
  - `POST /api/app/dispute/withdraw`

## 6. `order/detail` Refreshed BFF Surface Freeze

- `GET /api/app/order/detail` 当前正式冻结为：
  - 当前对象中的订单只读 app-facing carrier
- `BFF` 只允许：
  - query forward
  - 最小 read-model projection
  - controlled unavailable / invalid-params normalization

### 6.1 Minimum App-facing Projection

- 当前最小 app-facing projection 至少包括：
  - `orderId`
  - `orderNo`
  - `projectId`
  - `bidId`
  - `state`
  - `summary`
  - `milestones`

### 6.2 Hard Boundary

- 当前不得扩成：
  - `order/create` surface
  - dispute history surface
  - rating history surface
  - payment / settlement surface

## 7. `contract/detail` Refreshed BFF Surface Freeze

- `GET /api/app/contract/detail` 当前正式冻结为：
  - 当前对象中的合同只读 app-facing carrier
- `BFF` 只做：
  - query forward
  - 最小 detail shaping

### 7.1 Minimum App-facing Projection

- 当前最小 projection 至少包括：
  - `contractId`
  - `orderId`
  - `state`
  - `summary`

### 7.2 Hard Boundary

- 当前不得扩：
  - `contract/confirm`
  - `contract/amend`
  - 合同历史
  - 条款编辑器
  - 法务审核环

## 8. `milestone/list` Refreshed BFF Surface Freeze

- `GET /api/app/milestone/list` 当前正式冻结为：
  - 当前对象中的履约节点只读 app-facing carrier
- `BFF` 只允许：
  - query forward
  - 最小列表 projection

### 8.1 Minimum App-facing Projection

- 当前最小 projection 至少包括：
  - `items[]`
  - `milestoneId`
  - `orderId`
  - `title`
  - `amount`
  - `state`
  - `summary`

### 8.2 Projection Narrowing Note

- `sequenceNo`
  仍然可以是上游 truth / contract 语义的一部分。
- 但当前 refreshed BFF freeze 必须写死：
  - `BFF` 当前不以 `sequenceNo`
    作为本地必备 read-model requirement
  - `BFF` 不得为了补齐该字段
    自造本地次级映射或第二语义层

### 8.3 Hard Boundary

- 当前不得扩：
  - milestone history
  - approval console
  - 第二履约状态机
  - 本地 `milestone.completed` 推导

## 9. `inspection/detail` Refreshed BFF Surface Freeze

- `GET /api/app/inspection/detail` 当前正式冻结为：
  - 当前对象中的验收只读 app-facing carrier
- `BFF` 只允许：
  - query forward
  - 最小 detail shaping

### 9.1 Minimum App-facing Projection

- 当前最小 projection 至少包括：
  - `inspectionId`
  - `milestoneId`
  - `state`
  - `summary`

### 9.2 Projection Narrowing Note

- `rectificationCount`
- `recheckCount`
  仍然可以是上游 truth / contract 语义的一部分。
- 但当前 refreshed BFF freeze 必须写死：
  - `BFF` 当前不以这两个字段
    作为本地必备 read-model requirement
  - `BFF` 不得为了补齐它们
    自造本地 derived inspection state

### 9.3 Hard Boundary

- 当前不得扩：
  - inspection history
  - governance console
  - 把 route presence 写成验收闭环完成

## 10. `milestone/submit` Refreshed BFF Shell / Handoff Freeze

- `POST /api/app/milestone/submit` 当前正式冻结为：
  - 当前对象允许纳入的第一个 shell / handoff surface
- 当前正式语义是：
  - accepted continuation handoff
  - 不是 milestone truth already advanced

### 10.1 Allowed BFF Role

- `BFF` 只允许做：
  - command forward
  - envelope shaping
  - invalid-state / unavailable normalization

### 10.2 Minimum Request Handoff

- 当前最小 request 至少包括：
  - `milestoneId`
- `submissionNote`
  只可作为可选邻接负载描述，
  不得写成 BFF-owned 必填业务真值。

### 10.3 Minimum Accepted Response

- 当前最小 accepted response 只包括：
  - `milestoneId`

### 10.4 Hard Boundary

- 当前不得：
  - 本地计算 milestone 提交完成条件
  - 本地返回 `state / summary`
    作为 milestone 已推进完成证明
  - 把 shell / handoff position
    写成 active command family 已闭环

## 11. `inspection/submit` Refreshed BFF Shell / Handoff Freeze

- `POST /api/app/inspection/submit` 当前正式冻结为：
  - 当前对象允许纳入的第二个 shell / handoff surface
- 当前正式语义是：
  - accepted continuation handoff
  - 不是 inspection truth already advanced

### 11.1 Allowed BFF Role

- `BFF` 只允许做：
  - command forward
  - envelope shaping
  - invalid-state / unavailable normalization

### 11.2 Minimum Request Handoff

- 当前最小 request 至少包括：
  - `inspectionId`

### 11.3 Minimum Accepted Response

- 当前最小 accepted response 至少包括：
  - `inspectionId`
  - `milestoneId`
  - `state`
  - `summary`

### 11.4 Hard Boundary

- 当前不纳入：
  - `inspection/recheck`
- 当前不允许：
  - Flutter / BFF 本地判定验收通过
  - 把 shell / handoff accepted
    偷换成 closed fulfillment runtime

## 12. Adjacent `dispute/open` BFF Boundary Note

- `POST /api/app/dispute/open`
  当前在 repo 中已存在 concrete BFF shell / handoff runtime。
- 当前 `BFF` 允许做的只有：
  - command forward
  - accepted envelope shaping
  - unavailable / invalid-state normalization
- 当前最小 accepted response 继续只包括：
  - `orderId`
  - `state`
  - `summary`

### 12.1 Exclusion Rule

- 当前必须明确：
  - 这是邻接边界记录
  - 不是把 `dispute/open`
    纳入当前对象 refreshed BFF surface family
  - 不是为 `dispute` 对象 reopen 前置批准

### 12.2 Hard Boundary

- 当前不得借 `dispute/open`
  顺带冻结：
  - `dispute/detail`
  - `dispute/list`
  - `dispute/withdraw`
  - rating / aftersales / governance family

## 13. Workbench / My-project Reuse Boundary

### 13.1 Workbench Reuse Boundary

- `GET /api/app/exhibition/workbench`
  只承担：
  - summary
  - continuation handoff exposure
- workbench 侧只允许复用：
  - `activeOrderId`
  - `activeMilestoneId`
  - `canOpenOrderDetail`
  - `canOpenContractDetail`
  - `canOpenMilestoneList`
  - `canOpenMilestoneSubmit`
  - `canOpenInspectionDetail`
  - `canOpenInspectionSubmit`
- 当前不得把 workbench 写成：
  - order detail owner
  - contract detail owner
  - fulfillment truth owner

### 13.2 My-project Reuse Boundary

- `GET /api/app/my/projects`
- `GET /api/app/my/projects/{projectId}`
  只承担：
  - private carry reuse
  - project-level summary / progress projection
- 当前必须明确：
  - `privateSummary / privateProgress`
    不是当前对象 app-facing contract family owner
  - `formalCompletionStatus / evaluationStatus`
    只允许继续按 in-scope truth 结果透出
  - 不得再把 `ratings / disputes`
    反向写成当前对象 BFF 语义依赖

## 14. Upload / Error Envelope / Route-drift Boundary

### 14.1 Upload Reuse Boundary

- 如 submit shell / handoff 涉及补充凭证，`BFF` 只允许继续复用：
  - `POST /api/app/file/upload/init`
  - direct upload
  - `POST /api/app/file/upload/confirm`
- `BFF` 不得：
  - 把 upload 三段式改写成 submit 业务主合同
  - 透传 `objectKey`
  - 透传 raw URL

### 14.2 Unified Error Envelope Boundary

- read-corridor 当前只允许归一化到：
  - `AUTH_SESSION_INVALID`
  - `AUTH_PERMISSION_INSUFFICIENT`
  - `AUTH_RESOURCE_UNAVAILABLE`
  - `ORDER_DETAIL_INVALID`
  - `CONTRACT_DETAIL_INVALID`
  - `CONTRACT_ENTRY_UNAVAILABLE`
  - `MILESTONE_LIST_INVALID`
  - `INSPECTION_DETAIL_INVALID`
  - `INSPECTION_ENTRY_UNAVAILABLE`
- shell / handoff 当前只允许归一化到：
  - `AUTH_SESSION_INVALID`
  - `AUTH_PERMISSION_INSUFFICIENT`
  - `AUTH_RESOURCE_UNAVAILABLE`
  - `MILESTONE_SUBMIT_INVALID`
  - `MILESTONE_INVALID_STATE`
  - `INSPECTION_SUBMIT_INVALID`
  - `INSPECTION_ENTRY_UNAVAILABLE`
  - `DISPUTE_OPEN_INVALID`
  - `DISPUTE_INVALID_STATE`

### 14.3 Route-drift Fallback Boundary

- 当前 `BFF` 允许把以下 route drift
  归一化为 controlled unavailable：
  - `Cannot GET /server/order/detail`
  - `Cannot GET /server/contract/detail`
  - `Cannot GET /server/milestone/list`
  - `Cannot GET /server/inspection/detail`
  - `Cannot POST /server/milestone/submit`
  - `Cannot POST /server/inspection/submit`
  - `Cannot POST /server/dispute/open`
- 但当前不得：
  - 吞掉 `Server` 核心失败语义
  - 把 route drift 伪装成业务完成
  - 把 controlled unavailable 伪装成功能已上线

## 15. Non-goals / Stage Conclusion

### 15.1 Explicit Non-goals

- `order/create`
- `contract/confirm`
- `contract/amend`
- `inspection/recheck`
- `rating`
- `dispute`
- payment / billing / settlement / tax
- implementation unlock

### 15.2 Compatibility And Reuse Boundary

- 当前 refreshed BFF freeze 只服务于：
  - post-cleanup docs-only chain
  - current active module-family registration
  - current app-facing transport / shaping reality
- 本文书不得被误读成：
  - shell / handoff implementation unlock
  - `dispute/open` 纳入
    当前对象主链
  - `BFF` 已补齐上游全部 read semantics

### 15.3 Stage Conclusion

- `Go for refreshed frontend consumption freeze authoring`
- `No-Go for Phase 0 implementation exception unlock`
- `No-Go for implementation dispatch send`
- `No-Go for direct implementation`
- `No-Go for integration`
- `No-Go for release-prep`
- `No-Go for production release`

## 16. Next Unique Action

- 下一轮唯一动作：
  - 输出《订单承接与履约承接主链 refreshed frontend consumption freeze》
