---
owner: Codex Control
status: frozen
layer: L0 SSOT
date: 2026-05-02
depends_on:
  - docs/00_ssot/mobile_media_picker_chat_preview_map_minimal_closure_boundary_freeze_addendum.md
  - docs/01_contracts/project_conversation_workbench_v1_contract_addendum.md
  - docs/01_contracts/project_communication_notification_preview_v1_contracts_addendum.md
---

# 手机端照片入口与聊天图片发送确认最小闭环边界冻结单

## 总控结论

本轮冻结为 Flutter-only 体验修复：聊天图片发送前确认、聊天图片回显隐藏文件名、照片入口相册化、混合资料入口二选一。当前只改 Flutter 与必要测试/验收文书，不改 BFF、Server、contracts，不新增接口，不改云端运行态。

## 本轮只做什么

1. 聊天图片发送前确认：
   - 聊天图片按钮继续走手机相册。
   - 用户选择图片后先展示本地预览确认。
   - 用户点击“发送”后才进入既有上传三步流和消息发送。
   - 用户取消时不上传、不产生消息。

2. 聊天图片回显隐藏文件名：
   - 图片消息成功态只展示缩略图与必要状态，不展示真实 `fileName`。
   - 图片加载态只展示“正在加载图片”，不展示真实 `fileName`。
   - 图片失败态展示“图片暂不可预览”，不展示真实 `fileName`。
   - 非图片附件继续展示文件名。
   - 不删除、不改写 payload 中的 `fileName`。

3. 项目发布效果图混合入口：
   - “效果图”仍属于全格式报价依据资料，可上传图片、PDF、图纸、文档等文件。
   - 点击“选择效果图”后先弹来源选择：从相册选择照片 / 从文件选择资料。
   - 选择照片后仍按 `effect_image` 类型进入既有上传和绑定。
   - 选择文件后继续使用系统文件选择器和既有全格式校验。

4. 明确照片入口相册化：
   - 项目相册“上传图片”走相册。
   - 企业展示 Logo、企业展示图片、案例图片走相册，并保留既有编辑确认。
   - 论坛图片走相册。
   - 头像入口已走相册，本轮只回归。

## 本轮不做什么

- 不改 BFF。
- 不改 Server。
- 不改 OpenAPI / contracts。
- 不新增上传接口、预览接口、缩略图字段。
- 不改上传三步流：`init -> direct upload -> confirm`。
- 不改 `FileAsset` / `Evidence` / project communication message 真相。
- 不把 `objectKey`、OSS 私有地址或本地假 URL 暴露给 Flutter。
- 不把“效果图”限制为只支持图片。
- 不做多图批量、视频发送、图片压缩、转码、裁剪、标注。
- 不做完整 IM 重构、消息状态机重构或上传队列重构。
- 不做云端部署。

## 入口分类冻结

| 入口 | 当前分类 | 本轮行为 |
| --- | --- | --- |
| 聊天图片 | 纯图片 | 相册选择 -> 本地预览确认 -> 发送 |
| 聊天文件 | 纯文件 | 继续文件选择器 |
| 项目发布效果图 | 图片/文件混合 | 弹“照片 / 文件”二选一 |
| 项目发布尺寸图 / 施工图 | 文件资料 | 继续文件选择器 |
| 项目发布材质图 / 材料样板 | 文件资料 | 继续文件选择器 |
| 项目发布设备物料清单 | 文件资料 | 继续文件选择器 |
| 项目发布服务清单 | 文件资料 | 继续文件选择器 |
| 项目相册上传图片 | 纯图片 | 相册选择 |
| 企业展示 Logo | 纯图片 | 相册选择，保留编辑确认 |
| 企业展示图片 | 纯图片 | 相册选择，保留编辑确认 |
| 企业案例图片 | 纯图片 | 相册选择，保留编辑确认 |
| 论坛图片 | 纯图片 | 相册选择 |
| 论坛视频 | 文件 / 视频 | 继续文件选择器 |
| 论坛文件 | 纯文件 | 继续文件选择器 |
| 头像 | 纯图片 | 已为相册入口，仅回归 |

## 涉及页面 / 文件 / 模块

### Flutter 文件

- `apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_chat_widgets.dart`
- `apps/mobile/lib/features/exhibition/presentation/widgets/project_attachment_widgets.dart`
- `apps/mobile/lib/features/exhibition/presentation/presentation_support/project_attachment_support.dart`
- `apps/mobile/lib/features/exhibition/presentation/widgets/project_attachment_panels.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/project_album_section.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_media_actions.dart`
- `apps/mobile/lib/features/exhibition/presentation/forum/forum_media_upload_support.dart`
- `apps/mobile/lib/features/profile/presentation/profile_avatar_picker.dart`

### 测试文件

- `apps/mobile/test/counterpart_conversation_chat_test.dart`
- `apps/mobile/test/project_attachment_corridor_test.dart`
- 需要时补充企业展示 / 论坛图片入口聚焦测试。

## 是否需要改 contracts

不需要。

理由：本轮只改变 Flutter 选择来源、发送确认和展示方式，不改变 message payload、上传 payload、附件类型或 preview access 响应。

## 是否需要改 BFF

不需要。

BFF 继续提供既有 app-facing upload、message send、preview access。Flutter 不要求新增字段整形。

## 是否需要改 Server

不需要。

Server 继续是 FileAsset、权限、project communication message、preview access 的唯一业务真相 owner。

## 是否需要云上联调

需要只读联调，不需要部署。

验收通过隧道访问：

```text
ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198
http://127.0.0.1:8080
```

只验证健康、登录后既有上传/预览接口可访问、真机体验闭环；不改云端。

## 风险与降级

- 若用户拒绝相册权限：展示受控失败提示，不进入假成功。
- 若相册返回 HEIC / HEIF 且预览失败：上传真相不伪造，回显按现有失败降级。
- 若效果图来源选择取消：不改变待上传列表。
- 若图片发送确认取消：不上传、不产生消息。
- 若 preview access 失败：图片气泡显示不可预览，不暴露真实文件名。

## 阶段门禁

- Day 1 冻结单完成后，允许进入 Flutter 实现。
- 任一改动如需要 BFF/Server/contracts，必须停止并输出解锁建议。
- 未完成聚焦测试与真机/用户确认前，不宣布 Go。
