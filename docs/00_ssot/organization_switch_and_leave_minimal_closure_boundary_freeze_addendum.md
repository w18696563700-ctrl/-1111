---
title: 组织切换与退出组织最小闭环边界冻结单
status: active
owner: Codex Control
scope: profile_organization_identity_governance
created_at: 2026-05-01
---

# 组织切换与退出组织最小闭环边界冻结单

## 1. 冻结结论

本轮正式冻结为 `组织切换 + 退出当前组织` 的最小闭环治理，不进入组织删除、组织注销、组织合并、组织转让、认证资料清空或平台客服代操作后台。

本轮执行顺序必须为：

1. 先复用既有组织切换真链路。
2. 再冻结退出组织 contract 与状态规则。
3. 再实现 Server 自助退出组织接口。
4. 再由 BFF 透传与错误整形。
5. 最后由 Flutter 展示入口、确认弹窗和状态刷新。

## 2. 当前已确认真相

### 2.1 组织切换已有真实链路

- App-facing path:
  - `POST /api/app/profile/organization/switch`
- Server path:
  - `POST /server/profile/organization/switch`
- 当前切换语义：
  - 只能切换到当前账号已拥有 active membership 的组织。
  - Server 更新当前 session 的 `organization_id`。
  - BFF 只透传与整形 shell-compatible response。
  - Flutter 已有 `ProfileIdentityRoutes.organizationSwitch` 与组织切换页面基础能力。

### 2.2 组织列表已有真实读取链路

- App-facing path:
  - `GET /api/app/profile/organization/mine`
- 当前列表语义：
  - 返回当前账号可访问组织。
  - `current = true` 表示当前 session 组织。
  - 组织、成员身份、认证状态都来自 Server truth。

### 2.3 成员管理已有最小管理链路

- App-facing paths:
  - `GET /api/app/profile/organization/members`
  - `PATCH /api/app/profile/organization/members/{memberId}/role`
  - `PATCH /api/app/profile/organization/members/{memberId}/disable`
- 当前成员禁用语义：
  - 管理员可禁用其他 active 成员。
  - 禁止禁用当前 session 绑定的自己。
  - 禁止禁用后导致组织没有 active admin。

### 2.4 退出当前组织尚未冻结正式能力

当前未发现正式 `leave current organization` app-facing / server-facing contract。现有 `disable member` 不能直接等价为用户自助退出，因为它：

- 需要管理员权限。
- 禁止操作当前 session 自己。
- 语义是管理员禁用成员，不是用户主动退出。

因此本轮需要新增受控自助退出组织能力。

## 3. 本轮 In Scope

### 3.1 Flutter

- 在 `公司认证与我的身份` 或组织详情/切换页提供明确组织切换入口。
- 展示我加入的组织列表，标识当前组织。
- 切换组织前展示确认弹窗。
- 成功切换后刷新：
  - shell/context
  - organization/mine
  - certification/current
  - 当前页面状态
- 在组织详情/切换页提供 `退出当前组织` 入口。
- 退出组织前展示二次确认弹窗。
- 退出成功后刷新 shell/context 与组织列表。
- 若无剩余组织，进入未加入组织状态，并提供创建/加入组织入口。

### 3.2 BFF

- 新增 app-facing path:
  - `POST /api/app/profile/organization/current/leave`
- BFF 只负责：
  - 转发 Server command。
  - 整形 response。
  - 映射用户可理解错误文案。
- BFF 不拥有 membership truth，不改写业务状态机。

### 3.3 Server

- 新增 server-facing path:
  - `POST /server/profile/organization/current/leave`
- Server 是退出组织唯一业务真相 owner。
- Server 必须：
  - 校验当前 session 有 `organizationId`。
  - 校验当前 actor 在当前组织有 active membership。
  - 如当前 actor 是 admin，确认另有 active admin。
  - 将当前 membership 标记为 `removed`。
  - 记录审计日志 `OrganizationMemberLeft`。
  - 将当前用户所有指向已退出组织的 valid sessions 迁移到下一个 active organization；没有则置空。
  - 返回 `leftOrganizationId`、`nextOrganizationId`、`shellBootstrapState`、`traceId`。

### 3.4 Contracts / SSOT

- `docs/00_ssot` 新增本冻结单。
- `docs/01_contracts` 新增 / 更新退出组织 contract。
- 若后续生成 contracts package，必须确保 generated output 与 OpenAPI 同步。

## 4. 本轮 Explicit Out Of Scope

