---
owner: Codex 总控
status: frozen
purpose: Freeze the implementation dispatch planning addendum for the enterprise_hub application review package, grounding the next bounded implementation order on current code truth while keeping implementation dispatch closed in this round.
layer: L0 SSOT
freeze_date_local: 2026-04-12
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/enterprise_hub_application_review_controller_review_spec_bundle_addendum.md
  - docs/00_ssot/enterprise_hub_application_review_controller_review_conclusion_addendum.md
  - apps/server/src/modules/enterprise_hub/enterprise-hub-admin.controller.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-admin.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-published-change-admin.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-query.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-workbench.query.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub.presenter.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub.errors.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub.constants.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub.module.ts
  - apps/server/src/modules/enterprise_hub/entities/enterprise-application.entity.ts
  - apps/server/src/shared/current-session-verification.ts
  - apps/server/src/modules/auth/current-session-verification.service.ts
  - apps/server/src/modules/organization/current-actor-eligibility.service.ts
  - apps/server/src/modules/review/organization-review-query.service.ts
  - apps/server/src/modules/review/organization-review-write.service.ts
  - apps/server/src/modules/audit/identity-audit-log.entity.ts
  - apps/server/src/modules/audit/audit-admin.controller.ts
  - apps/server/src/modules/audit/audit-log.presenter.ts
  - apps/admin/src/core/auth/route-guard.ts
  - apps/admin/src/core/server/admin-api-runtime.ts
  - apps/admin/src/core/server/admin-api-client.ts
  - apps/admin/src/core/server/admin-review-api-client.ts
  - apps/admin/src/core/server/admin-organization-review-api-client.ts
  - apps/admin/src/core/server/admin-enterprise-hub-change-api-client.ts
  - apps/admin/src/app/review/page.tsx
  - apps/admin/src/app/review/change_requests/page.tsx
  - apps/admin/src/app/review/change_requests/[changeRequestId]/page.tsx
  - apps/admin/src/app/review/organizations/page.tsx
  - apps/admin/src/app/review/organizations/[organizationId]/page.tsx
  - apps/admin/src/modules/review/review-shell.tsx
  - apps/admin/src/modules/review/organization-review-shell.tsx
  - apps/admin/src/modules/review/organization-review-state.ts
  - apps/admin/src/modules/review/organization-review-actions.ts
  - apps/admin/src/modules/published_change_review/published-change-review-shell.tsx
  - apps/admin/src/modules/published_change_review/published-change-review-state.ts
  - apps/admin/src/modules/published_change_review/published-change-review-form.ts
  - apps/admin/src/modules/published_change_review/published-change-review-actions.ts
  - apps/admin/src/middleware.ts
  - apps/server/test/current-actor-eligibility-admin-reasons.test.cjs
  - apps/server/test/s1-r04-certification-minimal-review-ops-closure.test.cjs
  - apps/server/test/enterprise-hub-published-change-governance.test.cjs
  - apps/admin/test/admin-api-client.test.cjs
  - apps/admin/test/admin-route-guard.test.cjs
  - apps/admin/test/admin-organization-review.test.cjs
  - apps/admin/test/admin-published-change-review.test.cjs
---

# 《企业入驻审核 implementation dispatch plan》

## 1. 本轮目标与非目标

- 本轮唯一 planning target 固定为：
  - `enterprise_hub application review`
- 本轮唯一 planning 产物固定为：
  - `docs/00_ssot/enterprise_hub_application_review_implementation_dispatch_plan_addendum.md`
- 本轮 planning 只负责：
  - 基于当前真实代码面冻结实施写集
  - 冻结唯一实施顺序
  - 冻结每一步输入、动作、产出、完成标志
  - 冻结获得单独 Go 后的第一施工动作
- 本轮明确非目标：
  - implementation
  - patch
  - deploy
  - release-prep
  - launch
  - published change corridor 修正
  - recommendation-slots 修正
  - risk/security-events
  - ticketing
  - template_config
  - organization certification review
  - content-safety review task
  - 完整 Admin issuer login flow

## 2. 当前 gate 与 blocker 复述

- authoritative gate 固定为：
  - `controller review = PASS`
  - `implementation planning = GO`
  - `direct implementation dispatch = NO_GO`
- 当前唯一 authoritative blocker 固定为：
  - `reviewer guard 未统一`
