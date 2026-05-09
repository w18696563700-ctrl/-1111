---
owner: Codex 总控
status: frozen
reopening_type: flutter_only_visual_reopening
layer: L0 SSOT
scope:
  - forum post detail
  - published image attachments
  - Flutter presentation only
effective_local_date: 2026-05-06
purpose: >
  Freeze a narrow reopening after the Forum module closure: published image
  attachments on the post detail page may be shown directly as a real image
  grid after the body text and before the interaction bar, while continuing to
  use shared file/access and without reopening Forum product scope.
---

# 论坛帖子详情图片宫格直出 Flutter-only Reopening Addendum

## 1. 总裁决

`Go` for a narrow Flutter-only reopening.

本轮只允许修复一个展示缺陷：

- 当前帖子详情的图片附件必须能在正文后直接以图片宫格展示。
- 点击图片继续复用现有 App 内图片预览弹窗。
- 图片访问继续通过 shared `file/access` 获取短期 `accessUrl`。

本轮不是继续开发论坛，不解锁论坛新功能，不改变论坛业务真相。

## 2. 当前真相

当前字段和链路保持不变：

| 项 | 冻结结论 |
| --- | --- |
| 图片来源 | `ForumAttachmentRef(fileAssetId, fileName, mimeType)` |
| 授权访问 | `GET /api/app/file/access?fileAssetId=...&mode=preview` |
| 预览真相 | `ForumFileAccessView.accessUrl` |
| 文件真相 | shared `FileAsset` |
| 论坛真相 | post detail 只持有附件引用关系 |

Flutter 不得拼 OSS 地址，不得读取 `objectKey`，不得伪造图片 URL。

## 3. 本轮展示规则

图片附件在帖子详情中按以下规则展示：

| 图片数量 | 展示方式 |
| --- | --- |
| 0 张 | 不展示图片区 |
| 1 张 | 单图大卡，宽度占满内容区 |
| 2 张 | 双列自适配 |
| 3 张 | 一排三张 |
| 4-9 张 | 九宫格，最多三列 |
| 超过 9 张 | 只展示前 9 张，第 9 张叠加 `+N` |

展示位置锁定为：

`正文内容 -> 图片宫格 -> 非图片附件列表 -> 点赞/评论/收藏/举报互动条`

图片宫格必须只展示真实图片附件：

- `mimeType` 以 `image/` 开头才进入图片宫格。
- 视频、PDF、Office、普通文件继续走现有附件列表。
- 图片加载中显示受控占位。
- 图片读取失败显示可点击重试，不显示 raw error。

## 4. 点击预览规则

点击任意图片时：

1. 使用该图片的 `fileAssetId` 请求 `GET /api/app/file/access`。
2. `mode` 必须为 `preview`。
3. 成功后复用现有 App 内图片预览弹窗。
4. 失败时显示受控中文提示。

不得新增第二套图片预览系统，不得绕过 shared file/access。

## 5. 与既有附件冻结单的关系

本文件只在一个点上覆盖既有前端展示口径：

- 旧口径：post detail 只展示 `attachmentRefs` 附件列表并点击预览。
- 新口径：图片类 `attachmentRefs` 可在正文后直出宫格，仍通过 shared file/access 获取真实 `accessUrl`。

以下既有边界继续有效：

- No rich-text editor.
- No inline attachment anchors.
- No second attachment system.
- No upload-chain rewrite.
- No forum-owned file truth.
- No BFF / Server / OpenAPI / database change.

这里的“图片直出”不是富文本正文内插图，不允许把图片嵌入正文编辑器或改变正文数据结构。

## 6. 允许文件范围

本轮允许改动：

- `apps/mobile/lib/features/exhibition/presentation/forum/forum_detail_media_widgets.dart`
- `apps/mobile/lib/features/exhibition/presentation/forum/forum_detail_pages.dart`
- `apps/mobile/test/forum_published_attachment_access_test.dart`

本轮允许文书登记：

- 本文件。
- `docs/00_ssot/source_of_truth_map.md`。

## 7. 禁止事项

本轮不得做：

- 新增第二套图片宫格组件。
- 修改 BFF。
- 修改 Server。
- 修改 OpenAPI。
- 修改 generated contracts。
- 修改数据库或迁移。
- 修改云端 runtime、重启进程或部署。
- 新增接口字段。
- 新增假图片、假封面、假浏览量、假点赞数、假回复数。
- 改发帖上传链。
- 改帖子列表卡片、首页推荐频道、作者主页、我的论坛资产页。
- 引入富文本编辑器或正文内锚点。
- 扩展视频/PDF/Office 内嵌预览。

## 8. 验收标准

本轮完成后必须满足：

1. 2 张图片能显示为双列图片区。
2. 3 张图片能一排显示。
3. 4-9 张图片能按九宫格显示。
4. 超过 9 张时第 9 张显示 `+N`。
5. 点击图片仍走 `file/access` 并弹出 App 内图片预览。
6. 图片加载失败可重试。
7. 非图片附件仍在附件列表里可预览或下载。
8. 没有图片时页面不出现图片区占位。
9. `flutter analyze` 定向通过。
10. 相关 `flutter test` 通过。
11. diff 不包含 BFF、Server、OpenAPI、数据库或云端脚本。

## 9. 四类判断

| 判断项 | 结论 |
| --- | --- |
| 哪个更稳 | 只做 Flutter post-detail image grid，复用现有 file/access |
| 哪个更省成本 | 不改接口、不改服务端、不做富文本，只拆分图片与非图片附件 |
| 哪个更适合当前阶段 | 论坛已收口后的小型展示缺陷 reopening |
| 哪个风险最大 | 借图片直出继续扩论坛媒体中心、列表封面、推荐图、富文本和视频内嵌 |

## 10. 进入实现门禁

允许进入实现的条件：

- 本文件已冻结并登记到 `source_of_truth_map.md`。
- 实现 diff 只限 Flutter 展示层和定向测试。
- 不需要 BFF、Server、OpenAPI、数据库、云端联调。

未满足以上条件时，本轮实现 `No-Go`。
