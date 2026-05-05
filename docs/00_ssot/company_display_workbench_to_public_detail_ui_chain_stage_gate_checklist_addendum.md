---
owner: Codex 总控
status: active
purpose: Record the stage gate checklist for the Flutter-only company display workbench to public detail UI refinement.
layer: L0 Stage Gate
based_on:
  - docs/00_ssot/company_display_workbench_to_public_detail_ui_chain_truth_freeze_addendum.md
  - docs/04_frontend/company_display_workbench_to_public_detail_ui_chain_frontend_surface_addendum.md
freeze_date_local: 2026-05-05
---

# 《公司展示工作台到公司详情页展示链路 UI 精修 stage gate checklist》

## 1. Gate 0 Read-Only Scan

| Item | Result |
|---|---|
| 公司展示工作台文件已定位 | Pass |
| 公司详情页文件已定位 | Pass |
| 首页推荐卡文件已定位 | Pass |
| Workbench 字段来源已核实 | Pass |
| Public detail 字段来源已核实 | Pass |
| Published-change live / current change / preview 边界已核实 | Pass |
| 相关测试文件已定位 | Pass |

## 2. Gate 1 Truth And Surface Freeze

| Item | Result |
|---|---|
| 本轮只限 Flutter 展示层 | Pass |
| 不修改 BFF / Server / OpenAPI / DB / cloud | Pass |
| 不新增假字段、假数据、假路由 | Pass |
| 不改变 company listing/detail/workbench/published-change 真值关系 | Pass |
| 首页推荐公司卡去 badge + 整卡点击已冻结 | Pass |
| 工作台不冒充 public detail | Pass |
| 详情页只消费 public live detail | Pass |
| 完整度为展示层派生 | Pass |

## 3. Gate 2 Implementation Allowlist

允许进入：

- Flutter company recommendation card UI adjustment.
- Flutter company workbench homepage section ordering and visual refinement.
- Flutter company detail public display relayout.
- Targeted widget test updates.

禁止进入：

- BFF / Server / OpenAPI / generated contract changes.
- Cloud release, service restart, Nginx reload, database write.
- New dashboard, activity feed, review, certification, payment, or publish capability.

## 4. Gate 3 Verification Plan

Required local verification:

- `cd apps/mobile && flutter analyze <changed Flutter files and target tests>`
- `cd apps/mobile && flutter test test/enterprise_hub_routes_test.dart`
- `cd apps/mobile && flutter test test/enterprise_hub_workbench_stage1_relayout_test.dart`
- `cd apps/mobile && flutter test test/enterprise_hub_trust_repair_stage1_test.dart`
- `cd apps/mobile && flutter test test/exhibition_home_test.dart`

Visual verification:

- 公司首页推荐卡截图。
- 公司展示工作台截图。
- 公司详情页截图。
- 窄屏截图。
- Computer Use 前必须先通知用户热启动并登录。

## 5. Current Decision

Gate result: `GO for Flutter-only implementation`.

No-Go retained:

- No BFF.
- No Server.
- No contracts.
- No database.
- No cloud deployment.
- No fake data.
