---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the detailed repair checklist for `发布项目工作台 / Package 1 /
  workbench truth alignment`, constraining the current fix scope to
  workbench-summary truth alignment only while keeping Packages 2-4 closed.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_truth_boundary_freeze_addendum.md
  - docs/01_contracts/project_publish_workbench_full_extension_mainline_contract_freeze_addendum.md
  - docs/02_backend/project_publish_workbench_full_extension_mainline_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/project_publish_workbench_full_extension_mainline_bff_surface_freeze_addendum.md
  - docs/04_frontend/project_publish_workbench_full_extension_mainline_frontend_consumption_freeze_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_bounded_implementation_dispatch_bundle_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_freeze_landing_assessment_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_code_layer_scan_rerun_addendum.md
  - apps/server/src/modules/exhibition_workbench/exhibition-workbench.query.service.ts
  - apps/server/src/modules/exhibition_workbench/exhibition-workbench.presenter.ts
  - apps/bff/src/routes/exhibition_workbench/app-exhibition-workbench.controller.ts
  - apps/bff/src/routes/exhibition_workbench/exhibition-workbench.service.ts
  - apps/mobile/lib/features/exhibition/presentation/exhibition_page.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_page_sections.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model_sections.dart
  - apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart
  - apps/mobile/test/exhibition_home_test.dart
  - apps/mobile/test/shell_app_test.dart
---

# 《发布项目工作台 Package 1 workbench truth alignment 细化修复清单》

## 1. Scope

- 当前 package 只限：
  - `发布项目工作台 / Package 1 / workbench truth alignment`
- 本清单只回答：
  - Package 1 到底要修什么
  - 每一项修复的完成定义是什么
  - 哪些内容必须继续留给 Package 2-4
- 本清单不是：
  - implementation unlock
  - root-guardrail exception unlock
  - real implementation dispatch issuance
  - Package 2 / 3 / 4 开包
  - integration pass
  - `release-prep`
  - production release

## 2. Package 1 唯一目标

- 当前 package 唯一目标只有一条：
  - 让 `发布项目工作台` 页面、summary projection、handoff 节点、状态文案、
    测试断言与已经冻结的 mixed-maturity 真义重新对齐
- 当前 package 只允许解决：
  - “工作台把当前对象成熟度说错了”
  - “工作台遗漏了已经冻结允许的 `project pool/showcase` handoff”
  - “工作台当前文案把 read-corridor / shell / boundary 写成已闭环能力”
- 当前 package 不允许解决：
  - `order_chain / fulfillment_chain` 的真实 carrier closure
  - shell / handoff active-command 化
  - 冻结外命令族清理
  - admin / governance / reporting / moderation 后台联动

## 3. 当前 package 边界

### 3.1 允许处理的文件族

