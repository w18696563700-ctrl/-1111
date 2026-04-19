# 《账号密码登录最小闭环冻结文书｜Round B》

## 1. Round B 目标

本轮只冻结 `手机号验证码登录 + 手机号密码登录` 的双主链最小闭环。

Round B 只解决四件事：

1. `手机号 + 密码登录`
2. `OTP 登录成功后为当前账号设置密码`
3. `通过 OTP 验证重置密码`
4. `登录页双入口`

本轮不解决：

- 完整注册体系
- 第三方登录
- 独立账号中心
- 多 identity 编排层
- 用户名 / 邮箱登录
- 完整账号安全中心

本轮所有结论统一按四类落档：

- `已真实成立`
- `上架前必须补齐`
- `本轮明确不开通`
- `文档有但代码未实装`

## 2. 当前真相

### 2.1 已真实成立

- 当前唯一已正式成立的登录主链是 `手机号 + 验证码登录`
- 当前正式 auth family 只有：
  - `/api/app/auth/otp/send`
  - `/api/app/auth/otp/login`
  - `/api/app/auth/refresh`
  - `/api/app/auth/logout`
  - `/server/auth/otp/send`
  - `/server/auth/otp/login`
  - `/server/auth/refresh`
  - `/server/auth/logout`
- 未注册手机号首次 OTP 验证成功后，会自动创建 `user` 并建立 `session`
- 上述“首登自动建号”只表示 OTP 登录后的自动建号，不等于“独立注册体系完成”
- 当前 identity 真相仍锚定 `users.mobile -> user`
- 当前 consent 最小闭环已成立：
  - legal 页面
  - 显式勾选
  - `consentAccepted`
  - `agreement_version / privacy_version / agreed_at / audit`

### 2.2 当前缺口

- 当前尚无正式 `password login` path family
- 当前尚无正式 `set-password` canonical path
- 当前尚无正式 `forgot-password / reset-password` canonical path
- 当前登录页尚无 `验证码登录 / 账号密码登录` 双入口最小骨架
- 当前不得把已有 OTP 主链外推成“完整账号系统已完成”

## 3. Round B 正式开放范围

Round B 只允许冻结以下四项正式开放范围：

1. `手机号 + 密码登录`
2. `OTP 登录成功后，为当前已登录账号设置密码`
3. `手机号经 OTP 验证后重置密码`
4. `同一登录页双入口`
   - `验证码登录`
   - `账号密码登录`

### 3.1 最小交互骨架冻结

登录页最小交互骨架固定为：

- 同一路由、同一登录壳
- 顶部使用 `segmented control` 双入口切换
- 左侧分段：`验证码登录`
- 右侧分段：`账号密码登录`

最小页面骨架固定如下：

- `验证码登录`：
  - 手机号输入
  - 发送验证码
  - 验证码输入
  - 登录按钮
- `账号密码登录`：
  - 手机号输入
  - 密码输入
  - 登录按钮
  - 次级入口：`忘记密码`

`设置密码` 不作为第三个登录入口，不进入登录页主切换。其最小入口固定为：

- 当前账号已通过 OTP 登录
- 当前 session 已成立
- 进入“为当前账号设置密码”的单独最小页面或 sheet
- 该动作只服务于当前账号补齐密码，不表示独立注册完成

## 4. Round B 保留但不开通

以下能力全部保持 `本轮明确不开通`：

- 用户名登录
- 邮箱登录
- 微信登录
- Apple 登录
- 一键登录
- SSO
- 独立公众注册中心
- 多 provider identity 中层
- 完整账号安全中心
- 完整账号资料中心
- 账号申诉中心
- 多终端账号编排与合并体系

其中需要单独说明：

- `provider identity / apple / mobile` 等 future-facing identity 概念，即使文档曾出现，也不得写成 Round B 已开放能力
- `设置密码` 不得偷写成“独立注册完成”
- `密码登录` 不得偷扩成“完整账号体系”

