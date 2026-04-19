---
owner: Codex 总控
status: frozen
purpose: Freeze the bounded implementation dispatch bundle for `订单承接与履约承接主链` so execution authoring stays inside the already-frozen truth, contract, backend, BFF, and frontend chain without issuing any real implementation prompt yet.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_docs_only_freeze_review_conclusion_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_implementation_dispatch_stage_gate_checklist_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_truth_boundary_freeze_addendum.md
  - docs/01_contracts/order_intake_and_fulfillment_mainline_contract_freeze_addendum.md
  - docs/02_backend/order_intake_and_fulfillment_mainline_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/order_intake_and_fulfillment_mainline_bff_surface_freeze_addendum.md
  - docs/04_frontend/order_intake_and_fulfillment_mainline_frontend_consumption_freeze_addendum.md
---

# 《订单承接与履约承接主链 bounded implementation dispatch bundle》

## 1. Scope

- 本派工包只适用于：
  - `订单承接与履约承接主链`
- 本派工包只冻结：
  - 当前实现轮的唯一目标
  - 当前允许的增量范围
  - 当前执行角色与顺序
  - 当前 retained veto 与非目标
- 本派工包不代表：
  - implementation execution 已开始
  - backend / BFF / frontend 真实 dispatch prompt 已发出
  - integration 通过
  - `release-prep` 通过
  - production release

## 2. Round Unique Goal

- 当前实现轮唯一目标是：
  - 只把“订单 continuation read corridor + 履约 continuation read corridor + 首轮 `milestone/submit` 与 `inspection/submit` handoff + workbench continuation carrier”做成有界可跑实现
- 当前主链仅包括：
  - `workbench.order_chain` 只承担 `activeOrderId` continuation handoff
  - `workbench.fulfillment_chain` 只承担 `activeMilestoneId` continuation handoff
  - `order/detail` 的最小只读 continuation
  - `contract/detail` 的最小只读 continuation
  - `milestone/list` 的最小只读 continuation
  - `milestone/submit` 的首轮提交 handoff
  - `inspection/detail` 的最小只读 continuation
  - `inspection/submit` 的首轮提交 handoff
  - upload 三段式与 `evidence / file_asset` 的最小复用
- 当前轮不允许：
  - 回退到 `bid -> order/create`
  - 扩到 `contract/confirm`
  - 扩到 `contract/amend`
  - 扩到 `inspection/recheck`
  - 扩到 `rating/*`
  - 扩到 `dispute/*`
  - 扩到 payment / billing / settlement / tax
  - 扩到 `my-project` 详情 owner 改造

## 3. Included Scope

### 3.1 Backend Included Scope

- `apps/server` 当前只允许实现：
  - `trading_read_corridor` 内对以下最小 continuation read truth 的闭合：
    - `order/detail`
    - `contract/detail`
    - `milestone/list`
    - `inspection/detail`
  - 首轮 `milestone/submit` 的最小 submit truth entry
  - 首轮 `inspection/submit` 的最小 submit truth entry
  - `exhibition_workbench` 对 `activeOrderId / activeMilestoneId` 的最小 continuation projection
  - `upload` 对 `evidence / file_asset` 的三段式复用，不改变 `objectKey` 非真值原则
- `apps/server` 当前不允许实现：
  - `order/create`
  - `contract/confirm`
  - `contract/amend`
  - `inspection/recheck`
  - `rating / dispute`
  - 第二状态机
  - 新 path family
  - 把 `inspection/submit` 擅自发明成 `POST /server/inspection/submit`

### 3.2 BFF Included Scope

- `apps/bff` 当前只允许实现：
  - `trading_read_corridor` 的最小 app-facing shaping：
    - `order/detail`
    - `contract/detail`
    - `milestone/list`
    - `inspection/detail`
  - `milestone/submit` 与 `inspection/submit` 的最小 command forward 与 controlled failure normalization
  - `exhibition_workbench` 对 `order_chain / fulfillment_chain` 的最小 summary / handoff shaping
  - `file` route family 对 upload 三段式的既有复用承接
- `apps/bff` 当前不允许实现：
  - 第二套业务真义
  - 第二套状态机
  - 新 app-facing path
  - 把 `workbench / my-project` 写成 truth owner
  - 本地推导 `pass / complete / archive-ready / rating-eligible / dispute-eligible`

### 3.3 Frontend Included Scope

- `apps/mobile` 当前只允许实现：
  - `/exhibition/orders/detail` 的最小只读消费
  - `/exhibition/contracts/detail` 的最小只读消费
  - `/exhibition/milestones` 的最小列表消费
  - `/exhibition/milestones/submit` 的最小 submit 消费
  - `/exhibition/inspections/detail` 的最小只读消费
  - `/exhibition/inspections/submit` 的最小 submit 消费
  - `workbench` 的最小 continuation handoff 承接
