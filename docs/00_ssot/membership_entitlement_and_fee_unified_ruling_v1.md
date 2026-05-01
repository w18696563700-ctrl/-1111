---
owner: Codex 总控
status: frozen
purpose: Unify the current membership entitlement and platform service-fee discount ruling for review only, without unlocking contracts rewrite, runtime implementation, cloud write, or launch.
layer: L0 SSOT
freeze_date_local: 2026-05-01
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/platform_pricing_rules_master_v1.md
  - docs/00_ssot/my_building_v20_membership_entitlement_and_quota_rules_addendum.md
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_freeze_v1.md
  - docs/00_ssot/platform_pricing_runtime_drift_register_v1.md
  - docs/00_ssot/my_building_v20_paid_membership_implementation_prep_stage_gate_checklist_addendum.md
  - docs/00_ssot/my_building_v20_paid_membership_bounded_implementation_review_conclusion_addendum.md
  - docs/01_contracts/membership_entitlement_v1_contracts_addendum.md
  - docs/01_contracts/membership_direct_purchase_v1_contracts_addendum.md
  - docs/01_contracts/platform_pricing_contracts_master_v1.md
  - docs/02_backend/membership_entitlement_v1_backend_truth_addendum.md
  - docs/02_backend/platform_pricing_backend_truth_master_v1.md
  - docs/02_backend/exhibition_trade_task_membership_service_fee_linkage_server_truth_addendum_v1.md
  - docs/03_bff/membership_entitlement_v1_bff_surface_addendum.md
  - docs/03_bff/membership_direct_purchase_v1_bff_surface_addendum.md
  - docs/04_frontend/membership_entitlement_v1_frontend_surface_addendum.md
  - docs/04_frontend/membership_direct_purchase_v1_frontend_surface_addendum.md
  - docs/00_ssot/membership_old_fee_rate_drift_cleanup_day1_register_v1.md
  - apps/server/src/modules/membership/membership.catalog.ts
  - apps/server/src/modules/membership/membership.controller.ts
  - apps/server/src/modules/membership/membership.module.ts
  - apps/server/src/modules/p0_pay/p0-pay.state.ts
  - apps/server/src/modules/p0_pay/p0-pay-service-fee-rate.policy.ts
  - apps/bff/src/routes/profile/app-profile-read.controller.ts
  - apps/bff/src/routes/profile/profile-membership.read-model.ts
  - apps/bff/src/routes/profile/profile-membership.service.ts
  - apps/bff/src/routes/exhibition_p0_pay/exhibition-p0-pay.read-model.ts
  - apps/mobile/lib/features/profile/data/profile_membership_consumer_layer.dart
  - apps/mobile/lib/features/profile/presentation/profile_membership_pages.dart
  - apps/mobile/lib/features/profile/presentation/profile_feature_status_copy.dart
  - apps/mobile/lib/features/profile/presentation/profile_visible_copy.dart
---

# 《会员权益与费率统一裁决 V1》

## 1. 当前对象

- 本文当前只服务于：
  - 统一 `membership` 的正式档位口径
  - 统一当前正式平台服务费优惠口径
  - 把旧 `2.5% / 2.0% / 1.5%` 口径降级为历史候选或 deprecated planning 参数
  - 冻结当前最小闭环、保留不开通项、扩展位与阶段门禁
- 本文当前不代表：
  - contracts 重写完成
  - Server / BFF / Flutter 实现解锁
  - 云端改造授权
  - runtime payment pass
  - launch approval

## 2. 总裁决

### 2.0 Day 2 alignment freeze

自本轮 Day 2 起，本文正式承接 `membership_old_fee_rate_drift_cleanup_day1_register_v1.md` 的边界裁决：

1. `membership` 当前只处理读态与展示真相。
2. 旧 `3% / 2.5% / 2.0% / 1.5%` 不得作为当前正式展示或计算依据。
3. `rateBand`、`candidateDisplayRateBand` 等旧字段如为兼容保留，只能承载 deprecated / legacy / null 语义，不得承载固定百分比正式规则。
4. `membershipStatus` 继续只表示 Package 1 organization membership truth，不得表达 paid-membership truth。
5. 付费会员展示必须优先使用 `paidMembershipTier` 与服务费优惠说明。

