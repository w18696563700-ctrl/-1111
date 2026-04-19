---
owner: Codex 总控
status: active
purpose: Freeze the bounded BFF implementation dispatch bundle for enterprise-display three-board independence so the current round establishes board-scoped app-facing families and preserves the shared enterprise-hub family only as a compatibility bridge.
layer: L0 SSOT
freeze_date_local: 2026-04-19
inputs_canonical:
  - docs/00_ssot/enterprise_display_three_board_independence_bff_implementation_stage_gate_checklist_addendum.md
  - docs/01_contracts/enterprise_display_three_board_independence_contract_freeze_addendum.md
  - docs/03_bff/enterprise_display_three_board_independence_bff_surface_scope_addendum.md
---

# 《enterprise display three-board independence BFF implementation dispatch bundle》

## A. 当前轮唯一目标

- 当前轮唯一目标固定为：
  - 在 `BFF` 建立三板块 app-facing 独立 family
  - 把共享 `/api/app/exhibition/enterprise-hub/**` 降级成 compatibility bridge
  - 保持 service 聚合逻辑尽量不漂移
  - 不引入第二套 truth 或第二套状态机

## B. 当前轮明确非目标

- 不做 Flutter consumption rewiring
- 不做 Server truth 再改造
- 不做线上数据修复
- 不做 deploy / restart / rollback / release

## C. 当前轮 canonical inputs

- `docs/00_ssot/enterprise_display_three_board_independence_bff_implementation_stage_gate_checklist_addendum.md`
- `docs/01_contracts/enterprise_display_three_board_independence_bff_board_family_contract_concretization_addendum.md`
- `docs/03_bff/enterprise_display_three_board_independence_bff_surface_scope_addendum.md`

## D. 当前轮 allowed write set

- `apps/bff/src/routes/enterprise_hub/**`
- 与上述直接相关的最小 `apps/bff/test/**`
- 当前轮不允许写：
  - `apps/server/**`
  - `apps/mobile/**`
  - deploy / restart / rollback / release

## E. 当前轮 package split

### E1. Package A | board-scoped family package

- owner：
  - `Backend Agent / Codex`
- unique goal：
  - 新增 company / factory / supplier 三套 app-facing board family
  - 独立 family 内不再要求 client 显式传 `boardType`
- allowed write set：
  - `apps/bff/src/routes/enterprise_hub/**`
  - `apps/bff/test/**`
- must do：
  - 固定 canonical base path
  - 在 board-sensitive 动作上注入固定 `boardType`
  - 保留现有 service / published-change 聚合语义
- must not do：
  - 发明第二状态机
  - 改 Server path
  - 改 Flutter path consumption

### E2. Package B | compatibility bridge package

- owner：
  - `Backend Agent / Codex`
- unique goal：
  - 保留共享 `/api/app/exhibition/enterprise-hub/**` 家族
  - 明确它现在只是 compatibility bridge
- must do：
  - 保持旧 shared family 继续可用
  - 不吞掉 `boardType`
  - 不把 bridge 写成 canonical family
- must not do：
  - 删除旧桥接路径
  - 隐藏 board mismatch / ownership mismatch

## F. Concrete family freeze

- 当前轮 concrete canonical family 正式冻结为：
- `/api/app/exhibition/enterprise-hub/company/**`
- `/api/app/exhibition/enterprise-hub/factory/**`
- `/api/app/exhibition/enterprise-hub/supplier/**`
- 共享 compatibility bridge 继续为：
  - `/api/app/exhibition/enterprise-hub/**`
- internal mirror family 同步固定为：
  - `/bff/exhibition/enterprise-hub/company/**`
  - `/bff/exhibition/enterprise-hub/factory/**`
  - `/bff/exhibition/enterprise-hub/supplier/**`

## G. 执行顺序

1. 先补 stage gate 与 dispatch bundle。
2. 先冻结 concrete board family contract。
3. 实施 `Package A / independent family`。
4. 再确认 `Package B / compatibility bridge` 无破坏。
5. 运行 BFF build + targeted tests。
6. 输出 execution receipt。

## H. 当前轮验收标准

- company / factory / supplier 三套 app-facing family 已存在且可调用。
- board-sensitive 动作在独立 family 下不再要求 client 显式传 `boardType`。
- 共享 `/api/app/exhibition/enterprise-hub/**` 继续可用。
- 旧 bridge 不得丢掉 `boardType` contract。
- BFF tests 覆盖：
  - fixed-board route forwarding
  - payload board injection / mismatch rejection
  - compatibility bridge continuity
