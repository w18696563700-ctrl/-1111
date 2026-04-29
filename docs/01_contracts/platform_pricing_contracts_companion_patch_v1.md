---
owner: Codex 总控
status: frozen
purpose: >
  Record the Day 1 companion patch that aligns `openapi.yaml` and
  `error_codes.yaml` with the current platform pricing contracts master.
layer: L2 Contracts
freeze_date_local: 2026-04-29
version: V1
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/platform_pricing_rules_master_v1.md
  - docs/01_contracts/platform_pricing_contracts_master_v1.md
  - docs/01_contracts/openapi.yaml
  - docs/01_contracts/error_codes.yaml
---

# 《平台收费规则 Contracts Companion Patch 回执 V1》

## 0. 总结论

Day 1 的 `contracts companion patch` 已完成。

本轮正式选择：

1. 先补齐 `openapi.yaml` 与 `error_codes.yaml`
2. 不改 `apps/mobile/**`、`apps/bff/**`、`apps/server/**`
3. 不动阿里云、不做 deploy、不做 runtime 联调
4. 只把新收费主线收口到 `L2 contracts` 最小闭环

当前更稳的方案：

- 先把 `200 / 4000 / deal confirmation / pricing summary` 收成 contract 真相，再进入 `L3 backend truth`

当前更省成本的方案：

- 复用既有 `project publish`、`bid/submit` 主锚点，只新增最小 pricing route family 与错误码

当前阶段最适合的方案：

- 用 companion patch 把 `openapi.yaml`、`error_codes.yaml` 与母文件对齐，不直接开实现

风险更大的方案：

- 继续让新母文件、`openapi.yaml`、`error_codes.yaml` 三者分叉，再进入实现派工

## 1. 本轮已补齐的 canonical routes

当前已进入 `openapi.yaml` 的 pricing-specific canonical routes：

1. `GET /api/app/project/{projectId}/pricing-summary`
2. `POST /api/app/project/{projectId}/authenticity-sincerity/orders`
3. `POST /api/app/project/{projectId}/authenticity-sincerity/orders/{orderId}/pay-init`
4. `GET /api/app/project/{projectId}/authenticity-sincerity/orders/{orderId}`
5. `POST /api/app/project/{projectId}/bid-service-fee-authorizations`
6. `POST /api/app/project/{projectId}/bid-service-fee-authorizations/{authorizationId}/freeze-init`
7. `GET /api/app/project/{projectId}/bid-service-fee-authorizations/{authorizationId}`
8. `POST /api/app/project/{projectId}/bid-service-fee-authorizations/{authorizationId}/release`
9. `POST /api/app/project/{projectId}/deal-confirmations`
10. `GET /api/app/project/{projectId}/deal-confirmations/{dealConfirmationId}`

当前已同步 gate 描述的既有 canonical routes：

1. `POST /api/app/project/publish`
2. `POST /api/app/bid/submit`

## 2. 本轮已补齐的 schema 组

当前已进入 `openapi.yaml` 的最小 schema 组：

1. `ProjectPricingSummaryResponse`
2. `ProjectPricingPublisherSummary`
3. `ProjectPricingBidderSummary`
4. `ProjectPricingDealSummary`
5. `ProjectAuthenticitySincerityOrderCreateRequest / Response`
6. `ProjectAuthenticitySincerityPayInitRequest / Response`
7. `ProjectAuthenticitySincerityOrderStatusResponse`
8. `BidServiceFeeAuthorizationCreateRequest / Response`
9. `BidServiceFeeAuthorizationFreezeInitRequest / Response`
10. `BidServiceFeeAuthorizationStatusResponse`
11. `BidServiceFeeAuthorizationReleaseRequest / Response`
12. `DealConfirmationCreateRequest`
13. `DealConfirmationAcceptedResponse`
14. `DealConfirmationReadModel`
15. `PricingServiceFeeCalculation`

## 3. 本轮已补齐的错误码

当前已进入 `error_codes.yaml` 的新增错误码：

1. `PROJECT_AUTHENTICITY_SINCERITY_REQUIRED`
2. `PROJECT_AUTHENTICITY_SINCERITY_ORDER_CREATE_REJECTED`
3. `PROJECT_AUTHENTICITY_SINCERITY_ORDER_NOT_FOUND`
4. `PROJECT_AUTHENTICITY_SINCERITY_PAY_INIT_REJECTED`
5. `PROJECT_AUTHENTICITY_SINCERITY_INVALID_STATE`
6. `BID_SERVICE_FEE_AUTHORIZATION_REQUIRED`
7. `BID_SERVICE_FEE_AUTHORIZATION_CREATE_REJECTED`
8. `BID_SERVICE_FEE_AUTHORIZATION_NOT_FOUND`
9. `BID_SERVICE_FEE_AUTHORIZATION_FREEZE_INIT_REJECTED`
10. `BID_SERVICE_FEE_AUTHORIZATION_RELEASE_REJECTED`
11. `BID_SERVICE_FEE_AUTHORIZATION_INVALID_STATE`
12. `DEAL_CONFIRMATION_INVALID`
13. `DEAL_CONFIRMATION_INVALID_STATE`
14. `DEAL_CONFIRMATION_COUNTERPARTY_PENDING`
15. `PRICING_RULE_VERSION_MISMATCH`

`AUTH_SESSION_INVALID` 继续复用既有定义，不新增第二版本。

## 4. 本轮保留的兼容边界

本轮明确保留但未重开实现的兼容边界：

1. `GET /api/app/bid/thread/detail` 继续作为现有 admitted thread carrier 存在
2. 本轮只给 `BidThreadDetailReadModel` 补了：
   - `pricingGateRequired`
   - `pricingGateType`
   - `detailRouteTarget`
3. 本轮没有额外发明第二套消息中心、第二套 thread state machine、第二套支付中心

当前仍待后续单独冻结的点：

1. `project/bid-participation/thread/detail` 与现有 `bid/thread/detail` 的 route normalization 真相
2. runtime 侧到底保留 alias 还是只留单一路径

这两点当前记录为 `known drift`，但不阻塞进入 Day 2，因为 Day 1 目标是补齐新收费主线的 `contracts companion patch`，不是重写消息路由家族。

## 5. 本轮明确未做

1. 未改 `apps/mobile/**`
2. 未改 `apps/bff/**`
3. 未改 `apps/server/**`
4. 未改阿里云环境
5. 未做 deploy / restart / rollback
6. 未做 tunnel 联调
7. 未做 runtime 验真

## 6. 第 1 天验收结论

当前验收结果：

1. 新收费 routes 已全部有 canonical contract entry
2. 新收费 request / response 最小字段已全部有定义
3. 新收费错误码已全部有定义
4. `trade-task / inquiry-deposit / 3%` 未再作为当前 `openapi.yaml`、`error_codes.yaml` 的现行 authority

当前结论：

- `允许进入第 2 天`

原因：

1. Day 1 的 contract 缺口已被补齐
2. 当前剩余问题已压缩为 `L3 backend truth` 和 route normalization 后续项
3. 当前没有发现会直接阻断 Day 2 的 `L2 contracts veto`
