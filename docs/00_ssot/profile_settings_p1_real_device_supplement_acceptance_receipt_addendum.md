---
owner: Codex 总控
status: no_go
purpose: Record the real-device supplement verification attempt for P1 profile settings, limited to visible display, cache cleanup dialog, version information, and text overflow.
layer: L0 SSOT
acceptance_date_local: 2026-04-28
---

# 《设置 P1 真机补验回执》

## 1. 总控结论

本次补验结论：`No-Go`。

No-Go 原因不是 P1 代码边界扩大，也不是 BFF / Server 阻塞。补验期间先遇到真机锁屏 / 黑屏，解锁后 App 已能启动到真机，但页面停在“当前离线”承接面，无法进入设置 P1 页面完成真实视觉验收。

当前最终阻塞已更新：

1. 已确认手机 5G 可以直接访问公网云端 BFF，不应继续使用手机上的 `127.0.0.1:8080`。
2. 已确认公网入口 `http://47.108.180.198/api/app` 可达。
3. 用户已确认允许本次真机补验切换到公网云端 BFF 入口。
4. 但切换入口后，Mac 端开发连接显示真机 `unavailable / offline`，无法重新安装带公网 BFF 配置的真机包，也无法继续抓取验收截图。
5. 用户确认手机仍使用 5G 网络；该点不构成阻塞，App 运行时访问公网 BFF 本来就应走手机 5G。
6. 当前阻塞只在 Mac 到 iPhone 的 USB 开发连接：用于安装包和截图，不用于 App 访问 BFF。
7. 用户随后要求直接安装；总控再次尝试安装前置检查，但 Xcode Devices 仍将 `王巍威的iPhone` 放在 `Disconnected` 分组，`Take Screenshot` 与 `Open Console` 为禁用状态，因此无法开始安装。
8. 用户反馈“可以了”后，总控再次执行 `flutter devices --device-timeout=30`、`xcrun devicectl list devices`、`xcrun xctrace list devices`、`xcrun xcdevice wait --usb --timeout 90 00008130-000A0D313620001C`，结果仍未恢复可安装状态。

本次已完成的事实：

1. 已识别真机：`王巍威的iPhone`。
2. 已确认设备类型：`iPhone 15 Pro`。
3. 已确认系统版本：`iOS 26.3.1`。
4. 已确认设备 UDID：`00008130-000A0D313620001C`。
5. 已确认 App 已安装到真机：`com.example.mobile`，版本 `1.0.0`，构建号 `1`。
6. 已尝试通过 Flutter 真机调试启动。
7. 已尝试通过 `devicectl` 前台启动已安装 App。
8. 解锁后已通过 release 真机运行进入 App。
9. 已观察用户提供的真机截图，页面显示为“当前离线”。
10. 已清理本次临时登录引导文件，并完成测试 session 退出。
11. 已确认公网云端 BFF 入口可达。
12. 已确认下一轮应使用 `http://47.108.180.198/api/app`，不再使用手机侧的 `127.0.0.1:8080`。

本次未完成的验收：

1. 设置页 P1 真机实际显示。
2. 清理缓存二次确认弹窗真机显示。
3. 当前版本页真机显示。
4. 设置页 / 详情页文字是否在真机上溢出。

## 2. 本次补验边界

本次只验证：

- 真机显示是否正常。
- 清理缓存弹窗是否出现且文案可读。
- 当前版本信息是否真实展示。
- 设置页相关文字是否不溢出、不遮挡。

本次明确不验证 / 不进入：

- 完整设备管理。
- 踢设备 / 撤销设备。
- 完整公司认证办理。
- 完整个人认证提交链路。
- BFF / Server 修改。
- contracts 修改。
- 云端写入修改。

## 3. 关键证据

### 3.1 设备识别

命令：

- `flutter devices`

结果：

- 识别到无线真机：`王巍威的iPhone (wireless) · 00008130-000A0D313620001C · iOS 26.3.1 23D771330a`
- 同时存在另一台离线 iPhone；未纳入本次补验。

### 3.2 设备详情

命令：

- `xcrun devicectl device info details --device 00008130-000A0D313620001C`

结果摘要：

- 设备类型：`iPhone 15 Pro`
- 设备系统：`iOS 26.3.1`
- 开发者模式：`enabled`
- 连接方式：`localNetwork`
- 设备能力包含：`View Device Screen`

### 3.3 App 安装状态

命令：

- `xcrun devicectl device info apps --device 00008130-000A0D313620001C`

结果摘要：

- `Mobile`
- `com.example.mobile`
- version：`1.0.0`
- bundle version：`1`

### 3.4 Flutter debug 真机启动尝试

命令：

