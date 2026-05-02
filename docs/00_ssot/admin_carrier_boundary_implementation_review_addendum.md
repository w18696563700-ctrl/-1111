---
owner: Codex 总控
status: draft
layer: L1 SSOT Addendum
created_at: 2026-05-01
purpose: Review Admin carrier boundary implementation semantics after carrier-only truth freeze.
---

# Admin Carrier Boundary Implementation Review Addendum

## 1. 当前裁决复述

当前正式裁决保持不变：

- Admin 没有独立账号密码登录体系。
- Admin 没有管理员注册体系。
- Admin 登录页只消费 `Server Auth` 已签发的管理员 session carrier。
- Admin 前端验证 carrier 后，仅把 carrier 写入浏览器侧 `admin_session` cookie。
- Admin 后续请求应把 `admin_session` 转为 `Authorization: Bearer <carrier>`，直连 `Server Admin API`。
- Server Admin API 的最终准入必须来自 Server 侧 verified current-session context 与 DB-backed platform membership truth。
- 平台治理主门禁为 `platform_reviewer | platform_super_admin`；内容安全 manual review 的 `safety_reviewer` 例外只可作为受控审核角色，不得泛化为全 Admin 平台治理权限。

依据类型：文书 / contracts / 代码。

## 2. Admin Carrier 读取链路

| 环节 | 当前实现 | 语义判断 | 依据类型 |
| --- | --- | --- | --- |
| 登录页表单 | `/login` 页使用 `sessionCarrier` textarea 接收 raw carrier 或完整 Bearer 头 | 符合 carrier-only，不接收账号密码 | 代码 |
| 输入规范化 | `normalizeAdminSessionCarrier()` 去除 `Bearer ` 前缀并拒绝空值 | 符合 carrier-only | 代码 |
| 写入前验证 | `connectAdminSessionCarrierAction()` 先调用 `verifyAdminSessionCarrier()`，再写 `admin_session` cookie | 符合“不伪造登录成功” | 代码 |
| cookie 保存位 | `ADMIN_SESSION_COOKIE = admin_session`，cookie 为 httpOnly、sameSite=lax、生产 secure | 符合浏览器侧 carrier 保存位，不是业务真值 | 代码 |
| 受保护路由读取 | middleware 从 request cookie 读取 `admin_session`，无 carrier 时跳 `/login?next=...` | 符合最小 route guard，但只判断 carrier 存在，不在 Admin 层做角色真值判断 | 代码 / 推断 |
| 页面状态读取 | `/login` 读取 `admin_session` 仅用于显示“已接入 / 未接入”状态 | 符合 UI 状态展示，不等于权限真值 | 代码 |

关键文件：

- `apps/admin/src/app/login/page.tsx`
- `apps/admin/src/core/auth/route-guard.ts`
- `apps/admin/src/core/auth/session-carrier-actions.ts`
- `apps/admin/src/middleware.ts`

结论：读取与保存链路总体符合 `server_session_carrier_only`。Admin route guard 只做“是否有 carrier”的前置 UI 保护，最终权限仍必须由 Server 校验。

## 3. Admin Carrier 转发链路

| 环节 | 当前实现 | 语义判断 | 依据类型 |
| --- | --- | --- | --- |
| cookie -> Authorization | `toAdminAuthorizationCarrier()` 将 carrier 包装为 `Bearer <carrier>` | 符合 Server Admin API transport carrier 语义 | 代码 |
| 普通 Admin API 请求 | `adminJsonRequest()` 通过 `buildServerAdminHeaders()` 构造 Server Admin API headers | 符合直连 Server Admin API，不经过 BFF | 代码 |
| 验证 probe | `verifyAdminSessionCarrier()` 显式传入 `incomingHeaders: new Headers()` 和待验证 `sessionCarrier` | 符合验证链路，不受页面 incoming Authorization 污染 | 代码 / tests |
| 普通 runtime | `readAdminApiRuntimeFromNext()` 同时读取 incoming headers 与 `admin_session` cookie | 存在边界语义风险，见第 4 节 | 代码 |

