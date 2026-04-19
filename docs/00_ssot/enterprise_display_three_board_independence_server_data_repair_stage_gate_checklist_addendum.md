---
owner: Codex 总控
status: frozen
purpose: Freeze the bounded Server data-repair stage gate for enterprise-display three-board independence, deciding the package-level Go/No-Go order for readonly inventory, repair script execution, and verification after backend truth repair completed.
layer: L0 SSOT
freeze_date_local: 2026-04-19
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/enterprise_display_three_board_independence_data_repair_implementation_gate_checklist_addendum.md
  - docs/00_ssot/enterprise_display_three_board_independence_backend_execution_receipt_addendum.md
  - docs/02_backend/enterprise_display_company_factory_case_media_repair_online_fact_finding_20260419_addendum.md
  - apps/server/scripts/enterprise_hub_case_media_repair_readonly_audit.sql
  - apps/server/scripts/enterprise_hub_case_media_repair_template.sql
  - apps/server/scripts/enterprise_hub_case_media_post_release_smoke.sh
  - apps/server/src/modules/enterprise_hub/enterprise-hub-media-truth.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-published-change-support.service.ts
---

# 《enterprise display three-board independence Server data repair stage gate checklist》

## 1. Scope

- 本门禁核查表只服务于：
  - `enterprise display / three-board independence`
  - `Stage C / Server data repair`
- 本门禁核查表只回答：
  - 哪些门禁已通过
  - 哪些门禁未通过
  - 哪些是一票否决
  - 当前 package-level 是否允许进入下一阶段
- 本门禁核查表不等于：
  - deploy pass
  - release pass
  - BFF / Flutter unlock

## 2. Passed Gates

- server-truth prerequisite gate：
  - 通过
  - write-time media ownership、read-side fail-close、live ref sync 已在上一轮闭合，data repair 不再依赖先补新代码路径。
- readonly-audit asset gate：
  - 通过
  - `enterprise_hub_case_media_repair_readonly_audit.sql` 已形成 `Q1-Q7` 的 canonical inventory basis。
- bounded-repair template gate：
  - 通过
  - `enterprise_hub_case_media_repair_template.sql` 已明确默认 `ROLLBACK`，具备 bounded script skeleton。
- post-repair smoke asset gate：
  - 通过
  - `enterprise_hub_case_media_post_release_smoke.sh` 已提供 repair 后的只读验证骨架。
- ownership-hardening gate：
  - 通过
  - 当前 runtime 已禁止新的非法 media ownership 再次流入 live truth，repair 不会一边修一边继续漏。
- bounded-owner gate：
  - 通过
  - 当前对象仍然只属于 `Server / enterprise_hub`，不需要扩到 `BFF / Flutter` 才能解释 repair 成败。

## 3. Failed Gates

- candidate-set freeze completion gate：
  - 未通过
  - 候选集尚未通过 `Package A / inventory` 正式冻结。
- repair-script execution gate：
  - 未通过
  - 真实 SQL commit 仍未放行。
- repair verification completion gate：
  - 未通过
  - `Q2 / Q3 / Q4 / Q6 / Q7` 尚未完成 repair 后复跑。
- deploy / restart / rollback gate：
  - 未通过
- integration gate：
  - 未通过
- `release-prep` / production release gate：
  - 未通过

## 4. Veto Gates

- 若候选集需要靠“猜哪个 board 更像正确值”才能确定归属，直接 veto。
- 若 repair 需要新增 schema、迁移代码路径、补 BFF/Flutter 逻辑才能成立，直接 veto。
- 若 repair script 不是行级、可回滚、可审计，而是无界全量 backfill，直接 veto。
- 若修复了 `enterprise_case` / `file_asset` 却不重建对应 `enterprise_media_asset_ref`，直接 veto。
- 若把 `objectKey`、URL、页面展示结果当成 business truth 反写数据库，直接 veto。
- 若把 `Q5` 的 listing album / factory showcase 问题自动扩大成当前对象主修范围，直接 veto。
  - `Q5` 只允许作为同次盘点中的观察项，除非候选行与当前 case/media 对象直接重叠并经总控追加确认。
- 若把 runtime 已兼容的板块化 case `fileKind`
  - `enterprise_company_case_media`
  - `enterprise_factory_case_media`
  - `enterprise_supplier_case_media`
  自动判成脏数据并强改回 generic `enterprise_case_media`，直接 veto。

## 5. Whether The Next Stage Is Allowed

- 当前 package-level 允许状态固定为：
  - `Go for Package A / readonly inventory execution`
  - `Authored but No-Go for Package B / repair script execution until Package A receipt passes`
  - `Authored but No-Go for Package C / verification execution until Package B receipt passes`
- 当前不允许：
  - 跳过 inventory 直接执行脚本
  - 跳过脚本直接宣布验证通过
  - 越级进入部署或发版

## 6. Stage Go / No-Go Decision

- 当前阶段结论：
  - `Go for Package A / readonly inventory`
  - `No-Go for Package B / repair script execution yet`
  - `No-Go for Package C / verification execution yet`
  - `No-Go for BFF implementation`
  - `No-Go for frontend implementation`
  - `No-Go for deploy / restart / rollback`
  - `No-Go for integration`
  - `No-Go for release-prep`
  - `No-Go for production release`

## 7. Package-Level Meaning

- 当前 `Go` 的真实含义只有：
  - 可以开始用只读方式冻结候选集
  - 可以形成精确 repair plan
- 当前 `Go` 不代表：
  - 现在就可以 `COMMIT`
  - 现在就可以执行所有 repair SQL
  - 现在就可以宣布数据层闭合

## 8. Next Unique Action

- 下一步唯一动作：
  - 执行 `Package A / readonly inventory`
  - 产出 inventory execution receipt

## 9. Formal Conclusion

- 当前 `Server data repair stage gate` 的 formal conclusion 固定为：
  - 只放行 `Package A / inventory`
  - `Package B / script` 与 `Package C / verification` 仍保持 authored-not-executable 状态
