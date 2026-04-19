---
owner: Codex 总控
status: frozen
purpose: Freeze the runtime implementation package ordering for the enterprise display published-change corridor before any implementation dispatch starts.
layer: L0 SSOT
freeze_date_local: 2026-04-12
inputs_canonical:
  - docs/00_ssot/enterprise_display_published_change_corridor_truth_freeze_addendum.md
  - docs/01_contracts/enterprise_display_published_change_corridor_contract_freeze_addendum.md
  - docs/00_ssot/enterprise_display_published_change_corridor_admin_governance_contract_freeze_result_verification_conclusion_addendum.md
  - docs/00_ssot/enterprise_display_published_change_corridor_runtime_implementation_planning_stage_gate_checklist_addendum.md
---

# 《enterprise display published change corridor runtime implementation planning》

## 1. Scope

- 本单只回答：
  - `published change corridor` 的 runtime implementation 应如何拆成可执行 package 顺序
  - 哪些 package 当前允许进入 dispatch authoring
  - 哪些 package 仍然必须保持 `No-Go`
- 本单不是：
  - implementation unlock
  - implementation dispatch send
  - direct implementation
  - integration
  - release-prep
  - production release

## 2. Planning Basis

- 当前 planning 只吸收以下已冻结依据：
  - published-change corridor truth freeze
  - published-change corridor contract freeze
  - admin-governance contract freeze verification pass
  - runtime implementation planning stage gate checklist
- 当前 planning 明确不以以下事项作为实现放行依据：
  - 已有 app-facing path
  - 已有 admin-facing path
  - 已有页面壳或工作台壳
  - “contract 已冻结” 这一事实本身

## 3. Runtime Package Order

当前 runtime package 顺序正式冻结为：

1. `Package A / Server governance truth package`
2. `Package B / Admin review-apply surface package`
3. `Package C / BFF published-corridor surface package`
4. `Package D / Flutter published-change workbench package`

正式裁决：

- 当前 package 顺序不得颠倒。
- 不允许出现：
  - `Flutter / BFF` 先跑
  - `Server / Admin` 后补
- 每个下游 package 的 dispatch authoring 都必须等待上游 package 的结果验收结论通过后才能进入。

## 4. Package A

### 4.1 Name

- `Server governance truth package`

### 4.2 Owner

- `Backend Agent`

### 4.3 允许修改范围

- `apps/server/src/modules/enterprise_hub/**`
- 与 published-change corridor 直接相关的最小 supporting touch

### 4.4 禁止事项

- 不得改 `apps/bff/**`
- 不得改 `apps/mobile/**`
- 不得改 `apps/admin/**`
- 不得把 published change save 直接覆盖 live listing
- 不得把 `approve` 与 `apply` 混成同一状态机动作
- 不得发明第二条 published-edit 治理主链

### 4.5 最低验证要求

- `listing-owned change request` 语义成立
- 同一 listing 同时最多一条活动中的 change request
- `save` 只写 current change carrier，不写 live listing
- `submit`、`review`、`apply` 的状态流转与 frozen contract 一致
- 只有 `apply` 会更新 live listing

## 5. Package B

### 5.1 Name

- `Admin review/apply surface package`

### 5.2 Owner

- `Backend Agent`

### 5.3 允许修改范围

- `apps/admin/**`
- 与 Admin published-change queue / detail / review / apply 直接相关的最小 supporting touch

### 5.4 禁止事项

- 不得回写 `apps/server/**` 治理真相定义
- 不得改 `apps/bff/**`
- 不得改 `apps/mobile/**`
- 不得把 queue/detail surface 做成第二套状态机
- 不得把 `approve` 操作按钮伪装成 `apply`

### 5.5 最低验证要求

- review queue read 已承接 current change requests
- review detail 可同时看到 current change snapshot 与 live snapshot
- `approved / revision_required / rejected` 三种 review 决策可区分
- `apply` 为独立动作且只允许对 approved change 执行

