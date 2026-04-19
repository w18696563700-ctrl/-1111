---
owner: Codex 总控
status: frozen
purpose: Freeze the result verification conclusion for the frontend home location-scope handoff fix after confirming default automatic home load can now carry province scope when available.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/enterprise_display_home_location_scope_handoff_frontend_execution_prompt_addendum.md
  - apps/mobile/lib/core/location/device_location_service.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_home_support.dart
  - apps/mobile/test/exhibition_home_test.dart
---

# 《enterprise display home location scope handoff frontend 结果验收结论单》

## 1. 裁决结论

- 当前 `home location scope handoff frontend` 修正通过。
- 首页自动请求当前已经具备在可行时携带 `provinceCode / provinceName` 的能力。
- enterprise-display 主线不再停留在 `location scope handoff repair`。

## 2. 验收证据

### 2.1 自动 location carrier 已修正

- `apps/mobile/lib/core/location/device_location_service.dart`
  - `DeviceLocationSnapshot` 当前已携带：
    - `provinceCode`
    - `provinceName`
  - `GeolocatorDeviceLocationService.resolveCurrentPosition()` 当前会在拿到坐标后尝试解析省域 scope
  - 解析结果经：
    - `ChinaRegionCatalog`
    - placemark province normalization
    收口为当前 carrier

### 2.2 首页 request 组装已修正

- `apps/mobile/lib/features/exhibition/presentation/exhibition_home_support.dart`
  - `_homeLocationContextFromSnapshot(...)`
  当前已透传：
    - `latitude`
    - `longitude`
    - `provinceCode`
    - `provinceName`
    - `locationPermissionState`

### 2.3 定向测试成立

- 通过：
  - `flutter test test/exhibition_home_test.dart --plain-name "exhibition home automatic location handoff carries province scope into default home load"`
  - `flutter test test/exhibition_home_test.dart --plain-name "exhibition home keeps controlled placeholder when automatic location has no province scope"`
- 当前两条目标用例全部通过：
  - 有 province scope 时，自动路径命中推荐区
  - 无 province scope 时，仍保持受控空态

## 3. 当前结论边界

- 这轮通过证明的是：
  - 首页自动路径的省域 handoff 已在 Flutter 代码与定向测试层闭合
- 这轮尚未直接重跑：
  - 基于新 app 代码的完整 `ED-7 through-chain` runtime 验收
- 因此当前下一步必须回到：
  - `ED-7 result verification rerun`

## 4. 当前下一步唯一动作

- 当前阶段完成度：
  - `home location scope handoff closure 完成`
- 当前下一步唯一动作：
  - 重新执行 `ED-7 full-chain result verification`
- 下一步执行角色：
  - `结果校验`
- 下一步进入条件：
  - workbench/application/admin/public/home 各局部修正都已通过
  - 当前仅需重跑 through-chain 结论
