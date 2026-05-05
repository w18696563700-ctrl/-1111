---
owner: Codex 总控
status: active
purpose: Freeze the bounded truth for the Flutter-only visual refinement of public company detail and exhibition-home company recommendation cards.
layer: L0 SSOT
based_on:
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/company_display_workbench_to_public_detail_ui_chain_truth_freeze_addendum.md
  - docs/04_frontend/company_display_workbench_to_public_detail_ui_chain_frontend_surface_addendum.md
freeze_date_local: 2026-05-05
---

# 《公司详情页公开展示与首页公司推荐卡视觉精修 truth freeze》

## 1. Current Minimum Closure

本轮最小闭环只覆盖 Flutter 展示层的两个用户可见面：

1. 展览首页 `公司` 推荐列表卡从纯文字卡升级为“公司列表同款头像卡”。
2. 公司详情页继续作为公开展示页，按目标参考图的信任建立顺序精修视觉和信息密度。

本轮不改企业展示业务真值，不新增接口，不修改 BFF、Server、OpenAPI、数据库、云端部署、云端运行配置或联系方式公开权限。

## 2. Truth Ownership

| 层 | 本轮定位 | 是否修改 |
| --- | --- | --- |
| Server | 企业展示、公开详情、案例公开性、资质、评价、联系人权限的业务真值 owner | 否 |
| BFF | App-facing transport / auth / response shaping | 否 |
| OpenAPI / generated contracts | 既有字段与路径投影 | 否 |
| Flutter | 卡片布局、头像展示、详情页信息排序、受控空态、截图验收 | 是 |
| Cloud runtime | 本轮不发布、不重启、不写云端 | 否 |

## 3. Field Source Freeze

### 3.1 首页公司推荐卡字段来源

首页公司推荐卡只消费 `EnterpriseHubListItem`：

| 展示项 | 字段来源 | 缺失处理 |
| --- | --- | --- |
| 头像 / 缩略图 | `item.logoUrl` | 无值或加载失败时使用现有 fallback 首字占位 |
| 公司名称 | `item.name` | 必填字段，异常由既有 parser 处理 |
| 地区 | `item.provinceName` / `item.cityName` | 有值展示，无值不造假地区 |
| 简介 | `item.shortIntro` | 无值时可展示真实能力摘要 |
| 展会类型 | `item.boardHighlights['company']['exhibitionTypes']` | 无值不展示 |
| 服务项目 | `item.boardHighlights['company']['serviceItems']` | 无值不展示 |
| 认证 | `item.certificationLabel` | 无值不展示认证 chip |
| 案例数 | `item.caseCount` | 大于 0 才展示 |
| 评分 | `item.avgScore` | 有值才展示，不把目标图数字写死 |

首页公司推荐卡必须复用或等价对齐公司列表卡的头像/缩略图展示逻辑，不允许重新造 DTO 或新增推荐字段。

### 3.2 公司详情页字段来源

公司详情页只消费 `EnterpriseHubDetailData` public live detail：

| 展示项 | 字段来源 | 缺失处理 |
| --- | --- | --- |
| Hero 图 | `visualGallery.imageUrls`，fallback `header.logoUrl` | 无真实图片时使用既有 fallback，不制造展台图 |
| Hero 公司名 | `header.name` | 必填字段 |
| Hero 标签 | `header.verificationStatus`、`boardProfile.exhibitionTypes`、`boardProfile.serviceItems` | 无值减少标签数量 |
| 图片计数 | `visualGallery.imageUrls.length` | 多于 1 张才显示轮播计数 |
| 地区指标 | `location`、`header.provinceName/cityName`、`serviceAreas` | 无值不展示或降级为已有地区 |
| 认证指标 | `header.verificationStatus`、`certifications` | 无值展示受控未认证文案，不伪造认证 |
| 团队/经验指标 | `basicInfo.teamSizeRange`、`basicInfo.foundedAt` | 只能展示已有字段，不从日期强行包装“5 年经验” |
| 评分 / 评价 | `reviewSummary.avgScore`、`reviewSummary.reviewCount`、`reviewSummary.keywordTags` | 无值不显示 98% / 56 等目标图示例数字 |
| 公司介绍 | `basicInfo.fullIntro`、fallback `header.shortIntro` | 摘要优先，长文可展开 |
| 地址与地图 | `location.displayAddress`、`basicInfo.address`、`location.mapPreviewUrl/mapLinkUrl/coordinates` | 坐标或地图缺失时不伪造地图 |
| 核心优势 | `boardProfile.serviceItems`、`boardProfile.exhibitionTypes`、`boardProfile.maxProjectScale`、`boardProfile.qualificationDesc` | 无值减少优势卡数量 |
| 案例 | `cases` | 只展示 public live detail 返回的公开案例 |
| 资质 | `certifications`、`boardProfile.qualificationDesc` | 无值显示受控空态或隐藏，不伪造资质 |
| 联系人 | `contacts` | 严格遵守现有公开权限 |

## 4. Missing Field Rules

- 无评分：不显示评分指标，不显示 `98%`。
- 无评价数：不显示评价数，不显示 `56`。
- 无经验年限：不显示 `5 年经验`，不得从成立时间强行派生行业经验。
- 无头像：使用现有首字 fallback。
- 无 Hero 图：使用 `header.logoUrl` 或既有 fallback，不引入示意图。
- 无案例：展示公开案例空态，不造案例。
- 无资质：展示受控空态或隐藏资质项，不造证书。
- 无联系人：展示受控空态，不强行公开隐藏联系方式。

## 5. Visual Target Freeze

### 首页公司推荐卡

目标形态：

```text
[Logo/封面]  公司名称                         >
          地区
          展会类型 / 服务项目摘要
          [真实 chip] [真实 chip] [认证] [案例数]
```

硬性规则：

- 公司卡继续不展示 `优秀公司`。
- 公司卡整卡点击进入既有公司详情 route。
- 工厂 / 供应商推荐卡不得因公司卡改动回归。

### 公司详情页

目标顺序：

1. Hero：大图 / Logo、公司名、认证与能力标签、图片计数。
2. 信任指标：地区、认证、团队/成立时间、评分/评价。
3. 公司介绍：全宽摘要卡，可展开。
4. 地址与服务区域：压缩重复文案，保留真实地图。
5. 核心优势：3-4 个真实字段图标卡。
6. 案例展示：横向缩略图，最多 6 个。
7. 资质与口碑：真实资质、真实评分/评价，缺失受控空态。
8. 基本信息：紧凑信息行。
9. 联系方式：遵守权限，可做底部联系条。

## 6. Explicit Non-goals

- 不新增 BFF / Server 字段。
- 不编辑 OpenAPI 或 generated contracts。
- 不做云端部署、重启、数据库写入或云端写 smoke。
- 不新增假评分、假评价数、假案例、假资质、假联系人、假经验年限。
- 不新增数据看板、最新动态、审核能力、发布能力、认证能力或支付能力。
- 不把 workbench current change / draft projection 当成 public live detail。

## 7. Gate Decision

- Gate 0 read-only scan: Pass.
- Gate 1 truth freeze: Pass for Flutter-only implementation after this file and the matching frontend surface / stage-gate file are registered.
- Allowed next stage:
  - Flutter presentation edits under the allowlist.
  - Scoped Flutter tests.
  - Computer Use screenshots after user hot-starts and logs in.
- Not allowed:
  - BFF / Server / contracts / DB / cloud edits.
