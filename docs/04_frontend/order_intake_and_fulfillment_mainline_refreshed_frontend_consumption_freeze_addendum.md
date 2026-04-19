---
owner: Codex 总控
status: active
purpose: >
  Freeze the refreshed Flutter-side consumption, route/page carrier split,
  accepted-feedback boundary, adjacent dispute-page exclusion, and controlled
  state handling for `订单承接与履约承接主链` after the post-cleanup BFF refresh.
layer: L5 Frontend
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_refreshed_truth_boundary_freeze_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_fresh_asset_inventory_refresh_addendum.md
  - docs/01_contracts/order_intake_and_fulfillment_mainline_refreshed_contract_freeze_addendum.md
  - docs/02_backend/order_intake_and_fulfillment_mainline_refreshed_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/order_intake_and_fulfillment_mainline_refreshed_bff_surface_freeze_addendum.md
  - docs/04_frontend/order_intake_and_fulfillment_mainline_frontend_consumption_freeze_addendum.md
  - docs/04_frontend/flutter_screen_map.md
  - docs/01_contracts/openapi.yaml
  - apps/mobile/lib/shell/navigation/app_router.dart
  - apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart
  - apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_contract_validation.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_entry_contract_validation.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_trade_pages.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/order_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/contract_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/milestone_list_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/milestone_submit_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/inspection_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/inspection_submit_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/dispute_open_page.dart
---

# 《订单承接与履约承接主链 refreshed frontend consumption freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `订单承接与履约承接主链`
- 本冻结单只服务于：
  - 当前对象 Flutter 页面消费边界
  - 当前对象 included route / page carrier 与 adjacent excluded page 的区分
  - 当前对象 `loading / content / empty / blocker / failure` 状态边界
  - 当前对象 read-page 最小字段消费
  - 当前对象 shell / handoff page 的最小 accepted-feedback 边界
  - 当前对象 workbench / my-project continuation reuse boundary
- 本冻结单不进入：
  - `apps/mobile/**` 实现
  - 新路由族
  - integration
  - release-prep
  - production release

## 2. Refreshed Frontend Freeze Conclusion

- 本轮 refreshed frontend freeze 不是 `no-op`。
- 本轮只冻结当前对象纳入范围内的最小 Flutter consumption boundary。
- 与旧版
  [order_intake_and_fulfillment_mainline_frontend_consumption_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/04_frontend/order_intake_and_fulfillment_mainline_frontend_consumption_freeze_addendum.md)
  相比，当前必须收正 6 件事：
  1. 当前 route 注册里确实存在：
     - `/exhibition/disputes/open`
     但它只能记为邻接 shell / handoff page，
     不纳入当前对象 included frontend family。
  2. `milestone/submit`
     当前 accepted feedback 只冻结到：
     - `milestoneId`
     不再沿用旧版 `state / summary` 成功回显口径。
  3. `inspection/submit`
     当前仍然是 concrete shell / handoff page，
     但不是 active command family fully closed。
  4. `milestone/list`
     当前页面并不以 `sequenceNo`
     作为本地必备消费字段。
  5. `inspection/detail`
     当前页面并不以
     `rectificationCount / recheckCount`
     作为本地必备消费字段。
  6. `workbench / my-project`
     当前只承担 continuation reuse，
     不能被再写回 detail truth page。
- 本轮不允许借 refreshed frontend freeze 把以下对象重新带回：
  - `order/create`
  - `contract/confirm`
  - `contract/amend`
  - `inspection/recheck`
  - `rating/*`
  - `dispute/*`
  - payment / billing / settlement / tax

## 3. Active Frontend Carrier Freeze

- 当前对象在 Flutter 侧只承认以下 active carrier family：
  - `app_router`
  - `exhibition_routes`
  - `exhibition_consumer_layer`
  - `order_detail_page`
  - `contract_detail_page`
  - `milestone_list_page`
  - `milestone_submit_page`
  - `inspection_detail_page`
  - `inspection_submit_page`
  - `exhibition/workbench`
  - `my/projects`
- 其中：
  - `order / contract / milestone / inspection`
    页面承担当前对象主消费面
  - `workbench`
    只承担 summary + handoff
  - `my-project`
    只承担 private carry reuse

### 3.1 Adjacent But Excluded Page

- `dispute_open_page`
  与 `/exhibition/disputes/open`
  当前确实存在于 Flutter runtime。
- 但当前必须明确：
  - 它是邻接 shell / handoff page
  - 不是当前对象 included frontend family
  - 不是 `dispute` 对象 reopen 许可

## 4. Frontend Truth Boundary

- Flutter 只允许做：
  - consume app-facing projection
  - controlled `loading / content / empty / blocker / failure`
  - controlled accepted / unavailable / invalid-state feedback
  - continuation route handoff
