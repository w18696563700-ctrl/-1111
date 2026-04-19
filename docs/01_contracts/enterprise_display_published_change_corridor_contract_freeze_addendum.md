---
owner: Codex 总控
status: frozen
purpose: Freeze the app-facing contract bundle for the enterprise display published-change corridor before any implementation dispatch.
layer: L1 Contracts
freeze_date_local: 2026-04-11
inputs_canonical:
  - docs/00_ssot/enterprise_display_published_change_corridor_truth_freeze_addendum.md
  - docs/00_ssot/enterprise_display_case_library_continuation_truth_freeze_addendum.md
  - docs/00_ssot/enterprise_display_case_continuation_and_published_change_corridor_stage_gate_checklist_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 企业展示已发布修改通道 Contracts 冻结单

## 1. Scope

- 当前 contracts freeze 只覆盖：
  - `已发布展示` 在 app 侧进入正式 change corridor 的 canonical contract family
  - `已发布展示变更` 在 Admin / 治理侧的 review / revision / approve / reject / apply canonical contract family
- 当前不覆盖：
  - 修改频次与会员配额
  - runtime implementation 细则
  - 直接代码实现

## 2. Canonical Path Family

当前正式 contract family 冻结为：

1. `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current`
2. `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/basic`
3. `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/profiles/company`
4. `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/profiles/factory`
5. `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/profiles/supplier`
6. `POST /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/cases`
7. `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/cases/{caseId}`
8. `DELETE /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/cases/{caseId}`
9. `POST /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/submit`
10. `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/status`

正式裁决：

- 当前 published change corridor 一律锚定到：
  - `enterpriseId`
- 当前 corridor family 一律只承接：
  - `current active change carrier`
- 当前不得额外发明：
  - `user-owned change draft`
  - 第二套 published-edit upload family

## 3. Open Current Change Carrier

- 当前读取当前活动中 change carrier 的 canonical path 固定为：
  - `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current`
- 当前 success body 正式冻结为：
  - `EnterpriseHubPublishedChangeWorkbenchResponse`

### 3.1 Response Body Rule

- 当前 `EnterpriseHubPublishedChangeWorkbenchResponse` 至少承接：
  - `enterpriseId`
  - `boardType`
  - `liveSnapshot`
  - `currentChangeRequest`
  - `basic`
  - `boardProfile`
  - `primaryContact`
  - `cases`
  - `changeReadiness`

### 3.2 Live Snapshot Rule

- 当前 `liveSnapshot` 至少承接：
  - `enterpriseStatus`
  - `displayStatus`
  - `publishedAt`
- 当前 `liveSnapshot` 的唯一作用是：
  - 告诉前端当前线上展示仍是哪个公开 truth
- 当前不得把 `liveSnapshot` 伪装成：
  - 可直接编辑并立刻生效的 carrier

### 3.3 Current Change Request Rule

- 当前 `currentChangeRequest` 至少承接：
  - `changeRequestId`
  - `changeStatus`
  - `submittedAt`
  - `reviewedAt`
  - `rejectionReason`
- 当前若尚不存在活动中的 change request：
  - `currentChangeRequest` 允许为 `null`
- 当前 `GET /changes/current` 不得带副作用创建 state

### 3.4 Change Readiness Rule

- 当前 `changeReadiness` 至少承接：
  - `draftEditable`
  - `submitReady`
  - `blockers`

## 4. Save-Draft Path Rule

正式裁决：

- 已发布展示下，所有 `保存修改` 只允许写入：
  - `current active change carrier`
- 这些 save path 不得直接覆盖：
  - 当前 live published listing

### 4.1 Basic Save

- 当前 basic save canonical path 固定为：
  - `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/basic`
- 当前 request body 继续复用：
  - `EnterpriseHubUpdateBasicRequest`

### 4.2 Profile Save

- 当前 board profile save canonical path 固定为：
  - `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/profiles/company`
  - `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/profiles/factory`
  - `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/profiles/supplier`
- 当前 request body 继续复用：
  - `EnterpriseHubUpdateCompanyProfileRequest`
  - `EnterpriseHubUpdateFactoryProfileRequest`
  - `EnterpriseHubUpdateSupplierProfileRequest`

### 4.3 Case Save

- 当前 corridor 内新增案例 canonical path 固定为：
  - `POST /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/cases`
- 当前 corridor 内更新案例 canonical path 固定为：
  - `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/cases/{caseId}`
- 当前 corridor 内删除案例 canonical path 固定为：
  - `DELETE /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/cases/{caseId}`

当前 request body 冻结为：

- `EnterpriseHubChangeCreateCaseRequest`
- `EnterpriseHubUpdateCaseRequest`

