---
owner: Codex 总控
status: frozen
purpose: Freeze the implementation preflight dispatch plan for the enterprise certification review package, based on current frozen truth, actual code/runtime state, and a Go/No-Go implementation decision without entering implementation.
layer: L0 SSOT
freeze_date_local: 2026-04-12
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/admin_startup_full_scan_and_mainline_ruling_addendum.md
  - docs/00_ssot/s1_r04_certification_minimal_review_ops_closure_controller_review_spec_bundle_addendum.md
  - docs/00_ssot/s1_r04_certification_minimal_review_ops_closure_controller_review_conclusion_addendum.md
  - docs/00_ssot/s1_r04_certification_minimal_review_ops_closure_result_verification_conclusion_addendum.md
  - docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md
  - docs/05_admin/account_and_enterprise_certification_rules_v1_admin_surface_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/01_contracts/error_codes.yaml
  - apps/admin/src/app/layout.tsx
  - apps/admin/src/app/review/page.tsx
  - apps/admin/src/core/auth/route-guard.ts
  - apps/admin/src/core/server/admin-api-client.ts
  - apps/admin/src/core/server/admin-review-api-client.ts
  - apps/admin/src/modules/review/review-shell.tsx
  - apps/admin/src/modules/review/review-actions.ts
  - apps/server/src/modules/review/review.module.ts
  - apps/server/src/modules/review/organization-review.controller.ts
  - apps/server/src/modules/review/organization-review-query.service.ts
  - apps/server/src/modules/review/organization-review-write.service.ts
  - apps/server/src/modules/review/organization-review.presenter.ts
  - apps/server/src/modules/review/review.errors.ts
  - apps/server/src/modules/organization/current-actor-eligibility.service.ts
  - apps/server/test/s1-r04-certification-minimal-review-ops-closure.test.cjs
---

# 《企业认证审核包 implementation dispatch plan》

## 1. 本轮目标与非目标

### 1.1 本轮目标

- 本轮只冻结：
  - `organization certification review` 的 implementation preflight dispatch plan
- 本轮只回答：
  - 当前前置是否足够支撑 implementation dispatch
  - 若不足，卡在哪些 gate
  - 若足够，后续应按什么顺序施工

### 1.2 本轮非目标

- 不进入 implementation
- 不进入 release-prep
- 不进入 deploy
- 不补 `template_config`
- 不补 `published change review`
- 不补 `enterprise_hub application review`
- 不补 `risk/security-events`
- 不补 `ticketing`
- 不补 `Admin` 完整 issuer login flow

## 2. 当前前置条件检查结果

| 前置项 | 当前状态 | 结论 |
|---|---|---|
| L3 backend truth | `account_and_enterprise_certification_rules_v1_backend_truth_addendum.md` 已存在，但仍是 `draft` | `PASS WITH RISK` |
| Contracts path family | `openapi.yaml` 已冻结 `server/admin/reviews/organizations*` | `PASS` |
| Error code family | `error_codes.yaml` 已有 `ORG_REVIEW_*` 家族 | `PASS` |
| Server 代码承接面 | controller/query/write/presenter 已存在 | `PASS` |
| Server 本地最小回归 | `s1-r04-certification-minimal-review-ops-closure.test.cjs = 3/3 pass` | `PASS` |
| 云上 Server path family | `/server/admin/reviews/organizations* = 401`，说明 active runtime 已挂载并受会话门禁保护 | `PASS` |
| 当前包级 controller review spec bundle | `docs/00_ssot/enterprise_cert_review_controller_review_spec_bundle_addendum.md` 缺失 | `FAIL` |
| 当前包级 controller review conclusion | `docs/00_ssot/enterprise_cert_review_controller_review_conclusion_addendum.md` 缺失 | `FAIL` |
| Admin seat / route 裁决 | 当前没有专属冻结件；`/review` 实际承接内容安全审核 | `FAIL` |
| Admin 消费面与对象范围一致性 | 当前 `apps/admin` 没有 organization review transport/workbench | `FAIL` |

### 2.1 前置检查总裁决

- 当前 implementation preflight 的总体前置结论固定为：
  - `No-Go`

### 2.2 直接 No-Go 的冲突点

1. 当前仓内不存在这条新包级的 `enterprise_cert_review controller review spec bundle`。
2. 当前仓内不存在这条新包级的 `enterprise_cert_review controller review conclusion`。
3. 当前 `Admin /review` 主座位实际承接的是 `content-safety review-tasks`，不是企业认证审核。
4. 旧冻结链 `S1-R04 controller review conclusion` 明确写死：
   - 当前不先派前端
   - 当前缺口收敛在 bounded backend repair / verification closure
   - 这与当前 stage3 首包的 `Admin package` 语义不一致

