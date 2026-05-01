---
owner: Codex Control
status: pass_with_risk
layer: L0 SSOT
date: 2026-05-02
depends_on:
  - docs/00_ssot/mobile_photo_entry_and_chat_send_confirm_minimal_closure_boundary_freeze_addendum.md
---

# 手机端照片入口与聊天图片发送确认最小闭环执行回执

## 总控结论

本轮 Flutter-only 媒体入口治理已完成实现与聚焦验证，结论为 `Pass with Risk`。

通过项：

- 聊天图片选择后先展示本地预览确认，点击“发送图片”后才进入上传和消息发送。
- 聊天图片气泡成功态不再展示图片文件名。
- 聊天图片加载态不再展示图片文件名。
- 聊天图片失败态展示“图片暂不可预览”，不暴露真实文件名。
- 非图片附件仍保留原文件名展示。
- 项目发布“效果图”入口新增“从相册选择照片 / 从文件选择资料”来源选择；文件路径继续保留 PDF、图纸、文档等全格式能力。
- 项目相册上传图片改为相册入口。
- 企业展示 Logo / 展示图片 / 案例图片改为相册入口，并保留后续编辑确认。
- 论坛图片改为相册入口；论坛视频和论坛文件继续使用文件选择器。
- 未改 BFF、Server、contracts、OpenAPI，未部署云端。

保留风险：

- iPhone USB 设备可识别，debug build 已完成，安装/启动尝试已完成，但 Dart VM Service 仍未在 60 秒内连接，Codex 无法自动完成真机截图和点击验收。
- 真机最终体验需要用户人工点验确认；若用户确认通过，可视为本轮 Go，否则只修失败单点。

## 本轮实际改动

### Flutter

- `apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_page.dart`
  - 在图片选择后增加发送前预览确认。
  - 取消确认时不上传、不发送。
  - 确认后沿用既有上传三步流和消息发送。

- `apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_chat_widgets.dart`
  - 图片成功气泡隐藏 `fileName`。
  - 图片加载态隐藏 `fileName`。
  - 图片失败态不展示真实文件名。
  - 非图片附件继续展示文件名和大小。

- `apps/mobile/lib/features/exhibition/presentation/presentation_support/project_attachment_support.dart`
  - 增加项目附件来源选择模型。
  - 效果图支持“照片 / 文件”二选一。
  - 保持 `ProjectAttachmentDebugOverrides` 对测试兼容。

- `apps/mobile/lib/features/exhibition/presentation/widgets/project_attachment_widgets.dart`
  - 项目附件选择前按资料类型判断是否需要来源选择。
  - 效果图照片路径走相册，文件路径走文件选择器。

- `apps/mobile/lib/features/exhibition/presentation/pages/project_album_section.dart`
  - 项目相册上传图片改为相册入口。

- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_media_actions.dart`
  - 企业展示 Logo、展示图片、案例图片改为相册入口。
  - 保留既有图片编辑确认页。

- `apps/mobile/lib/features/exhibition/presentation/forum/forum_pages.dart`
- `apps/mobile/lib/features/exhibition/presentation/forum/forum_media_upload_support.dart`
  - 论坛图片入口改为相册。
  - 论坛视频 / 文件入口继续走文件选择器。

### SSOT

- `docs/00_ssot/mobile_photo_entry_and_chat_send_confirm_minimal_closure_boundary_freeze_addendum.md`
- `docs/00_ssot/source_of_truth_map.md`
- `docs/00_ssot/mobile_photo_entry_and_chat_send_confirm_minimal_closure_execution_receipt.md`

### BFF / Server / Contracts / 云端

- BFF：未改。
- Server：未改。
- Contracts / OpenAPI：未改。
- 云端：未部署，未写入，只做健康检查和真机云端直连运行参数尝试。

## 验证回执

### 静态检查

```text
flutter analyze lib/features/exhibition/presentation/exhibition_trade_pages.dart lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart lib/features/exhibition/presentation/forum/forum_pages.dart test/counterpart_conversation_chat_test.dart
No issues found.
```

### 聚焦测试

```text
flutter test test/counterpart_conversation_chat_test.dart --plain-name "project communication image button uploads file asset and sends image payload"
All tests passed.
```

```text
flutter test test/project_attachment_corridor_test.dart --plain-name "selected attachments can continue add and batch upload"
All tests passed.
```

```text
flutter test test/project_attachment_corridor_test.dart --plain-name "project attachment accepts full-format zip for service list"
All tests passed.
```

```text
flutter test test/enterprise_hub_routes_test.dart --plain-name "external map candidates keep app schemes before web fallback"
All tests passed.
```

### 边界检查

```text
git diff --check
pass
```

本轮未修改 `apps/bff`、`apps/server`、`docs/01_contracts`、`packages/contracts`。

说明：当前仓库已有大量非本轮 dirty files，不能据此判断为本轮改动；本回执只对本轮文件负责。

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

说明：真机本次运行使用云端直连参数，避免 iPhone 将 `127.0.0.1:8080` 解析为手机本机导致离线。调试服务未连接阻塞 Codex 自动截图和点击验收。

## 验收结论

| 项目 | 结论 | 说明 |
| --- | --- | --- |
| 聊天图片发送前确认 | Pass with Risk | 自动化通过；真机需用户点验。 |
| 聊天图片隐藏文件名 | Pass with Risk | 自动化覆盖成功态；真机需用户确认。 |
| 非图片附件保留文件名 | Pass | UI 仅对 image 分支隐藏文件名。 |
| 项目发布效果图二选一 | Pass with Risk | 代码已实现；真机需用户确认。 |
| 项目发布文件能力 | Pass | 服务清单 zip 测试通过，效果图文件路径保留。 |
| 项目相册相册入口 | Pass with Risk | 代码已切换；真机需用户确认。 |
| 企业展示图片相册入口 | Pass with Risk | 代码已切换并保留编辑确认；真机需用户确认。 |
| 论坛图片相册入口 | Pass with Risk | 代码已切换；真机需用户确认。 |
| BFF / Server / contracts 边界 | Pass | 未改。 |

## 下一轮唯一动作

请在 iPhone 上人工点验以下路径：

1. 聊天图片：选图后是否先出现“发送这张图片？”确认面板。
2. 聊天图片：点取消是否不发送，点发送是否发送成功。
3. 聊天图片：回显气泡是否只显示缩略图，不显示图片文件名。
4. 聊天文件：PDF / 文件是否仍显示文件名。
5. 我的项目发布效果图：是否先弹“从相册选择照片 / 从文件选择资料”。
6. 效果图照片路径：是否直接打开相册。
7. 效果图文件路径：是否仍可选择 PDF / 图纸 / 文档。
8. 项目相册、企业展示图片、论坛图片：是否直接打开相册。

如任一项失败，下一轮只修失败单点，不扩大到 BFF/Server/contracts 或上传体系重构。