- `apps/server/src/modules/exhibition_workbench/**`
- `apps/bff/src/routes/exhibition_workbench/**`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_page_sections.dart`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model.dart`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model_sections.dart`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model_text.dart`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_source.dart`
- 与上述 workbench 对齐直接相关的最小 supporting touch
- 与 workbench 页面直接相关的最小测试：
  - `apps/mobile/test/exhibition_home_test.dart`
  - `apps/mobile/test/shell_app_test.dart`

### 3.2 明确禁止处理的文件族

- `apps/server/src/modules/trading_read_corridor/**` 的 read-truth 扩面
- `apps/server/src/modules/my_project/**` 的越界 truth family 清理
- `apps/bff/src/routes/trading_read_corridor/**` 的 active-command 扩面
- `apps/mobile/lib/features/exhibition/presentation/pages/milestone_submit_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/inspection_submit_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/dispute_open_page.dart`
- `apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart`
- `apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart`
- `apps/mobile/lib/features/exhibition/data/services/exhibition_contract_validation.dart`
- `apps/mobile/lib/features/exhibition/data/services/exhibition_entry_contract_validation.dart`
- 所有冻结外命令页或命令对象

## 4. 当前 package 的修复项

### 4.1 修复项 A: workbench feature-status 文案降虚高

- 问题：
  - 当前 workbench 页面把“已完成四类私域摘要承接、刷新入口，以及既定私域续接入口”
    写成已成立事实。
  - 这与 live code 的 mixed-maturity 不一致。
- 必须修成：
  - feature-status 文案只允许准确表达：
    - `project_chain` 是当前最成熟 slice
    - `order / fulfillment` 当前主要是 read-corridor continuation
    - `shell / handoff` 仍不是 active command family
    - `boundary-only` 仍保持冻结
- 完成定义：
  - 页面不再出现“四类能力都已完成承接”的含义
  - 页面不再暗示交易后链已闭环
  - 页面不再把 workbench 写成“完整项目后台”

### 4.2 修复项 B: hero / banner / footnote 的 mixed-maturity 对齐

- 问题：
  - 当前 hero 边界与 feature-status 卡片之间存在成熟度口径漂移。
- 必须修成：
  - hero、banner、footnote 三者统一使用同一口径：
    - `project_chain = verified runtime`
    - `order / fulfillment = read-corridor continuation`
    - `milestone/submit / inspection/submit / dispute/open = shell / handoff`
    - `ratingEntryState / disputeWithdrawState = boundary-only`
- 完成定义：
  - 页面任意可见总述区都不能与 freeze maturity 分层冲突
  - 同一页面内不再同时出现“只读续接”与“完整已通”两套表述

### 4.3 修复项 C: `project_chain` handoff 补齐 `canOpenProjectPool`

- 问题：
  - freeze 允许 `canOpenProjectPool`
  - `Server` 已返回 `canOpenProjectPool`
  - Flutter workbench 当前没有“项目展示 / 项目池” handoff 节点
- 必须修成：
  - 当 `project_chain.canOpenProjectPool == true` 时，workbench 必须出现
    已冻结允许的“项目展示 / 项目池” handoff
  - 必须复用当前既有 page carrier：
    - `ExhibitionRoutes.showcase`
    或当前 repo 中已存在的同等 public project pool/showcase carrier
  - 不得新发明 route family
- 完成定义：
  - `canOpenProjectPool` 不再是 contract 里有、Server 里有、workbench UI 没入口
  - project_chain 至少包含：
    - 最近项目承接
    - 发布项目
    - 项目展示 / 项目池 handoff

### 4.4 修复项 D: `project_chain` 节点状态语义收正

- 问题：
  - 当前 `project_chain` 节点状态还没完全把“成熟资产”和“handoff 资产”说清。
- 必须修成：
  - `最近项目承接`
    只说明 recent project continuation
  - `发布项目`
    只说明 create handoff
  - `项目展示 / 项目池`
    只说明 public pool handoff
  - 三者都不得被写成第二项目控制台
- 完成定义：
  - `project_chain` 的三类 node description、stateLabel、actionLabel
    不再互相混义
  - owner truth page、public showcase、workbench summary 三者边界清晰

### 4.5 修复项 E: `order_chain` 容器文案降级到 read-corridor posture

- 问题：
  - 当前 `order_chain` 容器虽然节点是 continuation 结构，但页面整体仍容易被解读为
    “订单链已在 workbench 完整开放”。
- 必须修成：
  - `order_chain` summary 只能表达：
    - 当前承接的是最小 continuation container
    - `order/detail` 与 `contract/detail` 属于只读续接
    - `dispute/open` 目前只是后续 handoff position 的前置承接，不代表完整争议链已开放
- 完成定义：
  - `订单承接` 容器不再被任何 copy 写成“交易主链已闭环”
  - `争议开启` 文案不再暗示完整争议命令族已成立

### 4.6 修复项 F: `fulfillment_chain` 容器文案降级到 read-corridor posture

- 问题：
  - 当前 `fulfillment_chain` 容器仍容易把里程碑和验收后链写得过成熟。
- 必须修成：
  - `里程碑列表`
  - `验收详情`
    只表述 read-corridor continuation
  - `里程碑提交`
  - `验收提交`
    只表述 shell / handoff position
  - 不得出现“已形成完整履约写链”暗示
- 完成定义：
  - `履约承接` 容器文案与 freeze 的 read / shell 分层一致
  - `里程碑提交`、`验收提交` 的 copy 不再被写成 active command 已闭环

### 4.7 修复项 G: `extension_boundary` 文案只保留 boundary posture

- 问题：
  - `extension_boundary` 现在结构基本对，但必须保证后续收口不会回漂。
- 必须修成：
  - `合同详情`
  - `争议开启`
    只写 continuation
  - `评价入口边界`
  - `争议撤回边界`
    只写 boundary-only / frozen-state
  - 不得出现“待后续恢复即可开放”的乐观暗示
- 完成定义：
  - extension boundary 任一节点都不会被用户理解为“半开放业务子链”

### 4.8 修复项 H: BFF / Server workbench summary fail-closed 对齐

- 问题：
  - 当前 workbench 需要的是 truth alignment，不是凭 UI 自己修辞。
- 必须修成：
  - `Server` 继续保持四容器 summary 返回结构
  - 但不得虚构：
    - `activeOrderId`
    - `activeMilestoneId`
    - 其他当前不存在的 continuation anchor
  - `BFF` 继续只做 required record 校验与 app-facing envelope
  - 若上游缺字段，必须 fail-closed，而不是 UI 猜补
- 完成定义：
  - Package 1 期间不得为了“让页面更像已完成”而伪造 summary truth
  - workbench summary 仍由 `Server` 唯一决定

### 4.9 修复项 I: workbench 测试断言改成 truth-aligned 口径

- 问题：
  - 当前测试里有一部分还在把 workbench 当成“四容器都可承接到完整后链”的 happy path 容器。
- 必须修成：
  - workbench 相关测试优先断言：
    - 四容器结构存在
    - Package 1 文案不再虚高
    - `canOpenProjectPool` handoff 已落地
    - `rating / dispute withdraw` 仍为 frozen boundary
    - 冻结外 route 继续 unavailable
  - 不得在 Package 1 内新增对 Package 2-4 的 runtime 断言
- 完成定义：
  - 测试不再用错误成熟度倒逼实现回漂
  - workbench 测试只证明 Package 1 边界内的事实

## 5. Package 1 明确不做

- 不补 `activeOrderId`
- 不补 `activeMilestoneId`
- 不补 `order/detail / contract/detail / milestone/list / inspection/detail`
  的字段扩面
- 不补 `milestone/submit`
- 不补 `inspection/submit`
- 不补 `dispute/open`
  的 active command truth / surface / page closure
- 不清理 `order/create`
- 不清理 `contract/confirm`
- 不清理 `contract/amend`
- 不清理 `inspection/recheck`
- 不清理 `rating/submit`
- 不清理 `dispute/withdraw`
- 不清理 `my-project` 对 `ratings / disputes` 的越界投影
- 不引入 admin / governance / reporting / moderation console

## 6. Package 1 验收口径

- Package 1 只能按以下口径验收：
  1. `workbench` 页面可见表述与 mixed-maturity freeze 一致
  2. `project_chain.canOpenProjectPool` 已形成 handoff
  3. feature-status / hero / banner / footnote 口径一致
  4. `order_chain / fulfillment_chain / extension_boundary`
     不再被表述成 runtime 已闭环
  5. workbench 相关测试断言完成 truth-aligned 收正
- Package 1 明确不能按以下口径验收：
  - 订单链闭环
  - 履约链闭环
  - shell / handoff 命令链闭环
  - 冻结外命令族清理完成
  - admin 联动完成

## 7. Package 1 交付物

- 代码交付物只允许包括：
  - workbench summary / copy / node handoff alignment
  - `project pool/showcase` handoff 落地
  - 与此直接相关的最小 test update
- 回执必须至少说明：
  - 修改文件清单
  - 哪些 workbench 文案被降虚高
  - `canOpenProjectPool` 最终 handoff 到哪一个既有 route
  - 哪些 workbench 断言被改成 truth-aligned
  - 为什么本轮没有碰 Package 2 / 3 / 4

## 8. 当前裁决

- 当前正式允许：
  - 围绕本清单进入 `Package 1 / workbench truth alignment`
    的 bounded repair authoring
- 当前正式不允许：
  - 把本清单偷换成 Package 2
  - 把本清单偷换成 Package 3
  - 把本清单偷换成 Package 4
  - 把文案对齐偷换成交易主链实现 unlock

## 9. Next Unique Action

- 下一步唯一动作：
  - 按本清单收敛 `Package 1 / workbench truth alignment`
    的实际改动范围与执行顺序