- `flutter run --no-pub -d 00008130-000A0D313620001C --dart-define-from-file=/tmp/mobile-p1-real-device-bootstrap.XXXXXX.json`

结果摘要：

- Xcode build 完成。
- 安装 / 调试阶段进入 LLDB / shared cache symbols 流程。
- Flutter 提示无线调试较慢，并提示未在预期时间内发现 Dart VM Service。
- 最终结果：`The Dart compiler exited unexpectedly.`

### 3.5 devicectl 前台启动尝试

命令：

- `xcrun devicectl device process launch --device 00008130-000A0D313620001C --terminate-existing com.example.mobile`

锁屏时结果：

- 系统拒绝启动。
- 关键错误：`Unable to launch com.example.mobile because the device was not, or could not be, unlocked.`

解锁后结果：

- `Launched application with com.example.mobile bundle identifier.`
- 但已安装的 debug App 不能脱离 Flutter tooling / Xcode 直接前台运行。
- 关键错误：`Cannot create a FlutterEngine instance in debug mode without Flutter tooling or Xcode.`

### 3.6 release 真机运行

命令：

- `flutter run --release --no-pub -d 00008130-000A0D313620001C --dart-define-from-file=/tmp/mobile-p1-real-device-bootstrap.XXXXXX.json`

结果摘要：

- Xcode build 完成。
- 安装完成。
- Flutter run 进入交互状态。
- 真机可见页面，但停在离线承接面，未能进入设置 P1。

### 3.7 屏幕状态

命令：

- `xcrun devicectl device info displays --device 00008130-000A0D313620001C`

锁屏时结果摘要：

- 主屏尺寸：`1179 x 2556`
- 方向：`portrait`
- 背光状态：`backlight is off`

解锁后结果摘要：

- 主屏尺寸：`1179 x 2556`
- 方向：`portrait`
- 背光状态：`backlight is on and active`

### 3.8 用户真机截图观察

用户提供的三张真机截图显示：

1. `我的` Tab：显示“当前离线 / 当前网络不可用，页面先停留在离线承接面 / 重试承接”。
2. `消息` Tab：显示“当前离线 / 当前网络不可用，页面先停留在离线承接面 / 重试承接”。
3. `展览` Tab：显示“当前离线 / 当前网络不可用，页面先停留在离线承接面 / 重试承接”。

观察结论：

- 真机显示本身可观察。
- 底部 Tab 与离线承接卡片没有明显文字溢出。
- 但该画面不是设置 P1 页面，不能替代设置 P1 真机验收。
- 真机网络不可达是当前阻塞。

### 3.9 公网云端 BFF 入口复核

命令：

- `curl http://47.108.180.198/`
- `curl http://47.108.180.198/api/app/shell/context`

结果摘要：

- `/` 返回 `200`。
- `/api/app/shell/context` 返回 `401 AUTH_SESSION_INVALID`。

结论：

- `401` 是未登录状态的合理返回，说明公网 app-facing BFF 路由可达。
- 真机 5G 直连公网 BFF 是可行路线。
- 本次后续真机包应使用 `APP_BFF_BASE_URL=http://47.108.180.198/api/app`。

### 3.10 切换公网入口后的设备连接状态

命令：

- `flutter devices`
- `xcrun xctrace list devices`
- `xcrun devicectl list devices`
- `xcrun xcdevice wait --usb --timeout 60 00008130-000A0D313620001C`
- `ioreg -p IOUSB -l -w0`

结果摘要：

- Flutter 只识别到 `macOS` 与 `Chrome`。
- `王巍威的iPhone` 在 Xcode / CoreDevice 中显示为 offline / unavailable。
- `xcdevice wait --usb` 等待 60 秒后仍未出现目标设备。
- `ioreg` USB 总线未发现 iPhone / Apple Mobile Device。
- 错误提示要求设备解锁并通过 USB 连接，或与 Mac 处于同一局域网。
- Xcode Devices UI 中该设备位于 `Disconnected` 分组。
- Xcode 的 `Take Screenshot` 与 `Open Console` 均为禁用状态。

结论：

- 手机用 5G 访问公网 BFF 没问题。
- 但 Mac 要重新安装带公网 BFF 配置的 iOS 包、并抓取 Xcode 设备截图，仍需要 USB 数据连接或同局域网开发连接。
- 当前 USB 更像只充电或未完成信任 / 数据握手，不是 App 5G 网络问题。
- 当前无法进入下一步安装与截图。

### 3.11 安装尝试裁决

用户已确认要求安装。

安装前置检查结果：

