# 论坛媒体呈现施工清单

状态：前端展示层冻结稿

范围：论坛发帖页、帖子详情页、已发布附件查看链路。

## 1. 当前最小闭环

- 发帖页继续使用现有附件选择能力：图片来自 `image_picker`，视频和文件来自 `file_selector`。
- 上传链路保持不变：`upload/init -> direct upload -> upload/confirm -> draft/save attachmentFileAssetIds -> publish`。
- 帖子详情继续只消费现有 `attachmentRefs(fileAssetId, fileName, mimeType)`。
- 图片在正文输入框底部以真实本地 bytes 呈现，发布后在正文底部按真实 `attachmentRefs` 呈现。
- 图片点击走 `file/access(mode=preview)` 后在 App 内用 `InteractiveViewer + Image.network` 预览。
- 视频、PDF、Word、Excel、PPT、普通文件点击后先进入 App 内承接面板，再调用设备能力打开；失败时提供复制链接兜底。

## 2. 字段来源

- 发帖本地态：`_ForumComposerMediaItem.fileName`、`mimeType`、`bytes`、`stage`、`fileAssetId`。
- 草稿保存：`ForumConsumerLayer.saveDraft(... attachmentFileAssetIds)`。
- 发布详情：`ForumPostDetailView.attachmentRefs`。
- 附件访问：`ForumConsumerLayer.requestFileAccess(fileAssetId, mode)` 返回 `ForumFileAccessView.accessUrl`。

## 3. 类型能力

- 图片：App 内原生预览，可缩放、可关闭。
- 视频：当前不内置播放器；App 内承接后调用设备播放器。
- PDF：当前不内置 PDF viewer；App 内承接后调用设备能力打开。
- Office 文档：当前不内置 Office viewer；App 内承接后调用设备能力打开。
- 文本文件：发帖阶段可在本地弹窗展示文本内容；发布后按附件承接链处理。

## 4. 本轮不做

- 不改 BFF、Server、OpenAPI、数据库。
- 不新增接口字段。
- 不新增假帖子、假图片、假附件、假缩略图。
- 不引入 `webview_flutter`、`video_player`、PDF viewer 或 Office viewer 依赖。
- 不把论坛正文升级为富文本编辑器。
- 不把图片插入正文任意位置；本轮固定为正文底部图片区。

## 5. 后续扩展位

- 如果后续需要全格式 App 内预览，可单独冻结 viewer 依赖和文件缓存策略。
- 如果后续 BFF/Server 返回缩略图 URL，可把详情图片区从点击加载升级为首屏直接缩略图。
- 如果后续要做富文本正文，需要新增合同字段表达正文 block，不应复用纯文本 `content` 强行拼接。

## 6. 本轮验收口径

- 发帖页：图片选择后出现在正文输入框底部；非图片仍在附件区。
- 详情页：正文之后、互动条之前出现图片或附件；没有媒体时不占位。
- 点击图片：App 内预览。
- 点击附件：App 内承接面板，主视觉不暴露复杂 accessUrl。
- 失败态：中文受控提示，不暴露上游英文。
