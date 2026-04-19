---
owner: Codex 总控
status: frozen
purpose: Freeze the package-level controller-review spec bundle for the enterprise_hub application review package, locking the object anchor, Admin seat and route family, Server controller surface, reviewer eligibility boundary, state machine, audit rule, and implementation gate without entering implementation.
layer: L0 SSOT
freeze_date_local: 2026-04-12
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/admin_startup_full_scan_and_mainline_ruling_addendum.md
  - docs/00_ssot/enterprise_hub_v1_app_aligned_freeze_addendum.md
  - apps/admin/src/app/layout.tsx
  - apps/admin/src/app/review/page.tsx
  - apps/admin/src/app/review/change_requests/page.tsx
  - apps/admin/src/app/review/change_requests/[changeRequestId]/page.tsx
  - apps/admin/src/core/auth/route-guard.ts
  - apps/admin/src/core/server/admin-api-runtime.ts
  - apps/admin/src/modules/published_change_review/published-change-review-shell.tsx
  - apps/server/src/modules/enterprise_hub/enterprise-hub-admin.controller.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-admin.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub.presenter.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub.errors.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub.constants.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-truth.controller.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-query.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-workbench.query.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-published-change-admin.service.ts
  - apps/server/src/modules/enterprise_hub/entities/enterprise-application.entity.ts
  - apps/server/src/modules/organization/current-actor-eligibility.service.ts
---

# 《企业入驻审核包 controller review spec bundle》

## 1. 冻结目标与 No-Go 边界

- 本轮唯一对象固定为：
  - `enterprise_hub application review`
- 本轮唯一目标固定为：
  - 冻结企业入驻审核包的 package-level controller review spec
  - 收口对象锚点、Admin 座位、路由家族、Server controller surface、reviewer eligibility、状态机、审计要求、错误码家族与 implementation gate
- 本轮明确不做：
  - implementation
  - patch
  - deploy
  - release-prep
  - launch
- 本轮明确 No-Go：
  - 不得把本包写成 `organization certification review`
  - 不得把本包写成 `content-safety review task`
  - 不得把本包写成 `enterprise_hub published change review/apply`
  - 不得把本包写成 `recommendation-slots` 运营台
  - 不得并入 `risk/security-events`
  - 不得并入 `ticketing`
  - 不得并入 `template_config`

## 2. 对象锚定与非目标

### 2.1 对象锚定

- 当前包固定只指向：
  - `enterprise_hub application review`
- 当前对象中文真义固定为：
  - `企业入驻审核`
- 当前对象的唯一 truth anchor 固定为：
  - `enterprise_application`
- 当前包只承接：
  - application review list
  - application detail aggregate
  - reviewer review command
  - reviewer attribution
  - application review audit append

### 2.2 当前明确不包含

- `organization certification review`
- `content-safety review task`
- `enterprise_hub published change review/apply corridor`
- `enterprise_hub listing publish / offline / freeze`
- `recommendation-slots`
- `appeal`
- `penalty`
- `security event`
- `ticketing`

## 3. 当前代码/运行态扫描结论

### 3.1 Server 当前真实状态

- 当前 `apps/server` 已存在：
  - `GET /server/admin/exhibition/enterprise-hub/applications`
  - `GET /server/admin/exhibition/enterprise-hub/applications/{applicationId}`
  - `POST /server/admin/exhibition/enterprise-hub/applications/{applicationId}/review`
- 当前 `EnterpriseHubAdminController` 同时混载：
  - `applications*`
  - `enterprises/* publish/offline/freeze`
  - `recommendation-slots*`
  - `change-requests*`
- 这说明当前 controller 物理文件存在，但当前对象边界尚未在 controller level 被收干净。
- 当前 `EnterpriseHubAdminService.listApplications / getApplicationDetail / reviewApplication` 没有统一接入：
  - `requireVerifiedCurrentSessionContext(...)`
  - `CurrentActorEligibilityService.requireReviewer(...)`
- 当前 `applications*` family 因而存在真实权限漂移：
  - 管理读路径不是稳定 fail-closed reviewer surface
  - 管理写路径也没有显式 reviewer/super-admin guard
- 当前 `reviewApplication(...)` 命令形态为：
  - 单一路径 `POST .../review`
  - `action` 允许 `approved | revision_required | rejected`
- 当前 application state family 已声明：
  - `draft`
  - `submitted`
  - `under_review`
  - `revision_required`
  - `approved`
  - `rejected`
- 但当前 application 代码里没有真实把 `submitted` 推进到 `under_review` 的实现。
- 因此 `under_review` 当前是 declared-but-dead state，不应被当作已成立能力。
- 当前 `reviewApplication(...)` 仅写入：
  - `applicationStatus`
  - `reviewedAt`
  - `reviewerId`
  - `reviewNote`
  - `rejectionReason`