证据：

- [membership_old_fee_rate_drift_cleanup_day1_register_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/membership_old_fee_rate_drift_cleanup_day1_register_v1.md:1)
- [my_building_v20_membership_minimum_package_boundary_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_membership_minimum_package_boundary_addendum.md:239)
- [identity_permission_minimum_contracts.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/identity_permission_minimum_contracts.yaml:88)

### 2.1 正式规则 owner

当前正式规则 owner 固定如下：

| 对象 | 当前唯一 owner | 证据 |
|---|---|---|
| 会员档位结构 | `docs/00_ssot/my_building_v20_membership_entitlement_and_quota_rules_addendum.md` | [档位冻结](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_membership_entitlement_and_quota_rules_addendum.md:123) |
| 平台服务费基础规则 | `docs/00_ssot/platform_pricing_rules_master_v1.md` | [基础收费规则](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/platform_pricing_rules_master_v1.md:236) |
| 会员服务费折扣与封顶 | `docs/00_ssot/platform_pricing_rules_master_v1.md` + `docs/02_backend/platform_pricing_backend_truth_master_v1.md` | [L0 折扣冻结](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/platform_pricing_rules_master_v1.md:251) [L3 discount truth](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/platform_pricing_backend_truth_master_v1.md:420) |
| membership 读态 package | `membership_entitlement_v1_*` 文书链 | [L2 contracts](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/membership_entitlement_v1_contracts_addendum.md:66) [L3 backend](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/membership_entitlement_v1_backend_truth_addendum.md:165) [L3 BFF](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/membership_entitlement_v1_bff_surface_addendum.md:81) [L3 frontend](/Users/wangweiwei/Desktop/展览装修之家总控/docs/04_frontend/membership_entitlement_v1_frontend_surface_addendum.md:121) |
| 会员直购执行包 | `membership_direct_purchase_v1_*` 文书链，但当前只保留、不启用 | [L2 direct purchase](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/membership_direct_purchase_v1_contracts_addendum.md:26) [L3 BFF direct purchase](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/membership_direct_purchase_v1_bff_surface_addendum.md:18) [L3 frontend direct purchase](/Users/wangweiwei/Desktop/展览装修之家总控/docs/04_frontend/membership_direct_purchase_v1_frontend_surface_addendum.md:11) |

### 2.2 当前正式会员档位

当前正式会员档位固定为：

1. 免费认证版
2. 标准会员
3. 专业会员

当前明确只保留为预留位，不启用：

1. KA
2. 旗舰

证据：

- `当前正式接受以下 3 档结构：免费认证版 / 标准会员 / 专业会员`。[档位冻结](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_membership_entitlement_and_quota_rules_addendum.md:123)
- `旗舰 / KA 版` 当前只做战略预留，不进入首轮冻结。[KA 预留](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_membership_entitlement_and_quota_rules_addendum.md:129)

### 2.3 当前正式服务费优惠

当前正式服务费优惠固定为：

| 档位 | 正式规则 | 备注 | 证据 |
|---|---|---|---|
| 免费认证版 | `baseFeeAmount × 1.0` | 无会员折扣，当前封顶仍为 `4000` | [L3 discount truth](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/platform_pricing_backend_truth_master_v1.md:424) |
| 标准会员 | `baseFeeAmount × 0.9` | 单项目封顶 `3600` | [L0 折扣冻结](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/platform_pricing_rules_master_v1.md:251) [L3 discount truth](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/platform_pricing_backend_truth_master_v1.md:426) |
| 专业会员 | `baseFeeAmount × 0.8` | 单项目封顶 `3200` | [L0 折扣冻结](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/platform_pricing_rules_master_v1.md:253) [L3 discount truth](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/platform_pricing_backend_truth_master_v1.md:427) |
| KA / 旗舰 | 当前不启用 | 不进入当前正式 discount mapping | [L3 not enabled](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/platform_pricing_backend_truth_master_v1.md:429) |

当前正式解释同时固定如下：

