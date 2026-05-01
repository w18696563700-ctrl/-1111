---
owner: Codex Control
status: pass_with_risk
layer: L0 SSOT
date: 2026-05-02
depends_on:
  - docs/00_ssot/mobile_media_picker_chat_preview_map_minimal_closure_boundary_freeze_addendum.md
---

# 手机端图片选择、聊天回显与地图跳转最小闭环执行回执

## 总控结论

本轮 Flutter 端最小闭环已完成本地实现与聚焦验证，结论为 `Pass with Risk`。

通过项：

- 聊天图片入口改为相册选择。
- 文件入口继续保留文件选择器。
- 图片消息可通过既有 preview access 获取 `accessUrl` 并在聊天气泡内回显缩略图。
- 点击图片附件优先进入 App 内 `InteractiveViewer` 预览，失败降级为原附件卡或失败提示。
- 地图入口优先尝试系统地图 / 已安装地图 App scheme，失败后保留原网页 fallback。
- 不改 BFF，不改 Server，不改 contracts，不新增接口，不伪造图片 URL。

保留风险：

- 真机已完成 USB 识别、iOS debug build、签名、安装/启动尝试，并确认 `com.zhanlandingzhijia.mobile` 已安装且存在运行进程；但调试 VM Service 未在 60 秒内连接，无法由 Codex 自动完成相册弹窗、图片发送、图片放大和地图 App 跳转的手点验截图。
- 广域 Flutter 回归存在本轮外失败项，集中在 profile/local_dev 测试配置、forum 附件卡可见性、项目附件走廊和个人资料返回按钮；不作为本轮媒体闭环的通过依据。

## 本轮实际改动边界

### 前端 Flutter

- `apps/mobile/lib/features/exhibition/presentation/presentation_support/project_attachment_support.dart`
  - 为图片入口新增 `imageOnly` 分支。
  - `imageOnly=true` 使用 `image_picker` 的 `ImageSource.gallery`。
  - debug picker override 优先级保持不变，测试入口不被破坏。

- `apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_page.dart`
  - 图片发送入口传入 `imageOnly`。
  - 新增图片附件 preview access 预加载、加载中集合、失败集合和简单内存缓存。
  - 图片附件点击时优先使用缓存 `accessUrl` 进入 App 内图片预览。

- `apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_chat_widgets.dart`
  - 图片附件渲染为缩略图卡片。
  - 缩略图加载中显示轻量占位。
  - preview access 不可用时降级为原附件文件名卡片。

- `apps/mobile/lib/features/exhibition/presentation/widgets/project_attachment_preview_widgets.dart`
  - 新增网络图片 App 内预览弹窗。
  - 支持关闭、放大、拖动和加载失败提示。

- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_relayout_sections.dart`
  - 地图按钮改为调用外部地图优先打开工具。
  - 有经纬度或既有网页链接时均可尝试打开。

- `apps/mobile/lib/features/exhibition/presentation/presentation_support/external_map_launcher.dart`
  - 新增地图候选 URL 构造与按序启动逻辑。
  - iOS 优先 `maps://`，再尝试高德、百度、腾讯、Google Maps、Apple Maps web 和既有网页 fallback。
  - Android 优先 `geo:`，再尝试高德、百度、腾讯、Google Maps、Apple Maps web 和既有网页 fallback。

- `apps/mobile/ios/Runner/Info.plist`
  - 复核并保留 `NSPhotoLibraryUsageDescription`。
  - 增加地图 App scheme 查询白名单。

- `apps/mobile/android/app/src/main/AndroidManifest.xml`
  - 增加图片读取相关权限声明。
  - 增加地图 scheme queries。

### SSOT

- `docs/00_ssot/mobile_media_picker_chat_preview_map_minimal_closure_boundary_freeze_addendum.md`
- `docs/00_ssot/source_of_truth_map.md`
- `docs/00_ssot/mobile_media_picker_chat_preview_map_minimal_closure_execution_receipt.md`

### BFF / Server / Contracts / 云端

- BFF：未改。
- Server：未改。
- Contracts：未改。
- 云端：未部署，未写入，只做健康检查和真机云端直连运行参数尝试。

## 验证回执

### 静态检查

```text
flutter analyze lib/features/exhibition/presentation/exhibition_trade_pages.dart lib/features/exhibition/presentation/enterprise_hub_detail_relayout_sections.dart lib/features/exhibition/presentation/presentation_support/external_map_launcher.dart test/counterpart_conversation_chat_test.dart test/enterprise_hub_routes_test.dart
No issues found.
```

