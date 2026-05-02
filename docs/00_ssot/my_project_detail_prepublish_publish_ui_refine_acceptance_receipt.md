---
owner: Codex 总控
status: conditional_pass
phase_day: 第 7 天
layer: L0 SSOT
purpose: >
  Record the implementation, verification, runtime health, and remaining
  acceptance gaps for the Flutter-only UI refinement of My Project Detail
  prepublish material-completion and publish-confirmation page.
---

# 《预发布补资料并发布页 UI 精修验收回执》

## 1. 总裁决

本轮裁决：`Conditional Pass`。

代码和聚焦测试已通过；云端 BFF / Server live health 已通过。
但本项目当前未配置 Flutter Web，Browser Use 页面验证无法执行；本轮也未取得真机截图文件，因此不得写成 `Go` 或 `全量验收完成`。

## 2. 本轮目标

对 `我的项目详情（预发布补资料并发布页）` 做 Flutter-only UI 精修：

1. 页面更短，状态先行。
2. 项目摘要只保留关键字段，其余折叠。
3. 发布进度 stepper 清晰。
4. 诚意金规则默认折叠，并保留内测说明但不改支付真相。
5. 当前阶段动作主 / 次 / 危险分层。
6. 五类报价依据资料都支持 `照片 / 文件` 二选一。
7. 附件回显简化，技术字段默认折叠。
8. 公共资源下载区简化，并修复移动端 URL 打开方式。
9. 底部 CTA 不被 bottom nav 遮挡。

## 3. 范围裁决

| 范围 | 本轮是否涉及 | 裁决 |
|---|---:|---|
| Flutter 前端 | 是 | 唯一实现层 |
| BFF | 否 | 只读健康检查 |
| Server | 否 | 只读健康检查 |
| contracts / OpenAPI | 否 | 未修改 |
| 数据库 / migration | 否 | 未修改 |
| 云端配置 / Nginx / systemd | 否 | 未修改 |
| SSOT | 是 | 冻结单、验收回执、索引 |
| 云端联调 | 只读 | health 与未登录 shell/context |

## 4. 实际产出物

### 4.1 文书

- `docs/00_ssot/my_project_detail_prepublish_publish_ui_refine_day1_freeze_addendum.md`
- `docs/00_ssot/my_project_detail_prepublish_publish_ui_refine_acceptance_receipt.md`
- `docs/00_ssot/source_of_truth_map.md`

### 4.2 Flutter 实现文件

- `apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/presentation_support/project_attachment_support.dart`
- `apps/mobile/lib/features/exhibition/presentation/presentation_support/project_public_resource_support.dart`
- `apps/mobile/lib/features/exhibition/presentation/presentation_support/project_publish_progress_support.dart`
- `apps/mobile/lib/features/exhibition/presentation/widgets/exhibition_page_frames.dart`
- `apps/mobile/lib/features/exhibition/presentation/widgets/project_attachment_panels.dart`
- `apps/mobile/lib/features/exhibition/presentation/widgets/project_edit_surface_widgets.dart`
- `apps/mobile/lib/features/exhibition/presentation/widgets/project_public_resource_widgets.dart`
- `apps/mobile/lib/shell/navigation/app_router.dart`

### 4.3 测试文件

- `apps/mobile/test/my_project_private_carry_test.dart`
- `apps/mobile/test/project_attachment_corridor_test.dart`
- `apps/mobile/test/project_attachment_prepublish_and_bid_materials_test.dart`

## 5. 行为验收

| 验收项 | 结果 | 说明 |
|---|---:|---|
| 顶部标题 | Pass | `我的项目详情（预发布补资料并发布页）` |
| 项目摘要 | Pass | 默认只展示项目名称、编号、当前阶段；其他字段折叠到 `展开全部信息` |
| 真实预览项目入口 | Pass | 仅在存在 `projectId` 时复用真实项目详情路由 |
| 发布进度 | Pass | 使用真实 state + 诚意金快照映射 stepper |
| 诚意金卡片 | Pass | 状态、金额、订单状态保留；长规则默认折叠；内测说明不改支付状态 |
| 阶段动作 | Pass | 主操作、次操作、危险操作分层；作废删除非金色实心 |
| 五类资料来源选择 | Pass | 效果图、尺寸图/施工图、材质图/材料样板、设备物料清单、服务清单均可选照片或文件 |
| 上传三步流 | Pass | 未改 `init -> direct upload -> confirm` |
| 附件回显 | Pass | 图片/文件卡片轻量展示；文件名、FileAsset、mime、可见范围、排序号、长时间折叠 |
| 图片预览 | Pass | 图片仍走 App 内预览；失败降级 |
| 公共资源 | Pass | 合同模板、流程图与说明、公共资料三类保留；技术字段折叠 |
| 移动端下载 | Pass | `url_launcher` externalApplication 优先打开 accessUrl |
| bottom nav 遮挡 | Pass by code/test | `_LoadPageFrame.bottomPinnedBuilder` 预留底部 padding + SafeArea |

