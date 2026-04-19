---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the temporary unlock boundary for `联调白名单测试会话`, making it clear
  this is a controlled integration-testing capability rather than a formal user
  feature or production bypass.
layer: L0 SSOT
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/account_login_identity_permission_minimum_freeze_addendum.md
  - docs/02_backend/package1_current_session_and_auth_session_truth_addendum.md
  - docs/01_contracts/auth_contracts.yaml
  - docs/03_bff/account_and_enterprise_certification_rules_v1_bff_surface_addendum.md
---

# 联调白名单测试会话解锁单

## 1. Final Position

本能力正式冻结为：

- `联调测试能力`
- 不是正式业务能力
- 不是正式用户能力
- 不是生产万能钥匙

## 2. Unique Meaning

当前唯一允许的语义是：

- `跳过 OTP 验证步骤`

当前明确不允许的语义是：

- 跳过 `current session` truth
- 跳过 `Server` session establishment
- 跳过 organization / role / certification 归属
- 直接伪造 shell context
- 直接伪造登录态给 Flutter

## 3. Unlock Boundary

本能力只允许作为：

- `integration / smoke / 联调取证`

本能力不得作为：

- 对外用户登录方式
- 日常内部运营登录方式
- 生产 fallback 登录方式
- 发布后常驻调试开关

## 4. Required Binding Fields

每一条联调白名单测试会话必须绑定：

1. `userId`
2. `phone`
3. `organizationId`
4. `role`
5. `certificationStatus`
6. `expiresAt`
7. `reason`
8. `createdBy`
9. `traceId`

这些字段必须由 `Server` truth 持有并可审计。

## 5. Environment Rule

本能力只允许在受控环境开启。

当前正式要求：

1. 必须有 `env flag`
2. 必须命中 `whitelist`
3. 必须两者同时满足

单独满足以下任一条件都不允许：

- 只有 env flag
- 只有 whitelist
- 只有 Flutter 本地调试入口
- 只有 BFF 本地判断

## 6. Session Truth Rule

当前正式写死：

- 允许跳过 OTP
- 不允许跳过 session truth

含义：

1. 最终 session 仍必须由 `Server` 建立
2. 最终 current-session verification 仍必须由 `Server` 完成
3. `authorization` 仍只是 transport carrier，不是真相
4. `BFF` 不得认证 session
5. Flutter 不得本地构造 current user / current organization / role / certification 真值

## 7. Audit / Revoke / Expire Rule

本能力必须满足：

- 可审计
- 可撤销
- 可失效

最小强制要求：

1. 每次创建都要留下 `createdBy + traceId + reason`
2. 每条测试会话都必须有 `expiresAt`
3. 必须支持显式撤销
4. 过期后必须 fail-closed

## 8. App-facing Exposure Rule

当前建议并冻结为：

- 允许暴露一个 `BFF app-facing controlled path`

但该 path 必须同时满足：

1. 仅供联调/内部调用
2. 不作为普通 Flutter 业务登录入口
3. 必须受 `env flag + whitelist` 双重限制
4. 必须保留受控 unavailable / forbidden 行为

因此当前结论不是：

- 完全不经 BFF

也不是：

- Flutter 直接拿到生产级调试登录能力

## 9. Hard Prohibitions

1. 不得把该能力写成正式登录能力
2. 不得跳过 `Server` session truth
3. 不得让 Flutter 伪造登录态
4. 不得让 BFF 持有第二套 session 真相
5. 不得取消 `expiresAt`
6. 不得省略 `reason / createdBy / traceId`
7. 不得在生产环境默认开启
8. 不得把该能力扩成万能 debug backdoor

## 10. Formal Conclusion

当前正式解锁的只有：

- `联调白名单测试会话` docs-only 边界

当前正式批准的只有：

- 在受控环境下，通过 `env flag + whitelist` 双重限制，跳过 OTP 步骤，
  但仍由 `Server` 建立并验证真实 session 的临时联调能力