- 当前未见 append-only application review audit。

### 3.2 Admin 当前真实状态

- 当前 `apps/admin` 已存在 review family 座位：
  - `/review`
  - `/review/change_requests`
  - `/review/organizations`
- 当前座位意义已在代码中明确分离：
  - `/review` = `content-safety review-tasks`
  - `/review/change_requests` = `enterprise_hub published change review/apply`
  - `/review/organizations` = `organization certification review`
- 当前 `apps/admin` 不存在：
  - enterprise_hub application review page
  - enterprise_hub application review shell
  - enterprise_hub application review state
  - enterprise_hub application review actions
  - enterprise_hub application review API client
- 当前企业入驻审核没有真实 Admin 工作台。
- 当前 `route-guard` 对 `/review` 家族已整体生效，这说明：
  - review family 作为受控 Admin review workbench family 已经成立
  - 新包若进入 `/review` 子路由，不需要新开独立权限宪法

### 3.3 当前代码/运行态分类裁决

- 当前 `admin_startup_full_scan_and_mainline_ruling_addendum.md` 已记录：
  - `enterprise_hub applications*` 在云上曾出现未带管理员会话直接 `200`
  - 企业入驻审核当前 `形式存在但内核未成立`
- 当前据此固定分类：
  - `实现缺口`
    - Admin 无企业入驻审核工作台
    - Admin 无对应 transport / state / actions
    - `under_review` 没有真实进入点
  - `权限缺口`
    - `applications*` 管理读路径未统一接入 reviewer guard
    - `applications*` 管理写路径未统一接入 reviewer guard
  - `部署缺口`
    - 本轮 docs-first 不单独认定新的 cloud deploy gap
    - 当前 cloud 暴露的 `200 without admin session` 与本地源码权限漂移一致，因此先归类为权限缺口，不伪装成单纯部署缺页问题

## 4. truth owner 与边界归属

- 当前单选结论固定为：
  - `A. Admin 只消费和发命令，不改写真相`
- `Server` 继续是唯一 truth owner：
  - `enterprise_application`
  - `enterprise_listing`
  - application state machine
  - reviewer attribution
  - audit append
- `Admin` 当前只允许：
  - 读取受控 `Server Admin API`
  - 发出 application review 命令
- `Admin` 当前不得：
  - 直接编辑 application truth
  - 直接编辑 listing truth
  - 直接承担 application review state persistence
  - 直接承担 audit truth
- `App` 侧 workbench / create / submit / status read 继续是企业自服务面。
- `BFF` 不介入本包。

## 5. Admin 工作台 seat meaning 裁决

### 5.1 `/review` 家族归属裁决

- 当前单选结论固定为：
  - `A. 企业入驻审核进入 /review 子路由`

### 5.2 与 published change 是否共用工作台家族

- 当前单选结论固定为：
  - `B. 企业入驻审核与 published change review 完全分家族`

### 5.3 seat meaning 固定口径

- `/review`
  - 继续只承接 `content-safety review-tasks` 主座位
- `/review/change_requests`
  - 继续只承接 `enterprise_hub published change review/apply` 座位
- `/review/organizations`
  - 继续只承接 `organization certification review` 座位
- `/review/enterprise_hub_applications`
  - 固定承接 `enterprise_hub application review` 列表座位
- `/review/enterprise_hub_applications/{applicationId}`
  - 固定承接 `enterprise_hub application review` 详情与 review 命令座位

### 5.4 为什么不并入 `/review/change_requests`

- `change_requests` 当前明确属于：
  - 已发布变更治理走廊
- `applications` 当前明确属于：
  - 企业入驻申请审核走廊
- 两者对象不同：
  - `enterprise_application` 不是 `enterprise_change_request`
- 两者状态机不同：
  - `approved` application 不等于 `applied` change request
- 两者命令副作用不同：
  - application review 不是 live apply

## 6. Admin route family 冻结

- 当前企业入驻审核的 Admin 路由家族固定为：
  - `GET /review/enterprise_hub_applications`
  - `GET /review/enterprise_hub_applications/{applicationId}`
- 当前列表 query family 最小只允许：
  - `page`
  - `pageSize`
  - `applicationStatus`
  - `boardType`
- 当前 detail route param 固定为：
  - `applicationId`
- 当前明确不允许：
  - 复用 `/review` 主座位的 `taskId`
  - 复用 `published change` 的 `changeRequestId`
  - 复用 `organization certification review` 的 `organizationId`
  - 复用 `recommendation-slots` 的运营 query

## 7. Server controller surface 冻结

- 当前包只冻结以下 Server Admin path family：
  - `GET /server/admin/exhibition/enterprise-hub/applications`
  - `GET /server/admin/exhibition/enterprise-hub/applications/{applicationId}`
  - `POST /server/admin/exhibition/enterprise-hub/applications/{applicationId}/review`
