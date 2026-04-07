---
owner: 独立联合核验
status: completed
purpose: Independent combined code verification for Package 1 BFF and Flutter read-only fail-closed surfaces, without treating compile or UI wiring as full auth or trade-flow unlock.
layer: L0 SSOT
decision_date_local: 2026-04-03
inputs_canonical:
  - AGENTS.md
  - apps/bff/src/core/auth/auth-context.service.ts
  - apps/bff/src/routes/routes.module.ts
  - apps/bff/src/routes/shell/shell.module.ts
  - apps/bff/src/routes/shell/shell.controller.ts
  - apps/bff/src/routes/shell/shell.service.ts
  - apps/bff/src/routes/profile/profile-read.module.ts
  - apps/bff/src/routes/profile/profile-read.controller.ts
  - apps/bff/src/routes/profile/profile-read.service.ts
  - apps/bff/src/core/idempotency/idempotency.service.ts
  - apps/bff/src/core/core.module.ts
  - apps/bff/src/app.module.ts
  - apps/bff/src/main.ts
  - apps/mobile/lib/core/boot/app_bootstrap_controller.dart
  - apps/mobile/lib/shell/presentation/shell_state_page.dart
  - apps/mobile/lib/features/profile/presentation/profile_page.dart
  - apps/mobile/lib/features/profile/presentation/profile_detail_pages.dart
  - apps/mobile/lib/features/profile/presentation/profile_identity_access_pages.dart
  - apps/mobile/lib/features/profile/presentation/profile_organization_pages.dart
  - apps/mobile/test/profile_page_test.dart
  - apps/mobile/test/shell_app_test.dart
---

# 展览项目发布-竞标-履约治理四文书
# Package 1 BFF Flutter Combined Verification Addendum

## 1. Review Scope

- 本轮只做一次联合代码核验，不做新实现，不做新冻结文书，不做 migration，不做发布。
- 本轮只核验：
  - BFF 4 条只读 route 是否仍符合当前 Package 1 边界
  - Flutter 是否真实消费 fail-closed / unavailable / pending / rejected 状态
  - 两侧是否仍避免伪造 full auth / BFF happy-path / 交易流 happy-path
  - 当前是否足以进入“联动发布 pre-release smoke”

## 2. Review Basis

- BFF 代码证据：
  - [auth-context.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/core/auth/auth-context.service.ts)
  - [routes.module.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/routes.module.ts)
  - [shell.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/shell/shell.controller.ts)
  - [shell.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/shell/shell.service.ts)
  - [profile-read.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/profile/profile-read.controller.ts)
  - [profile-read.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/profile/profile-read.service.ts)
  - [idempotency.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/core/idempotency/idempotency.service.ts)
  - [core.module.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/core/core.module.ts)
  - [app.module.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/app.module.ts)
  - [main.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/main.ts)
- Flutter 代码证据：
  - [app_bootstrap_controller.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/core/boot/app_bootstrap_controller.dart)
  - [shell_state_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/shell/presentation/shell_state_page.dart)
  - [profile_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/profile/presentation/profile_page.dart)
  - [profile_detail_pages.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/profile/presentation/profile_detail_pages.dart)
  - [profile_identity_access_pages.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/profile/presentation/profile_identity_access_pages.dart)
  - [profile_organization_pages.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/profile/presentation/profile_organization_pages.dart)
  - [profile_page_test.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/test/profile_page_test.dart)
  - [shell_app_test.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/test/shell_app_test.dart)

## 3. Combined Verification Findings

### 3.1 BFF pass findings

- BFF 当前确实保留了 4 个对应的 read-only surface consumer：
  - shell context
  - profile index
  - organization mine
  - certification current
- `AuthContextService` 当前仍然只是 transport / hint 归集与转发，不做 current-session verification。
- `ShellService` 与 `ProfileReadService` 只把 401/403/404 规整成受控 envelope，并把 payload 整形成最小 view model；未见本地 auth truth 派生。
- `IdempotencyService` 仍只是内存缓存工具，未见被扩张成 session / auth / business truth owner。

### 3.2 BFF fail findings