结论：验证 probe 是安全的；普通 Admin API runtime 的 carrier 来源优先级需要后续最小修正。

## 4. incoming Authorization 语义判断

当前实现：

```ts
const authorization =
  readForwardHeader(input.incomingHeaders, 'authorization') ??
  toAdminAuthorizationCarrier(input.sessionCarrier);
```

语义判断：

- `incoming Authorization` 当前优先于 `admin_session` cookie。
- 这不是 Admin password login，也不是新增登录方式。
- Server 仍会验证 `Authorization` carrier，因此 raw header 本身不是权限真值。
- 但该优先级弱化了“Admin 后续请求由 `admin_session` 转为 Authorization”的冻结口径。
- 如果某个受保护 Admin 页面请求同时带有合法 `admin_session` 与外来 `Authorization`，当前 runtime 会优先转发外来 `Authorization`，而不是 cookie 中的 Admin carrier。

当前裁决：Conditional Pass。

原因：

- 不冲突于“Admin 不接收账号密码”。
- 不冲突于“Server 仍是最终认证与权限真值”。
- 但与更严格的 `server_session_carrier_only` 实现语义存在漂移：Admin runtime 不应默认优先使用 incoming Authorization。

最小修正方向：

- 后续代码 clean-window 中，将普通 Admin runtime 改为优先使用 `admin_session` cookie。
- 更稳方案是普通 runtime 完全忽略 incoming `Authorization`，只保留 request-id / trace-id 等审计关联头。
- 如测试仍需覆盖 raw Authorization，可仅通过 `setAdminApiRuntimeForTest()` 或显式 test override 注入，不进入生产 Next runtime 默认路径。

依据类型：代码 / tests / 文书 / 推断。

## 5. `x-actor-role` / `x-role` 语义判断

当前实现：

- Admin runtime 会转发 `x-actor-role`。
- Admin runtime 会转发 `x-role`。
- Admin tests 中存在 `platform_reviewer` 的 header hint 样例。
- Server `RequestContext` 会读取 `x-actor-role` 为 `actorRole` 字段。

语义判断：

- `x-actor-role` / `x-role` 只能是 forwarding hint、调试提示或兼容字段。
- 它们不能替代 Server verified current-session context。
- 它们不能替代 DB-backed platform membership truth。
- 当前扫描到的平台 Admin 主路径仍通过 `requireVerifiedCurrentSessionContext()` 与 `CurrentActorEligibilityService.requireReviewer()` 做最终角色判断。
- 当前未在扫描范围内发现 Server platform reviewer gate 直接信任 raw `x-actor-role` / `x-role` 的实现。

当前裁决：Pass with Documentation Risk。

风险：

- Admin runtime 与 tests 仍显式转发 role hint，容易让后续实现者误把 header role 当成权限真值。
- `RequestContext.actorRole` 字段存在，未来新增服务时有被误用风险。

最小修正方向：

- 短期文书必须继续明确：header role 是 hint，不是 auth truth。
- 后续 tests 应新增断言：即使 incoming `x-actor-role=platform_super_admin`，无 DB-backed platform membership 仍不得通过 Server reviewer gate。
- 如后续安全收紧，可从 Admin runtime 默认转发列表中移除 `x-actor-role` / `x-role`，只保留 trace/audit 头；但这需要独立兼容性评估。

依据类型：代码 / contracts / 推断。

## 6. Server Platform Role Gate 判断

当前 Server 平台角色门禁链路：

1. Controller 将 headers 转为 `RequestContext`。
2. Service 调用 `requireVerifiedCurrentSessionContext(context, currentSessionVerificationService)`。
3. Server Auth / session resolver 验证 current-session carrier。
4. `CurrentActorEligibilityService.requireReviewer()` 根据 verified session 中的 user 查询组织成员关系。
5. membership 必须 `memberStatus = active`。
6. membership role 必须命中 `platform_reviewer | platform_super_admin`。
7. membership 所属组织必须是 `organizationType = platform`。

