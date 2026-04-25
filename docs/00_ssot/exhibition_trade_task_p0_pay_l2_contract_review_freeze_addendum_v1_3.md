---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the control review conclusion for the P0-Pay L2 contracts package,
  confirming that the app-facing route family, minimum schemas, payment-channel
  boundary, account-binding boundary, message-building read-only handoff, and
  retained No-Go list are sufficient to proceed to Server truth authoring while
  still blocking direct implementation, integration, release-prep, and launch.
layer: L0 SSOT
freeze_date_local: 2026-04-26
version: V1.3
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/exhibition_trade_task_payment_mainline_p0_pay_freeze_v1_3.md
  - docs/01_contracts/exhibition_trade_task_p0_pay_contracts_addendum_v1_3.md
  - docs/01_contracts/project_transaction_skeleton_p0_contracts_addendum.md
  - docs/01_contracts/messages_interaction_center_contract_freeze_addendum.md
---

# 展览平台任务发布与交易收费规则 P0-Pay L2 合同评审与冻结回执 V1.3

## 1. Review Scope

本回执只评审：

- [exhibition_trade_task_p0_pay_contracts_addendum_v1_3.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/exhibition_trade_task_p0_pay_contracts_addendum_v1_3.md)

本回执不评审：

1. `apps/**` 实现。
2. Server persistence / migration。
3. BFF surface freeze。
4. Flutter consumption freeze。
5. 支付通道商户资质实测。
6. 云上发布。
7. 生产切流。

## 2. Review Conclusion

当前 L2 合同评审结论：

- `P0-Pay L2 contracts = 通过`
- `Go for L3 Server truth authoring`
- `No-Go for direct implementation`
- `No-Go for integration`
- `No-Go for release-prep`
- `No-Go for production release`

评分：

- 96 / 100

扣分项不阻断进入 L3：

1. 支付通道商户资质、App 支付、预授权、退款、释放和回调域名尚未实测。
2. L3/L4/L5 尚未冻结。
3. 具体实现时是否复用既有 `bid/submit` 内部 carrier 仍需 L3/L4 决定。

## 3. Passed Gates

已通过门禁：

1. L2 合同挂在 `/api/app/exhibition/*` 与 trade-task 主线下，没有裸开 `/payment/*`。
2. 明价竞标单平台服务费预授权已冻结为订单级预授权，不是真实扣费。
3. 询价报价单 200 元发单诚意金已冻结为订单级支付，不叫押金、罚款或保证金。
4. 合同确认后平台服务费扣取已冻结为最终成交确认金额口径，不按发布预算抽成。
5. 发布方、竞标工厂、中标工厂不需要提前绑定支付宝、微信或银行卡。
6. Contract 不含支付宝账号、微信账号、银行卡号、支付密码、短信验证码、长期自动扣款授权或用户资金账户控制权。
7. 消息楼只读展示资金状态，不执行支付、不产生资金真相、不裁定资金状态。
8. BFF 只做认证汇聚、请求整形、响应整形、可见性裁剪和轻幂等。
9. Server 是业务状态、资金状态、回调状态和审计状态唯一真相。
10. error family 覆盖认证、任务状态、预授权、诚意金、询价席位、合同确认、通道约束和幂等冲突。
11. 钱包、余额、金币、资金池、保证金、清分结算、发票、财务后台继续 No-Go。

## 4. Route Cohesion Decision

本轮正式选择：

- 所有 P0-Pay 资金动作都挂在展览交易任务主线下。
- 不采用裸 `/api/app/payment/*`。
- 不采用裸 `/api/app/wallet/*`。
- 不采用裸 `/api/app/billing/*`。

理由：

1. 更稳：资金动作都有 `taskId / bidId / quotationId / contractConfirmationId` 业务锚点。
2. 更省成本：不需要建设通用支付中心或账户绑定模块。
3. 更适合当前阶段：只服务展览任务 P0-Pay 轻闭环。
4. 风险更小：减少 BFF/Flutter 误读成全局支付平台的概率。

风险更大的写法：

- 把 P0-Pay route 设计成通用支付中心、钱包、保证金中心或财务中心。

## 5. Contract Coverage Review

### 5.1 当前最小闭环

L2 已覆盖：

1. 发布明价竞标单。
2. 发布询价报价单。
3. 真实性材料与真实性声明。
4. 明价竞标单报价与方案。
5. 平台服务费预授权创建、拉起和状态读取。
6. 询价单 200 元发单诚意金创建、拉起和状态读取。
7. 询价报价席位。
8. 发布方处理询价结果。
9. 合同确认与最终成交金额确认。
10. P0-Pay 聚合只读状态。
11. 消息楼只读 handoff。

### 5.2 需要保留但暂不开通

L2 已保留并继续阻断：

1. 履约保证金。
2. 钱包 / 余额 / 金币 / 资金池。
3. 通用支付中心。
4. 通用账单中心。
5. 清分结算。
6. 发票 / 税务。
7. 财务后台。
8. 消息楼支付执行台。
9. 消息楼争议裁判台。

### 5.3 后续扩展位

后续扩展位必须另行冻结：

1. P1 履约保证金独立规则包。
2. P1 支付通道冻结 / 解冻 contract。
3. P1 保证金争议协商 contract。
4. P2 节点付款 / 验收付款。
5. P2 清分结算 / 发票 / 财务后台。

## 6. Failed Gates

当前未通过、但不阻断 L3 authoring 的门禁：

1. L3 Server truth 尚未冻结。
2. L3 persistence / state machine / audit 尚未冻结。
3. L4 BFF surface 尚未冻结。
4. L5 Flutter consumption 尚未冻结。
5. `openapi.yaml` 尚未按本 L2 文书产出受控 diff。
6. `error_codes.yaml` 尚未按本 L2 文书产出受控 diff。
7. 支付通道能力尚未实测。

这些门禁阻断：

- direct implementation
- integration
- release-prep
- production release

这些门禁不阻断：

- L3 Server truth authoring
- L3 persistence / state / audit freeze authoring

## 7. Retained Veto Gates

保留否决门禁：

1. 不得绕过 L3/L4/L5 直接实现。
2. 不得让 BFF 持有资金真相。
3. 不得让 Flutter 直连 Server。
4. 不得把消息楼变成支付执行台或争议裁判台。
5. 不得把平台服务费预授权写成报名费、竞标费或席位费。
6. 不得把发单诚意金写成押金、罚款或履约保证金。
7. 不得在 P0-Pay 打开履约保证金。
8. 不得建设钱包、余额、金币或资金池。
9. 不得保存用户支付账户敏感信息。
10. 不得按发布预算直接抽平台服务费。
11. 不得向未中标工厂收取平台服务费。

## 8. Stage Decision

下一阶段正式结论：

- `Go`：进入 P0-Pay `L3 Server truth` 编写。
- `Go`：进入 P0-Pay `L3 persistence / state machine / audit` 冻结编写。
- `No-Go`：直接进入 Server / BFF / Flutter 代码实现。
- `No-Go`：Computer Use 联调。
- `No-Go`：生产发布。

## 9. Formal Conclusion

P0-Pay L2 合同已经具备进入 L3 的条件。

本回执冻结：

```text
L2 contract review passed.
P0-Pay may proceed to Server truth authoring.
Implementation remains blocked.
```
