---
title: Project Counterparty Rating Credit Bridge And R2 Verification Receipt Addendum
status: receipt
execution_date_local: 2026-04-25
scope:
  - planned 2026-05-08 credit bridge
  - planned 2026-05-09 cloud R2 verification
---

# 《双方互评信用 bridge / 云上 R2 核查执行回执》

## 1. 总控结论

- `2026-05-08 信用 bridge` 已从旧 `/api/app/rating/submit` 旁路状态推进为新 `ProjectCounterpartyRating` 真值链路直接触发。
- 新双方互评提交后以 `rateeOrganizationId` 为信用聚合对象，触发 `CreditScoringShadowAggregationService.recomputeAfterFormalRatingSubmit`。
- `CreditScoringShadowAggregationService` 已纳入 `public.project_counterparty_ratings`，但不把 `score_value` 的 1-5 分直接当 0-100 信用分，只消费 `score_label` 映射。
- `2026-05-09 云上 R2` 当前仍只证明路由到达 BFF 鉴权边界；未取得真实登录态，不能判定真实读写闭环完成。

## 2. 代码落点

- Server truth submit:
  - `apps/server/src/modules/project_counterparty_rating/project-counterparty-rating.service.ts`
  - 提交成功后调用 `triggerCreditShadowBridge`
  - `organizationId = rating.rateeOrganizationId`
  - `sourceOrderId = rating.orderId`
  - `sourceRatingId = rating.id`
- Server module:
  - `apps/server/src/modules/project_counterparty_rating/project-counterparty-rating.module.ts`
  - 导入 `CreditScoringShadowModule`
- Shadow aggregation:
  - `apps/server/src/modules/credit_scoring_shadow/credit-scoring-shadow.aggregation.service.ts`
  - `public.ratings` 与 `public.project_counterparty_ratings` 合并为候选评价
  - 同一 `orderId` 去重，`project_counterparty_ratings` 优先
  - 互评分支输出 `null::numeric as "scoreValue"`，只以 `score_label` 进入 label 映射

## 3. 本地验证

- `cd apps/server && npm run build`
  - passed
- `cd apps/server && node --test test/project-counterparty-rating.test.cjs test/credit-scoring-shadow.test.cjs test/rating-entry-submit.test.cjs`
  - 18 passed
- `cd apps/server && node --test test/project-communication-album.test.cjs`
  - 6 passed
- `cd apps/bff && node --test test/project-counterparty-rating-transport.test.cjs test/project-album-transport.test.cjs`
  - 7 passed
- `cd apps/mobile && flutter test test/counterpart_conversation_chat_test.dart`
  - 9 passed

## 4. 云上 R2 探针

- 当前本机 `8080` 监听进程为 `ssh`，符合固定隧道：
  - `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`
- `GET http://127.0.0.1:8080/health/bff/live`
  - `200`
  - service: `exhibition-bff-isolated-s6`
- `GET http://127.0.0.1:8080/api/app/project-counterparty-rating/entry?orderId=order-probe&projectId=project-probe&rateeOrganizationId=org-probe`
  - `401 AUTH_SESSION_INVALID`
  - 判定：route materialized to BFF auth boundary

## 5. No-Go 边界

- 不得把旧 `/api/app/rating/submit` 的信用触发冒充新双方互评信用 bridge。
- 不得把 `project_counterparty_ratings.score_value` 的 1-5 分直接当 0-100 信用分。
- 不得把未登录 `401 AUTH_SESSION_INVALID` 冒充真实业务验收完成。
- 未完成真实登录态云上读写前，`2026-05-09 云上 R2` 只能判定为“路由可达 + 鉴权边界可达”，不能判定为“真实闭环完成”。

## 6. Remaining Gate

- 需要真实 `accessToken` 或可登录账号。
- 需要已完成项目的 `projectId / orderId / rateeOrganizationId`。
- 需要一组可提交双方互评的账号关系。
- 需要验证提交后：
  - `project_counterparty_ratings` 新增一条方向唯一评价
  - `organization_shadow_credit_recompute_triggers` 新增/处理触发
  - `organization_shadow_credit_ledgers` 追加 ledger
  - 重复提交返回 duplicate
