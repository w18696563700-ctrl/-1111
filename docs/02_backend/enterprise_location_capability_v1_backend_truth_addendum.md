---
owner: Codex 总控
status: active
purpose: Freeze the backend truth design for enterprise location capability V1, including truth ownership, persistence delta, provider adapter boundary, state handling, and publication snapshot rules.
layer: L3 Backend
freeze_date_local: 2026-04-16
inputs_canonical:
  - AGENTS.md
  - docs/02_backend/service_boundaries.md
  - docs/00_ssot/enterprise_location_capability_v1_truth_freeze_addendum.md
  - docs/01_contracts/enterprise_location_capability_v1_contract_freeze_addendum.md
  - apps/server/src/modules/enterprise_hub/entities/enterprise-listing.entity.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub.presenter.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-published-change-snapshot.service.ts
---

# Enterprise Location Capability V1 Backend Truth Addendum

## 1. Truth ownership

- `Server` 是企业位置能力 V1 的唯一真值 owner。
- `enterprise_hub` 负责：
  - 企业位置真值持久化
  - 工作台读写
  - 公开详情读投影
- provider-specific geocode / reverse-geocode adapter 必须落在受控 provider boundary，不得直接散落在 listing write service 中。

## 2. Persistence delta

- 当前最小持久化增量固定为：
  - 在 `enterprise_listing` 或其受控关联 carrier 上新增：
    - `districtCode`
    - `districtName`
    - `latitude`
    - `longitude`
    - `geoSource`
    - `geoStatus`
    - `lastGeocodedAt`
    - `mapProvider`
    - `publicDisplayAddress`
    - `addressText`
- 若选择单表承接：
  - 允许挂在 `enterprise_listing`
- 若选择拆表：
  - 必须是 `enterprise_listing` 的从属 truth carrier
  - 不得形成第二个位置真源

## 3. Provider adapter boundary

- 当前 provider 固定为：
  - `amap`
- 当前最小 provider 能力固定为：
  - `geocode(address)`
  - `reverseGeocode(latitude, longitude)`
- 当前不做：
  - route planning
  - near-by search
  - POI search center
- provider 配置与密钥必须来自云端配置，不得硬编码在仓库。

## 4. Write rules

- `manual_address`
  - 服务端 geocode 成功：
    - 写入完整位置真值
    - `geoSource = manual_address_geocode`
    - `geoStatus = resolved`
  - geocode 失败：
    - 允许只保留 `addressText`
    - `geoStatus = text_only` 或 `failed`
- `device_location`
  - reverse geocode 成功：
    - 写入完整位置真值
    - `geoSource = device_location`
    - `geoStatus = resolved`
  - reverse geocode 失败：
    - 若仍有地址文本，允许退回 `text_only`
    - 否则写为 `failed`

## 5. Snapshot and publication rules

- 发布态快照必须冻结企业位置真值的公开消费面：
  - `provinceName`
  - `cityName`
  - `districtName`
  - `publicDisplayAddress`
  - `latitude / longitude`（若公开策略允许）
  - `geoStatus`
  - `mapProvider`
- 不得让详情页直接拼装未冻结的运行时 provider 结果。

## 6. Query and presenter rules

- `enterprise-hub-workbench.presenter.ts`
  - 必须回读完整 `basic.location`
- `enterprise-hub.presenter.ts`
  - 必须输出 `detail.location`
- `enterprise-hub-published-change-snapshot.service.ts`
  - 必须承接位置公开消费字段，避免发布后读侧与工作台真值漂移

## 7. Runtime gate

- 当前云端必须证明：
  - 存在真实 provider config
  - geocode / reverse-geocode 调用可用
  - DB migration 已落库
  - 发布态与 live detail 读链不冲突
- 若 provider config 不存在：
  - 必须返回受控错误
  - 不得伪装为成功
