---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the unique L5 Flutter consumption authority for the current platform
  pricing master, aligning the mobile charging corridor to the existing
  `project publish -> bid participation request -> bid submit` mainline while
  introducing only the minimum pricing-specific Flutter consumption surfaces,
  copy rules, route handoff, polling rules, and no-go boundaries required by
  the 200/4000/deal confirmation model.
layer: L5 Frontend
freeze_date_local: 2026-04-29
version: V1
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/platform_pricing_rules_master_v1.md
  - docs/01_contracts/platform_pricing_contracts_master_v1.md
  - docs/02_backend/platform_pricing_backend_truth_master_v1.md
  - docs/03_bff/platform_pricing_bff_surface_master_v1.md
  - docs/04_frontend/exhibition_trade_task_p0_pay_frontend_consumption_freeze_addendum_v1_3.md
  - docs/04_frontend/project_publish_workbench_full_extension_mainline_frontend_consumption_freeze_addendum.md
  - docs/04_frontend/bid_submit_five_step_business_flow_frontend_surface_addendum.md
  - docs/04_frontend/project_transaction_skeleton_p0_frontend_surface_addendum.md
  - docs/04_frontend/frontend_ssot.md
  - docs/04_frontend/flutter_screen_map.md
  - apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart
  - apps/mobile/lib/features/exhibition/data/services/p0_pay_consumer_service.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart
  - apps/mobile/lib/features/exhibition/presentation/presentation_support/p0_pay_bid_authorization_actions.dart
  - apps/mobile/lib/features/exhibition/presentation/presentation_support/p0_pay_bid_authorization_support.dart
  - apps/mobile/lib/features/exhibition/presentation/presentation_support/exhibition_payload_support.dart
---

# 《平台收费规则 L5 Flutter Consumption 母文件 V1》

## 0. 总裁决

当前收费 `L5 Flutter consumption` 正式重写完成。

本轮正式选择：

1. Flutter 继续只消费 `BFF /api/app/*`
2. 收费消费主链直接挂到现有 `project publish -> bid participation request -> bid submit` 主链
3. Flutter 不再以旧 `trade-task / inquiry deposit / service-fee-authorization / 3%` 语义作为当前收费消费 authority
4. Flutter 只消费 `pricing summary / 200 / 4000 / deal confirmation` 最小对象，不自建第二收费状态机

当前更稳的方案：

- 复用现有 `project create/publish`、`bid participation`、`bid/submit` 页面壳与私域承接，只把收费前置 gate 与只读摘要接进去

当前更省成本的方案：

- 不重起通用支付中心，不重起新的 trade-task 页面族，优先把当前收费消费冻结在现有项目页、竞标页和只读摘要页

当前阶段最适合的方案：

- 先冻结 Flutter 消费面，明确 `200 / 4000 / deal confirmation` 的页面文案、CTA 和轮询规则，真实支付 runtime 继续受 feature flag 控制

风险更大的方案：

- 继续保留旧 `发单诚意金 / 平台服务费预授权 / 3% 预计服务费 / trade-task` 页面口径，并在局部代码里偷偷接新收费主线

本文件生效后：

1. [exhibition_trade_task_p0_pay_frontend_consumption_freeze_addendum_v1_3.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/04_frontend/exhibition_trade_task_p0_pay_frontend_consumption_freeze_addendum_v1_3.md) 不再作为当前收费 `L5` 主文件
2. 当前收费 `L5` 只以本文件为准
3. 下一轮唯一动作切换为《阶段门禁核查表》并决定是否允许进入实现派工

## 1. Scope

本文件只冻结 `当前平台收费规则` 的 `L5 Flutter consumption`。

本文件覆盖：

1. `project publish` 前后的收费 gate Flutter 消费边界
2. `200 元项目真实性诚意金` 的下单、支付拉起、状态轮询与页面文案
3. `bid participation approved` 之后 `4000 元竞标服务费预授权额度` 的页面 handoff、冻结、状态、主动解冻文案
4. `bid/submit` 的收费准入消费边界
5. `deal confirmation` 的 Flutter 消费边界
6. `pricing summary` 的只读消费边界
7. `project detail / my project / workbench / message handoff` 的收费只读消费定位
8. controlled loading / blocker / failure / invalid-state / stale-copy 处理边界

本文件不覆盖：

1. `apps/mobile/**` 实现改动
2. BFF / Server 代码改动
3. 真实支付 SDK 最终集成
4. 云端联调
5. 通用支付中心
6. wallet / balance / coins / fund-pool
7. settlement / invoice / finance-admin
8. 履约保证金
9. 会员直购支付 runtime

## 2. 当前最小闭环

当前收费 `L5` 的最小闭环正式写死为：