- 当前 planning conclusion 继续写死为：
  - `planning = GO`
  - `dispatch = 仍然 NO_GO，直到本 planning addendum 输出收口并被单独验收`
- 当前不得把以下项升级成新的 authoritative blocker set：
  - `Admin desk 不存在`
  - `under_review dead state`
  - `audit append 缺失`
  - `error/reject-reason 未对齐`

## 3. 真实对象范围确认

- 当前对象只包括：
  - `GET /server/admin/exhibition/enterprise-hub/applications`
  - `GET /server/admin/exhibition/enterprise-hub/applications/{applicationId}`
  - `POST /server/admin/exhibition/enterprise-hub/applications/{applicationId}/review`
  - `GET /review/enterprise_hub_applications`
  - `GET /review/enterprise_hub_applications/{applicationId}`
  - enterprise_hub application review list
  - enterprise_hub application review detail
  - reviewer review command
  - reviewer attribution
  - application review audit append
- 当前对象明确不包括：
  - `/review` 主座位内容安全任务
  - `/review/change_requests*`
  - `/review/organizations*`
  - `enterprises/:enterpriseId/publish`
  - `enterprises/:enterpriseId/offline`
  - `enterprises/:enterpriseId/freeze`
  - `recommendation-slots*`
  - `change-requests*`

## 4. 当前真实代码复核

### 4.1 blocker `reviewer guard 未统一` 的真实落点

- `apps/server/src/modules/enterprise_hub/enterprise-hub-admin.controller.ts`
  - `listApplications(...)` 当前没有 `@Headers()`，因此没有把请求上下文传入 service。
  - `getApplicationDetail(...)` 当前没有 `@Headers()`，因此没有把请求上下文传入 service。
  - `reviewApplication(...)` 虽然传入了 `resolveRequestContext(headers)`，但下游没有统一 fail-closed reviewer guard。
- `apps/server/src/modules/enterprise_hub/enterprise-hub-admin.service.ts`
  - `listApplications(...)` 当前没有 `RequestContext` 入参，也没有 `requireVerifiedCurrentSessionContext(...)`。
  - `getApplicationDetail(...)` 当前没有 `RequestContext` 入参，也没有 `CurrentActorEligibilityService.requireReviewer(...)`。
  - `reviewApplication(...)` 当前接收 `context`，但没有调用：
    - `requireVerifiedCurrentSessionContext(context, currentSessionVerificationService)`
    - `eligibilityService.requireReviewer(currentSession)`
- 对照真实可复用模式：
  - `apps/server/src/modules/enterprise_hub/enterprise-hub-published-change-admin.service.ts`
    已经把 reviewer gate 收成私有 `requireReviewer(...)`，当前 applications family 没有复用这个闭环。
- 结论固定为：
  - blocker 不是缺 auth primitive。
  - blocker 是 `applications*` 没有统一接现成 auth primitive。

### 4.2 server/admin 写集应落的位置

- server 侧 bounded write-set 应落在：
  - `enterprise-hub-admin.controller.ts`
    - 只调整 `applications*` 入口的 headers/context 传递与 service 路由。
  - `enterprise-hub.module.ts`
    - 注入 application review bounded service 与审计仓储依赖。
  - 新 bounded service 文件，而不是继续扩大混载文件：
    - `enterprise-hub-application-review-admin.query.service.ts`
    - `enterprise-hub-application-review-admin.write.service.ts`
  - `enterprise-hub-admin.service.ts`
    - 收掉原 `applications*` 逻辑，避免继续把 application review 与 publish/offline/freeze/recommendation-slot 混在同一服务内。
  - `enterprise-hub.presenter.ts`
    - 对齐 application read model。
  - `enterprise-hub.constants.ts`
    - 冻结 reject-reason family 常量。
  - `enterprise-hub.errors.ts`
    - 补齐 review body/transition 校验时复用的 bounded domain error 入口。
- admin 侧 bounded write-set 应落在：
  - 新 route family：
    - `apps/admin/src/app/review/enterprise_hub_applications/page.tsx`
    - `apps/admin/src/app/review/enterprise_hub_applications/[applicationId]/page.tsx`
  - 新 desk module：
    - `apps/admin/src/modules/enterprise_hub_application_review/enterprise-hub-application-review-shell.tsx`
    - `apps/admin/src/modules/enterprise_hub_application_review/enterprise-hub-application-review-state.ts`
    - `apps/admin/src/modules/enterprise_hub_application_review/enterprise-hub-application-review-form.ts`
    - `apps/admin/src/modules/enterprise_hub_application_review/enterprise-hub-application-review-actions.ts`
  - 新 transport：
    - `apps/admin/src/core/server/admin-enterprise-hub-application-review-api-client.ts`
    - `apps/admin/src/core/server/admin-api-client.ts`