1. 折扣作用对象是现行平台定价母规则计算出的 `baseFeeAmount`。
2. 折扣不作用于 `200` 或 `4000`。
3. 当前正式收费主线不再把会员优惠表达为“成交金额固定百分比”。

证据：

- `会员折扣只作用于最终平台服务费`，且不作用于 `200 元项目真实性诚意金` 与 `4000 元竞标服务费预授权额度`。[L0 折扣边界](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/platform_pricing_rules_master_v1.md:246)
- `折扣只作用于 baseFeeAmount，不作用于 200 或 4000`。[L3 折扣边界](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/platform_pricing_backend_truth_master_v1.md:418)
- `platformServiceFeeCalculation` 当前最小字段已经固定为 `baseFeeAmount / membershipDiscountRate / capAmount / finalFeeAmount`，而不是旧 `feeRate` 主模型。[pricing contracts](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/platform_pricing_contracts_master_v1.md:475)

## 3. 旧口径统一降级裁决

### 3.1 统一降级规则

自本文生效用于评审起，以下旧口径统一降级为：

- 历史候选参数
- deprecated planning 参数
- 迁移参考

不得再被解释成：

- 当前正式服务费规则
- 当前正式展示口径
- 当前正式计算依据
- 当前正式折扣表达方式

统一降级对象：

1. `标准会员 = 固定 2.5%`
2. `专业会员 = 固定 2.0%`
3. `KA / 旗舰 = 固定 1.5%`
4. `基础平台服务费 = 固定 3%`
5. `membership tier -> feeRate` 是当前唯一优惠表达方式

### 3.2 文书层 superseded / deprecated 证据

| 文件 | 当前状态 | 旧口径 | 统一裁决后的读取方式 | 证据 |
|---|---|---|---|---|
| `docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_freeze_v1.md` | `superseded` | `3% / 2.5% / 2.0% / 1.5%` | 只保留为历史记录和迁移参考 | [Supersede Note](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_freeze_v1.md:19) |
| `docs/02_backend/exhibition_trade_task_membership_service_fee_linkage_server_truth_addendum_v1.md` | `superseded` | `feeRate 2.5% / 2.0% / 1.5%` | 只保留为历史 `P0-Pay feeRate linkage` 对照件 | [superseded backend truth](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/exhibition_trade_task_membership_service_fee_linkage_server_truth_addendum_v1.md:21) |
| `docs/00_ssot/my_building_v20_membership_entitlement_and_quota_rules_addendum.md` | `frozen` | `2.5% / 2.0% / 1.5%` | 只允许继续视为 `candidate commercial parameter`，不得当当前正式费率 | [candidate appendix](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_membership_entitlement_and_quota_rules_addendum.md:339) |
| `docs/01_contracts/exhibition_trade_task_membership_service_fee_linkage_contracts_addendum_v1.md` | `frozen` 历史字段件 | `standard 2.5% / professional 2.0% / ka/flagship 1.5%` | 只保留字段演进与迁移参考，不得据此解释现行收费主线 | [旧 L2 总裁决](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/exhibition_trade_task_membership_service_fee_linkage_contracts_addendum_v1.md:19) [旧 tier 语义](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/exhibition_trade_task_membership_service_fee_linkage_contracts_addendum_v1.md:95) |

### 3.3 当前正式反向证据

当前正式反向证据固定如下：

1. 当前唯一收费母文件已经改成 `platform_pricing_rules_master_v1.md`。[L0 owner](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_freeze_v1.md:23)
2. 当前唯一收费 `L3 backend truth` 已经改成 `platform_pricing_backend_truth_master_v1.md`。[L3 owner](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/exhibition_trade_task_membership_service_fee_linkage_server_truth_addendum_v1.md:25)
3. 当前正式 `L2 contracts` 已经改成 `membershipDiscountRate / capAmount / finalFeeAmount` 口径。[pricing contracts](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/platform_pricing_contracts_master_v1.md:475)

## 4. Day 1 证据矩阵 V1

