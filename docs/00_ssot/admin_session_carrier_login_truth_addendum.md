# Admin Session Carrier Login Truth Addendum

doc_meta:
  owner: Codex 总控
  status: draft
  layer: L1 SSOT
  scope: Admin 登录与 Server session carrier 真相冻结
  created_at: 2026-05-01

## 1. 当前裁决

Admin 当前没有独立账号密码登录体系，也没有管理员注册体系。Admin 登录页只消费 `Server Auth` 已签发的 session carrier，并把验证通过的 carrier 写入浏览器 `admin_session` cookie。后续 Admin 请求仍由 `Server Admin API` 校验当前 carrier、session truth、用户状态、平台组织 membership 和平台角色。

本文件只冻结 Admin 登录真相，不裁定 App 用户侧 password auth 是否作为正式主线继续保留。当前仓库内已同时存在 `OTP-only / phone_code_plus_org_invite` 旧合同口径、`account_password_plus_second_factor` 历史术语、以及 `password/login` formal/generated 变更痕迹，三者需要单独合同清理窗口处理。

依据类型：代码 / contracts / 文书 / 推断。

## 2. 正式 Admin 登录方式

当前正式 Admin 登录方式是 `server_session_carrier_only`。

最小流程：

1. 从受控 Server Auth 来源取得已签发的管理员 session carrier。
2. 在 Admin `/login` 页粘贴 raw access carrier，或粘贴完整 `Bearer <carrier>`。
3. Admin 前端先规范化输入：如输入包含 `Bearer ` 前缀，则仅保留 token 主体。
4. Admin 前端调用 `Server Admin API` 的受保护 review probe 校验 carrier 是否有效。
5. 校验通过后写入 `admin_session` cookie。
6. 后续 Admin API 请求把 `admin_session` 转为 `Authorization: Bearer <carrier>` 直连 Server Admin API。

代码依据：

- `apps/admin/src/app/login/page.tsx`：登录页表单字段为 `sessionCarrier`，说明文案为 Server 签发 carrier。
- `apps/admin/src/core/auth/route-guard.ts`：`ACTIVE_ADMIN_LOGIN_MODE = server_session_carrier_only`，`ADMIN_SESSION_COOKIE = admin_session`。
- `apps/admin/src/core/auth/session-carrier-actions.ts`：`connectAdminSessionCarrierAction` 先 `verifyAdminSessionCarrier`，再写 cookie。
- `apps/admin/src/core/server/admin-review-api-client.ts`：`verifyAdminSessionCarrier` 使用 `/content-safety/review-tasks` 作为受保护 probe。
- `apps/admin/src/core/server/admin-api-runtime.ts`：把 `admin_session` 转成 `Authorization` 头直连 Server。

依据类型：代码。

## 3. Carrier 来源边界

Server 当前会在以下 Auth 路径返回 `accessToken`。该 `accessToken` 是可作为 Admin 登录页输入的 session carrier 候选，但是否能进入 Admin 取决于后续平台角色校验。

| 来源 | Server endpoint | 当前语义 | Admin 可否作为正式登录来源 |
| --- | --- | --- | --- |
| OTP 登录 | `POST /server/auth/otp/login` | 建立 Server session，返回 `accessToken / refreshToken / expiresInSeconds / shellBootstrapState` | 可以，但 actor 必须具备平台 reviewer/super admin 角色 |
| refresh | `POST /server/auth/refresh` | 基于 refresh token 换新 access carrier | 可以，但仍必须绑定有效 session truth 与平台角色 |
| password login | `POST /server/auth/password/login` | 代码存在并可签发同类 accessToken；App-facing 是否主线需单独裁决 | 不作为 Admin 登录方式，不得写成 Admin 账号密码登录 |
| whitelist test session | `POST /server/auth/whitelist-test-session` | 受控测试会话签发，受 runtime gate 和手机号白名单限制 | 仅限非生产或 isolated 测试，不是正式登录方式 |

签发方式：

- `AccessCarrierService.issue()` 生成 opaque access carrier。
- token 结构为 `p1a.<payload>.<signature>`。
- payload 包含 `sessionId / organizationId / expiresAt / nonce`。
- 签名材料来自 Server runtime secret，不允许本地伪造。

代码依据：

- `apps/server/src/modules/auth/auth.controller.ts`
- `apps/server/src/modules/auth/auth-session.service.ts`
- `apps/server/src/modules/auth/auth-password.service.ts`
- `apps/server/src/modules/auth/auth-whitelist-test-session.service.ts`
- `apps/server/src/modules/auth/access-carrier.service.ts`
- `apps/server/src/shared/current-session-verification.ts`

依据类型：代码。

## 4. Password Login 裁决

本文件裁决：`password login` 不得作为 Admin 登录方式，不得被写成 Admin 账号密码体系。