## 3. 实际对象范围确认

### 3.1 本轮对象锚定

- 当前对象固定为：
  - `organization certification review`

### 3.2 本轮只允许包含

- organization certification review list
- organization certification review detail
- approve
- reject
- reviewer eligibility / fail-closed gate
- approve / reject audit append
- Admin 消费面与 `Server Admin API` 对齐

### 3.3 本轮明确不包含

- `enterprise_hub application review`
- 企业入驻审核
- 内容安全审核扩写
- 风险事件
- `ticketing`
- `template_config`
- `published change review`
- `recommendation-slots`
- `Admin` issuer login flow

## 4. 计划触达文件清单

### 4.1 apps/admin

- 当前确定会触达的既有文件：
  - `apps/admin/src/app/layout.tsx`
  - `apps/admin/src/core/auth/route-guard.ts`
  - `apps/admin/src/core/server/admin-api-client.ts`
  - `apps/admin/src/app/review/page.tsx`
- 当前高概率新增文件：
  - `apps/admin/src/core/server/admin-organization-review-api-client.ts`
  - `apps/admin/src/modules/review/organization-review-shell.tsx`
  - `apps/admin/src/modules/review/organization-review-state.ts`
  - `apps/admin/src/modules/review/organization-review-actions.ts`
- 路由文件为条件触达：
  - 若 controller review 冻结为 `review` 子路由：
    - `apps/admin/src/app/review/organizations/page.tsx`
    - `apps/admin/src/app/review/organizations/[organizationId]/page.tsx`
  - 若 controller review 冻结为独立路由：
    - 对应独立 route family 文件

### 4.2 apps/server

- 当前确定会触达的既有文件：
  - `apps/server/src/modules/review/organization-review.controller.ts`
  - `apps/server/src/modules/review/organization-review-query.service.ts`
  - `apps/server/src/modules/review/organization-review-write.service.ts`
  - `apps/server/src/modules/review/organization-review.presenter.ts`
  - `apps/server/src/modules/review/review.errors.ts`
  - `apps/server/src/modules/review/review.module.ts`
  - `apps/server/src/modules/organization/current-actor-eligibility.service.ts`

### 4.3 docs

- implementation 开始后不应新增 docs-first 真源文书。
- 但当前必须先存在、否则不得开工的前置冻结件是：
  - `docs/00_ssot/enterprise_cert_review_controller_review_spec_bundle_addendum.md`
  - `docs/00_ssot/enterprise_cert_review_controller_review_conclusion_addendum.md`

### 4.4 tests

- `apps/server/test/s1-r04-certification-minimal-review-ops-closure.test.cjs`
- `apps/admin/test/admin-api-client.test.cjs`
- `apps/admin/test/admin-route-guard.test.cjs`
- 当前高概率新增：
  - `apps/admin/test/admin-organization-review.test.cjs`

## 5. 任务拆解总表

| 任务 | 目标 | 当前状态 |
|---|---|---|
| T0 | 补齐 package-level controller review freeze | `blocked` |
| T1 | 固化 Server controller/presenter/payload 与 contracts 一致性 | `ready after T0` |
| T2 | 新建 Admin organization-review transport family | `ready after T0` |
| T3 | 物化 Admin route + workbench seat | `ready after T0 and T2` |
| T4 | 权限与边界隔离落地 | `ready after T1 and T3` |
| T5 | 审计追加与错误码透传落地 | `ready after T1 and T3` |
| T6 | 本地回归 | `ready after T1~T5` |
| T7 | 云上联调 / 验证 | `ready after T6` |

## 6. 实施顺序总表

1. 先收掉 `T0`：
   - 补齐当前包级 controller review 冻结
2. 再做 `T1`：
   - 先校准 `Server` surface 与 contracts
3. 再做 `T2`：
   - 新建 Admin transport，不直接复用 content-safety client
4. 再做 `T3`：
   - 物化 route / page / shell，并处理菜单与参数隔离
5. 再做 `T4 + T5`：
   - 权限、审计、错误码一起收口
6. 最后做 `T6 + T7`：
   - 本地验证
   - 云上验证

## 7. 每一步的输入、动作、产出、完成标志

### Step 0. package-level freeze gate

- 输入：
  - `admin_startup_full_scan_and_mainline_ruling_addendum.md`
  - 当前缺失的 package-level controller review freeze
- 动作：
  - 先冻结当前包级 `controller review spec bundle + conclusion`
  - 收口：
    - seat meaning
    - route family
    - `review` 是否共家族
    - object pollution boundary
- 产出：
  - package-level freeze 成立
- 完成标志：
  - 当前仓内已存在并冻结上述两份文书

### Step 1. Server surface alignment

- 输入：
  - `openapi.yaml`
  - `error_codes.yaml`
  - 当前 `organization-review.*`