## 5. 登录方式能力矩阵

| 能力 | Android | iOS | runtime env | feature flag | contract | backend truth | 当前归类 | 冻结结论 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 手机号 + 验证码登录 | 已真实成立 | 已真实成立 | 已真实成立 | 已真实成立 | 已真实成立 | 已真实成立 | 已真实成立 | Round A 基线，继续保留 |
| OTP 首登自动建号 | 已真实成立 | 已真实成立 | 已真实成立 | 已真实成立 | 已真实成立 | 已真实成立 | 已真实成立 | 只表示自动建 user，不等于注册体系 |
| 手机号 + 密码登录 | 上架前必须补齐 | 上架前必须补齐 | 上架前必须补齐 | 上架前必须补齐 | 上架前必须补齐 | 上架前必须补齐 | 缺口 | Round B 主线之一 |
| OTP 后设置密码 | 上架前必须补齐 | 上架前必须补齐 | 上架前必须补齐 | 上架前必须补齐 | 上架前必须补齐 | 上架前必须补齐 | 缺口 | 只允许作用于当前 OTP 已登录账号 |
| 忘记密码 / OTP 重置密码 | 上架前必须补齐 | 上架前必须补齐 | 上架前必须补齐 | 上架前必须补齐 | 上架前必须补齐 | 上架前必须补齐 | 缺口 | 只允许 `mobile -> OTP -> reset` 最小闭环 |
| 登录页双入口 | 上架前必须补齐 | 上架前必须补齐 | 上架前必须补齐 | 上架前必须补齐 | 不单独成 contract | 不单独成 truth | 缺口 | 固定为同页 segmented control |
| 用户名登录 | 本轮明确不开通 | 本轮明确不开通 | 本轮明确不开通 | 本轮明确不开通 | 本轮明确不开通 | 本轮明确不开通 | No-Go | 不进入 Round B |
| 邮箱登录 | 本轮明确不开通 | 本轮明确不开通 | 本轮明确不开通 | 本轮明确不开通 | 本轮明确不开通 | 本轮明确不开通 | No-Go | 不进入 Round B |
| 微信登录 | 本轮明确不开通 | 本轮明确不开通 | 本轮明确不开通 | 本轮明确不开通 | 本轮明确不开通 | 本轮明确不开通 | No-Go | 不进入 Round B |
| Apple 登录 | 文档有但代码未实装 | 文档有但代码未实装 | 本轮明确不开通 | 本轮明确不开通 | 文档有但代码未实装 | 文档有但代码未实装 | 文档有但代码未实装 | 不得写成当前开放 |
| 一键登录 | 本轮明确不开通 | 本轮明确不开通 | 本轮明确不开通 | 本轮明确不开通 | 本轮明确不开通 | 本轮明确不开通 | No-Go | 不进入 Round B |
| SSO | 本轮明确不开通 | 本轮明确不开通 | 本轮明确不开通 | 本轮明确不开通 | 本轮明确不开通 | 本轮明确不开通 | No-Go | 不进入 Round B |

## 6. 页面状态矩阵

