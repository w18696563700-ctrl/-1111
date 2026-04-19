---
owner: Codex 总控
status: frozen
purpose: Freeze the package-level controller-review spec bundle for the enterprise certification review package, locking the object anchor, Admin seat and route family, Server controller surface, permission boundary, and implementation gate without entering implementation.
layer: L0 SSOT
freeze_date_local: 2026-04-12
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/admin_startup_full_scan_and_mainline_ruling_addendum.md
  - docs/00_ssot/enterprise_cert_review_implementation_dispatch_plan_addendum.md
  - docs/00_ssot/s1_r04_certification_minimal_review_ops_closure_controller_review_spec_bundle_addendum.md
  - docs/00_ssot/s1_r04_certification_minimal_review_ops_closure_controller_review_conclusion_addendum.md
  - docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md
  - docs/05_admin/account_and_enterprise_certification_rules_v1_admin_surface_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/01_contracts/error_codes.yaml
  - apps/admin/src/app/layout.tsx
  - apps/admin/src/app/review/page.tsx
  - apps/admin/src/core/auth/route-guard.ts
  - apps/admin/src/modules/review/review-shell.tsx
  - apps/server/src/modules/review/organization-review.controller.ts
  - apps/server/src/modules/review/organization-review-query.service.ts
  - apps/server/src/modules/review/organization-review-write.service.ts
  - apps/server/src/modules/review/review.errors.ts
  - apps/server/src/modules/organization/current-actor-eligibility.service.ts
---

# 《企业认证审核包 controller review spec bundle》

## 1. 冻结目标与 No-Go 边界

- 本轮唯一对象固定为：
  - `organization certification review`
- 本轮唯一目标固定为：
  - 冻结企业认证审核包的 package-level controller review spec
  - 收口 seat / route / controller / permission / audit / error family / implementation gate
- 本轮明确不做：
  - implementation
  - deploy
  - release-prep
  - launch

## 2. 上游固定约束

- 当前平台主线仍固定为：
  - `阶段3｜Admin 最小运营与治理闭环`
- 当前后台启动扫描裁决已写死：
  - 企业认证审核是 stage3 后台主线第一包
  - 但此前不得把旧 `S1-R04` backend-first packaging 直接冒充为当前 stage3 Admin package freeze
- 当前 package-level freeze 只服务于：
  - stage3 后台首包
- 当前不重开：
  - 平台级后台分层讨论
  - App/Admin/企业运营台平台宪法讨论

## 3. 对象锚定与非目标

### 3.1 对象锚定

- 当前包固定只指向：
  - `organization certification review`
- 其唯一真义固定为：
  - organization certification review list
  - detail
  - approve
  - reject
  - reviewer eligibility
  - append-only audit attribution

### 3.2 当前明确不包含

- `enterprise_hub application review`
- 企业入驻审核
- 组织生命周期治理扩写
- 内容安全审核扩写
- 风险事件 / `security-events`
- `ticketing`
- `template_config`
- `published change review`
- `recommendation-slots`
- 完整 `Admin` issuer login flow

## 4. truth owner 与边界归属

- `Server` 继续是唯一 truth owner：
  - `organizations`
  - `organization_certifications`
  - reviewer eligibility truth
  - audit append truth
- `Admin` 当前只允许：
  - 读取受控 `Server Admin API`
  - 发出 approve / reject 命令
- `Admin` 当前不得：
  - 持有第二 certification truth
  - 持有第二 reviewer state
  - 持有第二 audit system
- `BFF` 当前明确不介入本包。

## 5. Admin 工作台座位裁决

### 5.1 `/review` 主座位归属裁决

- 当前单选结论固定为：
  - `A. 继续共用 /review 家族，但企业认证审核进入其子路由`

### 5.2 为什么不是独立顶层路由

- 当前不取“新开独立顶层路由”，原因固定为：
  - `review` 家族本身就是受控 review workbench family
  - `route-guard` 已对 `/review` 家族整体生效
  - 当前 top-level 导航已把 review 视为独立后台对象家族
  - 若再新开顶层路由，会扩大当前后台 route constitution，增加无必要的主导航漂移

### 5.3 主座位与子座位固定口径

- `/review`
  - 当前继续承接：
    - `content-safety review-tasks` 主座位
- `/review/organizations`
  - 当前固定承接：
    - `organization certification review` 列表座位
- `/review/organizations/{organizationId}`
  - 当前固定承接：
    - `organization certification review` 详情与命令座位

## 6. Admin 路由冻结

- 当前企业认证审核的唯一路由族固定为：
  - `GET /review/organizations`
  - `GET /review/organizations/{organizationId}`
- 当前 route query family 最小只允许：
  - `status`
  - `keyword`
  - `organizationId`
