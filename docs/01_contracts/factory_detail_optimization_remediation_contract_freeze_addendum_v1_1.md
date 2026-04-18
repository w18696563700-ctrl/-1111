---
owner: Codex 总控
status: frozen
purpose: Freeze the app-facing contract delta for the current factory-detail remediation round, including hero-image source priority, formal-info route availability requirements, and case-state semantics.
layer: L1 Contracts
freeze_date_local: 2026-04-18
inputs_canonical:
  - docs/00_ssot/factory_detail_optimization_remediation_freeze_addendum_v1_1.md
  - docs/01_contracts/enterprise_display_album_and_target_enterprise_info_contract_freeze_addendum.md
  - docs/01_contracts/enterprise_hub_v1_fields_states_api_contract_addendum.md
---

# 工厂详情优化修复 Contracts 冻结单 V1.1

## 1. Scope

- 当前 contracts freeze 只覆盖：
  - 工厂详情 Hero 图源优先级的 app-facing 消费语义
  - `formal-info` path 的必须成立要求
  - 案例展示状态的 app-facing 判定语义
- 当前不覆盖：
  - 新的 route family
  - 非工厂对象详情改版
  - 企业身份体系扩面

## 2. Factory Detail Read Rule

- 工厂详情 canonical path 继续固定为：
  - `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}`
- `boardType=factory` 继续 required。

## 3. Hero Source Consumption Rule

- 当前工厂详情 Hero 消费优先级正式冻结为：
  1. `boardProfile.showcaseImageUrls`
  2. `visualGallery.albumImageUrls`
  3. 页面级 fallback

正式裁决：

- 若当前 app-facing 仍只返回 `showcaseImageFileAssetIds`，则 contracts 当前不视为闭环完成。
- `BFF` / `Server` 必须把 `showcase` file truth 投影成可展示 URL surface。
- 前端不得直接消费 `showcaseImageFileAssetIds` 当最终图源。

## 4. Hero Summary Rule

- 工厂详情首屏底部安全区当前只允许展示：
  - 地区
  - 认证
  - 厂房面积
  - 团队规模
- `monthlyCapacityDesc` 不再属于当前工厂详情公开主字段。

## 5. Formal-info Route Requirement

- 当前 `formal-info` canonical path 继续固定为：
  - `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/formal-info`

正式要求：

- 该 path 必须存在且返回受控语义。
- `404 Cannot GET ...` 当前属于未接通状态，不得视为“仅剩权限控制”。

## 6. Case State Semantics

- 当前 contracts 需支持前端区分：
  - 已接通但当前无公开案例
  - 能力未接通

正式裁决：

- `cases=[]` 仅能说明“当前无公开案例”，不能单独代表“能力未接通”。
- 若 app-facing 需要表达“未接通”，必须由云端返回明确可判定语义，而非由前端猜测。

## 7. Formal Conclusion

- 当前 contracts 正式要求新增 / 收紧：
  - 工厂 Hero 的可展示 `showcaseImageUrls` 优先级语义
  - `formal-info` 路由必须成立
  - 案例状态的 app-facing 判定边界
