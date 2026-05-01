---
owner: Codex 总控
status: active
purpose: Submit the stage gate checklist for company display workbench homepage implementation, allowing only Flutter presentation work after SSOT and frontend surface freeze.
layer: L0 SSOT
based_on:
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/company_display_workbench_homepage_truth_freeze_addendum.md
  - docs/04_frontend/company_display_workbench_homepage_frontend_surface_addendum.md
freeze_date_local: 2026-05-01
---

# 《公司展示工作台首页化阶段门禁核查表》

## 1. Scope

- 当前对象：
  - `company display workbench homepage`
  - `factory workbench regression protection only`
- 当前门禁只服务于：
  - SSOT freeze
  - frontend surface freeze
  - Flutter-only implementation
  - local Flutter verification
- 当前门禁不代表：
  - BFF / Server implementation
  - contracts / OpenAPI changes
  - database changes
  - cloud deployment
  - release-prep

## 2. Passed Gates

- 真源门禁：
  - 已冻结公司展示工作台首页化 truth。
  - 已冻结 Flutter frontend surface。
  - 已明确 `Server` 仍为 enterprise display truth owner。
- 架构边界门禁：
  - 本轮只允许 Flutter 展示层变化。
  - 不改 BFF、Server、OpenAPI、database、cloud。
  - 不新增全局 route，不改 bottom nav。
- 契约门禁：
  - 本轮不新增字段、不改字段语义。
  - 只消费现有 `EnterpriseHubWorkbenchData`、`readiness`、`latestApplication`、published-change status、`cases`、`certification`。
  - 信息完整度仅为展示层派生。
- 前端体验门禁：
  - 长页内容折叠进模块入口。
  - 数据看板和最新动态无真实数据时不展示。
  - 地图只承接现有位置真值，不伪装完整地图能力。
- 阶段控制门禁：
  - 当前允许进入第 2 天 Flutter 实现。
  - 当前不允许进入云端发布。

## 3. Failed Gates

- BFF implementation gate：
  - failed，本轮无 BFF 实施授权。
- Server implementation gate：
  - failed，本轮无 Server 实施授权。
- contracts / OpenAPI gate：
  - failed，本轮无合同变更授权。
- cloud runtime gate：
  - failed，本轮无云端联调或部署授权。

## 4. Veto Gates

- 若修改 `apps/bff/**`，直接 `No-Go`。
- 若修改 `apps/server/**`，直接 `No-Go`。
- 若修改 `docs/01_contracts/**` 或 `openapi.yaml`，直接 `No-Go`。
- 若展示假数据看板、假动态、假地图接通状态，直接 `No-Go`。
- 若把 workbench 预览写成线上 public detail，直接 `No-Go`。
- 若削弱 published-change corridor，直接 `No-Go`。
- 若修改 bottom nav route，直接 `No-Go`。

## 5. Next Day Decision

- whether the next day is allowed:
  - `Allowed`
- 当前允许进入：
  - 第 2 天 Flutter 实现公司展示工作台首页最小闭环。
- 当前不允许进入：
  - BFF / Server / contracts / cloud work。

## 6. Verification Receipt

- `flutter test test/enterprise_hub_workbench_stage1_relayout_test.dart`
  - `PASS`
  - 覆盖 company 首页、模块入口、published-change corridor，并确认 factory 原有直接编辑面不被动改坏。
- `flutter test test/enterprise_hub_routes_test.dart`
  - `PASS`
  - 覆盖 57 项 enterprise route / published-change / location 回归。
- `flutter analyze`
  - `PASS`
  - 本轮 company 首页化文件未新增 analyze issue。

## 7. UAT / Screenshot Receipt

- 本轮未修改 BFF / Server / OpenAPI / DB / cloud。
- 已使用 Computer Use 检查当前运行的 `mobile` desktop app；未执行云端写入。
- 已用本地 fake workbench payload 生成视觉截图：
  - `/Users/wangweiwei/Desktop/展览装修之家总控/.tmp/agent_reports/company_display_workbench_homepage/20260501/company_workbench_homepage_wide.png`
  - `/Users/wangweiwei/Desktop/展览装修之家总控/.tmp/agent_reports/company_display_workbench_homepage/20260501/company_workbench_homepage_narrow.png`
- 截图不代表云端账号数据，只用于前端结构和窄屏表现验证。

## 8. Final Gate Decision

- passed:
  - L0 / L5 冻结完成。
  - company 首页化代码闭合。
  - factory 原有工作台回归通过。
  - supplier 首页回归通过。
  - 无 BFF / Server / contracts / DB / cloud 变更。
  - 无假数据看板、无假动态、无假全局二级路由。
- failed:
  - none for current Flutter-only scope。
- veto:
  - none for Flutter code delivery。
- next stage allowed:
  - `Allowed for company workbench homepage completed`
  - `Not allowed for cloud deployment based only on this local run`
