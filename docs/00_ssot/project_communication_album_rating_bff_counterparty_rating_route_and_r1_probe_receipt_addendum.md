---
owner: Codex 总控
status: active
purpose: Record the BFF counterparty-rating route completion and the current R1 cloud probe result for project communication, album, and rating.
layer: L0 SSOT
schedule_dates_local:
  - 2026-04-30
  - 2026-05-01
execution_date_local: 2026-04-24
based_on:
  - docs/00_ssot/project_communication_album_rating_truth_freeze_addendum.md
  - docs/00_ssot/project_communication_album_rating_route_table_addendum.md
  - docs/01_contracts/project_communication_album_rating_contract_freeze_addendum.md
  - docs/03_bff/project_communication_album_rating_bff_surface_freeze_addendum.md
---

# 《项目沟通 / 相册 / 互评 BFF 路由与云上 R1 探针回执》

## 1. Scope

- 本回执覆盖：
  - `GET /api/app/project-counterparty-rating/entry`
  - `POST /api/app/project-counterparty-rating/submit`
  - 本地 BFF build / transport regression
  - `127.0.0.1:8080` 云上隧道探针
- 本回执不覆盖：
  - Flutter 互评 UI。
  - 真实账号登录态读写验收。
  - 信用 shadow 重算链路验收。

## 2. Implementation Receipt

- BFF 新增独立 `project_counterparty_rating` route module。
- BFF app-facing path 已挂入 `RoutesModule`。
- BFF 只做：
  - auth/session carrier forwarding
  - request field normalization
  - response read-model shaping
  - feature-specific error mapping
- BFF 不做：
  - `ProjectCounterpartyRating` 真值创建
  - `raterOrganizationId` 自行判定
  - 评价状态机
  - 信用分计算
- 旧 `/api/app/rating/*` 保持历史单向/受控评价入口，不作为本轮双方互评入口。

## 3. Verification Evidence

- Local Server build：
  - `corepack pnpm --filter @exhibition/server build`
  - result：passed
- Local BFF build：
  - `corepack pnpm --filter @exhibition/bff build`
  - result：passed
- Local Server regression：
  - `node --test test/project-counterparty-rating.test.cjs test/project-communication-album.test.cjs`
  - result：12 passed
- Local BFF regression：
  - `node --test test/project-counterparty-rating-transport.test.cjs test/message-interaction-transport.test.cjs test/project-album-transport.test.cjs test/rating-entry-submit.test.cjs`
  - result：21 passed

## 4. Cloud R1 Probe

- Cloud release current：
  - Server：`/srv/apps/server/current -> /srv/releases/server/20260425001009-project-counterparty-rating-r1-minimal`
  - BFF：`/srv/apps/bff/current -> /srv/releases/bff/20260425001009-project-counterparty-rating-r1-minimal`
- Nginx whitelist：
  - `/etc/nginx/conf.d/exhibition.conf` now includes `project-counterparty-rating` in both app-facing regex locations.
- Runtime health：
  - `GET http://127.0.0.1:3001/health/live` returned `200`.
  - `GET http://127.0.0.1:3000/health/live` returned `200`.
- `127.0.0.1:8080` reaches the existing cloud BFF / Server chain：
  - `GET /api/app/message/interactions?lane=project_communication`
  - with actor hint
  - result：`401 AUTH_SESSION_INVALID` from Server
- 新双方互评 app-facing path 已在云上 current materialize：
  - `GET /api/app/project-counterparty-rating/entry?orderId=order-probe&projectId=project-probe&rateeOrganizationId=org-probe`
  - with actor hint
  - result：`401 AUTH_SESSION_INVALID` from Server, not nginx/Nest `404`
- 判定：
  - local BFF route implementation：passed
  - cloud R1 route materialization：passed
  - real-account read/write验收：blocked

## 5. Runtime Correction Note

- A first cloud release `20260425000411-project-counterparty-rating-r1` was prepared by overlaying full local `dist`.
- That release unintentionally carried a dirty-worktree future migration:
  - `20260504_p0_pay_payment_execution_truth`
- Correction performed:
  - switched current to `20260425001009-project-counterparty-rating-r1-minimal`
  - current Server `AppModule` contains `ProjectCounterpartyRatingModule`
  - current Server `AppModule` does not contain `P0PayModule`
  - current BFF contains only the required `ProjectCounterpartyRatingModule` route addition for this slice
- Residual risk:
  - the migration ledger already records `20260504_p0_pay_payment_execution_truth`
  - any DB objects created by that migration require a separate DBA-controlled assessment before deletion or acceptance
  - this回执 does not approve P0-Pay runtime, contracts, frontend, release, or production cutover

## 6. Gate Result

- Passed gates：
  - BFF no-truth-owner。
  - BFF route独立于旧 `/api/app/rating/*`。
  - request truth anchors include `orderId / projectId / rateeOrganizationId`。
  - submit payload does not accept frontend-owned `scoreValue` as truth。
  - BFF build and targeted tests pass。
  - Server build and targeted tests pass。
  - Aliyun current exposes the new app-facing route to auth boundary.
  - Aliyun current runtime has been corrected to the minimal counterparty-rating release.
- Failed gates：
  - No real logged-in account has completed rating entry/read/write验收。
  - Scope-control hygiene has a residual DB migration ledger risk from the temporary full-dist release.
- Veto gates retained：
  - 不得把旧单向评价当双方互评。
  - 不得由 BFF 生成评价业务真值。
  - 不得在缺少 `projectId` 的情况下提交或读取互评入口。
  - 不得把 nginx 404 或未登录 401 误判为业务验收通过。
  - 不得把 `20260504_p0_pay_payment_execution_truth` 误判为 P0-Pay 放行。

## 7. Next Stage Decision

- `Go`：
  - prepare real-account R1 validation scripts.
  - proceed to Flutter-side consumption work only against the frozen BFF route.
- `No-Go`：
  - claiming Flutter end-to-end互评验收通过.
  - claiming real-account R1 read/write验收通过.
  - enabling production cutover.
  - deleting or accepting the residual P0-Pay DB migration side effect without separate stage gate.
