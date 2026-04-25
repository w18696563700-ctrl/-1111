# 展览首页项目卡 UI 精修 Day 1 盘点记录

## 1. 记录定位

本文只记录展览首页项目卡 UI 精修 Day 1 的只读盘点结果与施工边界。

本文不解锁任何业务能力，不修改接口真值，不修改路由真值，不修改状态机真值。

## 2. 当前 UI 目标

本阶段目标是把展览首页项目卡从信息堆叠样式优化为更清爽、统一、商业感更强的首页推荐卡。

目标只覆盖展示层：

- 首页项目卡增加固定商业示意默认封面。
- 项目卡保留标题、状态 badge、进场、搭建地、面积、预算、进入项目详情 CTA。
- 信息结构更清楚，窄屏不挤压、不遮挡。
- 首屏能看到项目卡主体。
- 底部 floating nav 不遮挡项目卡 CTA。

## 3. 涉及文件清单

本阶段允许关注和修改的 Flutter 前端展示层文件包括：

- `apps/mobile/lib/features/exhibition/presentation/exhibition_home_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_home_project_forum_panels.dart`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_home_widgets.dart`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_home_visual_tokens.dart`
- `apps/mobile/lib/shell/presentation/app_shell_scaffold.dart`
- `apps/mobile/lib/dev/visual_demo/visual_demo_app.dart`
- `apps/mobile/test/exhibition_home_test.dart`
- `apps/mobile/test/exhibition_home_weather_test.dart`
- `apps/mobile/test/shell_app_test.dart`

默认封面当前优先使用 Flutter 绘制，不依赖本地图片资源。

## 4. 禁止触碰清单

本阶段不得触碰或变更：

- `apps/bff/**`
- `apps/server/**`
- `docs/00_ssot/**` 的业务真源
- `docs/01_contracts/openapi.yaml`
- `docs/01_contracts/error_codes.yaml`
- 数据库、接口契约、状态机
- app 路由真值
- BFF / Server 返回结构
- 项目列表真实字段结构

## 5. 不允许顺手新增的能力

本阶段不得为了接近参考图而新增以下未闭环能力：

- 搜索入口
- 通知入口
- 收藏或关注入口
- 真实项目图片展示
- 项目附件公开预览
- 图片上传或公开封面上传
- 本地照片资产或带 EXIF/GPS 元数据的图片资产
- 第三方图片接口
- 网络图片依赖
- 假天气数据
- 假项目字段

## 6. 修改前截图

Day 1/Day 3-4 之前的基线截图保存在：

- `artifacts/ui_iteration_20260426_home_project_card_day3_day4/day3-day4-before-baseline.png`

该截图仅用于 UI 对比，不作为业务真值。

## 7. 当前最小闭环

本阶段最小闭环为：

首页展示真实项目列表返回的项目字段，用统一默认商业示意封面改善视觉表达，同时不泄露真实项目图、不改变项目详情权限、不新增未闭环业务能力。

默认商业示意封面使用 Flutter `CustomPaint` 绘制抽象展台，不依赖真实照片、本地照片资产或网络图片。

## 8. 后续扩展位

后续可单独立项但当前不开放：

- 多套项目类型默认商业示意封面
- 公开项目封面上传能力
- 搜索、通知、收藏等真实能力入口
- 长标题、长城市、长预算的专项截断测试

## 9. Day 1 结论

Day 1 冻结结论为：

本阶段只做展览首页项目卡展示层优化。任何搜索、通知、收藏、真实项目图片、图片上传、接口字段、路由或状态机变更均不属于本阶段。
