---
owner: Codex 总控
status: draft
layer: L0 SSOT
scope: Admin Day 2 权限与 protected route 证据闭合
created_at: 2026-05-11
---

# Admin Day 2 权限与 Protected Route 证据闭合

## 1. 总裁决

Day 2 目标是关闭 `P0-1` 的本地证据缺口：证明 Admin UI 不替代 Server role gate，且 raw role header 不能绕过 DB-backed platform membership。

当前本地裁决：`PASS`。

云端 runtime 裁决：`UNKNOWN`。本文件不声明云端已通过。

## 2. 代码证据

| 证据 | 路径 | 结论 |
| --- | --- | --- |
| Admin protected route guard | `apps/admin/src/core/auth/route-guard.ts` | 缺少 `admin_session` 时受保护路径返回登录跳转；有 session carrier 时允许进入页面壳 |
| Admin middleware matcher | `apps/admin/src/middleware.ts` | `/review`、`/governance`、`/project_review`、`/template_config`、`/audit`、`/membership`、`/ticketing` 被保护 |
| Server reviewer gate | `apps/server/src/modules/organization/current-actor-eligibility.service.ts` | `requireReviewer()` 查询 active membership，并要求 membership 所属 organization 为 `platform` |
| Header hint 边界测试 | `apps/server/test/admin-role-gate-header-hint.test.cjs` | raw `x-actor-role` / `x-role` 不能替代 DB-backed membership |
| Admin route guard 测试 | `apps/admin/test/admin-route-guard.test.cjs` | protected route 缺 session 时跳 `/login?next=...` |

## 3. 本地测试结果

```bash
cd apps/server && node --test test/admin-role-gate-header-hint.test.cjs
```

结果：`2 pass / 0 fail`。

覆盖点：

- raw `x-actor-role = platform_super_admin` 不能绕过 DB-backed platform reviewer membership。
- DB-backed `platform_reviewer` membership 能通过 reviewer gate，即使 raw role header hint 写成其他角色。

```bash
cd apps/admin && node --test test/admin-route-guard.test.cjs
```

结果：`15 pass / 0 fail`。

覆盖点：

- `/project_review`
- `/review/change_requests`
- `/review/enterprise_hub_applications`
- `/review/organizations`
- `/audit`
- `/membership`
- `/template_config`
- `next` 参数安全清洗

## 4. 权限边界冻结

当前 Admin 权限边界如下：

1. `admin_session` 只是浏览器侧 carrier 保存位，不是权限真值。
2. Admin UI route guard 只负责页面级 fail-close，不负责最终权限裁决。
3. Server Admin API 最终权限由 `requireVerifiedCurrentSessionContext()` 和 `CurrentActorEligibilityService.requireReviewer()` 共同判定。
4. raw `x-actor-role` / `x-role` 只能作为兼容或调试 hint，不能作为 reviewer 权限真值。
5. 平台 reviewer 权限必须来自 DB-backed active membership，且 organization type 必须为 `platform`。

## 5. 人工 runtime 核验清单

以下核验需要在受控 runtime 环境完成；本文件不执行云端访问，也不记录真实 token、密码或账号隐私。

| 编号 | 场景 | 输入 | 期望结果 | 通过标准 |
| --- | --- | --- | --- | --- |
| R-1 | 未登录打开 `/audit` | 无 `admin_session` | 跳转 `/login?next=%2Faudit` 或 Server API 返回 401 | 不进入业务数据页面 |
| R-2 | 未登录打开 `/project_review` | 无 `admin_session` | 跳转 `/login?next=%2Fproject_review` 或 Server API 返回 401 | 不进入案件数据页面 |
| R-3 | 无 platform reviewer 角色 carrier 调用 Server Admin API | 有效普通用户 carrier | 403 | 不能只靠 header hint 进入 |
| R-4 | 伪造 `x-actor-role=platform_super_admin` 但无 DB-backed membership | 普通用户 carrier + spoofed header | 403 | raw role header 不生效 |
| R-5 | 有 platform reviewer / platform_super_admin membership 的 carrier | 受控 reviewer carrier | 200 或业务列表空态 | Server verified session + DB membership 生效 |

## 6. Day 2 准入下一天裁决

Day 2 本地证据已闭合。准入 Day 3 条件：

- Server role gate 防误用测试通过。
- Admin protected route 测试通过。
- runtime 仍标记为 `UNKNOWN`，不把本地 PASS 写成云端 PASS。
- 不生成、不输出、不伪造任何真实 carrier。

当前裁决：`PASS`。
