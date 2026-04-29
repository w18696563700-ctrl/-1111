# App 视觉系统 V1 第一批阶段收口记录

## 1. 阶段定位

本阶段只做 Flutter 前端展示层视觉系统 V1 的最小闭环，不做全 App 一次性美化，不做业务流程重构。

本阶段目标：

- 冻结 App 级视觉系统 V1 的施工边界。
- 建立可复用 token 与基础组件。
- 迁移第一批低风险页面。
- 用真实入口截图、相关测试和边界记录完成阶段收口。

## 2. 已冻结真相

已新增并登记：

- `docs/00_ssot/app_visual_system_v1_freeze_addendum.md`
- `docs/04_frontend/app_visual_system_v1_frontend_plan.md`
- `docs/00_ssot/source_of_truth_map.md`

冻结口径：

- 只允许 Flutter 展示层改造。
- 不修改 BFF、Server、OpenAPI、数据库、接口契约、业务状态机。
- 不修改业务路由规则。
- 不新增假功能、假入口、假状态。
- 隐藏楼只允许接入 token，不做页面级精修。
- 第一批只迁移：我的页未登录卡/登录页、参与竞标申请状态页、项目展示列表页。

## 3. 已新增视觉基础

新增 token：

- 颜色：页面底色、卡片底色、品牌金、深金、浅金、正文/说明/弱化文字、柔和边框、轻状态色。
- 字体：页面标题、区块标题、卡片标题、正文、强调正文、说明、小徽章、按钮。
- 间距：页面留白、卡片留白、区块间距、条目间距、chip 间距。
- 圆角：小、中、大、超大、胶囊。
- 阴影：soft/card/floating。
- 尺寸：bottom nav 高度、浮层按钮、最小触控、输入框、主按钮高度。

新增共享组件：

- `AppPageHeader`
- `AppCard`
- `AppSectionCard`
- `AppPrimaryButton`
- `AppSecondaryButton`
- `AppStatusBadge`
- `AppFilterChip`
- `AppInfoChip`
- `AppEmptyState`
- `AppBottomSafePadding`

组件边界：

- 不持有业务真值。
- 不调用接口。
- 不改状态管理。
- 不内置业务文案。
- 只承接视觉一致性。

## 4. 第一批已迁移页面

### 4.1 我的页未登录卡 / 登录页

迁移内容：

- 未登录卡接入 V1 卡片、留白、按钮和状态视觉。
- 登录页 hero、登录方式切换、输入区域、协议区域接入 V1 token。
- 保留原登录流程、登录方式、协议勾选、底部导航。

未改动：

- 未新增第三方登录。
- 未修改 auth 状态判断。
- 未修改登录接口、路由和状态管理。

### 4.2 参与竞标申请状态页

迁移内容：

- 状态页改为 `状态 Hero + 项目信息 + 申请流程 + 申请记录` 结构。
- 待审批、已通过、已拒绝、异常态保持可见。
- 技术 ID 在非主视觉区弱化展示。
- 保留刷新状态、处理申请、申请记录。

未改动：

- 未隐藏真实状态。
- 未改接口字段。
- 未改审批/申请状态机。
- 未改路由。

### 4.3 项目展示列表页

迁移内容：

- 筛选区域接入 V1 section/card/chip。
- 项目卡接入 V1 card、badge、info chip、主次 action。
- 保留项目编号、预算、面积、搭建地、时间、状态、详情入口、申请入口。
- 增加列表底部安全区，避免 floating bottom nav 遮挡最后一张卡。

未改动：

- 未删除字段。
- 未修改筛选动作。
- 未修改项目详情入口。
- 未改申请参与竞标动作和状态。

## 5. 截图验收

修改前截图：

- `docs/04_frontend/screenshots/app_visual_system_v1_day1_before_exhibition_home.png`
- `docs/04_frontend/screenshots/app_visual_system_v1_day1_before_messages.png`
- `docs/04_frontend/screenshots/app_visual_system_v1_day1_before_profile.png`
- `docs/04_frontend/screenshots/app_visual_system_v1_day1_before_project_detail.png`
- `docs/04_frontend/screenshots/app_visual_system_v1_day1_before_project_showcase.png`

修改后截图：

- `docs/04_frontend/screenshots/app_visual_system_v1_day7_after_login.png`
- `docs/04_frontend/screenshots/app_visual_system_v1_day7_after_profile_unauth.png`
- `docs/04_frontend/screenshots/app_visual_system_v1_day7_after_exhibition_home.png`
- `docs/04_frontend/screenshots/app_visual_system_v1_day7_after_exhibition_home_logged_in.png`
- `docs/04_frontend/screenshots/app_visual_system_v1_day7_after_project_showcase.png`
- `docs/04_frontend/screenshots/app_visual_system_v1_day7_after_project_showcase_logged_in.png`
- `docs/04_frontend/screenshots/app_visual_system_v1_day7_after_project_showcase_bottom_safe.png`
- `docs/04_frontend/screenshots/app_visual_system_v1_day7_after_bid_participation_status.png`

截图结论：