- `flutter devices --device-timeout=30` 未列出 iPhone。
- `xcrun xcdevice list --timeout 20` 显示目标 iPhone `available=false`，`interface=usb`，错误码 `-27`。
- `xcrun devicectl device info details` 显示 `pairingState=paired`，但 `tunnelState=unavailable`，`ddiServicesAvailable=false`。
- Xcode Devices UI 显示设备 `Disconnected`。
- 用户反馈“可以了”后复查，`xcrun xcdevice wait --usb --timeout 90 00008130-000A0D313620001C` 仍返回目标设备 90 秒内未出现。

裁决：

- 当前不能执行安装。
- 不是 App 包、BFF、Server 或 5G 网络问题。
- 必须先恢复 Mac 与 iPhone 的可用开发连接。

## 4. 安全清理

本次使用测试账号取得临时启动参数文件，用于真机启动前置态注入。

清理结果：

- 临时引导文件：已删除。
- 第二轮解锁后补验的退出登录请求：返回 `200`。

解释：

- 第一轮临时 access token 曾因锁屏阻塞耗时返回 `401`。
- 第二轮 release 真机运行后已成功退出测试 session。
- 本地临时引导文件已删除。
- 未在回执中记录账号密码、token、refresh token 或完整 device id 以外的敏感凭据。

## 5. 验收判断

| 验收项 | 本次结果 | 是否通过 | 说明 |
|---|---|---:|---|
| 真机安装 | 已安装 | 是 | `com.example.mobile` 已出现在真机 app 列表 |
| 真机前台启动 | release 已启动 | 是 | debug 直启受限，release 可进入 App |
| 公网 BFF 可达 | 已确认 | 是 | `http://47.108.180.198/api/app/shell/context` 返回未登录 401 |
| 真机网络承接 | 当前离线 | 否 | 旧包仍使用手机侧 `127.0.0.1:8080` |
| 带公网入口的真机包 | 未能安装 | 否 | Mac 当前无法连接真机 |
| 设置页 P1 显示 | 未能观察 | 否 | App 停在离线承接面 |
| 清理缓存弹窗 | 未能观察 | 否 | App 停在离线承接面 |
| 当前版本信息 | 未能观察 | 否 | App 停在离线承接面 |
| 文字不溢出 | 部分观察 | 否 | 离线页无明显溢出，但不能替代设置 P1 |
| 完整设备管理 | 未进入 | 符合边界 | 本次禁止展开 |
| 完整认证办理 | 未进入 | 符合边界 | 本次禁止展开 |

## 6. 风险与下一步

已解决风险：

- 未把 Mac 桌面端结果冒充真机验收。
- 未为真机绕开既定 `127.0.0.1:8080` 隧道边界。
- 未修改 BFF / Server / contracts。
- 未进入完整设备管理或完整认证办理。
- 已清理真机补验临时测试 session。

未解决但不属于代码阻塞的风险：

- iPhone 无线调试依赖设备亮屏、解锁和本地网络权限。
- iPhone 上的 `127.0.0.1` 不等于 Mac 的 SSH 隧道入口。
- 用户已确认本次真机补验可改用公网云端 BFF，但重新装包仍需要 Mac 与 iPhone 保持开发连接。
- 手机继续使用 5G 是正确方向；USB 只用于装包和截图。

阻塞项：

- `王巍威的iPhone` 当前在 Flutter / Xcode 中为 offline / unavailable，且未在 USB 总线中形成可用数据连接，无法安装带公网 BFF 配置的真机包。
- 用户已要求安装，但安装前置条件未满足。

下一轮唯一动作：

- 将 iPhone 临时接入 USB，或让 iPhone 与 Mac 回到同一 Wi-Fi 开发连接。
- 保持手机 5G 可用；不要切换到 Mac 网络作为 App 访问 BFF 的前提。
- 在手机上确认“信任此电脑”提示；如无提示，重新插拔数据线、解锁屏幕，必要时更换可传数据的线或接口。
- 使用 `APP_BFF_BASE_URL=http://47.108.180.198/api/app` 重新安装 release 真机包。
- 只重跑设置 P1 真机视觉补验：设置页显示、清理缓存弹窗、版本信息、文字不溢出。

## 7. 非本轮 dirty files 记录

补验期间曾检测到展览首页相关非本轮变更，收口时工作区 dirty files 又发生变化。总控未回滚、未合并、未纳入本次 P1 补验结论。

收口时检测到：

- `apps/mobile/ios/Podfile.lock`
- `apps/mobile/lib/features/profile/presentation/profile_identity_legal_pages.dart`
- `apps/mobile/lib/shell/navigation/app_router.dart`
- `apps/mobile/lib/shell/presentation/shell_state_page.dart`
- `apps/mobile/lib/features/profile/presentation/profile_login_page.dart`

这些变更不属于本次真机补验实现范围。
