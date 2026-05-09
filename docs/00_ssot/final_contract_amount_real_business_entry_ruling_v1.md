---
title: final_contract_amount_real_business_entry_ruling_v1
status: frozen
date: 2026-05-07
scope: SSOT
---

# 最终合同金额确认真实业务入口裁决 V1

## 0. 总裁决

最终合同金额确认必须回到 Server-owned `deal-confirmations` 主路径族和真实业务页承接。消息楼只能做提醒、入口和上下文跳转，不得持有、计算或替代 `finalConfirmedAmount` 真值。

本文件不修改最终合同金额确认接口，不修改 BidAward / Order / Contract seed，不进入支付、扣费、履约或争议施工。

## 1. 当前最小闭环

| 节点 | 裁决 |
|---|---|
| 入口可见 | 消息楼、我的竞标、我的项目详情均可出现跳转入口 |
| 真实业务页 | 合同金额确认页 / deal confirmation 详情页 |
| 主路径 | `/api/app/project/{projectId}/deal-confirmations` |
| 金额字段 | `finalConfirmedAmount` |
| 双方确认 | 必须由 Server 持久化双方确认状态 |
| 后续读取 | 合同、服务费、支付、金额变更只能读取 Server finalConfirmedAmount |

## 2. 金额真值边界

| 字段 | 是否最终金额 | 后续可否作为合同/支付真值 |
|---|---:|---:|
| `Bid.quoteAmount` | 否 | 否 |
| `Order.totalAmount` | 否 | 否 |
| 聊天消息文本 | 否 | 否 |
| 资料确认结果 | 否 | 否 |
| `finalConfirmedAmount` | 是 | 是 |

## 3. 消息楼职责

1. 展示“进入最终合同金额确认”的提醒或待办。
2. 携带 `projectId / dealConfirmationId / bidId` 等跳转上下文。
3. 展示 Server 返回的确认状态摘要。
4. 不写金额，不拼金额，不让聊天内容替代确认单。

## 4. 真实页面职责

1. 读取 Server 当前 deal confirmation truth。
2. 展示双方确认状态、金额、规则提示。
3. 提交确认动作时只走 Server 主路径。
4. 后续合同生成、服务费计算、支付读取均基于 Server truth。

## 5. No-Go

1. `/api/app/contract/confirm` 不得作为 `finalConfirmedAmount` 主 setter。
2. 不在消息楼 material-review 里确认最终合同金额。
3. 不让 BFF 或 Flutter 持有最终金额。
4. 不把资料确认通过、预授权完成、BidAward、Order seed 写成成交金额已确认。

## 6. 后续施工切片

| 阶段 | 内容 |
|---|---|
| SSOT/Contracts 复核 | 核对 deal-confirmations 当前主路径是否已满足真实页 |
| Server | 确认 finalConfirmedAmount 持久化、双方确认、幂等和 audit |
| BFF | 仅透出真实状态和 routeTarget |
| Flutter | 我的竞标 / 我的项目 / 消息楼跳转到真实确认页 |
| UAT | 双账号确认金额后刷新/重登仍读取 Server truth |

## 7. 当前阶段结论

最终合同金额确认专项可独立进入后续冻结和施工；不得混入当前资料确认、预授权 gate 后移和项目级自由发送 P0 闭环。
