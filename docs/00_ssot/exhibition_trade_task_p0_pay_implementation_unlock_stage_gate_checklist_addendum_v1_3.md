---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the implementation-unlock and stage-gate checklist for
  `exhibition_trade_task_p0_pay` after the L0/L2/L3/L4/L5 document chain has
  been completed, deciding the bounded implementation scope for Server, BFF,
  Flutter, result verification, tunnel-based integration, and Computer Use
  checks while keeping production release, guarantee deposit, wallet, settlement,
  invoice, finance-admin, and any unbounded payment center blocked.
layer: L0 SSOT
freeze_date_local: 2026-05-03
version: V1.3
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/exhibition_trade_task_payment_mainline_p0_pay_freeze_v1_3.md
  - docs/01_contracts/exhibition_trade_task_p0_pay_contracts_addendum_v1_3.md
  - docs/02_backend/exhibition_trade_task_p0_pay_server_truth_addendum_v1_3.md
  - docs/02_backend/exhibition_trade_task_p0_pay_persistence_state_audit_freeze_addendum_v1_3.md
  - docs/03_bff/exhibition_trade_task_p0_pay_bff_surface_freeze_addendum_v1_3.md
  - docs/04_frontend/exhibition_trade_task_p0_pay_frontend_consumption_freeze_addendum_v1_3.md
---

# 展览平台任务发布与交易收费规则 P0-Pay Implementation Unlock / Stage Gate Checklist V1.3

## 1. Scope

本门禁核查表只服务于：

- `exhibition_trade_task_p0_pay`
- bounded implementation dispatch authoring
- Server / BFF / Flutter 分段实现派工
- 结果校验
- 隧道联调
- Computer Use UI 验证

本门禁核查表只回答：

1. 哪些门禁已通过。
2. 哪些门禁未通过。
3. 哪些是一票否决。
4. 当前是否允许进入下一阶段。
5. 当前允许实现什么。
6. 当前仍禁止实现什么。

本门禁核查表不等于：

1. Server implementation receipt。
2. BFF implementation receipt。
3. Flutter implementation receipt。
4. 支付通道生产开通证明。
5. integration pass。
6. release-prep pass。
7. production release pass。

## 2. Current Conclusion

当前正式结论：

- `P0-Pay implementation unlock = bounded Go`
- `Go for bounded implementation dispatch`
- `Go for Server implementation planning / dispatch`
- `Go for BFF implementation planning / dispatch`
- `Go for Flutter implementation planning / dispatch`
- `Go for result-verification spec authoring`
- `No-Go for production release`
- `No-Go for guarantee deposit implementation`
- `No-Go for wallet / balance / coins / funds pool`
- `No-Go for generic payment center`
- `No-Go for generic billing center`
- `No-Go for settlement / invoice / finance-admin`

当前更稳的执行顺序：

1. Server。
2. BFF。
3. Flutter。
4. 结果校验。
5. 隧道联调。
6. Computer Use 联调。

当前更省成本的执行方式：

- 订单级支付 / 订单级预授权 / 订单级退款 / 订单级释放。
- 不做支付账户绑定。
- 不做平台钱包。
- 不做资金池。

当前阶段最适合：

- 先实现 P0-Pay 轻商业闭环。

风险更大：

- 同时开启履约保证金、争议裁判、通用支付中心、结算、发票和财务后台。

## 3. Passed Gates

已通过门禁：

1. L0 SSOT 母资料已冻结。
2. L2 app-facing contracts 已冻结。
3. L2 合同评审与冻结回执已通过。
4. L3 Server truth 已冻结。
5. L3 persistence / state / audit 已冻结。
6. L4 BFF surface 已冻结。
7. L5 Flutter consumption 已冻结。
8. P0-Pay 当前最小闭环已冻结：
   - 明价竞标单平台服务费预授权。
   - 询价报价单 200 元发单诚意金。
   - 合同确认后平台服务费。
   - 项目真实性保障。
   - 消息楼只读承接。
