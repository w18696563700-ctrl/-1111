---
owner: Codex 总控
status: active
purpose: Freeze the Flutter frontend surface for the company display workbench homepage, using only existing workbench and published-change data while preserving public detail separation.
layer: L4 Frontend
based_on:
  - docs/00_ssot/company_display_workbench_homepage_truth_freeze_addendum.md
  - docs/00_ssot/company_display_workbench_homepage_stage_gate_checklist_addendum.md
  - docs/04_frontend/enterprise_display_workbench_stage1_relayout_frontend_surface_addendum.md
freeze_date_local: 2026-05-01
---

# 《公司展示工作台首页化 frontend surface freeze》

## 1. Scope

- 当前冻结只覆盖：
  - `/exhibition/company-display/workbench`
  - `/exhibition/company-display/cases/editor`
  - `/exhibition/company-display/status`
  - company published-change mode under the existing workbench route
  - factory workbench regression protection only; no homepage branch in this stage
  - Flutter 本地页面结构、模块入口、展示摘要和本地验证
- 当前冻结不覆盖：
  - BFF / Server / OpenAPI / database / cloud deployment
  - public company detail business rule changes
  - analytics truth
  - activity feed truth
  - review management truth
  - bottom navigation changes

## 2. File Boundary

允许修改：

- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_shell.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_company_homepage.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_*`
- `apps/mobile/test/enterprise_hub_workbench_stage1_relayout_test.dart`
- `apps/mobile/test/enterprise_hub_routes_test.dart`

禁止修改：

- `apps/bff/**`
- `apps/server/**`
- `docs/01_contracts/**`
- database migrations / seeds
- cloud deployment artifacts

## 3. Homepage Structure

公司展示工作台首页必须按以下最小结构落地：

1. 顶部公司身份卡
2. 公司展示状态卡
3. 真实快捷入口
4. 信息完整度
5. 核心信息概览
6. 公开展示摘要

不得新增独立工作台 bottom tab。
不得把示意图里的 `数据看板` 当作真实能力展示；无真实指标时本轮不展示。
不得展示假动态；无真实动态流时本轮不展示。

## 4. Display Rules

### 顶部身份卡

- 展示公司名称；缺失时再回退认证/基础名称。
- 展示 Logo 或真实空态，不伪造图片。
- 展示 company board profile 中已有标签。
- 展示 `basic.shortIntro`；缺失时只给诚实空态。
- 展示当前状态 badge。
- `编辑资料` 进入本地核心模块或展示标识模块。

### 展示状态卡

- 展示 `readiness`、`latestApplication`、published-change status 的摘要。
- 展示最多 2 条阻断项。
- 查看状态入口必须使用现有状态 route 或本地状态模块。
- 不派生第二套状态机。

### 快捷入口

- `公司展示`：仅在 `enterpriseId` 存在时进入 existing public company detail route。
- `发布展示变更`：仅在 `enterpriseId` 存在且当前展示具备 published-change 语义时展示或启用。
- `预览展示`：只能打开本地预览模块，且必须区分 workbench summary 与 public detail。
- `数据看板`：本轮没有真实指标，不展示，不展示假 0、假趋势或假增长。

### 信息完整度

- 基于 `readiness` 的 5 项前端派生：
  - 基础资料
  - 展示能力
  - 案例
  - 联系人
  - 认证
- 文案必须说明这是展示层辅助进度。
- 不作为业务真值，不写回。

### 核心信息概览

- 模块入口使用本地 `Navigator.push`。
- 不新增 app router 全局 path。
- 每个模块继续复用原有 section 和动作。
- 模块入口至少覆盖：
  - 展示标识
  - 地址与服务区域
  - 企业画册
  - 基础资料
  - 联系人
  - 案例展示
  - 认证与状态

### 公开展示摘要

- 只展示当前工作台已有资料摘要。
- application mode 文案必须说明不等于线上公开展示。
- published-change mode 必须保留 live public display 与 current change draft preview 分离。

## 5. Visual Rules

- 页面背景使用极浅暖白。
- 卡片白底、大圆角、轻阴影。
- 品牌金只用于主 CTA、状态 badge、关键 icon。
- 首页长度必须明显短于旧长页。
- 技术字段弱化，`change request`、`carrier` 等词不进入首页主文案。
- bottom nav / bottom safe area 不得遮挡页面末尾内容。

## 6. Acceptance Criteria

- 公司工作台首页不再铺满全部长表单。
- 首页没有数据看板假数字。
- 首页没有最新动态假记录。
- 首页无真实指标时不展示数据看板，无真实动态流时不展示最新动态。
- 详细字段均可通过模块入口抵达。
- `workbench` 与 `public preview/detail` 明确区分。
- published-change corridor 不被削弱。
- supplier homepage 不回归。
- factory workbench 不进入首页化最小闭环；只要求本轮不回归。
- `flutter analyze` 和目标 Flutter tests 通过，或明确失败非本轮原因。
