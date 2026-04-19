---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the successor business bridge blueprint for
  `Bid -> Award -> Order Conversion -> Contract Seed` so the current repo can
  advance from `Project publish/showcase/bid submit` into the trading bridge
  without polluting `Order` truth, reopening the workbench object, or silently
  skipping future publish/public gates.
layer: L0 SSOT
freeze_date_local: 2026-04-12
based_on:
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_maintenance_only_follow_up_judgment_addendum.md
  - docs/00_ssot/project_showcase_detail_bid_board_boundary_freeze_addendum.md
  - docs/00_ssot/exhibition_showcase_bid_flow_v11_upgrade_addendum.md
  - docs/00_ssot/project_showcase_publish_alignment_truth_freeze_addendum.md
---

# 《Bid -> Award -> Order Conversion -> Contract Seed 业务桥接蓝图》

## 1. Freeze Judgment

- 当前真源已经足够支撑本轮合法冻结，结论为：
  - `Freeze Go`
- 当前不进入实现，不进入补丁，不进入 runtime 操作。
- 当前冻结对象不是 `发布项目工作台` 重开，也不是 `Order` 家族重写。
- 当前冻结对象是：
  - `Bid -> Award -> Order Conversion -> Contract Seed`
    这段交易桥接蓝图

## 2. Why Current Truth Is Sufficient

- 当前 repo 已有：
  - `Project` 私域写链真相
  - `Project Showcase` 公域读链真相
  - `Bid submit` 最小提交真相
  - `Order / Contract / Milestone / Inspection / Rating / Dispute`
    的下游最小真相或 continuation
- 当前真正缺的不是前后两端对象不存在，而是：
  - `Bid` 与 `Order` 之间没有正式桥接对象
  - `定标`、`落选理由`、`转单`、`合同种子`
    没有被一个合法中间层承接
- 因此本轮冻结可以直接建立在当前 repo 事实之上，不会因为证据不足而翻案。

## 3. Unique Bridge Object

### 3.1 Selected object name

- 当前唯一桥接对象正式命名为：
  - `BidAward`

### 3.2 Why `BidAward` and not `WinnerDecision` or `Order`

- 不选 `Order`：
  - `Order` 只能承接正式交易实例
  - 不能同时承接：
    - 中标决定
    - 落选处理
    - 选择依据
    - 操作人
    - 定标时间
- 不选 `WinnerDecision`：
  - `WinnerDecision` 只表达“决策”
  - 不足以自然承接：
    - 中标后转单
    - 落选留痕
    - 合同种子生成前态
- 选 `BidAward`：
  - 与当前 repo 已有的 `project.state = awarded / converted_to_order`
    语义最一致
  - 可以同时承接：
    - winner truth
    - loser disposition
    - order conversion precursor

### 3.3 Formal definition

- `BidAward` 是 `Bid` 与 `Order` 之间唯一合法桥接真相对象。
- 一个 `Project` 在当前阶段最多只允许一个有效 `BidAward`。
- 一个 `Order` 只能由一个 `BidAward` 转化生成。
- 当前阶段 `BidAward` 的最小承责为：
  - 记录哪一个 `Bid` 被选中
  - 记录哪些 `Bid` 落选以及落选理由
  - 记录谁在何时完成定标
  - 记录何时已完成 `order conversion`

### 3.4 Minimal truth fields

- `bidAwardId`
- `projectId`
- `winningBidId`
- `buyerOrganizationId`
- `supplierOrganizationId`
- `decisionReasonCode`
- `decisionReasonText`
- `decidedByActorId`
- `decidedAt`
- `convertedOrderId`
- `convertedAt`
- `state`

### 3.5 Minimal states

- `awarded`
- `converted_to_order`

## 4. Launch Permission Boundary

### 4.1 Who may initiate award

- 当前阶段只有 `Project` 所属 buyer 侧组织可以发起比选/定标。
- 发起人必须同时满足：
  - 当前 session 已验证
  - 当前 organization scope 有效
  - 当前 organization = `project.organizationId`
  - 当前角色属于：
    - `buyer_admin`
    - `buyer_member(scoped)`

### 4.2 Who may not initiate award

- `supplier_admin`
- `supplier_member(scoped)`
- `platform_reviewer`
- `platform_super_admin`

### 4.3 Why platform does not directly award in current phase

- 平台在当前阶段保留：
  - `publish 前门禁 / 公域前门禁`
  - 审计 / reviewer 能力
- 但 `award` 不是平台代 buyer 做业务选择。
- 否则会把：
  - 平台治理
  - buyer 商业决策
  混成一个状态机。

## 5. Losing Bid Handling and Audit

### 5.1 Frozen minimum loser rule

- 当前阶段不允许“静默落选”。
- 每个未中标 `Bid` 都必须有最小 disposition 留痕。

### 5.2 Minimum loser record

- `bidId`
- `result = lost`
- `reasonCode`
- `reasonText`
- `decidedByActorId`
- `decidedAt`
- `bidAwardId`

### 5.3 Frozen responsibility

- loser disposition 是 `BidAward` 的子事实，不是 `Order` 字段。
- 当前阶段至少要保证：
  - Server 有留痕
  - 后续 app-facing 可以稳定读取“为什么没中”
- 当前阶段不强制先开完整 buyer compare console，
  但必须先把 loser truth 留下来。

### 5.4 Audit rule

