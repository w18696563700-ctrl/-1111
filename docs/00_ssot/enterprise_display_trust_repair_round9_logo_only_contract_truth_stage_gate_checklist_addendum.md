---
owner: Codex 总控
status: frozen
purpose: Gate the next bounded object that opens the Logo-only contract/truth scheme for enterprise display trust repair.
layer: L0 SSOT
freeze_date_local: 2026-04-17
round_id: TC-20260417-09
inputs_canonical:
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/enterprise_display_trust_repair_round8_independent_verification_judgment_addendum.md
  - docs/00_ssot/enterprise_display_workbench_v1_truth_freeze_addendum.md
  - docs/01_contracts/enterprise_hub_v1_fields_states_api_contract_addendum.md
  - apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts
  - apps/server/src/modules/enterprise_hub/entities/enterprise-application.entity.ts
  - apps/bff/src/routes/enterprise_hub/enterprise-hub.service.ts
---

# 《enterprise display trust repair round 9 Logo-only contract/truth stage gate checklist》

## 1. 本轮目标

- 正式打开 `Logo-only contract/truth scheme`。
- 只冻结：
  - `Logo-only` 为什么当前仍被申请人姓名/手机号前置门槛卡住
  - 下一轮 contract / backend truth / BFF surface 应如何拆 carrier
  - 哪些动作仍然不得直接实施

## 2. 非目标

- 本轮不直接改 `apps/server` / `apps/bff` / `apps/mobile` 业务代码。
- 本轮不直接放行 deploy / rollback / live runtime 验证。
- 本轮不把 `enterprise_application.applicantName / applicantMobile` 偷改成空值兼容。
- 本轮不把联系人真值偷塞回前端本地假状态。

## 3. Passed Gates

- 真源门禁：
  - 当前 blocker 已有正式独立校验结论，见 round-8 judgment。
- 架构边界门禁：
  - `Server` 仍是唯一业务真值 owner，`BFF` 只做 app-facing shape。
- 契约门禁：
  - 当前已知 contract 与 persistence 约束清楚：
    - `enterprise_application.applicantName`
    - `enterprise_application.applicantMobile`
    - `createApplication`
  - 当前问题不是“字段不存在”，而是 carrier 绑错。
- 阶段控制门禁：
  - 本轮只开 docs-only 的方案冻结，不越级进实施。

## 4. Failed Gates

- 契约门禁：
  - 还没有冻结 `Logo-only` 的正式 shell carrier。
- 状态机门禁：
  - 还没有冻结“listing shell”和“application draft”之间的边界。
- 数据与上传门禁：
  - 还没有冻结 `Logo-only` 首次维护时如何在不造假申请人的前提下拿到 `enterpriseId`。
- 阶段控制门禁：
  - 还没有新一轮 implementation bundle。

## 5. Veto Gates

- 若本轮试图直接进实现：
  - `No-Go`
- 触发 veto 的原因：
  - `enterprise_application` 仍是强制申请人字段 carrier
  - `Logo-only` shell acquisition contract 尚未冻结
  - persistence / audit / submit chain 还未写成单一正式口径

## 6. Go / No-Go

- 对 `docs-only Logo-only scheme freeze`：
  - `Go`
- 对 `cloud implementation / BFF implementation / frontend consumption change`：
  - `No-Go`

## 7. 当前允许进入的下一阶段

- 只允许进入：
  - `Logo-only contract/truth ruling`
- 当前不允许进入：
  - backend implementation
  - BFF implementation
  - frontend consumption update
  - independent verification
  - integration release

## 8. Formal Conclusion

- `Logo-only` 当前可以正式打开一个新的 docs-only bounded object。
- 在 carrier 边界冻结前，不允许把“只传 Logo”继续绑定到 `createApplication`。
