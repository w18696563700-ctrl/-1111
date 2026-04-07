---
owner: Codex 总控
status: pre_frozen
purpose: Pre-freeze the current publish experience optimization boundary, limited to approved P0 and P1 UX issues and without widening business truth, contract meaning, persistence, or unrelated boards.
layer: L0 SSOT
inputs_canonical:
  - AGENTS.md
  - 当前发布体验问题优先级排序 v1（已审核通过）
  - docs/00_ssot/project_publish_round_a_consumption_truth_and_ui_boundary_freeze_addendum.md
  - docs/00_ssot/project_showcase_publish_alignment_frontend_consumption_freeze_addendum.md
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_frontend_consumption_freeze_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/project_create_round_a_widgets.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/exhibition_page_frames.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_load_service.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/project_list_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_list_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/presentation_support/my_project_private_progress_support.dart
  - apps/mobile/lib/features/profile/presentation/profile_page.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_home_page_sections.dart
freeze_date_local: 2026-04-04
---

# 当前发布体验优化预冻结单

## 1. Scope

- 本预冻结单只覆盖 `当前发布体验优化 pre-freeze`。
- 本预冻结单只允许覆盖《当前发布体验问题优先级排序 v1》中的：
  - `P0 必改`
  - `P1 应改`
- 本预冻结单只服务于当前已完成主线上的 Flutter 消费层体验优化，不进入：
  - truth freeze
  - contract freeze
  - persistence freeze
  - backend / BFF / Flutter 实现
- 本预冻结单不扩到：
  - forum
  - 消息
  - 搜索界面
  - 地域分类页面
  - 地图 / 经纬度
  - 企业库
  - 订单平台化后台
  - 合同后台
  - 履约治理后台
  - 其他无关板块

## 2. Pre-freeze Conclusion

- 本轮优化现正式预冻结为一条纯体验优化主线。
- 本轮优化只处理以下 6 件事：
  - 发布失败原因提示改准
  - 发布成功态改成明确业务成功
  - 发布成功后增加“已发布项目预览”
  - 公域项目展示列表提密度、减解释
  - 公域项目详情继续去掉边界型噪音
  - 统一“我的项目 / 项目工作台 / 发布工作台”用户语言
- 本轮优化不新增 business truth，不扩 contract 真义，不新增 persistence 真相。
- 本轮优化的真实边界只包括：
  - Flutter 消费层体验优化
  - 页面框架文案优化
  - 信息呈现密度优化
  - 页面关系语言收口

## 3. 本轮优化正式范围

### 3.1 P0 必改 + P1 应改的正式准入项

- `发布失败原因提示改准`
  - 问题本质现正式冻结为：
    - 真实 guard 分支与真实失败原因已经存在
    - 但 blocked / result card 的固定提示语会误导当前用户
  - 本轮只允许优化：
    - 失败提示语
    - 失败承接语
    - 返回路径语言
  - 本轮不允许改：
    - guard 真义
    - access truth
    - create contract

- `发布成功态改成明确业务成功`
  - 当前成功后仍保留较重的“结果反馈 / 后续承接”讲解语气。
  - 本轮现正式允许把成功结果优先收口为：
    - 明确的业务成功态
    - 再附带继续处理入口
  - 本轮不允许改：
    - project create success truth
    - success payload 真义

- `发布成功后增加“已发布项目预览”`
  - 本轮现正式纳入。
  - 但预览只允许复用现有已冻结字段，不得发明新字段。
  - 预览当前正式更适合落在：
    - 发布成功结果区的受控预览卡片
  - 本轮不 author：
    - 第二套详情页
    - 第二套列表 card truth

- `公域项目展示列表提密度、减解释`
  - 当前列表卡片与概览区存在解释文案偏重、垂直成本偏高问题。
  - 本轮现正式允许：
    - 压缩卡片垂直成本
    - 减少说明性文案
    - 提升最小有效信息密度
  - 本轮不允许改：
    - list contract
    - list truth
    - list data source

- `公域项目详情继续去掉边界型噪音`
  - 当前详情已具备真值字段承接，但解释型提示仍偏多。
  - 本轮现正式允许：
    - 继续压缩解释型文案
    - 保留必要边界说明但明显降噪
  - 本轮不允许改：
    - detail truth
    - detail contract
    - detail public/private 边界

- `统一“我的项目 / 项目工作台 / 发布工作台”用户语言`
  - 当前三者职责已经冻结，但页面文案与导流话术仍可能给用户造成职责重叠感。
  - 本轮现正式允许：
    - 标题、摘要、入口文案、导流文案收口
    - 首页/工作台/我的楼的用户语言统一
  - 本轮不允许改：
    - 路由职责
    - truth 职责
    - contract family

## 4. 本轮明确排除范围

- 正式附件列表 read truth / visibility truth
- `我的项目` richer 私域状态真相接入
- 发布资格与认证真相重构
- `奖励金额`
- `单位平方面积金额`
- 搜索界面
- 地域分类页面
- 地图 / 经纬度
- forum / 消息
- 订单平台化后台
- 合同后台
- 履约治理后台
- 其他无关板块

## 5. Truth / Contract / Persistence Boundary

