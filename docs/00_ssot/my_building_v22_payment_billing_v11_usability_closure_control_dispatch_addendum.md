---
owner: Codex 总控
status: frozen
purpose: Freeze the `V1.1` usability-closure control judgment and dispatch matrix for `我的楼｜支付与账单状态`, locking bounded read-only positioning, conflict-priority rules, current-organization unavailable interpretation, local mobile-first dispatch scope, and explicit No-Go boundaries while payment-system expansion, auto organization switching, seed repair, BFF/Server escalation by default, integration, release-prep, and closure remain blocked.
layer: L0 SSOT
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/my_building_feature_status_register_v1.md
  - docs/00_ssot/my_building_v22_payment_billing_package_boundary_judgment_addendum.md
  - docs/00_ssot/my_building_v22_payment_billing_bounded_implementation_review_conclusion_addendum.md
  - docs/00_ssot/my_building_full_capability_diagnosis_and_cross_building_prerequisite_audit_addendum.md
  - docs/00_ssot/project_funds_and_risk_integration_boundary_ruling_addendum.md
  - docs/04_frontend/payment_billing_v1_frontend_surface_addendum.md
  - apps/mobile/lib/features/profile/presentation/profile_payment_billing_pages.dart
  - apps/mobile/lib/features/profile/data/profile_payment_billing_consumer_layer.dart
  - apps/mobile/lib/features/profile/presentation/profile_organization_switch_page.dart
  - apps/bff/src/routes/profile/app-profile-read.controller.ts
  - apps/bff/src/routes/profile/profile-payment-billing-status.service.ts
  - apps/server/src/modules/payment_billing/payment-billing.query.service.ts
---

# 《我的楼｜支付与账单状态｜V1.1 可用性收口主线总控冻结与派工单》

## 1. Current Object

- 当前对象：
  - `我的楼｜支付与账单状态`
- 当前阶段：
  - `V1.1 可用性收口主线`
- 当前裁决类型：
  - total-control freeze
  - stage gate checklist
  - dispatch matrix

## 2. Conflict Priority Rule

- 若 authority 文书、代码实现、runtime 现象三者冲突，当前优先级固定为：
  1. positioning / boundary / non-goals 以 authority 文书为准
  2. current availability / current failure posture 以最新 runtime 证据为准
  3. implemented facts / touch points / error carriers 以 repo code 为准
  4. 历史文书仅可作为参考，不得反向覆盖上述 authority
- `本轮不要写代码` 当前解释固定为：
  - total control 的 first response 先冻结判断单与派工矩阵
  - 冻结完成后，允许按本单进入受控 dispatch
- 当前升级到 `BFF / Server` 的条件固定为：
  - 只有在 `docs-only + local mobile/test` 无法在不改协议、不改 truth owner、不补 seed 的前提下收住 `解释层 / 引导 / 测试闭环` 时，才允许精确申请 `BFF / Server` 配合
- 当前完成判定固定为：
  - 默认 current organization 未命中 truth 时，页面解释成立
  - 页面明确提示这不是支付执行失败，也不是系统异常
  - 用户可达组织切换入口，但不发生自动切换
  - 切换到已命中 truth 的组织后，读取恢复 success
  - 新增失败路径测试与恢复路径测试通过

## 3. 当前总控判断单

- current_positioning:
  - `支付与账单状态 = bounded read-only package`
  - 当前只承接：
    - `status`
    - `explanation`
    - `handoff`
    - `dependency`
  - 当前明确不是：
    - payment center
    - billing center
    - settlement center
    - invoice center
    - finance backoffice
    - payment execution runtime
- implementation_status:
  - `bounded package implemented; default current-org usability not yet stable`
  - mobile / BFF / Server 当前实现链已成立
  - 当前缺口不是“没实现”，而是默认 current-org 路径尚未稳定可解释
- runtime_truth:
  - `/api/app/profile/payment-and-billing-status/status|explanation|handoff` 路由链真实存在；无鉴权时返回 `401 AUTH_SESSION_INVALID`
  - 多组织用户默认 current organization 若未命中 payment/billing truth，当前会 fail-closed 为 `404 PAYMENT_STATUS_UNAVAILABLE`
  - 同一用户切换到已铺 truth 的组织后，上述三条路径可恢复 `200`
  - 因此当前 runtime 真相不是“模块断链”，而是 `current organization truth alignment` 偏差
- current_gap:
  - status / explanation / handoff 页当前对 `notFound / PAYMENT_STATUS_UNAVAILABLE` 仍主要落在通用“暂不可用”口径
  - 页面尚未明确表达“当前组织暂无支付与账单状态”
  - 页面尚未明确表达“这不是支付执行失败，也不是系统异常”
  - 页面尚未把“切换组织后再查看”收成最小引导
  - 当前 happy path 已有，但“多组织默认 current-org unavailable -> 切换后恢复 success”尚未形成完整测试闭环
  - `my_building_effective_truth_mother_file_v1.md` 对该 bounded family 的正文吸收仍滞后
- recommended_v11_scope:
  - current-org unavailable 解释层
  - 组织切换最小引导
  - 多组织失败路径与恢复路径测试
  - future integration seam 说明固化
- explicit_non_goals:
  - 不扩 payment execution
  - 不扩 refund / split billing / invoice / tax / settlement / finance-admin
  - 不做 active runtime 救火
  - 不补 seed
  - 不自动切 organization
  - 不把 project 主链支付化

