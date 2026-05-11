# Admin Server-Owned Carrier Issuer Freeze Addendum

doc_meta:
  owner: Codex 总控
  status: draft
  layer: L0 SSOT
  scope: Admin 登录接入体验最小优化
  created_at: 2026-05-11

## 1. 当前裁决

Admin 仍保持 `server_session_carrier_only`。本轮只新增一个由 Server Auth 持有的受控 Admin carrier 签发入口，解决持有人必须手工 curl、复制 `accessToken` 的问题。

该入口不新增独立 Admin 账号密码体系，不新增管理员注册，不经过 BFF，不改变 Server Admin API 的最终角色门禁。

## 2. 最小闭环

新增 Server-owned endpoint：

- `POST /server/admin/auth/session-carrier/issue`

最小流程：

1. Admin 登录页提交 Server Auth 凭据。
2. Server 复用现有 password auth session envelope 建立 Server session。
3. Server 用刚签发的 access carrier 重新验证 current-session truth。
4. Server 查询 DB-backed platform membership。
5. 仅 `platform_reviewer | platform_super_admin` 可获得 `adminSessionCarrier`。
6. Admin 登录页把 `adminSessionCarrier` 写入 `admin_session` cookie。
7. 后续 Admin API 仍直连 Server Admin API，并由 Server role gate 继续校验。

## 3. 明确不是

- 不是 Admin 独立账号密码登录。
- 不是 Admin 注册。
- 不是 BFF 登录代理。
- 不是 whitelist-test-session 正式化。
- 不是绕过 `platform_reviewer | platform_super_admin`。
- 不是把 raw header hint 写成权限真值。
- 不是新增 DB 状态机。

## 4. 安全边界

- Admin 不保存账号密码。
- Server 只返回可写入 Admin cookie 的 `adminSessionCarrier`，不向 Admin 页面返回 refresh token。
- 角色判断必须来自 DB-backed platform membership。
- 普通 App 用户即使密码正确，也只能得到 `403 AUTH_PERMISSION_INSUFFICIENT`。
- 旧的手工粘贴 carrier 保留为兜底入口。

## 5. contracts 范围

OpenAPI 只新增 Server Admin Auth 路径：

- `POST /server/admin/auth/session-carrier/issue`

响应字段：

- `adminSessionCarrier`
- `expiresInSeconds`
- `roleKey`
- `platformOrganizationId`
- `nextPath`
- `issuer`

不新增 app-facing path，不改 BFF path，不改 Flutter path。

## 6. 当前最小闭环

当前最小闭环是：`Server Auth credential -> Server session -> DB-backed platform role gate -> Admin carrier -> admin_session cookie -> Server Admin API`。

## 7. 需要保留但暂不开通

- OTP 方式签发 Admin carrier：暂不做，短信运行态不稳定时容易制造登录误判。
- SSO / 企业微信 / OAuth：暂不做。
- Admin 多因子登录：暂不做。
- Admin refresh 自动续期：暂不做，继续依赖短期 carrier 和重新签发。

## 8. 后续扩展位

- 后续可把 OTP、SSO 或硬件二次确认接入同一个 Server-owned issuer。
- 后续可在 Server 添加 Admin issuer audit event。
- 后续可增加 Admin session 管理页面，但不得成为第二身份真值。

## 9. 裁决

- 更稳：Server-owned issuer + DB-backed role gate。
- 更省成本：复用现有 password auth session envelope。
- 更适合当前阶段：在 Admin 登录页增加受控签发入口，同时保留手工 carrier 兜底。
- 风险更大：直接新增 Admin 独立账号密码表、BFF 中转、或把 header hint 当权限真值。