- 本轮不新增 business truth。
- 本轮不改变现有 contract 真义。
- 本轮不新增 persistence 真相。
- 本轮不新增 migration。
- 本轮正式定义为：
  - Flutter 消费层体验优化
  - 页面框架文案优化
  - 信息呈现密度优化
  - 页面关系语言收口
- 因此本轮正式禁止：
  - 把优化需求包装成 richer private truth 接入
  - 把页面文案调整包装成 contract 扩面
  - 把结果预览包装成 second read model

## 6. 允许进入后续优化的页面 / 组件范围

### 6.1 允许影响的页面 / 组件族

- 发布页：
  - `apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/widgets/project_create_round_a_widgets.dart`
- 发布页 blocked / success 结果承接：
  - `apps/mobile/lib/features/exhibition/presentation/widgets/exhibition_page_frames.dart`
  - `apps/mobile/lib/features/exhibition/data/services/exhibition_load_service.dart`
- 公域项目展示列表：
  - `apps/mobile/lib/features/exhibition/presentation/pages/project_list_page.dart`
- 公域项目展示详情：
  - `apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart`
- 我的项目列表：
  - `apps/mobile/lib/features/exhibition/presentation/pages/my_project_list_page.dart`
- 我的项目详情：
  - `apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/presentation_support/my_project_private_progress_support.dart`
- 我的楼入口文案：
  - `apps/mobile/lib/features/profile/presentation/profile_page.dart`
- 首页 / 工作台 / 导流页面的结构性用户语言：
  - `apps/mobile/lib/features/exhibition/presentation/exhibition_home_page_sections.dart`

### 6.2 允许优化的内容类型

- 页面标题与摘要文案
- 受控状态文案
- blocked / success 结果承接文案
- 列表卡片的密度与说明文案收口
- 详情页解释型提示降噪
- “我的项目 / 项目工作台 / 发布工作台”之间的导流语言统一

## 7. 明确禁止触碰的范围

- 公域 truth 本身
- 公域 contract 本身
- `project/create` 提交真义
- `project/workbench` truth 真义
- `GET /api/app/project/list` / `GET /api/app/project/detail` / `GET /api/app/my/projects` / `GET /api/app/my/projects/{projectId}` 的 contract 真义
- BFF / Server / Admin
- forum / 消息 / upload 真相链
- 正式附件列表相关 truth
- richer 私域进度真相
- 奖励金额
- 单位平方面积金额

## 8. 结果反馈框架边界

### 8.1 `exhibition_page_frames.dart` 的框架语气

- 当前正式允许：
  - 局部收缩或弱化 `结果反馈 / 动作前确认 / 动作执行 / 后续承接` 的讲解语气
  - 尤其在发布结果页上，把“讲解框架感”收束为“业务结果感优先”
- 当前正式不允许：
  - 直接推翻统一页面框架
  - 改变受控状态 / retry / fallback 的行为真义

### 8.2 发布成功态

- 本轮现正式允许对发布成功页做：
  - “业务成功态优先”的结果框架调整
  - 在成功态中降低解释型话术密度
  - 保留必要的后续动作入口

### 8.3 已发布项目预览

- 本轮现正式允许发布成功页新增：
  - “已发布项目预览”
- 但该预览只允许复用现有已冻结字段，例如：
  - `title`
  - `buildingType`
  - `budgetAmount`
  - `areaSqm`
  - standardized location name
  - `scopeSummary`
  - `plannedStartAt`
  - `plannedEndAt`
  - `scheduleDetail`
- 当前正式禁止：
  - 为预览发明新字段
  - 为预览引入正式附件列表
  - 为预览引入 richer 私域状态

## 9. 公域与私域页面关系边界

- 公域项目展示页仍是公域。
- 项目发布工作台仍是创建页。
- 项目工作台仍是摘要 / 导流页。
- 我的项目仍是当前组织私域资产入口。
- 本轮只允许优化上述四者之间的用户语言与体验，不允许改它们的 truth 职责。
- 当前正式允许做的只是：
  - 用户语言统一
  - 标题 / 摘要 / 导流文案统一
  - 成功 / 失败后续承接语言统一
- 当前正式禁止：
  - 把“项目工作台”重写成“我的项目”
  - 把“发布工作台”重写成公域列表
  - 把“我的项目”重写成公域展示入口

## 10. Stage Conclusion

- 当前结论：
  - `Go` for entering the `当前发布体验优化 truth freeze` stage
  - `No-Go` for直接进入 contract freeze
  - `No-Go` for直接进入 persistence freeze
  - `No-Go` for直接进入 implementation
- 本预冻结单的真实含义是：
  - 当前发布体验优化的正式范围已写死
  - 明确排除范围已写死
  - 本轮已被正式限定为纯体验优化主线
  - 页面允许范围与禁止范围已写清

## 11. 修订记录

- `v1.0` `2026-04-04`
  - 首版冻结“当前发布体验优化”预冻结边界。
  - 正式确认本轮只覆盖已审核通过的 `P0 必改 + P1 应改` 六项体验问题。
  - 正式确认发布成功预览纳入本轮，但只允许复用现有已冻结字段。
  - 正式确认 `exhibition_page_frames` 框架语气允许局部收缩，但不改框架真义。
