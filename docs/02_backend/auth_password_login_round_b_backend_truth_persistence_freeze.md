# 《账号密码登录最小闭环 Round B backend truth / persistence freeze》

## 1. 目标

本轮只冻结 `账号密码登录最小闭环 Round B` 的 backend truth / persistence。

本轮只承接四项主线的后端真相：

1. `手机号 + 密码登录`
2. `OTP 登录后为当前账号设置密码`
3. `OTP 验证后重置密码`
4. 为登录页双入口提供唯一合法的后端真相承接

本轮不是：

- 完整账号系统 backend 设计
- 多 provider identity 中层
- 用户名 / 邮箱登录 backend
- 第三方登录 backend
- 完整账号安全中心
- BFF / Flutter / implementation

## 2. 当前真相

### 2.1 已真实成立

- 当前唯一已正式成立的登录主链仍是 `手机号 + 验证码登录`
- 当前身份锚点仍是 `users.mobile -> user`
- 当前会话真相仍是既有 `session / device` 闭环
- 当前 OTP carrier 仍是 `login_otp_codes`
- 当前 `login_otp_codes.scene` 为字符串字段，可承接后续 `password_reset` scene，而不要求另起 OTP 表

### 2.2 当前缺口

- 当前尚无 password credential persistence carrier
- 当前尚无 password login backend truth
- 当前尚无 set-password backend truth
- 当前尚无 reset-password backend truth
- 当前不得把 password credential 扩写成 identity 中层

## 3. Persistence 方案裁决

### 3.1 正式裁决

Round B 的 password truth carrier 正式冻结为：

- `单独 password_credentials 真值表`
- 不在 `users` 表上直接扩 `password_hash` 等列

### 3.2 采用单独 carrier 的冻结理由

本轮正式判断如下：

- `users` 继续承接账号主体与 `mobile` 身份锚点
- `password_credentials` 只承接当前 `userId` 的 password credential 真值
- 这样可以把账号主体与敏感 credential 真值分离
- 这样仍然是 `mobile -> user` 主链下的从属 credential，不是多 provider identity 中层
- 这样不会把 `users` 扩成混合 profile + credential 的大表
- 这样满足最小闭环，不会误扩成完整账号系统

### 3.3 Round B 唯一合法 persistence 形态

Round B 的正式 persistence 方案固定为：

- `users`
  - 继续是账号主体
- `password_credentials`
  - 继续是当前 Round B 唯一合法 password truth carrier
- `sessions / devices`
  - 继续复用既有 truth
- `login_otp_codes`
  - 继续复用既有 OTP carrier，只扩 `scene=password_reset` 语义，不新建 OTP 表

## 4. 最小 persistence 字段集合

### 4.1 `password_credentials` 最小字段

Round B 最小字段集合冻结为：

- `userId`
- `passwordHash`
- `passwordSetAt`
- `passwordUpdatedAt`
- `passwordAlgo`

### 4.2 明确纳入 Round B 的字段

#### `userId`

- 唯一锚定当前 `mobile -> user` 主体
- `password_credentials.userId` 必须唯一
- 一个 `user` 在 Round B 只允许一条 password credential

#### `passwordHash`

- 唯一合法 password 真值
- 不得明文存储
- 不得可逆加密存储

#### `passwordSetAt`

- 首次成功设置密码时间
- 用于区分“已设置过密码”与“未设置过密码”

#### `passwordUpdatedAt`

- 最近一次 password 变更时间
- 用于 reset / overwrite 审计与后续安全判断

#### `passwordAlgo`

- Round B 纳入
- 理由：需要把 hash family 明确落盘，避免后续校验逻辑漂移
- 当前 Round B 固定值见第 7 章

### 4.3 明确不纳入 Round B 的字段

#### `passwordVersion`

- `不进 Round B`
- 理由：当前只冻结单一算法家族与单一最小闭环，不做多轮密码策略版本编排

#### `passwordResetRequired`

- `不进 Round B`
- 理由：当前不做强制改密、风控强制改密、账号安全中心
- 该字段若后续需要，必须单独开新一轮冻结，不得在 Round B 顺手加入

## 5. Truth 流程裁决

### 5.1 password login truth

正式冻结如下：

1. 先按 `mobile` 定位当前 `mobile -> user`
2. 再按 `userId` 查找 `password_credentials`
3. 使用 `passwordHash + passwordAlgo` 校验输入密码
4. 成功后复用既有 `session / device` 闭环
5. 不新开第二套 token/session truth

补充裁决：

- `password login` 成功后的 session truth 与 OTP login 一致
- `BFF` 只承接透传与整形
- `Server` 是唯一 password login truth owner

### 5.2 password login 失败语义

正式冻结如下：