| 页面状态 | 当前判定 | 冻结说明 |
| --- | --- | --- |
| 空态 | OTP 已真实成立；双入口空态上架前必须补齐 | 登录页需升级为双入口同页空态 |
| 输入中 | OTP 已真实成立；密码输入态上架前必须补齐 | 两个入口分别维护输入态，不引入第三入口 |
| 发送验证码中 | OTP 已真实成立；忘记密码 OTP 发送态上架前必须补齐 | 忘记密码复用 OTP 发送，不新开第二条发送家族 |
| 倒计时 | OTP 已真实成立；忘记密码倒计时上架前必须补齐 | 倒计时语义可复用，但必须区分登录与重置场景 |
| OTP 登录中 | 已真实成立 | 继续保留 |
| 密码登录中 | 上架前必须补齐 | 新增最小 loading 态 |
| 设置密码提交中 | 上架前必须补齐 | 仅对当前 OTP 已登录账号开放 |
| 忘记密码提交中 | 上架前必须补齐 | `OTP 验证通过 -> 设置新密码` 的最小提交态 |
| 成功 | OTP 已真实成立；密码登录/重置成功上架前必须补齐 | 密码登录成功后建立 session；重置成功不等于自动注册 |
| 验证码错误 | OTP 已真实成立；重置验证码错误上架前必须补齐 | 重置流需单独受控提示 |
| 密码错误 | 上架前必须补齐 | 必须是正式错误态，不能落回泛失败 |
| 频控 | OTP 已真实成立；密码重置相关频控上架前必须补齐 | 继续由 Server 真相控制 |
| 服务不可用 | OTP 已真实成立；密码链路同样上架前必须补齐 | 不得由客户端伪造业务态 |
| 取消 | 本轮明确不开通 | 不单列取消业务流 |
| 超时 | 上架前必须补齐 | 密码相关请求需有明确 timeout/fallback 行为 |
| fallback | OTP 已真实成立；密码链路上架前必须补齐 | 统一落入受控 fallback |
| 协议未勾选 | OTP 已真实成立；双入口共用态上架前必须补齐 | 两种登录方式共用同一 consent gate，不得分裂两套协议逻辑 |
| 设置密码入口态 | 上架前必须补齐 | 仅在当前账号已 OTP 登录前提下开放 |
| 忘记密码入口态 | 上架前必须补齐 | 仅出现在密码登录分段内 |

## 7. identity / credential 模型冻结说明

### 7.1 冻结判断

Round B 的密码能力固定挂在当前 `mobile -> user` 真相之上，不另起新的 identity 中层。

正式判断如下：

- `user` 仍是唯一账号主体
- `mobile` 仍是当前真实 login identity
- `password` 只是挂载在当前 `mobile -> user` 真相之上的新增 credential
- Round B 不创建新的 provider-identity 编排层
- Round B 不引入用户名 identity
- Round B 不引入邮箱 identity

### 7.2 最小 credential 模型

Round B 的最小 credential 模型固定为：

- `user`
  - 继续作为账号主体
- `mobile`
  - 继续作为当前唯一登录身份锚点
- `password credential`
  - 作为从属当前 `userId` 的最小密码真值 carrier
  - 只服务于 `password login / set password / forgot password reset`
  - 不等于多 provider identity 中层
- `session / device`
  - 继续沿用 Round A 真相
  - 密码登录成功后复用同一 session / device 闭环

### 7.3 设置密码前置条件

设置密码的前置条件固定为：

- 必须是当前已通过 `OTP 登录` 的当前账号
- 必须已有有效 session
- 该动作只对“当前账号补齐密码”成立
- 不得写成独立注册完成
- 不得扩成完整账号中心里的通用密码治理体系

### 7.4 忘记密码最小闭环

忘记密码的最小闭环固定为：

1. 输入手机号
2. 发送 OTP
3. OTP 验证通过
4. 为该手机号对应的当前 `mobile -> user` 账号设置新密码

该闭环不允许扩成：

- 邮箱找回
- 用户名找回
- 人工申诉找回
- 多 provider 凭证重置

## 8. migration 与 contracts 缺口清单

### 8.1 必须冻结但当前未成立的 canonical path family

#### app-facing

- `POST /api/app/auth/password/login`
- `POST /api/app/auth/password/set`
- `POST /api/app/auth/password/reset`

#### server-facing

- `POST /server/auth/password/login`
- `POST /server/auth/password/set`
- `POST /server/auth/password/reset`

### 8.2 OTP 发送复用边界

忘记密码不新开第二条 OTP family。Round B 只允许：

- 继续复用现有 OTP 发送 canonical path
- 在 contract 中显式区分 `login` 与 `password_reset` 使用场景
- 不得再开新的 `password/otp/send` 家族

