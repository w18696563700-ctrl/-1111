---
owner: Codex 总控
status: frozen
purpose: Freeze the app-facing contract rules for enterprise-display company/factory board separation, case-media carrier stability, and public-case route alignment before any bounded repair implementation begins.
layer: L1 Contracts
freeze_date_local: 2026-04-19
inputs_canonical:
  - docs/00_ssot/enterprise_display_company_factory_case_media_repair_bounded_object_ruling_addendum.md
  - docs/00_ssot/enterprise_display_company_factory_case_media_repair_stage_gate_checklist_addendum.md
  - docs/01_contracts/enterprise_hub_v1_fields_states_api_contract_addendum.md
  - docs/01_contracts/enterprise_display_case_library_continuation_contract_freeze_addendum.md
  - docs/01_contracts/enterprise_display_field_alignment_v1_revision_projection_contract_addendum.md
---

# 《企业展示 company/factory 串板块与案例媒体回显合同冻结单》

## 1. Scope

- 当前 contract freeze 只覆盖：
  - company / factory 命名语义
  - case detail / public-case / workbench case item 的媒体 carrier
  - board-scoped case visibility 语义
  - `public-cases` canonical app-facing route
- 当前不覆盖：
  - 新 board type
  - 新列表筛选 contract
  - map preview contract

## 2. Canonical Public Case Path

- 当前正式重申 canonical app-facing path：
  - `GET /api/app/exhibition/enterprise-hub/public-cases/{caseId}`
- 当前 path contract 语义固定为：
  - 读取公开可见、已批准、且属于当前公开展示档的单案例 detail carrier
- 当前不得把 live `404` 解释为：
  - route 不存在
  - contract 未冻结

## 3. Case Detail Carrier Rule

### 3.1 Private case detail

- `GET /api/app/exhibition/enterprise-hub/cases/{caseId}` 当前正式要求继续返回：
  - `caseId`
  - `enterpriseId`
  - `boardType`
  - `title`
  - `exhibitionType`
  - `city`
  - `eventTime`
  - `summary`
  - `caseCoverFileAssetId`
  - `caseMediaFileAssetIds`
  - `caseImageUrlMap`
  - `isFeatured`
  - `caseStatus`

### 3.2 Public case detail

- `GET /api/app/exhibition/enterprise-hub/public-cases/{caseId}` 当前正式要求返回同一组核心字段：
  - `caseCoverFileAssetId`
  - `caseMediaFileAssetIds`
  - `caseImageUrlMap`
  不得缺失

### 3.3 Workbench case summary

- `GET /api/app/exhibition/enterprise-hub/workbench` 中的 `cases[]` 当前正式要求继续承接：
  - `caseCoverFileAssetId`
  - `caseMediaFileAssetIds`
  - `caseImageUrlMap`
- 当前不得把 `caseImageUrlMap` 从 workbench case summary 静默移除。

## 4. Media Truth Rule

- `fileAssetId` 仍是媒体真值 carrier。
- `caseImageUrlMap` / `showcaseImageUrlMap` 仍是 display projection carrier。
- 当前正式冻结：
  - client 不得把“URL map 缺项”解释成“没有图片”
  - `caseCoverFileAssetId / caseMediaFileAssetIds` 仍然是 canonical truth
  - `caseImageUrlMap` 缺项只代表 display projection 不完整，不代表媒体真值为空

## 5. Board-scoped Case Visibility Rule

- 当前正式冻结：
  - 公开 company detail 只允许暴露 `boardType=company` 的 case
  - 公开 factory detail 只允许暴露 `boardType=factory` 的 case
  - workbench 只允许暴露当前 listing `primaryBoardType` 的 case
  - published-change snapshot / apply 只允许处理当前 listing `primaryBoardType` 的 case
- 当前不得继续把：
  - `enterpriseId` 裸读取
  解释为合法 contract 行为

## 6. Factory Naming Contract Rule

- 当前正式冻结 factory 的 app-facing naming 语义：
  - factory 对外标题优先展示 `factoryName`
  - 公司主体名 / legal name 只作为辅助信息 carrier
- 公开列表 / 推荐 / 详情 / 私有 workbench 不得再各自发明不同的 title 语义。

## 7. Anti-revert

- 不得把 `caseImageUrlMap` 重新定义成可选且可静默丢弃的临时字段。
- 不得把 factory 标题重新写回公司主体名唯一展示。
- 不得把 `enterpriseId` 裸 case 聚合继续伪装成合法 detail contract。

## 8. Formal Conclusion

- 当前 contract bundle 已冻结为：
  - canonical `public-cases` app-facing path
  - mandatory case-media projection carrier presence
  - board-scoped case visibility semantics
  - unified factory naming semantics

