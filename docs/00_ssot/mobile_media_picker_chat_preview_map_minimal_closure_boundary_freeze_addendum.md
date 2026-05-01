---
owner: Codex Control
status: frozen
layer: L0 SSOT
date: 2026-05-02
depends_on:
  - docs/00_ssot/project_conversation_workbench_v1_truth_freeze_addendum.md
  - docs/01_contracts/project_conversation_workbench_v1_contract_addendum.md
  - docs/01_contracts/project_communication_notification_preview_v1_contracts_addendum.md
---

# 手机端图片选择、聊天回显与地图跳转最小闭环边界冻结单

## 总控结论

本轮冻结为 Flutter 端体验修复最小闭环：相册选择、聊天图片回显、App 内图片预览、地图 App 优先打开。当前只改 Flutter 与必要平台权限声明，不改 BFF、Server、contracts，不新增接口，不改云端运行态。

## 本轮只优化什么

1. 聊天图片入口：
   - `imageOnly=true` 的图片发送入口必须调用手机相册选择。
   - 文件入口继续保留系统文件选择器。
   - 取消选择、读取失败、格式不支持必须有可理解提示。

2. 聊天图片回显：
   - 对 `category=image` 或 `mimeType=image/*` 的聊天附件展示图片缩略图。
   - 缩略图只读取既有 preview access 返回的 `accessUrl`。
   - `accessUrl` 不可用时降级为原文件名附件卡，不伪造图片地址。

3. App 内图片预览：
   - 点击聊天图片后在 App 内预览。
   - 预览支持放大、拖动、关闭返回聊天。
   - 非图片文件继续使用既有预览/外部打开降级。

4. 地图跳转：
   - 地图入口优先尝试系统地图或已安装地图 App。
   - 全部失败后 fallback 到既有 `mapLinkUrl` 网页。
   - 不接地图 SDK，不做地图内嵌导航。

## 本轮不优化什么

- 不新增 BFF route。
- 不新增 Server route。
- 不改 OpenAPI / contracts。
- 不新增缩略图字段。
- 不把 OSS `objectKey` 暴露给 Flutter。
- 不伪造图片 URL。
- 不做完整 IM 重构、消息状态机重构、实时链路重做。
- 不做多图批量发送。
- 不做视频发送、图片编辑、裁剪、压缩策略重构。
- 不接入高德 / 百度 / 腾讯地图 SDK。
- 不做云端部署。

## 涉及页面 / 文件 / 路由

### Flutter 文件

- `apps/mobile/lib/features/exhibition/presentation/exhibition_trade_pages.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_chat_widgets.dart`
- `apps/mobile/lib/features/exhibition/presentation/presentation_support/project_attachment_support.dart`
- `apps/mobile/lib/features/exhibition/presentation/widgets/project_attachment_preview_widgets.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_relayout_sections.dart`
- `apps/mobile/ios/Runner/Info.plist`
- `apps/mobile/android/app/src/main/AndroidManifest.xml`

### 复用既有接口

- `POST /api/app/file/upload/init`
- Direct upload URL from existing upload directive
- `POST /api/app/file/upload/confirm`
- `POST /api/app/message/project-communication/messages`
- `GET /api/app/file/preview/access`

## 是否需要改 contracts

不需要。

理由：现有 `ProjectCommunicationAttachment` 已有 `fileAssetId / fileName / mimeType / size / category`，现有 `GET /api/app/file/preview/access` 已返回 `accessUrl / previewType / canPreview`，足够支撑最小图片回显与 App 内预览。

## 是否需要改 BFF

不需要。

BFF 只读联调现有 preview access，不新增字段整形，不新增 route，不改变错误映射。

## 是否需要改 Server

不需要。

Server 仍是 FileAsset、权限和 signed access 的真相 owner。本轮不改 FileAsset、Evidence、ProjectCommunicationMessage 或 preview access 业务规则。

## 是否需要云上联调

需要只读联调，不需要部署。

验收通过隧道访问：

```text
ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198
http://127.0.0.1:8080
```

只验证健康、登录后既有上传/预览接口可访问、真机展示闭环；不改云端。

## 风险与降级

- 若用户拒绝相册权限：提示用户到系统设置打开相册权限，不进入假成功。
- 若 HEIC / HEIF 选择后上传链路不接受：保留格式提示，不把格式改写成 JPEG 假真相。
- 若 preview access 返回失败：图片气泡降级为文件名附件卡，点击后提示当前附件暂不可预览。
- 若地图 App scheme 不可用：fallback 到既有网页链接。

## 阶段门禁

- Day 1 冻结单完成后，允许进入 Flutter 实现。
- 若实现过程中发现现有 preview access 不返回可用 `accessUrl`，停止扩大范围，只输出 BFF/Server 解锁建议。
- 未完成结果校验和真机回归前，不允许宣布 Go。
