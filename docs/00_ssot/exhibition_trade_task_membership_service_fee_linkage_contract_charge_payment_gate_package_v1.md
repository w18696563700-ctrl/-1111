---
title: exhibition_trade_task_membership_service_fee_linkage_contract_charge_payment_gate_package_v1
owner: Codex 总控
status: frozen
layer: L0 Next Gate Package
updated_at: 2026-04-29
purpose: Open the next separated gate package for P0-Pay membership-tier service-fee contract final charge, payment initialization, and payment callback verification after authorization snapshot linkage passed.
inputs_canonical:
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_freeze_v1.md
  - docs/01_contracts/exhibition_trade_task_membership_service_fee_linkage_contracts_addendum_v1.md
  - docs/02_backend/exhibition_trade_task_membership_service_fee_linkage_server_truth_addendum_v1.md
  - docs/02_backend/exhibition_trade_task_membership_service_fee_linkage_persistence_migration_unlock_addendum_v1.md
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_final_verification_receipt_v1.md
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_day10_formal_enablement_gate_receipt_v1.md
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_day10a_controlled_sample_receipt_v1.md
---

# P0-Pay 会员分层服务费率合同扣费与支付门禁包 V1

## 0. 总裁决

- 当前是否允许继续使用会员分层 authorization snapshot 链路：`Go`
- 当前是否允许自动放开支付初始化：`No-Go`
- 当前是否允许自动放开 payment callback：`No-Go`
- 当前是否允许自动放开合同确认最终扣费：`No-Go`
- 当前是否允许进入本门禁包：`Go`
- 本门禁包性质：`separated verification gate, not implementation auto-unlock`
- 下一轮唯一动作：先做只读差距核查，确认 payment init / callback / contract final charge 是否已经完整消费 locked authorization snapshot。

核心原因：

1. Day 9 / Day 10A 只证明 fee requirement 与 authorization snapshot 可以按会员等级生成。
2. 本轮尚未证明支付初始化、支付回调、合同确认最终扣费会完整复用锁定费率。
3. 支付与扣费属于资金链路，必须单独门禁，不得跟随 authorization snapshot 自动放行。

## 1. 当前最小闭环

已完成且可作为本门禁输入的最小闭环：

| 环节 | 当前结论 | 证据 |
|---|---|---|
| Server 读取工厂组织会员等级 | Pass | Day 9 / Day 10A runtime 样本 |
| Server 计算会员分层费率 | Pass | `standard / professional / ka / flagship` 均有样本 |
| Server 保存 authorization snapshot | Pass | 四档 authorization 均为 `pending_authorization` |
| BFF 只读投影 fee fields | Pass | p0-pay summary 已返回 fee snapshot |
| Flutter 展示动态费率 | Pass locally | P0-Pay Flutter targeted analyze/test 通过 |
| 支付初始化 | No-Go | 未触发，未验证 |
| payment callback | No-Go | 未触发，未验证 |
| 合同确认最终扣费 | No-Go | 未触发，未验证 |

## 2. 本门禁只做什么

本门禁包只允许验证和冻结以下内容：

1. `authorize-init` 是否只使用已存在 authorization snapshot。
2. 支付初始化是否不重新计算会员等级和费率。
3. payment order / transaction 是否携带或可回溯 locked fee snapshot。
4. payment callback 是否幂等、可审计，且不覆盖 feeRate。
5. 合同确认最终扣费是否按 `finalConfirmedAmount * locked feeRate` 计算。
6. 最终 charge 是否保存与 authorization 一致的 fee source、tier snapshot、rule version、snapshot hash。
7. BFF / Flutter 是否只读展示最终扣费结果，不参与计算。
8. 受控 runtime 样本是否不触发真实外部支付扣款。

## 3. 本门禁不做什么

本门禁包不允许直接放开：

1. 真实 Alipay / WeChat 资金扣款。
2. 公开生产流量。
3. 钱包、余额、资金池、结算、发票、财务后台。
4. P1 履约保证金。
5. 活动费率、封顶费率、后台配置费率。
6. Flutter 本地计算最终服务费。
7. BFF 本地计算或兜底生成 feeRate。
8. 合同确认时重新读取会员等级。

