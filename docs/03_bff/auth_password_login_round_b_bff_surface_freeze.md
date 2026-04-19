# 《账号密码登录最小闭环 Round B BFF surface freeze》

## 1. 目标

本轮只冻结 `账号密码登录最小闭环 Round B` 的 BFF app-facing surface。

本轮只承接：

- `password login`
- `set password`
- `password reset`
- `scene=password_reset` 下的 OTP send app-facing 复用面

本轮不是：

- password truth owner
- password hash / verify / update owner
- password audit truth owner
- Server truth 设计
- Flutter 消费实现

## 2. BFF 职责边界

Round B 下，`BFF` 的职责固定为：

- app-facing -> server-facing transport
- request normalization
- response shaping
- error mapping
- 既有 session envelope 透传
- mutation success envelope 透传与整形

Round B 下，`BFF` 明确不做：

- password hash
- password verify
- password update
- password truth state machine
- password audit truth
- 账号是否已设密码的业务真值 owner
- username / email / third-party password family 扩展

## 3. Path Mapping Freeze

本轮逐条冻结如下 path mapping：

- `/api/app/auth/password/login` -> `/server/auth/password/login`
- `/api/app/auth/password/set` -> `/server/auth/password/set`
- `/api/app/auth/password/reset` -> `/server/auth/password/reset`
- `/api/app/auth/otp/send` with `scene=password_reset` -> `/server/auth/otp/send`

额外边界：

- 不新开 `password/otp/send` family
- 不新开 `reset/otp/send` family
- 不新开 username/email password family
- 不新开 Apple / 微信 / 一键登录 / SSO family

## 4. Request Surface Freeze

### 4.1 `password login`

app-facing 输入与 BFF 规范化字段冻结为：

- `mobile`
- `password`
- `consentAccepted`
- `deviceId`
- `deviceName`
- `osType`

补充规则：

- `mobile` 进入 BFF 后按既有 auth mobile 规范化口径处理
- `password` 只做最小输入清洗，不做 policy 改写
- `consentAccepted` 必须原样承接 Round A consent gate

### 4.2 `password set`

app-facing 输入冻结为：

- `newPassword`

补充规则：

- 当前身份来自 session / token
- 不新增第二身份载体
- 不附带 `mobile`
- 不附带 `userId`

### 4.3 `password reset`

app-facing 输入冻结为：

- `mobile`
- `otpCode`
- `newPassword`

补充规则：

- reset 只承接 `mobile -> OTP -> newPassword`
- 不承接独立注册输入
- 不承接 username / email recovery

## 5. Response Shaping Freeze

### 5.1 `password login`

成功后必须复用 OTP login 同一 `session envelope`。

冻结规则：

- 不新开第二套登录响应族
- token / refreshToken / expiresAt / session context 结构与 OTP login 对齐
- `BFF` 只做字段整形，不更改业务真值

### 5.2 `password set`

成功后复用统一最小 `mutation success envelope`。

冻结规则：

- 不自动登录
- 不新建第二套 session 响应
- 不把 `set-password` 写成注册完成

### 5.3 `password reset`

成功后复用统一最小 `mutation success envelope`。

冻结规则：

- 不自动登录
- 不自动建立 session
- 不把 `reset-password` 写成自动登录

## 6. Error Mapping Freeze

本轮 BFF 至少冻结以下错误码消费与透传边界：

- `AUTH_PASSWORD_LOGIN_INVALID`
- `AUTH_PASSWORD_NOT_SET`
- `AUTH_PASSWORD_SET_NOT_ALLOWED`
- `AUTH_PASSWORD_RESET_OTP_INVALID`
- `AUTH_PASSWORD_POLICY_INVALID`
- `AUTH_CONSENT_REQUIRED`

额外规则：

- public password login 不得暴露账号枚举差异
- 若 backend 对 public login 统一返回 `AUTH_PASSWORD_LOGIN_INVALID`，BFF 不得拆开
- `AUTH_PASSWORD_NOT_SET` 不得在 public login 场景被 BFF 改写为账号存在性提示
- `AUTH_CONSENT_REQUIRED` 只表示 consent gate 未满足，不得被改写成 password 错误

## 7. Consent Surface Freeze

本轮 consent surface 正式冻结如下：

- `password login` 继续强制 `consentAccepted = true`
- `set password` 不新增 `consentAccepted`
- `password reset` 不新增 `consentAccepted`
- BFF 只透传 consent carrier，不生成 consent 真值
- BFF 不新增独立 password consent 逻辑

## 8. Normalization Freeze

本轮最小 normalization 边界冻结如下：

### 8.1 mobile

- `mobile` 允许 trim
- `mobile` 允许沿用既有 auth normalize 规则
- 不得在 BFF 发明第二套 mobile canonicalization

### 8.2 password

- `password` 只允许最小输入清洗
- 不得在 BFF 改写 password policy
- 不得在 BFF 做复杂度校验真值判断
- 不得在 BFF 做 hash / verify

### 8.3 device context

以下字段继续沿用既有 auth 语义：

- `deviceId`
- `deviceName`
- `osType`

冻结规则：

- 不新增第二套 device carrier
- 不因 password family 另起独立 device model

## 9. 合规与发布门禁

- `BFF surface freeze` 完成前，不进入 frontend surface freeze 实施派工
- BFF 不得新开 username / email / third-party path
- BFF 不得把 Round B 扩成完整账号中心对外 surface
- BFF 不得反向定义 `Server` password truth

## 10. No-Go 边界

以下全部写死为 `No-Go`：

- BFF 不持 password truth
- BFF 不做 hash / verify
- BFF 不做账号是否已设密码的业务真值 owner
- 不新开 password otp send family
- 不把 `set-password` 写成注册完成
- 不把 `reset-password` 写成自动登录
- 不开放 username login
- 不开放 email login
- 不开放 Apple / 微信 / 一键登录 / SSO
- 不把 password family 扩成完整账号系统

## 11. 裁决

`Round B BFF surface freeze 是否可入库：是`

入库含义仅限：

- app-facing password family BFF surface 已冻结
- path mapping 已冻结
- request / response shaping 已冻结
- consent / normalization / error mapping 已冻结

这不代表：

- backend 已实现
- BFF 已实现
- frontend 已实现
- Round B 已进入实现

`下一步唯一动作是什么：等待总控发出 Round B implementation package bundle`
