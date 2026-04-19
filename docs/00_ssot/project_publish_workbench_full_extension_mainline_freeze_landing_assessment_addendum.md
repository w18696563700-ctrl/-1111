---
owner: Codex 总控
status: frozen
purpose: >
  Assess how much of the current `发布项目工作台` freeze chain has actually
  landed in live code, split the workbench object into four bounded packages,
  and freeze that Package 1 `workbench truth alignment`、Package 2
  `order / fulfillment carrier closure`、Package 3
  `shell / handoff normalization`、Package 4
  `boundary and dead-family cleanup` have now completed their bounded landing.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_ruling_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_truth_boundary_freeze_addendum.md
  - docs/01_contracts/project_publish_workbench_full_extension_mainline_contract_freeze_addendum.md
  - docs/02_backend/project_publish_workbench_full_extension_mainline_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/project_publish_workbench_full_extension_mainline_bff_surface_freeze_addendum.md
  - docs/04_frontend/project_publish_workbench_full_extension_mainline_frontend_consumption_freeze_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_docs_only_freeze_review_conclusion_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_bounded_implementation_dispatch_bundle_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_code_layer_scan_rerun_addendum.md
  - apps/server/src/modules/exhibition_workbench/exhibition-workbench.query.service.ts
  - apps/server/src/modules/exhibition_workbench/exhibition-workbench.presenter.ts
  - apps/server/src/modules/trading_read_corridor/trading-read-corridor.controller.ts
  - apps/server/src/modules/my_project/my-project.query.service.ts
  - apps/bff/src/routes/exhibition_workbench/app-exhibition-workbench.controller.ts
  - apps/bff/src/routes/exhibition_workbench/exhibition-workbench.service.ts
  - apps/bff/src/routes/trading_read_corridor/app-trading-read-corridor.controller.ts
  - apps/mobile/lib/features/exhibition/presentation/exhibition_page.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_page_sections.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model_sections.dart
  - apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_contract_validation.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_entry_contract_validation.dart
  - apps/mobile/lib/shell/navigation/app_router.dart
  - apps/mobile/test/exhibition_home_test.dart
  - apps/mobile/test/shell_app_test.dart
  - apps/mobile/test/inspection_phase3_test.dart
  - apps/mobile/test/dispute_entry_test.dart
---

# 《发布项目工作台冻结落实评估单》

## 1. Scope

- 本评估单只回答三件事：
  - 当前 `发布项目工作台` 冻结链在 live code 里到底落实了多少
  - 当前对象应如何拆成四个 bounded package
  - 当前为什么 Package 4 可以视为已完成 bounded landing
- 本评估单不是：
  - root-guardrail exception unlock
  - implementation unlock
  - real implementation dispatch issuance
  - integration pass
  - `release-prep`
  - production release

## 2. 总体评估

- 先分开看：
  - docs-only freeze chain 完成度：高
  - runtime 落地完成度：中低
- 当前综合结论：
  - 文书冻结链已经基本成形，完成度可视为 `90%+`
  - 代码层的 freeze landing 只完成了第一层骨架，完成度更接近
    `40% - 50%`
- 当前不能写成：
  - “发布项目工作台已闭环”
  - “订单、履约、边界能力都已 runtime 接通”

## 3. 已落实的冻结事实

### 3.1 文书冻结链：已基本落实

- 当前对象已经形成：
  - mainline ruling
  - truth boundary freeze
  - contract freeze
  - backend truth / persistence freeze
  - BFF surface freeze
  - frontend consumption freeze
  - docs-only freeze review conclusion
  - bounded implementation dispatch bundle
- 当前文书链已经明确：
  - `发布项目工作台及延伸功能全链` 是当前真实主线对象
  - `订单承接与履约承接主链` 只保留为从属 stop-line 子链
  - mixed-maturity 结构必须区分：
    - verified runtime
    - read-corridor
    - shell / handoff
    - boundary-only