1. `project create / save / submit` 保持现状
2. 发布前，Flutter 先消费 `GET /api/app/project/{projectId}/pricing-summary`
3. 若 `publishGateStatus` 不满足，则先完成：
   - `POST /api/app/project/{projectId}/authenticity-sincerity/orders`
   - `POST /api/app/project/{projectId}/authenticity-sincerity/orders/{orderId}/pay-init`
   - `GET /api/app/project/{projectId}/authenticity-sincerity/orders/{orderId}`
4. 只有 `200 元项目真实性诚意金` 完成并且 publish 命令成功后，Flutter 才显示发布成功
5. `bid participation request approve` 保持现状
6. `approved` 后如仍需收费 gate，Flutter 先消费：
   - `GET /api/app/project/bid-participation/thread/detail`
   - `POST /api/app/project/{projectId}/bid-service-fee-authorizations`
   - `POST /api/app/project/{projectId}/bid-service-fee-authorizations/{authorizationId}/freeze-init`
   - `GET /api/app/project/{projectId}/bid-service-fee-authorizations/{authorizationId}`
   - `POST /api/app/project/{projectId}/bid-service-fee-authorizations/{authorizationId}/release`
7. 只有 `authorizationStatus = frozen` 时，Flutter 才允许实际执行 `POST /api/app/bid/submit`
8. 达成唯一合作对象后，Flutter 通过 `deal-confirmations` 消费双向确认与扣费结果
9. `project detail / my project / workbench / message handoff` 只展示只读收费摘要，不本地改写收费真相

## 3. 需要保留但暂不开通

当前 Flutter 消费面必须保留但暂不开通：

1. 通用支付中心页面
2. wallet / balance / billing center
3. 履约保证金专属页面
4. 会员直购支付页面
5. 结算、发票、财务后台页面
6. 线下转账对账页面
7. Flutter 直连 `Server` 或自持回调结果

当前正式解释固定如下：

1. Flutter 不是资金真相 owner
2. Flutter 不是支付回调 owner
3. Flutter 不是第二收费状态机 owner
4. Flutter 不是通用 payment runtime 容器

## 4. 后续扩展位

后续扩展位正式保留：

1. `pricing summary` 在 `project detail / my project / workbench / message` 的统一卡片化
2. `deal confirmation detail` 的 richer 展开页
3. feature flag 打开后的真实支付通道联调
4. 当前旧 `p0_pay` Flutter 资产向新收费主线的实现迁移
5. 部署后的云端验真脚本与人工验收口径

## 5. Page / Route Carrier Matrix

| Flutter carrier | 当前收费定位 | 当前裁决 |
|---|---|---|
| `/exhibition/projects/create` | 项目发布与 `200` gate 主消费页 | 允许 |
| `/exhibition/project/bid-participation/thread/detail` 或同等 thread handoff | `approved` 后的 `4000` gate handoff | 允许 |
| `BidSubmitPage` / 继续竞标页 | `4000 frozen` 之后的实际竞标提交页 | 允许 |
| `project detail / my project detail` | 只读收费摘要与 handoff | 允许 |
| `/exhibition/workbench` | 只读收费摘要与 continuation handoff | 允许 |
| `Messages / bid thread detail` | 只读收费状态与 handoff | 允许 |
| `deal confirmation sheet/page` | 双向确认与扣费结果只读消费 | 允许 |

当前明确不新开：

1. `/exhibition/trade-task/*`
2. `/exhibition/payment-center/*`
3. `/exhibition/wallet/*`
4. `/profile/payment-runtime/*`
5. `/profile/membership-purchase/*`

## 6. Canonical API Consumption

Flutter 当前正式允许消费以下 `BFF` app-facing routes：

### 6.1 既有锚点

1. `POST /api/app/project/create`
2. `POST /api/app/project/save`
3. `POST /api/app/project/submit`
4. `POST /api/app/project/publish`
5. `POST /api/app/project/bid-participation/request`
6. `GET /api/app/project/bid-participation/thread/detail`
7. `GET /api/app/my/projects/{projectId}/bid-participation/pending`
8. `POST /api/app/my/projects/{projectId}/bid-participation/{requestId}/approve`
9. `POST /api/app/my/projects/{projectId}/bid-participation/{requestId}/reject`
10. `POST /api/app/bid/submit`

### 6.2 本轮新增的收费专属 routes