- 当前不应作为 implementation 首批触达面的依赖代码：
  - `apps/admin/src/core/auth/route-guard.ts`
  - `apps/admin/src/core/server/admin-api-runtime.ts`
  - `apps/admin/src/middleware.ts`
  - `apps/server/src/shared/current-session-verification.ts`
  - `apps/server/src/modules/auth/current-session-verification.service.ts`
  - `apps/server/src/modules/organization/current-actor-eligibility.service.ts`
- 上述文件当前是真实依赖，但不是 blocker 的改动落点；planning 只要求复用，不要求重写。

### 4.3 Admin desk 缺口的真实落点

- 当前不存在的路由：
  - `apps/admin/src/app/review/enterprise_hub_applications/page.tsx`
  - `apps/admin/src/app/review/enterprise_hub_applications/[applicationId]/page.tsx`
- 当前不存在的 shell/state/actions/api client：
  - `apps/admin/src/modules/enterprise_hub_application_review/*`
  - `apps/admin/src/core/server/admin-enterprise-hub-application-review-api-client.ts`
- 当前已存在且必须复用、不应重写的底座：
  - `/review` 家族受 `route-guard` 与 `middleware` 保护
  - `admin-api-runtime.ts` 已会转发 canonical admin carrier 与请求头
  - `admin-api-client.ts` 已作为统一出口
- 结论固定为：
  - Admin 缺口是真正的 seat/shell/state/action/transport 缺口。
  - 不是 route-guard 缺口。
  - 不是 admin-api-runtime 缺口。

### 4.4 `under_review` dead state 的真实落点

- `apps/server/src/modules/enterprise_hub/enterprise-hub.constants.ts`
  - `under_review` 已被声明。
- `apps/server/src/modules/enterprise_hub/enterprise-hub-write.service.ts`
  - `submitApplication(...)` 只把状态推到 `submitted`。
- `apps/server/src/modules/enterprise_hub/enterprise-hub-admin.service.ts`
  - `reviewApplication(...)` 允许从 `submitted | under_review` 直接终态迁移。
  - `getApplicationDetail(...)` 没有像 published change detail 那样把 `submitted` 规范化推进到 `under_review`。
- 结论固定为：
  - `under_review` 不是不存在。
  - `under_review` 是 declared-but-dead。
  - 其 fit-gap 应放在 reviewer guard 与 command/read surface 收口之后处理。

### 4.5 audit append 的真实落点

- `enterprise_application` 已有：
  - `reviewerId`
  - `reviewNote`
  - `rejectionReason`
  - `reviewedAt`
- 当前 `reviewApplication(...)` 没有任何 append-only audit。
- repo 内现有两类可参考 carrier：
  - `IdentityAuditLogEntity`
    - 有 `objectType/objectId/objectNo/action/actorId/actorRole/beforeState/afterState/reason/requestId/traceId/occurredAt`
    - 没有结构化 `payload`
  - `ProjectPublishAuditLogEntity`
    - 有 `payload`
    - 但其 source family 与 aggregate 语义不属于本包
- 结论固定为：
  - application review audit append 应留在本包内接入现有 append-only audit carrier。
  - 不能借 published change object 偷渡 event family。
  - 不能提前把 audit 伪装成 blocker 替代 reviewer guard。

## 5. 计划触达文件清单

### 5.1 apps/server

- `[apps/server/src/modules/enterprise_hub/enterprise-hub-admin.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/enterprise_hub/enterprise-hub-admin.controller.ts)`
- `[apps/server/src/modules/enterprise_hub/enterprise-hub-admin.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/enterprise_hub/enterprise-hub-admin.service.ts)`
- `[apps/server/src/modules/enterprise_hub/enterprise-hub-application-review-admin.query.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/enterprise_hub/enterprise-hub-application-review-admin.query.service.ts)` `new`
- `[apps/server/src/modules/enterprise_hub/enterprise-hub-application-review-admin.write.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/enterprise_hub/enterprise-hub-application-review-admin.write.service.ts)` `new`
- `[apps/server/src/modules/enterprise_hub/enterprise-hub.module.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/enterprise_hub/enterprise-hub.module.ts)`
- `[apps/server/src/modules/enterprise_hub/enterprise-hub.presenter.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/enterprise_hub/enterprise-hub.presenter.ts)`
- `[apps/server/src/modules/enterprise_hub/enterprise-hub.constants.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/enterprise_hub/enterprise-hub.constants.ts)`
- `[apps/server/src/modules/enterprise_hub/enterprise-hub.errors.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/enterprise_hub/enterprise-hub.errors.ts)`

