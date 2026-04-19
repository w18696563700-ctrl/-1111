---
owner: Codex 总控
status: frozen
purpose: >
  Assess whether `BidAward bridge` has reached package-level implementation
  unlock readiness. This document is docs-only assessment only and does not
  grant implementation unlock, Phase 0 exception unlock, backend real dispatch
  issuance, BFF dispatch, frontend dispatch, integration, or release
  permission.
layer: L0 SSOT
freeze_date_local: 2026-04-12
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/domain_model.md
  - docs/00_ssot/lifecycle_state_machine.md
  - docs/00_ssot/project_visibility_and_trade_state_map_freeze_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_maintenance_only_follow_up_judgment_addendum.md
  - docs/00_ssot/bid_award_order_conversion_contract_seed_bridge_blueprint_freeze_addendum.md
  - docs/00_ssot/bid_award_bridge_implementation_stage_gate_checklist_addendum.md
  - docs/00_ssot/bid_award_bridge_bounded_implementation_dispatch_bundle_addendum.md
  - docs/00_ssot/bid_award_bridge_backend_implementation_dispatch_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/00_ssot/forum_implementation_unlock_addendum.md
---

# 《BidAward bridge package-level implementation unlock 评估与总控裁决》

## 1. 当前对象

- 当前对象仅限：
  - `BidAward bridge`
  - `package-level implementation unlock assessment`
- 本文书不是：
  - implementation unlock grant
  - Phase 0 implementation exception unlock grant
  - backend real dispatch issuance
  - `BFF implementation dispatch`
  - frontend implementation dispatch
  - integration / `release-prep` / production release

## 2. 当前依据

- 当前 assessment 只吸收以下 docs 链：
  - bridge blueprint freeze
  - implementation stage gate checklist
  - bounded implementation dispatch bundle
  - backend implementation dispatch addendum
- 当前必须明确：
  - 当前已有 authoring basis
  - 但 authoring basis 不自动等于 implementation unlock

## 3. 本轮先补硬的 3 个点

### 3.1 Authoritative path 单选收口

- 当前唯一 authoritative external frozen path 只允许是：
  - `POST /api/app/bid/award`
  - `GET /api/app/bid/result?projectId={projectId}`
- 当前 backend dispatch 中出现的：
  - `POST /server/bid/award`
  - `GET /server/bid/result?projectId={projectId}`
  只允许解释为：
  - `Server` 内部实现 / smoke / backend-focused transport path
  - 不是第二套对外冻结 path
  - 不是 contracts / BFF / frontend 的双轨真源
- 当前正式裁决：
  - 对外唯一冻结口径 = `/api/app/*`
  - backend 内部实现可使用 `/server/*`
  - 后续所有 contracts / BFF / frontend authoring 不得把 `/server/*` 回写成第二套 app-facing 真源

### 3.2 首轮最小写集再收紧

#### 3.2.1 首轮必改

- `docs/01_contracts/openapi.yaml`
- `packages/contracts/src/generated/app-api.types.ts`
- `apps/server/src/modules/bid/**`
- `apps/server/src/modules/project/**`
- `apps/server/src/modules/bid_award/**` 新增最小桥接模块
- `apps/server/test/*award*.test.cjs`

#### 3.2.2 条件触达

- `apps/server/src/app.module.ts`
  - 仅当新增 `BidAwardModule` 且需要正式注册时允许触达
- `apps/server/src/modules/organization/current-actor-eligibility.service.ts`
  - 仅当现有 `buyer` 资格判断无法安全承接 `award` 权限边界时允许触达
- `apps/server/src/modules/audit/**`
  - 仅当现有 append-only audit 无法安全承接 `BidAwarded / loser disposition / conversion attempt` 时允许触达
- `apps/server/src/modules/my_project/**`
  - 仅当 bridge 成功后 buyer 私域投影无法自然承接 `awarded / converted_to_order` fallout 时允许触达
- `apps/server/src/modules/exhibition_workbench/**`
  - 仅当 bridge 成功后 `project_chain / order_chain` 无法自然承接 fallout 时允许触达

#### 3.2.3 本轮禁止触达

- `apps/server/src/modules/trading_read_corridor/**`
- `apps/server/src/modules/trading_shell_handoff/**`
- `apps/server/src/modules/rating/**`
- `apps/server/src/modules/upload/**`
- `apps/server/src/modules/enterprise_hub/**`
- `apps/server/src/modules/payment_billing/**`
- `apps/server/src/modules/forum/**`
- 任何 `BFF` 与 frontend 目录
- 任何 `/api/app/order/create` 相关重新接回