### 3.2 Flutter 工作台页壳：已基本落实

- `/exhibition/workbench` 已有正式页面壳：
  - hero
  - feature status
  - 四容器 deck
  - boundary footnote
- 四容器结构已经按当前对象渲染：
  - `项目承接`
  - `订单承接`
  - `履约承接`
  - `边界能力`
- 边界能力中的 `评价入口边界` 与 `争议撤回边界`
  目前保持只读冻结态，没有被做成可点击 live action。

### 3.3 `project_chain`：已落实最多

- 当前真正最成熟的仍是 `project_chain`：
  - `GET /api/app/exhibition/workbench`
  - `POST /api/app/project/create`
  - `GET /api/app/project/detail`
  - `GET /api/app/project/list`
  - `GET /api/app/my/projects`
  - `GET /api/app/my/projects/{projectId}`
- 这部分已经具备：
  - workbench summary
  - project publish corridor reuse
  - public detail / list
  - my-project private carry

### 3.4 read-corridor：只读走廊已落实

- 当前 `order / fulfillment` 真正落实的是 read-corridor：
  - `GET /api/app/order/detail`
  - `GET /api/app/contract/detail`
  - `GET /api/app/milestone/list`
  - `GET /api/app/inspection/detail`
- `BFF` 与 `Server` 当前都已存在对应 controller。

## 4. 尚未落实的冻结事实

### 4.1 `workbench` 真值与页面成熟度仍未对齐

- `Server` workbench query 当前只真实提供：
  - 最近项目
  - `canCreateProject`
  - `canOpenProjectPool`
- 但 presenter 仍固定返回四容器结构，且：
  - `order_chain`
  - `fulfillment_chain`
  - `extension_boundary`
  当前都还是空壳 projection。
- Flutter 页面当前文案却已经写成：
  - “已完成四类私域摘要承接、刷新入口，以及既定私域续接入口”
- 这会把当前 mixed-maturity 误写成四容器都已具备相同成熟度。

### 4.2 `canOpenProjectPool` 已冻结，但页面没接出来

- 当前 freeze 允许：
  - `canOpenProjectPool`
  - `open project pool`
- `Server` 也已经返回了 `canOpenProjectPool`
- 但 Flutter `project_chain` 当前只展示：
  - `最近项目承接`
  - `发布项目`
- 没有把“项目展示 / 项目池”做成工作台 handoff。

### 4.3 `order_chain / fulfillment_chain` 仍停在“容器存在，真投影不足”

- 当前已存在：
  - 订单详情
  - 合同详情
  - 里程碑列表
  - 验收详情
  的 read-corridor
- 但 workbench summary 还没有真实提供：
  - `activeOrderId`
  - `activeMilestoneId`
  - 与当前组织 continuation 对应的稳定 anchor
- 结果是：
  - 页面节点能渲染
  - 但工作台自身没有足够真值支撑这些 continuation 按 freeze 成熟度稳定成立

### 4.4 shell / handoff 节点仍被 mobile 当成 active POST

- freeze 明确把以下节点定义为：
  - shell / handoff position
  - 不是 active command family 已成立
- 当前受影响的节点：
  - `milestone/submit`
  - `inspection/submit`
  - `dispute/open`
- 但 mobile 页面与测试当前仍把它们按真实 happy-path POST 在维护。
- 这和当前 mixed-maturity freeze 直接冲突。

### 4.5 冻结外命令族残留仍在

- 当前 freeze 明确排除：
  - `order/create`
  - `contract/confirm`
  - `contract/amend`
  - `inspection/recheck`
  - `rating/submit`
  - `dispute/withdraw`
- 当前路由层已经部分收缩。
- 但 consumer layer、canonical paths、contract validation、entry validation
  仍保留这些冻结外命令族残留。

### 4.6 `my-project` 仍混入冻结外 truth family

