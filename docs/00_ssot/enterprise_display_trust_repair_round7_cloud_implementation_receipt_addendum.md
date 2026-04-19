---
owner: Codex 总控
status: frozen
purpose: Record the bounded cloud implementation receipt for round-7 of enterprise display trust repair after round-6 admission was granted.
layer: L0 SSOT
freeze_date_local: 2026-04-17
round_id: TC-20260417-07
inputs_canonical:
  - docs/00_ssot/enterprise_display_trust_repair_round6_cloud_implementation_admission_judgment_addendum.md
  - docs/02_backend/enterprise_display_trust_repair_round6_backend_truth_scope_addendum.md
  - docs/03_bff/enterprise_display_trust_repair_round6_bff_surface_scope_addendum.md
---

# 《enterprise display trust repair round 7 cloud implementation receipt》

## 1. 现状

- 当前 round-7 已进入受限云端 `BFF / Server` 实施轮。
- 本轮只允许在 cloud git root：
  - `/srv/git/exhibition-infra-monorepo`
  内做最小增量修改。
- 本轮未 author：
  - deploy
  - rollback
  - restart service
  - integration release

## 2. 冻结边界

- 当前 round-7 只处理：
  - `Server` 的 enterprise truth backfill / readiness 判定收口
  - `BFF` 的 `sendPut 400` 错误映射回归
- 当前 round-7 明确不处理：
  - `Logo-only` carrier 解耦
  - founded-time filter
  - 新 contract route
  - live runtime 发布

## 3. 派工对象

- `后端 Agent（仅云端）`
- `BFF Agent（仅云端）`
- `结果校验 Agent`

## 4. 实施结果

- `Server`
  - `enterprise-hub-certification-sync.service.ts`
    - 空白 `listing.name` 现在允许回填 `certification legalName / organization.name`
    - 空白 `listing.provinceCode / cityCode` 现在允许从 `organization` 真值回填
  - `enterprise-hub-workbench.query.service.ts`
    - workbench readiness 现在接受 `code-based registered city truth`
  - `enterprise-hub.presenter.ts`
  - `enterprise-hub-workbench.presenter.ts`
    - 企业名称读面现在允许 fallback 到 `legalNameSnapshot`
- `BFF`
  - `enterprise-hub.service.ts`
    - `sendPut()` 不再把所有 `400` 一刀切误映射成 `ENTERPRISE_LOCATION_WRITE_INVALID`
    - `updateBasic()` 只在 Server 显式返回 `ENTERPRISE_LOCATION_WRITE_INVALID` 时保留该专属 message
- `tests`
  - `apps/server/test/enterprise-hub-workbench-closure.test.cjs`
    - 补齐 location harness，并新增 `code-based registered city truth` 覆盖
  - `apps/server/test/enterprise-hub-certification-sync.test.cjs`
    - 新增 `syncForListing()` 直测，独立证明空白 listing 会从 organization/certification 真值回填 `name / provinceCode / cityCode`
  - `apps/server/test/enterprise-hub-public-read-closure.test.cjs`
    - 补齐 presenter 的 location harness
  - `apps/bff/test/enterprise-hub-update-basic-contact-transport.test.cjs`
    - 新增 `generic 400` 与 `location-invalid 400` 分型回归覆盖

## 5. 运行态证据

- 当前运行态未变更。
- 本轮未执行：
  - deploy
  - rollback
  - service restart
  - live HTTP smoke
- 本轮编译 / 测试只发生在 cloud git root。
- 为避免无锁 `pnpm install` 拉取新版本，本轮临时将：
  - `/srv/git/exhibition-infra-monorepo/apps/server/node_modules`
  - `/srv/git/exhibition-infra-monorepo/apps/bff/node_modules`
  链接到 active runtime 的现成依赖目录，仅用于 build / test verification。

## 6. 文档证据

- round-6 admission 已正式允许 bounded cloud implementation：
  - `docs/00_ssot/enterprise_display_trust_repair_round6_cloud_implementation_admission_judgment_addendum.md`
- backend / BFF scope 已分别冻结：
  - `docs/02_backend/enterprise_display_trust_repair_round6_backend_truth_scope_addendum.md`
  - `docs/03_bff/enterprise_display_trust_repair_round6_bff_surface_scope_addendum.md`

## 7. 风险与 blocker

- 当前仍然存在的 blocker：
  - `Logo-only` 仍被 `createApplication` 的申请人姓名 / 手机号前置门槛卡住
  - 公司名 / 省市真值同步仍未完全关闭，当前只做了空白字段 backfill
  - 文字地址 provider/config 路径还缺 live runtime smoke
- 当前 non-blocking risk：
  - cloud git root 仍是 dirty worktree
  - `._*` AppleDouble 异常文件仍存在

## 8. 下一步

- 下一轮先进入 `结果校验 Agent` 的独立复核结论。
- 若结果校验无新增 blocker，再决定是否继续推进：
  - `syncForListing()` 的直接测试补强
  - `provinceName / cityName` 显示策略收口
  - `Logo-only` 的单独 contract / truth 方案
