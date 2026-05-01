---
owner: Codex 总控
status: active
purpose: Freeze the bounded truth for turning the company display workbench into a compact Flutter-only homepage without changing enterprise display truth, BFF, Server, contracts, database, or cloud runtime.
layer: L0 SSOT
based_on:
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/enterprise_display_workbench_stage1_relayout_bounded_object_ruling_addendum.md
  - docs/00_ssot/enterprise_display_workbench_stage1_relayout_stage_gate_checklist_addendum.md
  - docs/04_frontend/enterprise_display_workbench_stage1_relayout_frontend_surface_addendum.md
  - docs/04_frontend/supplier_workbench_homepage_frontend_surface_addendum.md
freeze_date_local: 2026-05-01
---

# 《公司展示工作台首页化 truth freeze》

## 1. Current Minimum Closure

- 本轮唯一目标：
  - 把 `/exhibition/company-display/workbench` 从长表单工作台压缩为 `公司展示工作台首页 + 本地模块入口 + 真实动作`。
  - 工厂工作台不进入本轮首页化，只做回归防护，不改变原有展示结构。
- 本轮只允许修改 Flutter 展示层。
- 首页只消费当前 Flutter 已经读取的既有数据：
  - `EnterpriseHubWorkbenchData`
  - `readiness`
  - `latestApplication`
  - `published-change status`
  - `cases`
  - `certification`
- 详细内容不在首页全部摊开，必须通过本地模块入口进入。
- 模块入口只能复用现有 section、现有动作、现有 route helper，不新增全局 route，不新增云端能力。

## 2. Ownership Boundary

- `Server` 继续是企业展示真值 owner。
- `BFF` 继续是 app-facing transport / auth / response shaping owner。
- `Flutter` 只拥有展示、交互、折叠、分组、本地 drill-in 和展示层辅助进度。
- 本轮不修改：
  - BFF
  - Server
  - OpenAPI
  - contracts
  - database
  - cloud runtime
  - enterprise display truth model

## 3. Homepage Allowlist

首页允许展示：

| 首页块 | 允许字段 / 行为 | 来源 | 说明 |
|---|---|---|---|
| 身份卡 | 公司名称、Logo、标签、一句话简介、当前展示状态、编辑资料入口 | `basic`、`boardProfile`、`readiness`、`latestApplication` | 缺失时用诚实空态，不造展示内容 |
| 展示状态卡 | 当前状态、申请/变更状态、阻断项、查看状态入口 | `readiness`、`latestApplication`、`published-change status` | 不派生第二套状态机 |
| 快捷入口 | 公司展示、发布展示变更、预览展示 | `enterpriseId`、board route helper、published-change route helper | 只在真实 route/真实 id 存在时展示或启用 |
| 信息完整度 | 展示层百分比、当前建议、去完善入口 | `readiness` 派生 | 不是业务真值，不写回后端 |
| 核心模块入口 | 地址与服务区域、画册、基础资料、联系人、案例、认证与状态 | 现有 section 和本地 Navigator | 不新增全局二级路由 |
| 最新动态 | 本轮不展示 | workbench 当前无独立动态流 | 不伪造历史记录 |
| 数据看板 | 本轮不展示 | workbench 当前无 analytics 字段 | 不展示假 0、假趋势或假增长 |
| 精选案例 | 最多 3 个现有案例摘要 | `cases` | 不新增案例真值 |
| 联系人 | 主要联系人摘要 | `primaryContact` | 完整维护仍进联系人模块 |
| 下一步建议 | 基于 `readiness` 的展示层建议 | `readiness` 派生 | 不是业务真值，不写回后端 |
| 公开展示摘要 | 位置、服务/展示能力、精选案例摘要 | `basic`、`boardProfile`、`cases` | 必须标明是工作台摘要，不等于 public detail |

## 4. Module Mapping

| 模块入口 | 承接 section / 组件 | 处理规则 |
|---|---|---|
| 展示标识 | `_buildDisplayIdentificationSection` | 复用现有 Logo、公司名称、公司位置、展示类型、服务项目 |
| 地址与服务区域 | `_buildMapLocationSection` | 只承接位置真值和现有解析能力，不伪装地图已完整接通 |
| 画册 | `_buildAlbumSection` | 复用现有画册 section，不新增图片真值 |
| 基础资料 | `_buildBasicSection` | 复用现有基础资料保存链 |
| 联系人 | `_buildContactSection` | 复用现有联系人和公开展示开关 |
| 案例展示 | `EnterpriseWorkbenchCaseListCard` | 复用现有案例新增/编辑/删除入口 |
| 认证与状态 | upstream truth / certification / submit sections | 仅展示真实阻断、认证、提交状态和真实动作 |

## 5. Explicit Non-goals

- 不做数据看板真实数字。
- 不做 `曝光 / 访客 / 询盘 / 收藏` 假 0 或假趋势。
- 不做最新动态伪记录。
- 不新增活动流、数据分析、review 管理接口。
- 不新增地址、案例、资质、联系人全局二级路由。
- 不新增审核能力、发布能力、支付能力。
- 不修改底部导航。
- 不把 workbench 当 public detail。
- 不把 current change 保存描述成直接更新线上展示。
- 不把地图卡写成高德/地图已完整接通。

## 6. Completeness Rule

- `信息完整度` 只允许基于 `readiness` 做展示层派生。
- 推荐派生方式：
  - `basicCompleted`
  - `profileCompleted`
  - `hasCase`
  - `hasContact`
  - `certificationApproved`
- 百分比只服务于用户理解当前资料完善程度。
- 该百分比不是业务真值、不是审核真值、不是 Server 字段、不得提交或写回。

## 7. Public Detail And Preview Separation

- `公司展示` 快捷入口：
  - 仅在存在真实 `enterpriseId` 时进入现有 company public detail route。
- `发布展示变更` 快捷入口：
  - 仅在已发布展示且存在真实 `enterpriseId` 时进入 existing published-change route。
- `预览展示`：
  - application mode 只能显示当前工作台资料摘要或本地预览语义。
  - published-change mode 必须继续区分 `线上公开展示` 与 `当前变更稿预览`。
- 本轮不得新增第二套 public detail。

## 8. Formal Decision

- 当前允许进入：
  - Flutter-only implementation
  - Flutter widget tests
  - local visual screenshot verification
- 当前不允许进入：
  - BFF implementation
  - Server implementation
  - contracts or OpenAPI changes
  - database changes
  - cloud deployment or cloud runtime mutation
  - production release