- 动作：
  - 对齐 list/detail/approve/reject payload 与 response shape
  - 确认 `approve.note` / `reject.reason + note` 与 presenter/detail 一致
  - 确认 list/detail 只暴露 package 范围字段
- 产出：
  - `Server` controller surface 与 contracts 对齐
- 完成标志：
  - list/detail/approve/reject 无 contract drift
  - 不新增 enterprise_hub / security-events / appeals 字段

### Step 2. Admin transport family

- 输入：
  - Step 1 的稳定 server surface
- 动作：
  - 新建 organization-review 专属 Admin API client
  - 把 `reviews/organizations*` 请求从内容安全 client 中隔离
  - 更新 `admin-api-client.ts` barrel export
- 产出：
  - organization-review 专属 transport family
- 完成标志：
  - Admin transport 不再复用 `content-safety` task type / taskId / submissionId 语义

### Step 3. Admin route and workbench materialization

- 输入：
  - Step 0 的 route verdict
  - Step 2 的 transport family
- 动作：
  - 创建组织认证审核列表 / 详情 / approve / reject 消费面
  - 根据已冻结 route 决议落对应 page files
  - 更新导航与受保护路由
- 产出：
  - 企业认证审核的真实 Admin 消费面
- 完成标志：
  - 未登录时 chosen route `307 -> /login`
  - 登录后可进入 org review queue/detail
  - 不污染当前内容安全 `/review` 工作台

### Step 4. Permission and boundary enforcement

- 输入：
  - 当前 `requireVerifiedCurrentSessionContext`
  - 当前 `requireReviewer`
- 动作：
  - 确认 list/detail/approve/reject 全部仍经 `Server` 权限验证
  - Admin 仅发命令、不改写真相
  - 处理菜单、query param、notice/error 文案隔离
- 产出：
  - package boundary fail-closed
- 完成标志：
  - 非 reviewer actor 无法 list/detail/approve/reject
  - 组织认证审核与内容安全审核参数、状态、菜单不串

### Step 5. Audit and error propagation

- 输入：
  - 现有 `IdentityAuditLogEntity`
  - 现有 `ORG_REVIEW_*` error family
- 动作：
  - 保持 approve/reject append-only audit
  - Admin 透传并展示 `ORG_REVIEW_*`
  - 拒绝理由只使用当前已冻结 `reason`/`note`
- 产出：
  - 审计与错误码承接闭环
- 完成标志：
  - approve/reject 都有 audit append
  - 无 generic “操作失败” 吞码行为

### Step 6. Local verification

- 输入：
  - Step 1~5 完成代码
- 动作：
  - 跑 server/admin 关键回归
  - 跑 build / tsc / eslint / bounded tests
- 产出：
  - 本地闭环证据
- 完成标志：
  - server/admin 指定回归全部绿

### Step 7. Cloud validation

- 输入：
  - 本地闭环结果
  - 部署后的云上 active runtime
- 动作：
  - 验 route / server path / auth behavior / smoke data
- 产出：
  - 云上 active runtime evidence
- 完成标志：
  - chosen admin route 不再 404
  - `server/admin/reviews/organizations*` 行为与本地一致

## 8. 权限与边界实现计划

- `Server` 继续是唯一 truth owner。
- `Admin` 只消费：
  - `GET /server/admin/reviews/organizations`
  - `GET /server/admin/reviews/organizations/{organizationId}`
  - `POST /server/admin/reviews/organizations/{organizationId}/approve`
  - `POST /server/admin/reviews/organizations/{organizationId}/reject`
- 权限计划固定为：
  - 先 `requireVerifiedCurrentSessionContext`
  - 再 `CurrentActorEligibilityService.requireReviewer`
  - reviewer 必须满足：
    - authenticated actor
    - active membership
    - `platform_reviewer | platform_super_admin`
    - platform organization membership
- 边界计划固定为：
  - 不经 `BFF`
  - 不改企业入驻审核
  - 不读写 `security-events`
  - 不接 appeals / ticketing / published change

## 9. 状态机与命令落地计划

- 当前包允许承接的状态集：
  - `not_submitted`
  - `pending_review`
  - `approved`
  - `rejected`
  - `expired`
- 当前包实际命令只落：
  - `approve`
  - `reject`
- 命令边界：
  - `approve`
    - 只允许 `pending_review -> approved`
    - 副作用：
      - `reviewedAt`
      - `reviewedBy`
      - clear `rejectReason`
      - 若 `organization.status = draft`，可进入 `active`
  - `reject`
    - 只允许 `pending_review -> rejected`
    - 副作用：
      - `reviewedAt`
      - `reviewedBy`
      - persist `rejectReason`
      - 不得偷偷关闭 organization lifecycle
