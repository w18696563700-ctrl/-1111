---
owner: Codex 总控
status: active
purpose: Freeze the BFF app-facing surface for enterprise location capability V1, including request shaping, resolve routing, public/private trimming, and error mapping.
layer: L4 BFF
freeze_date_local: 2026-04-16
inputs_canonical:
  - AGENTS.md
  - docs/01_contracts/enterprise_location_capability_v1_contract_freeze_addendum.md
  - docs/02_backend/enterprise_location_capability_v1_backend_truth_addendum.md
  - apps/bff/src/routes/enterprise_hub/enterprise-hub.service.ts
  - apps/bff/src/routes/enterprise_hub/enterprise-hub.read-model.ts
  - apps/bff/src/routes/enterprise_hub/enterprise-hub-workbench.read-model.ts
---

# Enterprise Location Capability V1 BFF Surface Addendum

## 1. Scope

- `BFF` 只负责：
  - app-facing 位置 resolve route
  - workbench `basic.location` shaping
  - detail `location` shaping
  - 错误映射
  - public/private visibility trim
- `BFF` 不负责：
  - geocode 真值
  - provider 调用策略
  - 第二套位置状态机

## 2. App-facing route family

- 新增：
  - `POST /api/app/exhibition/enterprise-hub/location/resolve`
- 扩充：
  - `GET /api/app/exhibition/enterprise-hub/workbench`
  - `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/basic`
  - `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}`

## 3. Request shaping

- resolve route 必须只做：
  - request validation
  - canonical path forwarding
  - response shaping
- `basic.location` write payload 必须原样透传 contract 中冻结的 truth fields，不得私自删改为旧字段-only 写法。

## 4. Response shaping

- `workbench.basic.location`
  - 必须完整承接 contract 冻结字段
- `detail.location`
  - 只输出允许公开的字段
- `BFF` 不得在 response 中额外发明：
  - `poiList`
  - `routeInfo`
  - `mapBusinessState`

## 5. Error mapping

- 当前 app-facing 错误映射族固定为：
  - `ENTERPRISE_LOCATION_RESOLVE_INVALID`
  - `ENTERPRISE_LOCATION_RESOLVE_PROVIDER_UNAVAILABLE`
  - `ENTERPRISE_LOCATION_RESOLVE_FAILED`
  - `ENTERPRISE_LOCATION_WRITE_INVALID`
  - `ENTERPRISE_LOCATION_PROVIDER_CONFIG_MISSING`
- 不得把 provider gate 失败映射成假成功或空坐标成功。

## 6. Public/private trim

- 工作台 read/write 可消费完整位置真值字段
- 公开详情只能消费：
  - `provinceName`
  - `cityName`
  - `districtName`
  - `publicDisplayAddress`
  - `latitude / longitude`（若当前公开策略允许）
  - `geoStatus`
  - `mapProvider`
- `BFF` 不得持有独立 public address 拼接规则；必须消费 `Server` 给出的公开裁剪结果。
