---
owner: Codex 总控
status: active
purpose: Freeze enterprise location capability V1 as a bounded truth object, including ownership, truth carriers, provider boundary, public/private sync, and anti-revert rules.
layer: L0 SSOT
freeze_date_local: 2026-04-16
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/platform_capability_unified_baseline_addendum.md
  - docs/00_ssot/enterprise_display_workbench_v1_truth_freeze_addendum.md
  - docs/00_ssot/enterprise_detail_surface_relayout_and_map_minimal_frontend_truth_note.md
  - docs/02_backend/service_boundaries.md
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_media_actions.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_relayout_sections.dart
  - apps/bff/src/routes/enterprise_hub/enterprise-hub.read-model.ts
  - apps/server/src/modules/enterprise_hub/entities/enterprise-listing.entity.ts
---

# 企业位置能力 V1 真源冻结单

## 1. 对象定义

- 当前对象正式冻结为：
  - `企业位置能力 V1`
- 它是：
  - `企业展示工作台` 与 `公开企业详情页` 共享的一条企业位置真值链
- 它不是：
  - 详情页上的临时地图组件
  - 前端本地地址辅助动作
  - 平台级地图全面解锁

## 2. 当前现状盘点结论

- 当前工作台已有：
  - 详细地址输入
  - `用当前位置回填`
  - 基于设备定位和系统逆地理编码的地址辅助
- 当前工作台没有：
  - 坐标真值
  - 行政区到 `district` 级 carrier
  - 解析状态
  - provider 来源
- 当前公开详情已有：
  - `provinceName`
  - `cityName`
  - `basicInfo.address`
  - `serviceAreas`
- 当前公开详情没有：
  - `latitude / longitude`
  - `publicDisplayAddress`
  - 地图卡 carrier
  - 高德地图可用链路

## 3. 真值归属

- `Server` 是企业位置能力 V1 的唯一真值 owner。
- `BFF` 只负责：
  - app-facing shape
  - 错误映射
  - public/private visibility trim
- `Flutter App` 只负责：
  - 位置输入
  - 预览
  - 已冻结 contract 的消费
- 前端不得长期持有正式企业位置真值。

## 4. 企业位置真值字段

- 后端真值至少必须承接：
  - `addressText`
  - `provinceCode`
  - `provinceName`
  - `cityCode`
  - `cityName`
  - `districtCode`
  - `districtName`
  - `latitude`
  - `longitude`
  - `geoSource`
  - `geoStatus`
  - `lastGeocodedAt`
  - `mapProvider`
  - `publicDisplayAddress`

## 5. geoSource / geoStatus 冻结

### 5.1 geoSource

- `device_location`
- `manual_address_geocode`
- `manual_text_only`
- `unknown`

### 5.2 geoStatus

- `resolved`
- `text_only`
- `failed`
- `not_provided`

## 6. provider 边界

- 高德 provider 适配必须归入受控 provider/adapter 边界。
- 当前正式采用：
  - `Amap Web Service Key` 用于服务端 geocode / reverse-geocode
- 当前不允许：
  - 在 `enterprise_hub` 业务服务里散落 provider-specific URL 规则
  - 让前端把 provider 结果直接当正式真值
- 若需要地图卡图片或轻量预览：
  - 必须明确是基于同一坐标真值的 provider 输出
  - 不得成为第二套位置链路

## 7. 工作台与公开详情的关系

- 工作台保存成功后：
  - 公开详情必须读取同一位置真值
- 不允许：
  - 工作台自己算一套
  - 公开详情再自己算一套
- `服务区域` 保持为独立业务字段：
  - 继续表达企业覆盖范围
  - 但不得冒充企业地理位置

## 8. 公开展示裁剪规则

- 公开详情至少可消费：
  - `provinceName`
  - `cityName`
  - `districtName`
  - `publicDisplayAddress`
  - `geoStatus`
  - `mapProvider`
  - `latitude / longitude`（仅在当前公开策略允许时）
- 若当前公开策略不允许直出完整地址：
  - 必须通过 `publicDisplayAddress` 统一裁剪
- 任何公开裁剪都不得让私域、公域变成两套位置真值。

## 9. 高德控制台与操作者职责

- 高德开发者控制台页面：
  - [我的应用 | 高德控制台](https://console.amap.com/dev/key/app)
- 当前正式结论固定为：
  - 总控可以协助梳理：
    - 需要哪类 key
    - 哪个链路用哪个 key
    - 包名/签名/安全域配置项
  - 但以下动作属于操作者职责：
    - 登录控制台
    - 完成验证码或账户验证
    - 创建或查看 key
    - 手动输入敏感信息
- `key`、签名、密码、secret 不得进入任何 formal truth 文档。

## 10. Anti-revert

- 后续线程不得把企业位置能力 V1 回退成：
  - 只有 `address`
  - 只有“当前位置回填”
  - 只有前端本地 geocode
  - 只有详情页假地图占位
- 后续线程不得再把：
  - `platform.map.*` pre-embed
  误写成：
  - enterprise end-user map 已接通
- 若 provider gate 不成立，必须明确记为 blocker 或真实降级，不能伪装完成。
