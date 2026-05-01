---
owner: Codex 总控
status: frozen
layer: L0 Day 1 Boundary Register
created_at: 2026-05-01
scope: membership direct purchase, membership order/Admin minimum query, and P0-Pay membership discount linkage boundary freeze
purpose: Freeze the three-stage execution boundary before implementation. This file does not unlock code, contracts, cloud deployment, payment execution, DB migration, Admin write operations, or P0-Pay runtime enablement.
inputs_canonical:
  - docs/00_ssot/membership_entitlement_and_fee_unified_ruling_v1.md
  - docs/00_ssot/membership_read_surface_alignment_stage_gate_checklist_v2.md
  - docs/00_ssot/membership_direct_purchase_rules_v1.md
  - docs/00_ssot/platform_pricing_rules_master_v1.md
  - docs/01_contracts/membership_entitlement_v1_contracts_addendum.md
  - docs/01_contracts/membership_direct_purchase_v1_contracts_addendum.md
  - docs/01_contracts/exhibition_trade_task_membership_service_fee_linkage_contracts_addendum_v1.md
  - apps/server/src/modules/membership/membership.controller.ts
  - apps/server/src/modules/membership/membership.module.ts
  - apps/server/src/modules/p0_pay/p0-pay-service-fee-rate.policy.ts
  - apps/bff/src/routes/profile/app-profile-read.controller.ts
  - apps/bff/src/routes/profile/profile-membership.service.ts
  - apps/admin/src/core/server/admin-api-client.ts
---

# 会员直购 / Admin 查询 / P0-Pay 联动 Day 1 边界冻结台账 V1

## 0. Day 1 总裁决

- 是否允许进入会员直购实现：`No-Go until Day 2 SSOT and Day 3 contracts are frozen`
- 是否允许进入会员订单状态与 Admin 最小查询实现：`No-Go until membership order truth is frozen`
- 是否允许进入 P0-Pay 9 折 / 8 折服务费联动实现：`No-Go until new platform-pricing contract snapshot replaces old feeRate owner`
- 是否允许沿用 `2.5% / 2.0% / 1.5%`：`No`
- 是否允许本轮把 KA / 旗舰放入正式启用：`No`
- 是否允许本轮动云端 / DB / 支付通道：`No`
- Day 1 是否允许进入 Day 2：`Yes`

Day 1 只冻结边界，不施工。Day 2 必须先产出新的 SSOT 主裁决，才能进入 contracts / code。

## 1. 会员购买与 P0-Pay 联动总边界表

| 开发线 | 当前目标 | 真相 owner | BFF 边界 | Flutter / Admin 边界 | 当前状态 | 证据 |
|---|---|---|---|---|---|---|
| 会员直购最小闭环 | purchase-offers、order-create、pay-init、order-result、支付成功后权益写入 | `Server.membership` + `Server.payment` | 只做 app-facing 聚合、转发、错误归一；不得生成第二订单状态机 | Flutter 只发起请求和展示结果；不得本地确认权益生效 | 有 L0 draft 与 L2 contracts；未解锁 backend/BFF/frontend/runtime 实现 | [membership_direct_purchase_rules_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/membership_direct_purchase_rules_v1.md:97), [membership_direct_purchase_v1_contracts_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/membership_direct_purchase_v1_contracts_addendum.md:58) |
| 会员订单状态与 Admin 最小查询 | 用户侧订单状态只读；Admin 会员订单/会员状态只读 | `Server.membership` + `Server.admin` | App BFF 只暴露用户侧订单状态；Admin 不经 BFF | Admin 只能查，不得手工开通、退款、改支付状态 | 当前缺 dedicated Admin membership API/client/page | [apps/admin/src/core/server/admin-api-client.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/admin/src/core/server/admin-api-client.ts:1), [apps/server/src/modules/membership/membership.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/membership/membership.controller.ts:6) |
| P0-Pay 9 折 / 8 折服务费联动 | 按 `baseFeeAmount × 0.9 / 0.8` 计算最终平台服务费，并保存折扣快照 | `Server.pricing` + `Server.p0_pay` + `Server.membership` | 只透传 Server summary；不得计算折扣 | Flutter 只展示 Server 返回的折扣前后金额与快照 | 当前代码存在新旧双轨：合同确认已有 `baseFeeAmount / membershipDiscountRate / capAmount / finalFeeAmount`，但 authorization requirement 仍有旧 `feeRate` 分层 | [platform_pricing_rules_master_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/platform_pricing_rules_master_v1.md:244), [p0-pay-service-fee-rate.policy.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/p0_pay/p0-pay-service-fee-rate.policy.ts:52), [p0-pay-service-fee-rate.policy.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/p0_pay/p0-pay-service-fee-rate.policy.ts:119) |

