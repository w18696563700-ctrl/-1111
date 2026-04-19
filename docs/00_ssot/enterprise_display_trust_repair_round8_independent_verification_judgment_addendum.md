---
owner: Codex 总控
status: frozen
purpose: Record the independent verification judgment for round-8 of enterprise display trust repair after the bounded cloud implementation completed.
layer: L0 SSOT
freeze_date_local: 2026-04-17
round_id: TC-20260417-08
inputs_canonical:
  - docs/00_ssot/enterprise_display_trust_repair_round7_cloud_implementation_receipt_addendum.md
  - docs/00_ssot/current_cloud_execution_baseline_freeze_addendum.md
---

# 《enterprise display trust repair round 8 independent verification judgment》

## Findings

- blocker:
  - `Server truth backfill/readiness` 只算 `partial pass`，当前只会回填空白 `listing.name / provinceCode / cityCode`；不会纠正旧值，也不会补 `provinceName / cityName`。
  - `Logo-only` 仍未关闭。`createApplication` 继续强制 `applicantName / applicantMobile`，当前还不能支持“只传 Logo 就拿 enterprise shell”。
- non-blocking risk:
  - location provider/config 只做到代码 + transport 分型，未做 live runtime smoke。
  - public read 还没有 direct test 覆盖 `provinceName / cityName` 的 code-only 显示策略。
  - `apps/server/test/enterprise-hub-certification-sync.test.cjs` 当前仍是 cloud workspace 的未跟踪测试文件，变更集完整性还没收口到已跟踪集合。
- observation:
  - `BFF sendPut 400` 的 `location-invalid` 回归已修掉。
  - workbench readiness 现在接受 `code-based registered city truth`。
  - public read / list query / basic transport 最小回归均通过。

## Runtime Evidence

- 独立核验 workspace：
  - `/srv/git/exhibition-infra-monorepo`
- 独立执行通过：
  - `cd apps/server && pnpm build && node --test test/enterprise-hub-workbench-closure.test.cjs`
  - `cd apps/server && node --test test/enterprise-hub-certification-sync.test.cjs`
  - `cd apps/server && node --test test/enterprise-hub-public-read-closure.test.cjs`
  - `cd apps/bff && pnpm build && node --test test/enterprise-hub-update-basic-contact-transport.test.cjs`
  - `cd apps/bff && node --test test/enterprise-hub-list-query-transport.test.cjs`
- 独立核验未执行：
  - deploy / rollback
  - service restart
  - live HTTP smoke
  - DB query truth verification

## Docs Evidence

- 当前 deploy / rollback 仍未正式放行为 live runtime 动作：
  - `docs/00_ssot/current_cloud_execution_baseline_freeze_addendum.md`
- 当前轮次实施与 scope 已落盘：
  - `docs/00_ssot/enterprise_display_trust_repair_round7_cloud_implementation_receipt_addendum.md`

## Verification Results

- 公司名 / 省市真值同步：
  - `partial pass`
- `BFF 400 location-invalid` 误映射：
  - `pass`
- `syncForListing()` 直写回填写路径：
  - `pass`
- workbench code-based city truth readiness：
  - `pass`
- `Logo-only` 联系人手机号前置门槛：
  - `fail / still blocker`
- location provider/config 端到端关闭：
  - `not verified`

## Verdict

- `部分通过，不可结案。`
- 当前允许结论：
  - 受限云端实施轮完成
  - 最小编译与 targeted regression 通过
- 当前不允许结论：
  - 云端已生效
  - 问题全闭环
  - integration release 可放行