1. `GET /api/app/project/{projectId}/pricing-summary`
2. `POST /api/app/project/{projectId}/authenticity-sincerity/orders`
3. `POST /api/app/project/{projectId}/authenticity-sincerity/orders/{orderId}/pay-init`
4. `GET /api/app/project/{projectId}/authenticity-sincerity/orders/{orderId}`
5. `POST /api/app/project/{projectId}/bid-service-fee-authorizations`
6. `POST /api/app/project/{projectId}/bid-service-fee-authorizations/{authorizationId}/freeze-init`
7. `GET /api/app/project/{projectId}/bid-service-fee-authorizations/{authorizationId}`
8. `POST /api/app/project/{projectId}/bid-service-fee-authorizations/{authorizationId}/release`
9. `POST /api/app/project/{projectId}/deal-confirmations`
10. `GET /api/app/project/{projectId}/deal-confirmations/{dealConfirmationId}`

### 6.3 当前禁止作为现行 authority 的旧 routes

Flutter 当前不得继续把以下路由当成当前收费主线 authority：

1. `POST /api/app/exhibition/trade-tasks`
2. `POST /api/app/exhibition/trade-tasks/{taskId}/fixed-price-bids`
3. `POST /api/app/exhibition/trade-tasks/{taskId}/fixed-price-bids/{bidId}/service-fee-authorizations`
4. `POST /api/app/exhibition/trade-tasks/{taskId}/fixed-price-bids/{bidId}/service-fee-authorizations/{authorizationId}/authorize-init`
5. `GET /api/app/exhibition/trade-tasks/{taskId}/fixed-price-bids/{bidId}/service-fee-authorizations/{authorizationId}`
6. `POST /api/app/exhibition/trade-tasks/{taskId}/inquiry-deposit/orders`
7. `POST /api/app/exhibition/trade-tasks/{taskId}/inquiry-deposit/orders/{depositOrderId}/pay-init`
8. `GET /api/app/exhibition/trade-tasks/{taskId}/inquiry-deposit/orders/{depositOrderId}`
9. `GET /api/app/exhibition/trade-tasks/{taskId}/p0-pay-summary`

## 7. Project Publish Consumption

当前项目发布消费边界正式冻结为：

1. 项目发布仍以现有 `project create/save/submit/publish` 为主壳
2. Flutter 不再以 `trade-task type segmented control` 作为当前收费真相入口
3. `200 元` 的正式文案必须是：
   - `项目真实性诚意金`
4. Flutter 必须明确展示：
   - 该金额不是平台服务费
   - 该金额不是货款
   - 该金额不是履约保证金
   - 成交成立或按规则正式撤回后可原路退回
5. Flutter 在 `paid` 之前不得把项目显示为已正式发布成功

当前 Flutter 不得：

1. 把 `200 元` 写成 `发单诚意金`
2. 把 `200 元` 绑定到旧 `询价报价单` 专属语义
3. 在本地创建 `trade-task`
4. 在本地决定是否免收 `200`

## 8. Bid Participation And 4000 Gate Consumption

当前 `approved` 之后的消费边界正式冻结为：

1. `approved` 只表示准入通过，不等于可直接提交竞标
2. 若 `pricingGateRequired=true` 且 `pricingGateType=bid_service_fee_authorization_required`，Flutter 首个 CTA 必须先指向 `4000` 冻结 gate
3. `4000 元` 的正式文案必须是：
   - `竞标服务费预授权额度`
4. Flutter 必须明确展示：
   - 该金额不是货款
   - 该金额不是履约保证金
   - 该金额不是平台沉淀资金
   - 主动解冻即视为放弃本次竞标
5. Flutter 必须把主动解冻后的当前项目竞标入口视为关闭，直到上游重新放行

当前 Flutter 不得：

1. 把 `4000` 写成报名费、席位费、押金
2. 本地让 `approved` 直接跳 `bid_submit.open`
3. 本地允许解冻后继续沿旧竞标链路提交

## 9. Bid Submit Consumption

当前 `BidSubmitPage` 或同等继续竞标页，正式冻结如下：

1. 可以保留当前五步页面壳与材料上传走廊
2. 但其收费语义必须服从当前收费主线，而不是旧 `P0-Pay`
3. 最终实际竞标提交的唯一 authority 仍是：
   - `POST /api/app/bid/submit`
4. Flutter 只允许在 `authorizationStatus = frozen` 时开放最终提交
5. 若未完成 `4000` 冻结，页面必须表现为 blocker / handoff，而不是直接提交

当前 Flutter 不得再把以下旧语义当成现行收费消费：

1. `3% 平台服务费率`
2. `预计平台服务费`
3. `expectedQuotedAmount / expectedFeeRate / expectedAuthorizationAmount`
4. 在提交后再创建旧 `service-fee-authorization`
5. 通过旧 `fixed-price-bids` 直接承接当前竞标主提交链

## 10. Deal Confirmation Consumption

当前 `deal-confirmations` 的 Flutter 消费边界正式冻结为：

