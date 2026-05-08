# 消息楼交互枢纽与我的楼真实业务入口地图 OpenAPI 裁决 V1

状态：Frozen

裁决日期：2026-05-07

上游 SSOT：

- `docs/00_ssot/message_hub_real_business_entry_map_v1.md`
- `docs/00_ssot/bid_service_fee_authorization_gate_shift_project_communication_open_condition_addendum_v1.md`

## 0. 总裁决

本轮不修改 `docs/01_contracts/openapi.yaml`。

现有 App-facing contracts 已能表达当前 P0 最小闭环所需的消息楼入口、我的竞标承接、项目沟通 workbench、资料确认、预授权只读/跳转、资金只读摘要、最终金额确认主路径和通知中心提醒。

本轮只冻结 OpenAPI 裁决表：消息楼继续复用既有 message / project-communication / notifications route family；真实业务页面继续复用我的项目、我的竞标、profile payment/billing、pricing-summary、deal-confirmations 等既有路径族。不得新增“消息楼支付/合同/钱包/发票/保证金真值写入接口”。

## 1. 裁决原则

| 原则 | 裁决 |
|---|---|
| 优先级 | 优先复用既有 OpenAPI，不新增接口 |
| 消息楼接口 | 只承接提醒、入口、未读、routeTarget、chatAvailability 和资料确认 workbench |
| 我的楼接口 | 承接真实业务页面的只读状态、记录、详情和后续命令入口 |
| Server truth | 资金、合同、预授权、支付、发票、钱包、保证金、最终金额必须由 Server 持有 |
| BFF | 只做 projection 和 routeTarget 透出 |
| Flutter | 只消费 contracts，不发明 DTO、状态或业务真值 |

## 2. 能力到现有 OpenAPI 路径裁决表

| 能力 | 当前主入口 | 复用 Path | Method | 是否需改 OpenAPI | 裁决 | 风险 |
|---|---|---|---|---|---|---|
| 消息楼主体列表 | 消息楼 | `/api/app/message/interactions` | GET | 否 | 继续作为消息楼项目互动主列表 | 不得变成交易真值列表 |
| 项目沟通线程 | 消息楼 / 项目沟通页 | `/api/app/message/project-communication/thread` | GET | 否 | `chatAvailability` 继续承接可发送锁态 | Flutter 不得本地放行 |
| 项目沟通消息 | 项目沟通页 | `/api/app/message/project-communication/messages` | GET/POST | 否 | POST 必须受 Server canSendMessage 校验 | 不得绕过预授权门禁 |
| 项目沟通已读 | 项目沟通页 | `/api/app/message/project-communication/read-cursor` | POST | 否 | 只承接 read cursor，不代表业务完成 | unread 与业务状态混用 |
| 资料确认 workbench | 消息楼 / 我的项目 | `/api/app/message/project-communication/workbench` | GET | 否 | 资料确认单入口和状态主读模型 | 不得承接最终金额 |
| 资料确认命令 | 资料确认页 | `/api/app/message/project-communication/workbench/material-review` | POST | 否 | 只处理资料确认/补充，Server 留痕 | 不得当成 BidAward/成交 |
| 通知中心 | 消息中心 / 铃铛 | `/api/app/notifications/list` | GET | 否 | 只读提醒列表和 routeTarget | 失效治理另开专项 |
| 通知已读 | 消息中心 | `/api/app/notifications/read` | POST | 否 | 只改通知 read truth | 不得自动误读失效提醒 |
| 我的竞标列表 | 我的楼 / 我的竞标 | `/api/app/my/bids` | GET | 否 | 竞标方真实私域入口 | 不得扩 compare/award |
| 竞标摘要 | 我的竞标 / 消息跳转 | `/api/app/bid/submission/snapshot` | GET | 否 | 竞标资料只读摘要/附件预览入口 | 不得改 Bid 真值 |
| 竞标提交 | 提交竞标页 | `/api/app/bid/submit` | POST | 否 | 已裁定不受 4000 预授权前置阻断 | 旧错误文案需实现层清理 |
| 项目收费只读摘要 | 项目详情 / 我的楼资金只读 | `/api/app/project/{projectId}/pricing-summary` | GET | 否 | 可承接折叠只读资金状态 | 不得在详情页裁定扣费 |
| 4000 预授权 | 我的竞标 / 预授权记录页 | 既有 platform pricing / p0_pay 预授权路径族 | GET/POST | 暂不改 | P0 先复用既有 routeTarget，真实支付通道后续裁决 | test authorization 仍是 blocker |
| 最终金额确认 | 我的合同 / 成交确认页 | `/api/app/project/{projectId}/deal-confirmations*` | GET/POST | 否 | 唯一 App-facing 最终金额确认候选主路径 | 不得走 `/api/app/contract/confirm` |
| profile 支付账单姿态 | 我的楼 | `/api/app/profile/payment-and-billing-status/*` | GET | 否 | 只读 posture / handoff | 不得变支付执行 |