### 8.3 必须冻结的最小 contract 输入输出

#### `password login`

最小请求真相应冻结为：

- `mobile`
- `password`
- `consentAccepted`

最小结果真相应冻结为：

- 登录成功后返回与 OTP 登录一致的 session 承接语义
- 不新开第二套 token family

#### `set password`

最小请求真相应冻结为：

- `newPassword`
- 当前 session 身份由 auth context 承接，不另传第二身份载体

#### `password reset`

最小请求真相应冻结为：

- `mobile`
- `otpCode`
- `newPassword`

### 8.4 新错误码最小集合

Round B 只允许新增以下最小错误码集合：

- `AUTH_PASSWORD_LOGIN_INVALID`
- `AUTH_PASSWORD_NOT_SET`
- `AUTH_PASSWORD_SET_NOT_ALLOWED`
- `AUTH_PASSWORD_RESET_OTP_INVALID`
- `AUTH_PASSWORD_POLICY_INVALID`

本轮不得顺手扩成完整账号安全错误码族。

### 8.5 audit 最小集合

Round B 只允许冻结如下最小 audit：

- `password_login_success`
- `password_login_failure`
- `password_set`
- `password_reset_requested`
- `password_reset_success`
- `password_reset_failure`

### 8.6 当前缺口裁决

当前以下项目统一属于 `上架前必须补齐`：

- password login contract
- set-password contract
- forgot-password/reset contract
- password credential persistence
- password audit truth
- BFF surface
- Flutter 双入口与 set/reset 消费面

## 9. 合规与发布门禁

Round B 进入正式上线准备前，以下门禁必须全部满足：

1. `password login / set / reset` contract 已正式冻结
2. password credential persistence 已正式冻结并完成 migration
3. `Server` 已正式承接：
   - password login
   - set password
   - forgot-password reset
   - 最小 audit
4. `BFF` 只做透传、整形、错误映射，不拥有密码真值
5. `Flutter` 双入口已落地，且：
   - 用户不会误解“设置密码 = 独立注册完成”
   - 用户不会误解“忘记密码 = 创建新账号”
6. Round A consent 闭环继续沿用，双入口必须共用同一 consent gate
7. 密码真值必须使用正式 hash 存储，不得明文存储、不得在 `BFF` 或客户端持久化
8. `password login` 与 `password reset` 必须纳入最小风控与频控
9. 必须完成正式 smoke：
   - OTP 登录
   - 设置密码
   - 密码登录
   - 忘记密码重置
   - refresh
   - logout

## 10. No-Go 边界清单

以下全部保持 `No-Go`：

- 不得把 Round B 写成完整账号体系完成
- 不得把 `set password` 写成独立注册完成
- 不得新开用户名登录
- 不得新开邮箱登录
- 不得顺手接入微信登录
- 不得顺手接入 Apple 登录
- 不得顺手接入一键登录
- 不得顺手接入 SSO
- 不得新开独立公众注册中心
- 不得默认 provider identity 中层已经存在
- 不得让 `BFF` 持有密码真值
- 不得让 `Flutter` 直持密码业务真值
- 不得把 `forgot password` 写成第二条注册链
- 不得新开第二套 token / session 家族
- 不得把双入口登录页扩成完整账号中心
- 不得以“未来文档提过”推定当前代码已实装

## 11. 下一步唯一动作

下一步唯一动作：

- `等待总控发出 Round B implementation package bundle`

## 裁决

`Round B 是否可作为正式冻结稿入库：是`

入库含义仅限：

- 主线范围已冻结
- identity / credential 边界已冻结
- contracts / migration / audit 缺口已冻结
- No-Go 边界已冻结

这不代表：

- password login 已实现
- set password 已实现
- forgot password 已实现
- 双入口登录页已实现
- Round B 已获得实现放行

`下一步唯一动作是什么：等待总控发出 Round B implementation package bundle`
