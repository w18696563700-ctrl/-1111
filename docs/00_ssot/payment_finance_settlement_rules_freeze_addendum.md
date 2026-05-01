# Payment Finance Settlement Rules Freeze Addendum

## 0. 总裁决

- 当前是否允许自动打款结算：No-Go
- 当前允许的最小闭环：只读结算摘要、结算草稿、对账摘要。
- Server 真相：Server 只从已存在的 charge、refund、audit 数据生成结算读模型。
- BFF 职责：只读投影，不生成财务真相。
- Flutter 职责：只展示摘要，不提示“已到账”。

## 1. 本轮做什么

| 范围 | 冻结结论 |
|---|---|
| 平台收入 | 来自 `platform_service_fee_charges.charge_status = charged` |
| 待结算 | 首版等于已扣取但未进入自动打款的服务费摘要 |
| 已结算 | 首版固定 `0.00`，不做自动打款 |
| 退款金额 | 来自已标记 `refunded` 的 charge 摘要，首版只读 |
| 异常挂账 | `charge_failed` 或 `refund_pending` 进入异常提示 |
| 对账差异 | 首版只读为 `0.00` 或异常提示，不自动调账 |
| batch draft | 只生成草稿摘要，不落地支付指令 |

## 2. 本轮不做什么

- 不做自动打款。
- 不做银行/支付宝/微信提现。
- 不做发票、税务、清分财务后台。
- 不做跨项目批量结算执行。
- 不做结算影响订单主状态。

## 3. 门禁

| 门禁 | 结论 |
|---|---|
| 结算写入真实付款通道 | 禁止 |
| 结算状态反向改订单状态 | 禁止 |
| BFF 计算平台收入 | 禁止 |
| Flutter 展示已到账 | 禁止 |

## 4. 下一步

通过本冻结后，允许进入结算只读最小实现：summary、batch draft、reconciliation read model。
