---
owner: Codex 总控
status: active
purpose: Record the stage gate result for the Flutter-only factory display workbench homepage implementation.
layer: L0 Gate
based_on:
  - docs/00_ssot/factory_display_workbench_homepage_truth_freeze_addendum.md
  - docs/04_frontend/factory_display_workbench_homepage_frontend_surface_addendum.md
gate_date_local: 2026-05-01
---

# 《工厂展示工作台首页化阶段门禁核查表》

## 1. Scope Result

| 项 | 结果 |
|---|---|
| Flutter 展示层 | Pass |
| BFF | Not touched |
| Server | Not touched |
| OpenAPI / contracts | Not touched |
| Database | Not touched |
| Cloud deployment / restart | Not touched |
| 企业展示真值 | Not changed |

## 2. Completed Items

| 门禁项 | 结果 | 证据 |
|---|---|---|
| 只读核实 factory 入口和真实 route | Pass | factory workbench、public detail、published-change、case editor、status route 均已确认存在 |
| L0 ruling | Pass | `docs/00_ssot/factory_display_workbench_homepage_truth_freeze_addendum.md` |
| L5 frontend surface | Pass | `docs/04_frontend/factory_display_workbench_homepage_frontend_surface_addendum.md` |
| factory 首页骨架 | Pass | factory 进入 compact homepage，不再首屏直出旧长表单 |
| 模块入口化 | Pass | 展示标识、地址与服务区域、工厂照片、基础资料、联系人、案例、认证与状态复用本地模块入口 |
| 最新动态 | Pass | 当前无真实动态流，展示 `暂无动态`，不伪造历史 |
| 数据看板 | Pass | 当前无真实 analytics，展示 `暂无数据`，不伪造数字或趋势 |
| 工厂亮点 | Pass | 仅从真实工艺、厂房面积、设备条目、案例数量派生；无真源则空态 |
| bottom action 遮挡 | Pass | homepage 改为 `Column + Expanded scroll + bottom action`，不再使用覆盖式 Stack |
| supplier 回归 | Pass | supplier homepage 目标测试通过 |
| company 回归 | Pass | company homepage / published-change 目标测试通过 |

## 3. Tests

| 命令 | 结果 |
|---|---|
| `flutter test test/enterprise_hub_workbench_stage1_relayout_test.dart` | Pass, 5/5 |
| `flutter test test/enterprise_hub_routes_test.dart --plain-name "enterprise factory workbench keeps local board-profile draft when remote hydration runs"` | Pass |
| `flutter test test/enterprise_hub_routes_test.dart --plain-name "enterprise factory workbench collapses optional capability section by default"` | Pass |
| `flutter test test/enterprise_hub_routes_test.dart --plain-name "enterprise generic factory workbench route with enterpriseId enters current change carrier before live hydration"` | Pass |
| `flutter test test/enterprise_hub_routes_test.dart --plain-name "enterprise published change basic save uses changes current basic path and keeps copy off live semantics"` | Pass |
| `flutter test /Users/wangweiwei/Desktop/展览装修之家总控/.tmp/agent_reports/factory_display_workbench_homepage/20260501/factory_workbench_homepage_capture_test.dart --update-goldens` | Pass |
| `flutter analyze` | Failed with 41 existing repo issues; no new issue appears in the factory homepage files touched in this stage |

## 4. Screenshots

| 类型 | 路径 |
|---|---|
| 窄屏 | `/Users/wangweiwei/Desktop/展览装修之家总控/.tmp/agent_reports/factory_display_workbench_homepage/20260501/factory_workbench_homepage_narrow.png` |
| 宽屏 | `/Users/wangweiwei/Desktop/展览装修之家总控/.tmp/agent_reports/factory_display_workbench_homepage/20260501/factory_workbench_homepage_wide.png` |

## 5. Veto Check

| veto 项 | 结果 |
|---|---|
| 修改 BFF / Server / OpenAPI / DB | No |
| 新增假数据、假动态、假趋势 | No |
| 新增无真实 route 的全局二级页 | No |
| 把 workbench 当成 public detail | No |
| 删除原编辑字段 | No |
| 破坏 published-change current carrier | No |

## 6. Gate Decision

- failed gates:
  - `flutter analyze` 仍有 41 个既有仓库问题，需要另开清理阶段。
- veto gates:
  - none.
- decision:
  - Go for当前 Flutter-only factory 首页化闭环。
  - 允许进入真实账号 UAT。
  - 不允许把数据看板、动态流、独立二级页、云端接口改造混入本阶段。
