---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the production-release gate checklist for the exhibition bid-submit
  duplicate-submit residual fix only, deciding whether the bounded
  server-side production rollout may proceed after staging closure has been
  proven.
layer: L0 SSOT
freeze_date_local: 2026-04-15
gate_basis:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/exhibition_bid_submit_full_version_duplicate_submit_500_residual_defect_sheet_addendum.md
  - docs/00_ssot/exhibition_bid_submit_full_version_duplicate_submit_500_residual_fix_closure_receipt_addendum.md
  - docs/02_backend/exhibition_bid_submit_full_version_backend_truth_addendum.md
  - docs/03_bff/exhibition_bid_submit_full_version_bff_surface_addendum.md
---

# 《竞标提交页满分版重复提交 500 production release gate 门禁核查表》

## 1. Scope

- 当前阶段对象：
  - `EXH-BID-FULL-RESIDUAL-001`
  - `production release gate judgment only`
- 当前只允许审核：
  - `apps/server/**` 的 bounded rollout
  - production DB 是否可安全补齐唯一约束
  - production BFF 当前运行面是否已具备 `409` 归一化
  - release-safe smoke target 是否成立
- 当前不开放：
  - `apps/mobile/**`
  - production BFF rebuild
  - whole-repo production release

## 2. Passed Gates

- staging closure gate：
  - 通过
  - 当前已证明 `same organization + same project -> 409`
  - 当前已证明 `second supplier + same project -> 202`
- source isolation gate：
  - 通过
  - local-to-production 最小 diff 只落在：
    - `bid-write.service.ts`
    - `bid.errors.ts`
    - `bid.entity.ts`
    - `migrations.ts`
- production BFF readiness gate：
  - 通过
  - current production BFF source 已具备：
    - `409 -> BID_DUPLICATE_SUBMISSION`
    - app-facing 中文 message rewrite
- production DB safety gate：
  - 通过
  - `server_schema_migration` 尚未登记：
    - `20260415_bid_duplicate_submission_controlled_repair`
  - 当前生产库已核实：
    - `bidder_organization_id null/empty = 0`
    - `duplicate project + bidder pair = 0`
    - `duplicate bid_no = 0`
- release-safe target gate：
  - 通过
  - production 库内已存在 `smoke-*` 数据系
  - 当前允许使用独立 smoke buyer/project 做 bounded write smoke

## 3. Failed Gates

- whole-package promotion gate：
  - fail on purpose
  - staging current 与 production current 差异面过大，禁止整包晋升
- production BFF rebuild gate：
  - fail on purpose
  - 当前没有证据要求重建 BFF

## 4. Veto Gates

- 若把 `/srv/apps/server-staging/current` 或 `/srv/apps/bff-staging/current` 整包提升到 production，直接 veto。
- 若为了关闭该缺陷去动 `apps/mobile/**` 或 production BFF current，直接 veto。
- 若 production write smoke 使用真实业务项目而不是独立 smoke target，直接 veto。
- 若 production journal 在 rollout 后再次出现 `23505` 或 `bids_bid_no_key`，直接 veto。

## 5. Stage Go / No-Go

- 当前结论：
  - `Go for bounded server-only production release`
  - `Go for bounded production smoke on dedicated smoke target`
  - `No-Go for scope expansion`

## 6. Next Unique Action

- 下一步唯一动作：
  - 执行 production server bounded rollout
  - 复核 migration 记账
  - 用独立 smoke target 完成：
    - 首次提交 `202`
    - 第二次提交 `409`