其中：

- `EnterpriseHubChangeCreateCaseRequest` 至少承接：
  - `title`
  - `exhibitionType`
  - `city`
  - `eventTime`
  - `summary`
  - `caseCoverFileAssetId`
  - `caseMediaFileAssetIds`
  - `isFeatured`
- 当前 `EnterpriseHubChangeCreateCaseRequest` 明确不承接：
  - `boardType`

原因：

- 当前 published change corridor 已由 `enterpriseId` 锚定 listing 与 board
- 不允许前端在 corridor create-case body 中再搬一次 `boardType`

## 5. Submit And Status Rule

- 当前提交当前变更 canonical path 固定为：
  - `POST /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/submit`
- 当前 submit request body 正式冻结为：
  - `EnterpriseHubSubmitChangeRequest`
- 当前 `EnterpriseHubSubmitChangeRequest` 最小字段固定为：
  - `confirm: boolean`

- 当前查看变更状态 canonical path 固定为：
  - `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/status`
- 当前 status response body 正式冻结为：
  - `EnterpriseHubChangeStatusResponse`

### 5.1 Change Status Enum

- 当前正式冻结新增枚举：
  - `EnterpriseHubChangeRequestStatus`
- 当前枚举值至少包括：
  - `draft`
  - `submitted`
  - `under_review`
  - `revision_required`
  - `approved`
  - `rejected`
  - `applied`

### 5.2 Status Response Rule

- 当前 `EnterpriseHubChangeStatusResponse` 至少承接：
  - `enterpriseId`
  - `changeRequestId`
  - `changeStatus`
  - `submittedAt`
  - `reviewedAt`
  - `rejectionReason`

## 6. Admin / 治理 Canonical Contract Family

当前 Admin / 治理承接面的 canonical path family 正式冻结为：

1. `GET /server/admin/exhibition/enterprise-hub/change-requests`
2. `GET /server/admin/exhibition/enterprise-hub/change-requests/{changeRequestId}`
3. `POST /server/admin/exhibition/enterprise-hub/change-requests/{changeRequestId}/review`
4. `POST /server/admin/exhibition/enterprise-hub/change-requests/{changeRequestId}/apply`

正式裁决：

- 当前 review queue read 只允许走：
  - `GET /server/admin/exhibition/enterprise-hub/change-requests`
- 当前 review detail read 只允许走：
  - `GET /server/admin/exhibition/enterprise-hub/change-requests/{changeRequestId}`
- 当前 approve / revision_required / rejected 三种治理决策只允许收口到：
  - `POST /server/admin/exhibition/enterprise-hub/change-requests/{changeRequestId}/review`
- 上述 review path 必须通过单一 `action` 枚举承接：
  - `approved`
  - `revision_required`
  - `rejected`
- 当前 apply live listing 只允许走：
  - `POST /server/admin/exhibition/enterprise-hub/change-requests/{changeRequestId}/apply`
- 明确禁止：
  - 发明第二条 published-edit 治理主链
  - 把 `approve` 与 `apply` 混成同一步

## 7. Admin Request / Response Rule

### 7.1 Queue Read

- 当前 review queue response 正式冻结为：
  - `EnterpriseHubAdminChangeRequestListResponse`
- 当前 list item 至少承接：
  - `changeRequestId`
  - `enterpriseId`
  - `boardType`
  - `enterpriseName`
  - `changeStatus`
  - `submittedAt`
  - `reviewedAt`
  - `appliedAt`

### 7.2 Detail Read

- 当前 review detail response 正式冻结为：
  - `EnterpriseHubAdminChangeRequestDetailResponse`
- 当前 detail 至少承接：
  - `changeRequest`
  - `enterprise`
  - `liveSnapshot`
  - `basic`
  - `boardProfile`
  - `primaryContact`
  - `cases`
- 当前 `changeRequest` 至少承接：
  - `changeRequestId`
  - `enterpriseId`
  - `boardType`
  - `changeStatus`
  - `submittedAt`
  - `reviewedAt`
  - `appliedAt`
  - `reviewNote`

### 7.3 Review Action

- 当前 review request 正式冻结为：
  - `EnterpriseHubAdminChangeReviewRequest`
- 最小字段固定为：
  - `action`
  - `reviewNote`
- 当前 review response 正式冻结为：
  - `EnterpriseHubAdminChangeReviewResponse`
- 最小返回至少承接：
  - `changeRequestId`
  - `changeStatus`
  - `reviewedAt`

### 7.4 Apply Action

- 当前 apply response 正式冻结为：
  - `EnterpriseHubAdminChangeApplyResponse`