9. Server 唯一 business truth / payment truth / callback truth / audit truth 已冻结。
10. BFF 只做 app-facing surface、聚合、整形、裁剪、轻幂等转发已冻结。
11. Flutter 只消费 BFF、不直连 Server 已冻结。
12. 支付通道与账户绑定边界已冻结。
13. P1 履约保证金独立规则包索引已冻结。
14. 钱包、余额、金币、资金池继续 No-Go 已冻结。

## 4. Failed Gates

未通过但不阻断 bounded implementation dispatch 的门禁：

1. Server 代码尚未实现。
2. BFF 代码尚未实现。
3. Flutter 代码尚未实现。
4. OpenAPI runtime diff 尚未产出。
5. error codes runtime diff 尚未产出。
6. 支付通道商户资质尚未完成当前轮实测。
7. 支付通道 App 支付、预授权、退款、释放能力尚未完成当前轮实测。
8. 支付通道回调域名尚未完成当前轮实测。
9. 云上 BFF / Server implementation receipt 尚未产出。
10. 隧道端到端 smoke 尚未产出。
11. Computer Use UI 验证尚未产出。

这些失败门禁阻断：

- release-prep。
- production release。
- 对外宣称支付主线已上线。

这些失败门禁不阻断：

- bounded implementation dispatch。
- 本地 Flutter implementation。
- 云上 Server / BFF bounded implementation planning。

## 5. Veto Gates

以下任一情况出现，直接 veto：

1. Flutter 直连 Server。
2. BFF 持有资金真相、支付回调真相或第二状态机。
3. Server 不再是唯一 business truth / payment truth / callback truth / audit truth owner。
4. 把平台服务费预授权实现成报名费、竞标费或席位费。
5. 把发单诚意金实现成押金、罚款或履约保证金。
6. 报名竞标时真实扣平台服务费。
7. 未中标工厂被收平台服务费。
8. 按发布预算直接抽平台服务费。
9. 在 P0-Pay 实现履约保证金。
10. 建设钱包、余额、金币或资金池。
11. 保存支付宝账号、微信账号、银行卡号、支付密码、短信验证码或长期自动扣款授权。
12. 消息楼产生、修改或裁定资金状态。
13. 消息楼承接支付执行台或完整争议处理台。
14. 未通过支付通道核验却宣称生产可用。
15. 没有 tunnel smoke 却宣称联调通过。
16. 没有 release gate 却生产切流。

## 6. Bounded Implementation Scope

### 6.1 Server Scope

Server 允许实现：

1. `TradeTask` task type 与真实性材料绑定。
2. `FixedPriceBid` 明价竞标报价与平台服务费预授权业务锚点。
3. `PlatformServiceFeeAuthorization`。
4. `InquiryQuoteTaskDeposit`。
5. `InquiryQuotation` 与 5 席位事务占用。
6. `InquiryResultProcessing`。
7. `ContractConfirmation`。
8. `PlatformServiceFeeCharge`。
9. `PaymentOrder`。
10. `PaymentTransaction`。
11. `PaymentCallbackEvent`。
12. audit actions。
13. idempotency scopes。
14. callback verification and apply。

Server 禁止实现：

1. 履约保证金。
2. 钱包、余额、金币、资金池。
3. 清分结算。
4. 发票 / 税务。
5. 财务后台。
6. AI 自动判责。
7. 律师争议协助。

### 6.2 BFF Scope

BFF 允许实现：

1. `/api/app/exhibition/trade-tasks*` P0-Pay route family。
2. BFF -> Server route mapping。
3. auth / organization scope forwarding。
4. request shaping。
5. response shaping。
6. idempotencyKey forwarding。
7. controlled error normalization。
8. P0-Pay summary shaping。
9. message-building read-only payment status projection。

BFF 禁止实现：

1. payment order persistence。
2. payment callback endpoint。
3. fee final truth。
4. inquiry seat final truth。
5. contract confirmation final truth。
6. wallet / balance / coin。
7. guarantee deposit。
8. settlement / invoice / finance-admin。
9. message-building payment execution。

### 6.3 Flutter Scope

Flutter 允许实现：

