# 展览首页项目卡 UI 精修 Day 5 前端收口记录

## 1. 记录定位

本文只记录展览首页项目卡 UI 精修 Day 5 的前端展示层收口结果。

本文不解锁任何业务能力，不修改接口真值，不修改路由真值，不修改状态机真值。

## 2. 当前最小闭环

当前展览首页项目卡展示层已完成以下最小闭环：

- 项目卡保留标题、状态 badge、进场、搭建地、面积、预算、进入项目详情 CTA。
- 首页项目卡使用固定商业示意默认封面。
- 默认封面表达为“商业示意默认封面，不代表项目真实图片”。
- 当前默认封面实现口径冻结为：Flutter `CustomPaint` 绘制抽象展台封面。
- 当前默认封面不得读取项目附件、真实效果图、施工图、客户私有图片或网络图片。
- 首屏能看到项目卡主体与 CTA。
- visual demo 已提供 3 条不同项目 mock，用于验收连续三卡列表体验。
- 最后一张项目卡完整可见，CTA 不被底部 floating nav 遮挡。

## 3. 本轮展示层边界

本轮只允许被理解为 Flutter 展示层优化。

本轮未触碰：

- `apps/bff/**`
- `apps/server/**`
- OpenAPI
- 数据库
- 接口契约
- 路由
- 状态机
- 项目列表真实字段结构

本轮未新增：

- 搜索能力
- 通知能力
- 收藏能力
- 真实项目图片展示能力
- 图片上传能力
- 第三方图片接口
- 本地照片资产或带 EXIF/GPS 元数据的图片资产
- 假天气数据
- 假业务字段

## 4. 防误删/误改项

以下内容属于当前首页项目卡展示层验收成果，不应被后续误删或误改：

- `_HomeDefaultProjectCover` 的“示意图”标签
- `_HomeDefaultProjectCover` 的语义说明：“商业示意默认封面，不代表项目真实图片”
- `_HomeDefaultProjectCover` 的 Flutter 绘制默认封面不能替换为真实项目图、网络图或来源不明的本地照片资产
- 如本地存在 `apps/mobile/assets/images/exhibition/default_project_cover.jpg`，它属于本地遗留照片资产，不属于本阶段入库资产，不应被提交或打包
- `_HomeProjectCard` 中进场、搭建地、面积、预算四个字段 chip
- `_HomeProjectPrimaryAction` 的整宽 CTA
- 首页 ListView bottom padding 对 bottom nav 高度、安全区和额外留白的覆盖

## 5. 验收命令

Day 5 已通过以下验收：

- `flutter analyze lib/dev/visual_demo/visual_demo_app.dart lib/features/exhibition/presentation/exhibition_home_page.dart lib/features/exhibition/presentation/exhibition_home_widgets.dart lib/features/exhibition/presentation/exhibition_home_project_forum_panels.dart lib/shell/presentation/app_shell_scaffold.dart test/exhibition_home_test.dart`
- `flutter test test/exhibition_home_test.dart`
- `flutter test test/exhibition_home_weather_test.dart`
- `flutter test test/shell_app_test.dart --plain-name "exhibition root presents a clean weather shell home"`
- `flutter test test/shell_app_test.dart --plain-name "first release bottom navigation only shows three buildings"`

以上命令均通过。

## 6. 验收截图

截图保存在：

- `artifacts/ui_iteration_20260426_home_project_card_day3_day4/day5-final-real-home.png`
- `artifacts/ui_iteration_20260426_home_project_card_day3_day4/day5-final-bottom-safe-area.png`
- `artifacts/ui_iteration_20260426_home_project_card_day3_day4/day4-continuous-three-cards-real-home.png`
- `artifacts/ui_iteration_20260426_home_project_card_day3_day4/day4-last-card-bottom-safe-area-real-home.png`

## 7. 后续扩展位

后续允许作为扩展位保留，但当前不开放：

- 按项目类型切换多套默认商业示意封面
- 首页项目公开封面上传与权限治理
- 搜索、通知、收藏等真实能力入口
- 长标题、长城市、长预算字段的专项 widget 截断测试

## 8. 收口结论

Day 5 收口结论为：

展览首页项目卡展示层精修已完成阶段验收。

该结论只覆盖展示层，不得被解释为真实项目图片展示、项目附件公开、搜索、通知、收藏或图片上传能力已经开通。