当前仓库事实：

- Server 代码存在 `POST /server/auth/password/login`，成功后复用 Auth session envelope 并签发 `accessToken`。
- App-facing contracts / generated 中已出现 `POST /api/app/auth/password/login|set|reset`。
- `docs/01_contracts/auth_contracts.yaml` 与 `docs/01_contracts/identity_permission_minimum_contracts.yaml` 仍保留旧的 `account_password_plus_second_factor` Admin 术语。
- `docs/00_ssot/app_p0_b_contracts_runtime_drift_ruling_addendum.md` 曾将 password auth 标为 conditional / contract drift。
- `docs/00_ssot/app_p0_b_contracts_clean_window_ruling_addendum.md` 又将 app-facing password auth 裁成 `Formal active bounded auth`。

因此本文件不把 password login 自动扶正为 Admin 主线，也不在本文件内推翻或确认 App 用户侧 password auth 主线。需要单独清理：

- 若 App 当前阶段坚持 OTP-only，则 formal OpenAPI/generated 中的 password auth 必须降级或标记非 active。
- 若 App 当前阶段接受 bounded password auth，则 `auth_contracts.yaml` 的 `phone_code_plus_org_invite` 口径需要补充说明，避免与 generated path 冲突。
- 无论 App 侧如何裁决，Admin 仍保持 `server_session_carrier_only`，不接收账号密码。

依据类型：代码 / contracts / 文书 / 推断。

## 5. Whitelist-Test-Session 裁决

本文件裁决：`whitelist-test-session` 只能作为非生产或 isolated 受控测试入口，不是正式 Admin 登录方式。

启用条件：

- `AUTH_WHITELIST_TEST_SESSION_ENABLED=true`
- `AUTH_WHITELIST_TEST_SESSION_MOBILES` 包含目标手机号
- 运行时满足 `!isProduction || isIsolatedRuntime`
- 目标用户存在
- 目标用户在指定 organization 下有 active membership
- membership 的 `roleKey` 必须匹配请求中的 `roleKey`
- 如请求带 `certificationStatus`，还必须匹配当前认证状态

关键边界：

- 生产 `NODE_ENV=production` 且 `APP_NAME` 不含 `isolated` 时，该入口按代码设计不可启用。
- whitelist test session 创建的 session 在后续校验时仍会检查 runtime flag 和手机号白名单；白名单关闭或移除后，session 会被视为 revoked。
- 不允许把该入口包装成正式后台登录，不允许在生产主进程偷开。

代码依据：

- `apps/server/src/core/runtime-config.service.ts`
- `apps/server/src/modules/auth/auth-whitelist-test-session.service.ts`
- `apps/server/src/modules/auth/current-session-verification.service.ts`
- `apps/server/src/modules/auth/auth-command.parser.ts`

依据类型：代码。

## 6. Platform Role 门禁

Admin carrier 只证明当前请求有可验证 Server session，不等于拥有 Admin 权限。Server Admin API 继续以 DB-backed platform membership 做准入。

当前 reviewer 门禁：

- 必须先通过 `requireVerifiedCurrentSessionContext` 验证 carrier、session、用户状态。
- 再由 `CurrentActorEligibilityService.requireReviewer()` 查询当前用户 active membership。
- membership 必须属于 `organizationType = platform` 的平台组织。
- role 必须在 `platform_reviewer | platform_super_admin` 范围内。

当前 manual reviewer 门禁：

- 内容安全类 task 还允许 `safety_reviewer` 参与 manual review。
- 但平台级 Admin review / audit / governance 的主门禁仍应以 `platform_reviewer | platform_super_admin` 为准。

代码与合同依据：

- `apps/server/src/modules/organization/current-actor-eligibility.service.ts`
- `docs/01_contracts/identity_permission_minimum_contracts.yaml`
- `apps/server/src/modules/review/organization-review-query.service.ts`
- `apps/server/src/modules/audit/audit-log-query.service.ts`
- `apps/server/src/modules/content_safety/content-safety-review-task.query.service.ts`

依据类型：代码 / contracts。

## 7. 旧文书 `account_password_plus_second_factor` 裁决

本文件裁决：`account_password_plus_second_factor` 应降级为历史残留术语，不得继续描述当前 Admin 登录真相。

原因：

- 当前 Admin 代码没有账号密码表单。
- 当前 Admin 登录页只接收 `sessionCarrier`。
- 当前 Admin route guard 明确是 `server_session_carrier_only`。
- 当前 Server Admin API 权限不是从 Admin 账号密码派生，而是从 Server session + DB-backed platform membership 派生。

需要同步清理的文件：

- `docs/01_contracts/auth_contracts.yaml`
- `docs/01_contracts/identity_permission_minimum_contracts.yaml`
- 后续引用 `account_password_plus_second_factor` 的 SSOT / contracts 索引文书