## 3. routeTarget 裁决

当前 P0 可继续复用既有 routeTarget 最小字段：

1. `actionKey`
2. `canonicalPath`
3. `routeLocation`
4. `params`
5. `displayText`

新增页面入口优先通过既有 actionKey 和 canonicalPath 表达。只有出现现有 actionKey 无法表达的真实页面时，才进入 OpenAPI 新 enum 裁决。

当前不得新增以下 routeTarget：

1. `message_payment.execute`
2. `message_wallet.open_truth`
3. `message_invoice.issue`
4. `message_final_amount.set`
5. `message_deposit.freeze`
6. 任何以消息楼为资金/合同真值 owner 的 actionKey

## 4. 当前不新增 OpenAPI 的理由

1. `chatAvailability` 已有 `service_fee_authorization_pending` 和 `complete_service_fee_authorization`。
2. 资料确认 workbench 已有 `sourceFiles`、`reviewState`、`actionState`、`routeTarget`。
3. 资金只读摘要已有 `pricing-summary`。
4. 竞标方私域承接已有 `my/bids` 和 bid submission snapshot 合同族。
5. 最终合同金额确认已有 `deal-confirmations` 主路径族。
6. 通知中心已有 `notifications/list` 和 `notifications/read`。
7. 支付、钱包、发票、保证金、结算尚未进入当前 P0 施工范围。

## 5. 实现层必须处理但不需要 OpenAPI 变更的事项

| 事项 | 层级 | 裁决 |
|---|---|---|
| BFF 旧错误文案 `冻结成功后才能提交竞标` | BFF | 实现层修文案，不改 contracts |
| Flutter 旧预授权 checkbox / 测试残留 | Flutter | 实现层清理，不改 contracts |
| 平台收费只读状态折叠 | Flutter | UI 展示调整，不改 contracts |
| 资料确认必须预览后确认才变绿 | Flutter + Server read model | 消费既有 `reviewState`，不改 contracts |
| 预授权按钮跳转 | BFF + Flutter | 先复用既有 routeTarget；若云端缺字段再开裁决 |
| test authorization | Server + Contracts 待裁 | 若新增接口/状态，单独开 Test Authorization Contracts 裁决 |

## 6. 后续单独 Contracts 专项

以下能力不得混入本轮 OpenAPI：

1. 真实支付宝 / 微信预授权通道完整接入。
2. 自动解冻定时规则。
3. 失效提醒批量治理。
4. 支付扣费。
5. 保证金。
6. 结算。
7. 发票。
8. 钱包。
9. finalConfirmedAmount 后续变更。

## 7. Go / No-Go

| 项 | 裁决 |
|---|---|
| 是否改 `openapi.yaml` | No |
| 是否生成 generated | No，除非后续实现发现 drift |
| 是否允许进入 P0 实现收口 | Conditional Go |
| 进入实现前必须确认 | 本裁决表、test authorization 是否单独开口、是否折叠资金面板 |
| 最大风险 | 把消息楼入口误扩成资金/合同真值接口 |