### 5.2 apps/admin

- `[apps/admin/src/core/server/admin-enterprise-hub-application-review-api-client.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/admin/src/core/server/admin-enterprise-hub-application-review-api-client.ts)` `new`
- `[apps/admin/src/core/server/admin-api-client.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/admin/src/core/server/admin-api-client.ts)`
- `[apps/admin/src/app/review/enterprise_hub_applications/page.tsx](/Users/wangweiwei/Desktop/展览装修之家总控/apps/admin/src/app/review/enterprise_hub_applications/page.tsx)` `new`
- `[apps/admin/src/app/review/enterprise_hub_applications/[applicationId]/page.tsx](/Users/wangweiwei/Desktop/展览装修之家总控/apps/admin/src/app/review/enterprise_hub_applications/[applicationId]/page.tsx)` `new`
- `[apps/admin/src/modules/enterprise_hub_application_review/enterprise-hub-application-review-shell.tsx](/Users/wangweiwei/Desktop/展览装修之家总控/apps/admin/src/modules/enterprise_hub_application_review/enterprise-hub-application-review-shell.tsx)` `new`
- `[apps/admin/src/modules/enterprise_hub_application_review/enterprise-hub-application-review-state.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/admin/src/modules/enterprise_hub_application_review/enterprise-hub-application-review-state.ts)` `new`
- `[apps/admin/src/modules/enterprise_hub_application_review/enterprise-hub-application-review-form.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/admin/src/modules/enterprise_hub_application_review/enterprise-hub-application-review-form.ts)` `new`
- `[apps/admin/src/modules/enterprise_hub_application_review/enterprise-hub-application-review-actions.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/admin/src/modules/enterprise_hub_application_review/enterprise-hub-application-review-actions.ts)` `new`

### 5.3 tests

- `[apps/server/test/enterprise-hub-application-review-admin.test.cjs](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/test/enterprise-hub-application-review-admin.test.cjs)` `new`
- `[apps/admin/test/admin-enterprise-hub-application-review.test.cjs](/Users/wangweiwei/Desktop/展览装修之家总控/apps/admin/test/admin-enterprise-hub-application-review.test.cjs)` `new`
- `[apps/admin/test/admin-api-client.test.cjs](/Users/wangweiwei/Desktop/展览装修之家总控/apps/admin/test/admin-api-client.test.cjs)`
- `[apps/admin/test/admin-route-guard.test.cjs](/Users/wangweiwei/Desktop/展览装修之家总控/apps/admin/test/admin-route-guard.test.cjs)`

## 6. 任务拆解总表

| 任务 | 内容 | 目的 | 主落点 |
| --- | --- | --- | --- |
| T1 | reviewer guard 统一收口 | 先关闭唯一 blocker | server `applications*` |
| T2 | `applications*` command/read surface fit-gap | 固化被 Admin 消费的受控面 | server `enterprise_hub` bounded service |
| T3 | Admin desk 落位 | 落 `/review/enterprise_hub_applications*` 独立座位 | admin route + shell + state + actions + api client |
| T4 | `under_review` state fit-gap | 去掉 declared-but-dead state | server review flow |
| T5 | audit append 接入 | 建立 append-only 留痕闭环 | server review write path |
| T6 | targeted tests + build | 本地闭环验证 | server/admin tests |
| T7 | cloud validation | 最后做 runtime read-only 核验 | cloud route + server admin endpoints |

## 7. 实施顺序总表

1. 第一步：先统一 `applications*` 的 reviewer guard。
2. 第二步：再收 `applications*` 的 command/read surface fit-gap。
3. 第三步：再落 Admin `/review/enterprise_hub_applications*` desk。
4. 第四步：再补 `under_review` state fit-gap。
5. 第五步：再补 application review audit append。
6. 第六步：再补 targeted tests 与本地 build 闭环。
7. 第七步：最后做 cloud validation。