- 真实 App 入口已验收，不是只在 demo 中生效。
- 本地 `127.0.0.1:8080` 隧道处于监听状态，真实入口截图使用当前 App 配置返回的数据。
- 项目展示列表连续卡片可滚动。
- 底部 floating nav 没有遮挡列表主要操作区。
- 参与竞标状态页保持真实状态可见。

## 6. 测试与分析结果

已通过：

- `dart analyze lib/shared/ui/app_visual_tokens.dart lib/shared/ui/app_visual_components.dart lib/shared/theme/app_theme.dart`
- `dart analyze lib/features/profile/presentation/profile_page.dart lib/features/profile/presentation/profile_login_frame.dart lib/features/profile/presentation/profile_login_page.dart`
- `dart analyze lib/features/exhibition/presentation/exhibition_trade_pages.dart lib/features/exhibition/presentation/pages/project_name_access_thread_page.dart`
- `dart analyze lib/features/exhibition/presentation/exhibition_trade_pages.dart lib/features/exhibition/presentation/pages/project_list_page.dart lib/features/exhibition/presentation/widgets/project_list_filter_widgets.dart lib/features/exhibition/presentation/widgets/project_showcase_card_widgets.dart`
- `flutter test --no-pub test/project_name_access_day45_test.dart test/project_showcase_filter_create_refactor_test.dart`
- `flutter test --no-pub test/profile_page_test.dart --name "switch account logs out and routes to login page"`

全量 `flutter analyze --no-pub` 当前仍有非本轮红灯，主要集中在：

- 历史 `avoid_print`。
- 历史未使用变量、未使用方法、不可达代码。
- 历史 `invalid_use_of_protected_member`。
- 历史测试 support 未使用 import / unnecessary override。

这些红灯不在本轮新增文件和本轮目标页面中，后续应作为单独清理批次处理。

全量 `flutter test --no-pub` 当前结果：

- 通过：522
- 失败：107

失败范围较宽，主要包括：

- 论坛截图类 golden baseline 缺失。
- 论坛发布/详情/附件/作者页面旧断言与当前页面结构不一致。
- shell / 展览首页测试仍断言旧天气标题或旧展示文案。
- showcase / bid submit 相关测试仍断言旧按钮 widget 类型或旧滚动结构。
- profile 深层状态页测试仍断言旧详情页回退按钮或旧整段摘要文案。

结论：

- 本轮目标相关的 token / 组件 / 参与竞标状态页 / 项目展示列表页 / 登录页目标测试已通过。
- 全量测试仍不是绿色，不能作为本阶段“全 App 已稳定”的结论。
- 全量失败应拆成后续独立测试债清理批次，不在本轮视觉系统第一批内扩大修复。

## 7. 本轮 changed_files 清单

Flutter 展示层：

- `apps/mobile/lib/shared/theme/app_theme.dart`
- `apps/mobile/lib/shared/ui/app_visual_tokens.dart`
- `apps/mobile/lib/shared/ui/app_visual_components.dart`
- `apps/mobile/lib/features/profile/presentation/profile_page.dart`
- `apps/mobile/lib/features/profile/presentation/profile_page_sections.dart`
- `apps/mobile/lib/features/profile/presentation/profile_login_frame.dart`
- `apps/mobile/lib/features/profile/presentation/profile_login_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_trade_pages.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/project_list_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/widgets/project_list_filter_widgets.dart`
- `apps/mobile/lib/features/exhibition/presentation/widgets/project_showcase_card_widgets.dart`

说明：`apps/mobile/lib/features/exhibition/presentation/pages/project_name_access_thread_page.dart`
已作为状态页验收对象复核；当前工作区无该文件 diff，本阶段只把其现有状态纳入截图与测试收口。

文书与截图：

- `docs/00_ssot/app_visual_system_v1_freeze_addendum.md`
- `docs/00_ssot/source_of_truth_map.md`
- `docs/04_frontend/app_visual_system_v1_frontend_plan.md`
- `docs/04_frontend/app_visual_system_v1_stage_receipt.md`
- `docs/04_frontend/screenshots/app_visual_system_v1_day1_before_*.png`
- `docs/04_frontend/screenshots/app_visual_system_v1_day7_after_*.png`

## 8. 明确未触碰边界

本阶段未修改：

- `apps/bff/**`
- `apps/server/**`
- `openapi.yaml`
- 数据库迁移
- 接口契约
- 业务状态机
- App 业务路由规则
- 隐藏楼页面级精修
- 云端服务配置

说明：当前工作区存在其他非本阶段 BFF/Server/合同/Flutter dirty changes，本收口记录只覆盖 App 视觉系统 V1 第一批相关文件。

## 9. 后续建议

建议下一批进入：

1. 展览首页 V1 复核与组件化收束。
2. 项目详情页视觉统一。
3. 我的项目页列表/阶段卡统一。

暂不建议：

- 一次性迁移消息楼所有详情态。
- 对隐藏楼做页面级精修。
- 引入图片资产体系或重型 UI 库。
- 在视觉系统批次中夹带接口、状态机或路由改造。
