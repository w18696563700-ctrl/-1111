---
owner: Codex 总控
status: active
purpose: Freeze the bounded truth for the Flutter-only UI refinement across exhibition home company recommendations, company display workbench, and public company detail.
layer: L0 SSOT
based_on:
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/company_display_workbench_homepage_truth_freeze_addendum.md
  - docs/04_frontend/company_display_workbench_homepage_frontend_surface_addendum.md
freeze_date_local: 2026-05-05
---

# 《公司展示工作台到公司详情页展示链路 UI 精修 truth freeze》

## 1. Current Minimum Closure

本轮最小闭环只覆盖 Flutter 展示层的三段用户可见链路：

1. 展览首页 `公司` 推荐列表卡片更简约。
2. 公司展示工作台继续作为资料管理入口，进一步减负和分组。
3. 公司详情页继续作为公开展示页，按信任建立顺序展示 public live detail。

本轮不改企业展示业务真值，不新增接口，不修改 BFF、Server、OpenAPI、数据库、云端部署或云端运行配置。

## 2. Truth Ownership

| 层 | 本轮定位 | 是否修改 |
|---|---|---|
| Server | 企业展示、审核、发布、联系人权限、案例公开性、资质与口碑的业务真值 owner | 否 |
| BFF | App-facing transport / auth / response shaping | 否 |
| OpenAPI / generated contracts | 既有字段与路径投影 | 否 |
| Flutter | 展示顺序、卡片样式、折叠分组、入口点击区域、受控空态 | 是 |
| Cloud runtime | 只可做已批准的只读验证；本轮不发布、不重启、不写云端 | 否 |

## 3. Three-Surface Boundary

### 展览首页公司推荐

- 只消费 `EnterpriseHubListItem` 和现有 `EnterpriseHubConsumerLayer`。
- 公司推荐卡不再展示 `优秀公司` 这类板块 badge。
- 公司推荐卡允许整卡点击进入既有 company detail route。
- 不新增首页聚合字段，不新增推荐算法，不新增假标签。

### 公司展示工作台

- 只消费 `EnterpriseHubWorkbenchData`、`readiness`、`latestApplication`、published-change status、`cases`、`certification`。
- 工作台负责有秩序地管理资料，不作为线上公开详情真值。
- `信息完整度` 只能基于 `readiness` 做展示层派生，不是业务真值，不写回。
- 详细内容继续通过现有本地模块入口承接，不新增全局二级 route。

### 公司详情页

- 只消费 public live detail：`EnterpriseHubDetailData`。
- 详情页不得读取 workbench draft/current change 作为公开真值。
- published-change 预览只能使用 current change projection，且必须与 live public detail 明确分离。
- 不显示内部审核技术字段、`changeRequestId`、`readiness.blockers`、OCR 内部说明或后台处理文案。

## 4. Workbench To Public Detail Field Map

| 信息 | 工作台来源 | 公开详情来源 | 展示规则 |
|---|---|---|---|
| Logo | `basic.logoUrl` / `logoFileAssetId` | `header.logoUrl` | Logo 是身份识别，不与案例图混用 |
| 封面 / Hero 图 | `basic.albumImageUrlMap` / `boardProfile.showcaseImageUrlMap` | `visualGallery.imageUrls` | 优先公开详情返回的 gallery，不从工作台临时图直接冒充 live |
| 公司名称 | `basic.name` / organization truth | `header.name` | 详情页只展示 public live name |
| 一句话简介 | `basic.shortIntro` | `header.shortIntro` | Hero 或摘要区展示 |
| 公司介绍 | `basic.fullIntro` | `basicInfo.fullIntro` | 首屏展示摘要，长文允许折叠展开 |
| 所在地区 | `basic.provinceName/cityName/location` | `header.provinceName/cityName` / `location` | 只展示真实返回地区 |
| 详细地址 | `basic.address/location.publicDisplayAddress` | `location.displayAddress` / `basicInfo.address` | 坐标缺失时不伪造地图 |
| 服务区域 | `boardProfile.serviceCities` | `serviceAreas` | 公开详情以 Server/BFF 返回 public live serviceAreas 为准 |
| 展会类型 | `boardProfile.exhibitionTypes` | `boardProfile.exhibitionTypes` | 无值不展示 |
| 服务项目 | `boardProfile.serviceItems` | `boardProfile.serviceItems` | 无值不展示 |
| 最大项目规模 | `boardProfile.maxProjectScale` | `boardProfile.maxProjectScale` | 可作为核心优势或基本信息 |
| 资质说明 | `boardProfile.qualificationDesc` / `certification` | `certifications` / `boardProfile.qualificationDesc` | 未认证或未返回摘要时不得伪造 |
| 案例 | `cases` | `cases` | 公开详情只展示 BFF 返回的 public cases |
| 团队规模 | `basic.teamSizeRange` | `basicInfo.teamSizeRange` | 无值不展示 |
| 合作方式 | `basic.cooperationModes` | public detail 现有返回字段或 boardProfile 投影 | 无真实字段不展示 |
| 联系人 | `primaryContact` / visibility flags | `contacts` | 必须遵守云端公开权限，前端不强行公开 |
| 发布/审核状态 | `latestApplication` / `currentChangeRequest` / `liveSnapshot` | 仅轻量公开 badge | 内部状态不进入公开详情主体 |

## 5. Explicit Non-goals

- 不做数据看板。
- 不做最新动态。
- 不做假地图、假大图、假案例、假资质、假评价、假联系人。
- 不新增审核能力、发布能力、认证能力、支付能力。
- 不修改底部导航。
- 不修改 company listing/detail/workbench/published-change 真值关系。
- 不把 workbench draft/current change 当成 public live detail。
- 不修改 BFF / Server / OpenAPI / generated contracts / database / cloud runtime。

## 6. Gate Decision

- Gate 0 read-only scan: Pass.
- Gate 1 truth freeze: Pass for Flutter-only UI implementation.
- Allowed next stage:
  - Flutter presentation implementation.
  - Flutter scoped tests.
  - Local screenshot verification.
  - Computer Use visual verification only after the user hot-starts and logs in.
- Not allowed:
  - BFF implementation.
  - Server implementation.
  - Contract generation or OpenAPI edit.
  - Cloud deploy, restart, runtime mutation, database write.