- 若 `mobile` 不存在，返回统一失败
- 若 `user` 存在但未设置 password credential，不得在 public login 面暴露账号状态细节
- 若密码不匹配，返回统一失败
- 对 public login，统一对外落入 `AUTH_PASSWORD_LOGIN_INVALID`
- `AUTH_PASSWORD_NOT_SET` 不用于 public password login 的账号枚举暴露

### 5.3 set-password truth

正式冻结如下：

- `set password` 只允许当前已通过 OTP 登录的当前账号调用
- 必须基于当前有效 session
- 必须锚定当前 session 的 `userId`
- 不允许未登录状态直接 set password

关于“当前账号已有/无 password”的判断冻结如下：

- 若当前账号不存在 `password_credentials`：
  - 允许创建 password credential
- 若当前账号已存在 `password_credentials`：
  - Round B 的 `set-password` 不允许覆盖旧密码
  - 返回 `AUTH_PASSWORD_SET_NOT_ALLOWED`

正式判断：

- Round B 的 `set-password` 只承接“补齐密码”
- 不承接“修改已有密码”
- 不扩成完整密码治理中心

### 5.4 reset-password truth

正式冻结如下：

- 输入固定为：
  - `mobile`
  - `scene=password_reset`
  - `otpCode`
  - `newPassword`
- `Server` 先按 `mobile` 定位当前 `mobile -> user`
- 再校验 `login_otp_codes` 中 `scene=password_reset` 的有效 OTP
- OTP 验证通过后：
  - 若已有 `password_credentials`，更新其 `passwordHash / passwordUpdatedAt`
  - 若尚无 `password_credentials`，创建一条最小 credential
- `reset` 成功后不自动登录
- `reset` 成功后不自动创建 session
- `reset` 不得写成注册 flow

### 5.5 overwrite 约束

Round B 明确区分：

- `set-password`
  - 只允许无 password credential 的当前 OTP 已登录账号补齐密码
  - 不允许覆盖旧密码
- `reset-password`
  - 允许覆盖已有 password credential
  - 但必须经过 `scene=password_reset` 的 OTP 验证
  - 必须写入最小 audit
  - 不自动登录

## 6. Password Policy Freeze

Round B 最小 password policy 正式冻结如下：

### 6.1 最小长度

- 最小长度：`8`

### 6.2 组成要求

- 必须同时包含：
  - 至少一个字母
  - 至少一个数字

### 6.3 空白规则

- 禁止纯空格
- 首尾空白在进入校验前必须先 trim
- trim 后若为空，视为非法密码

### 6.4 与手机号关系

- 不允许与当前手机号完全相同
- 理由：`mobile` 是当前唯一登录 identity，密码不得退化成 identity 本身

### 6.5 与旧密码关系

- `set-password`
  - 不涉及旧密码覆盖，因为 Round B 不允许 set 覆盖已有密码
- `reset-password`
  - 不允许与当前已存在密码相同
  - 若相同，返回 `AUTH_PASSWORD_POLICY_INVALID`

### 6.6 明确不纳入 Round B 的 policy 项

以下项全部 `不进 Round B`：

- 特殊字符强制要求
- 多档复杂度分层
- 密码到期策略
- 历史密码轮换策略
- 风控强制改密策略
- 账号锁定中心

## 7. Hashing / Secret Freeze

### 7.1 存储方式

正式冻结如下：

- password 必须 hash 后存储
- 不得明文存储
- 不得可逆加密存储

### 7.2 算法家族

Round B 正式冻结算法家族为：

- `argon2id`

不得写成：

- “实现时自行选择”
- “bcrypt 或 argon2 均可”

### 7.3 secret / pepper

Round B 正式冻结如下：

- 需要独立 server-side pepper / secret env
- 该 secret 只允许 `Server` 使用
- 不得暴露给 `BFF`
- 不得暴露给 `Flutter`

最小边界判断：

- `argon2id + per-password salt + server-side pepper` 是 Round B 唯一合法方向
- `BFF` 不持有 hashing secret
- `Flutter` 不持有 hashing secret

### 7.4 security 边界

- `BFF` 不参与 password truth 决策
- `BFF` 只做 transport / normalization
- `Flutter` 只做输入与消费
- password truth 只在 `Server` 完成 hash / verify / update

## 8. Audit Truth Freeze

Round B audit owner 固定为 `Server`。

### 8.1 每个 audit 的最小记录字段

每条 Round B password audit 至少记录：

- `eventType`
- `actorType`
- `actorUserId`
- `targetUserId`
- `mobile`
- `traceId`
- `sessionId`
- `deviceId`
- `ip`
- `result`
- `occurredAt`

### 8.2 各事件最小语义

#### `password_set`