## 6. Package C

### 6.1 Name

- `BFF published-corridor surface package`

### 6.2 Owner

- `Backend Agent`

### 6.3 允许修改范围

- `apps/bff/src/routes/enterprise_hub/**`
- `apps/bff/src/shared/contracts.ts`
- 与 corridor app-facing surface 直接相关的最小 supporting touch

### 6.4 禁止事项

- 不得改 `apps/server/**` 治理主链
- 不得改 `apps/mobile/**`
- 不得自持第二套 published-change 状态机
- 不得本地推导 `approved` 或 `applied`
- 不得让 app-facing save surface 绕过治理真相直接写 live listing

### 6.5 最低验证要求

- `GET /changes/current`
- `PUT /changes/current/basic`
- `PUT /changes/current/profiles/*`
- `POST/PUT/DELETE /changes/current/cases`
- `POST /changes/current/submit`
- `GET /changes/current/status`
  全部与 frozen app-facing contract 对齐
- `revision_required`、`approved`、`applied` 只回显 `Server` 当前真值，不由 `BFF` 本地猜测

## 7. Package D

### 7.1 Name

- `Flutter published-change workbench package`

### 7.2 Owner

- `Frontend Agent`

### 7.3 允许修改范围

- `apps/mobile/lib/features/exhibition/**`
- 与 published-change workbench / status / submit flow 直接相关的最小 supporting touch

### 7.4 禁止事项

- 不得直连 `Server`
- 不得改 `apps/server/**`
- 不得改 `apps/admin/**`
- 不得把 `保存修改` 渲染成“已立即上线”
- 不得把 `approved` 与 `applied` 混成一个用户侧状态

### 7.5 最低验证要求

- 用户侧可进入 published-change workbench
- `save / submit / status / revision_required return` 语义完整
- `liveSnapshot` 与 current change snapshot 有明确区分
- 用户侧不会误解为“改完立即上线”

## 8. Dependency And Veto Gate

当前 package 依赖顺序与 veto gate 固定如下：

- `Package A`
  - 当前 dispatch authoring：`Go`
  - veto：
    - 任何把 save 直接写 live listing 的实现
    - 任何把 `approve` 与 `apply` 混写的实现
- `Package B`
  - 当前 dispatch authoring：`No-Go`
  - 解除条件：
    - `Package A` 结果验收结论通过
  - veto：
    - 如果 `Server governance truth` 未通过验收
    - 如果 Admin 仍试图用 surface 代替治理真相
- `Package C`
  - 当前 dispatch authoring：`No-Go`
  - 解除条件：
    - `Package A` 通过
    - `Package B` 通过
  - veto：
    - 任何 app-facing runtime 早于治理主链
    - 任何 `BFF` 自持第二状态机
- `Package D`
  - 当前 dispatch authoring：`No-Go`
  - 解除条件：
    - `Package C` 通过
  - veto：
    - 任何 Flutter 早于 BFF surface
    - 任何把 change draft 伪装成 live listing truth 的消费层

## 9. Dispatch Entry Judgment

当前 planning 结论正式固定为：

- `runtime implementation planning = PASS`
- `Go for Package A / Server governance truth package dispatch authoring`
- `No-Go for Package B dispatch authoring`
- `No-Go for Package C dispatch authoring`
- `No-Go for Package D dispatch authoring`

正式裁决：

- 当前只允许进入第一包 dispatch。
- 当前不允许继续口头推进后续包。
- 当前不允许把 planning 伪装成 unlock。

## 10. Formal Conclusion

- `published change corridor` 现在已有 formal runtime package 顺序。
- `Server / Admin` 治理主链位于 app-facing runtime 之前，倒挂顺序已被正式禁止。
- 当前下一步唯一动作固定为：
  - `enterprise display published change corridor / Server governance truth package dispatch authoring`
