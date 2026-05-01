---
owner: Codex 总控
status: active
purpose: Freeze the Flutter frontend surface for the factory display workbench homepage, using existing factory workbench data and local module drill-in only.
layer: L5 Frontend
based_on:
  - docs/00_ssot/factory_display_workbench_homepage_truth_freeze_addendum.md
freeze_date_local: 2026-05-01
---

# 《工厂展示工作台首页化 frontend surface freeze》

## 1. Scope

本轮只覆盖：

- `/exhibition/factory-display/workbench`
- `/exhibition/factory-display/cases/editor`
- `/exhibition/factory-display/status`
- factory published-change mode under the existing workbench route
- Flutter 本地页面结构、模块入口、展示摘要、空态和 widget/route 回归

本轮不覆盖：

- BFF / Server / OpenAPI / database / cloud deployment
- factory public detail 真值变更
- analytics truth
- activity feed truth
- review management truth
- bottom navigation route changes

## 2. File Boundary

允许修改：

- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_shell.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_company_homepage.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_company_modules.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_company_status_preview.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_company_support.dart`
- `apps/mobile/test/enterprise_hub_workbench_stage1_relayout_test.dart`
- `apps/mobile/test/enterprise_hub_routes_test.dart`

禁止修改：

- `apps/bff/**`
- `apps/server/**`
- `docs/01_contracts/**`
- database migrations / seeds
- cloud deployment artifacts

## 3. Homepage Structure

工厂展示工作台首页必须按以下结构落地：

1. 顶部工厂身份卡
2. 工厂展示状态卡
3. 真实快捷入口
4. 信息完整度
5. 核心信息概览
6. 最新动态空态
7. 数据看板空态
8. 精选案例
9. 联系人
10. 工厂亮点
11. 下一步建议
12. 当前资料摘要

不得新增独立 workbench bottom tab。
不得新增假全局二级 route。
不得把 `数据看板` 做成假数字或假趋势。

## 4. Display Rules

### 顶部身份卡

- 工厂名称优先使用 factory board profile / controller，缺失时回退基础名称或认证名称。
- Logo / 封面只使用真实已上传图片。
- 标签只使用工艺、核心产品等真实字段。
- 一句话简介来自 `basic.shortIntro`；缺失时显示诚实空态。
- `编辑资料` 打开本地展示标识模块。

### 快捷入口

- `工厂展示`：仅在真实 `enterpriseId` 存在时进入 existing factory public detail route。
- `发布展示变更`：仅在真实 `enterpriseId` 且 existing published-change corridor 可用时启用。
- `预览展示`：application mode 打开本地当前资料预览；published-change mode 继续区分 live 与 current draft。
- `数据看板`：本轮不做快捷入口；如页面展示，只能是 `暂无数据` 空态。

### 信息完整度

- 基于 `readiness` 的展示层派生。
- 必须标明不作为业务真值。
- 不提交、不写回、不影响 Server 审核。

### 核心信息概览

模块入口使用本地 `MaterialPageRoute`，承接原 section：

- 展示标识
- 地址与服务区域
- 工厂照片
- 基础资料
- 联系人
- 案例展示
- 认证与状态

### 真实内容区

- 最新动态：当前无真实动态流，显示 `暂无动态`。
- 数据看板：当前无真实指标，显示 `暂无数据`。
- 精选案例：最多展示 3 个 existing cases。
- 联系人：只展示 primary contact。
- 工厂亮点：只用真实字段派生；无真实字段时显示诚实空态。
- 下一步建议：基于 `readiness` 派生，不作为业务真值。

## 5. Acceptance Criteria

- factory workbench 首屏不再展示旧长表单。
- 首屏可见工厂身份、状态、快捷入口、信息完整度。
- 原编辑字段未删除，能通过模块入口抵达。
- supplier homepage 不回归。
- company homepage 不回归。
- 无假数据、无假动态、无假二级路由。
- bottom action / bottom nav 不遮挡尾部内容。
- 目标 Flutter tests 通过；`flutter analyze` 通过或列明既有非本轮问题。
