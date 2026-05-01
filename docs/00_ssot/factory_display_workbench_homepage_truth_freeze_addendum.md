---
owner: Codex 总控
status: active
purpose: Freeze the bounded truth for turning the factory display workbench into a compact Flutter-only homepage without changing enterprise display truth, BFF, Server, contracts, database, or cloud runtime.
layer: L0 SSOT
based_on:
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/company_display_workbench_homepage_truth_freeze_addendum.md
  - docs/04_frontend/company_display_workbench_homepage_frontend_surface_addendum.md
freeze_date_local: 2026-05-01
---

# 《工厂展示工作台首页化 truth freeze》

## 1. Current Minimum Closure

- 本轮目标只覆盖 Flutter 展示层的 `factory` workbench 首页化。
- `/exhibition/factory-display/workbench` 从旧长表单工作台调整为：
  - 工厂身份卡
  - 展示状态卡
  - 真实快捷入口
  - 信息完整度
  - 核心模块入口
  - 最新动态诚实空态
  - 数据看板诚实空态
  - 精选案例
  - 联系人
  - 工厂亮点
  - 下一步建议
  - 工作台资料摘要
- 详细编辑内容不在首页全部铺开，继续由本地模块入口承接原 section。
- 本轮不删除能力，只重排、折叠、分组和入口化。

## 2. Ownership Boundary

- `Server` 继续是企业展示真值 owner。
- `BFF` 继续是 app-facing transport / auth / response shaping owner。
- `Flutter` 只做展示、折叠、分组、本地 drill-in、展示层派生进度和空态。
- 本轮不修改：
  - BFF
  - Server
  - OpenAPI
  - contracts
  - database
  - cloud runtime
  - enterprise display truth model

## 3. Field Source Ruling

| 内容 | 来源 | 规则 |
|---|---|---|
| 工厂名称 | `boardProfile.factoryName` / controller / `basic.name` | 不伪造名称 |
| Logo / 封面 | `basic.logoUrl`、logo image、factory showcase image | 缺失时展示真实空态 |
| 标签 | `boardProfile.processTypes`、`boardProfile.coreProducts`、本地选项 | 只展示真实已选项 |
| 一句话简介 | `basic.shortIntro` | 缺失时展示诚实空态 |
| 状态 | `readiness`、`latestApplication`、published-change status | 不新增状态机 |
| 信息完整度 | `readiness` 前端派生 | 不是业务真值，不写回 |
| 核心模块 | 现有 workbench section | 本地 `Navigator.push`，不新增全局路由 |
| 最新动态 | 当前 contract 无动态流 | 显示 `暂无动态`，不伪造记录 |
| 数据看板 | 当前 contract 无 analytics 指标 | 显示 `暂无数据`，不展示假 0 或趋势 |
| 工厂亮点 | 工艺、厂房面积、设备条目、案例数量等真实字段 | 无真源则不硬写营销数字 |

## 4. Workbench And Public Detail Separation

- `factory workbench` 是组织侧资料维护工作台，不等于 public detail。
- `工厂展示` 快捷入口仅在存在真实 `enterpriseId` 时进入 existing factory public detail route。
- `发布展示变更` 仅使用 existing published-change route。
- `预览展示` 在 application mode 只展示当前 workbench 摘要；published-change mode 必须继续区分 live public detail 与 current change draft。
- 无真实全局二级页时，不新增假 route；模块入口使用本地 route 承接原 section。

## 5. Explicit Non-goals

- 不做 BFF / Server / OpenAPI / DB 变更。
- 不新增审核、发布、支付、结算能力。
- 不新增底部导航 route。
- 不新增 analytics 真值或动态流真值。
- 不展示假曝光、假访客、假询盘、假收藏、假趋势。
- 不把 `workbench` 当成 `public detail`。
- 不把示意图中的营销数字写死进页面。
- 不影响 supplier homepage 现有分支。

## 6. Formal Decision

- 允许进入：
  - Flutter-only factory homepage implementation
  - Flutter widget / route tests
  - local visual verification where account state allows
- 不允许进入：
  - BFF implementation
  - Server implementation
  - contracts / OpenAPI changes
  - database changes
  - cloud deployment or restart