## 8. 每一步输入 / 动作 / 产出 / 完成标志

### Step 1. reviewer guard 统一收口

- 为什么先做这一步：
  - 它是当前唯一 authoritative blocker。
  - 当前 list/detail 甚至拿不到 headers/context，不能被伪装成受控 Admin surface。
- 依赖输入：
  - `enterprise_hub_application_review_controller_review_spec_bundle_addendum.md`
  - `enterprise_hub_application_review_controller_review_conclusion_addendum.md`
  - `enterprise-hub-published-change-admin.service.ts` 的 `requireReviewer(...)` 现成模式
- 动作：
  - 给 `applications` list/detail controller 方法补 `@Headers()` 与 `resolveRequestContext(headers)`。
  - 在 application review bounded service 内建立统一 reviewer gate：
    - `requireVerifiedCurrentSessionContext(...)`
    - `eligibilityService.requireReviewer(...)`
  - 让 list/detail/review 三条 `applications*` path 统一先过 reviewer gate 再读写。
- 产出：
  - reviewer-only `applications*` surface
- 完成标志：
  - 无 carrier 时三条 path fail-closed
  - 非 reviewer carrier 时三条 path fail-closed
  - raw `x-actor-role` / `x-role` header hint 不能单独放行

### Step 2. `applications*` command/read surface fit-gap

- 为什么第二步做：
  - Step 1 先解决 boundary，Step 2 才能在受控前提下固定 server application review surface。
- 依赖输入：
  - Step 1 的 protected `applications*` surface
- 动作：
  - 把 application review 从混载 `enterprise-hub-admin.service.ts` 中抽成 bounded query/write service。
  - review body 对齐为：
    - `action`
    - `reason`
    - `reviewNote`
  - 校验对齐：
    - `approved` 不要求 `reason`
    - `revision_required | rejected` 必填 `reason`
    - `reviewNote` 只做补充说明
  - read model 对齐：
    - 保持 `application/enterprise/profiles/cases/certifications/contacts` 细分对象
    - 不把对象语义偷渡成 `taskId/changeRequestId/organizationId`
- 产出：
  - 稳定的 server admin application review surface
- 完成标志：
  - server list/detail/review surface 满足 frozen spec
  - `reviewNote` 不再冒充 `rejectionReason`
  - `revision_required` 可稳定持久化 `rejectionReason = reason`

### Step 3. Admin `/review/enterprise_hub_applications*` desk 落位

- 为什么第三步做：
  - Admin desk 只能消费已经受保护、已对齐的 server canonical surface。
  - 不能先做页面再倒逼 server 补 guard。
- 依赖输入：
  - Step 2 的 bounded server read/write surface
- 动作：
  - 新增独立 route family：
    - `/review/enterprise_hub_applications`
    - `/review/enterprise_hub_applications/{applicationId}`
  - 新增独立 admin transport：
    - list
    - detail
    - review
  - 新增独立 shell/state/form/actions
  - route-guard 与 admin-api-runtime 只复用，不改真相
- 产出：
  - enterprise_hub application review 独立 desk
- 完成标志：
  - 新 desk 不复用 `/review` 主座位 task 语义
  - 新 desk 不复用 `/review/change_requests*`
  - 新 desk 不复用 `/review/organizations*`
  - 新 desk 只调用 Server Admin canonical API

### Step 4. `under_review` state fit-gap

- 为什么第四步做：
  - guard 与 seat 已稳定后，再去激活 dead state，不会把 auth/desk/state 混成一次改动。
- 依赖输入：
  - Step 2 server review command/read surface
  - Step 3 Admin desk status consumption
- 动作：
  - reviewer 首次读取 detail 时，把 `submitted` 规范化推进到 `under_review`
  - review command 命中 `submitted` 时，先规范化为 `under_review`，再做终态迁移
  - app-side `getApplicationStatus(...)` 保持能读到这个真实状态推进
- 产出：
  - `under_review` 不再是 dead state
- 完成标志：
  - `submitted -> under_review` 有真实进入点
  - `approved | revision_required | rejected` 只从 `under_review` 进入
  - 相同 application 不再长期卡在 declared-but-dead `submitted`

### Step 5. audit append 接入

- 为什么第五步做：
  - 需要基于稳定的 before/after state 写 append-only audit。
