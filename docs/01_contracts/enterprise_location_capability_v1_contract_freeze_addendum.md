---
owner: Codex 总控
status: active
purpose: Freeze the app-facing and truth-facing contract delta for enterprise location capability V1, including resolve flows, persisted location fields, public detail shape, and error families.
layer: L2 Contracts
freeze_date_local: 2026-04-16
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/enterprise_location_capability_v1_truth_freeze_addendum.md
  - docs/01_contracts/enterprise_hub_v1_fields_states_api_contract_addendum.md
  - apps/bff/src/routes/enterprise_hub/enterprise-hub.read-model.ts
  - apps/bff/src/routes/enterprise_hub/enterprise-hub-workbench.read-model.ts
---

# Enterprise Location Capability V1 Contract Freeze

## 1. Scope

- 本文冻结：
  - 工作台位置 resolve contract
  - 工作台位置 read/write contract delta
  - 公开详情位置 read contract delta
  - 位置状态枚举
  - 位置错误码
- 本文不冻结：
  - 路线规划
  - 周边搜索
  - 导航

## 2. App-facing path family delta

- 当前新增 app-facing path family 固定为：
  - `POST /api/app/exhibition/enterprise-hub/location/resolve`
- 当前扩充既有 path：
  - `GET /api/app/exhibition/enterprise-hub/workbench`
  - `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/basic`
  - `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}`

## 3. Resolve request

### 3.1 Request body

- `resolveMode: device_location | manual_address`
- `addressText?: string`
- `provinceCode?: string`
- `provinceName?: string`
- `cityCode?: string`
- `cityName?: string`
- `districtCode?: string`
- `districtName?: string`
- `latitude?: number`
- `longitude?: number`

### 3.2 Rules

- `resolveMode = device_location`
  - 必须至少提供：
    - `latitude`
    - `longitude`
- `resolveMode = manual_address`
  - 必须至少提供：
    - `addressText`
- `province / city / district` 为辅助输入，可选。

## 4. Resolve response

- `location`
  - `addressText: string`
  - `provinceCode?: string`
  - `provinceName?: string`
  - `cityCode?: string`
  - `cityName?: string`
  - `districtCode?: string`
  - `districtName?: string`
  - `latitude?: number`
  - `longitude?: number`
  - `geoSource: device_location | manual_address_geocode | manual_text_only | unknown`
  - `geoStatus: resolved | text_only | failed | not_provided`
  - `lastGeocodedAt?: string`
  - `mapProvider: amap`
  - `publicDisplayAddress?: string`
- `message?: string`

## 5. Workbench read delta

- `GET /api/app/exhibition/enterprise-hub/workbench`
  - `basic` 下新增：
    - `location`

### 5.1 workbench basic.location

- `addressText?: string`
- `provinceCode?: string`
- `provinceName?: string`
- `cityCode?: string`
- `cityName?: string`
- `districtCode?: string`
- `districtName?: string`
- `latitude?: number`
- `longitude?: number`
- `geoSource: device_location | manual_address_geocode | manual_text_only | unknown`
- `geoStatus: resolved | text_only | failed | not_provided`
- `lastGeocodedAt?: string`
- `mapProvider?: amap`
- `publicDisplayAddress?: string`

## 6. Workbench write delta

- `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/basic`
  - 在既有 `basic` payload 上新增：
    - `location`

### 6.1 basic.location

- `addressText?: string`
- `provinceCode?: string`
- `provinceName?: string`
- `cityCode?: string`
- `cityName?: string`
- `districtCode?: string`
- `districtName?: string`
- `latitude?: number`
- `longitude?: number`
- `geoSource?: device_location | manual_address_geocode | manual_text_only | unknown`
- `geoStatus?: resolved | text_only | failed | not_provided`
- `lastGeocodedAt?: string`
- `mapProvider?: amap`
- `publicDisplayAddress?: string`

### 6.2 Write rules

- 若 `geoStatus = resolved`
  - `latitude / longitude` 必须同时存在
- 若 `geoStatus = text_only`
  - 允许没有坐标
- 若 `geoStatus = failed`
  - 允许保留 `addressText`
  - 不得伪造坐标

## 7. Public detail read delta

- `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}`
  - 返回 `location`

### 7.1 detail.location

- `provinceName?: string`
- `cityName?: string`
- `districtName?: string`
- `publicDisplayAddress?: string`
- `latitude?: number`
- `longitude?: number`
- `geoStatus: resolved | text_only | failed | not_provided`
- `mapProvider?: amap`

## 8. Error families

- `ENTERPRISE_LOCATION_RESOLVE_INVALID`
- `ENTERPRISE_LOCATION_RESOLVE_PROVIDER_UNAVAILABLE`
- `ENTERPRISE_LOCATION_RESOLVE_FAILED`
- `ENTERPRISE_LOCATION_WRITE_INVALID`
- `ENTERPRISE_LOCATION_PROVIDER_CONFIG_MISSING`

## 9. Compatibility rule

- 旧字段：
  - `provinceCode`
  - `provinceName`
  - `cityCode`
  - `cityName`
  - `address`
- 继续保留兼容窗口
- 但本轮新增实现必须以 `location` 为主 carrier，再由后端做旧字段对齐或回填，不得再让前端长期只写旧字段。
