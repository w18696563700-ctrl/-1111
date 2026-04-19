---
owner: Codex 总控
status: active
purpose: Freeze the frontend execution prompt for enterprise_hub V1 residual-risk closure so the mobile consumption layer closes only the real entity and authenticated application-status chain on the formal app-facing surface.
layer: L0 SSOT
based_on:
  - docs/00_ssot/enterprise_hub_v1_bounded_reentry_dispatch_bundle_addendum.md
  - docs/00_ssot/enterprise_hub_v1_integration_risk_closure_verification_conclusion_addendum.md
  - docs/00_ssot/enterprise_hub_v1_frontend_real_entity_chain_receipt_addendum.md
  - docs/00_ssot/enterprise_hub_v1_real_account_context_dependency_freeze_addendum.md
  - docs/00_ssot/enterprise_hub_v1_app_aligned_freeze_addendum.md
freeze_date_local: 2026-04-10
---

# 《enterprise_hub V1 frontend residual-risk closure execution prompt》

## 当前阶段

- 主线：
  - `enterprise_hub V1`
- 子阶段：
  - `residual-risk closure / frontend`
- 当前只允许处理：
  - home card -> real list entity -> real detail 的真实消费闭环
  - real authenticated application-status 的受控承接

## 当前唯一动作

- 发给 `前端 Agent` 的唯一执行口令如下。

```text
你是前端 Agent（仅本地），本轮不是重做 enterprise_hub，而是只关闭 residual-risk closure 中属于 mobile consumption 的剩余问题。

【一、唯一目标】
你这轮只完成两件事：
1. 让首页三卡进入真实实体链消费闭环：
   - home card -> real list entity -> real detail
2. 让 `application-status` 在真实 authenticated context 下被前端正确承接

【二、强制阅读】
- docs/00_ssot/enterprise_hub_v1_bounded_reentry_dispatch_bundle_addendum.md
- docs/00_ssot/enterprise_hub_v1_integration_risk_closure_verification_conclusion_addendum.md
- docs/00_ssot/enterprise_hub_v1_frontend_real_entity_chain_receipt_addendum.md
- docs/00_ssot/enterprise_hub_v1_real_account_context_dependency_freeze_addendum.md
- docs/00_ssot/enterprise_hub_v1_app_aligned_freeze_addendum.md
- backend Agent 本轮 residual-risk closure 回执
- BFF Agent 本轮 residual-risk closure 回执

【三、启动前提】
- 若 backend/BFF 本轮回执未齐备：
  - 不要猜测真值
  - 不要拿空列表或 missing-entity 404 当“已经接通”
  - 直接按阻断态回报，不能扩写成前端新任务

【四、只允许修改的范围】
- apps/mobile/**
- 与 enterprise_hub 当前消费面直接相关的最小测试文件

【五、优先检查的文件】
- apps/mobile/lib/features/exhibition/presentation/exhibition_home_page.dart
- apps/mobile/lib/features/exhibition/presentation/enterprise_hub_list_pages.dart
- apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_pages.dart
- apps/mobile/lib/features/exhibition/presentation/enterprise_hub_apply_pages.dart
- apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart
- apps/mobile/lib/features/exhibition/presentation/enterprise_hub_board_surface.dart
- apps/mobile/lib/features/exhibition/presentation/enterprise_hub_list_state_support.dart
- apps/mobile/lib/features/exhibition/data/enterprise_hub_consumer_layer.dart
- apps/mobile/lib/features/exhibition/data/enterprise_hub_workbench_consumer_layer.dart

【六、禁止事项】
- 不得新增新 building
- 不得新增新 tab
- 不得直连 Server
- 不得新增本地 fake entity 伪装成真实闭环
- 不得把 empty-state / 401 / 403 / 404 重写成成功态
- 不得扩到 enterprise_hub 外的页面

【七、你必须完成的消费闭环】
1. 首页三卡
- 当前首页已暴露：
  - `优秀公司`
  - `优秀工厂`
  - `优秀供应商`
- 你必须保证三卡点击后能进入真实列表消费面，而不是继续停在“看起来像已通”的空壳承接

2. 三类列表
- 你必须保证 backend/BFF 已提供真实实体后：
  - `company / factory / supplier` 列表都能出现真实实体卡片
  - 不再把 `items=[]` 的旧空态当默认成功视觉
  - real content-state 与真正 empty-state 明确区分

3. 真实 detail
- 对 backend/BFF 提供的真实 `enterpriseId`：
  - detail 页面必须消费真实内容
  - 不得继续落到 missing-entity 404 才算“链路已到”

4. real authenticated application-status
- 在真实 `session + organization context` 下：
  - `/exhibition/enterprise/application-status`
  - 必须消费 app-facing `GET /api/app/exhibition/enterprise-hub/applications/{applicationId}` 的真实结果
- 当前要证明的是：
  - 真状态已被正确读到
  - 真状态被正确展示
  - 不再把无会话 `401` 当默认承接成功

【八、测试要求】
- 至少补最小必要测试，证明：
  1. real entity 出现时，列表从 empty-state 切到 content-state
  2. detail 在真实 entity 数据下渲染真实内容，而不是 not-found fallback
  3. application-status 在真实状态下承接正确
- 不要求堆测试数量，但必须覆盖你这轮修正过的真实闭环点

【九、完成标准】
- 当前 mobile consumption 能证明：
  - home card -> real list entity -> real detail 已闭环
  - application-status 在真实认证上下文下已闭环
  - empty-state / 401 / 403 / 404 仍保留为真实阻断或真实中间态，不被伪装成通过

【十、回执要求】
回执必须至少包含：
1. 修改文件清单
2. 哪些页面之前仍把空态或错误态看起来像“已接通”
3. 现在如何区分 real content-state 与真实 empty/blocker state
4. 新增或更新的测试结果
5. 当前剩余非前端阻断项

【十一、输出禁令】
- 不要写“后端给数据就行”
- 不要把 fake transport / demo transport 当 closure 证据
- 不要顺手做 UI 重构
- 不要扩到论坛、项目、工作台其他主线
- 只给 bounded consumption closure 结果
```