- 依赖输入：
  - Step 4 的稳定状态机
- 动作：
  - review terminal 决策追加 append-only audit：
    - `EnterpriseHubApplicationApproved`
    - `EnterpriseHubApplicationRevisionRequired`
    - `EnterpriseHubApplicationRejected`
  - `objectType` 固定为：
    - `enterprise_hub_application`
  - `objectId/objectNo` 固定承接：
    - `applicationId`
  - 复用现有 `audit_logs` carrier，不改 audit admin route
  - 由于当前 `IdentityAuditLogEntity` 没有结构化 payload：
    - first-class 列写入 `objectType/objectId/objectNo/action/actorId/actorRole/beforeState/afterState/requestId/traceId/occurredAt`
    - `enterpriseId/organizationId/reason/reviewNote` 以 bounded serialized string 方式保存在 `reason`
- 产出：
  - application review append-only audit 闭环
- 完成标志：
  - 每次 terminal review 只追加 1 条 audit，不覆盖旧记录
  - `/server/admin/audit/logs` 可通过 `sourceFamily=identity&objectType=enterprise_hub_application` 读到记录

### Step 6. targeted tests 与本地 build 闭环

- 为什么第六步做：
  - 前五步都到位后，才能一次性验证 bounded package 闭环。
- 依赖输入：
  - Step 1-5 全部落地
- 动作：
  - 补 server targeted tests
  - 补 admin route/api client/seat separation/route guard tests
  - 跑 `tsc --noEmit`
  - 跑 `npm run build`
- 产出：
  - 本地可复验闭环
- 完成标志：
  - server/admin targeted tests 通过
  - build 不报错

### Step 7. cloud validation

- 为什么最后做：
  - cloud validation 只能验证 runtime reachability 与 fail-closed，不能替代本地实现闭环。
- 依赖输入：
  - Step 6 本地通过
- 动作：
  - 做只读云上核验
  - 不做 production-like write smoke
- 产出：
  - runtime proof
- 完成标志：
  - Step 7-1 匿名访问 `/review/enterprise_hub_applications*` 为 `307 -> /login`
  - Step 7-2 无合法管理员 carrier 访问 `/server/admin/exhibition/enterprise-hub/applications*` fail-closed
  - Step 7-3 合法登录态访问 `/review/enterprise_hub_applications*` 不是 `404`，不是 `/review` 主座位，不是 `/review/change_requests*`，不是 `/review/organizations*`

## 9. reviewer guard 收口计划

- 当前第一施工项必须围绕以下真实落点收口：
  - `enterprise-hub-admin.controller.ts` 的 `listApplications/getApplicationDetail`
  - `enterprise-hub-admin.service.ts` 的 `listApplications/getApplicationDetail/reviewApplication`
- 当前 reviewer guard 的统一方案固定为：
  - 复用 `requireVerifiedCurrentSessionContext(...)`
  - 复用 `CurrentActorEligibilityService.requireReviewer(...)`
  - 拒绝直接信任 header hint
- 当前不计划改动：
  - `CurrentActorEligibilityService.requireReviewer(...)` 的 reviewer truth 定义
  - `CurrentSessionVerificationService` 的 carrier 解析规则
  - `route-guard.ts` 与 `admin-api-runtime.ts`
- 当前 reviewer guard 收口完成的唯一判定口径固定为：
  - `applications*` 三条 admin path 全部 fail-closed reviewer-only

## 10. Admin desk 落位计划

- 当前 Admin desk 固定落位为：
  - `/review/enterprise_hub_applications`
  - `/review/enterprise_hub_applications/{applicationId}`
- 当前 desk 结构固定为：
  - list shell
  - detail panel
  - approve form
  - revision_required form
  - reject form
  - status summary
- 当前 transport 结构固定为：
  - `fetchEnterpriseHubApplications(...)`
  - `fetchEnterpriseHubApplication(...)`
  - `reviewEnterpriseHubApplication(...)`
- 当前 desk 必须避免的语义漂移：
  - 不得使用 `taskId`
  - 不得使用 `changeRequestId`
  - 不得使用 `organizationId` 作为主 detail param
  - 不得把 `approved` 冒充 `published`
- 当前不需要前置改动：
  - `route-guard.ts`
  - `middleware.ts`
  - `admin-api-runtime.ts`
- 原因固定为：
  - `/review/:path*` 已经是受保护 family
  - canonical carrier 转发已经成立