- 当前包不落：
  - resubmit
  - supplement
  - appeal
  - risk escalation

## 10. 审计留痕接入计划

- 审计 carrier 固定为：
  - `IdentityAuditLogEntity`
- 当前必须追加的 action：
  - `OrganizationCertificationApproved`
  - `OrganizationCertificationRejected`
- 当前必须保留的字段：
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
- 当前计划不新增第二审计真源。

## 11. 错误码与拒绝理由接入计划

- 当前错误码家族固定为：
  - `ORG_REVIEW_RESOURCE_UNAVAILABLE`
  - `ORG_REVIEW_APPROVE_INVALID`
  - `ORG_REVIEW_REJECT_INVALID`
  - `ORG_REVIEW_INVALID_STATE`
- Admin 错误接入计划：
  - 原样读取 `Server` code/message
  - 不在 Admin 本地重写第二错误码体系
- 拒绝理由计划：
  - 当前只承接：
    - `reason` 必填
    - `note` 可选
  - 当前不发明：
    - `rejectReasonCode`
    - 风险等级
    - governance overlay

## 12. 测试计划（本地）

### 12.1 Server

- 必跑：
  - `node --test test/s1-r04-certification-minimal-review-ops-closure.test.cjs`
- 若触达 reviewer gate：
  - 增补或复跑基于 `CurrentActorEligibilityService` 的 fail-closed 断言

### 12.2 Admin

- 必跑：
  - `npm run test:admin-side`
- 必增：
  - organization review transport tests
  - organization review route guard tests
  - organization review page action/state tests

### 12.3 Static checks

- `apps/server`
  - `tsc --noEmit`
  - `npm run build`
- `apps/admin`
  - `tsc --noEmit`
  - `npm run build`
  - bounded eslint

## 13. 联调 / 验证计划（云上）

- route smoke：
  - chosen admin route 未登录必须 `307 -> /login`
  - 登录后不再 `404`
- server smoke：
  - `/server/admin/reviews/organizations*` 未登录或无效 carrier 继续 fail-closed
  - 合法管理员 carrier 下可 list/detail/approve/reject
- boundary smoke：
  - 不影响当前 `content-safety /review`
  - 不影响 `governance / project_review / audit`
  - 不顺手碰 `template_config / published change`
- evidence standard：
  - 页面承接证据
  - server path evidence
  - auth evidence
  - audit append evidence

## 14. 风险点与阻塞点

1. 当前 package-level controller review freeze 缺失，这是 implementation `No-Go` 的直接 blocker。
2. 当前 `/review` 主座位已被内容安全审核占用，route/seat 未冻结前直接开发会造成对象污染。
3. 旧 `S1-R04` 冻结结论是 backend-first，不等于当前 stage3 Admin 首包；直接沿用会造成层级冲突。
4. `docs/05_admin/account_and_enterprise_certification_rules_v1_admin_surface_addendum.md` 仍是 `draft`。
5. 工作区存在大规模 dirty-tree 并发改动，traceability 风险高。
6. 当前 Admin 完全没有 organization review transport/client/workbench，不能把“Server 路由存在”误写成“包已可开发完成”。

## 15. 本轮不做但必须保留的扩展位

- `enterprise_hub application review`
- `security-events` companion surface
- appeals
- `ticketing`
- `template_config`
- `published change review`
- 完整 `Admin` issuer login flow

## 16. Go / No-Go for implementation 判断

### 16.1 当前结论

- 当前 implementation 判断固定为：
  - `No-Go`

### 16.2 No-Go 原因

- 当前不是因为 Server truth 不存在。
- 当前也不是因为 contracts 缺失。
- 当前唯一直接阻断是：
  - 当前包级 `controller review spec bundle + conclusion` 不存在
  - 当前 Admin seat / route verdict 未冻结
  - 因此无法合法下发 implementation dispatch

## 17. 获得 Go 后的第一步唯一施工动作

- 在 package-level controller review freeze 补齐之后，
  当前第一步唯一施工动作固定为：
  - 先实现 `Admin` 侧 organization review 专属 transport family 与 route scaffold，
    使企业认证审核从当前内容安全 `/review` 语义中隔离出来，
    再进入 server/admin surface fit-gap 收口。

## 18. Formal Conclusion

- 当前 `organization certification review` 的 implementation preflight 已完成。
- 当前真实情况不是“什么都没有”，而是：
  - backend truth、contracts、error codes、server controller family、local server tests、cloud backend path 都已存在
  - 但 package-level controller review freeze 缺失，且 Admin seat/routing 仍未冻结
- 因此当前唯一合法结论只能是：
  - `No-Go for implementation`
- 当前若要进入下一步，唯一正确动作不是写代码，而是：
  - 先补齐该包的 `controller review spec bundle + conclusion`
