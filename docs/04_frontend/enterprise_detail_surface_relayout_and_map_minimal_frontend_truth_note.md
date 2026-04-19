---
owner: Codex 总控
status: active
purpose: Freeze the bounded frontend truth for the company/factory/supplier detail relayout round, including the unified IA, per-board module mapping, and the formal map feasibility conclusion.
layer: L2 frontend
freeze_date_local: 2026-04-16
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/enterprise_detail_surface_relayout_and_map_minimal_stage_gate_checklist_addendum.md
  - docs/00_ssot/platform_capability_unified_baseline_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_pages.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_surface_widgets.dart
  - apps/mobile/lib/features/exhibition/data/enterprise_hub_consumer_layer.dart
  - apps/bff/src/routes/enterprise_hub/enterprise-hub.read-model.ts
---

# 企业详情页重排与最小地图判定前端真值说明

## 1. 本轮目标

- 本轮只重做：
  - `公司详情`
  - `工厂详情`
  - `供应商详情`
  的信息架构和视觉层级。
- 本轮唯一允许的增强项是：
  - 地图能力判定
- 本轮不做：
  - 新业务流
  - 新上传链路
  - 新详情真值
  - 新企业 formal-info 读取路径

## 2. 当前公开详情真值结论

- 当前 `EnterpriseDetailPage` 公开 detail read 已稳定承接：
  - `header`
  - `basicInfo`
  - `boardProfile`
  - `serviceAreas`
  - `cases`
  - `certifications`
  - `reviewSummary`
  - `contacts`
- 当前 detail-facing 真值已足以支持：
  - 企业首屏重排
  - 能力模块重排
  - 地址与服务区域增强
  - 图册/案例分离展示
- 当前 detail-facing 真值不足以支持：
  - 真实地图卡片
  - 经纬度定位
  - 地图静态底图
  - 地图跳转

## 3. 统一 IA 方案

### 3.1 首屏骨架

- 首屏必须回答 5 个问题：
  - 企业是什么
  - 擅长什么
  - 在哪里
  - 规模如何
  - 为什么可信
- 首屏固定骨架为：
  - `头图 / Hero`
  - `企业名 + 标签`
  - `一句话定位`
  - `关键指标条`
  - `地址与服务区域卡`

### 3.2 次屏骨架

- 次屏固定顺序为：
  - `核心能力`
  - `产品 / 工艺 / 服务项目`
  - `企业画册`
  - `案例展示`
  - `联系方式`
  - `补充信息 / 口碑 / 资质`

### 3.3 深层信息骨架

- 深层资料只作为低优先级说明，不允许上提为首屏字段堆叠：
  - `详细介绍`
  - `口碑摘要`
  - `认证摘要`
  - `其他留空块`

## 4. 三类对象模块映射表

| 模块 | 公司 | 工厂 | 供应商 |
|---|---|---|---|
| Hero 封面 | 共用 | 共用 | 共用 |
| 企业名 / 标签 / 认证态 | 共用 | 共用 | 共用 |
| 关键指标 | 城市、服务项目数感、项目规模 | 厂房面积、月产能、配送半径 | 供应品类、响应时效、配送范围 |
| 地址与服务区域 | 省市 + 服务城市 | 省市 + 详细地址 + 服务区域 | 省市 + 配送范围 / 服务区域 |
| 核心能力 | 展会类型、服务项目、服务城市 | 工艺类型、核心产品、设备清单 | 供应品类、供应模式、核心产品或服务 |
| 图册 | 共用 | 共用，优先承接工厂图源 | 共用 |
| 案例 | 共用 | 共用 | 共用 |
| 联系方式 | 共用 | 共用 | 共用 |
| 详细介绍 | 共用 | 共用 | 共用 |

## 5. 地图能力正式判定

### 5.1 当前结论

- 当前正式结论固定为：
  - `本轮不接通真地图`
  - `本轮只增强地址与服务区域展示`

### 5.2 证据链

- 当前 BFF read-model 已见：
  - `provinceName`
  - `cityName`
  - `basicInfo.address`
  - `serviceAreas`
- 当前未见 detail-facing：
  - `latitude`
  - `longitude`
  - `mapUrl`
  - `mapSnapshot`
  - `gaodePoiId`
- 当前 `platform.map.*` 只是在 `L0` 作为 pre-embed capability name 冻结，
  不能被前端擅自解释为用户可用地图功能。

### 5.3 本轮前端处理规则

- 本轮允许：
  - 做 `地址与服务区域` 卡
  - 明确呈现省市、详细地址、服务区域
  - 在视觉上保留未来地图卡位
- 本轮不允许：
  - 出现“查看地图”真按钮
  - 出现可点击地图缩略图
  - 出现伪造的经纬度或外链

## 6. 视觉与交互规则

- 详情页必须从“字段白卡堆叠”升级为“有首屏层级和阅读节奏的详情页”。
- 画册和案例必须继续分离：
  - 图册是企业形象与能力观感
  - 案例是独立内容证明
- 空态允许保留，但必须：
  - 不塌陷
  - 不抢主信息
  - 不伪装成已接通

## 7. Anti-revert

- 后续线程不得把详情页退回成：
  - 录入字段顺序回读
  - 大量白底长表单卡片
  - 首屏缺少地址/能力/可信信息的旧形态
- 后续线程不得把“地图可接”误写成：
  - `地图已接通`
- 后续线程若要真接地图，必须先补：
  - contract
  - backend truth
  - BFF surface
  - runtime evidence
