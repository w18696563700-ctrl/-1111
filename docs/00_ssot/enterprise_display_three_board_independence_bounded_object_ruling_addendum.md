---
owner: Codex 总控
status: frozen
purpose: Freeze the bounded Day-1 maintenance object for enterprise-display three-board independence so the repo has one formal object covering company/factory/supplier entry, case, media, and published-change isolation before any implementation prompt is allowed.
layer: L0 SSOT
freeze_date_local: 2026-04-19
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/enterprise_display_chain_single_source_of_truth_freeze_addendum.md
  - docs/00_ssot/profile_enterprise_display_entry_split_truth_ruling_addendum.md
  - docs/00_ssot/profile_factory_display_entry_published_change_routing_truth_ruling_addendum.md
  - docs/00_ssot/enterprise_display_case_library_and_change_corridor_ruling_addendum.md
  - docs/00_ssot/enterprise_display_published_change_corridor_truth_freeze_addendum.md
  - docs/02_backend/enterprise_display_company_factory_case_media_repair_online_fact_finding_20260419_addendum.md
  - 用户截图与 2026-04-19 隧道取证结果
---

# 《企业展示三板块独立化边界裁决单》

## 1. 裁决目的

- 当前正式重开一个新的 bounded Day-1 object。
- 当前对象只处理：
  - `company / factory / supplier` 三板块独立化
  - profile 入口独立化
  - workbench / case library / case editor 独立化
  - case upload 与 media ownership 独立化
  - published-change same-board 收口
- 当前对象不等于：
  - 新业务扩面
  - `个人/团队展示` 正式落地
  - deploy / rollback / release

## 2. 当前唯一 active bounded object

- 当前唯一 active bounded object 正式锁定为：
  - `enterprise display / three-board independence`
- 当前对象覆盖：
  - `docs/**` 的 Day-1 truth / gate / contracts / backend / BFF / frontend freeze
  - 后续经重新放行后的 `apps/server/src/modules/enterprise_hub/**` 真值修复
  - 后续经重新放行后的 `apps/bff/src/routes/enterprise_hub/**` 与 `apps/bff/src/routes/file/**`
  - 后续经重新放行后的 `apps/mobile/lib/features/profile/**`
  - 后续经重新放行后的 `apps/mobile/lib/features/exhibition/**enterprise_hub**`
  - 对应测试与 tunnel smoke
- 当前对象明确不覆盖：
  - 新 board type
  - 新推荐算法
  - Admin 审核扩面
  - 第二套 published-change corridor
  - 非 `enterprise_hub` 对象扩面

## 3. 当前已确认的问题族

### 3.1 入口已拆但工作台壳层未独立

- 当前 `我的公司展示 / 我的工厂展示 / 我的供应商展示` 已在 profile 列表拆开。
- 但当前仓库与线上行为仍表明：
  - 共享 workbench route identity
  - 共享 case editor route identity
  - workbench 内仍残留 board switcher 心智

### 3.2 case family 仍有共享实现残留

- 当前三板块大部分 listing/profile 已具备 board-scoped truth。
- 但 case library、continue edit、published-change case corridor 仍主要表现为：
  - shared family + `boardType` 分流
  - 不是三条独立 case family

### 3.3 media ownership 尚未锁死

- 当前线上与本地代码共同证明：
  - case cover / case media 仍可能引用异角色或异用途素材
  - supplier public case cover 可落到 `profile/business_license/...`
- 该问题正式定性为：
  - media ownership truth 缺口
  - 不是单纯 projection 文案问题

### 3.4 published-change routing 仍不对称

- 当前 `factory` 已有更明确的 post-submit routing 收口。
- `company / supplier` 尚未形成同等级对称裁决。
- 该问题正式定性为：
  - 三板块入口与 corridor 对称性不足

## 4. 当前阶段拆分裁决

### 4.1 Stage A

- 当前 stage-A 只负责：
  - bounded object ruling
  - docs-only stage gate checklist
  - truth / contract / backend / BFF / frontend freeze 文书
- 当前 stage-A 不允许：
  - 绕过 docs 直接改代码
  - 先修线上数据再反推 truth

### 4.2 Stage B

- 当前 stage-B 只负责：
  - Server 真值修复
  - BFF app-facing contract 收口
  - Flutter route / workbench / case editor 独立化
  - 测试补强
- Stage-B 必须在新的 implementation gate 放行后才允许进入。

### 4.3 Stage C

- 当前 stage-C 只负责：
  - 历史脏数据修复
  - authenticated tunnel smoke
  - bounded rollout judgment

## 5. Allowed Directories

- 当前 stage-A 允许：
  - `docs/00_ssot/**`
  - `docs/01_contracts/**`
  - `docs/02_backend/**`
  - `docs/03_bff/**`
  - `docs/04_frontend/**`
- 当前 stage-A 不允许：
  - `apps/mobile/**`
  - `apps/bff/**`
  - `apps/server/**`
  - 线上云主机写操作

## 6. Anti-revert

- 不得把三板块独立化退回成“一个工作台换三种皮肤”。
- 不得把 case 独立化简化成“只改入口文案”。
- 不得把 media ownership 缺口继续留给 Flutter 或 BFF 兜底。
- 不得把 `factory` 特例当成 `company / supplier` 已完成对称治理。
- 不得借修复之名引入第二套 case 或 published-change 状态机。

## 7. Formal Conclusion

- 当前 enterprise display 已正式进入：
  - `three-board independence`
    bounded Day-1 docs-first object
- 当前下一步必须先完成：
  - docs-only stage gate checklist
  - truth freeze
  - contracts / backend / BFF / frontend freeze bundle
- 在上述文书冻结前：
  - 不允许直接进入实现派工