- backend freeze 已明确排除：
  - `ratings`
  - `disputes`
- 但 `my_project` 当前仍直接读取：
  - `public.disputes`
  - `public.ratings`
  来投影私域进度。
- 这说明 `my-project` 还没有完全按 full-object freeze 收口。

## 5. 四包拆分

### 5.1 Package 1

- 名称：
  - `workbench truth alignment`
- 当前定位：
  - 唯一允许先开的 package
- 目标：
  - 让 `发布项目工作台` 先对齐当前 freeze 与当前真值
  - 先把“工作台是什么、不是什麽、哪些已通、哪些只读、哪些只是边界”
    写对并落对
- 只允许处理：
  - `workbench` summary / handoff 真值对齐
  - 四容器成熟度表达对齐
  - `canOpenProjectPool -> 项目展示` handoff 对齐
  - workbench feature-status / banner / node 文案去虚高
  - 与上述直接相关的最小 BFF / Flutter / Server touch
- 明确不处理：
  - 新交易主链扩面
  - admin / governance console
  - shell 节点 active-command 化
  - 排除项重开
- 当前落实率评估：
  - `60% 左右`
- 当前主要缺口：
  - workbench 真值与页面成熟度未对齐
  - `canOpenProjectPool` 未落 handoff
  - 页面状态文案高估了当前闭环程度

### 5.2 Package 2

- 名称：
  - `order / fulfillment carrier closure`
- 当前定位：
  - 已完成 bounded landing，当前关闭
- 目标：
  - 只补 workbench summary 中与 read-corridor 对应的最小 continuation carrier
  - 让 `order_chain / fulfillment_chain`
    从“有壳无锚”变成“有最小真实 anchor 的 continuation slice”
- 只允许处理：
  - `activeOrderId`
  - `activeMilestoneId`
  - 只读走廊和 summary carrier 的对齐
- 明确不处理：
  - 订单创建
  - 合同确认 / 变更
  - 复检
  - 评价提交
  - 争议撤回
- 当前落实率评估：
  - `90% 左右`
- 当前阻断：
  - 当前包的最小 carrier projection 已闭合，后续 shell posture 仍待 Package 3 收正

### 5.3 Package 3

- 名称：
  - `shell / handoff normalization`
- 当前定位：
  - 已完成 bounded landing，当前关闭
- 目标：
  - 只把
    - `milestone/submit`
    - `inspection/submit`
    - `dispute/open`
    从“被误当 active POST”收回到 freeze 允许的 shell / handoff posture
- 只允许处理：
  - shell page posture
  - fail-closed blocker
  - app-facing transport 一致性
- 明确不处理：
  - active command write closure
  - 第二状态机
  - 争议 / 验收 / 里程碑完整业务闭环
- 当前落实率评估：
  - `90% 左右`
- 当前阻断：
  - 当前包的 shell posture 与 accepted surface 已闭合，后续 dead-family residue
    与 `my-project` 越界 truth 仍待 Package 4 收正

### 5.4 Package 4

- 名称：
  - `boundary and dead-family cleanup`
- 当前定位：
  - 已完成 bounded landing，当前关闭
- 目标：
  - 清理冻结外动作残留
  - 清理 `my-project` 对冻结外 truth family 的混入
  - 让 extension boundary 只剩 freeze 认可的 boundary posture
- 只允许处理：
  - dead route / dead command / dead validation residue
  - `my_project` 对 `ratings / disputes` 的越界投影收口
  - extension boundary 与排除项一致性清理
- 当前落实率评估：
  - `90% 左右`
- 当前阻断：
  - 当前包的 dead-family residue 与 `my-project` 越界 truth 已完成 bounded
    cleanup；若再扩面，已经超出 Package 4 定义

## 6. Package 3 已完成后的当前原因

- 当前最大的错误已经不再是 shell posture 漂移，而是：
  - mobile 里冻结外命令族仍保留 consumer / action / load / validation /
    page / route 残留
  - `my-project` 仍在直接读取 `ratings / disputes` 这两类冻结外 truth family
