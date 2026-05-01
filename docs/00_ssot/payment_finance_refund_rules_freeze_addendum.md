# Payment Finance Refund Rules Freeze Addendum

## 0. 总裁决

- 当前是否允许直接开放全量退款：No-Go
- 当前允许的最小闭环：仅允许项目真实性诚意金按当前项目订单发起退款、回调确认、状态回读和审计留痕。
- Server 真相：Server 是退款状态、退款订单、退款回调、审计的唯一真相。
- BFF 职责：只转发和整形，不判断退款成功。
- Flutter 职责：只展示退款状态和中文提示，不裁定退款到账。

## 1. 本轮做什么

| 范围 | 冻结结论 |
|---|---|
| 退款对象 | 仅 `project_authenticity_sincerity_payment` 对应的当前项目 200 元诚意金 |
| 可退款状态 | `paid` 可发起；`refund_pending` 只读继续等待；`refunded` 只读完成 |
| 退款金额 | 使用原诚意金订单金额，首版不支持部分退款 |
| 退款发起 | Server 创建 `project_authenticity_sincerity_refund` 退款订单 |
| 退款确认 | 渠道 callback 验签后更新退款订单与诚意金状态 |
| 退款失败 | 退款订单失败，诚意金回到 `paid`，不自动重试 |
| 幂等 | 同一诚意金只允许一个有效退款订单；重复 callback 不重复退款 |
| 审计 | 记录发起、成功、失败相关事件 |

## 2. 本轮不做什么

- 不做钱包余额。
- 不做用户自助任意退款。
- 不做平台服务费 charge 退款。
- 不做部分退款。
- 不做自动退款重试。
- 不做退款到账时间承诺。
- 不做退款财务后台。

## 3. 门禁

| 门禁 | 结论 |
|---|---|
| 无订单退款 | 禁止 |
| 前端传最终退款状态 | 禁止 |
| BFF 本地判断退款成功 | 禁止 |
| Server callback 未验签即改状态 | 禁止 |
| 重复 callback 重复改状态 | 禁止 |

## 4. 下一步

通过本冻结后，允许进入退款最小实现：refund-init、refund callback、status readback、audit。