- 不删除组织。
- 不注销公司。
- 不合并重复组织。
- 不转让组织所有权。
- 不清空组织认证资料。
- 不删除历史项目、竞标、消息、订单、评价、审核、审计。
- 不改变 `organization_certifications` 的认证历史。
- 不做 Admin 代退后台。
- 不做批量成员治理。
- 不引入本地假 BFF / Server。
- 不让 Flutter 直连 Server。
- 不把 mock 或测试数据作为生产事实。

## 5. 退出组织状态规则

### 5.1 可退出条件

当前用户允许退出当前组织，当且仅当：

- 当前 session 已认证。
- 当前 session 存在 current organization scope。
- 当前用户在 current organization 中有 active membership。
- 如果当前 membership 是 `buyer_admin` 或 `supplier_admin`，组织内还存在另一个 active admin。

### 5.2 禁止退出条件

必须阻断并返回受控错误：

- 当前未登录。
- 当前 session 没有 organization scope。
- 当前 membership 不存在。
- 当前 membership 不是 active。
- 当前 actor 是最后一个 active admin。
- 当前组织已不可用。

### 5.3 退出后的数据语义

- membership 状态变为 `removed`。
- 不删除 `organizations`。
- 不删除 `organization_certifications`。
- 不删除项目、竞标、消息、订单、评价与审计。
- 历史记录继续保持原组织归属。
- 退出用户不再以该组织身份访问当前组织私域能力。

### 5.4 退出后的 session 语义

- Server 必须处理当前用户所有 valid sessions。
- 所有绑定到已退出组织的 valid sessions：
  - 若用户还有其他 active app-facing organization，则切换到最近 joined 的组织。
  - 若没有其他 active organization，则 `organization_id = null`。
- 新 access token 仍由既有 refresh / login 链路处理；本接口返回 shell-compatible summary，供 Flutter 立即刷新 shell/context。

## 6. Contract 草案

### 6.1 Request

`POST /api/app/profile/organization/current/leave`

```json
{
  "reason": "用户主动退出当前组织"
}
```

`reason` 可选；如果提供，必须是字符串，长度上限按后续 contract 固定。

### 6.2 Response

```json
{
  "leftOrganizationId": "uuid",
  "nextOrganizationId": "uuid-or-null",
  "shellBootstrapState": "authenticated-or-no_organization",
  "traceId": "trace-id"
}
```

### 6.3 错误边界

- `ORGANIZATION_SCOPE_REQUIRED`
- `ORGANIZATION_MEMBER_UNAVAILABLE`
- `ORGANIZATION_MEMBER_LEAVE_INVALID`
- `ORGANIZATION_LAST_ADMIN_LEAVE_BLOCKED`
- `AUTH_SESSION_INVALID`

实际错误码命名以后续 `docs/01_contracts/error_codes.yaml` 冻结为准，但语义不得改变。

## 7. 低风险施工路径

### 第 1 阶段

只做组织切换入口增强，复用已有 `organization/switch`。

### 第 2 阶段

冻结退出组织 contract 与状态规则，不写实现。

### 第 3 阶段

Server 新增自助退出能力，测试覆盖最后管理员、普通成员、session rebinding。

### 第 4 阶段

BFF app-facing 透传与错误文案。

### 第 5 阶段

Flutter 增加退出入口、确认弹窗、成功/失败状态刷新。

### 第 6 阶段

真实隧道联调与真机验收。

## 8. 风险判断

### 最稳方案

先只上线组织切换入口增强。该方案完全复用既有 Server/BFF truth，风险最低。

### 最低成本方案

只在 Flutter 暴露已有组织切换页并加强确认文案，不新增退出组织。

### 最适合当前阶段方案

本轮采用 `组织切换入口增强 + 受控退出当前组织`。它解决用户当前真实困惑，同时不进入组织删除和复杂治理后台。

### 风险最大方案

一次性做组织删除、组织合并、所有权转让、认证资料清空和历史数据迁移。这会跨越组织、认证、项目、消息、订单、审计多条业务真相链，当前禁止。

## 9. 阶段门禁

### 第 1 天门禁结论

- 已确认本轮只改最小组织身份治理闭环。
- 已确认组织切换可复用既有接口。
- 已确认退出组织不是现有成员禁用能力的简单复用。
- 已确认本轮不删除组织、不清历史数据、不合并组织。
- 已确认本地不新建 BFF / Server 真相。

结论：允许进入第 2 天组织切换入口增强；退出组织实现必须等待第 3 天 contracts 冻结完成。