## 11. state machine fit-gap 计划

- 当前 fit-gap 固定在 Step 4 处理，不前置冒充完成。
- 原因固定为：
  - Step 1 要先关掉唯一 blocker。
  - Step 2 要先收口 protected server surface。
  - Step 3 要先把 Admin seat 落在正确家族。
- 当前 state machine 处理口径固定为：
  - `draft -> submitted` 继续只在 app submit path
  - reviewer detail 首次承接：
    - `submitted -> under_review`
  - reviewer approve：
    - `under_review -> approved`
  - reviewer request revision：
    - `under_review -> revision_required`
  - reviewer reject：
    - `under_review -> rejected`
- 当前兼容规则固定为：
  - review command 命中 `submitted` 时，必须先规范化视为 `under_review`

## 12. audit append 接入计划

- 当前 audit append 固定在 Step 5 处理。
- 原因固定为：
  - 它依赖稳定的 reviewer boundary 与稳定的 before/after state。
- 当前 audit append 实现边界固定为：
  - 只为 `enterprise_hub application review` 写 append-only audit
  - 不扩展成 published change audit
  - 不扩展成 organization certification audit
- 当前 audit carrier 策略固定为：
  - 优先复用现有 `audit_logs`
  - 以 `objectType = enterprise_hub_application` 做对象锚定
  - 不在本包内重写 audit admin read surface
- 当前已知 fit-gap 明确记账为：
  - `IdentityAuditLogEntity` 没有结构化 payload
  - 因此 `enterpriseId/organizationId/reason/reviewNote` 需以 bounded serialized 方式保留
  - 若后续需要结构化 audit payload，那是后续独立审计包决策，不在本 planning 升级为 blocker

## 13. error / reject-reason 对齐计划

- 当前 server fit-gap：
  - `reviewApplication(...)` 只校验 `action`
  - `revision_required` 当前没有稳定持久化 `rejectionReason`
  - `rejected` 当前把 `reviewNote` 冒充 `rejectionReason`
- 当前 admin fit-gap：
  - 不能照搬 published change form 的 `reviewNote 既是原因又是备注` 模式
- 当前对齐方案固定为：
  - `reason` 只承接 reject-reason family
  - `reviewNote` 只承接补充说明
  - `rejectionReason` 只由 `reason` 写入
- 当前 reject-reason family 固定为：
  - `basic_info_incomplete`
  - `profile_incomplete`
  - `case_incomplete`
  - `contact_incomplete`
  - `certification_not_approved`
  - `other`
- 当前错误家族固定为：
  - auth/session deny 继续走：
    - `AUTH_SESSION_INVALID`
    - `AUTH_PERMISSION_INSUFFICIENT`
    - `AUTH_RESOURCE_UNAVAILABLE`
  - domain validation/transition 继续走：
    - `ENTERPRISE_HUB_APPLICATION_NOT_FOUND`
    - `ENTERPRISE_HUB_INVALID_STATE_TRANSITION`
    - `ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS`

## 14. 本地测试计划

### 14.1 apps/server

- 新增 targeted harness：
  - `enterprise-hub-application-review-admin.test.cjs`
- 必测项固定为：
  - `applications*` list/detail/review 对无 carrier fail-closed
  - `applications*` list/detail/review 对非 reviewer fail-closed
  - `submitted -> under_review -> approved`
  - `submitted -> under_review -> revision_required`
  - `submitted -> under_review -> rejected`
  - `revision_required/rejected` 的 `reason` 必填
  - audit append 每次只追加 1 条
  - app-side `getApplicationStatus(...)` 能读到真实状态推进
- 编译校验固定为：
  - `tsc --noEmit`
  - `npm run build`

### 14.2 apps/admin

- 新增 seat test：
  - `admin-enterprise-hub-application-review.test.cjs`
- 续改 transport/route guard test：
  - `admin-api-client.test.cjs`
  - `admin-route-guard.test.cjs`
- 必测项固定为：
  - `/review/page.tsx` 仍是 content-safety 主座位
  - `/review/enterprise_hub_applications*` 独立 route family 存在
  - API client path 全部命中 `/server/admin/exhibition/enterprise-hub/applications*`
  - route guard 对 `/review/enterprise_hub_applications*` 匿名访问跳转登录
  - shell/state 不复用 `taskId/changeRequestId/organizationId` 主语义
  - form payload 明确拆分 `reason` 与 `reviewNote`
