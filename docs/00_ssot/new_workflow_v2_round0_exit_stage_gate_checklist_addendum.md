---
owner: Codex 总控
status: frozen
purpose: Record the Round 0 exit stage gate checklist for New Workflow V2, using the post-signoff asset register as the single active baseline before any Round 1 admission decision.
layer: L0 SSOT
gate_basis:
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/project_asset_register_v1.md
  - docs/00_ssot/round0_inventory_validation_signoff.md
  - docs/00_ssot/round0_inventory_release_integration_agent.md
freeze_date_local: 2026-04-02
---

# 新工作流 V2 Round 0 退出阶段门禁核查表

## Scope

- Current object:
  - `新工作流 V2 / Round 0 exit gate / Round 1 admission review`
- This checklist applies only to:
  - Round 0 盘点闭环后的 active baseline 冻结
  - 《项目资产总台账 V1》与当前 active runtime truth
  - 是否允许进入 `Round 1` 准入审查
- It does not by itself:
  - unlock `apps/mobile` implementation
  - unlock `apps/bff` implementation
  - unlock `apps/server` implementation
  - unlock `apps/admin` implementation
  - unlock migration
  - unlock deployment
  - unlock release-prep
  - unlock release execution

## Gate Basis

- Current gate basis is frozen against:
  - `AGENTS.md`
  - `docs/00_ssot/gate_register_v1.md`
  - `docs/00_ssot/new_workflow_v2_takeover_declaration_round0.md`
  - `docs/00_ssot/team_organization_freeze_round0.md`
  - `docs/00_ssot/project_topology_and_tunnel_rules_round0.md`
  - `docs/00_ssot/zh_incremental_construction_principles_round0.md`
  - `docs/00_ssot/project_asset_register_v1.md`
  - `docs/00_ssot/round0_inventory_validation_signoff.md`
  - `docs/00_ssot/round0_inventory_release_integration_agent.md`
  - `docs/01_contracts/openapi.yaml`

## Passed Gates

- Current workflow-takeover gate:
  - passed
  - 新工作流 V2、六角色边界、Round 0 only-inventory 约束已冻结
- Current topology-and-tunnel gate:
  - passed
  - active host、active tunnel、active validation address 已形成单一口径
- Current frontend-boundary gate:
  - passed
  - Flutter 默认仍走 BFF app-facing canonical path，隐藏楼未被推翻
- Current active-runtime-presence gate:
  - passed
  - `80 -> Nginx -> 3000/3001` 主链存在，主联调链使用 `/srv/releases/**`
- Current independent-signoff gate:
  - passed
  - 结果校验 Agent 已给出 `有条件通过`
- Current asset-register gate:
  - passed
  - 《项目资产总台账 V1》已冻结为单一 active baseline

## Failed Gates

- Current contract-path-alignment gate:
  - failed
  - `/api/admin/*` 对外路径与 canonical `/server/admin/*` 当前不闭环
- Current runtime-repo-consistency gate:
  - failed
  - BFF 本地 `RoutesModule` 与当前 runtime 已挂载面不一致
- Current environment-purity gate:
  - failed
  - `pm2 + /srv/workspaces/** + 3100/3101/18080` 并存
- Current server-truth-completeness gate:
  - failed
  - forum/uploads 真相链当前未在本地或补证中闭环
- Current file-length-governance gate:
  - failed
  - 已发现 handwritten source `>=450`，当前未定位到 formal exemption
- Current Round 1 admission gate:
  - failed
  - veto 阻断项未闭环，不满足发出《Round 1 增量派工单》的条件
- Current implementation gate:
  - failed
- Current migration gate:
  - failed
- Current deployment gate:
  - failed
- Current release-prep gate:
  - failed
- Current release-execution gate:
  - failed

## Veto Gates

- no canonical path drift at active entry
  - 当前失败：`/api/admin/*` vs `/server/admin/*`
- no cloud-only truth drift at active runtime
  - 当前失败：`/api/app/*` 真实 rewrite 未在 repo runtime truth 中同构体现
- no unresolved runtime/repo drift before Round 1 admission
  - 当前失败：BFF 本地挂载面与 runtime 已挂载面漂移
- no mixed environment purity as if it were one active chain
  - 当前失败：release 主链与 pm2 workspace smoke 链并存
- no handwritten source `>=450` without formal exemption
  - 当前失败：多处源码超线且本轮未定位到 exemption

## Gate Table Answer

### Passed gates

- `Gate 2 目录洁癖门禁`
- `Gate 3 架构边界门禁`
- `Gate 6 数据与上传门禁`
- `Gate 10 阶段控制门禁`

### Failed gates

- `Gate 1 真源门禁`
- `Gate 4 契约门禁`
- `Gate 9 云上运行门禁`
- `Gate 11 文件长度与职责门禁`

### Veto gates

- `Gate 4` canonical path drift
- `Gate 9` cloud-only truth drift / environment purity unresolved
- `Gate 11` handwritten source over limit without located formal exemption

### Stage Go / No-Go

- Stage decision:
  - `Go` for freezing active baseline only
  - `Go` for maintaining Round 0 signoff as the current formal truth
  - `Go` for future Round 1 admission re-review only after blocker closure
  - `No-Go` for 《Round 1 增量派工单》
  - `No-Go` for any execution-role development round
  - `No-Go` for migration
  - `No-Go` for deployment
  - `No-Go` for release-prep
  - `No-Go` for release execution

## Current Meaning

- Current allowed meaning:
  - 总控可以把 active topology、active tunnel、runtime/repo drift、veto blockers 固定为单一真相
  - 后续可以围绕 blocker 关闭条件重新发起准入复核
- Current non-allowed meaning:
  - 当前不是 Round 1 放行
  - 当前不是实现放行
  - 当前不是联调实施放行
  - 当前不是迁移、部署或发版放行

## Next Unique Action

- The next single action is:
  - keep every execution role in `No-Go for development`
  - 仅围绕 veto 阻断项关闭条件筹备下一轮准入复核
  - 在新的 blocker-closure 证据成形前，不再发出任何开发口令
