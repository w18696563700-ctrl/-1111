# P0-Pay 会员折扣联动施工设计 v1

## 0. 总裁决

- 本设计只处理 P0-Pay 服务费折扣联动，不解锁会员购买、退款、发票、续费、KA / 旗舰。
- Server 是唯一计算 owner；BFF 只透出 Server summary；Flutter 只展示，不自算。
- 当前正式会员折扣只允许两档：标准会员 9 折，专业会员 8 折。
- 折扣作用对象是 `baseFeeAmount`，不是成交金额固定百分比。
- `feeRate` 字段只作为旧 contracts / command 兼容载体，不再作为正式展示或计算依据。

## 1. 正式公式

```text
baseFeeAmount = platform pricing 母规则按 finalConfirmedAmount / quotedAmount 计算出的基础平台服务费
discountedFeeAmount = baseFeeAmount × membershipDiscountRate
finalFeeAmount = min(discountedFeeAmount, capAmount)
releasedRemainderAmount = max(authorizationQuotaAmount - finalFeeAmount, 0)
```

## 2. 正式档位

| 档位 | membershipDiscountRate | capAmount | 是否启用 | 备注 |
|---|---:|---:|---:|---|
| 免费认证版 / 无会员 | 1.0000 | 4000.00 | 是 | 无会员折扣 |
| 标准会员 | 0.9000 | 3600.00 | 是 | 作用于 baseFeeAmount |
| 专业会员 | 0.8000 | 3200.00 | 是 | 作用于 baseFeeAmount |
| KA / 旗舰 | Unknown / Evidence Missing | Unknown / Evidence Missing | 否 | 仅预留，不进入当前 P0-Pay 计算 |

## 3. 快照字段

### 授权阶段

- `quotedAmount`：竞标报价金额。
- `authorizationQuotaAmount` / `quotaAmount`：固定 4000.00 预授权额度。
- `baseFeeAmount`：按报价金额计算的基础平台服务费预估。
- `membershipDiscountRate`：授权时会员档位折扣快照。
- `capAmount`：授权时会员档位封顶快照。
- `estimatedFeeAmount`：按 `baseFeeAmount × discount` 和 cap 计算出的预估服务费，仅作展示，不替代 4000 预授权额度。
- `feeRate`：兼容旧 command 校验字段，当前统一按基础平台定价兼容值透出，不作为正式服务费规则。
- `feeRateLabel`：只允许“基础平台定价规则 / 免费认证版无会员折扣 / 标准会员 9折（作用于 baseFeeAmount）/ 专业会员 8折（作用于 baseFeeAmount）”。

### 成交确认阶段

- `finalConfirmedAmount`：最终成交确认金额。
- `baseFeeAmount`：按最终成交确认金额计算的基础平台服务费。
- `membershipDiscountRate`：使用授权时会员档位快照，不在成交确认时重新读取实时会员态。
- `capAmount`：使用授权时封顶快照。
- `finalFeeAmount`：最终扣取服务费。
- `releasedRemainderAmount`：4000 预授权额度中需释放的余额。

## 4. 不做项

- 不按 2.5% / 2.0% / 1.5% 计算或展示正式服务费。
- 不把会员折扣作用到成交金额。
- 不开启 KA / 旗舰折扣。
- 不改退款、发票、续费、取消链路。
- 不让 BFF 或 Flutter 生成金额真相。

## 5. 验收门禁

- Server 单测必须覆盖：无会员、免费认证版、标准会员、专业会员、过期会员、KA / 旗舰拒绝。
- BFF 测试必须证明只透出 Server fee snapshot，不计算金额。
- Flutter 测试必须证明展示 baseFeeAmount、membershipDiscountRate、capAmount、finalFeeAmount，不展示 2.5% / 2.0% / 1.5%。
- runtime 联调前必须确认支付通道、回调域名、商户资质、ICP 与回滚点。

## 6. 下一步

进入 Day10 Server P0-Pay 会员折扣联动实现与回归；不得跳过 Server 测试直接改 BFF / Flutter 展示。