1. 交易任务类型选择。
2. 真实性材料和声明。
3. 明价竞标报价与平台服务费预授权确认。
4. 支付通道 channelPayload 拉起。
5. 预授权结果轮询。
6. 询价发单诚意金订单确认、支付拉起和结果轮询。
7. 询价报价席位显示。
8. 询价结果处理。
9. 合同确认最终金额输入与确认 handoff。
10. 项目详情 P0-Pay 只读状态。
11. 消息楼 P0-Pay 只读状态卡。
12. controlled failure states。

Flutter 禁止实现：

1. direct Server calls。
2. local payment truth。
3. local callback truth。
4. local fee final truth。
5. local quote-seat truth。
6. local contract-confirmation truth。
7. wallet UI。
8. guarantee deposit UI。
9. settlement / invoice / finance-admin UI。
10. message-building payment execution UI。

## 7. Required Implementation Order

正式派工顺序冻结为：

1. Server 实现。
2. Server targeted tests。
3. BFF 实现。
4. BFF targeted tests。
5. Flutter 实现。
6. Flutter analyze / tests。
7. tunnel smoke。
8. Computer Use UI 验证。
9. implementation receipt。
10. release-prep gate。

不得跳序：

- 不得在 Server truth 未实现前让 BFF 伪造成功。
- 不得在 BFF surface 未实现前让 Flutter 写 fake adapter。
- 不得在 tunnel smoke 未通过前进入 release-prep。

## 8. Required Result Verification

结果校验必须至少覆盖：

1. 明价竞标单创建。
2. 明价竞标报价提交。
3. 平台服务费预授权创建。
4. 预授权拉起。
5. 预授权状态读取。
6. 未中标释放预授权。
7. 中标后 pending contract confirm。
8. 合同确认后平台服务费扣取。
9. 发布方毁约释放 / 退回。
10. 工厂拒签 breach hold。
11. 询价报价单创建。
12. 发单诚意金支付。
13. 5 席报价限制。
14. 询价结果处理。
15. 发单诚意金退回。
16. 发单诚意金扣除候选。
17. 项目详情只读状态。
18. 消息楼只读状态。

## 9. Tunnel And Computer Use Gate

本地隧道：

```bash
ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198
```

隧道联调前置：

1. 云上 Server / BFF 进程可识别。
2. BFF `/api/app/*` 可通过 `localhost:8080` 访问。
3. 当前环境 headers / auth 测试账号可用。
4. 支付通道可使用 mock / sandbox / channel constraint posture。

Computer Use 联调必须验证：

1. 发布明价竞标单。
2. 工厂报价并看到平台服务费预授权。
3. 支付拉起页或受控 unavailable。
4. 询价单发单诚意金。
5. 询价报价席位。
6. 项目详情只读 P0-Pay 状态。
7. 消息楼只读 P0-Pay 状态。

## 10. Release Blockers

以下 blocker 未解除前不得 release：

1. 支付通道商户资质未核验。
2. 支付通道回调未核验。
3. 退款 / 释放能力未核验。
4. Server / BFF cloud receipt 未产出。
5. Flutter UI receipt 未产出。
6. tunnel smoke 未通过。
7. Computer Use 联调未通过。
8. release rollback point 未冻结。
9. 监控和日志未确认。

## 11. Source-map And Receipt Rule

后续每个实现阶段必须产出 receipt：

1. Server implementation receipt。
2. BFF implementation receipt。
3. Flutter implementation receipt。
4. integration smoke receipt。
5. Computer Use verification receipt。

每份 receipt 必须登记到 `source_of_truth_map.md`。

## 12. Stage Decision

当前阶段决策：

- `Go`：bounded implementation dispatch authoring。
- `Go`：Server bounded implementation。
- `Go`：BFF bounded implementation after Server route contract is available。
- `Go`：Flutter bounded implementation after BFF app-facing surface is available or mock contract is explicitly controlled。
- `Go`：result-verification spec authoring。
- `No-Go`：release-prep。
- `No-Go`：production release。

## 13. Formal Conclusion

P0-Pay 从文书冻结链进入有界实现阶段。

正式口径：

```text
L0/L2/L3/L4/L5 freeze chain is complete.
Bounded implementation is allowed.
Production release remains blocked.
P1 guarantee deposit remains blocked.
Wallet, balance, coins, funds pool, settlement, invoice, and finance-admin remain blocked.
```
