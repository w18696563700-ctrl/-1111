---
owner: Codex 总控
status: active
purpose: Correct the screenshot-derived mainline misread, freezing that the real follow-up mainline is the full publish-project workbench and its direct downstream extension capabilities rather than the narrower order-intake and fulfillment slice alone.
layer: L0 SSOT
freeze_date_local: 2026-04-11
based_on:
  - docs/00_ssot/post_project_showcase_filter_and_project_create_form_refactor_next_bounded_object_ruling_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_stop_line_reentry_gate_path_addendum.md
  - docs/00_ssot/workbench_private_board_boundary_freeze_addendum.md
  - docs/00_ssot/workbench_private_board_closure_conclusion_addendum.md
  - docs/00_ssot/project_publish_board_boundary_freeze_addendum.md
  - docs/00_ssot/project_publish_board_closure_conclusion_addendum.md
  - docs/00_ssot/three_board_mainline_integration_release_review_conclusion_addendum.md
  - docs/04_frontend/flutter_screen_map.md
  - apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model_sections.dart
---

# 《发布项目工作台及延伸功能全链 主线纠偏改判单》

## 1. Scope

- 本改判单只回答三件事：
  - 基于当前工作台截图，真正的主线对象到底是什么
  - 之前冻结出来的 `订单承接与履约承接主链` 应如何重新定位
  - 当前下一轮唯一动作应该回到哪一步
- 本改判单不代表：
  - direct implementation
  - integration
  - `release-prep`
  - production release

## 2. 纠偏依据

- 当前截图对应的不是单一 `order / fulfillment` 子链页面，而是完整的
  `发布项目工作台` 私域承接页。
- 当前页面定义直接写明了四个容器，而不是两个容器：
  - `项目承接`
  - `订单承接`
  - `履约承接`
  - `边界能力`
- 当前页面可见能力节点也不是只围绕 `order / fulfillment`：
  - `项目承接` 2 个节点：
    - `最近项目承接`
    - `发布项目`
  - `订单承接` 4 个节点：
    - `当前订单承接`
    - `订单详情`
    - `合同详情`
    - `争议开启`
  - `履约承接` 5 个节点：
    - `当前里程碑承接`
    - `里程碑列表`
    - `里程碑提交`
    - `验收详情`
    - `验收提交`
  - `边界能力` 4 个节点：
    - `合同详情`
    - `争议开启`
    - `评价入口边界`
    - `争议撤回边界`
- 因此当前截图导出的真实问题不是：
  - “订单承接与履约承接子链还差多少”
- 而是：
  - “发布项目工作台这张私域承接面及其直接延伸出去的能力全链还差多少”

## 3. 之前的误判

- 之前把当前截图里的阻断重点收缩成：
  - `订单承接与履约承接主链`
- 这个动作并非完全错误，但它只抓到了当前页面里的一个重要子集：
  - `order_chain`
  - `fulfillment_chain`
- 它漏掉了同一页面内同等级存在的：
  - `project_chain`
  - `extension_boundary`
- 也漏掉了“这张页面本身是总承接入口，而不是只为 order / fulfillment 服务”的事实。
- 因此当前正式纠偏结论是：
  - `订单承接与履约承接主链` 只能被理解为当前截图导出的从属子链对象
  - 不能再被理解为这条问题链的真实主线对象

## 4. 当前真实主线对象

- 当前真实主线正式改判为：
  - `发布项目工作台及延伸功能全链`
- 当前对象至少包含以下四块：
  1. `项目承接`
     - 最近项目承接
     - 发布项目入口
  2. `订单承接`
     - 当前订单承接
     - 订单详情
     - 合同详情
     - 争议开启
  3. `履约承接`
     - 当前里程碑承接
     - 里程碑列表
     - 里程碑提交
     - 验收详情
     - 验收提交
  4. `边界能力`
     - 合同详情续接
     - 争议开启续接
     - 评价入口边界
     - 争议撤回边界
- 当前对象的正式语义是：
  - 先完成 `发布项目工作台` 这张私域承接页的全量真义盘点
  - 再完成它直接 handoff 出去的下游功能链盘点与边界冻结
  - 而不是把其中一个子链提前抽出来替代整张工作台主线

## 5. 与既有冻结链的关系

- [workbench_private_board_boundary_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/workbench_private_board_boundary_freeze_addendum.md)
  和
  [workbench_private_board_closure_conclusion_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/workbench_private_board_closure_conclusion_addendum.md)
  只说明：
  - `工作台私域` 作为摘要页与 handoff 页的最小封板成立
- 它们不等于：
  - `发布项目工作台及延伸功能全链` 已经完成
- [project_publish_board_boundary_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/project_publish_board_boundary_freeze_addendum.md)
  和
  [project_publish_board_closure_conclusion_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/project_publish_board_closure_conclusion_addendum.md)
  只说明：
  - 当前最小 `项目发布` 走廊曾经做过独立封板
- 它们也不等于：
  - 当前 screenshot 所指向的整张私域工作台及所有延伸入口已经完整闭环
- [three_board_mainline_integration_release_review_conclusion_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/three_board_mainline_integration_release_review_conclusion_addendum.md)
  只验证了：
  - `项目发布工作台 / 项目发布 / 项目展示`
    的一个最小 development-stage canonical mainline
- 它明确没有通过：
  - 交易后链扩面
  - `order / contract / fulfillment / inspection / rating / dispute`
    的完整后续主链

## 6. `订单承接与履约承接主链` 的重新定位

- 当前正式重新定位如下：
  - `订单承接与履约承接主链`
    保留为当前截图导出的从属子链冻结资产
  - 它仍然是有效文书链
  - 但它不再代表：
    - 当前真实主线对象
    - 当前整张 `发布项目工作台` 的完成定义
- 当前必须明确：
  - 该子链当前仍保持其既有 `stop-line` 结论
  - 但这不再意味着：
    - 当前截图对应的完整主线已经被正确定义完毕

## 7. 当前阶段裁决

- 当前正式裁决如下：
  - `发布项目工作台及延伸功能全链`
    才是这条问题链的真实主线
  - 之前把主线锁成
    `订单承接与履约承接主链`
    的口径，当前正式纠偏
- 当前只允许进入：
  - 新对象的阶段门禁与现有资产盘点
- 当前仍然：
  - `No-Go for direct implementation`
  - `No-Go for integration`
  - `No-Go for release-prep`
  - `No-Go for production release`

## 8. Next Unique Action

- 下一轮唯一动作：
  - 提交《发布项目工作台及延伸功能全链 阶段门禁核查表》