## 6. 验证回执

### 6.1 通过项

- `flutter analyze lib/features/exhibition/presentation/exhibition_trade_pages.dart lib/shell/navigation/app_router.dart test/my_project_private_carry_test.dart test/project_attachment_corridor_test.dart test/project_attachment_prepublish_and_bid_materials_test.dart`
  - 结果：`No issues found`
- `flutter test test/my_project_private_carry_test.dart`
  - 结果：`All tests passed`
- `flutter test test/project_attachment_corridor_test.dart`
  - 结果：`All tests passed`
- `flutter test test/project_attachment_prepublish_and_bid_materials_test.dart`
  - 结果：`All tests passed`

### 6.2 全量 analyze

- `flutter analyze`
  - 结果：`40 issues found`
  - 裁决：`非本轮阻塞`
  - 原因：失败项分布在既有 `bin/`、`scripts/`、交易 IM、bid submit、profile test support 等文件；本轮触及文件定向 analyze 已通过。

### 6.3 云端只读健康

- `GET http://127.0.0.1:8080/health/bff/live`
  - 结果：`200`
  - body：`{"status":"ok","service":"exhibition-bff","port":3000,...}`
- `GET http://127.0.0.1:8080/health/server/live`
  - 结果：`200`
  - body：`{"status":"ok","service":"exhibition-server","port":3001,...}`
- `GET http://127.0.0.1:8080/api/app/shell/context`
  - 结果：`401 AUTH_SESSION_INVALID`
  - 裁决：未携带登录态时符合门禁，不代表 BFF/Server health 失败。

### 6.4 Browser Use / 截图

- `flutter build web ...`
  - 结果：`This project is not configured for the web.`
  - 裁决：Browser Use 页面验证不可执行。
- `flutter devices`
  - 结果：识别到 `王巍威的iPhone (ios)`、`macOS`、`Chrome`。
  - 裁决：设备可见，但本轮没有取得可靠真机截图文件。
- 页面截图路径：`未产出`
- 窄屏截图路径：`未产出`

## 7. Dirty Files 裁决

本轮只声明以下文件为本轮产出：

- 文书与索引：见 `4.1`
- Flutter 与测试：见 `4.2`、`4.3`

工作区仍存在其他非本轮 dirty 文件，例如 `bid_submit_page.dart`、`project_create_page.dart`、`project_detail_page.dart`、`trading_im_bid_thread_page.dart`、`bid_award_bridge_test.dart` 以及若干 SSOT addendum。它们不在本轮验收声明内，本轮未回退、未合并裁决。

## 8. 风险清单

### 已解决风险

- 五类资料只有效果图支持相册的问题已修正。
- 效果图/附件主卡片铺长文件名和技术字段的问题已收敛。
- 公共资源下载在移动端无法打开的问题已改为 `url_launcher` 外部应用优先。
- 底部 CTA 遮挡 bottom nav 的代码风险已通过 SafeArea 和底部 padding 处理。

### 未解决但不阻塞代码合并的风险

- 回读模型没有文件大小字段，因此主卡片没有伪造展示文件大小。
- 图片缩略图依赖 `file/access` preview access；失败时会降级成图标卡片。
- Browser Use 无法执行，因为 Flutter Web 未配置。
- 真机截图未归档。

### 阻塞 `Go` 的项

- 缺真实页面截图 / 窄屏截图。
- 缺真机截图回执。
- 全量 `flutter analyze` 仍被非本轮既有问题阻断。

## 9. 下一轮唯一动作

下一轮只做 `真机补验与截图归档`：

1. 使用已连接 iPhone 安装当前 Flutter 包。
2. 登录测试账号。
3. 打开预发布项目详情。
4. 截图首屏、资料区、公共资源区、底部 CTA。
5. 验证五类资料 `照片 / 文件` 二选一。
6. 验证公共资源下载。
7. 将截图路径补入本回执或新增真机补验回执。

未补截图前，不得把本轮状态从 `Conditional Pass` 升级为 `Go`。
