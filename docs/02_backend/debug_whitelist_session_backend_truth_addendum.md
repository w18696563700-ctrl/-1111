---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the backend truth boundary for `联调白名单测试会话`, including truth
  ownership, required bindings, audit/revoke/expire semantics, and the rule
  that this capability may bypass OTP only but never bypass Server-owned session truth.
layer: L3 Backend
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/debug_whitelist_session_unlock_addendum.md
  - docs/02_backend/package1_current_session_and_auth_session_truth_addendum.md
  - docs/02_backend/identity_permission_persistence_minimum_addendum.md
  - docs/02_backend/identity_permission_audit_log_increment_addendum.md
---

# Debug Whitelist Session Backend Truth Addendum

## 1. Scope

本文件只冻结 `联调白名单测试会话` 的 backend truth。

## 2. Truth Owner

当前唯一 truth owner 是：

- `Server`

明确禁止：

- Flutter 持有 session truth
- BFF 持有 session truth
- Redis-only session truth
- 前端缓存冒充 current-session truth

## 3. Unique Meaning

后端当前只允许一件事：

- 跳过 OTP 验证步骤

后端当前不允许跳过：

1. 用户归属校验
2. organization scope 归属校验
3. role 归属校验
4. certificationStatus 归属校验
5. session 建立
6. current-session verification

## 4. Required Truth Bindings

每条联调白名单测试会话必须绑定以下后端真值：

1. `userId`
2. `phone`
3. `organizationId`
4. `role`
5. `certificationStatus`
6. `expiresAt`
7. `reason`
8. `createdBy`
9. `traceId`

其中：

- `role` 与 `certificationStatus` 必须来自既有 identity / organization truth
- 不能由 BFF 或 Flutter 填写后直接认定为真

## 5. Persistence / Verification Rule

当前冻结规则：

1. 测试会话仍必须落入既有 `sessions` 真相体系
2. 既有 current-session verification 继续是唯一验证目标
3. 不允许新造第二套 `debug_session_truth_root`
4. 不允许只靠 whitelist 记录就直接把请求视为已登录

## 6. Audit Rule

每次受控测试会话创建必须可审计。

最小审计要求：

1. 记录 `createdBy`
2. 记录 `traceId`
3. 记录 `reason`
4. 记录目标 `userId / organizationId`
5. 记录创建时间
6. 记录过期时间

## 7. Revoke / Expire Rule

当前后端必须支持：

1. 显式撤销
2. 到时失效
3. 验证时 fail-closed

明确禁止：

- 永久有效
- 无法撤销
- 过期后仍可续用

## 8. Environment + Whitelist Double-lock

后端当前必须坚持双锁：

1. `env flag`
2. `whitelist`

两者任何一个不满足，都必须拒绝。

## 9. Prohibited Shortcuts

1. 不得跳过 `Server` session establishment
2. 不得跳过 `Server` current-session verification
3. 不得把 `x-actor-id / x-user-id / x-organization-id` 当最终真相
4. 不得把 whitelist 命中当成最终授权
5. 不得把该能力扩成生产环境万能调试后门

## 10. Formal Conclusion

`联调白名单测试会话` 的 backend truth 正式冻结为：

- `Server` 唯一持有真相
- 只允许 OTP bypass
- 不允许 session-truth bypass
- 必须受 `env flag + whitelist` 双重限制
- 必须可审计、可撤销、可失效