## 2. 三阶段门禁表

| 阶段 | 目标 | 前置门禁 | 必须通过 | 不得越权 |
|---|---|---|---|---|
| 阶段 A：会员直购最小闭环 | 从套餐 offer 到支付成功后权益生效 | Day 2 SSOT、Day 3 contracts、Server order/payment/entitlement 状态机设计 | 订单状态、支付状态、权益状态三者分离；回调幂等；支付成功不等于权益已生效 | 不做续费、取消、退款完整流、发票、KA / 旗舰 |
| 阶段 B：会员订单状态与 Admin 最小查询 | 用户和 Admin 可只读查询会员订单和会员状态 | 阶段 A 的订单/权益 truth 已存在 | Admin 只能读；能定位异常订单；权限与审计边界清楚 | 不做手工开通、手工退款、改支付状态、改权益额度 |
| 阶段 C：P0-Pay 9 折 / 8 折联动 | P0-Pay 使用有效会员态计算服务费折扣 | 阶段 A 会员生效 truth、阶段 B Admin 可视性、新 platform-pricing contract snapshot | `baseFeeAmount × discountRate`；标准 `0.9 / 3600`；专业 `0.8 / 3200`；折扣快照可审计 | 不复活 `2.5% / 2.0% / 1.5%`；不启用 KA / 旗舰；不让 BFF/Flutter 自算 |

## 3. 不做项清单

| 不做项 | 当前判定 | 原因 / 证据 |
|---|---|---|
| 自动续费 | 暂不开通 | Direct purchase contracts 只冻结最小 purchase/order/pay-init/result/refund family，不授予 launch。[membership_direct_purchase_v1_contracts_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/membership_direct_purchase_v1_contracts_addendum.md:245) |
| 取消会员 | 暂不开通 / Evidence Missing | 当前未发现 dedicated cancel contract / backend truth / BFF surface / frontend surface。 |
| 退款完整运营流 | 暂不开通 | Direct purchase contracts 曾包含 refund apply/result 字段，但当前执行路径仍未解锁，Day 1 不扩大退款。[membership_direct_purchase_v1_contracts_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/membership_direct_purchase_v1_contracts_addendum.md:176) |
| 发票 | 暂不开通 | Direct purchase contract 明确不服务 invoice / tax full system。[membership_direct_purchase_v1_contracts_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/membership_direct_purchase_v1_contracts_addendum.md:49) |
| KA / 旗舰 | 仅预留 | 当前正式会员档位只启用免费认证版、标准、专业；KA / 旗舰不启用。[membership_entitlement_and_fee_unified_ruling_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/membership_entitlement_and_fee_unified_ruling_v1.md:87) |
| 曝光 / 排序算法实装 | 暂不开通 | 当前只保留权益类型与摘要，不冻结 rich workflow 或精确算法。[membership_entitlement_and_fee_unified_ruling_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/membership_entitlement_and_fee_unified_ruling_v1.md:245) |
| Admin 写操作 | 暂不开通 | Day 1 只允许 Admin 最小查询规划；当前 Admin 会员 API/client/page 缺失。[admin-api-client.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/admin/src/core/server/admin-api-client.ts:1) |
| 云端部署 / DB migration / 支付通道写入 | 暂不开通 | Day 1 只冻结边界；runtime tunnel 当前不可用，HTTP live evidence missing。 |

## 4. 旧口径回流风险台账