## 4. 门禁核查项

| 门禁项 | 必须验证 | 当前裁决 |
|---|---|---|
| authorization snapshot source | `authorize-init` 只能读取已锁定 snapshot | Pending |
| payment init amount | 初始化金额必须来自 locked authorization amount | Pending |
| payment idempotency | 重试不得重复创建真实支付订单或覆盖 fee snapshot | Pending |
| callback idempotency | 重复 callback 不得重复确认、重复扣费或改写 feeRate | Pending |
| contract final amount | 最终服务费 = 合同确认金额 x locked feeRate | Pending |
| charge snapshot | charge 保存 feeRateSource / tier / ruleVersion / snapshotHash | Pending |
| BFF projection | 只读返回 authorization / charge 结果 | Pending |
| Flutter display | 只展示，不计算正式金额 | Pending |
| runtime safety | test-channel 或受控路径，不触发真实外部扣款 | Pending |

## 5. 串行关系

必须串行：

1. 只读差距核查。
2. Contracts / truth 差距冻结。
3. Server payment init / callback / charge 行为核查或修复。
4. BFF 只读投影核查或修复。
5. Flutter 展示核查或修复。
6. 受控 runtime 样本。
7. Go / No-Go 门禁。

不得并行越级：

| 禁止并行 | 原因 |
|---|---|
| 未核查 payment init 就触发支付 | 资金链路不可用猜测替代证据 |
| 未核查 callback 幂等就放开回调 | 可能重复确认或重复扣费 |
| 未核查合同最终扣费就启用扣款 | 最终金额可能与锁定费率不一致 |
| 未核查 BFF/Flutter 就公开展示 | 用户看到的金额可能与 Server 真相不一致 |

## 6. 验收标准

本门禁通过必须同时满足：

1. `authorize-init` 使用 locked authorization snapshot。
2. payment order / transaction 不自行计算会员费率。
3. callback 不覆盖 fee snapshot。
4. contract confirmation 不重新读取会员等级。
5. final charge 使用 locked feeRate 和 finalConfirmedAmount。
6. Server tests 覆盖 standard / professional / ka / flagship。
7. BFF tests 证明只读投影。
8. Flutter tests 证明不本地计算正式金额。
9. runtime 样本停留在受控路径，无真实外部扣款。
10. 有明确回滚路径。

## 7. 风险清单

| 风险 | 等级 | 处理 |
|---|---|---|
| 合同确认时重新读取会员等级 | P0 | 必须阻断 |
| callback 重复导致重复扣费 | P0 | 必须阻断 |
| payment init 使用旧 3% 或本地计算 | P0 | 必须阻断 |
| BFF 兜底生成 feeRate | P1 | 修复后才能进入 runtime |
| Flutter 残留固定 3% 文案 | P1 | 修复后才能进入公开展示 |
| OpenAPI / generated types 未同步 | P1 | 正式发布前补齐 |

## 8. 四类判断

| 判断 | 结论 | 原因 |
|---|---|---|
| 哪个更稳 | 单独开本门禁包 | 支付与扣费不能跟随 authorization snapshot 自动放行 |
| 哪个更省成本 | 先只读差距核查 | 避免未定位缺口就重写支付主线 |
| 哪个更适合当前阶段 | test-channel / controlled path 受控验证 | 既能验证链路，又不触发真实扣款 |
| 哪个风险更大 | 直接放开真实支付和合同扣费 | 金额、幂等、回调、审计任一失败都会进入资金风险 |

## 9. 需要保留但暂不开通

- 真实外部支付扣款。
- 公开生产流量。
- 自动合同扣费。
- 结算、发票、财务对账。
- 费率后台配置和活动费率。

## 10. 后续扩展位

- 真实支付沙箱。
- 支付渠道生产资质验证。
- 回调签名审计增强。
- 退款 / 释放 / 补扣。
- 会员费率封顶。
- 财务对账和发票。

## 11. 下一轮唯一动作

执行本门禁包的第一步：

只读核查 `authorize-init`、payment callback、contract final charge 当前实现是否完整复用 locked authorization snapshot；不得触发真实支付，不得修改云端数据。