- `BidAward` 及 loser disposition 都属于必须审计动作。
- 审计至少记录：
  - actor
  - role
  - projectId
  - winningBidId
  - loser bid ids
  - reason summary
  - decidedAt

## 6. Bid -> Order Mapping and State Transition

### 6.1 Preconditions

- `project.state = published`
- `winning bid.state = submitted`
- 当前 `Project` 尚无有效 `BidAward`
- 当前 `Project` 尚未 `converted_to_order`

### 6.2 Transition order

- 当前冻结顺序固定为：
  1. buyer 发起 `BidAward`
  2. `BidAward.state = awarded`
  3. 同步落 loser disposition
  4. 从 `BidAward` 生成 `Order`
  5. `BidAward.state = converted_to_order`
  6. `Project.state = converted_to_order`

### 6.3 Bid -> Order field mapping

- `order.projectId <- bidAward.projectId`
- `order.bidId <- bidAward.winningBidId`
- `order.buyerOrganizationId <- project.organizationId`
- `order.supplierOrganizationId <- winningBid.organizationId`
- `order.title <- project.title`
- `order.totalAmount <- winningBid.quoteAmount`

### 6.4 Frozen order state for current phase

- 当前阶段 `Order` 创建后直接进入：
  - `active`
- 这样做不是满分语义，而是当前 repo 下游 continuation 的最稳兼容选项。
- 当前 repo 的：
  - `contract/detail`
  - `contract/confirm`
  - `contract/amend`
  - `milestone/list`
  - `inspection/detail`
  都已经围绕 `active order` 形成最小后半链，
  当前桥接蓝图不得把这条兼容链打断。

## 7. Contract Seed Timing

### 7.1 Single frozen answer

- `contract seed` 必须在 `order create` 时同步生成。

### 7.2 Why synchronous seed is required

- 如果 `Order` 创建后没有同步 `contract seed`，
  当前 repo 已闭合的：
  - `contract/detail`
  - `contract/confirm`
  - `contract/amend`
  将失去起点。
- 因此当前阶段不接受：
  - 先有 order
  - 之后另找时机再生合同种子

### 7.3 Minimal seed semantics

- 当前阶段 `contract seed` 只负责：
  - 让合同链有最小正式起点
  - 形成 `pending_confirm` 前态
- 当前阶段不代表：
  - 电子签已成立
  - 完整合同工作区已成立
  - PDF 文件流已完整闭环

### 7.4 Frozen seed state

- `contract.state = pending_confirm`

## 8. Reserved Hooks For Publish Gate And Public Visibility Gate

### 8.1 Current factual baseline

- 当前 repo 的 `project publish` 真实门禁只有：
  - buyer role
  - organization scope
  - certification approved
  - `draft -> submitted -> published` 生命周期

### 8.2 Reserved hook 1

- 必须预留：
  - `ProjectPublishPrecheckHook`
- 挂点固定在：
  - `submitted -> published`
    之前

### 8.3 Reserved hook 2

- 必须预留：
  - `ProjectPublicVisibilityGate`
- 挂点固定在：
  - `project/list`
  - `project/detail`
    的公域可见性判断中

### 8.4 Frozen meaning

- 当前桥接蓝图必须承认：
  - 以后项目能否进公域，不应只由 `publish` 按钮决定
- 但当前阶段先不实现重审核系统。
- 当前阶段只冻结：
  - 上游门必须有挂点
  - 后续不得因为先补桥而把门禁彻底焊死

## 9. Current-open and Deferred Lists

### 9.1 Current-open in this blueprint

- `BidAward`
- loser disposition
- `BidAward -> Order conversion`
- synchronous `contract seed`
- 相关最小 app-facing continuation

### 9.2 Adjacent bid hardening that remains necessary

- 当前必须承认，完整高质量交易入口还缺：
  - `seat`
  - `bid package completeness`
- 但这两项不在本蓝图首包内。
- 本蓝图只冻结桥接层，不把 `Bid intake` 一口气扩成重系统。

### 9.3 Explicitly deferred

- 多轮议价
- 复杂评分模型
- 复杂支付担保
- 分账
- 电子签
- 重型风控
- 完整合同工作区
- 完整履约 ERP
- 完整 rating workspace
- 完整 dispute workspace

## 10. Risks This Blueprint Is Solving

- 防止把 `Award` 直接污染进 `Order`
- 防止把 loser 处理丢成黑洞
- 防止 `Bid submit` 被误判成已经形成交易闭环
- 防止后半链对象继续孤立存在而没有合法前桥
- 防止后续再回头补 `publish gate` 时翻案

## 11. Final Ruling

- 当前系统更接近：
  - 前半链方向正确
  - 后半链对象已有雏形
  - 中间 `Bid -> Order` 交易桥接层缺失
- 本轮正式裁决：
  - `BidAward` 是当前唯一合法桥接对象
  - `Order` 不得兼任定标真相
  - `contract seed` 必须随 `order create` 同步生成
  - `publish 前门禁 / 公域前门禁` 必须在蓝图层预留挂点

## 12. Next Unique Action

- 下一步唯一动作固定为：
  - 输出《BidAward bridge implementation stage gate checklist》
  - 目标对象限定为：
    - `BidAward`
    - loser disposition
    - `order conversion`
    - `contract seed`
  - 不得顺手扩到：
    - `seat`
    - `bid package completeness`
    - 支付
    - 分账
    - 电子签
    - 重型审核与风控
