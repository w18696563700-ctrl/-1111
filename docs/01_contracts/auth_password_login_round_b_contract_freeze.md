# 《账号密码登录最小闭环 Round B contract freeze》

## 1. 目标

本轮只冻结 `账号密码登录最小闭环 Round B` 的 contract truth。

本轮只承接四项范围：

1. `手机号 + 密码登录`
2. `OTP 登录后为当前账号设置密码`
3. `OTP 验证后重置密码`
4. `登录页双入口` 对应的最小 contract 支撑

本轮不是：

- 完整注册体系 contract
- 第三方登录 contract
- 用户名 / 邮箱登录 contract
- 多 provider identity contract
- 完整账号中心 contract
- backend / BFF / frontend 实现

## 2. 当前真相约束

- 当前唯一已正式成立的登录主链仍是 `手机号 + 验证码登录`
- 首登自动建号已存在，但不等于独立注册体系完成
- 当前 identity 仍锚定 `users.mobile -> user`
- 当前尚无正式 `password login / set / reset` canonical path family
- Round B 只是在现有 `mobile -> user` 真相之上补齐 password credential contract，不另起 identity 中层

## 3. Canonical Paths

### 3.1 app-facing canonical path family

本轮冻结为唯一合法 app-facing password family：

- `POST /api/app/auth/password/login`
- `POST /api/app/auth/password/set`
- `POST /api/app/auth/password/reset`

### 3.2 server-facing canonical path family

本轮冻结为唯一合法 server-facing password family：

- `POST /server/auth/password/login`
- `POST /server/auth/password/set`
- `POST /server/auth/password/reset`

### 3.3 path family 边界

- 不新增第二条 password auth family
- 不新增 username/email auth family
- 不新增第三方登录 canonical path
- 不新增独立注册 canonical path
- `BFF` 只承接 app-facing -> server-facing 透传与整形，不拥有 password truth

## 4. Request / Response Freeze

### 4.1 `POST /api/app/auth/password/login` / `POST /server/auth/password/login`

请求最小冻结字段：

- `mobile`
- `password`
- `consentAccepted`

响应最小冻结规则：

- 成功响应必须复用与 OTP login 相同的 `session envelope`
- 不新开第二套 token/session 响应结构
- 登录成功语义固定为：
  - 找到当前 `mobile -> user`
  - 校验 password credential
  - 建立或更新 session / device
- 若当前账号未设置密码，不得伪装成登录成功

### 4.2 `POST /api/app/auth/password/set` / `POST /server/auth/password/set`

请求最小冻结字段：

- `newPassword`

前置条件冻结为：

- 必须是当前已通过 OTP 登录的当前账号
- 必须已有有效 session
- 不允许未登录状态直接调用 `set`

响应最小冻结规则：

- 成功响应只返回最小 mutation success envelope
- 不返回 password truth
- 不新建第二套 session
- 不把 `set password` 写成“注册完成”

### 4.3 `POST /api/app/auth/password/reset` / `POST /server/auth/password/reset`

请求最小冻结字段：

- `mobile`
- `otpCode`
- `newPassword`

前置条件冻结为：

- 必须先经过 OTP 验证
- 该 OTP 只用于 password reset 场景
- 不允许跳过 OTP 直接 reset

响应最小冻结规则：

- 成功响应只返回最小 mutation success envelope
- 不自动登录
- 不自动创建 session
- 不得把 `forgot password / reset` 写成第二条注册链

## 5. Error Code Freeze

本轮新增并冻结的最小错误码集合为：

- `AUTH_PASSWORD_LOGIN_INVALID`
- `AUTH_PASSWORD_NOT_SET`
- `AUTH_PASSWORD_SET_NOT_ALLOWED`
- `AUTH_PASSWORD_RESET_OTP_INVALID`
- `AUTH_PASSWORD_POLICY_INVALID`

错误码边界固定如下：

- `AUTH_PASSWORD_LOGIN_INVALID`
  - 手机号存在但 password 校验失败时使用
- `AUTH_PASSWORD_NOT_SET`
  - 当前 `mobile -> user` 尚未配置 password credential
- `AUTH_PASSWORD_SET_NOT_ALLOWED`
  - 未登录、非当前账号、或不满足 set-password 前置条件时使用
- `AUTH_PASSWORD_RESET_OTP_INVALID`
  - reset 场景下 OTP 校验失败时使用
- `AUTH_PASSWORD_POLICY_INVALID`
  - 新密码不满足最小 password policy 时使用

本轮不扩完整账号安全错误码族。

## 6. OTP Reset Reuse Rule

忘记密码不得新开第二条 OTP family。

正式冻结如下：

- 继续复用现有 `/otp/send` canonical family
- 必须通过 `scene=password_reset` 区分 reset 语义
- `scene=password_reset` 是 Round B 唯一合法 reset OTP contract 口径
- 不允许新增 `password/otp/send`
- 不允许新增 `reset/otp/send`
- 不允许把 reset OTP 与 login OTP 混成无场景区分的同义调用

