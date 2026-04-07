---
owner: Codex 总控
status: frozen
purpose: Freeze the single bounded `Personal minimal edit` package so `头像` and `昵称` may be introduced on `个人资料` without drifting into OCR, real-name, organization, certification, or broader profile-center expansion.
layer: L0 SSOT
freeze_date_local: 2026-04-06
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/profile_ia_cleanup_boundary_freeze_addendum.md
  - apps/mobile/lib/features/profile/presentation/profile_detail_pages.dart
  - apps/mobile/lib/features/profile/presentation/profile_detail_widgets.dart
  - apps/mobile/lib/features/profile/presentation/profile_visible_copy.dart
  - apps/mobile/lib/core/boot/app_shell_context.dart
  - apps/mobile/lib/core/boot/app_shell_context_consumer.dart
  - apps/bff/src/routes/profile/app-profile-command.controller.ts
  - apps/bff/src/routes/profile/profile-command.service.ts
  - apps/bff/src/routes/file/file.service.ts
  - apps/server/src/modules/identity/entities/user.entity.ts
  - apps/server/src/modules/auth/auth-session.service.ts
  - apps/server/src/modules/upload/upload-write.service.ts
---

# `Personal minimal edit` 边界冻结单

## 1. Scope

- 本轮唯一对象只限：
  - `我的楼 / 个人资料`
  - `头像`
  - `昵称`
- 本轮唯一目标只限：
  - 在 `个人资料` 页红框上方新增两项可编辑入口：
    - `头像`
    - `昵称`
  - 让头像与昵称形成最小可用编辑闭环
  - 让成功保存后的显示结果能回读到当前个人可见面
- 本轮明确不是：
  - 个性签名
  - 性别 / 生日 / 地区
  - 营业执照上传
  - OCR 识别
  - 身份证上传
  - 个人实名
  - 自动审核 / 审核后台
  - 公司信息编辑
  - 公司认证流程简化

## 2. Current Accepted Baseline

- `Profile IA cleanup` 已完成，当前 `个人资料` 页顶部卡片已被明确定义为：
  - 资料摘要卡
  - 非编辑器
  - 非头像上传入口
- 当前 `个人资料` 页仍明确写着：
  - `当前只展示资料摘要；昵称和头像编辑暂未在这里开放。`
- `users` 真相表当前已经存在：
  - `nickname`
  - `avatar_url`
- 当前首次验证码登录自动建户时，后端会把：
  - `nickname = null`
  - `avatarUrl = null`
- 当前 App Shell 上下文与 `个人资料` 页的主要读面仍只消费：
  - `userId`
  - 而不是正式的 `displayName / avatarUrl`
- 当前 app-facing `profile command family` 只覆盖：
  - organization create / join / switch
  - certification submit / resubmit
  - member role / disable
  - security device revoke
- 当前并不存在：
  - `nickname edit` app-facing command
  - `avatar commit` app-facing command
- 当前 upload 三步流已经存在，但 `Server` truth 仍只支持：
  - `businessType = project`
  - `fileKind = evidence`
- 因此，`头像上传` 当前不是单纯前端 UI 问题，而是：
  - `profile command`
  - `upload truth`
  - `readback projection`
  三条链同时缺口

## 3. Minimum Package Object

- 本包冻结后的最小对象是：
  - `个人资料` 页新增 `头像` 行
  - `个人资料` 页新增 `昵称` 行
  - 一个 `个人头像` 页面
  - 一个 `设置昵称` 页面
  - 一条 `昵称写入 -> 回读显示` 最小闭环
  - 一条 `头像上传三步流 -> 头像提交 -> 回读显示` 最小闭环
- 本包必须承认的真实目标是：
  - 改完以后，用户在 `我的楼` 和 `个人资料` 的可见面不能继续只显示手机号和字母占位
- 因此，本包不是“做两个入口”而已；
  它必须同时关心：
  - write path
  - readback path
  - fail-closed path

## 4. Frozen UX Decisions

### 4.1 Personal Page Placement

- `头像` 与 `昵称` 必须插入在 `个人资料` 页红框上方。
- 两项入口必须位于当前 `资料摘要` section 之前。
- 本轮不得把 `头像` 或 `昵称` 塞进顶部摘要卡内部伪装成“可编辑卡片”。
- 本轮冻结后的结构顺序固定为：
  - 顶部摘要卡
  - `头像`
  - `昵称`
  - `资料摘要`
  - `身份与安全`

### 4.2 Avatar Surface

- `头像` 行必须展示：
  - 当前头像缩略图；若没有头像，则展示当前 fallback 占位
- 点击 `头像` 行后，必须进入：
  - `个人头像`
- `个人头像` 页右上角必须出现：
  - `更换头像`
- `更换头像` 点击后，本包只允许弹出最小操作表：
  - `拍照`
  - `从相册选择`
  - `取消`
- 本包明确不做：
  - 裁剪编辑器
  - 滤镜
  - 头像历史
  - 保存图片
  - AI 处理

### 4.3 Nickname Surface

- `昵称` 行必须展示：
  - 当前昵称
  - 若尚未设置，则展示 `未设置`
- 点击 `昵称` 行后，必须进入：
  - `设置昵称`
