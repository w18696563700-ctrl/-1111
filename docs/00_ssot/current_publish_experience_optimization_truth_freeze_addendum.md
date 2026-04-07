---
owner: Codex 总控
status: frozen
purpose: Formally freeze the truth boundary for the current publish experience optimization, limited to user-visible expression, result carry style, list density direction, detail-noise reduction, and entry-language alignment without changing business truth, contract meaning, or persistence truth.
layer: L0 SSOT
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/current_publish_experience_optimization_pre_freeze_addendum.md
  - 当前发布体验问题优先级排序 v1（已审核通过）
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

# 当前发布体验优化真源冻结单

## 1. Scope

- 本冻结单只覆盖 `当前发布体验优化 truth freeze`。
- 本冻结单只覆盖已经通过 pre-freeze 的 6 项：
  - 发布失败原因提示改准
  - 发布成功态改成明确业务成功
  - 发布成功后增加“已发布项目预览”
  - 公域项目展示列表提密度、减解释
  - 公域项目详情继续去掉边界型噪音
  - 统一“我的项目 / 项目工作台 / 发布工作台”用户语言
- 本冻结单只冻结：
  - 用户可见表达 truth
  - 结果承接方式 truth
  - 列表密度方向 truth
  - 说明型文案边界 truth
  - 页面关系语言 truth
- 本冻结单不进入：
  - contract freeze
  - persistence freeze
  - backend / BFF / Flutter 实现
- 本冻结单继续排除：
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

## 2. Truth Freeze Conclusion

- 本轮已正式冻结为一条“只改用户可见表达与呈现方式、不改现有业务真义”的体验优化主线。
- 本轮正式不新增 business truth。
- 本轮正式不改变 contract 真义。
- 本轮正式不改变 persistence truth。
- 本轮正式不改变：
  - 发布资格真义
  - workbench 真义
  - my-project 私域状态真义
  - 公域展示字段真义
- 因此本轮真实含义是：
  - 把错误说准
  - 把成功说清
  - 把页面讲解感降下来
  - 把列表与详情的信息呈现收紧
  - 把“我的项目 / 项目工作台 / 发布工作台”的用户语言收口

## 3. 发布失败提示 Truth Freeze

### 3.1 正式表达原则

- 发布失败页现正式以：
  - `真实失败原因优先`
  作为第一用户可见表达 truth。
- 动作引导仍可保留，但必须排在真实原因之后。
- 本轮正式结论是：
  - “错误说准”优先于“引导去哪里”

### 3.2 正式禁止的表达方式

- 当前正式禁止继续用固定泛提示覆盖不同失败原因，至少不得混淆：
  - 未登录
  - 无组织
  - `canCreateProject = false`
  - workbench 请求失败
  - 网络错误
- 当前正式写死：
  - 网络 / BFF / workbench 请求失败 != 账号准备不足
  - 账号准备不足 != 网络错误
  - 无组织 != `canCreateProject=false`

### 3.3 按钮与承接边界

- 当前正式允许保留受控引导按钮。
- 但按钮文案、承接文案、返回路径文案必须与真实失败原因一致。
- 当前正式不允许：
  - 用统一“回到项目工作台”掩盖完全不同的失败成因
  - 让用户从文案上误判当前阻断属于认证不足、网络失败或页面未加载完成中的另一类

## 4. 发布成功态 Truth Freeze

### 4.1 成功页第一表达

- 发布成功页现正式以：
  - `业务成功态优先`
  作为第一表达 truth。
- 成功页必须先回答：
  - 你已经发布成功
  - 你发出去的是哪一个项目
  - 下一步能去哪里

### 4.2 系统框架表达的降级

- `结果反馈`、`后续承接` 这类系统框架表达，在成功态中现正式允许降为次级表达。
- 当前正式禁止：
  - 继续让成功页首先呈现“讲解框架页”的感受
  - 用“系统结果反馈”压过“项目已经发布成功”的业务感知

### 4.3 成功页的正式表达结构

- 本轮正式冻结的成功表达顺序为：
  - 成功主标题
  - 已发布项目预览
  - 下一步动作
- 当前正式不采用：
  - `系统结果反馈 + 后续承接`
  作为第一感受结构

## 5. 成功后项目预览 Truth Freeze

### 5.1 是否准入

- 发布成功后现正式允许展示：
  - `已发布项目预览`

### 5.2 预览的 truth 边界

- 该预览只允许复用现有已冻结字段。
- 当前正式更接近：
  - `列表卡片预览`
- 当前不冻结为：
  - 第二套详情头部 read truth
- 原因已写死：
  - 本轮只是成功结果增强，不重造第二套 detail 入口
  - 列表卡片风格更适合表达“刚刚已发布出去的项目”

### 5.3 正式允许复用的字段面

- 当前正式允许复用的预览字段包括但不限于：
  - `title`
  - `buildingType`
  - `budgetAmount`
  - `areaSqm`
  - standardized location name
  - `scopeSummary`
  - `plannedStartAt`
  - `plannedEndAt`
  - `scheduleDetail`

### 5.4 正式禁止混入的内容

- 当前正式禁止：
  - 发明新字段
  - 混入正式附件列表
  - 混入 richer 私域状态
  - 混入 `奖励金额`
  - 混入 `单位平方面积金额`

## 6. 公域项目列表 Truth Freeze

### 6.1 正式优化方向

- 公域项目展示列表当前正式优化方向定义为：
  - 提高一屏可见项目数
  - 降低单卡垂直成本
  - 保留核心信息
  - 减少说明型噪音
