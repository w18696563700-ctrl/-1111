---
owner: Codex 总控
status: frozen
purpose: Freeze the contract patch for enterprise-detail visual gallery, workbench brand-assets alignment, and gated target-enterprise formal-info read.
layer: L1 Contracts
freeze_date_local: 2026-04-15
inputs_canonical:
  - docs/00_ssot/enterprise_display_album_layout_and_target_enterprise_info_stage_gate_checklist_addendum.md
  - docs/01_contracts/enterprise_hub_v1_fields_states_api_contract_addendum.md
  - docs/01_contracts/enterprise_display_workbench_v1_contract_freeze_addendum.md
  - docs/01_contracts/enterprise_display_published_change_corridor_contract_freeze_addendum.md
  - docs/01_contracts/certification_license_field_collection_contracts_addendum.md
---

# 企业展示详情画册化与目标企业信息查看 Contracts 冻结单

## 1. Scope

- 当前 contracts freeze 只覆盖：
  - 公域企业详情 `visualGallery` 视觉字段补丁
  - 工作台品牌素材字段补丁
  - 目标企业正式信息查看 path
- 当前不覆盖：
  - 筛选字段与筛选 path
  - Admin 审核 path
  - 第二套认证中心 path
  - 新的 OCR preview path

## 2. Public Detail Visual Patch

### 2.1 Existing Path Confirmation

- 公域企业详情 canonical path 继续固定为：
  - `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}`
- `boardType` query 继续 required。

### 2.2 Detail Response Patch

- 当前 detail success body 在既有字段基础上必须新增：
  - `visualGallery`

### 2.3 `visualGallery` Shape

- `visualGallery` 至少承接：
  - `albumImageUrls: string[]`
  - `source: enterprise_album | empty`
- 当前 `albumImageUrls` 数量上限冻结为：
  - `6`

正式裁决：

- `cases[]` 继续只承接案例信息，不得被重命名为企业画册。
- `visualGallery` 是详情页企业画册视觉 carrier。
- `visualGallery` 不得承接：
  - 当前用户私域图片
  - 裸 `fileAssetId`
  - OCR 证照图

## 3. Workbench Brand-assets Patch

### 3.1 Existing Workbench Read Confirmation

- 工作台 read canonical path 继续固定为：
  - `GET /api/app/exhibition/enterprise-hub/workbench`
- `boardType` query 继续 required。

### 3.2 Basic Field Patch

- 当前 `workbench.basic` 必须额外承接：
  - `logoFileAssetId?: string`
  - `albumImageFileAssetIds: string[]`
- 当前 `albumImageFileAssetIds` 数量上限冻结为：
  - `6`

### 3.3 Existing Write Family Patch

- 当前 `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/basic`
  所使用的 `EnterpriseHubUpdateBasicRequest` 必须额外承接：
  - `logoFileAssetId?: string | null`
  - `albumImageFileAssetIds?: string[]`

正式裁决：

- `albumImageFileAssetIds` 为空数组时，语义固定为：
  - 清空当前企业画册
- 历史 `coverFileAssetId / coverImageUrl` 当前不再属于 app-facing 合同面；
  若服务端仍承接旧库兼容修复，只能在后端内部完成，不得继续透传给 Flutter。
- factory profile 既有：
  - `showcaseImageFileAssetIds`
  继续保留为工厂实景/履约证明字段，
  不改名、不并入跨三类统一企业画册真值名。
- 已发布修改通道当前继续复用：
  - `EnterpriseHubUpdateBasicRequest`
  因此上述字段补丁自动进入当前 `changes/current/basic` family。

## 4. Target-enterprise Formal-info Read Path

### 4.1 New Path

- 当前新增 app-facing canonical path：
  - `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/formal-info`

### 4.2 Path Purpose

- 该 path 的唯一 purpose 固定为：
  - 给公域企业详情页的 `查看企业信息` 弹层提供目标企业正式认证文字信息

当前不得把该 path 解释为：

- 当前用户自己的认证 current
- 第二个认证中心首页
- OCR 预览查看入口

### 4.3 Success Body

- 当前 success body 正式冻结为：
  - `EnterpriseHubTargetEnterpriseFormalInfoResponse`
- 该 response 至少承接：
  - `enterpriseId`
  - `legalName`
  - `uscc`
  - `legalPerson`
  - `businessType`
  - `address`
  - `registeredCapital`
  - `establishedAt`
  - `businessTerm`
  - `businessScope`
  - `certificationStatus`

### 4.4 Permission Rule

- 当前 path 只允许：
  - 已登录
  - 当前 actor 双重认证通过
  的用户读取。
- 当前若未满足该条件：
  - 必须返回受控失败
  - 不得伪装成 success empty body

### 4.5 Privacy Rule

- 当前 path 明确不承接：
  - `licenseFileId`
  - OCR preview provider 原始字段
  - 当前查看者自己的身份真值
  - 非正式认证快照字段

## 5. Error Rule

- `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/formal-info`
  当前至少必须支持：
  - `AUTH_SESSION_INVALID`
  - `ENTERPRISE_HUB_PERMISSION_DENIED`
  - `ZLK_ENTERPRISE_NOT_FOUND`
- 当前双重认证未满足时：
  - 不得包装成 success
  - 不得让前端自行猜测完整 formal-info 内容

## 6. Formal Conclusion

- 当前正式结论固定为：
  - 公域企业详情新增 `visualGallery`
  - 工作台与已发布修改通道的基础资料 write/read 同步补入品牌素材字段
  - 目标企业正式信息查看固定走：
    - `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/formal-info`
  - 该 path 只承接正式认证文字信息，
    不承接证照图片与 OCR preview。