- 编译校验固定为：
  - `tsc --noEmit`
  - `npm run build`

## 15. 云上验证计划

- 当前 cloud validation 固定是 Step 7，不得前置冒充完成。
- 当前云上验证顺序固定为：
  - Step 7-1：
    - 匿名访问 `/review/enterprise_hub_applications`
    - 期望 `307 -> /login`
  - Step 7-2：
    - 不带合法管理员 carrier 访问
      - `/server/admin/exhibition/enterprise-hub/applications`
      - `/server/admin/exhibition/enterprise-hub/applications/{applicationId}`
    - 期望 fail-closed
  - Step 7-3：
    - 合法登录态访问 `/review/enterprise_hub_applications*`
    - 期望：
      - 不是 `404`
      - 不是 `/review` 主座位
      - 不是 `/review/change_requests*`
      - 不是 `/review/organizations*`
- 当前明确不能前置冒充完成的事项：
  - 没做 Step 7-1 就说 route guard 完成
  - 没做 Step 7-2 就说 reviewer fail-closed 完成
  - 没做 Step 7-3 就说 Admin desk 云上可达完成
- 当前明确禁止：
  - 在 production-like runtime 上做真实 write smoke

## 16. 风险与阻塞项

- 风险 1：
  - `enterprise-hub-admin.service.ts` 当前已混载多个 enterprise_hub admin object。
  - 如果 Step 2 不做 bounded extraction，只在原文件继续堆逻辑，会继续恶化责任边界。
- 风险 2：
  - `IdentityAuditLogEntity` 无结构化 payload。
  - 本包可先用 serialized `reason` 保留 `enterpriseId/organizationId/reason/reviewNote`，但后续若要做结构化筛选，需要单独 audit schema 决策。
- 风险 3：
  - Admin 当前会话探针仍走 `/content-safety/review-tasks`。
  - 该 issuer/login flow 本轮明确不在对象范围内，不能被顺手扩成 reviewer surface 变更。
- 风险 4：
  - cloud validation 是只读闭环，不会替代本地 terminal review 测试。
- 当前阻塞项口径继续固定为：
  - authoritative blocker 仍只有 `reviewer guard 未统一`
  - 以上风险保持为 planning 风险，不升级成新的 blocker set

## 17. Go / No-Go for implementation dispatch

- 当前 planning 结论固定为：
  - `implementation planning = GO`
- 当前 dispatch 结论固定为：
  - `implementation dispatch = NO_GO`
- 当前 `NO_GO` 的直接含义固定为：
  - 本 planning 文书虽然已经收口，但本轮不能直接进入 implementation dispatch
  - 必须先对本 planning addendum 做单独验收
- 当前只有在以下条件同时满足后，implementation dispatch 才可能申请 Go：
  - 本 planning addendum 被单独验收
  - 第一施工动作明确围绕 reviewer guard 启动
  - 不篡改对象范围
  - 不新增 authoritative blocker set

## 18. 获得 Go 后的第一施工动作

- 第一施工动作固定为：
  - 先收 `applications*` reviewer guard，不做 Admin desk，不做 audit，不做云上。
- 第一施工动作的精确落点固定为：
  - `enterprise-hub-admin.controller.ts`
    - 给 `listApplications(...)` 和 `getApplicationDetail(...)` 补 `@Headers()` 与 `resolveRequestContext(headers)`
  - 新建 bounded reviewer gate service path：
    - `enterprise-hub-application-review-admin.query.service.ts`
    - `enterprise-hub-application-review-admin.write.service.ts`
  - 在上述 bounded service 内先实现统一 reviewer gate：
    - `requireVerifiedCurrentSessionContext(...)`
    - `eligibilityService.requireReviewer(...)`
- 第一施工动作完成前明确不允许先做：
  - Admin `/review/enterprise_hub_applications*` 页面
  - `under_review` 状态推进
  - audit append
  - cloud validation

## 19. Formal Planning Conclusion

- `enterprise_hub application review` 的 implementation planning 已冻结为：
  - 有界对象成立
  - 写集成立
  - 实施顺序成立
  - 第一施工动作成立
- 当前 authoritative dispatch verdict 继续固定为：
  - `direct implementation dispatch = NO_GO`
- 当前唯一第一施工动作继续固定为：
  - `先统一 applications* reviewer guard`
