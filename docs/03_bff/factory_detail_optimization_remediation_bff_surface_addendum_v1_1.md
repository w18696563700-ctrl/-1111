---
owner: Codex 总控
status: frozen
purpose: Freeze the BFF surface delta for the current factory-detail remediation round, including showcase display-url shaping, formal-info app-facing closure, and controlled case-state semantics.
layer: L2.5 BFF
freeze_date_local: 2026-04-18
inputs_canonical:
  - docs/01_contracts/factory_detail_optimization_remediation_contract_freeze_addendum_v1_1.md
  - docs/02_backend/factory_detail_optimization_remediation_backend_truth_addendum_v1_1.md
  - docs/03_bff/enterprise_display_album_and_target_enterprise_info_bff_surface_addendum.md
  - apps/bff/src/routes/enterprise_hub/**
---

# 工厂详情优化修复 BFF Surface 冻结单 V1.1

## 1. Scope

- 当前 `BFF` freeze 只覆盖：
  - 工厂 Hero 图源所需的 `showcase` app-facing 展示面
  - `formal-info` app-facing path 成立
  - 案例展示状态所需的 app-facing 语义
  - 地区 / 名称 / 地址字段输出优先级收口

## 2. Showcase Surface Rule

- `BFF` 必须把工厂 `showcase` file truth 整形成可消费 URL surface。
- 正式要求：
  - `BFF` 不得把裸 `fileAssetId` 直接下发给详情页当最终展示 URL
  - `BFF` 必须稳定输出给 Flutter 可直接消费的展示字段

## 3. Formal-info Path Rule

- 当前 `BFF` 必须提供：
  - `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/formal-info`
- 当前该 path 只允许做：
  - session / actor context forward
  - controlled error normalization
  - response shaping
- 当前不得做：
  - 目标企业 formal-info 本地缓存真值
  - 当前用户 `profile/certification/current` 冒充目标企业信息

## 4. Case-state Surface Rule

- 当前 `BFF` 必须确保前端不会把：
  - `当前无公开案例`
  误判成：
  - `能力未接通`

正式裁决：

- 若云端需要表达“未接通”，`BFF` 必须返回受控可判定语义。
- 仅返回 `cases=[]` 时，不得暗示“未接通”。

## 5. Location / Name Output Rule

- `BFF` 必须收口：
  - 地区字段输出优先级
  - 厂名 / 企业名输出口径
  - 公开地址字段形状
- 不得让前端继续面对：
  - `header / basic / location` 三套漂移口径

## 6. Formal Conclusion

- 当前 `BFF` 正式职责固定为：
  - 输出可直接消费的工厂 `showcase` 图源 surface
  - 打通 `formal-info` app-facing path
  - 为案例状态与地区 / 名称口径提供受控 app-facing 语义
