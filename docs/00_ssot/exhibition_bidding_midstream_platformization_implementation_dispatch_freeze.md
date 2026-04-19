---
owner: Codex 总控
status: frozen
purpose: Freeze the implementation dispatch order, package split, role boundary, acceptance rule, and parallel runtime hard-gate input for exhibition bidding midstream platformization so later prompt bundles can dispatch bounded execution without reopening scope or mixing roles.
layer: L0 SSOT
freeze_date_local: 2026-04-13
inputs_canonical:
  - docs/00_ssot/exhibition_bidding_midstream_platformization_minimum_closure_freeze.md
  - docs/01_contracts/exhibition_bidding_midstream_platformization_contract_freeze.md
  - docs/02_backend/exhibition_bidding_midstream_platformization_backend_truth_persistence_freeze.md
  - docs/03_bff/exhibition_bidding_midstream_platformization_bff_surface_freeze.md
  - docs/04_frontend/exhibition_bidding_midstream_platformization_frontend_consumption_freeze.md
  - docs/00_ssot/runtime_release_stabilization_execution_checklist_dispatch_freeze.md
  - docs/00_ssot/source_of_truth_map.md
---

# 《展览竞标平台化中段 implementation dispatch freeze》

## 1. 目标

- 本轮只冻结：
  - `展览竞标平台化中段` 的实现派工顺序与角色边界
- 本轮只服务于：
  - 下一轮 prompt bundle dispatch
- 本轮不等于：
  - 实现已开始
  - runtime 已通
  - release-ready

## 2. 当前真相

- 当前 `展览竞标平台化中段` 的 L0-L5 freeze 链已经形成：
  - minimum closure freeze
  - contract freeze
  - backend truth / persistence freeze
  - BFF surface freeze
  - frontend consumption freeze
- 当前对象仍然只承接：
  - `seat`
  - `bid package completeness`
  - `buyer compare` 最小稳定消费面
  - `loser feedback` 最小稳定消费面
- 当前不得误写成：
  - 完整竞标平台已完成
  - payment / deposit 已打开
  - compare console 已完成
  - loser feedback 系统已完成

## 3. 角色边界

### 3.1 总控

- 负责：
  - stage gate judgment
  - package order approval
  - final Go / No-Go
- 不负责：
  - 具体代码实现
  - 角色混岗执行

### 3.2 总控文书冻结 Agent

- 负责：
  - `docs/**` 真相收口
  - dispatch / receipt / verification freeze authoring
  - source-of-truth 索引维护
- 不负责：
  - `apps/**` 实现
  - 代替其他 Agent 执行代码改动

### 3.3 前端 Agent（仅本地）

- 负责：
  - `apps/mobile/**` 本地 Flutter bounded consumption implementation
- 不负责：
  - `apps/server/**`
  - `apps/bff/**`
  - backend truth 改写
  - release-final judgment

### 3.4 后端 Agent（仅云端 / backend truth owner scope）

- 负责：
  - `apps/server/**` bounded implementation
  - `Server` truth owner scope
  - persistence / migration / audit / state transition
- 不负责：
  - `apps/bff/**`
  - `apps/mobile/**`
  - BFF aggregation truth

### 3.5 BFF Agent（仅云端 / app-facing aggregation scope）

- 负责：
  - `apps/bff/**` bounded implementation
  - transport / shaping / normalization / visibility trim
- 不负责：
  - `Server` truth
  - `Flutter` consumption truth
  - 第二状态机

### 3.6 结果校验 Agent

- 负责：
  - 每个 Package 的独立结果复核
  - contract/backend/BFF/frontend 对齐校验
  - 受控 smoke 结果复核
- 不负责：
  - 实现代码
  - final release approval

### 3.7 联调发布 Agent

- 负责：
  - release integration / smoke
  - runtime evidence 汇总
  - active/release/workspace 一致性验证
- 不负责：
  - 改写 docs truth
  - 跳过结果校验直接放行

## 4. Implementation Package Sequence

### 4.1 正式包序

