# 公共资料下载闭环与预发布按钮治理验收回执

状态：Go

## 1. 总裁决

本轮 Flutter 最小闭环已完成：

- 公共资料下载改为先通过 `file/access` 获取授权，再下载到 App 本地。
- 下载完成后提供“打开”和“保存 / 分享”系统动作。
- 公共资料三类入口保留并显示数量。
- 下载失败态改为“资料文件暂不可下载”。
- 预发布列表按钮去重。
- “作废删除”改为“作废并归档”。
- 已发布撤回到预发布前增加信用风险提示。

裁决为 Go，依据：

- 聚焦测试通过。
- 云端只读 `file/access` 验证通过。
- iPhone 人工真机补验通过：公共资料入口、下载、打开、保存、分享、三类切换、作废归档、撤回信用提示和文字遮挡均通过。
- `flutter analyze` 仍因既有非本轮 warning 返回非零，本轮新增 warning 已清理。
- 当前 Flutter 自动化未识别到可用 iPhone 设备，但用户已完成真机人工回执。

## 2. 本轮范围

涉及：
- Flutter 公共资料下载体验。
- Flutter 公共资料展示和不可用态。
- Flutter 预发布列表按钮文案。
- Flutter 预发布作废归档文案。
- Flutter 已发布撤回信用风险提示。
- SSOT 验收与信用账本建议文书。

不涉及：
- BFF。
- Server。
- DB schema。
- 项目状态机。
- 公共资料数据补齐。
- 真实信用扣分。
- 信用分恢复接口。
- Nginx、systemd、云端基础设施。

## 3. 改动文件

Flutter：
- `apps/mobile/pubspec.yaml`
- `apps/mobile/pubspec.lock`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_trade_pages.dart`
- `apps/mobile/lib/features/exhibition/data/services/project_public_resource_action_service.dart`
- `apps/mobile/lib/features/exhibition/presentation/presentation_support/project_public_resource_support.dart`
- `apps/mobile/lib/features/exhibition/presentation/widgets/project_public_resource_widgets.dart`
- `apps/mobile/lib/features/exhibition/presentation/presentation_support/bid_submit_template_download_support.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/my_project_list_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/presentation_support/my_project_stage_support.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/widgets/exhibition_status_messages.dart`

测试：
- `apps/mobile/test/project_attachment_corridor_test.dart`
- `apps/mobile/test/project_attachment_prepublish_and_bid_materials_test.dart`
- `apps/mobile/test/my_project_private_carry_test.dart`
- `apps/mobile/test/shell_app_test.dart`

文书：
- `docs/00_ssot/public_resource_download_closure_and_prepublish_button_governance_boundary_freeze_addendum.md`
- `docs/00_ssot/public_resource_download_closure_and_prepublish_button_governance_acceptance_receipt.md`
- `docs/00_ssot/published_project_withdraw_credit_ledger_next_round_recommendation.md`

## 4. 云端只读回执

通过隧道 `http://127.0.0.1:8080` 验证：

- `GET /api/app/project/public-resources`：200。
- 三类资源均存在：
  - `contract_template`：1 条。
  - `process_guide`：1 条。
  - `other_resource`：1 条。
- 三条资源都有有效 `fileAssetId`。
- 三条资源调用 `GET /api/app/file/access?mode=download&accessScope=public_resource` 均返回 200。
- 三条资源均返回 `accessUrl`。

## 5. 测试结果

通过：

- `flutter test test/project_attachment_corridor_test.dart`
- `flutter test test/project_attachment_prepublish_and_bid_materials_test.dart`
- `flutter test test/my_project_private_carry_test.dart`
- `flutter test test/shell_app_test.dart --plain-name 'bid submit keeps compact template download actions available'`

说明：
- 曾并行启动多个 Flutter test，触发 Flutter shader 资产写入锁冲突；改为串行后通过。

`flutter analyze`：
- 结果：40 issues，非零退出。
- 本轮新增 warning 已清理。
- 剩余 issues 位于既有未治理文件，例如 `avoid_print`、`unused_element`、`invalid_use_of_protected_member` 等，不属于本轮改动新增。

设备：
- `flutter devices` 当前只识别 `macOS` 和 `Chrome`。
- iPhone 显示为 LAN browsing 错误，未成为可部署 device。
- 真机补验由用户人工完成并反馈通过。

真机人工回执：
- 公共资料入口：通过。
- 合同模板下载：通过，可打开、可保存、可分享。
- 下载完成操作面板：通过，可打开、可保存、可分享。
- 打开文件：通过。
- 保存到文件：通过。
- 三类资源切换：通过。
- 预发布列表按钮：通过；观察到第一次弹出诚意金提示，第二次点击通过。
- 作废并归档：通过。
- 已发布撤回提示：通过。
- 文字与遮挡：通过，无文字遮挡。
- 最终结论：通过。

## 6. 风险清单

已解决：
- 公共资料点击下载直接跳浏览器。
- 公共资料只有合同模板感知，不知道还有三类资源。
- 预发布列表同卡片动作重复。
- 作废动作误叫“删除”。
- 已发布撤回缺少信用风险提醒。

未解决但不阻塞：
- App 内不解析 DOCX/PDF，只交给系统打开或分享保存。
- iOS “保存到文件”依赖系统分享面板，不能由 App 直接写到用户指定目录。
- 预发布列表第一次点击弹出诚意金提示、第二次通过。当前不阻塞本轮下载闭环和按钮治理，但建议在下一轮单独复核诚意金内测豁免提示节奏。

阻塞项：
- 无。

## 7. 下一轮唯一动作

本轮已结项。下一轮建议只做一件事：

1. 单独复核“预发布第一次点击弹诚意金提示、第二次通过”的交互节奏，判断是否需要把内测豁免说明前置到第一次点击前。
