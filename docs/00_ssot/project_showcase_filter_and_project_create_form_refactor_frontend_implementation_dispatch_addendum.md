---
owner: Codex 总控
status: active
purpose: Freeze the frontend implementation dispatch prompt for the project showcase filter and project create form refactor object so local mobile execution closes only the frozen list filter consumption, dual-field create form, compact card layout, and public expiry-unavailable handling.
layer: L0 SSOT
freeze_date_local: 2026-04-11
based_on:
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_bounded_implementation_dispatch_bundle_addendum.md
  - docs/04_frontend/project_showcase_filter_and_project_create_form_refactor_frontend_consumption_freeze_addendum.md
  - docs/03_bff/project_showcase_filter_and_project_create_form_refactor_bff_aggregation_app_facing_surface_freeze_addendum.md
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_bff_implementation_dispatch_addendum.md
  - docs/02_backend/project_showcase_filter_and_project_create_form_refactor_backend_truth_persistence_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《项目展示筛选与创建表单重构 frontend implementation dispatch》

## 当前阶段

- 主对象：
  - `项目展示筛选与创建表单重构`
- 子阶段：
  - `bounded implementation dispatch / frontend`
- 当前只允许处理：
  - 项目展示列表页的筛选与卡片压缩消费
  - 项目展示详情页的双字段优先消费与过期 unavailable
  - 项目创建页的双字段表单

## 当前唯一动作

- 发给 `前端 Agent` 的唯一执行口令如下。

```text
你是前端 Agent（仅本地），本轮不是重做整个展示页，而是只闭合《项目展示筛选与创建表单重构》在 Flutter 侧已经冻结好的最小消费范围。

【一、唯一目标】
你这轮只完成 4 件事：
1. 让项目展示列表页支持：
   - 默认当前城市上下文承接
   - 手动城市筛选
   - 面积档位筛选
   - 金额档位筛选
2. 让项目展示列表卡片改为紧凑主信息结构，重点只突出：
   - 展会
   - 品牌
   - 金额
   - 面积
   - 地点
   - 时间
3. 让项目展示详情页支持：
   - `exhibitionName / brandName` 双字段优先
   - expired public continuation unavailable 的受控承接
4. 让项目创建页把原“项目名称”升级成两格：
   - 第一格：展会
   - 第二格：品牌
   并保持 legacy `title` compatibility 不被前端擅自破坏

【二、强制阅读】
- docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_truth_boundary_freeze_addendum.md
- docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_contract_freeze_compatibility_ruling_addendum.md
- docs/04_frontend/project_showcase_filter_and_project_create_form_refactor_frontend_consumption_freeze_addendum.md
- docs/03_bff/project_showcase_filter_and_project_create_form_refactor_bff_aggregation_app_facing_surface_freeze_addendum.md
- docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_bounded_implementation_dispatch_bundle_addendum.md
- docs/01_contracts/openapi.yaml

【三、当前已知后端 / BFF 闭合事实】
当前已可依赖：
- `/api/app/project/create`
  - 已支持 dual-field mode
  - 已支持 legacy-title mode
- `/api/app/project/list`
  - 已支持：
    - `provinceCode`
    - `cityCode`
    - `areaBucket`
    - `budgetBucket`
- `/api/app/project/detail`
  - 已承接：
    - `exhibitionName`
    - `brandName`
    - `plannedStartAt`
    - `plannedEndAt`
- expired public continuation：
  - 已返回受控 `404 AUTH_RESOURCE_UNAVAILABLE`

【四、只允许处理的范围】
- apps/mobile/lib/features/exhibition/presentation/pages/project_list_page.dart
- apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart
- apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart
- apps/mobile/lib/features/exhibition/** 中与上述页面直接相关的最小 consumer / state / support touch
- 证明本轮闭环所必需的最小测试文件

【五、禁止事项】
- 不得改 `my_project` 页面
- 不得改 workbench
- 不得扩到附件公开
- 不得扩到审核状态机
- 不得扩到交易后链
- 不得把“公司所在地”做成筛选项
- 不得新增地图 / 行政区联动
- 不得做全站 UI 重构
- 不得把 demo/fake transport 当成通过证据
- 不得直连 Server

【六、必须落实的前端消费真义】
1. 列表筛选
- 必须承接：
  - `provinceCode`
  - `cityCode`
  - `areaBucket`
  - `budgetBucket`
- 默认城市上下文优先级必须保持：
  1. 手动选择城市
  2. 当前定位 / 当前城市上下文
  3. 全国兜底
- 不得新增：
  - 企业所在地筛选
  - `districtCode` 主筛选

2. 列表状态边界
- 必须清楚区分：
  - real content-state
  - real empty-state
  - blocker / failure state
- 不得把 empty-state 伪装成“已接通成功”

3. 紧凑卡片
- 列表卡片主展示顺序必须是：
  1. 展会
  2. 品牌
  3. 金额
  4. 面积
  5. 地点
  6. 时间
- `title` 只作 fallback
- 必须明显压缩当前过高的纵向占用
- 但不要借机做全页风格重做

4. 详情页
- 当 `exhibitionName / brandName` 存在时：
  - 必须优先展示双字段
- `title` 只作 fallback
- expired public continuation 命中时：
  - 必须受控承接 unavailable
- 不得继续把过期项目当正常公开详情展示

5. 创建页
- 原“项目名称”改为两格：
  - 展会
  - 品牌
- 前端新表单优先走 dual-field mode
- 但不得删除 legacy compatibility
- 不得扩到更多新字段

6. 文案边界
- 必须明确：
  - 公域展示是只读展示
  - 过期退出展示不等于项目不存在
  - 过期退出展示不等于 owner 私域不可见

【七、测试要求】
- 至少补最小必要测试，证明：
  1. 列表筛选参数会被前端消费层正确带出
  2. real content-state / real empty-state / blocker state 已区分
  3. 列表卡片按新主信息顺序渲染
  4. 详情页在 dual-field 存在时优先展示双字段
  5. expired unavailable 被受控承接
  6. 创建页双字段模式可提交，legacy 兼容未被前端误删

【八、完成标准】
- 项目展示列表页已支持：
  - 城市 / 面积 / 金额筛选
- 列表卡片已压缩为六项重点信息结构
- 项目展示详情页已支持：
  - dual-field 优先
  - expired unavailable
- 项目创建页已升级为：
  - 展会 + 品牌
- 本地 analyze / targeted tests 通过

【九、回执要求】
回执必须至少包含：
1. 当前对象
2. 修改文件清单
3. 哪些页面原来仍不够专业或仍有语义漂移
4. 现在如何收口：
   - 筛选
   - 卡片结构
   - 详情结构
   - 创建表单
5. analyze / test 结果
6. 当前剩余非前端阻断项
7. 是否可移交 `结果校验 Agent`

【十、输出禁令】
- 不要写“后端给数据就行”
- 不要把 fake/demo 当通过
- 不要重做全站样式
- 不要改 `my_project`
- 只给真实代码修改与真实本地验证结果
```
