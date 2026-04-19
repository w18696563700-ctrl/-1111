---
owner: Codex 总控
status: active
purpose: Freeze the bounded Flutter implementation dispatch bundle for enterprise-display three-board independence so the current round completes private board-fixed route identity cutover and workbench shell alignment while switching canonical consumption to the BFF board-scoped family.
layer: L0 SSOT
freeze_date_local: 2026-04-19
inputs_canonical:
  - docs/00_ssot/enterprise_display_three_board_independence_flutter_implementation_stage_gate_checklist_addendum.md
  - docs/00_ssot/enterprise_display_three_board_independence_bff_execution_receipt_addendum.md
  - docs/04_frontend/enterprise_display_three_board_independence_frontend_surface_addendum.md
---

# 《enterprise display three-board independence Flutter implementation dispatch bundle》

## A. 当前轮唯一目标

- 当前轮唯一目标固定为：
  - 把 `company / factory / supplier` 私有展示工作台切成三套 fixed-board route family
  - 去掉 in-workbench board switching 主路径
  - 让 private consumer layer 切到 `BFF` board-scoped canonical family
  - 保持 public list / detail family 不漂移

## B. 当前轮明确非目标

- 不做 `Server truth` 再改造
- 不做 `BFF` 再改 path family
- 不做线上数据修复
- 不做 authenticated tunnel smoke
- 不做 deploy / restart / rollback / release
- 不做 `个人/团队展示`

## C. 当前轮 canonical inputs

- `docs/00_ssot/enterprise_display_three_board_independence_flutter_implementation_stage_gate_checklist_addendum.md`
- `docs/00_ssot/enterprise_display_three_board_independence_bff_execution_receipt_addendum.md`
- `docs/04_frontend/enterprise_display_three_board_independence_frontend_surface_addendum.md`

## D. 当前轮 allowed write set

- `apps/mobile/lib/features/exhibition/**`
- `apps/mobile/lib/features/profile/**`
- `apps/mobile/lib/shell/navigation/**`
- 与上述直接相关的最小 `apps/mobile/test/**`
- 当前轮不允许写：
  - `apps/server/**`
  - `apps/bff/**`
  - deploy / restart / rollback / release

## E. 当前轮 package split

### E1. Package A | route identity cutover

- owner：
  - `Frontend Agent / Codex`
- unique goal：
  - 建立三套 fixed-board private workbench / case-editor / status route family
  - 让 profile 三入口与回跳链路不再生成 shared `boardType` query route
- must do：
  - 新增 company / factory / supplier fixed-board route helper
  - router 按 path family 固定 `_boardType`
  - 保留 shared legacy route 仅作 compatibility alias
- must not do：
  - 漂移 public list / detail route family
  - 删除 legacy shared route 兼容入口

### E2. Package B | workbench shell and board-copy alignment

- owner：
  - `Frontend Agent / Codex`
- unique goal：
  - 收掉 shared workbench shell 的 board switcher
  - 让 private consumer canonical path 切到 board-scoped family
  - 让 company / factory / supplier 的 published-change entry 对称
- must do：
  - 去掉 in-workbench board switching 主路径
  - 切换 `workbench / enterprises / recommendations / ensure-shell / applications / createCase / changes/current` 到 board-scoped canonical family
  - 保持 `public-cases / applicationId / caseId / location/resolve / formal-info` 的最小共享 carrier
- must not do：
  - 在页面层到处手写字符串拼接 `company / factory / supplier`
  - 为补 consumer path 而新增第二套页面状态机

## F. Concrete Flutter cutover freeze

- 当前轮 private fixed-board route family 正式冻结为：
  - `/exhibition/company-display/workbench`
  - `/exhibition/factory-display/workbench`
  - `/exhibition/supplier-display/workbench`
  - `/exhibition/company-display/cases/editor`
  - `/exhibition/factory-display/cases/editor`
  - `/exhibition/supplier-display/cases/editor`
  - `/exhibition/company-display/status`
  - `/exhibition/factory-display/status`
  - `/exhibition/supplier-display/status`
- shared legacy route family 继续保留为 compatibility alias：
  - `/exhibition/enterprise/apply`
  - `/exhibition/enterprise/cases/editor`
  - `/exhibition/enterprise/application-status`
- canonical app-facing consumption family 正式冻结为：
  - `/api/app/exhibition/enterprise-hub/company/**`
  - `/api/app/exhibition/enterprise-hub/factory/**`
  - `/api/app/exhibition/enterprise-hub/supplier/**`

## G. 执行顺序

1. 先补 stage gate 与 dispatch bundle。
2. 实施 `Package A / route identity cutover`。
3. 实施 `Package B / workbench shell and board-copy alignment`。
4. 运行 Flutter analyze / targeted tests。
5. 输出 execution receipt。

## H. 当前轮验收标准

- company / factory / supplier 三入口都进入各自 fixed-board private family。
- workbench 页面不再暴露 `SegmentedButton` board switcher 作为正式主路径。
- company / factory / supplier published-change entry 逻辑对称。
- private canonical request 已切到 board-scoped `BFF` family，且不再把 `boardType / applyBoardType` 塞进固定板块 canonical request。
- shared legacy route 仍可兼容打开正确页面。
