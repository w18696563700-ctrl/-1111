---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the BFF surface boundary for `联调白名单测试会话`, ensuring BFF only
  forwards and shapes the controlled handoff without becoming a second session
  truth root.
layer: L4 BFF
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/debug_whitelist_session_unlock_addendum.md
  - docs/01_contracts/debug_whitelist_session_contracts_addendum.md
  - docs/02_backend/debug_whitelist_session_backend_truth_addendum.md
  - docs/03_bff/account_and_enterprise_certification_rules_v1_bff_surface_addendum.md
  - docs/03_bff/bff_routes.md
---

# Debug Whitelist Session BFF Surface Addendum

## 1. Scope

本文件只冻结 `联调白名单测试会话` 的 `BFF` surface。

## 2. Exposure Verdict

当前正式结论：

- 允许一个受控 app-facing path 经过 `BFF`

但该 path 只允许：

- 联调/内部调用
- 受控 envelope
- 最小响应整形

## 3. BFF Allowed Responsibilities

`BFF` 当前只允许：

1. 转发请求到 `Server`
2. 转发 `authorization` 与 trace headers
3. 归一 `x-request-id / x-trace-id`
4. 整形最小成功/失败 envelope
5. 返回受控 unavailable / forbidden / invalid 响应

## 4. BFF Forbidden Responsibilities

`BFF` 当前明确禁止：

1. 验证 current session
2. 建立 session truth
3. 签发第二套 auth truth
4. 自行根据 whitelist 决定“用户已登录”
5. 自行认定 `organizationId / role / certificationStatus` 为真
6. 把 Flutter 传来的本地状态升级成 session 真相

## 5. Shaping Boundary

`BFF` 允许 shape 的最小字段只有：

1. `ok`
2. `userId`
3. `phone`
4. `organizationId`
5. `role`
6. `certificationStatus`
7. `expiresAt`
8. `traceId`

`BFF` 不允许 shape：

1. 第二套 shell context
2. 第二套 actor context
3. 第二套 organization summary
4. 第二套 certification truth

## 6. Controlled Availability Rule

若以下任一条件不满足，`BFF` 必须 fail-closed：

1. env flag 未开
2. whitelist 未命中
3. 上游 `Server` 验证失败
4. 会话已过期或被撤销

## 7. Flutter Boundary

`BFF` 必须保护 Flutter 不获得以下能力：

1. 本地伪造登录成功
2. 绕过 `Server` current-session verification
3. 把 debug 会话误当普通登录能力

因此当前 app-facing 暴露必须同时满足：

- 受控 path
- 受控环境
- 受控调用方
- 受控 copy

## 8. Formal Conclusion

`联调白名单测试会话` 的 `BFF surface` 正式冻结为：

- 可以暴露受控 app-facing path
- 但 `BFF` 只做 forwarding + shaping
- 不得成为第二套 session truth root
