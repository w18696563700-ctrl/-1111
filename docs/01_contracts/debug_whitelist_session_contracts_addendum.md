---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the L2 contracts boundary for `联调白名单测试会话`, including the
  controlled app-facing route policy, required request fields, required response
  fields, and explicit non-user-facing restrictions.
layer: L2 Contracts
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/debug_whitelist_session_unlock_addendum.md
  - docs/01_contracts/auth_contracts.yaml
  - docs/01_contracts/identity_permission_minimum_contracts.yaml
---

# Debug Whitelist Session Contracts Addendum

## 1. Scope

本文件只冻结 `联调白名单测试会话` 的 contracts 边界。

本文件不做：

- 正式 OTP/login contracts 重写
- Flutter 正常登录流程变更
- Admin 密码登录流程变更

## 2. Path Exposure Verdict

当前正式裁决：

- 允许存在一个 `BFF app-facing controlled path`

但该 path 的定位必须写死为：

- `internal integration only`
- `controlled app-facing handoff`
- `not for ordinary user login`

## 3. Path Family Rule

当前路径规则冻结为：

- 仍在 `/api/app/*` 家族下
- 不新增 bare `/debug/*`
- 不新增 bare `/session/*`
- 不新增 Flutter 直连 `Server` 登录路径

推荐 path 族语义：

- `POST /api/app/auth/debug-whitelist-session`

注意：

- 这是 contracts 冻结的语义方向
- 不是本轮代码实现要求

## 4. Request Contract Minimum

最小请求体必须包含：

1. `phone`
2. `organizationId`
3. `reason`

同时 contracts 必须冻结以下隐含限制：

1. `phone` 必须命中允许的白名单身份
2. `organizationId` 必须与该测试身份允许的 scope 一致
3. 请求必须带 `x-request-id`
4. 请求必须带 `x-trace-id`

## 5. Response Contract Minimum

成功响应最小字段必须包含：

1. `ok`
2. `userId`
3. `phone`
4. `organizationId`
5. `role`
6. `certificationStatus`
7. `expiresAt`
8. `traceId`

响应可承接：

- 最小 session-established acknowledgment

响应不得承接：

- 完整 shell context payload
- 第二套 actor truth
- 任意绕过 `Server` 验证的 token 真相说明

## 6. Controlled Failure Contract

本 path 当前只允许返回受控失败：

1. `401`
   - session not established or verification failed
2. `403`
   - env flag 未开
   - whitelist 不命中
   - organization scope 不允许
3. `409`
   - 已有未过期受控测试会话且策略不允许覆盖
4. `423` 或等价 controlled unavailable
   - 当前环境关闭该调试能力

具体错误码命名可后续冻结，但语义必须先写死：

- fail-closed
- 不暴露内部绕过细节

## 7. Session Truth Rule In Contracts

contracts 必须明确：

1. 本 path 只跳过 OTP
2. 不跳过 session establishment
3. 不跳过 current-session verification
4. `authorization` 仍不是 verified current-session truth

## 8. Non-goals

1. 不把该 path 作为正式登录入口暴露给普通用户
2. 不支持 Flutter 本地离线伪造登录态
3. 不支持 BFF 本地发 token 充当最终真相
4. 不支持无限期会话
5. 不支持无审计、无 reason、无 createdBy 的测试登录

## 9. Formal Conclusion

`联调白名单测试会话` 的 contracts 正式冻结为：

- 只允许一个受控 `BFF app-facing path`
- 该 path 只服务联调/内部调用
- 它可以跳过 OTP，但不能跳过 `Server` session truth