- 当前明确不允许：
  - 复用 content-safety 的 `taskId`
  - 复用 content-safety 的 `taskType`
  - 复用 enterprise-hub 的 `applicationId`
  - 复用 governance 的 `penaltyId / appealCaseId`

## 7. Server controller surface 冻结

- 当前唯一受控 path family 固定为：
  - `GET /server/admin/reviews/organizations`
  - `GET /server/admin/reviews/organizations/{organizationId}`
  - `POST /server/admin/reviews/organizations/{organizationId}/approve`
  - `POST /server/admin/reviews/organizations/{organizationId}/reject`
- 当前不允许顺手带入：
  - `GET /server/admin/security-events`
  - `enterprise-hub applications*`
  - appeals
  - ticketing

## 8. reviewer eligibility 与权限矩阵

- 当前 reviewer eligibility 固定为：
  - verified current-session context
  - active membership truth
  - role key in `platform_reviewer | platform_super_admin`
  - platform organization membership
- 当前 fail-closed 规则固定为：
  - 无 verified current-session 不得读写
  - 无 reviewer eligibility 不得 list/detail/approve/reject
  - raw header hints 不得直接放行 reviewer 权限

## 9. 状态机与命令表

### 9.1 状态机固定

- 当前包只承接：
  - review object = current organization certification
- 当前允许关注的状态集固定为：
  - `not_submitted`
  - `pending_review`
  - `approved`
  - `rejected`
  - `expired`

### 9.2 命令边界固定

- `approve`
  - 只允许：
    - `pending_review -> approved`
- `reject`
  - 只允许：
    - `pending_review -> rejected`
- 当前不允许：
  - resubmit
  - supplement
  - appeal
  - risk escalation

### 9.3 命令副作用固定

- `approve`
  - `reviewedAt`
  - `reviewedBy`
  - clear `rejectReason`
  - when `organization.status = draft`, organization may become `active`
- `reject`
  - `reviewedAt`
  - `reviewedBy`
  - persist `rejectReason`
- 当前 reject 明确不得：
  - close organization
  - mutate membership truth
  - mutate session truth

## 10. 审计与留痕要求

- 当前 approve / reject 必须保持 append-only audit discipline。
- 当前最低审计 action 固定为：
  - `OrganizationCertificationApproved`
  - `OrganizationCertificationRejected`
- 当前必须保留的审计字段固定为：
  - `objectType`
  - `objectId`
  - `objectNo`
  - `actorId`
  - `actorRole`
  - `beforeState`
  - `afterState`
  - `reason`
  - `requestId`
  - `traceId`
  - `occurredAt`

## 11. 错误码与拒绝理由

- 当前错误码家族固定为：
  - `ORG_REVIEW_RESOURCE_UNAVAILABLE`
  - `ORG_REVIEW_APPROVE_INVALID`
  - `ORG_REVIEW_REJECT_INVALID`
  - `ORG_REVIEW_INVALID_STATE`
- 当前 reject 理由族固定为：
  - `reason` 必填
  - `note` 可选
- 当前不允许：
  - `rejectReasonCode`
  - risk level
  - governance overlay reason family

## 12. 本地 / 云上验证要求

### 12.1 本地

- `apps/server`
  - `node --test test/s1-r04-certification-minimal-review-ops-closure.test.cjs`
  - `tsc --noEmit`
  - `npm run build`
- `apps/admin`
  - organization review transport tests
  - organization review route tests
  - organization review action/state tests
  - `npm run test:admin-side`
  - `tsc --noEmit`
  - `npm run build`

### 12.2 云上

- chosen admin route 未登录必须：
  - `307 -> /login`
- `server/admin/reviews/organizations*` 未携带合法管理员 carrier 必须：
  - fail-closed
- chosen admin route 上线后不得：
  - 404
  - 跳到内容安全任务详情

## 13. Go / No-Go for implementation 条件

### 13.1 Go 条件

- 当前 package-level spec 已冻结
- 当前 package-level conclusion 已冻结
- 当前 seat / route family 已冻结
- 当前对象污染边界已冻结

### 13.2 veto 条件

- 不得把企业认证审核扩成企业入驻审核
- 不得把企业认证审核扩成 generic review task union
- 不得顺手带入 content-safety 扩写
- 不得带入 `security-events`
- 不得带入 `ticketing`
- 不得带入 `template_config`
- 不得带入 `published change review`

## 14. Formal Conclusion

- `enterprise certification review` 当前 package-level controller review spec bundle 已冻结。
- 当前 seat / route / controller / permission / state machine / audit / error family 已收口。
- 当前企业认证审核包的唯一受控 route family 固定为：
  - `/review/organizations*`
- 当前 `/review` 主座位继续承接内容安全审核，不被企业认证审核覆盖。