补充冻结：

- `password reset` 使用：
  - `POST /api/app/auth/otp/send` with `scene=password_reset`
  - `POST /api/app/auth/password/reset`
- 不复用 `/otp/login` 完成 reset
- reset 的提交入口固定为 `/password/reset`

## 7. Consent Gate Freeze

### 7.1 password login

`password login` 继续强制要求：

- `consentAccepted = true`

冻结理由：

- 登录页双入口属于同一登录壳
- Round A 已形成 consent 闭环
- Round B 不允许在 OTP 与 password 之间拆成两套 consent 逻辑

### 7.2 set password

`set password` 不新增 `consentAccepted` 字段。

冻结规则：

- 该动作复用当前账号已建立的合法登录态与既有 consent truth
- `set password` 不单独生成新的 consent 记录
- `set password` 不被视为新注册

### 7.3 password reset

`password reset` 不新增 `consentAccepted` 字段。

冻结规则：

- `reset` 是 credential recovery mutation，不是登录成功态本身
- `reset` 成功后不自动登录
- 后续若走 `password login`，仍必须提交 `consentAccepted = true`

## 8. Password Truth Carrier Boundary

正式冻结判断如下：

- password truth 只归 `Server` 持有
- `passwordHash` 只允许存在于 `Server` truth carrier
- `BFF` 不持有 password truth
- `Flutter` 不持有 password truth
- `BFF` 与 `Flutter` 只允许短暂承接当前请求输入，不得持久化 password truth
- Round B 不把 password carrier 写成 provider identity 中层
- Round B 的 password credential 只挂在当前 `mobile -> user` 真相之上

最小 contract 边界固定为：

- `user` 仍是账号主体
- `mobile` 仍是唯一登录 identity
- `password credential` 是当前 `userId` 下的最小从属真值 carrier
- 不引入第二身份系统
- 不引入多 provider 编排层

## 9. Audit Freeze

本轮冻结的最小 audit 集合为：

- `password_login_success`
- `password_login_failure`
- `password_set`
- `password_reset_requested`
- `password_reset_success`
- `password_reset_failure`

audit 边界固定如下：

- audit owner = `Server`
- `BFF` 不拥有业务审计真值
- `Flutter` 不拥有业务审计真值
- `password_reset_requested` 对应 `scene=password_reset` 的 OTP send 场景
- `approved`、`registered`、`identity_linked` 等非本轮事件不得混入 Round B audit

## 10. 合规与发布门禁

Round B 在 contract 层进入后续阶段前，必须满足：

1. 上述 canonical path family 已正式入库
2. `scene=password_reset` 已正式冻结为唯一 reset OTP 口径
3. `password login` 已明确复用 OTP login 同一 session envelope
4. `set password` 与 `password reset` 已明确为 mutation success envelope，不自动生成第二套登录闭环
5. consent gate 已明确：
   - `password login` 强制 `consentAccepted`
   - `set/reset` 不新增 consent 字段
6. password truth carrier 已明确归 `Server`
7. 最小 audit family 已冻结
8. 未开放能力已全部保持 `No-Go`

在以上门禁完成前，不得进入 release-ready 表述。

## 11. No-Go 边界

以下结论全部写死为 `No-Go`：

- 不得把 `set password` 写成“注册完成”
- 不得把 `forgot password / reset` 写成“第二条注册链”
- 不得把 password credential 扩成多 provider identity 中层
- 不得开放用户名登录
- 不得开放邮箱登录
- `Apple 登录`：
  - 本轮明确不开通
  - 无现行 contract
  - 无 backend truth
  - 仅 future identity 词表保留，不得开放
- `微信登录`：
  - 本轮明确不开通
  - 无现行 contract
  - 无 backend truth
  - 仅 future identity 词表保留，不得开放
- 一键登录：
  - 本轮明确不开通
  - 无现行 contract
  - 无 backend truth
- SSO：
  - 本轮明确不开通
  - 无现行 contract
  - 无 backend truth
- 不得把 `BFF` 写成 password truth owner
- 不得把 `Flutter` 写成 password truth owner
- 不得把 Round B contract freeze 写成实现完成

## 12. 下一步唯一动作

下一步唯一动作：

- `等待总控发出 Round B implementation package bundle`

## 裁决

`Round B contract freeze 是否可入库：是`

入库含义仅限：

- Round B contract family 已冻结
- request / response 边界已冻结
- consent 规则已冻结
- password truth carrier contract 边界已冻结
- audit 最小集合已冻结

这不代表：

- backend 已实现
- BFF 已实现
- Flutter 已实现
- Round B 已获得上线放行

`下一步唯一动作是什么：等待总控发出 Round B implementation package bundle`