- `Package A`
  - `seat`
  - `bid package completeness`
- `Package B`
  - `buyer compare` 最小稳定消费面
  - `winner decision` 最小稳定消费面
- `Package C`
  - `loser feedback` 最小稳定消费面

### 4.2 顺序理由

- `Package A` 必须先过：
  - compare 与 winner decision 的最小稳定消费面建立在 seat 和 completeness 的 backend/BFF/frontend 一致真相之上
- `Package B` 必须等待 `Package A`：
  - compare 不能先于 seat / completeness 稳定落地
  - winner decision 的最小消费面不能脱离 compare 基础
- `Package C` 必须等待 `Package B`：
  - loser feedback 以 award / loser disposition 派生结果为前提

## 5. Package Ownership Matrix

## 5.1 Package A

### 后端 Agent

- 文件域：
  - `apps/server/src/modules/bid/**`
  - 条件触达：
    - `apps/server/src/modules/project/**`
- 职责：
  - `bid_seats` carrier
  - seat lock / release / timeout truth
  - completeness derived truth
  - audit / migration

### BFF Agent

- 文件域：
  - `apps/bff/src/routes/bid/**`
- 职责：
  - `seat` app-facing transport / shaping
  - completeness projection shaping
  - controlled error mapping

### 前端 Agent

- 文件域：
  - `apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/bid_submit_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/presentation_support/bid_submit_sections_support.dart`
  - `apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart`
  - `apps/mobile/lib/features/exhibition/data/services/exhibition_action_service.dart`
  - `apps/mobile/lib/features/exhibition/data/services/exhibition_contract_mapper.dart`
  - `apps/mobile/lib/features/exhibition/data/services/exhibition_contract_validation.dart`
- 职责：
  - seat CTA gating / rendering
  - completeness section consumption
  - controlled error / state rendering

### 结果校验 Agent

- 独立复核对象：
  - seat lock / release / status
  - completeness projection
  - timeout / released seat surface

### 联调发布 Agent

- 运行态验真对象：
  - `seat` app-facing chain
  - completeness app-facing chain
  - build / health / smoke / evidence

## 5.2 Package B

### 后端 Agent

- 文件域：
  - `apps/server/src/modules/bid/**`
  - `apps/server/src/modules/bid_award/**`
  - 条件触达：
    - `apps/server/src/modules/project/**`
- 职责：
  - buyer compare derived read-model
  - winner decision 最小稳定消费前置
  - award/result 边界对齐

### BFF Agent

- 文件域：
  - `apps/bff/src/routes/bid/**`
  - 条件触达：
    - `apps/bff/src/routes/my_project/**`
- 职责：
  - compare path shaping
  - award-related app-facing transport continuity
  - buyer-side visibility trim

### 前端 Agent

- 文件域：
  - `apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/presentation_support/bid_award_support.dart`
  - `apps/mobile/lib/features/exhibition/presentation/widgets/exhibition_status_messages.dart`
  - `apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart`
  - `apps/mobile/lib/features/exhibition/data/commands/bid_award_command.dart`
- 职责：
  - buyer compare section consumption
  - winner decision 最小稳定消费面
  - compare_not_ready / visibility / CTA gating

### 结果校验 Agent

- 独立复核对象：
  - compare projection
  - winner decision 最小稳定消费面
  - role-based visibility

### 联调发布 Agent

- 运行态验真对象：
  - compare read chain
  - award-to-compare continuity
  - build / health / smoke / evidence

## 5.3 Package C

### 后端 Agent

- 文件域：
  - `apps/server/src/modules/bid_award/**`
  - `apps/server/src/modules/bid/**`
- 职责：
  - loser feedback derived read-model
  - loser disposition exposure boundary
  - result error boundary

### BFF Agent

- 文件域：
  - `apps/bff/src/routes/bid/**`
- 职责：
  - loser feedback path shaping
  - supplier-side visibility trim
  - result error mapping

### 前端 Agent