已核对的代表路径：

| Server 模块 | 当前门禁 | 判断 |
| --- | --- | --- |
| `enterprise_hub` admin publish/offline/freeze/recommendation-slots | `requireVerifiedCurrentSessionContext()` + `requireReviewer()` | Pass |
| `enterprise_hub` application review | `requireVerifiedCurrentSessionContext()` + `requireReviewer()` | Pass |
| `enterprise_hub` published change review | `requireVerifiedCurrentSessionContext()` + `requireReviewer()` | Pass |
| `exhibition_report_cases` admin case queue / detail / action | `requireVerifiedCurrentSessionContext()` + `requireReviewer()` | Pass |
| `content_safety` review tasks | `requireVerifiedCurrentSessionContext()` + `requireManualReviewer()`，可 fallback 到 `requireReviewer()` | Conditional: DB-backed gate pass，但 role set 包含 `safety_reviewer` |

结论：

- Server 平台治理主门禁仍来自 DB-backed membership truth，不来自 Admin UI、Admin runtime 或 header hint。
- `content_safety` 的 manual reviewer 角色集比 `platform_reviewer_or_super_admin` 更宽；这不等于绕过 DB truth，但需要在 Admin 登录验证 probe 与角色边界文书中保持明确。

依据类型：代码 / contracts。

## 7. 当前是否与 `server_session_carrier_only` 冲突

| 项 | 裁决 | 原因 |
| --- | --- | --- |
| Admin 登录页接收 carrier | 不冲突 | 页面只接收 `sessionCarrier`，无账号密码字段 |
| `admin_session` cookie 写入 | 不冲突 | 写入前调用 Server Admin probe |
| route guard | 不冲突 | 只做 carrier 存在性保护，不充当权限真值 |
| verify probe | 基本不冲突 | 显式清空 incoming headers；但 probe 所用 content-safety role set 可能宽于平台治理主门禁 |
| 普通 Admin API runtime | 条件冲突 | 当前 incoming `Authorization` 优先于 `admin_session` |
| `x-actor-role` / `x-role` | 不构成当前权限绕过，但有解释风险 | Server 主门禁仍走 DB-backed membership |

总裁决：Conditional Pass。

原因：carrier-only 登录真相成立；但普通 runtime 的 incoming Authorization 优先级与 role hint 转发需要后续最小实现修正或更明确文书边界。

## 8. 是否需要改代码

需要，但不在本轮执行。

后续最小代码修正建议：

1. 将 Admin 普通 runtime 的 Authorization 来源调整为：
   - 优先 `admin_session` cookie；
   - 若无 cookie，则不转发 incoming Authorization；
   - test runtime 如需注入 Authorization，必须走显式 test override。
2. 保留 `verifyAdminSessionCarrier()` 的 `incomingHeaders: new Headers()` 语义。
3. 评估是否从 Admin runtime 默认转发列表移除 `x-actor-role` / `x-role`。
4. 若不移除，则在代码注释与 tests 中明确它们是 hint，不能作为权限真值。

依据类型：代码 / 推断。

## 9. 是否需要改文书

本轮需要新增本报告草案。

后续可选文书更新：

- 在 `docs/05_admin/admin_ssot.md` 增加本报告索引。
- 在 Admin carrier boundary implementation patch 通过后，补一条执行回执，登记 runtime 已改为 cookie-first 或 cookie-only。
- 不需要改 OpenAPI。
- 不需要改 generated types。
- 不需要把 password login 纳入 Admin 登录。

依据类型：文书 / 推断。

## 10. 是否需要改 tests

需要，但不在本轮执行。

后续最小测试点：