| 残留点 | 当前表现 | Day 1 归类 | 处理要求 | 证据 |
|---|---|---|---|---|
| P0-Pay 旧 L2 contracts | `standard 2.5% / professional 2.0% / ka/flagship 1.5%` | 必须清理 / superseded | Day 3 必须冻结新的 9 折 / 8 折 contract snapshot；旧 L2 只作迁移参考 | [exhibition_trade_task_membership_service_fee_linkage_contracts_addendum_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/exhibition_trade_task_membership_service_fee_linkage_contracts_addendum_v1.md:95) |
| P0-Pay Day 10 formal enablement | 曾写 `Go for authorization snapshot` 且目标是 `2.5% / 2.0% / 1.5%` | 必须清理 / superseded | 不得作为当前 P0-Pay 联动实施依据 | [exhibition_trade_task_membership_service_fee_linkage_day10_formal_enablement_gate_receipt_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_day10_formal_enablement_gate_receipt_v1.md:19) |
| Server P0-Pay authorization requirement | `TIER_POLICIES` 仍按 `feeRate` 输出 `3.0% / 2.5% / 2.0% / 1.5%` | 必须清理 | 后续 Server 实现必须改为 platform-pricing `baseFeeAmount / membershipDiscountRate / capAmount / finalFeeAmount` 快照，不再把 fixed feeRate 当当前折扣真相 | [p0-pay-service-fee-rate.policy.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/p0_pay/p0-pay-service-fee-rate.policy.ts:52) |
| Server P0-Pay final charge | 已出现 `baseFeeAmount / membershipDiscountRate / capAmount / finalFeeAmount` | 先保留 / 可复用 | 可作为阶段 C 的复用基础，但必须先统一 authorization snapshot 与 contracts | [p0-pay-service-fee-rate.policy.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/p0_pay/p0-pay-service-fee-rate.policy.ts:119), [p0-pay-contract-confirmation.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/p0_pay/p0-pay-contract-confirmation.service.ts:177) |
| Membership read/display | 已清漂移，旧候选字段不得展示旧固定费率 | 先保留 | 不回退；作为三阶段后续展示基础 | [membership_read_surface_alignment_stage_gate_checklist_v2.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/membership_read_surface_alignment_stage_gate_checklist_v2.md:18) |
| Runtime HTTP 证据 | 本地 `127.0.0.1:8080` 当前不可连 | Unknown / Evidence Missing | Day 13 前不得用 runtime 反推 truth；开启隧道后再做只读复核 | `curl http://127.0.0.1:8080/api/app/profile/membership/current -> connection refused` |

## 5. 必须新增 / 修改的接口、表、页面和门禁

| 对象 | 必须新增 / 修改 | 所属阶段 | 备注 |
|---|---|---|---|
| SSOT | 新增《会员直购与服务费联动实施裁决 v1》 | Day 2 | 承接本文，正式冻结三阶段执行口径 |
| Contracts / OpenAPI | 会员 offers、orders、pay-init、order-result、Admin query、P0-Pay discount snapshot | Day 3 | 旧 feeRate 字段只能兼容读，不得作当前 owner |
| Server DB / migration spec | membership order、payment linkage、entitlement activation、audit/idempotency | Day 4 | 先设计，后实施 |
| Server membership | order create、pay init、payment result、callback writeback | Day 5 | 权益生效必须由 Server 写入 |
| BFF profile membership | App-facing purchase 投影 | Day 6 | BFF 不持有状态机 |
| Flutter profile membership | 购买入口、套餐确认、支付跳转、结果页、订单状态 | Day 7 | 不展示旧固定百分比 |
| Server/Admin | membership order/status read-only API | Day 8 | 不开放写操作 |
| Admin Web | 会员订单列表/详情/会员状态只读 | Day 8 | 仅查询 |
| P0-Pay Server pricing | 9 折 / 8 折联动与折扣快照 | Day 9-10 | 必须先清旧 feeRate owner |
| BFF/Flutter P0-Pay | 折扣 summary 只读展示 | Day 11 | Flutter 不自算 |
| Runtime gate | 受控联调、回滚点、沙箱/测试通道 | Day 12-13 | 不触发真实生产支付 |

## 6. Day 1 验收

| 验收项 | 结果 | 证据 |
|---|---|---|
| 三条开发线 owner 清晰 | Pass | 本文第 1 节 |
| 旧费率明确禁止 | Pass | 本文第 4 节；统一裁决已禁止 `2.5% / 2.0% / 1.5%` 当前化。[membership_entitlement_and_fee_unified_ruling_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/membership_entitlement_and_fee_unified_ruling_v1.md:128) |
| 购买、Admin、P0-Pay 先后关系写死 | Pass | 本文第 2 节 |
| Admin 最小查询未扩大为运营后台 | Pass | 本文第 3 节 |
| P0-Pay 未提前实现 | Pass | 本文件只冻结边界，不修改代码 |
| Runtime 缺证显式标注 | Pass | 本文第 4 节 |

## 7. Day 2 唯一动作

起草并冻结：

`docs/00_ssot/membership_purchase_admin_p0pay_implementation_ruling_v1.md`

该文只能冻结 SSOT 主裁决，不得直接改 contracts、Server、BFF、Flutter、Admin、DB 或云端。