### 聚焦测试

```text
flutter test test/counterpart_conversation_chat_test.dart --plain-name "project communication image button uploads file asset and sends image payload"
All tests passed.
```

```text
flutter test test/enterprise_hub_routes_test.dart --plain-name "external map candidates keep app schemes before web fallback"
All tests passed.
```

### 隧道和云端健康

隧道监听：

```text
127.0.0.1:8080 LISTEN
```

BFF health：

```text
GET http://127.0.0.1:8080/health/bff/live
200 OK
{"status":"ok","service":"exhibition-bff","port":3000}
```

Server health：

```text
GET http://127.0.0.1:8080/health/server/live
200 OK
{"status":"ok","service":"exhibition-server","port":3001}
```

正式云端直连健康：

```text
GET https://47.108.180.198/health/bff/live
200 OK
GET https://47.108.180.198/health/server/live
200 OK
```

### 真机安装尝试

设备识别：

```text
王巍威的iPhone (mobile) - 00008130-000A0D313620001C - iOS 26.3.1
```

构建和安装启动尝试：

```text
flutter run -d 00008130-000A0D313620001C --debug --dart-define=APP_FORMAL_CLOUD_BFF_BASE_URL=https://47.108.180.198/api/app --dart-define=APP_BFF_BASE_URL=https://47.108.180.198/api/app --dart-define=APP_RUNTIME_ENTRY_MODE=cloud
Xcode build done.
Installing and launching...
The Dart VM Service was not discovered after 60 seconds.
```

安装状态：

```text
展览定制之家 com.zhanlandingzhijia.mobile 1.0.0 1 installed=true
```

进程观察：

```text
/private/var/containers/Bundle/Application/.../Runner.app/Runner
```

说明：真机本次运行使用云端直连参数，避免 iPhone 将 `127.0.0.1:8080` 解析为手机本机导致离线。调试服务未连接不等于安装失败，但阻塞 Codex 自动截图和点击验收。

### 广域回归

```text
flutter test test/app_api_client_test.dart test/profile_identity_contract_compat_test.dart test/profile_personal_minimal_edit_test.dart test/project_attachment_corridor_test.dart test/project_notification_preview_consumption_test.dart test/forum_published_attachment_access_test.dart test/enterprise_hub_routes_test.dart
Result: 118 tests executed, 106 passed, 12 failed.
```

失败归类：

- `profile_identity_contract_compat_test.dart`：旧用例仍使用 `127.0.0.1:3000` local_dev，被当前禁用规则阻断。
- `forum_published_attachment_access_test.dart`：forum 附件卡查找不到预期文件名。
- `project_attachment_corridor_test.dart`：项目附件区文本重复或预期附件名不可见。
- `profile_personal_minimal_edit_test.dart`：个人资料保存后测试找不到返回按钮。

这些失败不在本轮四个媒体体验闭环的实现路径内，暂不扩大修复范围。

## 验收结论

| 项目 | 结论 | 说明 |
| --- | --- | --- |
| 相册选择 | Pass with Risk | 代码路径和聚焦测试通过；真机相册弹窗需人工点验。 |
| 聊天图片回显 | Pass | 使用既有 preview access，聚焦测试覆盖成功回显与请求次数。 |
| App 内图片预览 | Pass with Risk | Flutter 预览能力已实现；真机缩放/关闭需人工点验。 |
| 地图 App 优先跳转 | Pass with Risk | 候选顺序测试通过；不同地图 App scheme 的实际安装态需真机点验。 |
| BFF / Server 边界 | Pass | 未改接口、未改云端、未新建本地假服务。 |
| 广域回归 | Pass with Risk | 本轮聚焦链路通过；既有广域失败另行排期。 |

## 下一轮唯一动作

在 iPhone 上人工点验四步并回传截图或现场确认：

1. 聊天图片按钮是否弹出相册。
2. 选图后是否完成发送。
3. 聊天气泡是否显示缩略图，点击是否 App 内放大，关闭是否回到聊天页。
4. 企业地图按钮是否优先打开系统地图或已安装地图 App，失败是否回到网页 fallback。

若任一真机点验失败，下一轮只修对应单点，不扩大到 IM 重构、地图 SDK 或 BFF/Server 改造。
