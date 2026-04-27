---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Day5.1 bounded Flutter patch for owner-private project attachment
  image preview rendering after UI/BFF/DB/OSS evidence showed only the macOS
  Image.network rendering carrier remained red.
layer: L0 SSOT
freeze_date_local: 2026-04-27
inputs_canonical:
  - docs/00_ssot/project_attachment_day5_e2e_acceptance_table_addendum.md
  - docs/00_ssot/project_attachment_day6_observation_and_closure_receipt_addendum.md
  - docs/04_frontend/project_attachment_corridor_runtime_alignment_frontend_truth_note.md
  - apps/mobile/lib/features/exhibition/presentation/widgets/project_attachment_widgets.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/project_attachment_preview_widgets.dart
  - apps/mobile/lib/features/exhibition/presentation/presentation_support/project_attachment_support.dart
---

# 《Day5.1 Flutter 图片预览渲染补丁冻结单》

## 1. 当前最小闭环

Day5.1 只修 owner-private 项目详情文书区中正式效果图的图片预览渲染。

冻结语义：

1. Flutter 仍通过 `GET /api/app/file/access` 获取 `accessUrl`。
2. `accessUrl` 仍由 Server 签名，BFF 只转发并做轻 shape。
3. Flutter 不拼 OSS URL，不读取或外露 `objectKey`。
4. 图片预览由 Flutter 受控读取 `accessUrl` bytes，再用 `Image.memory` 渲染。
5. bytes 读取失败时显示中文错误，并保留系统外部打开兜底。

## 2. 需要保留但暂不开通

本轮不改：

1. 上传链：`init -> direct upload -> confirm -> bind`。
2. 附件列表 contract：`projectId + attachments[]`。
3. BFF file/access 转发逻辑。
4. Server file/access 权限、签名和 owner 校验逻辑。
5. DB schema、OSS key 规则、项目状态机。

## 3. 后续扩展位

后续如需增强，可以单独冻结：

1. 图片预览缓存。
2. 大图分片或缩略图。
3. 专用图片解码错误码。
4. 预览失败后的统一 viewer fallback。

## 4. 阶段判断

当前更稳：

- 只改 Flutter 图片承载，不回滚 Server/BFF，不重做附件链路。

当前更省成本：

- 复用既有 `file/access` 和 signed OSS URL，只把 `Image.network` 换成受控 bytes 读取后
  `Image.memory` 渲染。

当前阶段最适合：

- Day5 阻断项只有 `image_pixels_rendered=FAIL`，因此本轮只补像素渲染，不扩大到上传、
  列表、签名或权限体系。

风险更大：

- 让 BFF 参与签名、Flutter 拼 OSS URL、回滚已通过的 Server-only release，或重做上传体系。
