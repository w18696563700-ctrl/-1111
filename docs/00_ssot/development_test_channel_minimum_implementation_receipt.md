# 开发态测试通道最小实现回执

## 1. 实现范围

- 本次实现对象仅为本地 Flutter 的开发态测试通道。
- 本次只解决以下两点：
- 当前登录页上的“测试通道直接进入”此前仍依赖 OTP send/login，无法构成真正的 dev-only 直入。
- 当前 auth / shell / workbench 运行态未闭环时，人工测试无法进入 `/exhibition/projects/create`。
- 本次未改：
- `apps/bff/**`
- `apps/server/**`
- `infra/**`
- 部署配置
- 正式 OTP send/login
- 正式 shell context
- 正式 exhibition workbench
- bid / order / contract / milestone / inspection / rating / dispute

## 2. 改动文件清单

- `apps/mobile/lib/features/profile/presentation/profile_identity_access_pages.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart`
- `apps/mobile/test/shell_app_test.dart`

## 3. 当前 dev-only 测试通道行为说明

- 当前“测试通道直接进入”仍只在 `kDebugMode` 下显示。
- 点击后不再调用：
- `AuthConsumerLayer.sendOtp()`
- `AuthConsumerLayer.loginWithOtp()`
- 点击后会立即执行以下本地 dev-only 动作：
- 安装开发态 base URL override：`http://47.108.180.198/api/app`
- 建立本地 dev-only session carrier，写入 fake accessToken / refreshToken / deviceId
- 注入本地 dev-only shell context snapshot，包含：
- `userId`
- `organizationId`
- `roleKeys`
- `certificationStatus`
- `membershipStatus`
- `visibleBuildings`
- 额外写入 dev-only 标记：
- `featureFlagsVersion=dev_test_channel.project_publish_minimum_corridor`
- 完成上述本地注入后，直接路由进入：
- `/exhibition/projects/create`
- 当前项目发布页仅在以下条件同时满足时绕过 workbench create guard：
- 当前为 debug build
- 当前存在本地 session
- 当前 shell context 带有显式 dev-test-channel 标记
- 登录态与组织态守卫没有被全局删除；它们只是通过本地 dev-only session/shell snapshot 被受控满足。
- create / detail / upload 的 canonical API path 未改，后续 create/upload 仍走真实联调 runtime。

## 4. 为什么没有打开正式 auth 板块

- 冻结文书明确要求当前轮不得把人工测试阻塞问题升级为正式 OTP 登录实现。
- 因此本次没有实现或宣称：
- 正式 `sendOtp`
- 正式 `loginWithOtp`
- 正式账号登录成功
- 正式认证完成
- 当前 debug 按钮只是一个开发态测试通道，用于绕开未闭环的 auth 启动阻塞，不代表产品 auth 板块完成。

## 5. 为什么没有声称 shell/workbench 已完成

- 当前运行态已知未闭环项包括：
- `/api/app/shell/context`
- `/api/app/exhibition/workbench`
- 本次实现没有补做这些 runtime truth，也没有把它们伪装成已完成。
- 当前方案只是在显式 dev-test-channel active 时：
- 本地注入 shell context snapshot
- 仅对 `/exhibition/projects/create` 的 workbench create guard 做最小绕过
- 一旦进入项目发布页后，真实 create/upload 失败仍会按真实 runtime 失败暴露，不会被测试通道伪装为成功。

## 6. 测试结果

- 回归测试：
- 命令：`cd /Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile && flutter test test/shell_app_test.dart --plain-name "debug test channel enters project create without auth or workbench requests"`
- 结果：通过。
- 该测试已验证：
- debug 按钮点击后进入 `/exhibition/projects/create`
- 不请求 `/api/app/auth/otp/send`
- 不请求 `/api/app/auth/otp/login`
- 不请求 `/api/app/exhibition/workbench`
- 开发态 base URL override 已安装为 `http://47.108.180.198/api/app`
- 兼容性复核：
- 命令：`cd /Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile && flutter test test/shell_app_test.dart --plain-name "project create success carries real projectId to detail"`
- 结果：通过。
- 命令：`cd /Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile && flutter test test/shell_app_test.dart --plain-name "project create page reuses upload init-direct-confirm chain after success"`
- 结果：通过。

## 7. 对主线联调的影响

- 当前改动只打通“入口进入项目发布最小走廊”的开发态测试通道。
- 当前改动不改变主线的 create/detail/upload canonical path。
- 当前改动不改变真实 runtime 的成功或失败判定。
- 当前若 create/upload 失败，应解读为：
- 入口已打通
- runtime 联调未完成
- 不能解读为正式 auth / shell / workbench 已完成
- 当前方案对主线联调的正向作用仅是：
- 让人工测试不再被 OTP / shell / workbench 未闭环阻塞
- 让项目发布最小走廊可以继续做 development-stage integration validation

## 8. 修订记录

- `2026-04-02`：将登录页“测试通道直接进入”改为真正的 dev-only 直入，不再调用 OTP send/login。
- `2026-04-02`：为 debug 测试通道注入本地 fake session 与本地 shell context snapshot。
- `2026-04-02`：在项目发布页增加显式 dev-test-channel active 判定，仅在该条件下绕过 workbench create guard。
- `2026-04-02`：增加并通过针对 debug 测试通道的最小回归测试。