- 如果继续停留在 Package 3：
  - shell / handoff 三条路径虽然已经收正
  - 但 mobile 代码库内部仍继续维护
    - `order/create`
    - `contract/confirm`
    - `contract/amend`
    - `inspection/recheck`
    - `rating/entry`
    - `rating/submit`
    - `dispute/withdraw`
    的执行与验证残留
  - `my-project` 也仍会把评价 / 争议误混回私域正式进度
- 因此当前必须继续固定：
  - 哪些冻结外命令必须从 mobile 实现链彻底收掉
  - 哪些 blocked route 只保留受控不可进入，不再保留真实 page / consumer
  - `my-project` 哪些字段必须退回已冻结 truth 内部
  - extension boundary 哪些状态只保留 boundary posture，不再暗示 executable family

## 6.1 Package 4 当前完成证据

- 已完成的 bounded landing：
  - mobile 已移除冻结外 command / consumer / action / load / validation / page
    残留
  - blocked route 仍保持 `路由不可用`，但不再保留 dead executable surface
  - `my-project` 已不再查询 `public.disputes` 与 `public.ratings`
  - `formalCompletionStatus / evaluationStatus`
    已退回当前 in-scope order-based truth 语义
- 当前对象内验证结果：
  - `apps/server/test/historical-projects-semantics.test.cjs` 通过
  - `apps/mobile/test/my_project_private_carry_test.dart` 通过
  - `apps/mobile/test/exhibition_home_test.dart` 通过
  - 相关 `shell_app` dead-route 定向用例已在前一轮通过
- 当前仍保留但不属于 Package 4 阻断的噪音：
  - `apps/mobile/test/profile_page_test.dart`
    仍有一批 back-button / scroll / organization flow 旧基线红点
  - 这些红点不依赖 `发布项目工作台` 当前对象，也不构成 Package 4 的 reopening 理由

## 7. 当前裁决

- 当前四包正式拆分如下：
  - Package 1：`workbench truth alignment`
  - Package 2：`order / fulfillment carrier closure`
  - Package 3：`shell / handoff normalization`
  - Package 4：`boundary and dead-family cleanup`
- 当前只允许：
  - 将当前四包视为已完成 bounded landing
- 当前不允许：
  - 任何 `Package 5` 幻想扩面
- 当前必须明确：
  - 这里的“开包”只表示当前对象的工作重心与顺序冻结
  - 不自动等于 root-guardrail exception 已通过
  - 不自动等于 implementation unlock 已通过
  - 不自动等于 real implementation dispatch issuance 已通过

## 8. Package 4 最小完成定义

- 若要判定 `Package 4 / boundary and dead-family cleanup` 完成，至少需要看到：
  1. mobile 不再保留冻结外命令族的真实 consumer / action / load / validation
     调用链
  2. blocked route 仍可进入受控不可用页，但对应 dead page 实现不再继续挂在当前
     exhibition trade library 中
  3. `order/create`、`contract/confirm`、`contract/amend`、
     `inspection/recheck`、`rating/entry`、`rating/submit`、
     `dispute/withdraw` 不再作为 current executable family 被维护
  4. `my-project` 不再直接查询 `public.disputes` 与 `public.ratings`
  5. `my-project` 的 formal-completion / evaluation 姿态只回退到当前仍被冻结的
     order-based truth 语义
  6. extension boundary 的 `ratingEntryState / disputeWithdrawState`
     继续保留 boundary-only posture，但不再反向拉起 dead command family
- 当前判定：
  - 以上 6 条已满足
  - Package 4 可判定为 `Completed`

## 9. Next Unique Action

- 下一步唯一动作：
  - 若继续推进，只能进入当前对象的 closure-review / maintenance-only judgment
    authoring，而不是 reopen 新交易扩面
