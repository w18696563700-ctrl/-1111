---
owner: Codex 总控
status: frozen
purpose: Freeze the app-facing contract bundle for the current enterprise display workbench, including the new workbench read path and the existing write path family.
layer: L1 Contracts
freeze_date_local: 2026-04-10
inputs_canonical:
  - docs/00_ssot/enterprise_display_chain_single_source_of_truth_freeze_addendum.md
  - docs/00_ssot/enterprise_display_workbench_v1_truth_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 企业展示工作台 V1 Contracts 冻结单

## 1. Scope

- 当前 contracts freeze 只覆盖：
  - `GET /api/app/exhibition/enterprise-hub/workbench`
  - 既有 enterprise-hub 工作台 write path family
- 当前不覆盖：
  - Admin publish/offline/freeze 路径
  - `个人/团队` 新 contract

## 2. New Read Path

- 当前新增 app-facing path：
  - `GET /api/app/exhibition/enterprise-hub/workbench`
- 当前 `GET /workbench` query truth 必须显式包含：
  - `boardType` required
- 当前 success body 必须至少包含：
  - `organizationId`
  - `enterpriseId`
  - `boardType`
  - `latestApplication`
  - `basic`
  - `boardProfile`
  - `primaryContact`
  - `cases`
  - `certification`
  - `readiness`
- 当前 workbench 仍继续复用：
  - `POST /api/app/file/upload/init`
  - `POST /api/app/file/upload/confirm`
  这组 shared upload path，不新开第二套企业上传 family。

## 3. Workbench Read Field Rule

- `latestApplication` 当前至少承接：
  - `applicationId`
  - `applicationStatus`
  - `submittedAt`
  - `reviewedAt`
  - `rejectionReason`
- `basic` 当前按基础资料字段面回读。
- 当前普通保存联系人最小 contract patch 只补入 write path：
  - `contactName`
  - `contactMobile`
- 当前 workbench 联系人 read 继续由：
  - `primaryContact.contactName`
  - `primaryContact.mobile`
  承接。
- `basic.fullIntro` 当前 contract 上限冻结为：
  - `2000`
- `boardProfile` 当前按既有：
  - `EnterpriseHubCompanyProfile`
  - `EnterpriseHubFactoryProfile`
  - `EnterpriseHubSupplierProfile`
  三选一回读。
- 其中 factory profile 当前额外承接：
  - `showcaseImageFileAssetIds`
- `primaryContact` 当前至少承接：
  - `contactName`
  - `mobile`
  - `wechat`
  - `phone`
  - `email`
  - `position`
  - `isPrimary`
  - `visibleToPublic`
- `cases` 当前至少承接：
  - `caseId`
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
- `caseMediaFileAssetIds` 当前每案最多允许：
  - `6`
- `certification` 当前至少承接：
  - `certificationStatus`
  - `legalName`
  - `uscc`
  - `licenseFileId`
  - `submittedAt`
  - `reviewedAt`
  - `rejectReason`
- `readiness` 当前至少承接：
  - `hasApplication`
  - `draftEditable`
  - `basicCompleted`
  - `profileCompleted`
  - `hasCase`
  - `hasContact`
  - `certificationApproved`
  - `submitReady`
  - `blockers`

## 4. Existing Write Family Confirmation

- 当前 write family 继续冻结为：
  - shared upload init / confirm
  - create application
  - update basic
  - update board profile
  - create case
  - delete case
  - submit application
  - get application status
- 当前 write family 不新增：
  - case update
  - listing publish/offline
  - media asset orchestration path
- 当前 `EnterpriseHubUpdateBasicRequest` 现在允许普通保存链最小承接：
  - `contactName`
  - `contactMobile`
- 上述最小补丁当前只覆盖工作台普通保存 UI 已暴露字段，不扩展到：
  - `wechat`
  - `phone`
  - `email`
  - `position`
- 但当前 write 细则新增：
  - `EnterpriseHubUpdateFactoryProfileRequest.showcaseImageFileAssetIds`
  - `EnterpriseHubCreateCaseRequest.caseCoverFileAssetId` 允许为空，由 server 默认首图兜底
  - `EnterpriseHubCreateCaseRequest.caseMediaFileAssetIds` 最多 6 个

## 5. Error Rule

- `GET /workbench` 当前必须至少支持：
  - `AUTH_SESSION_INVALID`
  - `ENTERPRISE_HUB_PERMISSION_DENIED`
- 当前不得把组织 scope 缺失包装成成功空壳。

## 6. Formal Conclusion

- 当前正式结论固定为：
  - `enterprise display workbench v1` contract bundle 已冻结
  - `workbench` read path 必须带 `boardType` query truth
  - 写路径继续复用既有 enterprise-hub family，并按当前 runtime truth 承接 `delete case`
  - generated contract projection 的唯一 formal owner 固定为 `packages/contracts`
  - `apps/bff/src/shared/generated/*` 只允许作为迁移中的 legacy asset，并必须走退役，不得长期并存