### 3.3 测试分层收死

#### 3.3.1 P0 必过桥接主链测试

- `BidAward` 创建成功
- loser disposition 同事务落库
- `POST /server/bid/award` 成功
- `GET /server/bid/result` 中标 / 落选最小结果可读
- duplicate award fail-close
- concurrent award 单胜
- `BidAward -> Order -> Contract seed -> Project.state`
  原子闭合
- 任一步失败整体回滚，不留脏数据

#### 3.3.2 P1 非回退烟雾测试

- buyer 侧 `my-project` fallout refresh 不回退
- buyer 侧 `workbench.project_chain / order_chain` fallout refresh 不回退
- `bid submit` 不回退
- `contract confirm / amend` invalid-state smoke 不回退
- `inspection recheck` invalid-state smoke 不回退
- `dispute withdraw` invalid-state smoke 不回退

- 当前正式裁决：
  - `P0 bridge mainline` 与 `P1 non-regression smoke` 不得混层
  - 未完成 `P0` 时，不得拿 `P1` 结果替代 bridge 主链通过

## 4. 已通过门禁

- docs chain completeness：
  - 通过
  - bridge blueprint、stage gate、dispatch bundle、backend dispatch authoring 已形成连续文书链。
- bridge object uniqueness：
  - 通过
  - `BidAward` 仍是唯一合法桥接对象。
- no-second-truth gate：
  - 通过
  - `Server` 仍是唯一 truth owner，`BFF` 与 Flutter 仍非 truth owner。
- path-authority gate：
  - 通过
  - 对外唯一 authoritative path 已收口到 `/api/app/*`。
- write-set discipline gate：
  - 通过
  - backend 首轮写集已按 `必改 / 条件触达 / 禁止触达` 收死。
- test-layer discipline gate：
  - 通过
  - `P0 bridge mainline` 与 `P1 non-regression smoke` 已分层冻结。

## 5. 当前未通过门禁

- root guardrail veto：
  - 未通过
  - `AGENTS.md` 仍明确：
    - `No trading flow implementation`
- package-level implementation exception basis：
  - 未通过
  - 当前 `BidAward bridge` 还没有自己的 `Phase 0 implementation exception assessment / unlock` 链。
- backend real dispatch basis：
  - 未通过
  - backend dispatch 已 author，但仍不得发送。
- `BFF / frontend dispatch basis`：
  - 未通过
- implementation receipt gate：
  - 未通过
- runtime verification gate：
  - 未通过
- integration gate：
  - 未通过
- `release-prep` gate：
  - 未通过
- production release gate：
  - 未通过

## 6. 一票否决项

- `No trading flow implementation`
- forum 之外没有自动例外
- docs-only assessment 不得偷换成 implementation unlock
- authored backend dispatch 不得偷换成 sendable backend dispatch
- `/api/app/*` 与 `/server/*` 不得并列成双轨外部真源
- `Order.state = active` 不得被偷换成“合同已确认完成”

## 7. 当前裁决

- `BidAward bridge docs chain = 已形成`
- `BidAward bridge package-level implementation unlock = No-Go`
- `backend real dispatch issuance = No-Go`
- `BFF implementation dispatch = No-Go`
- `frontend implementation dispatch = No-Go`
- `integration = No-Go`
- `release-prep = No-Go`
- `production release = No-Go`

## 8. 当前结论的含义

- 当前允许的是：
  - 继续进入 `Phase 0 implementation exception assessment` authoring
- 当前不允许的是：
  - 任何 `apps/server` 真实实现
  - 任何 backend real dispatch send
  - 把 backend dispatch authoring 解释成 unlock

## 9. 当前最小通过条件

- 若未来要把当前对象从 `No-Go` 转为 `Go`，至少需要新增并通过：
  1. `BidAward bridge Phase 0 implementation exception assessment`
  2. `BidAward bridge Phase 0 implementation exception independent review`
  3. `BidAward bridge Phase 0 implementation exception review conclusion`
  4. `BidAward bridge Phase 0 implementation exception unlock` 或同等级 formal grant
  5. 之后才有资格重新判断 `backend real dispatch issuance`

## 10. 下一步唯一动作

- 下一步唯一动作：
  - 输出《BidAward bridge Phase 0 implementation exception assessment》

## 11. Formal Conclusion

- 当前正式结论如下：
  - 本文只完成 `BidAward bridge` 的 `package-level implementation unlock assessment`
  - 本轮要求的 3 个补硬项已在 assessment 内冻结
  - 当前正式裁决仍是：
    - `No-Go for package-level implementation unlock`
    - `No-Go for backend real dispatch issuance`