1. Admin runtime 当 `admin_session` 存在且 incoming `Authorization` 同时存在时，必须转发 `admin_session` 对应的 `Bearer`。
2. Admin runtime 当无 `admin_session` 时，不应默认转发 incoming `Authorization` 到 Server Admin API。
3. `verifyAdminSessionCarrier()` 继续证明：验证 probe 使用传入 carrier，不转发 stale incoming Authorization。
4. Server reviewer gate 测试证明：raw `x-actor-role=platform_super_admin` 不足以通过，必须有 verified session + DB-backed platform membership。
5. 如保留 `safety_reviewer`，补充测试或文书说明：它只适用于 content-safety manual review，不等同于全平台治理 Admin role。

依据类型：tests / 推断。

## 11. 最小修正建议

优先级排序：

| 优先级 | 修正项 | 范围 | 是否改 contracts |
| --- | --- | --- | --- |
| P0 | Admin runtime Authorization 改为 cookie-first 或 cookie-only | `apps/admin/src/core/server/admin-api-runtime.ts` + tests | 否 |
| P0 | 增加 tests 防止 incoming Authorization 覆盖 `admin_session` | `apps/admin/test/admin-api-client.test.cjs` | 否 |
| P1 | 增加 Server role gate 防误用测试 | Server organization / admin route tests | 否 |
| P1 | 决定是否移除 `x-actor-role` / `x-role` 默认转发 | Admin runtime + tests | 否，除非要更新兼容说明 |
| P1 | 明确 `safety_reviewer` 是否允许通过 Admin login probe | docs + possibly probe endpoint | 否，除非新增正式 endpoint |

推荐最小方案：

- 只做 P0 两项：Admin runtime cookie-first / cookie-only + Admin tests。
- 不新增 Admin endpoint。
- 不改 Server Auth 行为。
- 不改 OpenAPI/generated。

更稳方案：

- 新增一个受控 Server Admin `session/me` 或 `whoami` endpoint，专门验证 platform reviewer gate。
- 该方案更准确，但涉及 Server API 与合同边界，当前不作为本轮最小修正。

## 12. 不允许事项

- 不允许新增 Admin 账号密码登录。
- 不允许新增 Admin 注册。
- 不允许把 App password login 扶正为 Admin login。
- 不允许把 whitelist-test-session 写成正式 Admin 登录方式。
- 不允许让 Admin UI 状态替代 Server 角色门禁。
- 不允许让 Admin runtime header hint 替代 DB-backed platform membership truth。
- 不允许把 raw `x-actor-role` / `x-role` 当成权限真值。
- 不允许把 `admin_session` cookie 当成业务真值；它只是 carrier 保存位。
- 不允许绕过 `Server Admin API`。
- 不允许改 OpenAPI/generated 来掩盖实现边界问题。
- 不允许输出真实 token、手机号、密钥。

## 13. 下一步唯一动作

提交一份单独的「Admin runtime carrier source precedence 最小实现方案」给人工审核。

该方案只应覆盖：

- `apps/admin/src/core/server/admin-api-runtime.ts`
- `apps/admin/test/admin-api-client.test.cjs`
- 必要时更新 `docs/05_admin/admin_ssot.md` 的索引

不得覆盖：

- Server Auth 行为
- BFF
- OpenAPI
- generated types
- Admin password login
- whitelist-test-session

## 14. 最终裁决

| 项 | 裁决 |
| --- | --- |
| Admin carrier 读取 / 保存链路 | PASS |
| Admin carrier 验证 probe | PASS with role-scope note |
| Admin 普通 API 转发链路 | CONDITIONAL PASS |
| incoming Authorization 语义 | NEEDS MINIMAL CODE FIX |
| `x-actor-role` / `x-role` 语义 | PASS WITH DOCUMENTATION RISK |
| Server platform role gate | PASS |
| 是否与 `server_session_carrier_only` 根原则冲突 | 不构成根原则失败，但存在 runtime 边界漂移 |
| 是否需要本轮改代码 | 否 |
| 是否需要后续改代码 | 是，最小改 Admin runtime + tests |
| 是否需要改 contracts/generated | 否 |