| 类别 | 结论 | 判定 | 证据 |
|---|---|---|---|
| 正式规则 | 当前正式会员档位 = `免费认证版 / 标准会员 / 专业会员` | 正式 | [档位冻结](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_membership_entitlement_and_quota_rules_addendum.md:123) |
| 正式规则 | `KA / 旗舰` 仅预留、不启用 | 预留 | [KA 预留](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_membership_entitlement_and_quota_rules_addendum.md:168) |
| 正式规则 | `标准 = 9 折 / 3600` | 正式 | [L0 折扣冻结](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/platform_pricing_rules_master_v1.md:251) [L3 discount truth](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/platform_pricing_backend_truth_master_v1.md:426) |
| 正式规则 | `专业 = 8 折 / 3200` | 正式 | [L0 折扣冻结](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/platform_pricing_rules_master_v1.md:253) [L3 discount truth](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/platform_pricing_backend_truth_master_v1.md:427) |
| 正式规则 | 折扣作用于 `baseFeeAmount`，不是成交金额固定百分比 | 正式 | [L3 折扣边界](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/platform_pricing_backend_truth_master_v1.md:418) [pricing contracts](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/platform_pricing_contracts_master_v1.md:475) |
| deprecated | `2.5% / 2.0% / 1.5%` 不是当前正式费率 | deprecated | [candidate appendix](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_membership_entitlement_and_quota_rules_addendum.md:343) [旧件 superseded](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/exhibition_trade_task_membership_service_fee_linkage_server_truth_addendum_v1.md:35) |
| 预留 | `membership_direct_purchase_v1_*` 当前只保留执行包，不等于开通 | 预留 | [L2 direct purchase](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/membership_direct_purchase_v1_contracts_addendum.md:35) [frontend direct purchase](/Users/wangweiwei/Desktop/展览装修之家总控/docs/04_frontend/membership_direct_purchase_v1_frontend_surface_addendum.md:11) |
| Unknown | 取消执行链是否已有独立正式 route family | Unknown / Evidence Missing | 当前只发现 entitlement package 明确不批 `membership cancellation` 写命令，未发现 dedicated cancel package。[entitlement no write](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/membership_entitlement_v1_contracts_addendum.md:71) |
| Unknown | 曝光/排序/商机提醒/席位的精确数值和算法 | Unknown / Evidence Missing | 当前只冻结类型和摘要，不冻结 rich workflow 或精确参数。[quota freeze](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_membership_entitlement_and_quota_rules_addendum.md:215) |

## 5. Day 1 旧口径残留点台账 V1

### 5.1 文书残留

| 分类 | 文件 | 残留内容 | 当前判定 |
|---|---|---|---|
| SSOT 残留 | `docs/00_ssot/my_building_v20_membership_entitlement_and_quota_rules_addendum.md` | `3.0% / 2.5% / 2.0% / 1.5%` 仍在 candidate appendix | 候选参数，可保留为历史 planning 参考，但不得当当前正式展示或计算依据 |
| SSOT 历史件 | `docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_freeze_v1.md` | 旧 `固定 3% -> 会员分层费率联动` | `superseded` 历史件 |
| Contracts 历史件 | `docs/01_contracts/exhibition_trade_task_membership_service_fee_linkage_contracts_addendum_v1.md` | 旧 `2.5% / 2.0% / 1.5%` 字段语义 | 历史字段参考，不是当前 owner |
| Backend 历史件 | `docs/02_backend/exhibition_trade_task_membership_service_fee_linkage_server_truth_addendum_v1.md` | 旧 `feeRate` 模型 | `superseded` 历史件 |
| Frontend/BFF 边界件 | `membership_entitlement_v1_*` | 仍允许 `candidate commercial display copy` | 允许受限展示，但不得被解释为正式折扣真相 |

### 5.2 Server 残留

| 文件 | 残留内容 | 当前判定 |
|---|---|---|
| [apps/server/src/modules/membership/membership.catalog.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/membership/membership.catalog.ts:27) | `rateBand = 当前规划费率档 3.0% / 2.5% / 2.0%`，`candidateDisplayRateBand = 3.0% / 2.5% / 2.0%` | 展示残留；只能继续被视为 candidate display，不得被视为当前正式折扣 |
| [apps/server/src/modules/p0_pay/p0-pay-service-fee-rate.policy.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/p0_pay/p0-pay-service-fee-rate.policy.ts:52) | `TIER_POLICIES` 仍有 `2.5% / 2.0% / 1.5%` feeRate 快照 | 运行时旧口径残留；与当前 `discountRate/cap` 双轨并存 |
| [apps/server/src/modules/p0_pay/p0-pay.state.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/p0_pay/p0-pay.state.ts:8) | `P0_PAY_DEFAULT_SERVICE_FEE_RATE = 0.03` | 运行时旧默认费率残留 |

