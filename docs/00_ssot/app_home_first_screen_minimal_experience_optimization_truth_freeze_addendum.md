---
title: app_home_first_screen_minimal_experience_optimization_truth_freeze_addendum
owner: Codex 总控
status: frozen
layer: L0 SSOT
updated_at: 2026-04-28
purpose: Freeze the bounded Flutter-only optimization object for the current App first-screen experience pass, limited to exhibition home presentation shell, key tabs, home cards, and controlled state surfaces.
inputs_canonical:
  - docs/00_ssot/gate_register_v1.md
  - docs/04_frontend/exhibition_ui_visual_baseline_stage_closure_20260421.md
  - docs/04_frontend/flutter_screen_map.md
  - docs/04_frontend/exhibition_home_project_card_day1_inventory_frontend_truth_note.md
  - docs/04_frontend/project_list_visibility_copy_clarity_frontend_surface_addendum.md
  - docs/04_frontend/project_showcase_filter_and_project_create_form_refactor_frontend_consumption_freeze_addendum.md
---

# App 首屏体验优化最小闭环冻结单

## 1. 本轮只优化什么

- 本轮只优化 `Flutter App` 的首屏体验最小闭环。
- 当前正式冻结对象只包括：
  - `App 首屏 / 展览楼首页 / 推荐频道`
  - `关键 Tab 与频道壳层`
  - `首页项目卡 / 首页论坛卡`
  - `首页加载态 / 空态 / 错误态 notice`
- 当前优化只允许发生在 `apps/mobile` 前端展示层：
  - 布局
  - 间距
  - 卡片视觉层级
  - CTA 轻重关系
  - Tab 视觉与切换反馈
  - 受控状态面文案与样式

## 2. 本轮不优化什么

- 不优化 `BFF`
- 不优化 `Server`
- 不优化 `OpenAPI / contracts`
- 不优化支付、会员、竞标、权限、项目状态机
- 不优化 `项目创建 / 项目编辑 / 我的项目 / 消息楼 / profile`
- 不优化 `项目展示列表` 的筛选真义、字段结构、分页行为
- 不新增搜索、通知、收藏、真实项目封面、公开附件、地图联动

## 3. 涉及页面

- `/exhibition`

## 4. 涉及文件

- `apps/mobile/lib/features/exhibition/presentation/exhibition_home_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_home_page_sections.dart`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_home_module_deck.dart`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_home_channel_rails.dart`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_home_project_forum_panels.dart`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_home_recommendation_section.dart`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_home_widgets.dart`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_home_visual_tokens.dart`
- `apps/mobile/test/exhibition_home_test.dart`
- `apps/mobile/test/shell_app_test.dart`

## 5. 涉及路由

- `AppBuilding.exhibition.routePath`
- `ExhibitionRoutes.home`
- 当前页面消费面仍只读承接：
  - `GET /api/app/exhibition/home`
  - 当前首页项目推荐临时复用的项目列表只读结果

## 6. 是否需要改 contracts

- `No`

## 7. 是否需要改 BFF

- `No`

## 8. 是否需要改 Server

- `No`

## 9. 是否需要云上联调

- `Yes, read-only smoke only`
- 用于验证：
  - 首页真实加载
  - 真实卡片与受控状态面
  - 未登录 / 登录态下的现有可见内容
- 不允许触发写操作。

## 10. 是否涉及业务真相

- `No`
- 本轮只调展示层，不调整：
  - 项目公开可见范围
  - 项目状态语义
  - 频道数据来源
  - 云端接口返回结构

## 11. 是否涉及接口字段

- `No`
- 不新增字段，不重解释字段，不私造字段。

## 12. 是否涉及 mock / seed

- `No for product truth`
- 测试允许继续使用现有 Flutter test doubles，但不得把 test doubles 写回产品文案或运行时逻辑。

## 13. runtime evidence missing

- 当前冻结阶段允许存在：
  - 首页实时数据样本的 runtime evidence missing
  - 登录态差异的 runtime evidence missing
- 这些缺证不阻塞本轮 `Flutter-only UI optimization`，但必须在收口报告里单列。

## 14. Go / No-Go 裁决对象

- `Go for Flutter-only UI optimization on /exhibition first-screen experience`
- `No-Go for project-list truth reinterpretation`
- `No-Go for contracts modification`
- `No-Go for BFF modification`
- `No-Go for Server modification`
- `Conditional Go for runtime smoke only`

## 15. 当前最小闭环

- 首页推荐频道壳层更干净
- Tab 更像成熟 App
- 项目卡与论坛卡更轻、更整齐、更省高度
- 加载态 / 空态 / 错误态更统一

## 16. 需要保留但暂不开通

- `项目展示列表` 新筛选能力
- 搜索 / 通知 / 收藏
- 真实项目封面与公开附件预览
- 任何新的首页聚合字段

## 17. 后续扩展位

- 公域项目列表二阶段视觉精修
- 首页更多频道的真实内容反射
- 长标题 / 长城市 / 长预算专项适配

## 18. 下一步唯一动作

- 进入 `apps/mobile` 的首页 Flutter-only 最小实现与 targeted test。
