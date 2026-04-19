# enterprise_display_case_library_continuation_bff_execution_receipt_addendum

## 1. 修改文件清单

- `apps/bff/src/routes/enterprise_hub/app-enterprise-hub.controller.ts`
- `apps/bff/src/routes/enterprise_hub/enterprise-hub.controller.ts`
- `apps/bff/src/routes/enterprise_hub/enterprise-hub.service.ts`
- `apps/bff/src/routes/enterprise_hub/enterprise-hub.read-model.ts`
- `apps/bff/test/enterprise-hub-case-continuation-transport.test.cjs`

## 2. 每个修改点对应的冻结事实编号

- 冻结事实 `1`
  - `GET /api/app/exhibition/enterprise-hub/cases/{caseId}`
  - `PUT /api/app/exhibition/enterprise-hub/cases/{caseId}`
  - 已在 app-facing controller 与 internal controller 同步补入
- 冻结事实 `2`
  - `EnterpriseHubService` 必须补入 `getCaseDetail()` / `updateCase()`
  - 已补齐 direct continuation 的 GET / PUT transport
- 冻结事实 `3`
  - `GET /cases/{caseId}` 必须返回 case detail carrier
  - `PUT /cases/{caseId}` 只返回最小 update ack
  - 已分别收口到：
    - `toEnterpriseHubCaseDetailResponse()`
    - `toEnterpriseHubCaseUpdateResponse()`
- 冻结事实 `4`
  - direct case update 至少要收口 `AUTH_SESSION_INVALID` / `ENTERPRISE_HUB_PERMISSION_DENIED` / `ENTERPRISE_HUB_CASE_NOT_FOUND` / `ENTERPRISE_HUB_CHANGE_CORRIDOR_REQUIRED`
  - 已在 `updateCase()` 的 transport error normalize 中补齐

## 3. GET /cases/{caseId} BFF 暴露说明

- 新增 canonical app-facing path：
  - `GET /api/app/exhibition/enterprise-hub/cases/{caseId}`
- 同步新增 internal mirror：
  - `GET /bff/exhibition/enterprise-hub/cases/{caseId}`
- 上游转发：
  - `GET /server/exhibition/enterprise-hub/cases/{caseId}`
- BFF 只做：
  - session / current organization scope transport
  - response shaping
  - controlled error mapping

## 4. PUT /cases/{caseId} BFF 暴露说明

- 新增 canonical app-facing path：
  - `PUT /api/app/exhibition/enterprise-hub/cases/{caseId}`
- 同步新增 internal mirror：
  - `PUT /bff/exhibition/enterprise-hub/cases/{caseId}`
- 上游转发：
  - `PUT /server/exhibition/enterprise-hub/cases/{caseId}`
- 当前 direct update 只透传冻结字段：
  - `title`
  - `exhibitionType`
  - `city`
  - `eventTime`
  - `summary`
  - `caseCoverFileAssetId`
  - `caseMediaFileAssetIds`
  - `isFeatured`
- update response 只返回：
  - `caseId`
  - `caseStatus`

## 5. boardType 禁入说明

- `updateCase()` 当前显式拒绝 `boardType`
- 若请求体带入 `boardType`，BFF 直接 fail-closed：
  - `400 ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS`
  - `当前继续编辑不接受 boardType，请直接编辑当前案例内容。`
- 这样可以避免把 case 归属的 `listing / boardType` 从 direct update path 重新打开

## 6. 错误映射说明

- `GET /cases/{caseId}`
  - `401 -> AUTH_SESSION_INVALID`
  - `403 -> ENTERPRISE_HUB_PERMISSION_DENIED`
  - `404 -> ENTERPRISE_HUB_CASE_NOT_FOUND`
- `PUT /cases/{caseId}`
  - `400 -> ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS`
  - `401 -> AUTH_SESSION_INVALID`
  - `403 -> ENTERPRISE_HUB_PERMISSION_DENIED`
  - `404 -> ENTERPRISE_HUB_CASE_NOT_FOUND`
  - `409 -> ENTERPRISE_HUB_CHANGE_CORRIDOR_REQUIRED`
- 当前 direct continuation 与 published corridor 继续分离：
  - published case direct update 命中 `ENTERPRISE_HUB_CHANGE_CORRIDOR_REQUIRED`
  - BFF 未把它改写成其他状态机语义

## 7. 新增或更新的测试清单

- 新增：
  - `apps/bff/test/enterprise-hub-case-continuation-transport.test.cjs`
- 覆盖：
  - 两个 controller 都暴露 `GET /cases/{caseId}` 与 `PUT /cases/{caseId}`
  - `getCaseDetail()` 正确转发
  - `updateCase()` 正确转发
  - `updateCase()` 不接受 `boardType`
  - `ENTERPRISE_HUB_CHANGE_CORRIDOR_REQUIRED` 正确透传到 app-facing surface

## 8. build / test 结果

- `cd apps/bff && npm run build`
  - `PASS`
- `cd apps/bff && node --test test/enterprise-hub-case-continuation-transport.test.cjs`
  - `PASS`
  - `4/4`

## 9. 当前剩余未闭合项

- 在当前 BFF package 范围内：`none`
- 当前 direct case continuation app-facing surface 已闭合
- `changes/current` 仍未实现，且本轮未触碰

## 10. 是否允许进入 Flutter package

- `yes`
- 当前含义仅为：
  - Flutter 可以继续接入 direct case continuation 的 canonical BFF carrier
  - 不表示 published change corridor 已一并开放
