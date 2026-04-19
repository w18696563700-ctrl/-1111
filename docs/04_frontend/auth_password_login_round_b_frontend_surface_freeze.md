# 《账号密码登录最小闭环 Round B frontend surface freeze》

## 1. 目标

本轮只冻结 `账号密码登录最小闭环 Round B` 的 Flutter 双入口消费面。

本轮只承接：

- 登录页双入口
- OTP 分段
- password 分段
- `set-password` 最小消费面
- `forgot-password / reset` 最小消费面

本轮不是：

- 完整账号中心
- 第三方登录入口集合
- password truth owner
- Server / BFF 真相定义

## 2. 页面骨架 Freeze

登录页页面骨架正式冻结如下：

- 同一路由
- 同一登录壳
- 顶部使用 `segmented control`
- 左侧：`验证码登录`
- 右侧：`账号密码登录`

补充规则：

- 不新增第三个登录主入口
- 不拆成两个独立登录路由
- 不把 `set-password` 放进主入口切换

## 3. OTP 分段 Freeze

OTP 分段固定包含：

- 手机号输入
- 发送验证码
- 验证码输入
- 登录按钮

附加规则：

- 继续共用 Round A legal 勾选 gate
- 不破坏 Round A 已成立 OTP 主链
- 不因 Round B 引入新的 OTP 登录语义漂移

## 4. password 分段 Freeze

password 分段固定包含：

- 手机号输入
- 密码输入
- 登录按钮
- 次级入口：`忘记密码`

附加规则：

- password 分段只承接 `mobile + password`
- 不承接 username
- 不承接 email
- 不承接第三方登录

## 5. set-password Surface Freeze

`set-password` 正式冻结如下：

- 不作为登录页第三入口
- 仅对当前 OTP 已登录账号开放
- 作为独立最小页面或 sheet
- 只补齐密码，不表示注册完成

附加边界：

- 不扩成完整账号中心里的改密中心
- 不扩成“已设置密码用户的常规修改密码面”
- 不新增第二身份载体

## 6. forgot-password Surface Freeze

`forgot-password` 正式冻结如下：

- 从 password 分段进入
- 手机号输入
- 发送 OTP（`scene=password_reset`）
- OTP 输入
- 新密码输入
- 提交 reset
- reset 成功后不自动登录

附加边界：

- 不写成注册 flow
- 不写成找回并自动建号
- 不写成自动登录

## 7. Consent Gate Freeze

本轮 consent gate 正式冻结如下：

- OTP 与 password 两个入口共用同一 legal 勾选 gate
- 未勾选前：
  - 发送验证码不可用
  - OTP 登录不可用
  - password 登录不可用

关于 `set/reset` 的冻结判断如下：

- `set-password`
  - 复用当前已登录账号既有 consent truth
  - 不新增新的独立 legal 逻辑
- `forgot-password / reset`
  - reset 页不新增新的独立 legal 逻辑
  - 不要求第二套勾选框

## 8. 页面状态矩阵

### 8.1 OTP 分段

- 空态
- 输入中
- 发送中
- 倒计时
- 登录中
- 成功
- 验证码错误

### 8.2 password 分段

- 空态
- 输入中
- 登录中
- 密码错误
- 未设置密码
- 成功

### 8.3 set-password

- 提交中
- 成功
- 失败

### 8.4 forgot-password / reset

- OTP 发送中
- 倒计时
- reset 提交中
- OTP 错误
- policy 错误
- 成功

### 8.5 通用状态

- 协议未勾选态
- fallback 态
- timeout 态

冻结规则：

- 用户侧不得误解为“保存或设置后已立即上线”
- reset 成功不得伪装成已自动登录
- password 未设置态只表示当前 password family 不可用，不表示注册未完成

## 9. Frontend Error Consumption Freeze

本轮至少冻结以下 app-facing 错误展示语义：

- `AUTH_PASSWORD_LOGIN_INVALID`
  - 展示为统一密码登录失败语义
- `AUTH_PASSWORD_NOT_SET`
  - 展示为当前账号尚未设置密码的受控提示
- `AUTH_PASSWORD_SET_NOT_ALLOWED`
  - 展示为当前场景不允许设置密码的受控提示
- `AUTH_PASSWORD_RESET_OTP_INVALID`
  - 展示为 reset OTP 校验失败
- `AUTH_PASSWORD_POLICY_INVALID`
  - 展示为新密码不满足最小 policy
- `AUTH_CONSENT_REQUIRED`
  - 展示为先完成 legal 勾选

附加规则：

- 不得在 Flutter 侧拆解 public login 的账号枚举差异
- 不得在 Flutter 侧推断 backend 未返回的业务真相

## 10. No-Go 边界

以下全部写死为 `No-Go`：

- 不得引入用户名登录入口
- 不得引入邮箱登录入口
- 不得引入微信 / Apple / 一键登录 / SSO 入口
- 不得把 reset flow 写成注册 flow
- 不得把 set-password 写成账号中心
- 不得在 Flutter 持久化 password truth
- 不得新增第三个登录主入口
- 不得把 Round B 扩成完整账号系统

## 11. 合规与发布门禁

- frontend surface freeze 完成前，不进入实现派工
- 双入口不得破坏 Round A 已成立的 OTP 主链
- Flutter 只能消费 BFF app-facing surface
- Flutter 不得直连 Server password truth

## 12. 裁决

`Round B frontend surface freeze 是否可入库：是`

入库含义仅限：

- 双入口最小页面骨架已冻结
- OTP / password / set / reset 的消费边界已冻结
- consent gate / 页面状态 / 错误消费已冻结

这不代表：

- Flutter 已实现
- backend 已实现
- BFF 已实现
- Round B 已进入发布

`下一步唯一动作是什么：等待总控发出 Round B implementation package bundle`
