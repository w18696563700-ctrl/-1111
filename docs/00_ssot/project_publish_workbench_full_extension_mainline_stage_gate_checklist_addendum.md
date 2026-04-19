---
owner: Codex 总控
status: active
purpose: Submit the stage gate checklist for the full publish-project workbench and extension mainline, so the next round can perform a fresh asset inventory and boundary freeze without reusing the narrower order-intake slice as the main object.
layer: L0 SSOT
based_on:
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_ruling_addendum.md
  - docs/00_ssot/workbench_private_board_boundary_freeze_addendum.md
  - docs/00_ssot/workbench_private_board_closure_conclusion_addendum.md
  - docs/00_ssot/project_publish_board_boundary_freeze_addendum.md
  - docs/00_ssot/project_publish_board_closure_conclusion_addendum.md
  - docs/00_ssot/three_board_mainline_integration_release_review_conclusion_addendum.md
  - docs/04_frontend/flutter_screen_map.md
  - apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model_sections.dart
  - docs/00_ssot/gate_register_v1.md
freeze_date_local: 2026-04-11
---

# 《发布项目工作台及延伸功能全链 阶段门禁核查表》

## 1. Scope

- 当前对象：
  - `发布项目工作台及延伸功能全链`
- 本门禁只服务于：
  - 判断当前是否允许进入
    `fresh 现有资产盘点 + 边界冻结 authoring`
- 本门禁不代表：
  - direct implementation
  - integration
  - `release-prep`
  - production release

## 2. Passed Gates

- 架构边界 gate：
  - passed
  - `Flutter App -> BFF -> Server` 唯一主通道不变
  - 当前对象仍在 `exhibition` building 内，不需要新壳
- workbench 页面定义 gate：
  - passed
  - 当前截图对应的页面定义已存在，并明确冻结为四个容器：
    - `项目承接`
    - `订单承接`
    - `履约承接`
    - `边界能力`
- 已有私域摘要封板 gate：
  - passed
  - `工作台私域` 作为摘要页与 handoff 页的最小封板已成立
- 已有发布走廊基础 gate：
  - passed
  - `项目发布` 最小 publish corridor 已有独立封板与 development-stage 基础
- 已有三板块最小主链基础 gate：
  - passed
  - `项目发布工作台 / 项目发布 / 项目展示`
    的最小 development-stage canonical mainline 已有既有验证结论
- 对象纠偏 gate：
  - passed
  - 当前已正式纠偏：
    - `订单承接与履约承接主链`
      只是从属子链
    - 当前真实主线是：
      `发布项目工作台及延伸功能全链`

## 3. Failed Gates

- full-object asset inventory gate：
  - failed
  - 当前还没有针对新对象正式冻结：
    - 四容器页面资产
    - 各节点现状
    - BFF / Server active source 对应情况
    - 已通 / 未通 / 受控 / 冻结 / 伪闭环
- full-object truth boundary gate：
  - failed
  - 当前还没有正式冻结：
    - `project_chain`
    - `order_chain`
    - `fulfillment_chain`
    - `extension_boundary`
    在同一主线对象中的职责边界
- node-admission gate：
  - failed
  - 当前还没有正式冻结：
    - 哪些节点属于当前对象的真实纳入范围
    - 哪些节点只是边界说明
    - 哪些节点保持显式排除
- subchain-position gate：
  - failed
  - 当前还没有把：
    - `订单承接与履约承接主链`
    与
    - `发布项目工作台及延伸功能全链`
    的主从关系写进新的完整资产盘点
- direct implementation gate：
  - failed
- integration gate：
  - failed
- `release-prep` gate：
  - failed
- production release gate：
  - failed

## 4. Veto Gates

- 不得把 `工作台私域已封板` 偷换成：
  - `发布项目工作台及延伸功能全链已完成`
- 不得把 `项目发布最小走廊已封板` 偷换成：
  - 当前整张工作台及其全部延伸点已闭环
- 不得再把：
  - `订单承接与履约承接主链`
  偷换成当前真实主线对象
- 不得跳过 fresh 资产盘点，直接进入 truth / contract / dispatch / implementation
- 不得在未重新冻结 full-object boundary 前，把任何页面壳或 route shell 写成 runtime fully open
- 不得把支付、结算、发票、税务、治理后台、历史列表后台
  偷扩进当前对象
- 不得绕过 `BFF` 让 Flutter 直连 `Server`
- 不得在 Flutter 或 `BFF` 私造第二状态机

## 5. Stage Go / No-Go Decision

- `Go` for：
  - `发布项目工作台及延伸功能全链`
    的 fresh 现有资产盘点
  - 后续 bounded truth authoring 准备
- `No-Go` for：
  - direct implementation
  - integration verification
  - `release-prep`
  - production release
  - scope expansion beyond the current corrected mainline object

## 6. Current Gate Meaning

- 当前允许的含义：
  - 可以重新按整张工作台的四容器与可见节点，
    做一次新的主线级资产盘点
  - 可以重新判断：
    - 哪些是已有资产
    - 哪些是当前受控
    - 哪些是冻结边界
    - 哪些是未开放
    - 哪些只是从属子链
- 当前不允许的含义：
  - 不能直接沿旧 `order / fulfillment` 子链继续写实现链文书
  - 不能把旧 stop-line 子链重新混成当前执行入口
  - 不能直接改代码
  - 不能直接把当前截图解释成“全工作台仅剩收尾”

## 7. Next Unique Action

- 下一轮唯一动作：
  - 输出《发布项目工作台及延伸功能全链 现有资产盘点单》
