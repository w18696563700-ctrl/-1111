---
owner: Codex 总控
status: active
purpose: Freeze the bounded Server data-repair dispatch bundle for enterprise-display three-board independence so inventory, repair script, and verification execute in a strict package order without reopening cross-layer implementation.
layer: L0 SSOT
freeze_date_local: 2026-04-19
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/enterprise_display_three_board_independence_server_data_repair_stage_gate_checklist_addendum.md
  - docs/00_ssot/enterprise_display_three_board_independence_backend_execution_receipt_addendum.md
  - docs/02_backend/enterprise_display_company_factory_case_media_repair_online_fact_finding_20260419_addendum.md
  - apps/server/scripts/enterprise_hub_case_media_repair_readonly_audit.sql
  - apps/server/scripts/enterprise_hub_case_media_repair_template.sql
  - apps/server/scripts/enterprise_hub_case_media_post_release_smoke.sh
---

# 《enterprise display three-board independence Server data repair dispatch bundle》

## A. 当前轮唯一目标

- 当前轮唯一目标固定为：
  - 识别并修复历史遗留的 case/media truth drift
  - 只处理已被 runtime truth-hardening 收紧后的历史残留
  - 让 `enterprise_case`、`enterprise_change_request.draft_cases`、`file_asset`、`enterprise_media_asset_ref` 四层重新一致

## B. 当前轮明确非目标

- 不改 `apps/bff/**`
- 不改 `apps/mobile/**`
- 不改 `apps/admin/**`
- 不新增 schema
- 不新增 `/api/app/*` path family
- 不新开 board type
- 不引入第二状态机
- 不把 `Q5` 自动升级为当前主修对象
- 不把 generic `enterprise_case_media` 全量强迁成板块化 `fileKind`
- 不做 deploy / restart / rollback / release

## C. 当前轮当前根因与盘点依据

- 当前已确认：
  - runtime truth 已收紧，新的非法媒体绑定不会继续进入 live truth。
  - 线上仍可能存在历史脏行、旧 `draft_cases` 快照、旧 `file_asset.business_id` 指向、旧 ref 漏同步。
- 当前 canonical inventory basis 固定为：
  - `apps/server/scripts/enterprise_hub_case_media_repair_readonly_audit.sql`
  - `Q1`：listing / application / case 总览
  - `Q2`：硬串板块 case
  - `Q3`：已影响公开面的脏 case
  - `Q4`：case 图片真值异常
  - `Q5`：listing album / factory showcase 观察项
  - `Q6`：draft_cases 错板块快照
  - `Q7`：draft_cases 缺少 `caseImageUrlMap`
- 当前额外解释固定为：
  - `Q4` 的旧查询只把 `enterprise_case_media` 当成合法 `file_kind`
  - 但当前 runtime 兼容集合已经扩大到：
    - `enterprise_case_media`
    - `enterprise_company_case_media`
    - `enterprise_factory_case_media`
    - `enterprise_supplier_case_media`
  - 因此 inventory 与 repair 不得把“板块化兼容 fileKind”自动判成脏数据

## D. 当前轮项目拓扑冻结

- 总控只允许写：
  - `docs/00_ssot/**`
- data-repair package 允许写：
  - `apps/server/scripts/**`
  - 如确有必要的最小辅助测试：
    - `apps/server/test/**`
- 当前不得写：
  - `apps/server/src/**`
  - `apps/bff/**`
  - `apps/mobile/**`
  - 任何 deploy / release 配置

## E. 当前轮 package split

### E1. Package A | Readonly inventory

- owner：
  - `Codex 总控 / backend data inventory worker`
- unique goal：
  - 冻结候选集，不做任何写操作
- must do：
  - 跑 `Q1-Q7`
  - 将候选行分类为：
    - live truth drift
    - snapshot drift
    - projection residue
    - out-of-scope observation
  - 明确每条候选行的：
    - target enterprise
    - target board
    - target carrier
    - 是否需要 ref rebuild
- deliverables：
  - inventory execution receipt
  - precise candidate list
- must not do：
  - SQL `UPDATE / DELETE / INSERT`
  - 任何 `COMMIT`

### E2. Package B | Bounded repair script

- owner：
  - `Backend Agent / data repair worker`
- unique goal：
  - 只对 `Package A` 已冻结的候选行做 bounded 修复
- must do：
  - 从 template 复制出 concrete repair script
  - 对每条 repair 指定：
    - `case_id`
    - `change_request_id`
    - `file_asset_id`
    - `enterprise_id`
    - `board_type`
  - 若修复 media truth：
    - 同步重建 `enterprise_media_asset_ref`
- may repair：
  - `enterprise_case.enterprise_id`
  - `enterprise_case.board_type`
  - `enterprise_change_request.draft_cases`
  - `file_asset.business_id`
  - `file_asset.file_kind`
  - 对应 `enterprise_media_asset_ref`
- must not do：
  - 宽表全量 backfill
  - 无 candidate list 的模糊修复
  - 借 API 修改 case ownership
  - 把 generic `enterprise_case_media` 一刀切改成 board-specific `fileKind`
  - 触碰 `apps/server/src/**`

### E3. Package C | Verification

- owner：
  - `Codex 总控 / verification worker`
- unique goal：
  - 证明 repair 后 truth 与 runtime surface 一致
- must do：
  - 重跑 `Q2 / Q3 / Q4 / Q6 / Q7`
  - 必要时复看 `Q1`
  - 跑 targeted server tests
  - 跑 post-repair smoke
- acceptance floor：
  - 对目标企业：
    - `Q2 / Q3 / Q4 / Q6 / Q7 = 0`
  - `enterprise_case`、`draft_cases`、`file_asset`、`enterprise_media_asset_ref` 四层一致
- must not do：
  - 以页面“看起来正常”替代真值核查
  - 以单接口成功替代整组 SQL 复跑

## F. 当前轮执行顺序

1. 先执行 `Package A / inventory`。
2. 只有 inventory receipt 通过后，才允许把 `Package B` 从 authored 状态升到 executable。
3. 只有 repair script receipt 通过后，才允许执行 `Package C / verification`。
4. 只有 verification receipt 通过后，才允许讨论：
  - 是否继续开 `BFF / Flutter`
  - 是否进入 release judgment

## G. 当前轮验收通过标准

- 所有 repair 都有明确候选集来源。
- 所有 repair 都有可回滚脚本。
- repair 后：
  - `Q2 / Q3 / Q4 / Q6 / Q7` 对目标企业返回 `0` 行
  - 公开面与私有链不再 cross-board 泄漏 case/media
  - `caseImageUrlMap` / `showcaseImageUrlMap` 该有的地方仍然存在

## H. 当前轮 Formal Conclusion

- 当前轮唯一合法推进路径固定为：
  - `implementation gate -> data repair gate -> Package A -> Package B -> Package C`
- 在 `Package A` receipt 通过前：
  - 一切真实数据写操作继续 `No-Go`