1. 只消费上游返回的：
   - `dealConfirmationId`
   - `dealStatus`
   - `selectedBidId`
   - `finalConfirmedAmount`
   - `platformServiceFeeCalculation`
   - `serviceFeeChargeStatus`
2. 只允许展示上游返回的：
   - `baseFeeAmount`
   - `membershipTierApplied`
   - `membershipDiscountRate`
   - `capAmount`
   - `finalFeeAmount`
3. `confirmed_deal` 是当前唯一正式成交成立状态

当前 Flutter 不得：

1. 本地重算最终平台服务费
2. 本地把单方确认显示为成交成立
3. 本地把未确认状态写成已扣费

## 11. Status Polling And Copy Boundary

当前 Flutter 的收费状态轮询边界正式冻结为：

1. `200` 与 `4000` 的状态只通过各自的 `GET .../{orderId|authorizationId}` 读取
2. Flutter 只读取 `BFF` 回读，不接收支付回调真相
3. 当前正式展示术语固定为：
   - `项目真实性诚意金`
   - `竞标服务费预授权额度`
4. 当前不得继续作为现行主文案展示：
   - `发单诚意金`
   - `平台服务费预授权`
   - `3%`
   - `预计服务费`

若 Flutter 仍收到旧字段或旧文案载荷：

1. 只能按历史兼容或 controlled unavailable 处理
2. 不得继续把旧字段提升为现行收费真相

## 12. 当前实现漂移证据

当前 repo 已存在以下旧收费 Flutter 资产，它们是实现迁移证据，不是当前 `L5` authority：

1. [project_create_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart:395)
   - 当前仍在 `create trade task -> inquiry deposit order -> pay-init -> poll` 旧链上工作
2. [exhibition_canonical_paths.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart:70)
   - 当前仍定义旧 `p0PayTradeTaskCreate / inquiryDeposit / p0PaySummary` routes
3. [p0_pay_consumer_service.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/services/p0_pay_consumer_service.dart:3)
   - 当前仍以 `ExhibitionP0PayConsumerActions` 消费旧 `trade-task` 主线
4. [p0_pay_bid_authorization_actions.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/presentation_support/p0_pay_bid_authorization_actions.dart:341)
   - 当前仍按 `quotedAmount / feeRate / estimatedFeeAmount` 生成旧授权命令
5. [p0_pay_bid_authorization_support.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/presentation_support/p0_pay_bid_authorization_support.dart:142)
   - 当前仍展示旧 `费率 / 预计服务费`
6. [exhibition_payload_support.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/presentation_support/exhibition_payload_support.dart:171)
   - 当前仍把轮询结果文案固定为旧 `发单诚意金 / 平台服务费预授权`

这些文件当前只能作为后续实现迁移清单，不得反向覆盖本文件。

## 13. 被正式降级的旧 Flutter 文书与条款

当前正式降级如下：

1. [exhibition_trade_task_p0_pay_frontend_consumption_freeze_addendum_v1_3.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/04_frontend/exhibition_trade_task_p0_pay_frontend_consumption_freeze_addendum_v1_3.md)
   - 旧 `trade-task / inquiry deposit / 3% / p0-pay summary` Flutter 消费主链
   - 当前只保留为 `historical migration baseline`
2. [project_publish_workbench_full_extension_mainline_frontend_consumption_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/04_frontend/project_publish_workbench_full_extension_mainline_frontend_consumption_freeze_addendum.md)
   - 继续保留其 publish workbench 主壳意义
   - 但不再拥有收费 gate authority
3. [bid_submit_five_step_business_flow_frontend_surface_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/04_frontend/bid_submit_five_step_business_flow_frontend_surface_addendum.md)
   - 继续保留其五步结构价值
   - 但其收费相关旧语义不再拥有 authority
4. [project_transaction_skeleton_p0_frontend_surface_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/04_frontend/project_transaction_skeleton_p0_frontend_surface_addendum.md)
   - 保留其交易骨架意义
   - 其中把 payment/deposit 一并排除的旧阶段性条款，当前只保留为历史阶段语义

## 14. Stage Conclusion

当前收费 `L5 Flutter consumption` 正式冻结为：

1. Flutter 只拥有收费主线的消费权
2. Flutter 不拥有任何收费业务真相
3. Flutter 不拥有任何第二收费状态机
4. 当前唯一收费 Flutter 主线是：
   - `pricing summary`
   - `200 元项目真实性诚意金`
   - `4000 元竞标服务费预授权额度`
   - `deal-confirmations`
   - 以及与之对接的 `project publish / bid participation / bid submit`
5. 下一轮唯一动作固定为：
   - 提交《阶段门禁核查表》，决定是否允许进入实现派工
