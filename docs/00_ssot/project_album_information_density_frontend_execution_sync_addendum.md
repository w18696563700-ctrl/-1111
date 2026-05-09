---
owner: Codex 总控
status: frozen
purpose: Record the Flutter-only project album information-density refinement and local-save semantics under the already frozen four-entry project communication boundary.
layer: L0 SSOT
effective_local_date: 2026-05-05
depends_on:
  - docs/00_ssot/project_communication_four_entry_full_closure_truth_freeze_addendum.md
  - docs/01_contracts/project_communication_four_entry_full_closure_contracts_addendum.md
---

# 项目相册信息密度优化与本地保存语义同步 Addendum

## 0. 总裁决

本文件只同步 `项目相册` Flutter 展示层优化，不改变项目相册业务真值、接口路径、文件真值或云端运行边界。

当前最小闭环：

`项目沟通 -> 项目相册 -> 分类筛选 -> 预览 / 保存到本地 / 删除`

本轮裁决：

- `项目相册` 继续是项目证据池，不升级为履约相册、验收相册或争议举证系统。
- 相册照片真值仍为 Server `ProjectAlbumPhoto` + `FileAsset`。
- 图片预览与保存前置访问继续走受控 `file preview/access`。
- Flutter 不展示 `objectKey`、`FileAssetId`、MIME type、OSS 技术字段或原始文件名。
- `保存到本地` 只表示保存到 App 本地缓存后通过系统打开/分享面板另存；不等于直接写入系统相册胶卷。

## 1. 本轮做什么

### 1.1 首屏信息降噪

项目相册页展示规则调整为：

- 顶部保留 `项目相册` 标题。
- 照片数量以轻量文案展示：`共 N / 50 张`。
- `刷新相册` 从页面中部按钮移动到右上角图标。
- `上传图片` 保留为主动作。
- 分类 chip 继续展示分类名称和真实数量：
  - `合同照片 N`
  - `进度照片 N`
  - `最终呈现 N`
  - `项目瑕疵 N`
- 分类说明只做一行轻量提示，不再长期占用首屏。

### 1.2 照片卡片小回显

照片卡片只展示用户需要操作的信息：

- 左侧：图片类图标回显。
- 中间：`相册照片` 与加入相册时间。
- 右侧：`预览`、`保存到本地`、`删除` 三个图标动作。

照片卡片不得展示：

- 原始文件名。
- `FileAssetId`。
- MIME type。
- 重复分类。
- OSS `objectKey`。

### 1.3 保存到本地 V1

`保存到本地` 的 V1 语义为：

1. Flutter 复用已冻结的 `file preview/access` 获取受控 `accessUrl`。
2. Flutter 下载图片到 App 本地缓存目录。
3. Flutter 展示中文结果面板。
4. 用户可以选择：
   - `打开`
   - `分享/另存`

边界：

- 不新增 OpenAPI。
- 不新增 BFF 路由。
- 不新增 Server 路由。
- 不新增数据库字段。
- 不直接写入系统相册胶卷。
- 不新增系统相册权限。

若后续要做“直接保存到系统相册胶卷”，必须另开权限、依赖和平台隐私说明 gate。

## 2. 明确不做范围

本轮不做：

- 履约相册。
- 验收相册。
- 争议举证系统。
- 图片审核治理。
- 相册公开展示。
- 批量下载。
- 批量删除。
- 批量分类移动。
- 新增相册分类。
- 新增相册接口。
- BFF / Server / OpenAPI / generated types 变更。
- 云端部署、重启或写入 smoke。

## 3. 分层边界

| 层 | 本轮裁决 |
| --- | --- |
| SSOT | 仅补充本文件，承接四入口相册证据池边界。 |
| OpenAPI / contracts | 不变；继续使用已冻结的 project album paths 与 file preview/access。 |
| generated types | 不变。 |
| Server | 不变；继续拥有 `ProjectAlbumPhoto` 与 `FileAsset` 真值。 |
| BFF | 不变；继续转发相册和 file access。 |
| Flutter | 只做展示降噪、本地保存和交互语义收口。 |
| 云端 runtime | 不变；不得用本地截图声明云端已部署。 |

## 4. 验收口径

### 4.1 必须成立

- 相册页不再展示原始文件名、`FileAssetId`、MIME type。
- 分类信息只在顶部分类 chip 表达，不在每张照片卡重复。
- 每张照片卡必须有 `预览`、`保存到本地`、`删除` 三个动作。
- `保存到本地` 必须走真实 preview/access，不得伪造 accessUrl。
- 无 `threadId` 或 accessUrl 不可用时必须中文失败，不得暴露英文 route/param 异常。
- 删除仍走现有 Server 相册删除路径，不得前端假删除。

### 4.2 本轮已取得的本地证据

- scoped Flutter analyze 通过。
- `counterpart_conversation_chat_test.dart` 相册定向用例通过。
- `counterpart_conversation_chat_test.dart` 全文件通过。

### 4.3 当前未完成证据

Computer Use 视觉截图未作为通过证据登记。

原因：

- 本地 `flutter run -d macos` 出现 native assets hook `Invalid SDK hash`。
- 前台 `mobile` 窗口仍显示旧相册 UI。
- 因此不得把旧页面截图写成新 UI 验收通过。

后续如需视觉验收，必须先修复本地 Flutter 调试同步问题或使用可证明已加载本轮代码的环境重新截图。

## 5. 后续扩展位

| 扩展位 | 接入方式 | 当前状态 |
| --- | --- | --- |
| 直接写入系统相册胶卷 | 另开权限、依赖、隐私说明 gate | 暂不开通 |
| 批量导出项目证据包 | 读取 `ProjectAlbumPhoto + FileAsset` 后生成导出包 | 暂不开通 |
| 履约阶段相册 | 从项目相册证据池拆出履约阶段视图 | 暂不开通 |
| 验收/争议举证 | 另建状态机，复用 FileAsset | 暂不开通 |

## 6. 四类判断

| 判断 | 裁决 |
| --- | --- |
| 哪个更稳 | 只改 Flutter 展示层，沿用 Server/BFF/Contracts 现有相册和 file access 真值。 |
| 哪个更省成本 | 仅隐藏技术字段和移动刷新按钮，但不做保存到本地；成本最低但不完整。 |
| 哪个最适合当前阶段 | 展示降噪 + 三动作收口 + 本地缓存/分享另存，保持 P0 相册证据池边界。 |
| 哪个风险最大 | 为相册 UI 优化顺手新增后端接口、图库权限或履约相册状态机。 |

## 7. Commit 边界建议

本文件应与 Flutter 相册 UI 优化作为同一主题或相邻主题入库。

建议 commit 范围仅包含：

- `docs/00_ssot/project_album_information_density_frontend_execution_sync_addendum.md`
- `docs/00_ssot/source_of_truth_map.md` 中本文件注册 hunk
- `apps/mobile/lib/features/exhibition/presentation/exhibition_trade_pages.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/project_album_section.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/project_album_support.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/project_album_save_support.dart`
- `apps/mobile/test/counterpart_conversation_chat_test.dart`

不得混入当前工作树中的企业/工厂/供应商视觉改动或其文书。