- 最小返回至少承接：
  - `changeRequestId`
  - `enterpriseId`
  - `changeStatus`
  - `appliedAt`
  - `enterpriseStatus`
  - `displayStatus`

## 8. Change Status Ownership And Transition Rule

当前 `EnterpriseHubChangeRequestStatus` 的状态流转归属正式冻结如下：

- `draft`
  - 由 app-facing `changes/current` save family 承接
  - 当前由用户侧保存修改形成或继续维护
- `submitted`
  - 由 app-facing：
    - `POST /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/submit`
    触发
- `under_review`
  - 由 `Server / Admin` 治理 intake 承接
  - 这是 review queue 的治理态，不由 Flutter 本地推导
- `revision_required`
  - 由 Admin：
    - `POST /server/admin/exhibition/enterprise-hub/change-requests/{changeRequestId}/review`
    且 `action=revision_required` 触发
- `approved`
  - 由 Admin：
    - `POST /server/admin/exhibition/enterprise-hub/change-requests/{changeRequestId}/review`
    且 `action=approved` 触发
- `rejected`
  - 由 Admin：
    - `POST /server/admin/exhibition/enterprise-hub/change-requests/{changeRequestId}/review`
    且 `action=rejected` 触发
- `applied`
  - 由 Admin：
    - `POST /server/admin/exhibition/enterprise-hub/change-requests/{changeRequestId}/apply`
    触发

正式裁决：

- `approve` 只代表 review 通过，不代表 live listing 已更新
- `apply` 才是把 approved snapshot 写入 live listing 的唯一治理动作
- `revision_required` 后，用户侧继续回到同一条 `changeRequestId` 上修改并可重新提交

## 9. App-facing 与 Admin-facing 对接规则

正式裁决：

- `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/status`
  必须回读与 Admin 治理面同一套：
  - `EnterpriseHubChangeRequestStatus`
- 当前对接关系固定为：
  - app-facing `submitted` 对应 Admin queue 的待进入治理态
  - app-facing `under_review` 对应 Admin review 处理中态
  - app-facing `revision_required` 对应 Admin 已退回修改态
  - app-facing `approved` 对应 Admin 已审核通过但尚未 apply 的态
  - app-facing `applied` 对应 live listing 已完成更新态
- `revision_required` 返回用户侧时：
  - `GET /changes/current` 继续锚定同一条当前 change carrier
  - 用户可继续修改并再次 `submit`
- `apply` 完成后：
  - live listing 必须更新为当前 approved change snapshot
  - 当前 public list / detail 后续读取必须以新 live listing truth 为准

## 10. Availability, Error, And Prohibition Rule

- 当前 corridor family 只适用于：
  - `已发布展示` 的正式修改通道
- 当前 corridor family 不适用于：
  - `未发布 / draft-editable` 展示档

当前至少必须支持的 controlled error 包括：

- `AUTH_SESSION_INVALID`
- `ENTERPRISE_HUB_PERMISSION_DENIED`
- `ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND`
- `ENTERPRISE_HUB_CHANGE_CORRIDOR_NOT_AVAILABLE`

其中：

- `ENTERPRISE_HUB_CHANGE_CORRIDOR_NOT_AVAILABLE` 的语义固定为：
  - 当前 enterprise 不处于 published-governed corridor 语义下，前端不得误走 published change family

明确禁止：

- 已发布修改绕过治理直接进入 live listing
- Admin review 没有 formal carrier、只靠口头约定
- `approve` 与 `apply` 被混写为一个动作

## 11. Relationship With Direct Workbench Paths

正式裁决：

- 当前 direct workbench save family 继续只承接：
  - `未发布 / draft-editable` 直接编辑
- 当前 published change corridor family 才承接：
  - `已发布展示` 的保存修改 / 提交变更

明确禁止：

- 让 `PUT /enterprises/{enterpriseId}/basic`
  继续伪装成已发布展示的直改线上 path
- 让 `PUT /cases/{caseId}`
  继续伪装成已发布案例的直改线上 path

## 12. Formal Conclusion

- 当前正式结论固定为：
  - `已发布展示修改通道` contract bundle 已冻结
  - `changes/current` 是唯一 app-facing current carrier family
  - `change-requests` 是唯一 Admin / 治理 review 与 apply carrier family
  - `GET /changes/current` 只读，不创建 state
  - 已发布展示下的 `保存修改` 与 `提交变更` 必须全部进入 `changes/current` family
  - Admin 侧的 `review` 与 `apply` 现已具有 formal contract owner，且两步不得混写
  - 直接工作台 save family 不再允许承担 published change 语义