- `actorType = user`
- `actorUserId = 当前 session userId`
- `targetUserId = 当前 session userId`
- `mobile = 当前账号 mobile`
- `traceId / sessionId / deviceId / ip`
- `result = success | failure`

#### `password_reset_requested`

- `actorType = anonymous_or_user`
- `actorUserId = null 或当前可识别 userId`
- `targetUserId = mobile 命中的 userId（若存在）`
- `mobile`
- `traceId / deviceId / ip`
- `result = accepted | rejected`
- 该事件对应 `scene=password_reset` 的 OTP send 受理

#### `password_reset_success`

- `actorType = anonymous_or_user`
- `actorUserId = null`
- `targetUserId = mobile 命中的 userId`
- `mobile`
- `traceId / deviceId / ip`
- `result = success`

#### `password_login_failure`

- `actorType = anonymous`
- `actorUserId = null`
- `targetUserId = 命中则记录 userId，否则 null`
- `mobile`
- `traceId / deviceId / ip`
- `result = failure`

#### `password_login_success`

- `actorType = user`
- `actorUserId = 登录成功 userId`
- `targetUserId = 登录成功 userId`
- `mobile`
- `traceId / sessionId / deviceId / ip`
- `result = success`

#### `password_reset_failure`

- `actorType = anonymous_or_user`
- `actorUserId = null`
- `targetUserId = 命中则记录 userId，否则 null`
- `mobile`
- `traceId / deviceId / ip`
- `result = failure`

## 9. Migration Freeze

### 9.1 Round B 必需 migration

Round B 需要的 persistence migration 正式冻结为：

1. 新增 `password_credentials` carrier migration

### 9.2 migration 明确判断

正式判断如下：

- `需要且只需要一个新的 password credential carrier migration`
- `users` 表本轮不扩列
- `sessions` 表本轮不扩列
- `devices` 表本轮不扩列
- `login_otp_codes` 表本轮不需要 schema migration

### 9.3 关于 `scene=password_reset`

正式判断如下：

- `login_otp_codes.scene` 现为 varchar 字段
- `scene=password_reset` 是 contract / truth 语义扩展
- 不要求新增 OTP 表
- 不要求为 `scene` 单独做 schema migration
- parser / service / truth logic 后续实现时必须显式支持该 scene，但这不属于本轮实现

### 9.4 audit carrier migration

正式判断如下：

- Round B 复用现有 audit carrier
- 不新增新的 audit 表
- 只新增 password 相关事件类型与字段填充规则
- 该部分属于 truth freeze，不是实现完成

## 10. 合规与发布门禁

### 10.1 truth 完成前的阻断条件

在本轮 backend truth / persistence freeze 完成前，以下全部 `No-Go`：

- `BFF` password family 实现
- `Flutter` 双入口与 password flow 实现
- 任意 password runtime implementation

### 10.2 truth 完成后的唯一放行方向

本轮入库后，唯一允许进入的下一阶段是：

- `Round B BFF surface freeze`

### 10.3 进入 BFF surface freeze 前必须成立的条件

- password truth carrier 已正式冻结
- password login / set / reset 的后端真相路径已冻结
- `scene=password_reset` 的 OTP 复用规则已冻结
- password policy 已冻结
- hash / secret 边界已冻结
- audit truth 已冻结
- migration 范围已冻结

### 10.4 仍然不允许的事项

即使本轮入库，也仍然不允许：

- 直接进入 Flutter
- 直接进入实现
- 直接宣布 Round B 上线
- 扩成完整账号安全中心

## 11. No-Go 边界

以下全部保持 `No-Go`：

- 不得把 Round B backend truth 写成完整账号系统
- 不得把 `password_credentials` 扩成 provider identity 中层
- 不得把 `reset-password` 写成注册 flow
- 不得把 `set-password` 写成完整密码管理中心
- 不得开放用户名登录
- 不得开放邮箱登录
- 不得开放微信 / Apple / 一键登录 / SSO
- 不得新增第二套 token/session truth
- 不得让 `BFF` 持有 password truth
- 不得让 `Flutter` 持有 password truth
- 不得把 `set-password` 扩成“已有密码也可随意改密”的完整安全中心
- 不得把本轮 truth freeze 写成实现完成

## 12. 下一步唯一动作

下一步唯一动作：

- `等待总控发出 Round B implementation package bundle`

## 裁决

`Round B backend truth / persistence freeze 是否可入库：是`

入库含义仅限：

- password persistence 方案已冻结
- truth 流程已冻结
- password policy 已冻结
- hashing / secret 边界已冻结
- audit truth 已冻结
- migration 范围已冻结

这不代表：

- backend 已实现
- BFF 已实现
- Flutter 已实现
- Round B 已上线
- 完整账号系统已成立

`下一步唯一动作是什么：等待总控发出 Round B implementation package bundle`
