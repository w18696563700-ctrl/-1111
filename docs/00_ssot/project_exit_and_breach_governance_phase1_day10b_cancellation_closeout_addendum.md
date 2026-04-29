---
title: project_exit_and_breach_governance_phase1_day10b_cancellation_closeout_addendum
owner: Codex 总控
status: frozen
layer: L0 SSOT
updated_at: 2026-04-29
purpose: Freeze Day10B closeout semantics after controlled runtime verification showed accepted cancellation was only recorded.
supersedes_partial:
  - docs/00_ssot/project_exit_and_breach_governance_phase1_rule_freeze_addendum.md
  - docs/02_backend/project_exit_and_breach_governance_phase1_server_truth_and_persistence_addendum.md
---

# 项目退出与违约治理第一期 Day10B 双方取消收口冻结单

## 0. 总裁决

- `accepted cancellation` 不再只是留痕。
- 双方同意取消后，Server 必须做最小状态收口：
  - `project.state -> submitted`
  - `project.published_at -> null`
  - `order.state -> cancelled`
  - `project_exit_cases.status -> accepted`
- 仍然不自动扣钱、不触发支付初始化、不删除订单/合同/支付/消息/审计记录。
- `reject cancellation` 仍然只关闭 case，项目和订单继续进行中。

## 1. 当前最小闭环

| 动作 | Day10A 结果 | Day10B 冻结 |
|---|---|---|
| 发起取消 | 生成 `requested` case | 保持 |
| 拒绝取消 | case -> `rejected`，项目继续进行中 | 保持 |
| 同意取消 | case -> `accepted`，但项目/订单未收口 | 改为项目回预发布、订单取消 |
| 违约记录 | 只留痕，信用候选，不扣钱 | 保持 |

## 2. 规则边界

1. 只允许 `awarded / converted_to_order` 项目上的 `requested` cancellation case 被同意收口。
2. 响应方必须是 `counterpartyOrganizationId`。
3. 订单必须存在，且当前仍为 `active`。
4. 同意取消后：
   - 项目回到预发布列表：`submitted`
   - 公域下架：`published_at = null`
   - 订单关闭：`cancelled`
   - case 关闭：`accepted`
   - audit 写入 `project_cancellation_accepted`
5. 不触碰：
   - payment order
   - platform service fee authorization
   - final charge
   - callback
   - bid/order/contract 历史物理删除

## 3. 需要保留但暂不开通

- 取消后的合同归档详情页。
- 取消原因多级分类。
- 双方取消后的评价入口。
- 自动信用分计算。
- 自动费用罚没。

## 4. 后续扩展位

- 仲裁中心。
- 平台人工审核。
- 违约金或保证金扣罚。
- 取消后重新发布继承旧资料但不继承旧竞标的完整规则。

## 5. 门禁

- Server 单测必须覆盖：
  - accept 后 `project.state=submitted`
  - accept 后 `order.state=cancelled`
  - reject 后项目/订单仍 active
  - breach 仍不扣钱
- 云端受控写入只允许测试样本。
- 支付表和 P0-Pay 授权表不得出现 Day10B requestId 写入。