## 4. 阶段门禁核查表

### 4.1 passed gates

- 真源门禁：
  - 通过
  - 当前定位、边界、frontend surface、bounded implementation conclusion 均已冻结在 `docs/**`
- 架构边界门禁：
  - 通过
  - 当前仍保持 `Flutter App -> BFF only`、`BFF` 不持有真相、`Server` 是唯一 truth owner
- 契约门禁：
  - 通过
  - `/api/app/profile/payment-and-billing-status/*` canonical path family 已冻结并已实现
- 状态机门禁：
  - 通过
  - 当前仍是只读姿态包，没有被偷写成 payment execution state machine
- 阶段控制门禁：
  - 通过
  - 当前唯一目标、不做事项、允许目录、authority inputs 均已固定在本单
- 文件长度与职责门禁：
  - 通过
  - 当前轮计划优先落在文书与 local mobile/test，未要求混改跨层真相

### 4.2 failed gates

- V1.1 usability completion gate：
  - 未通过
  - 当前解释层、组织切换引导、失败路径测试仍未闭环
- integration gate：
  - 未通过
  - 当前轮不进入 integration
- release-prep gate：
  - 未通过
  - 当前轮不进入 release-prep
- closure gate：
  - 未通过
  - 当前轮仍处于 usability closure mainline，不是最终 closure

### 4.3 veto gates

- second truth root：
  - 继续 veto
- payment center / billing center / settlement center drift：
  - 继续 veto
- payment execution / funds movement implementation：
  - 继续 veto
- auto organization switching to hide truth drift：
  - 继续 veto
- seed repair dressed as UX fix：
  - 继续 veto
- BFF / Server guessing or expansion without precise blocker：
  - 继续 veto
- project mainline paymentization：
  - 继续 veto

### 4.4 go_or_no_go_for_v11_dispatch

- 当前阶段结论：
  - `Go` for docs-only freeze completion
  - `Go` for local mobile/test dispatch
  - `No-Go` for default `BFF / Server` dispatch
  - `No-Go` for runtime rescue
  - `No-Go` for seed patch
  - `No-Go` for integration
  - `No-Go` for release-prep
  - `No-Go` for closure

## 5. 派工矩阵

- docs_only_actions:
  - 把本单挂入 `source_of_truth_map.md`，作为当前 `V2.2 payment_billing` 在 bounded implementation 之后的最新总控收口 authority
  - 修正 `my_building_feature_status_register_v1.md` 中 `支付与账单状态` 的当前可用性口径，明确 current-org truth alignment 偏差
  - 把 `my_building_effective_truth_mother_file_v1.md` 标记为后续 docs refresh 对象，但本轮不重写母文件正文
- local_mobile_actions:
  - 在 `apps/mobile/lib/features/profile/presentation/profile_payment_billing_pages.dart`
    与 `profile_payment_billing_read_pages.dart` 中，把 `PAYMENT_STATUS_UNAVAILABLE` / `AppPageState.notFound` 的展示从 generic unavailable 收成 explicit unavailable explanation
  - 页面必须明确表达：
    - 当前组织暂无支付与账单状态
    - 这不是支付执行失败
    - 这不是系统异常
    - 若你在其他组织下也有身份，可切换组织后再查看
  - 页面只允许提供显式引导到 `ProfileIdentityRoutes.organizationSwitch`
  - 禁止自动切换组织
  - 最小允许触达文件固定为：
    - `apps/mobile/lib/features/profile/presentation/profile_payment_billing_pages.dart`
    - `apps/mobile/lib/features/profile/presentation/profile_payment_billing_read_pages.dart`
    - `apps/mobile/lib/features/profile/presentation/profile_visible_copy.dart`
    - `apps/mobile/lib/features/profile/data/profile_payment_billing_consumer_layer.dart`
    - `apps/mobile/test/profile_payment_billing_contract_test.dart`
    - `apps/mobile/test/profile_payment_billing_pages_test.dart`
- server_bff_blockers_if_any:
  - 当前无 blocker
  - 现有 app-facing payload 已携带 `404 + errorCode + message`，足够支撑 mobile 做 V1.1 解释层与引导层收口
  - 除非 local mobile/test 在现有 contract 下无法稳定识别 `PAYMENT_STATUS_UNAVAILABLE`，否则不得升级到 `BFF / Server`

## 6. next_unique_action

- next_unique_action:
  - 发出 `Frontend Agent（本地）` 首轮派工包，先做 `支付与账单状态` unavailable explanation + organization switch guidance + tests
- why_this_first:
  - 当前真实缺口在 UI 解释层与测试闭环
  - 现有 protocol 与 truth owner 已足够支撑这轮收口
  - 若先动 `BFF / Server`，会把问题误导成协议缺失或真相缺失
- completion_criteria:
  - `status / explanation / handoff` 三页都能正确解释 unavailable
  - 页面可显式跳转到组织切换页
  - 不发生自动切组织
  - 覆盖默认 current-org unavailable 与切换后恢复 success 的测试

## 7. Formal Conclusion

- 当前正式收口语固定为：
  - `支付与账单状态｜V1.1 可用性收口主线 = 保持 bounded read-only positioning，不扩执行系统，优先收 current-organization 命中偏差、解释层和测试闭环。`