- 代码内真正注册的 controller path 不是题目要求的 `/api/app/*`，而是：
  - [shell.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/shell/shell.controller.ts#L5) 的 `/bff/shell/context`
  - [profile-read.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/profile/profile-read.controller.ts#L5) 的 `/bff/profile/index`
  - [profile-read.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/profile/profile-read.controller.ts#L14) 的 `/bff/profile/organization/mine`
  - [profile-read.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/profile/profile-read.controller.ts#L19) 的 `/bff/profile/certification/current`
- [main.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/main.ts) 未设置 global prefix，也未见 repo-local code 内的 `/api/app/*` path registration。
- 因此仅凭当前 BFF 代码，不能证明题目要求的 4 条 `/api/app/*` route 已由 BFF 本体直接暴露。
- `apps/bff` 全量 `./node_modules/.bin/tsc --noEmit` 失败，错误来自 `src/routes/forum/**` 缺失 service 文件；这说明当前 BFF workspace 不是全量 type-clean。

### 3.3 Flutter pass findings

- `AppBootstrapController` 与 `ShellStatePage` 已把 403/404/unavailable/offline/session_refreshing/no_organization 分开呈现，不再都折叠成 offline。
- `ProfilePage` 在无会话或资料未返回时，明确显示“不会伪造账号摘要”，不会伪造成功摘要或企业卡片。
- `ProfileCompanyPage` 与 `CertificationStatusPage` 对 `no session / empty / unavailable / unauthorized / forbidden / notFound / rejected` 都有真实受控呈现。
- `OrganizationHandoffPage`、`OrganizationCreatePage`、`OrganizationJoinPage`、`SessionCenterPage` 明确把 `create / join / switch / devices` 留在待开放或只读状态，没有继续伪装成当前可用能力。
- 指定 Flutter 测试通过，且覆盖了关键 fail-closed 行为：
  - [profile_page_test.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/test/profile_page_test.dart#L475) `company page stays fail-closed when organization surface is unavailable`
  - [shell_app_test.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/test/shell_app_test.dart#L2423) `shell context not found stays unavailable instead of offline`

### 3.4 Flutter fail findings

- [profile_identity_access_pages.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/profile/presentation/profile_identity_access_pages.dart#L83) 仍保留一个 `kDebugMode` 下的 dev-test-channel quick login：
  - 直接写入 fake access token / refresh token / deviceId
  - 直接写入 fake `userId / organizationId / roleKeys / certificationStatus=verified / membershipStatus=active`
  - 直接跳转到 `projectCreate`
- 这意味着 Flutter 代码里仍存在 debug-only fake session / fake org / fake approved fallback。
- [shell_app_test.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/test/shell_app_test.dart#L585) 还显式保留了该通道的测试：`debug test channel enters project create without auth or workbench requests`
- 因此当前不能宣称“没有 fake happy path”。

## 4. Verification Commands And Results

| Command | Result |
| --- | --- |
| `rg -n "@Controller\\('bff/(shell|profile)'\\)|@Get\\('context'\\)|@Get\\('index'\\)|@Get\\('organization/mine'\\)|@Get\\('certification/current'\\)" apps/bff/src/routes` | 确认 BFF 本地 controller 注册的是 `/bff/shell/*` 与 `/bff/profile/*`。 |
| `./node_modules/.bin/tsc --noEmit` in [apps/bff](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff) | 退出码 `2`；报错为 `src/routes/forum/**` 缺失 `forum-interaction.service` / `forum-report.service` / `forum-publish-result.service`。 |
| `./node_modules/.bin/nest build` in temporary mirror of [apps/bff](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff) plus `packages/contracts` | 退出码 `0`；说明当前 build slice 可编译，但不覆盖全量 `tsc` 红灯。 |
| `flutter analyze` in temporary mirror of [apps/mobile](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile) | 退出码 `1`；日志显示 19 个现存 warning/info，无本轮 profile/shell fail-closed 直接阻断错误，但 package 不是 analyze-clean。 |
| `flutter test test/profile_page_test.dart test/shell_app_test.dart` in temporary mirror of [apps/mobile](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile) | 退出码 `0`；`All tests passed!`，共 81 个测试通过。 |

## 5. Stage Decision

- 核验结论：`FAIL`
- Stage decision：`No-Go` for 联动发布 pre-release smoke only
- 原因：
  - 仅凭当前 BFF 代码，不能证明题目要求的 4 条 `/api/app/*` route 由 BFF 本体直接注册；代码内实际 controller path 仍是 `/bff/*`
  - `apps/bff` 全量 `tsc --noEmit` 仍失败，BFF workspace 不是全量 type-clean
  - Flutter 仍保留 debug-only fake session / fake org / fake approved quick-login path，因此不能宣称“没有伪造 happy path”

## 6. Explicit Non-conclusions

- 本轮不能把 fail-closed UI consumption 读成 runtime-ready。
- 本轮不能把 build slice 通过读成业务闭环已通。
- 本轮不能把当前结果读成 full auth unlock。
- 本轮不能把当前结果读成 BFF happy-path unlock。
- 本轮不能把当前结果读成交易流 unlock。