- 文件域：
  - `apps/mobile/lib/features/exhibition/presentation/pages/bid_submit_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/presentation_support/bid_submit_guard_support.dart`
  - `apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart`
  - `apps/mobile/lib/features/exhibition/data/services/exhibition_load_service.dart`
- 职责：
  - loser feedback result mode consumption
  - feedback_not_available / generic unavailable rendering
  - supplier-only visibility consumption

### 结果校验 Agent

- 独立复核对象：
  - loser feedback projection
  - supplier-only visibility
  - result reason surface

### 联调发布 Agent

- 运行态验真对象：
  - result read chain
  - release/current/runtime evidence
  - smoke evidence completeness

## 6. Stage Gate Sequence

- 每个 Package 的统一顺序固定为：
  1. `backend implementation`
  2. `BFF implementation`
  3. `frontend implementation`
  4. `result verification`
  5. `release integration / smoke`
  6. `total-control Go / No-Go`

### 6.1 并行规则

- `Package A / B / C` 之间不允许并行实现。
- 每个 Package 内：
  - backend 与 BFF 不允许并行实现
  - BFF 与 frontend 不允许并行实现
- 理由：
  - 本对象是 contract-first / backend-truth-first 链条
  - BFF shape 依赖 backend receipt
  - frontend consumption 依赖 BFF receipt

### 6.2 允许的有限并行

- 只允许并行准备：
  - 结果校验用例草拟
  - 联调发布 smoke checklist 草拟
- 前提：
  - 不形成真实实现
  - 不改变 package 顺序

## 7. Runtime Hard-gate Input

- `docs/00_ssot/runtime_release_stabilization_execution_checklist_dispatch_freeze.md`
  是所有 Package 的并行硬门禁输入。
- 这不是建议项。
- 每个 Package 在：
  - implementation
  - verification
  - integration
  - release
  前都必须服从这张 checklist。

## 8. Package Acceptance Criteria

## 8.1 Package A

- 必须满足：
  - contract 对齐
  - backend truth 对齐
  - BFF surface 对齐
  - frontend consumption 对齐
  - `seat + completeness` 受控 smoke 跑通
  - evidence archive 完整

## 8.2 Package B

- 必须满足：
  - compare / winner decision 最小消费面与 freeze 对齐
  - backend derived compare truth 对齐
  - BFF compare shaping / visibility 对齐
  - frontend compare section / CTA / state 对齐
  - 受控 smoke 跑通
  - evidence archive 完整

## 8.3 Package C

- 必须满足：
  - loser feedback derived truth 与 freeze 对齐
  - BFF result path / trim / error mapping 对齐
  - frontend result mode / state / visibility 对齐
  - 受控 smoke 跑通
  - evidence archive 完整

## 9. Blocker Taxonomy

- `backend truth missing`
  - backend carrier / state / audit / migration 未对齐 freeze
- `BFF route or shaping missing`
  - path mapping / trim / shaping / error mapping 未对齐
- `frontend consumption drift`
  - route / state / CTA / visibility 偏离 freeze
- `runtime drift`
  - active / release / workspace / current symlink 不一致
- `migration missing`
  - backend 所需 migration 未落库
- `sample pollution`
  - smoke / regression 样本已污染仍复用
- `provider or external dependency unavailable`
  - 外部依赖导致 smoke 不成立
- `evidence missing`
  - build / health / smoke / runtime / release evidence 缺失

## 10. No-Go 边界

- 不得把 implementation dispatch freeze 写成实现完成
- 不得把 `Package A / B / C` 混成一个大包
- 不得顺手带入支付 / 保证金
- 不得顺手带入复杂评分引擎
- 不得顺手带入完整治理台
- 不得顺手带入合同 / 履约 / 争议 / 信用飞轮
- 不得绕过结果校验直接进联调发布
- 不得绕过 runtime checklist 并行硬门禁

## 11. 下一步唯一动作

- 下一步唯一动作：
  - `输出《展览竞标平台化中段 Package A prompt bundle》`

## 12. 裁决

- `《展览竞标平台化中段 implementation dispatch freeze》是否可入库：是`
