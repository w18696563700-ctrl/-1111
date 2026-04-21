---
title: exhibition_ui_visual_baseline_stage_closure_20260421
doc_type: frontend_visual_stage_closure
owner: codex
status: frozen
updated_at: 2026-04-21
purpose: Freeze the bounded visual baseline and mutation guard for the current exhibition mobile UI convergence work so later edits do not accidentally revert the accepted hierarchy, color discipline, or homepage shell structure.
---

# 展览端 UI 阶段性收口冻结单

## 1. Scope

- 本冻结单只覆盖：
  - `apps/mobile` 当前展览端视觉收口
  - 2026-04-21 本轮连续 UI 迭代的阶段性结果
- 本冻结单只服务于：
  - 给后续前端改动提供明确视觉基线
  - 防止把已收口的首页、频道区、列表卡、详情卡、表单态、论坛/企业页重新改回“高噪音、多色、厚卡片”状态
- 本冻结单不表示：
  - 全仓设计系统已完备
  - 所有页面都已逐页精修完毕
  - 可以绕过现有 truth / route / contract 边界直接改业务语义

## 2. 当前正式视觉基线

### 2.1 总体气质

- 当前正式视觉方向冻结为：
  - `白底中性 + 单一暖棕强调`
- 当前不再允许回退为：
  - 暖米黄大底
  - 多暖色块并列
  - 卡片、按钮、chip、状态 badge 同时高强调

### 2.2 首页正式壳层

- 展览首页当前正式首屏顺序冻结为：
  1. 天气与定位卡
  2. `公开入口 / 推荐频道`
  3. 统一频道容器
- 频道容器当前正式结构冻结为：
  1. 主频道 tab
  2. 工具操作条
  3. 轻量筛选条
  4. 频道内容卡或受控 notice
- 当前不允许回退为：
  - 六宫格入口首页
  - 说明墙首页
  - 多个强浮层入口同时抢主路径

### 2.3 频道内容卡正式规则

- 项目卡、论坛卡、企业卡当前统一冻结为：
  - 轻白底卡
  - 紧凑标题
  - 两行摘要截断
  - 更小 badge
  - 更轻详情按钮
- 当前不允许回退为：
  - 厚 padding
  - 多段长摘要
  - 大 badge + 大按钮同时并列

### 2.4 工具条正式规则

- 频道工具条当前冻结为：
  - 主入口保留轻强调
  - 次动作退为工具级按钮
  - 筛选 chip 只承担切换，不承担视觉主角
- 当前不允许回退为：
  - 整排大按钮
  - 工具条比内容卡更抢眼
  - 筛选条高饱和高权重

## 3. 本轮已完成动作总览

### 3.1 全局减色与主题收口

- 已完成：
  - 全局主题从偏暖米黄体系收为白底中性体系
  - 主强调收敛到单一暖棕
  - 导航、按钮、chip、surface 统一减色
- 关键文件：
  - [app_theme.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/shared/theme/app_theme.dart)

### 3.2 首页结构与突兀感修正

- 已完成：
  - 首页标题层级重排
  - `公开入口 / 推荐频道` 壳层建立
  - 去除首页双浮层抢戏
  - 天气卡与频道区之间的断层感压缩
- 关键文件：
  - [exhibition_home_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/exhibition_home_page.dart)
  - [exhibition_home_page_sections.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/exhibition_home_page_sections.dart)
  - [exhibition_home_module_deck.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/exhibition_home_module_deck.dart)

### 3.3 天气卡减重

- 已完成：
  - 默认折叠态信息减密
  - `今夜降雨 / 官方预警` 收回展开态
  - 工具按钮从大横条改为轻量操作
  - 天气卡体量和首屏压迫感下降
- 关键文件：
  - [exhibition_home_weather_card.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/exhibition_home_weather_card.dart)

### 3.4 内容卡密度收口

- 已完成：
  - 项目卡标题、摘要、badge、按钮整体压缩
  - 企业卡、论坛卡同步统一
  - 卡片间纵向距离从 `12` 收到 `10`
- 关键文件：
  - [exhibition_home_widgets.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/exhibition_home_widgets.dart)
  - [exhibition_home_recommendation_section.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/exhibition_home_recommendation_section.dart)
  - [exhibition_home_project_forum_panels.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/exhibition_home_project_forum_panels.dart)
  - [exhibition_home_enterprise_panels.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/exhibition_home_enterprise_panels.dart)

### 3.5 工具条与筛选条收口

- 已完成：
  - 主入口按钮收小
  - 次动作退成轻工具条
  - 筛选 chip 缩一号
  - 工具条与内容区间距再收一档