### 5.3 BFF 残留

| 文件 | 残留内容 | 当前判定 |
|---|---|---|
| [apps/bff/src/routes/exhibition_p0_pay/exhibition-p0-pay.read-model.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/exhibition_p0_pay/exhibition-p0-pay.read-model.ts:55) | 仍直接承接 `feeRate` | 旧收费字段承接残留 |
| [apps/bff/src/routes/profile/profile-membership.read-model.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/profile/profile-membership.read-model.ts:37) | 仍承接 `rateBand / candidateDisplayRateBand` | 候选展示字段承接残留，不是 BFF 自有真相 |
| [docs/03_bff/membership_entitlement_v1_bff_surface_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/membership_entitlement_v1_bff_surface_addendum.md:157) | 仍允许 `candidate commercial display copy` | 允许受限展示，但不允许被改写为 final discount truth |

### 5.4 Flutter 残留

| 文件 | 残留内容 | 当前判定 |
|---|---|---|
| [apps/mobile/lib/features/profile/data/profile_membership_consumer_layer.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/profile/data/profile_membership_consumer_layer.dart:89) | 仍消费 `candidateDisplayPrice / candidateDisplayRateBand` | 候选展示字段消费残留 |
| [apps/mobile/lib/features/profile/presentation/profile_membership_pages.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/profile/presentation/profile_membership_pages.dart:496) | 升级引导页仍展示 `candidateDisplayPrice / candidateDisplayRateBand` | 候选展示 UI 残留 |
| [docs/04_frontend/membership_entitlement_v1_frontend_surface_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/04_frontend/membership_entitlement_v1_frontend_surface_addendum.md:143) | 仍允许 `candidate commercial display copy` | 允许受限展示，但不等于正式价格/折扣展示 |

### 5.5 Unknown / Evidence Missing

| 项目 | 当前判定 | 证据 |
|---|---|---|
| Flutter 文档或代码里是否仍直接写出 `2.5% / 2.0% / 1.5%` 字面量 | Unknown / Evidence Missing | 当前已确认 candidate 字段存在，但在本轮核查范围内未拿到完整云上实时返回样本；只能确认“展示能力存在”，不能确认“线上当前一定正在显示该字面值” |
| membership 取消链是否已有独立 execution 文书 | Unknown / Evidence Missing | 当前未发现 dedicated cancel contract / backend truth / BFF surface / frontend surface |

## 6. 会员权益保留策略

当前正式保留的权益与页面固定如下：

| 权益 / 页面 | 当前状态 | 证据 |
|---|---|---|
| 曝光 | 保留 | [免费/标准/专业权益](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_membership_entitlement_and_quota_rules_addendum.md:137) |
| 排序 | 保留 | [免费/标准/专业权益](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_membership_entitlement_and_quota_rules_addendum.md:138) |
| 商机提醒 | 保留 | [标准权益](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_membership_entitlement_and_quota_rules_addendum.md:152) [quota type](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_membership_entitlement_and_quota_rules_addendum.md:208) |
| 人工撮合 | 保留 | [专业权益](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_membership_entitlement_and_quota_rules_addendum.md:164) [quota type](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_membership_entitlement_and_quota_rules_addendum.md:210) |
| 客服优先 | 保留 | [专业权益](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_membership_entitlement_and_quota_rules_addendum.md:165) |
| quota 摘要 | 保留 | [entitlement family](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_membership_entitlement_and_quota_rules_addendum.md:179) |
| 成员席位 | 保留 | [quota type](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_membership_entitlement_and_quota_rules_addendum.md:211) |
| 会员状态页 | 保留 | [frontend page family](/Users/wangweiwei/Desktop/展览装修之家总控/docs/04_frontend/membership_entitlement_v1_frontend_surface_addendum.md:126) |
| 权益说明页 | 保留 | [frontend page family](/Users/wangweiwei/Desktop/展览装修之家总控/docs/04_frontend/membership_entitlement_v1_frontend_surface_addendum.md:127) |
| 配额说明页 | 保留 | [frontend page family](/Users/wangweiwei/Desktop/展览装修之家总控/docs/04_frontend/membership_entitlement_v1_frontend_surface_addendum.md:128) |
| 升级引导页 | 保留 | [frontend page family](/Users/wangweiwei/Desktop/展览装修之家总控/docs/04_frontend/membership_entitlement_v1_frontend_surface_addendum.md:129) |