推荐替换口径：

```yaml
admin:
  login_mode: server_session_carrier_only
  consumes: Server admin APIs
  issuer: Server Auth
  role_gate: platform_reviewer_or_super_admin
```

依据类型：代码 / contracts / 文书。

## 8. App 用户侧 OTP-Only 真相影响

Admin carrier-only 登录不影响 App 用户侧 OTP-only 真相。Admin 不经过 BFF，Flutter App 仍只访问 BFF，Admin 仍直连 Server Admin API。

但当前仓库存在 App auth 口径漂移，需独立裁决：

- `auth_contracts.yaml` 仍写 `flutter_app.login_mode: phone_code_plus_org_invite`。
- `openapi.yaml / openapi.bundle.json / generated` 已出现 app-facing password auth path。
- 多份 P0-B 文书对 password auth 的状态经历了 conditional -> formal active bounded auth 的演进。

因此：

- 若产品冻结为 App OTP-only，则 password auth paths 需要从 active contracts 降级或标记为 reserved。
- 若产品冻结为 bounded password auth，则 OTP-only 文书需要改成“OTP 为最小主线，password 为 bounded app-facing auth”，但不得影响 Admin。
- 本文件不改变 App 登录主线，只声明 Admin 登录不依赖、不消费、不展示 password login。

依据类型：contracts / 文书 / 代码 / 推断。

## 9. 不允许事项

以下事项不允许：

- 不允许生成、伪造、猜测或手写有效 admin session carrier。
- 不允许输出真实 token、真实密钥、真实账号隐私信息。
- 不允许新增 Admin 账号密码登录。
- 不允许新增管理员注册。
- 不允许把 `password/login` 写成 Admin 登录入口。
- 不允许把 `whitelist-test-session` 写成正式生产登录入口。
- 不允许把 Admin 接入改为 BFF。
- 不允许绕过 Server Admin API 的 platform role 校验。
- 不允许使用 raw `x-actor-role` 或类似 header 替代 DB-backed membership truth。
- 不允许把 `admin_session` cookie 当成业务真值；它只是浏览器侧 carrier 保存位。
- 不允许把 Admin 做成第二套身份系统或第二业务真值。

依据类型：Root AGENTS / 代码 / contracts / 推断。

## 10. 需要同步的 Contracts / Docs

需要同步但本文件不直接修改的项：

| 文件 | 当前问题 | 推荐动作 |
| --- | --- | --- |
| `docs/01_contracts/auth_contracts.yaml` | `admin.login_mode` 仍是 `account_password_plus_second_factor` | 改为 `server_session_carrier_only` |
| `docs/01_contracts/identity_permission_minimum_contracts.yaml` | `admin.login_mode` 仍是 `account_password_plus_second_factor` | 改为 `server_session_carrier_only`，并明确 issuer 为 Server Auth |
| `docs/01_contracts/openapi.yaml` | app-facing password auth 已出现，但与 OTP-only 旧口径存在漂移 | 单独裁决 App auth 主线；不得牵连 Admin |
| `packages/contracts/openapi/openapi.bundle.json` | 需跟随 OpenAPI 裁决 | 仅在 approved clean-window 中重新生成 |
| `packages/contracts/src/generated/**` | generated path 需跟随 OpenAPI 裁决 | 仅在 approved clean-window 中更新 |
| `docs/00_ssot/source_of_truth_map.md` | 需要登记本 addendum | 后续 SSOT 注册窗口补登记 |

依据类型：contracts / 文书 / 推断。

## 11. 下一步动作

唯一推荐下一步：开启一个小范围 `Admin auth truth docs clean-window`，只做文书与 contracts 口径同步，不改业务代码。

最小任务：

1. 将 Admin 旧登录术语从 `account_password_plus_second_factor` 替换为 `server_session_carrier_only`。
2. 明确 Admin issuer 是 `Server Auth`，Admin 只消费 carrier。
3. 明确 platform role gate 是 `platform_reviewer_or_super_admin`。
4. 单独列出 App password auth 与 OTP-only 的漂移，不在 Admin 文书里裁成后台登录。
5. 用受控 reviewer carrier 做一次 Admin `/login -> /audit or /review` 人工 smoke，但不记录 token。

进入实现前门禁：

- 不能修改 Server / BFF / DB / OpenAPI generated，除非另开合同清理窗口。
- 不能要求生成 carrier；只能使用 Server Auth 返回的合法 `accessToken`。
- 没有 reviewer/super admin membership 的普通 App session 不能算 Admin 登录通过。

最终裁决：Admin 登录真相为 `Go for carrier-only truth freeze`；Admin 独立账号密码体系为 `No-Go`；生产 whitelist-test-session 为 `No-Go`；App password auth 主线为 `待独立裁决`。