- Flutter 不得做：
  - truth owner
  - 第二状态机
  - 本地 `pass / complete / archived / withdrawable / rateable` 推导
  - 本地 dispute eligibility 推导
  - 本地 inspection final-pass 判定
  - 本地补全上游未给出的业务字段

### 4.1 Runtime-evidence Prohibition

- page shell / route shell / placeholder 不等于 runtime 已接通。
- demo fallback / controlled placeholder 不能被写成主链已通证据。
- route 存在不等于 `BFF / Server` active source 已通。
- accepted feedback 不等于对象 truth 已推进完成。

## 5. Canonical Route / Page Carrier Freeze

- 当前 frontend 只允许冻结以下 included route / page carrier：
  - `/exhibition/orders/detail`
  - `/exhibition/contracts/detail`
  - `/exhibition/milestones`
  - `/exhibition/milestones/submit`
  - `/exhibition/inspections/detail`
  - `/exhibition/inspections/submit`

### 5.1 Adjacent But Excluded Route / Page

- 当前相邻但排除的 route / page 只有：
  - `/exhibition/disputes/open`
- 当前必须明确：
  - 它当前只是邻接 shell / handoff page
  - 不得被偷写成当前对象 included route family

### 5.2 Explicitly Excluded Route / Page

- 当前必须明确禁止把以下 route / page 纳入本轮：
  - `/exhibition/orders/create`
  - `/exhibition/contracts/confirm`
  - `/exhibition/contracts/amend`
  - `/exhibition/inspections/recheck`
  - `/exhibition/ratings/entry`
  - `/exhibition/ratings/submit`
  - `/exhibition/disputes/withdraw`

## 6. `order/detail` Refreshed Frontend Consumption Freeze

- `/exhibition/orders/detail` 当前正式冻结为：
  - 当前对象中的订单只读消费页
- 页面只消费最小 app-facing projection。
- `orderId` 只作为 controlled continuation context。

### 6.1 Minimum Consumption Fields

- 当前最小消费字段至少包括：
  - `orderId`
  - `orderNo`
  - `projectId`
  - `bidId`
  - `state`
  - `summary`
  - `milestones`

### 6.2 Hard Boundary

- 当前不得扩：
  - acceptance workflow
  - dispute detail / history
  - rating detail / history
  - payment / settlement surface

## 7. `contract/detail` Refreshed Frontend Consumption Freeze

- `/exhibition/contracts/detail` 当前正式冻结为：
  - 当前对象中的合同只读消费页
- 页面只消费最小 app-facing projection。

### 7.1 Minimum Consumption Fields

- 当前最小消费字段至少包括：
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

## 8. `milestone/list` Refreshed Frontend Consumption Freeze

- `/exhibition/milestones` 当前正式冻结为：
  - 当前对象中的履约节点只读消费页
- 页面必须区分：
  - real content-state
  - real empty-state
  - blocker / failure state

### 8.1 Minimum Consumption Fields

- 当前最小消费字段至少包括：
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
- 但当前 refreshed frontend freeze 必须写死：
  - 当前页面不以 `sequenceNo`
    作为本地必备消费字段
  - Flutter 不得为了补齐该字段
    自造本地次级排序语义

### 8.3 Hard Boundary

- 当前不得扩：
  - milestone history
  - approval console
  - 第二履约状态机
  - 本地 `milestone.completed` 推导

## 9. `inspection/detail` Refreshed Frontend Consumption Freeze

- `/exhibition/inspections/detail` 当前正式冻结为：
  - 当前对象中的验收只读消费页
- 页面只消费最小 app-facing projection。

### 9.1 Minimum Consumption Fields

- 当前最小消费字段至少包括：
  - `inspectionId`
  - `milestoneId`
  - `state`
  - `summary`

### 9.2 Projection Narrowing Note

- `rectificationCount`
- `recheckCount`
  仍然可以是上游 truth / contract 语义的一部分。
- 但当前 refreshed frontend freeze 必须写死：
  - 当前页面不以这两个字段
    作为本地必备消费字段
  - Flutter 不得为了补齐它们
    自造本地 derived inspection state

### 9.3 Hard Boundary

- 当前不得扩：
  - inspection history
  - governance console
  - 不把 route presence 写成验收闭环完成

## 10. `milestone/submit` Refreshed Frontend Shell / Handoff Freeze

- `/exhibition/milestones/submit` 当前正式冻结为：
  - 当前对象允许纳入的第一个 shell / handoff consumption page
- 页面只承接最小 submit 交互与 accepted 反馈。

### 10.1 Minimum Request Consumption

- 当前最小 request 消费至少包括：
  - `milestoneId`
- `submissionNote`
  只可作为可选邻接输入，
  不得写成 Flutter-owned 必填业务真值。

### 10.2 Minimum Accepted Feedback

- 当前最小 accepted feedback 只包括：
  - `milestoneId`