- 当前 list query 最小固定为：
  - `page`
  - `pageSize`
  - `applicationStatus`
  - `boardType`
- 当前 detail response 最小固定为：
  - `application`
  - `enterprise`
  - `profiles`
  - `cases`
  - `certifications`
  - `contacts`
- 当前 `application` 最小字段固定为：
  - `applicationId`
  - `enterpriseId`
  - `applyBoardType`
  - `applicationStatus`
  - `rejectionReason`
  - `submittedAt`
  - `reviewedAt`
- 当前 review command 继续固定为单一路径：
  - `POST .../review`
- 当前 review command body 最小固定为：
  - `action`
  - `reason`
  - `reviewNote`
- 当前 `action` 只允许：
  - `approved`
  - `revision_required`
  - `rejected`
- 当前 `reason` 只在以下 action 必填：
  - `revision_required`
  - `rejected`
- 当前 `reviewNote` 为可选补充说明。
- 当前明确不把以下 controller surface 并入本包：
  - `enterprises/:enterpriseId/publish`
  - `enterprises/:enterpriseId/offline`
  - `enterprises/:enterpriseId/freeze`
  - `recommendation-slots*`
  - `change-requests*`

## 8. reviewer eligibility 与权限矩阵

- 当前单选结论固定为：
  - `A. enterprise_hub applications 的管理读路径必须统一接入 reviewer/super-admin guard`

### 8.1 reviewer eligibility 固定口径

- reviewer eligibility 固定为：
  - verified current-session context
  - active membership truth
  - role key in `platform_reviewer | platform_super_admin`
  - platform organization membership

### 8.2 权限矩阵冻结

- `GET /server/admin/exhibition/enterprise-hub/applications`
  - reviewer/super-admin only
- `GET /server/admin/exhibition/enterprise-hub/applications/{applicationId}`
  - reviewer/super-admin only
- `POST /server/admin/exhibition/enterprise-hub/applications/{applicationId}/review`
  - reviewer/super-admin only
- `GET /server/exhibition/enterprise-hub/applications/{applicationId}`
  - 继续是 app-side 当前组织 scope 自读路径
- `POST /server/exhibition/enterprise-hub/applications`
  - 继续是 app-side 组织作用域下的 create path
- `POST /server/exhibition/enterprise-hub/applications/{applicationId}/submit`
  - 继续是 app-side submit path

### 8.3 fail-closed 规则冻结

- 无 verified current-session 不得进入 admin list/detail/review
- 无 reviewer eligibility 不得进入 admin list/detail/review
- raw header hints 不得直接放行 reviewer 权限
- `ENTERPRISE_HUB_PERMISSION_DENIED` 继续只用于 app-side organization-scope deny
- reviewer admin path 的 fail-closed 应先落入统一 auth family，而不是放任 domain path 直接裸读

## 9. 状态机与命令表

### 9.1 application state family 固定

- application state family 固定为：
  - `draft`
  - `submitted`
  - `under_review`
  - `revision_required`
  - `approved`
  - `rejected`

### 9.2 review 包内可见状态机固定

- app create / app edit：
  - `draft`
- app submit：
  - `draft -> submitted`
- reviewer detail 首次承接：
  - `submitted -> under_review`
- reviewer approve：
  - `under_review -> approved`
- reviewer request revision：
  - `under_review -> revision_required`
- reviewer reject：
  - `under_review -> rejected`

### 9.3 兼容规则冻结

- 若 review command 命中 `submitted`：
  - 实现必须先把它规范化视为 `under_review` 再执行终态迁移
- 当前不得继续保留：
  - declared-but-dead `under_review`
- 当前不在本包内扩写：
  - applicant resubmit UX
  - live publish
  - recommendation placement

### 9.4 命令副作用固定

- `approved`
  - set `applicationStatus = approved`
  - set `reviewedAt`
  - set `reviewerId`
  - clear `rejectionReason`
  - preserve optional `reviewNote`
  - 不得自动 publish listing
  - 不得自动写 recommendation slot
  - 不得自动改写 `organization certification` truth
- `revision_required`
  - set `applicationStatus = revision_required`
  - set `reviewedAt`
  - set `reviewerId`
  - persist `rejectionReason = reason`
  - persist optional `reviewNote`
  - 不得自动 delete listing
  - 不得自动 freeze listing
- `rejected`
  - set `applicationStatus = rejected`
  - set `reviewedAt`
  - set `reviewerId`
  - persist `rejectionReason = reason`
  - persist optional `reviewNote`
  - 不得自动 publish/offline/freeze listing
  - 不得自动触发 `published change` corridor

## 10. 审计与留痕要求

