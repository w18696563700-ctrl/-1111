---
owner: Codex 总控
status: frozen
layer: L0-L5 SSOT
freeze_date_local: 2026-05-18
purpose: >
  Freeze the production transaction lifecycle from published project to bid
  award, order creation, order completion, counterparty rating, credit shadow,
  and dual-account acceptance.
---

# 项目交易链路 Day18 L0-L5 冻结

## 1. Scope

本轮只冻结并允许开发这条生产闭环：

`项目发布 -> 竞标/沟通 -> 选定合作方 -> 生成订单 -> 项目/订单完成 -> 双方互评 -> 信用 shadow/ledger 触发 -> 双账号验收通过`

## 2. L0 Product Truth

- `Project` 是发布项目真值。
- `Bid` 是承接方竞标真值。
- `BidAward` 是发布方选定合作方真值。
- `ProjectOrder` 是订单真值，必须强制携带 `projectId / buyerOrganizationId / sellerOrganizationId`。
- `ProjectCounterpartyRating` 是双方互评真值，必须强制携带 `orderId / projectId / raterOrganizationId / rateeOrganizationId`。
- `OrganizationCreditShadow` 只消费正式订单和正式互评，不消费前端本地状态。

## 3. L1 Information Architecture

- 展示入口可以统一到项目沟通页或消息楼聚合容器。
- 业务边界不得合并：
  - 竞标选择仍锚定 `projectId + bidId`。
  - 订单仍锚定 `orderId + projectId`。
  - 互评仍锚定 `orderId + projectId + rater + ratee`。
  - 信用只从 Server truth 派生。
- 一个对方主体可以显示为一个会话容器，但容器不拥有交易状态机。

## 4. L2 Contract Freeze

- App-facing 只允许通过 `/api/app/*` 访问。
- BFF 必须转发登录态、组织态、requestId、traceId。
- 命令接口必须返回 accepted carrier，不返回“前端自行推导成功”的状态。
- 所有 write 命令必须 fail-closed：
  - 缺 `projectId` / `bidId` / `orderId` 直接拒绝。
  - 非当前组织边界直接拒绝。
  - 已完成、已取消、已重复提交直接拒绝或幂等返回。

## 5. L3 Server Truth Freeze

- Server 是唯一业务真值所有者。
- `BidAwardWriteService` 负责竞标选择、单赢家约束、输家状态、订单/合同种子和审计。
- `ProjectOrder` 负责订单锚点、状态机、完成态资格。
- `TradingShellFulfillmentProgressService` 负责最小履约推进：
  - `Milestone.pending_submission -> submitted`
  - `Inspection.draft -> submitted`
  - `Inspection.submitted -> passed`
  - 全部 milestone completed 后派生 `ProjectOrder.completed`
- `ProjectCounterpartyRatingService` 只允许 completed order 下互评。
- 信用 shadow/ledger 只由 rating truth 触发。

## 6. L4 BFF Surface Freeze

- BFF 不持有交易真值。
- BFF 只做：
  - auth/context forwarding
  - request normalization
  - response shaping
  - routeTarget/actionKey preservation
  - controlled error mapping
- BFF 不允许创建第二套 `ProjectOrder.state`、`BidAward.state`、`Rating.state`。

## 7. L5 Flutter Consumption Freeze

- Flutter 只消费 BFF `/api/app/*`。
- Flutter 可以展示：
  - 竞标选择入口
  - 订单状态卡
  - 履约/验收动作入口
  - completed 后评价入口
  - 信用提示
- Flutter 不允许本地把 `竞标中` 推导成 `可评价`。
- Flutter 不允许本地把 `Inspection.passed` 推导成 `Order.completed`。

## 8. Non-Goals

- 不做支付、结算、发票、钱包、资金池。
- 不做完整合同电子签。
- 不做复杂争议仲裁。
- 不做多赢家拆单。
- 不做跨项目统一状态机。
- 不通过手工改 DB 冒充生产验收。

## 9. Day18 Gate Decision

- `Go` for Day19 Server bid selection hardening and Day20 ProjectOrder truth skeleton.
- `No-Go` for BFF/Flutter write expansion before Server truth is built and tested.
- `No-Go` for production acceptance claim before dual-account completed-order rating and credit ledger verification pass.