- `apps/mobile` 当前不允许实现：
  - `my_project` 详情 owner 改造
  - `contract_confirm_page`
  - `contract_amend_page`
  - `inspection_recheck_page`
  - `order_create_command`
  - 全站 UI 重做
  - 直连 `Server`
  - 把 page shell / placeholder / route presence 写成 runtime 已通

## 4. Execution Environment Boundary

- 前端只在本地执行：
  - `apps/mobile`
- `BFF` 只在云端执行：
  - `apps/bff`
- backend 只在云端执行：
  - `apps/server`
- 当前 bundle 只冻结 dispatch 边界：
  - 不冻结 runtime 通过
  - 不冻结联调通过
  - 不冻结发布通过

## 5. Allowed Directories

- backend dispatch 后续只允许触达：
  - `apps/server/src/modules/trading_read_corridor/**`
  - `apps/server/src/modules/exhibition_workbench/**`
  - `apps/server/src/modules/upload/**`
- BFF dispatch 后续只允许触达：
  - `apps/bff/src/routes/trading_read_corridor/**`
  - `apps/bff/src/routes/exhibition_workbench/**`
  - `apps/bff/src/routes/file/**`
- frontend dispatch 后续只允许触达：
  - `apps/mobile/lib/features/exhibition/presentation/pages/order_detail_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/contract_detail_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/milestone_list_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/milestone_submit_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/inspection_detail_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/inspection_submit_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model.dart`
  - `apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model_sections.dart`
  - `apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_source.dart`
  - `apps/mobile/lib/features/exhibition/data/commands/milestone_submit_command.dart`
  - `apps/mobile/lib/features/exhibition/data/commands/inspection_submit_command.dart`
  - `apps/mobile/lib/features/exhibition/**` 中与上述页面和命令直接相关的最小 consumer / supporting touch
- 当前不得放开：
  - `apps/server/src/modules/my_project/**`
  - `apps/bff/src/routes/my_project/**`
  - `apps/mobile/lib/features/exhibition/presentation/pages/my_project_*`
  - `apps/mobile/lib/features/exhibition/presentation/pages/contract_confirm_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/contract_amend_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/inspection_recheck_page.dart`
  - `apps/mobile/lib/features/exhibition/data/commands/order_create_command.dart`
  - `apps/mobile/lib/features/exhibition/data/commands/contract_confirm_command.dart`
  - `apps/mobile/lib/features/exhibition/data/commands/contract_amend_command.dart`
  - `apps/mobile/lib/features/exhibition/data/commands/inspection_recheck_command.dart`

## 6. Execution Order

1. `后端 Agent`
   - 先补齐最小 continuation read truth、首轮 submit truth entry、workbench continuation anchor projection、upload evidence reuse
2. `BFF Agent`
   - 再补齐最小 app-facing shaping、command forward、controlled failure normalization、workbench handoff shaping
3. `前端 Agent`
   - 再补齐详情页 / 列表页 / 提交页 bounded consumption closure
4. `结果校验 Agent`
   - 独立复核：
     - workbench continuation handoff
     - `order/detail`
     - `contract/detail`
     - `milestone/list`
     - `milestone/submit`
     - `inspection/detail`
     - `inspection/submit`
5. `联调发布 Agent`
   - 仅在前四步都通过后，重新给出当前对象的 integration judgment

## 7. Mandatory Receipt Rule

- 当前实现轮继续强制遵守：
  - backend / BFF / frontend 三份回执缺任一项，不启动结果校验
- 含义保持不变：
  - 后端 / BFF 回执允许先落云端
  - 前端回执先落本仓库 `docs/**`
- 当前仍不允许：
  - 用 workbench 页面壳替代真实回执
  - 用 page shell / placeholder 替代真实回执
  - 用 route presence 替代真实回执

## 8. Explicit Non-goals

- 不做 `order/create`
- 不做 `contract/confirm`
- 不做 `contract/amend`
- 不做 `inspection/recheck`
- 不做 `rating/*`
- 不做 `dispute/*`
- 不做 payment / billing / settlement / tax
- 不做 `my-project` 新详情 owner
- 不做 `workbench` 真值 owner 化
- 不做新 path family
- 不做第二状态机
- 不做 `objectKey` 真值化

## 9. Formal Conclusion

- 当前正式结论如下：
  - `订单承接与履约承接主链 = 当前可进入 backend implementation dispatch authoring`
  - `direct implementation / real implementation dispatch issuance / integration / release-prep / production release = 仍然 No-Go`

## 10. Next Unique Action

- 下一步唯一动作：
  - 先向 `后端 Agent` 发出《订单承接与履约承接主链 backend implementation dispatch》口令
