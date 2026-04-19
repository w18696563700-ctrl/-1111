---
owner: Codex 总控
status: frozen
purpose: Freeze the implementation-dispatch stage gate for `订单承接与履约承接主链`, deciding only whether bounded implementation dispatch bundle authoring may begin while direct implementation, real dispatch issuance, integration, release-prep, and production release remain blocked.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_docs_only_freeze_review_conclusion_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_truth_boundary_freeze_addendum.md
  - docs/01_contracts/order_intake_and_fulfillment_mainline_contract_freeze_addendum.md
  - docs/02_backend/order_intake_and_fulfillment_mainline_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/order_intake_and_fulfillment_mainline_bff_surface_freeze_addendum.md
  - docs/04_frontend/order_intake_and_fulfillment_mainline_frontend_consumption_freeze_addendum.md
---

# 《订单承接与履约承接主链 implementation dispatch stage gate checklist》

## 1. Scope

- 本门禁核查表只服务于：
  - `订单承接与履约承接主链`
  - bounded implementation dispatch bundle authoring
- 本门禁核查表只回答：
  - 哪些门禁已通过
  - 哪些门禁未通过
  - 哪些是一票否决
  - 当前是否允许进入下一阶段
- 本门禁核查表不等于：
  - direct implementation
  - real implementation dispatch issuance
  - integration pass
  - `release-prep` pass
  - production release

## 2. Passed Gates

- 真源连续性门禁：
  - 通过
  - `L0 / L2 / L3 / L4 / L5` 的 docs-only 冻结链已连续存在并已登记到 `source_of_truth_map.md`
- docs-only 复签门禁：
  - 通过
  - 当前对象的 docs-only freeze review 已正式复签为 `通过`，且只放行到 `implementation dispatch stage gate checklist authoring`
- 架构边界门禁：
  - 通过
  - `Flutter App -> BFF -> Server` 单主通道未漂移，`BFF` 仍不是 truth owner，`Server` 仍是唯一 truth owner
- 契约冻结门禁：
  - 通过
  - 当前只冻结：
    - `GET /api/app/order/detail`
    - `GET /api/app/contract/detail`
    - `GET /api/app/milestone/list`
    - `POST /api/app/milestone/submit`
    - `GET /api/app/inspection/detail`
    - `POST /api/app/inspection/submit`
- continuation 起点门禁：
  - 通过
  - 当前对象仍只允许从 `activeOrderId` / `activeMilestoneId` 已存在后的 continuation 起步，不得回写成 `bid -> order/create`
- backend / BFF / frontend 边界门禁：
  - 通过
  - backend truth、BFF surface、frontend consumption 的最小边界都已冻结，且 `workbench / my-project / upload` 的复用角色未漂移
- 上传与证据边界门禁：
  - 通过
  - 文件仍只允许复用 `init -> direct upload -> confirm` 三段式，`objectKey` 仍不是真值
- 阶段控制门禁：
  - 通过
  - 当前阶段目标仍然单一，只允许进入新的 docs authoring，不允许越级进入真实 dispatch 或实现执行

## 3. Failed Gates

- direct implementation gate：
  - 未通过
  - `AGENTS.md` 的 `Phase 0 Guardrail` 仍明确禁止交易流实现
- real implementation dispatch issuance gate：
  - 未通过
  - 当前还没有 `bounded implementation dispatch bundle`
  - 当前还没有 backend / BFF / frontend 的正式 dispatch prompt
- implementation receipt gate：
  - 未通过
  - 当前还没有 backend / BFF / frontend 的真实实现回执
- runtime verification gate：
  - 未通过
  - 当前还没有独立 runtime 结果校验
- integration gate：
  - 未通过
  - 当前还没有联调结论
- `release-prep` gate：
  - 未通过
- production release gate：
  - 未通过

## 4. Veto Gates

- 若把当前 `Go` 解释成 direct implementation，直接 veto
- 若把当前 `Go` 解释成 real implementation dispatch issuance，直接 veto
- 若在 `bounded implementation dispatch bundle` 冻结前就向 backend / BFF / frontend 发出真实执行 prompt，直接 veto
- 若把当前 `Go` 解释成 integration pass，直接 veto
- 若把当前 `Go` 解释成 release-ready，直接 veto
- 若扩到以下任一排除项，直接 veto：
  - `order/create`
  - `contract/confirm`
  - `contract/amend`
  - `inspection/recheck`
  - `rating/*`
  - `dispute/*`
  - payment / billing / settlement / tax
- 若把 `workbench / my-project` 写成 `order / contract / milestone / inspection` detail owner 或 truth owner，直接 veto
- 若把 Flutter page shell / route shell / placeholder 写成 runtime 已通，直接 veto
- 若把 `inspection/submit` 擅自写成 `POST /server/inspection/submit`，直接 veto
- 若新增任何 app-facing path family 或 server-facing path family，直接 veto

## 5. Dispatch Boundary

- 当前若进入 `bounded implementation dispatch bundle authoring`，只允许围绕：
  - backend 最小 continuation read corridor：
    - `order/detail`
    - `contract/detail`
    - `milestone/list`
    - `inspection/detail`
  - backend 最小 write-handoff truth：
    - `milestone/submit`
    - `inspection/submit`
  - BFF 最小 app-facing shaping 与 controlled failure normalization：
    - `order/detail`
    - `contract/detail`
    - `milestone/list`
    - `milestone/submit`
    - `inspection/detail`
    - `inspection/submit`
  - frontend 最小详情页 / 列表页 / 提交页消费：
    - `/exhibition/orders/detail`
    - `/exhibition/contracts/detail`
    - `/exhibition/milestones`
    - `/exhibition/milestones/submit`
    - `/exhibition/inspections/detail`
    - `/exhibition/inspections/submit`
  - `workbench.order_chain / fulfillment_chain` 的 continuation handoff 只允许最小 carrier touch，不允许升格成 truth owner
- 当前 allowed directories 只允许写死为：
  - `apps/server/src/modules/trading_read_corridor/**`
  - `apps/server/src/modules/exhibition_workbench/**`
  - `apps/server/src/modules/upload/**`
  - `apps/bff/src/routes/trading_read_corridor/**`
  - `apps/bff/src/routes/exhibition_workbench/**`
  - `apps/bff/src/routes/file/**`
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

## 6. Stage Go / No-Go

- 当前阶段结论：
  - `Go` for bounded implementation dispatch bundle authoring
  - `No-Go` for direct implementation
  - `No-Go` for real implementation dispatch issuance
  - `No-Go` for integration
  - `No-Go` for `release-prep`
  - `No-Go` for production release

## 7. Current Meaning

- 当前允许含义：
  - 总控现在可以 author 当前对象的 `bounded implementation dispatch bundle`
  - 但还不能把它解释成已经开工
- 当前不允许含义：
  - 不允许跳过 backend-first 顺序
  - 不允许跳过 `bounded implementation dispatch bundle`
  - 不允许把文书完成误写成实现完成
  - 不允许把 `Phase 0 Guardrail` 解释成已被解除

## 8. Next Unique Action

- 下一步唯一动作：
  - 输出《订单承接与履约承接主链 bounded implementation dispatch bundle》
