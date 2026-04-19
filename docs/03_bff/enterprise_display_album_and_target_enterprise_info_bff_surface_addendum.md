---
owner: Codex 总控
status: frozen
purpose: Freeze the BFF aggregation surface for enterprise-detail visual gallery shaping and gated target-enterprise formal-info read.
layer: L2.5 BFF
freeze_date_local: 2026-04-15
inputs_canonical:
  - docs/01_contracts/enterprise_display_album_and_target_enterprise_info_contract_freeze_addendum.md
  - docs/02_backend/enterprise_display_album_and_target_enterprise_info_backend_truth_addendum.md
  - docs/03_bff/enterprise_display_workbench_v1_bff_surface_addendum.md
  - apps/bff/src/routes/enterprise_hub/**
  - apps/bff/src/routes/profile/**
---

# 企业展示详情画册化与目标企业信息查看 BFF Surface 冻结单

## 1. Scope

- 当前 BFF freeze 只覆盖：
  - 公域企业详情 `visualGallery` 聚合整形
  - 目标企业 `formal-info` app-facing path
  - 双重认证受控失败整形
- 当前不覆盖：
  - 筛选 route family
  - 第二套身份中心
  - 公开证照图片查看

## 2. Public Detail Shaping Rule

- 公域企业详情 canonical path 继续固定为：
  - `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}`
- `BFF` 当前必须在 detail response 中新增：
  - `visualGallery`

- `BFF` 必须只做：
  - auth/session forward
  - organization scope forward
  - file display URL shaping
  - fallback source normalization

- `BFF` 不得做：
  - 第二套图片真值
  - 第二套画册选择规则真值
  - 公域图片权限绕过

## 3. `visualGallery` App-facing Rule

- `visualGallery` app-facing shape 固定为：
  - `albumImageUrls: string[]`
  - `source: enterprise_album | empty`

正式裁决：

- `BFF` 必须把后端返回的 `FileAsset` 引用整形成可消费图片 URL。
- `BFF` 不得把裸 `fileAssetId` 直接下发给详情页当最终展示 URL。
- `albumImageUrls` 最多返回：
  - `6`

## 4. Target-enterprise Formal-info App-facing Path

- 当前 `BFF` 必须新增：
  - `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/formal-info`

- 当前该 path 只做：
  - session forward
  - actor context forward
  - controlled error normalization
  - response shaping

- 当前该 path 不得做：
  - 当前 actor 双重认证最终判断
  - 目标企业 formal-info 本地缓存真值
  - 当前用户 `profile/certification/current` 冒充目标企业信息

## 5. Error Normalization Rule

- 当前 `formal-info` path 至少必须承接并整形：
  - `AUTH_SESSION_INVALID`
  - `ENTERPRISE_HUB_PERMISSION_DENIED`
  - `ZLK_ENTERPRISE_NOT_FOUND`

- 当前双重认证不满足时：
  - `BFF` 必须返回受控失败
  - 不得伪装成 `200 + 空对象`
  - 不得让 Flutter 误判为“该企业暂无信息”

## 6. Workbench Brand-assets Read / Write Continuity

- `BFF` 当前必须继续透传并归一：
  - `workbench.basic.logoFileAssetId`
  - `workbench.basic.albumImageFileAssetIds`
- 当前 `EnterpriseHubUpdateBasicRequest` 透传时必须额外承接：
  - `logoFileAssetId`
  - `albumImageFileAssetIds`

## 7. Formal Conclusion

- 当前 BFF 正式职责固定为：
  - 在企业详情中提供 `visualGallery`
  - 提供目标企业 `formal-info` app-facing 读取入口
  - 继续做轻量整形与受控失败归一
- 当前 BFF 不拥有：
  - 目标企业正式信息真值
  - 双重认证最终判定真值
  - 企业画册真值