### 10.3 Upload Reuse Boundary

- 如提及补充凭证，必须写清：
  - 继续复用 upload 三段式
  - 只消费 confirmed file asset handoff
  - 不消费 `objectKey`
  - 不消费 raw URL 作为业务真值

### 10.4 Hard Boundary

- 当前不得在前端本地实现 milestone 完整提交条件计算。
- 当前不得在前端本地推导：
  - `milestone.completed`
  - `order.completed`
- 当前不得把 accepted 结果写成：
  - milestone truth 已推进
  - fulfillment 链已闭环

## 11. `inspection/submit` Refreshed Frontend Shell / Handoff Freeze

- `/exhibition/inspections/submit` 当前正式冻结为：
  - 当前对象允许纳入的第二个 shell / handoff consumption page
- 页面只承接最小 submit 交互与 accepted 反馈。

### 11.1 Minimum Request Consumption

- 当前最小 request 消费至少包括：
  - `inspectionId`

### 11.2 Minimum Accepted Feedback

- 当前最小 accepted feedback 至少包括：
  - `inspectionId`
  - `milestoneId`
  - `state`
  - `summary`

### 11.3 Hard Boundary

- 当前对象不纳入：
  - `inspection/recheck`
- 当前对象不纳入：
  - `passed / archived` 最终闭环
- 当前不允许 Flutter 本地判定验收通过。
- 当前不得把 shell / handoff accepted
  写成 closed fulfillment runtime。

## 12. Adjacent `dispute/open` Frontend Boundary Note

- `/exhibition/disputes/open`
  当前在 repo 中已存在 concrete shell / handoff page。
- 当前页面允许做的只有：
  - consume `orderId`
  - consume optional `reason`
  - consume accepted result summary
  - 展示 controlled boundary explanation

### 12.1 Exclusion Rule

- 当前必须明确：
  - 这是邻接边界记录
  - 不是把 `dispute/open`
    纳入当前对象 refreshed frontend family
  - 不是 `dispute` reopen 前置批准

### 12.2 Hard Boundary

- 当前不得借该页顺带冻结：
  - `dispute/detail`
  - `dispute/list`
  - `dispute/withdraw`
  - rating / aftersales / governance family

## 13. State / Failure / Controlled Feedback Boundary

- Flutter 页面允许出现：
  - `loading`
  - `content`
  - `empty`
  - `blocker`
  - `failure`
  - `controlled unavailable`
  - `invalid-state`
  - `missing-anchor-style continuation failure`
- 这些状态必须基于 app-facing surface 消费，
  不得本地伪造业务完成。

### 13.1 Hard Boundary

- 不得把 `empty-state` 伪装成“已接通成功”。
- 不得把 page shell / placeholder 写成已完成。
- 不得把没有 active route / 没有 active truth module 包装成 happy-path `pass`。
- 不得把 accepted feedback 包装成主链 truth 已推进完成。

## 14. Workbench / My-project / Reuse Boundary

### 14.1 Workbench Reuse Boundary

- `/exhibition/workbench`
  只承担：
  - summary
  - continuation handoff
- 当前只允许它继续暴露：
  - `activeOrderId`
  - `activeMilestoneId`
  - `canOpenOrderDetail`
  - `canOpenContractDetail`
  - `canOpenMilestoneList`
  - `canOpenMilestoneSubmit`
  - `canOpenInspectionDetail`
  - `canOpenInspectionSubmit`
- 当前不得把 workbench 写成：
  - `order/detail` owner
  - `contract/detail` owner
  - `milestone/list` owner
  - `inspection/detail` owner

### 14.2 My-project Reuse Boundary

- `my/projects`
- `my/projects/{projectId}`
  只承担：
  - private carry reuse
  - project-level summary / progress projection
- 当前必须明确：
  - `privateSummary / privateProgress`
    不是当前对象详情页 owner
  - `formalCompletionStatus / evaluationStatus`
    只允许继续按 in-scope truth 结果透出
  - 不得再把 `ratings / disputes`
    反向写成当前对象页面语义依赖

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

### 15.2 Extra Prohibitions

- 不得把 Flutter 页面壳写成 runtime 已通。
- route 存在不等于 `BFF / Server` active source 已通。
- page shell 存在不等于主链已闭环。
- controlled placeholder 不等于真实完成。
- 不得把排除项借“邻接 route / 邻接 page”带回来。

### 15.3 Stage Conclusion

- `Go for refreshed docs-only freeze review conclusion authoring`
- `No-Go for Phase 0 implementation exception unlock`
- `No-Go for implementation dispatch send`
- `No-Go for direct implementation`
- `No-Go for integration`
- `No-Go for release-prep`
- `No-Go for production release`

## 16. Next Unique Action

- 下一轮唯一动作：
  - 输出《订单承接与履约承接主链 refreshed docs-only freeze review conclusion》