- 当前 enterprise_hub application review 必须追加 append-only audit。
- 当前最低审计 action 固定为：
  - `EnterpriseHubApplicationApproved`
  - `EnterpriseHubApplicationRevisionRequired`
  - `EnterpriseHubApplicationRejected`
- 当前必须保留的审计字段固定为：
  - `objectType`
  - `objectId`
  - `objectNo`
  - `enterpriseId`
  - `organizationId`
  - `actorId`
  - `actorRole`
  - `beforeState`
  - `afterState`
  - `reason`
  - `reviewNote`
  - `requestId`
  - `traceId`
  - `occurredAt`
- 当前 `objectType` 固定为：
  - `enterprise_hub_application`
- 当前 `objectNo` 在尚无独立业务编号前，固定以 `applicationId` 承接。
- 当前明确写死：
  - `reviewApplication(...)` 现状没有 append-only audit，不得被写成“已具备审计闭环”

## 11. 错误码与拒绝理由

### 11.1 auth/session 家族冻结

- reviewer boundary 继续使用统一 auth family：
  - `AUTH_SESSION_INVALID`
  - `AUTH_PERMISSION_INSUFFICIENT`
  - `AUTH_RESOURCE_UNAVAILABLE`

### 11.2 application review domain 家族冻结

- 当前 domain error family 最小固定为：
  - `ENTERPRISE_HUB_APPLICATION_NOT_FOUND`
  - `ENTERPRISE_HUB_INVALID_STATE_TRANSITION`
  - `ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS`
- 当前不在本包伪造：
  - `ORG_REVIEW_*`
  - `CHANGE_REQUEST_*`
  - `RECOMMENDATION_SLOT_*`

### 11.3 拒绝理由族冻结

- 当 `action = revision_required | rejected` 时：
  - `reason` 必填
- `reason` 家族固定为：
  - `basic_info_incomplete`
  - `profile_incomplete`
  - `case_incomplete`
  - `contact_incomplete`
  - `certification_not_approved`
  - `other`
- `reviewNote`：
  - 可选
  - 只承接补充说明
- 当前明确不允许：
  - 把 `reviewNote` 直接冒充 `rejectionReason`
  - 使用 `published change` 的 `changeStatus` 文案
  - 使用 `organization certification review` 的 `reason/note` 命名偷渡对象语义

## 12. 本地 / 云上验证要求

### 12.1 本地

- `apps/server`
  - enterprise_hub application review controller/service targeted tests
  - reviewer fail-closed tests for `applications*`
  - state transition tests for `submitted / under_review / revision_required / approved / rejected`
  - audit append tests
  - `tsc --noEmit`
  - `npm run build`
- `apps/admin`
  - application review route tests
  - application review API client transport tests
  - seat separation tests
  - route guard tests
  - `tsc --noEmit`
  - `npm run build`

### 12.2 云上

- chosen admin route 匿名访问必须：
  - `307 -> /login`
- `server/admin/exhibition/enterprise-hub/applications*` 未携带合法管理员 carrier 必须：
  - fail-closed
- chosen admin route 登录态访问必须：
  - 不是 `404`
  - 不是 `content-safety` 主座位
  - 不是 `published change` 座位
  - 不是 `organization certification review` 座位
- current production-like runtime 不得用真实对象执行 write smoke，除非有 release-safe target。

## 13. Go / No-Go for implementation

### 13.1 当前结论

- 当前仅凭本 spec bundle：
  - `No-Go for direct implementation dispatch in this round`

### 13.2 后续 Go 条件

- 当前 package-level spec 已冻结
- 必须先补一轮 controller review conclusion
- enterprise_hub application review 的 Admin route family 必须先以本 bundle 为唯一真源冻结
- `applications*` reviewer guard 必须被认定为 implementation 硬约束
- published change / recommendation-slots 必须继续被排除在本包外

### 13.3 veto 条件

- 不得把企业入驻审核实现成 `published change review`
- 不得把企业入驻审核实现成 generic review task union
- 不得保留 `applications*` 裸读或非 reviewer 可读
- 不得把 `approve` 写成 `publish`
- 不得把 `recommendation-slots` 并入本包
- 不得把“当前有 API”误写成“当前已可运营”

## 14. Formal Conclusion

- `enterprise_hub application review` 当前 package-level controller review spec bundle 已冻结。
- 当前唯一对象固定为：
  - `enterprise onboarding review`
- 当前唯一 Admin seat family 已冻结为：
  - `/review/enterprise_hub_applications*`
- 当前 `/review` 主座位继续只承接内容安全审核。
- 当前 `/review/change_requests` 继续只承接 published change review/apply。
- 当前 `applications*` 管理读写路径必须统一进入 reviewer/super-admin fail-closed boundary。
- 当前企业入驻审核包不得把 published change、recommendation-slots、organization certification review 混成一个后台对象。
- 当前下一步不得直接进入 implementation dispatch；必须先做 controller review conclusion。