- 本轮正式写死：
  - 结构压缩
  - 不是字段扩张

### 6.2 truth 不变边界

- 本轮只调整可见呈现密度与语言，不改变 list contract 真义。
- 本轮不改变 list data source。
- 本轮不改变 list 字段 owner。

### 6.3 卡片核心可见真相

- 列表卡片当前仍以以下字段作为核心可见真相：
  - 标题
  - 地点
  - 面积
  - 预算
  - 状态
  - 摘要

### 6.4 应被降级或移除的解释型话术

- 当前正式应被降级或移除的包括：
  - 过重的概览解释段
  - 过长的“下一步动作”讲解
  - 与卡片核心信息无关的开发验收型提示
  - 会把公域展示误导成私域工作台的说明文案

## 7. 公域项目详情 Truth Freeze

### 7.1 第一表达原则

- 公域项目详情页现正式以：
  - `业务信息优先，边界说明后置`
  作为用户可见 truth。

### 7.2 必须保留的业务信息区

- 当前必须保留的业务信息包括：
  - 项目概览
  - 地点与范围
  - 补充说明
  - 继续竞标导流

### 7.3 说明型文案边界

- 当前正式允许继续保留必要边界说明。
- 但必须明显弱化讲解语气。
- 本轮正式写死：
  - 详情降噪 = 说明型文案降级
  - 不是删掉业务边界

### 7.4 应被压缩的解释型噪音

- 当前正式应压缩的包括：
  - 重复强调“这里只负责什么、不负责什么”的长段解释
  - 面向开发验收口吻的技术来源提示
  - 抢在业务信息之前出现的导流讲解

## 8. `我的项目 / 项目工作台 / 发布工作台` 语言关系 Truth Freeze

### 8.1 三者用户语言真义

- `项目发布工作台`
  - 用户语言真义正式冻结为：
    - 创建项目
    - 发布项目
    - 发布后的继续查看入口
- `项目工作台`
  - 用户语言真义正式冻结为：
    - 摘要
    - 导流
    - 当前私域动作入口汇总
- `我的项目`
  - 用户语言真义正式冻结为：
    - 当前组织项目资产
    - 私域项目继续处理入口

### 8.2 三者关系的正式用户语言

- 当前正式写死三者关系为：
  - 发布工作台：创建项目
  - 项目工作台：摘要与导流
  - 我的项目：当前组织项目资产与继续处理入口
- 当前正式允许在：
  - 首页
  - 我的楼
  - 导流说明
  中统一这一语言。
- 当前正式不允许：
  - 改路由职责真义
  - 改 truth 职责
  - 把三者写成彼此替代关系

## 9. `exhibition_page_frames` 可被弱化的 Truth 边界

### 9.1 允许弱化的对象

- `exhibition_page_frames` 当前正式允许被局部弱化其框架语气。
- 这轮正式只弱化：
  - `讲解感`
  - `框架提示语`
  - `动作前确认 / 结果反馈 / 后续承接` 的显性存在感

### 9.2 允许弱化最明显的场景

- 发布成功页
  - 允许弱化最明显
- 发布失败页
  - 允许次级弱化，但真实失败原因必须更清楚
- 我的项目页
  - 允许弱化统一工作流口吻，增强私域项目资产入口感
- 公域列表 / 详情页
  - 允许压缩讲解文案与边界型噪音

### 9.3 必须保持不变的能力

- 当前必须保持不变：
  - 受控状态
  - retry
  - fallback
  - recovery route
- 当前正式写死：
  - 这轮只弱化“讲解感”
  - 不改框架行为真义

## 10. 本轮 Truth 的不变项

- 本轮不新增 business truth。
- 本轮不改变 contract 真义。
- 本轮不改变 persistence truth。
- 本轮不改变：
  - 发布资格真义
  - workbench 真义
  - my-project 私域状态真义
  - 公域展示字段真义
- 本轮只是一轮：
  - 体验表达 truth 冻结
- 本轮不是：
  - 业务真相重构
  - contract 改版
  - persistence 改版

## 11. Explicit Non-goals

- 不触碰正式附件列表 read truth
- 不触碰 richer 私域进度真相
- 不触碰 `奖励金额`
- 不触碰 `单位平方面积金额`
- 不触碰搜索界面
- 不触碰地域分类页面
- 不触碰地图 / 经纬度
- 不触碰 forum / 消息
- 不触碰其他无关板块

## 12. Stage Conclusion

- 当前结论：
  - `Go` for entering the `当前发布体验优化 contract freeze` stage
  - `No-Go` for直接进入 persistence freeze
  - `No-Go` for直接进入实现
- 本冻结单的真实含义是：
  - 6 项体验优化的 truth 边界已正式冻结
  - 页面框架可弱化边界已写清
  - “不改 business truth / contract / persistence 真义”已被正式写死
  - 下一步如需继续推进，应先进入 contract freeze，明确这轮体验优化是否需要 contract 层显式承载或保持 no-op

## 13. 修订记录

- `v1.0` `2026-04-04`
  - 首版冻结“当前发布体验优化” truth 边界。
  - 正式确认发布失败提示以真实原因优先。
  - 正式确认发布成功态以业务成功优先。
  - 正式确认成功后项目预览按列表卡片式受控预览承接。
  - 正式确认公域列表以密度优化为方向、公域详情以降噪为方向。
  - 正式确认“我的项目 / 项目工作台 / 发布工作台”的用户语言关系。