- `设置昵称` 页本包只允许包含：
  - 单个文本输入框
  - 一个 `完成` 动作
  - 必要的规则提示
- `完成` 按钮在以下场景必须禁用：
  - 空值
  - 未变更
  - 超长
  - 含非法字符

## 5. Frozen Rule Families

### 5.1 Nickname Rule

- 昵称长度冻结为：
  - `1 ~ 10` 个字
- 当前包的 authoritative validation 冻结为：
  - 只允许中文汉字
  - 不允许空格
  - 不允许英文字母
  - 不允许数字
  - 不允许标点
  - 不允许 emoji
- 当前包不冻结：
  - 昵称唯一性校验
  - 违禁词系统
  - 语言学意义上的简繁体判定引擎
- 当前包的产品文案可以表达为：
  - `昵称仅支持 1~10 个中文汉字`
- 但真正的 authoritative gate 必须在 `Server` 侧执行，前端只能镜像校验。

### 5.2 Avatar Rule

- 当前包只允许：
  - 单张图片头像
- 当前包头像写入必须沿用既有三步流：
  - `init`
  - `direct upload`
  - `confirm`
- 当前包绝不允许把：
  - 本地文件路径
  - 临时 object URL
  - `objectKey`
  直接当成头像业务真相
- 当前包必须继续遵守：
  - `FileAsset` 才是文件真相
- 当前包的 app-facing surface 只允许消费：
  - 已确认的头像投影
- 当前包不冻结：
  - 多尺寸头像裁剪
  - 封面图
  - 相册管理
  - 图像审核系统

## 6. Readback Consistency Freeze

- 当前包冻结后的回读范围至少必须覆盖：
  - `我的楼` 顶部用户卡
  - `个人资料` 顶部摘要卡
  - `头像` 行
  - `昵称` 行
- 当前包必须承认：
  - 只写成功但不回读更新，视为闭环失败
- 当前包允许的回读来源只限：
  - app-facing `profile` / `shell context` 正式投影
- 当前包明确不允许：
  - 前端仅靠本地内存临时冒充“已更新”
  - 写完后只更新当前页，不更新个人主入口

## 7. Execution Ownership And Bounded Write Sets

- `Frontend Agent` 后续只允许在以下范围施工：
  - `apps/mobile/lib/features/profile/**`
  - `apps/mobile/lib/core/boot/**`
- `Backend Agent` 后续只允许在以下范围施工：
  - `apps/bff/src/routes/profile/**`
  - `apps/bff/src/routes/file/**`
  - `apps/server/src/modules/profile/**`
  - `apps/server/src/modules/upload/**`
  - `apps/server/src/modules/identity/**`
  - 必要时的最小 migration carrier
- 当前包明确禁止执行者扩写到：
  - `organization`
  - `certification`
  - `messages`
  - `exhibition`
  - `payment / billing`
  - `V2.3`

## 8. Explicit In-scope

- `个人资料` 页新增 `头像` 行
- `个人资料` 页新增 `昵称` 行
- `个人头像` 页面
- `设置昵称` 页面
- `nickname` authoritative validation
- `avatar` 三步上传闭环
- 成功写入后的个人可见面回读
- fail-closed 文案与状态处理

## 9. Explicit Out-of-scope

- 个性签名
- 性别 / 生日 / 地区
- 营业执照上传
- OCR 识别
- 身份证上传
- 个人实名
- 自动审核 / 风控判真
- 公司信息编辑
- 公司认证简化
- 成员管理扩包
- 头像裁剪 / 滤镜 / 历史头像
- 审核后台 / Admin 操作台

## 10. Acceptance Standard

- 用户进入 `个人资料` 页时，能在红框上方直接看到：
  - `头像`
  - `昵称`
- 点击 `头像`，能进入 `个人头像` 页面，并看到右上角：
  - `更换头像`
- 点击 `昵称`，能进入 `设置昵称` 页面，并看到单输入框和规则提示。
- 非法昵称必须在前后端都被拦住，且不得伪造成功。
- 头像上传任一阶段失败时，页面必须 fail-closed，不得伪造成功头像。
- 成功保存后，`我的楼` 顶部用户卡与 `个人资料` 顶部摘要卡必须回读到新昵称/新头像。
- 本轮交付后，不得顺手引入任何：
  - OCR
  - 实名
  - 公司资料编辑
  - 审核流程

## 11. Stage Result

- `passed gates`
  - `Profile IA cleanup` 已完成，个人资料入口结构已收口。
  - `users.nickname / users.avatar_url` 真相字段已存在。
  - 既有 file upload 三步流已存在，可作为头像上传底座。
- `failed gates`
  - 个人资料 app-facing write family 尚不存在。
  - avatar upload truth 尚未支持 profile avatar 业务类型。
  - shell / profile readback 仍未消费正式 `displayName / avatarUrl`。
- `veto gates`
  - 禁止把当前包扩成 OCR / 实名 / 公司认证简化。
  - 禁止前端假做本地成功而不走 Server 真相。
  - 禁止把 raw object key 当成头像业务真相。
- `stage decision`
  - `Go for bounded Personal minimal edit execution split authoring`

## 12. Next Unique Action

- 输出：
  - `Personal minimal edit backend+bff bounded execution prompt`
  - `Personal minimal edit frontend bounded execution prompt`
