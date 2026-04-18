---
owner: Codex 总控
status: frozen
purpose: Freeze the backend truth delta for the current factory-detail remediation round, including location/name source priority, showcase-to-display-url projection requirement, and formal-info read closure.
layer: L2 Backend
freeze_date_local: 2026-04-18
inputs_canonical:
  - docs/00_ssot/factory_detail_optimization_remediation_freeze_addendum_v1_1.md
  - docs/01_contracts/factory_detail_optimization_remediation_contract_freeze_addendum_v1_1.md
  - docs/02_backend/enterprise_display_album_and_target_enterprise_info_backend_truth_addendum.md
  - apps/server/src/modules/enterprise_hub/**
---

# 工厂详情优化修复 Backend Truth 冻结单 V1.1

## 1. Scope

- 当前 backend freeze 只覆盖：
  - 工厂详情地区 / 名称 / 地址口径收口
  - 工厂 `showcase` 真值到可展示 URL surface 的组装输入
  - `formal-info` read closure
  - 案例状态语义所需的后端判定边界

## 2. Factory Location Truth Rule

- 当前工厂详情地区显示优先级冻结为：
  1. `location` 公开展示真值
  2. `listing` 中与 `location` 对齐后的回退值
- 不允许：
  - `header / basic / location` 三套口径长期漂移并存
  - “注册地址在重庆、地区显示成都”的公开冲突继续保留

正式要求：

- 后端必须定位并修复当前工厂地区错配来源。
- `listing / location / organization / certification / publicDisplayAddress`
  的职责边界必须明确，不得继续互相污染。

## 3. Factory Name Truth Rule

- 当前工厂详情必须明确区分：
  - 工厂名
  - 企业正式名称
- 后端必须给出稳定来源，不得让两者在同页语义打架。

## 4. Showcase Projection Rule

- `enterprise_profile_factory.showcase_image_file_asset_ids` 继续保留为工厂实景 / 履约证明真值。
- 但在当前工厂详情详情面，后端必须为其补出可展示 URL surface 输入。

正式裁决：

- 单独返回 `showcaseImageFileAssetIds` 不足以满足当前工厂 Hero 图源闭环。
- 当前后端必须提供可供 `BFF` 继续整形或直接透传的展示型 carrier。

## 5. Formal-info Rule

- `GET /server/exhibition/enterprise-hub/enterprises/{enterpriseId}/formal-info`
  必须真实存在并可读取目标企业正式认证 current truth。
- 不得读取：
  - 当前查看者自己的 `certification/current`
  - OCR preview 缓存
  - 证照图片公开对象

## 6. Cases State Rule

- 后端必须保证：
  - `cases=[]` 只表示当前无公开案例
- 若需要表达“能力未接通”，必须由更上层显式输出受控语义，不得让前端靠空数组自行推断。

## 7. Formal Conclusion

- 当前 backend 侧唯一必须收口的对象为：
  - 地区 / 名称 / 地址口径
  - `showcase` 展示型 carrier
  - `formal-info` 真值读取链
  - `cases` 状态语义边界
