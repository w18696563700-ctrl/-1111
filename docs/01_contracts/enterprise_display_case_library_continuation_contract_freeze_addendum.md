---
owner: Codex 总控
status: frozen
purpose: Freeze the app-facing contract bundle for enterprise display case-library continuation, including the case detail read carrier and the direct case update canonical path, before any implementation dispatch.
layer: L1 Contracts
freeze_date_local: 2026-04-11
inputs_canonical:
  - docs/00_ssot/enterprise_display_case_library_continuation_truth_freeze_addendum.md
  - docs/00_ssot/enterprise_display_case_continuation_and_published_change_corridor_stage_gate_checklist_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 企业展示案例库继续编辑 Contracts 冻结单

## 1. Scope

- 当前 contracts freeze 只覆盖：
  - `GET /api/app/exhibition/enterprise-hub/cases/{caseId}`
  - `PUT /api/app/exhibition/enterprise-hub/cases/{caseId}`
- 当前继续确认复用：
  - `POST /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/cases`
  - `DELETE /api/app/exhibition/enterprise-hub/cases/{caseId}`
  - shared upload `init / confirm`
- 当前不覆盖：
  - 已发布展示的正式 `change corridor`
  - Admin review / publish / apply path
  - 第二套 case upload family

## 2. New Read Path

- 当前新增 app-facing case detail canonical path：
  - `GET /api/app/exhibition/enterprise-hub/cases/{caseId}`
- 当前 path purpose 固定为：
  - 为 `案例库 -> 继续编辑` 提供稳定单案例 edit carrier
- 当前 path 不得被解释为：
  - `案例库摘要列表` 的重复展开
  - `已发布展示 change draft` 读取入口

### 2.1 Success Body

- 当前 success body 正式冻结为：
  - `EnterpriseHubCaseDetailResponse`
- 当前 `EnterpriseHubCaseDetailResponse` 至少承接：
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
  - `isFeatured`
  - `caseStatus`
- 当前 `caseMediaFileAssetIds` 继续冻结为：
  - 最多 `6` 个

### 2.2 Ownership Rule

- 当前 case detail 继续只承接：
  - 当前 actor 在当前 organization scope 下可维护的 `listing-owned case`
- 当前 path 不得被实现成：
  - `user-owned case detail`
  - `个人案例箱`

## 3. New Write Path

- 当前新增 app-facing case update canonical path：
  - `PUT /api/app/exhibition/enterprise-hub/cases/{caseId}`
- 当前 request body 正式冻结为：
  - `EnterpriseHubUpdateCaseRequest`
- 当前 response body 正式冻结为：
  - `EnterpriseHubCaseUpdateResponse`

### 3.1 Request Body Rule

- 当前 `EnterpriseHubUpdateCaseRequest` 至少承接：
  - `title`
  - `exhibitionType`
  - `city`
  - `eventTime`
  - `summary`
  - `caseCoverFileAssetId`
  - `caseMediaFileAssetIds`
  - `isFeatured`
- 当前 required 字段至少冻结为：
  - `title`
  - `summary`
- 当前 `EnterpriseHubUpdateCaseRequest` 明确不承接：
  - `boardType`

原因：

- `caseId` 已经锚定当前 case truth
- case 归属的 `listing / boardType` 不允许在 update path 中被前端搬迁

### 3.2 Media Rule

- 当前 case media 继续复用 shared upload `init / confirm` family
- 当前不得新增第二套 case media orchestration path
- 当前 `caseCoverFileAssetId` 允许为 `null`
- 当前若 `caseCoverFileAssetId = null` 且存在 media，server 可以继续使用：
  - 首图兜底

### 3.3 Update Response Rule

- 当前 `EnterpriseHubCaseUpdateResponse` 至少承接：
  - `caseId`
  - `caseStatus`

## 4. Published Boundary Rule

- 当前 `GET /cases/{caseId}` 与 `PUT /cases/{caseId}` 只冻结为：
  - `未发布 / draft-editable` 工作台语义下的直接 case continuation path
- 当前不得把这两条 path 偷偷扩成：
  - 已发布展示的 change corridor backdoor

正式裁决：

- 当目标 case 已经进入 `published listing` 所在治理域时：
  - 直接 case detail / case update path 不再是合法 edit carrier
  - 必须切换到 `published change corridor` family

## 5. Error Rule

- `GET /cases/{caseId}` 当前至少必须支持：
  - `AUTH_SESSION_INVALID`
  - `ENTERPRISE_HUB_PERMISSION_DENIED`
  - `ENTERPRISE_HUB_CASE_NOT_FOUND`
- `PUT /cases/{caseId}` 当前至少必须支持：
  - `AUTH_SESSION_INVALID`
  - `ENTERPRISE_HUB_PERMISSION_DENIED`
  - `ENTERPRISE_HUB_CASE_NOT_FOUND`
  - `ENTERPRISE_HUB_CHANGE_CORRIDOR_REQUIRED`

其中：

- `ENTERPRISE_HUB_CHANGE_CORRIDOR_REQUIRED` 的 contract 语义固定为：
  - 当前目标 case 不允许继续走 direct case update，必须进入已发布展示的正式 change corridor

## 6. Relationship With Existing Workbench Contract

- 当前 `EnterpriseHubWorkbenchResponse.cases[]` 继续只承接：
  - `案例库摘要`
- 当前不得继续把 `cases[]` 列表 carrier 膨胀成：
  - 完整 edit carrier
- 当前正式 edit carrier 固定为：
  - `GET /api/app/exhibition/enterprise-hub/cases/{caseId}`

## 7. Formal Conclusion

- 当前正式结论固定为：
  - `案例库继续编辑` contract bundle 已冻结
  - 当前必须补入：
    - `GET /api/app/exhibition/enterprise-hub/cases/{caseId}`
    - `PUT /api/app/exhibition/enterprise-hub/cases/{caseId}`
  - `PUT /cases/{caseId}` 不承接 `boardType`
  - direct case continuation path 只适用于 `未发布 / draft-editable` 语义
  - 已发布展示案例修改不得走 direct case update，必须改走 `published change corridor`
