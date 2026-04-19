---
owner: Codex 总控
status: frozen
purpose: Freeze the minimal contract patch for the stage-2 cloud alignment round so company public cards can consume serviceItems and workbench basic can formally round-trip albumImageFileAssetIds.
layer: L1 Contracts
freeze_date_local: 2026-04-17
inputs_canonical:
  - docs/00_ssot/enterprise_display_stage2_public_card_and_album_cloud_alignment_bounded_object_ruling_addendum.md
  - docs/01_contracts/enterprise_display_album_and_target_enterprise_info_contract_freeze_addendum.md
  - docs/01_contracts/enterprise_hub_v1_fields_states_api_contract_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 企业展示 Stage 2 公域卡片与画册补链 Contracts 冻结单

## 1. Scope

- 当前 contract freeze 只补：
  - company 公域列表 `boardHighlights.company.serviceItems`
  - workbench basic `albumImageFileAssetIds` continuity
- 当前不补：
  - 新 path
  - 新信用真值字段
  - 详情页整体 contract 扩面

## 2. Public List Company Highlights Patch

- 当前 app-facing canonical list/read family继续固定为：
  - `GET /api/app/exhibition/enterprise-hub/enterprises`
  - `GET /api/app/exhibition/enterprise-hub/recommendations`
- 当前 `EnterpriseHubListItem.boardHighlights.company` 至少必须承接：
  - `exhibitionTypes: string[]`
  - `serviceItems: string[]`
- 兼容性裁决：
  - `serviceCities` 当前可继续存在于 payload 中，
    但不再是 company 公域卡片的主消费目标字段。

## 3. Workbench Basic Album Continuity

- 当前 workbench read canonical path 继续固定为：
  - `GET /api/app/exhibition/enterprise-hub/workbench`
- 当前 `workbench.basic` 必须正式承接：
  - `albumImageFileAssetIds: string[]`
- 当前 write canonical path 继续固定为：
  - `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/basic`
- 当前 `EnterpriseHubUpdateBasicRequest` 必须正式承接：
  - `albumImageFileAssetIds?: string[]`

## 4. Upload Binding Continuity

- 当前 `albumImageFileAssetIds` 继续只承接：
  - 已完成 `init -> direct upload -> confirm` 的 `FileAsset` 引用
- 当前不得承接：
  - 裸 OSS key
  - 临时上传 URL
  - 未 confirm 的 upload token

## 5. Formal Conclusion

- 当前 stage-2 contracts 正式固定为：
  - company list highlights 必须有 `serviceItems`
  - workbench basic read / write 必须正式 round-trip `albumImageFileAssetIds`