- 关键文件：
  - [exhibition_home_channel_rails.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/exhibition_home_channel_rails.dart)
  - [exhibition_home_project_forum_panels.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/exhibition_home_project_forum_panels.dart)
  - [exhibition_home_enterprise_panels.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/exhibition_home_enterprise_panels.dart)
  - [exhibition_home_module_panels.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/exhibition_home_module_panels.dart)

### 3.6 列表页 / 详情页 / 表单页 / forum / enterprise 同步减色

- 已完成：
  - 列表页、详情页、表单页的次级动作与状态卡减色
  - forum / enterprise 的共享 card、chip、次按钮同步减色
  - 不再允许多套色块在同一页并列
- 关键文件：
  - [project_list_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/project_list_page.dart)
  - [project_detail_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart)
  - [project_create_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart)
  - [exhibition_status_widgets.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/widgets/exhibition_status_widgets.dart)
  - [exhibition_surface_widgets.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/widgets/exhibition_surface_widgets.dart)
  - [project_showcase_card_widgets.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/widgets/project_showcase_card_widgets.dart)
  - [forum_scaffold_widgets.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/forum/forum_scaffold_widgets.dart)
  - [forum_feed_support.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/forum/forum_feed_support.dart)
  - [forum_me_page_sections.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/forum/forum_me_page_sections.dart)
  - [forum_draft_search_pages.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/forum/forum_draft_search_pages.dart)
  - [enterprise_hub_shared.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/enterprise_hub_shared.dart)
  - [enterprise_hub_list_controls.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/enterprise_hub_list_controls.dart)
  - [enterprise_hub_list_pages.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/enterprise_hub_list_pages.dart)
  - [enterprise_hub_detail_pages.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_pages.dart)

### 3.7 最小视觉规范页

- 已完成：
  - 冻结最小视觉规范页用于后续对照
- 关键文件：
  - [minimal_visual_spec_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/minimal_visual_spec_page.dart)
  - [app_router.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/shell/navigation/app_router.dart)

## 4. 当前禁止回退项

- 不得恢复大面积暖米黄底
- 不得恢复首页双 FAB
- 不得把天气卡重新做成高信息密度说明卡
- 不得把频道工具条重新做成大块强调按钮组
- 不得把项目卡、企业卡、论坛卡重新拉回厚 padding 和多色 badge
- 不得把 forum / enterprise 再重新长出第二套高强调色系
- 不得把 `team` 频道伪装成真实推荐
- 不得用说明文案墙替代真实读链内容

## 5. 后续变更门槛

- 后续若继续修改上述冻结区域，至少必须同时满足：
  - 保留新的前后对比截图
  - 不新增业务语义漂移
  - 不破坏当前首页主路径
  - 保持相关 widget / shell 用例通过
- 若要推翻当前视觉基线，而不是小步微调，必须先补一份新的收口或替换文书，不能静默回退。

## 6. 证据与截图

- 本轮截图资产统一保留在：
  - `/Users/wangweiwei/Desktop/展览装修之家总控/artifacts/ui_iteration_20260421/`
- 关键对比图包括：
  - `home-before.png`
  - `home-after.png`
  - `home-theme-after.png`
  - `home-descoped-colors-after.png`
  - `home-before-round3.png`
  - `home-after-round3.png`
  - `home-after-round4-buttons.png`
  - `home-after-round5-weather-density.png`
  - `home-after-round6-weather-actions.png`
  - `home-after-round7-vertical-rhythm.png`
  - `home-after-round8-content-cards.png`
  - `home-after-round9-tool-rails.png`
  - `project-list-after.png`
  - `project-detail-after.png`
  - `project-form-after.png`
  - `visual-spec-after.png`
  - `forum-after-round2.png`
  - `enterprise-after-round2.png`

## 7. 验证基线

- 当前已作为收口基线跑通过的关键验证包括：
  - `flutter analyze`
  - `flutter test test/exhibition_home_test.dart`
  - `flutter test test/exhibition_home_weather_test.dart`
  - `flutter test test/widget_test.dart`
  - `flutter test test/shell_app_test.dart --plain-name 'exhibition root presents a clean weather shell home'`

## 8. Formal Conclusion

- 当前正式结论是：
  - 2026-04-21 展览端 UI 连续减色、减重、收口结果已经形成阶段性视觉基线
  - 这份基线当前应被视为“允许继续小步微调，但不允许无记录回退”的收口状态
  - 后续任何人若对首页、频道工具条、内容卡、forum / enterprise 共享视觉层做明显回退，均应视为违反本冻结单
