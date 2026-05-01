---
owner: Codex 总控
status: frozen
purpose: Freeze Day 1 read-only evidence register, old fee-rate drift ledger, and bounded change boundary for membership read/display truth alignment.
layer: L0 SSOT
freeze_date_local: 2026-05-01
scope:
  - membership read/display truth
  - old fee-rate drift register
  - current-round boundary table
out_of_scope:
  - membership purchase implementation
  - payment execution
  - P0-Pay runtime discount enablement
  - cloud write or deployment
---

# 会员旧费率口径清漂移 Day 1 台账 V1

## 0. 总裁决

本轮只处理 `membership` 的读态与展示真相：

- 正式会员服务费优惠只允许表达为 `baseFeeAmount × discount`。
- 标准会员为 `baseFeeAmount × 0.9`，单项目封顶 `3600`。
- 专业会员为 `baseFeeAmount × 0.8`，单项目封顶 `3200`。
- 免费认证版无会员折扣。
- `2.5% / 2.0% / 1.5%` 统一降级为 historical candidate / deprecated planning 参数。
- 本轮不打开购买、续费、取消、退款、发票、支付初始化、支付回调、P0-Pay 折扣 runtime enablement。

证据：

- [platform_pricing_rules_master_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/platform_pricing_rules_master_v1.md:232)
- [platform_pricing_backend_truth_master_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/platform_pricing_backend_truth_master_v1.md:416)
- [membership_entitlement_and_fee_unified_ruling_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/membership_entitlement_and_fee_unified_ruling_v1.md:1)

## 1. 本轮边界表

| 项目 | 本轮处理 | 本轮不处理 | Owner / 证据 |
|---|---|---|---|
| 会员档位 | 统一为 `免费认证版 / 标准会员 / 专业会员`，`KA / 旗舰` 仅预留 | 不新增 KA / 旗舰展示或计算 | [my_building_v20_membership_entitlement_and_quota_rules_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_membership_entitlement_and_quota_rules_addendum.md:123) |
| 服务费优惠 | 统一读态展示为 `baseFeeAmount × 0.9 / 0.8` | 不启用 P0-Pay runtime 会员折扣 | [platform_pricing_rules_master_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/platform_pricing_rules_master_v1.md:251) |
| 旧固定费率 | 清理正式展示感知 | 不删除历史 superseded 文书 | [exhibition_trade_task_membership_service_fee_linkage_freeze_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_freeze_v1.md:19) |
| 会员读态 | 对齐 `current / explanation / quota / upgrade-guide` | 不新增写命令 | [membership_entitlement_v1_contracts_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/membership_entitlement_v1_contracts_addendum.md:64) |
| 会员购买 | 仅保留为后续入口条件 | 不实现 purchase-offers / orders / pay-init | [membership_direct_purchase_v1_contracts_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/membership_direct_purchase_v1_contracts_addendum.md:58) |
| 云端 runtime | 只读验证 | 不写云、不部署、不触发支付 | `GET /api/app/profile/membership/purchase-offers -> 404` |

## 2. 旧口径残留台账

| 层级 | 残留点 | 当前表现 | 归类 | 处理要求 |
|---|---|---|---|---|
| SSOT | `3% / 2.5% / 2.0% / 1.5%` | candidate appendix 仍保留 | 先保留 | 只能作为 historical candidate / deprecated planning 参数 |
| contracts | `rateBand` / `candidateDisplayRateBand` | 读态 contract 仍允许旧展示字段 | 必须清理 | 字段保留兼容，但不得承载固定百分比正式规则 |
| backend truth | 旧 `feeRate` linkage 文书 | 已标 superseded | 先保留 | 不得作为当前 owner |
| Server code | `membership.catalog.ts` | 输出 `3.0% / 2.5% / 2.0%` 展示文本 | 必须清理 | 改为服务费优惠说明，不输出旧固定费率承诺 |
| Server code | `p0-pay-service-fee-rate.policy.ts` | 仍有旧 feeRate 模型 | 先保留 | 本轮不碰 P0-Pay 执行链，只登记为下一阶段 blocker |
| BFF code | `profile-membership.read-model.ts` | 继续承接 `rateBand / candidateDisplayRateBand` | 必须清理 | 兼容读取，新增/优先使用服务费优惠说明 |
| BFF code | `exhibition-p0-pay.read-model.ts` | 继续承接 `feeRate` | 先保留 | 本轮不碰 P0-Pay 执行链，只登记为下一阶段 blocker |
| Flutter code | `profile_membership_pages.dart` | 展示候选价格/费率档位 | 必须清理 | 只展示非交易化服务费优惠说明 |
| Flutter code | `profile_page_support.dart` | `我的会员` 摘要可能弱化 paid-membership 与 organization membership 区分 | 必须清理 | 基于 `paidMembershipTier` 表达付费会员档位 |
| Runtime | `upgrade-guide` | 云上仍可能返回 `2.5% / 2.0%` | Unknown / Evidence Missing until verified | 只读验证，不以 runtime 覆盖正式 truth |

## 3. Day 1 通过条件

| 条件 | 结果 |
|---|---|
| 残留点覆盖 SSOT / contracts / backend truth / BFF / frontend / Server / Flutter / runtime | Pass |
| 每个旧口径都有 owner 或缺证标记 | Pass |
| purchase 保留包没有被纳入本轮实现 | Pass |
| P0-Pay 执行链没有被纳入本轮实现 | Pass |

## 4. 是否允许进入第 2 天

`Go`。

允许进入第 2 天的范围仅限：

- SSOT / contracts 口径补丁
- 会员读态字段语义对齐
- `membershipStatus` 与 `paidMembershipTier` 的边界补强

继续禁止：

- 会员购买实现
- 会员支付实现
- P0-Pay 会员折扣 runtime enablement
- 云端写入或部署