当前不冻结精确数值或算法的项目统一记为：

- Unknown / Evidence Missing：曝光权重具体值
- Unknown / Evidence Missing：排序算法细则
- Unknown / Evidence Missing：商机提醒具体次数
- Unknown / Evidence Missing：人工撮合具体次数
- Unknown / Evidence Missing：席位具体数量

依据：当前只冻结权益类型、摘要字段与 quota 类型，不冻结 rich workflow 或精确运营参数。[quota freeze](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_membership_entitlement_and_quota_rules_addendum.md:217)

## 7. 当前最小闭环

当前最小闭环固定为：

1. 会员读态
2. 会员说明
3. 升级引导
4. 标准 / 专业两档折扣说明
5. 不做购买支付实现

最小闭环当前 legal surface：

- `GET /api/app/profile/membership/current`
- `GET /api/app/profile/membership/explanation`
- `GET /api/app/profile/membership/quota`
- `GET /api/app/profile/membership/upgrade-guide`

证据：

- contracts 冻结这 4 个 GET，且本轮不批准 `membership purchase / membership renewal / membership cancellation / membership order creation / payment confirmation`。[L2 entitlement](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/membership_entitlement_v1_contracts_addendum.md:66)
- backend 当前不批准 end-user purchase flow，membership cycle 只允许作为 read truth。[L3 backend truth](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/membership_entitlement_v1_backend_truth_addendum.md:165)
- BFF 当前只转发这 4 个 membership GET。[BFF controller](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/profile/app-profile-read.controller.ts:94) [BFF service](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/profile/profile-membership.service.ts:25)
- Flutter 当前只消费这 4 条 canonical path，并只完成 4 个二级页。[mobile paths](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/profile/data/profile_membership_consumer_layer.dart:10) [mobile pages](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/profile/presentation/profile_membership_pages.dart:496)
- 功能状态文案已明确：`当前不承接购买、续费、下单、支付与账单闭环。`。[mobile feature status](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/profile/presentation/profile_feature_status_copy.dart:169)

## 8. 需要保留但暂不开通

当前必须保留但暂不开通：

1. 会员直购
2. 续费
3. 取消
4. 退款
5. 发票
6. KA / 旗舰
7. 复杂 quota rich workflow

对应证据：

- `membership_direct_purchase_v1_*` 当前只冻结 execution-oriented package，但不代表 runtime payment pass、implementation unlock 或 launch approval。[L2 direct purchase](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/membership_direct_purchase_v1_contracts_addendum.md:35) [frontend direct purchase](/Users/wangweiwei/Desktop/展览装修之家总控/docs/04_frontend/membership_direct_purchase_v1_frontend_surface_addendum.md:45)
- entitlement package 明确不批准 `membership renewal / membership cancellation / payment confirmation` 写命令。[L2 entitlement](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/membership_entitlement_v1_contracts_addendum.md:71)
- invoice / settlement 在 entitlement package 与 direct purchase refund contract 中都不被冻结为当前结果真相。[backend non-goals](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/membership_entitlement_v1_backend_truth_addendum.md:235) [refund non-goals](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/membership_direct_purchase_v1_contracts_addendum.md:193)
- `KA / 旗舰` 当前不正式启用。[L3 not enabled](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/platform_pricing_backend_truth_master_v1.md:429)
- 复杂 quota rich workflow 当前不冻结，只保留类型与摘要。[quota freeze](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_membership_entitlement_and_quota_rules_addendum.md:217)

## 9. 后续扩展位

后续扩展位当前允许保留，但不得视为本轮启用：

1. 会员购买
2. 支付生效
3. 续费
4. 订单
5. 发票
6. 精准曝光 / 排序算法
7. 会员服务费联动 `P0-Pay`

说明：

- 会员购买 / 支付生效 / 续费 / 订单：由 `membership_direct_purchase_v1_*` 文书链保留执行位，但当前不启用 runtime。[L2 direct purchase](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/membership_direct_purchase_v1_contracts_addendum.md:62)
- 发票：当前未开通，需单独后续 package。当前证据只够支持“未冻结”。[refund non-goals](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/membership_direct_purchase_v1_contracts_addendum.md:193)
- 精准曝光 / 排序算法：当前未冻结精确参数，需单独后续规则包。Unknown / Evidence Missing。
- 会员服务费联动 `P0-Pay`：当前存在 runtime 漂移与历史 `feeRate` 残留，不能直接当现成能力接入。[runtime drift](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/platform_pricing_runtime_drift_register_v1.md:94)

## 10. 阶段门禁

当前阶段门禁固定如下：

| 项目 | 当前是否允许 | 证据 |
|---|---:|---|
| 改文书 | 仅允许本文所属 `SSOT` 统一裁决 | 本文当前对象；且下一阶段仅允许 docs-only prep。[stage gate](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_paid_membership_implementation_prep_stage_gate_checklist_addendum.md:152) |
| 改 contracts | 否 | [No-Go for implementation execution](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_paid_membership_implementation_prep_stage_gate_checklist_addendum.md:154) |
| 改 Server | 否 | [No-Go for implementation execution](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_paid_membership_implementation_prep_stage_gate_checklist_addendum.md:155) |
| 改 BFF | 否 | [No-Go for implementation execution](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_paid_membership_implementation_prep_stage_gate_checklist_addendum.md:155) |
| 改 Flutter | 否 | [No-Go for implementation execution](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_paid_membership_implementation_prep_stage_gate_checklist_addendum.md:155) |
| integration | 否 | [No-Go for integration](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_paid_membership_implementation_prep_stage_gate_checklist_addendum.md:156) |
| release-prep | 否 | [No-Go for release-prep](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_paid_membership_implementation_prep_stage_gate_checklist_addendum.md:157) |
| launch approval | 否 | [No-Go for launch approval](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_paid_membership_implementation_prep_stage_gate_checklist_addendum.md:158) |
| 动云端 | 否 | 当前只发现 docs-only `implementation-prep` 进入许可，未发现任何 cloud write 或 runtime unlock 证据。[stage gate](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_paid_membership_implementation_prep_stage_gate_checklist_addendum.md:152) [No-Go](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_paid_membership_implementation_prep_stage_gate_checklist_addendum.md:154) |

补充说明：

- 当前 `V2.0 paid membership bounded implementation = 已在当前 frozen package 内成立`，但这不等于 integration、release-prep、launch approval 或 closure 已通过。[bounded implementation conclusion](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_paid_membership_bounded_implementation_review_conclusion_addendum.md:35) [No-Go](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_paid_membership_bounded_implementation_review_conclusion_addendum.md:65)

## 11. 下一轮唯一动作

下一轮唯一动作固定为：

- 基于本文裁决结果，发起“旧口径清漂移方案评审”，只讨论：
  - 哪些文书需要把 `2.5% / 2.0% / 1.5%` 明确改成 deprecated 标注
  - 哪些 Server / BFF / Flutter 展示与字段需要按正式口径对齐
  - 清漂移顺序与阶段门禁

当前不得直接进入：

- 会员购买实现
- 会员支付实现
- runtime route 开通
- Server / BFF / Flutter 改造执行

## 12. 审校结论

当前审校结论固定为：

1. `9 折 / 8 折 / 3600 / 3200` 的正式 owner 已唯一化。
2. `2.5% / 2.0% / 1.5%` 已被统一降级为历史候选或 deprecated planning 参数。
3. `membership` 当前仍是读态最小闭环，不是购买支付主线。
4. `membership_direct_purchase_v1_*` 当前属于保留执行包，不等于开通。
5. 本文只统一规则口径，不顺带解锁任何实现层。
