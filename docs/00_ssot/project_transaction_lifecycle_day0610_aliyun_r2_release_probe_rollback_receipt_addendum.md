# Project Transaction Lifecycle Day0610 Aliyun R2 Release Probe / Migration Dry-Run / Rollback Receipt

计划日期：2026-06-10  
执行记录日期：2026-04-26  
状态：R2 gray runtime gate Conditional Pass；Production acceptance No-Go

## 1. 结论

Day0610 可记录为“云上 R2 灰度当前态核查通过”，但不是最终生产验收通过。

本轮没有执行新的 `current` 切换，也没有执行写入式 deploy。云上当前已经处于更新后的 R2 候选：

- Server current：`/srv/releases/server/20260426013000-project-detail-bid-candidates`
- BFF current：`/srv/releases/bff/20260426013000-project-detail-bid-candidates/apps/bff`

更稳：把本轮定义为 current/runtime/schema/route/rollback 的只读验收，不重复切回旧 release。

更省成本：复用已存在的 R2 候选 runtime 和 systemd/current symlink procedure baseline，不新增临时 deploy 脚本。

更适合当前阶段：先证明灰度 runtime 与 schema 已对齐，再进入 Day0611 Computer Use 双账号验收。

风险更大：没有双账号 UI 和真实 order/rating/credit 数据时，直接宣称 R2 满足 100% 生产验收。

## 2. 当前最小闭环

已完成：

- 云上 Server/BFF current 指针核查。
- systemd `WorkingDirectory` 与 active process cwd 核查。
- Nginx health 路由核查。
- Server/BFF live/ready 核查。
- migration ledger 与关键 schema 只读核查。
- app-facing 交易路由 auth/参数门禁探针。
- rollback procedure 与候选 rollback target 记录。

未完成：

- 双账号完整点击验收。
- 真实订单生成。
- 真实订单完成。
- 双方互评写入。
- `source_type=project_counterparty_rating` 的真实信用 trigger / ledger 证据。

## 3. Runtime Current Gate

| 项 | 结果 |
| --- | --- |
| Server current | `/srv/releases/server/20260426013000-project-detail-bid-candidates` |
| BFF current | `/srv/releases/bff/20260426013000-project-detail-bid-candidates/apps/bff` |
| `exhibition-server.service` | `active` |
| `exhibition-bff.service` | `active` |
| `nginx` | `active` |
| Server unit `WorkingDirectory` | `/srv/apps/server/current` |
| BFF unit `WorkingDirectory` | `/srv/apps/bff/current` |
| Server process cwd | `/srv/releases/server/20260426013000-project-detail-bid-candidates` |
| BFF process cwd | `/srv/releases/bff/20260426013000-project-detail-bid-candidates/apps/bff` |
| Server `ExecStart` | `node dist/main.js` |
| BFF `ExecStart` | `node dist/apps/bff/src/main.js` |

Gate result：Pass。

## 4. Health / Route Probe

Nginx through local tunnel `127.0.0.1:8080`：

| Route | Result |
| --- | --- |
| `GET /health/bff/live` | `200`, `status=ok`, `service=exhibition-bff` |
| `GET /health/bff/ready` | `200`, `status=ready`, `service=exhibition-bff` |
| `GET /health/server/live` | `200`, `status=ok`, `service=exhibition-server` |
| `GET /health/server/ready` | `200`, `status=ready`, `service=exhibition-server` |
| `GET /api/app/shell/context` | `401 AUTH_SESSION_INVALID` |
| `GET /api/app/order/detail?orderId=probe-order&projectId=probe-project` | `401 AUTH_SESSION_INVALID` |
| `GET /api/app/project-counterparty-rating/entry?...` | `401 AUTH_SESSION_INVALID` |
| `GET /api/app/message/interactions` | `401 AUTH_SESSION_INVALID` |
| `POST /api/app/bid/select-bid-and-create-order {}` | `400 BID_AWARD_INVALID` |
| `POST /api/app/order/complete/request {}` | `400 PROJECT_ORDER_COMPLETE_INVALID` |
| `POST /api/app/order/complete/confirm {}` | `400 PROJECT_ORDER_COMPLETE_INVALID` |
| `POST /api/app/project-counterparty-rating/submit {}` | `400 PROJECT_COUNTERPARTY_RATING_INVALID` |

Direct cloud-local Server probe：

- `GET http://127.0.0.1:3001/server/project-counterparty-rating/entry?...` returns `401 AUTH_SESSION_INVALID`.

Interpretation：

- Route families are materialized.
- Unauthenticated GET is correctly auth-gated.
- Empty-body POST is parameter-gated before business mutation.
- These probes prove route/materialization, not business acceptance.

## 5. Migration Dry-Run Equivalent

当前工程没有独立 `migration dry-run` 脚本；`ServerMigrationRunnerService` 会在 Server 启动时真实执行未应用 migrations，因此不能把本地启动 Server 当 dry-run。

本轮采用只读等价核查：

1. Local migration source contains key set.
2. Active cloud dist contains the same transaction-chain migration keys.
3. Cloud `server_schema_migration` has the required keys.
4. Cloud information schema has the required columns and indexes-ready fields.
5. No write migration command was executed in this turn.

Key evidence：

| Check | Result |
| --- | --- |
| Local migration keys | `48` |
| Active cloud dist migration keys | `48` |
| Cloud migration ledger count | `58` |
| `20260520_project_order_truth_state_machine` | Present |
| `20260428_project_counterparty_rating_truth` | Present |
| `20260602_credit_shadow_source_type_truth` | Present |

Schema evidence：

| Column | Result |
| --- | --- |
| `orders.completed_at` | Present |
| `orders.completion_request_state` | Present / NOT NULL |
| `project_counterparty_ratings.order_id` | Present / NOT NULL |
| `project_counterparty_ratings.project_id` | Present / NOT NULL |
| `project_counterparty_ratings.rater_organization_id` | Present / NOT NULL |
| `project_counterparty_ratings.ratee_organization_id` | Present / NOT NULL |
| `project_counterparty_ratings.rating_state` | Present / NOT NULL |
| `organization_shadow_credit_recompute_triggers.source_type` | Present / NOT NULL |
| `organization_shadow_credit_ledgers.source_type` | Present / NOT NULL |

Dry-run equivalent conclusion：Pass for schema-diff / ledger alignment; no destructive migration executed.

## 6. Data Snapshot

| Object | Count |
| --- | ---: |
| `project` | `1` |
| `project.published` | `1` |
| `bids` | `1` |
| `bids.submitted` | `1` |
| `orders` | `0` |
| completed orders | `0` |
| `project_counterparty_ratings` | `0` |
| credit recompute triggers | `0` |
| credit ledgers | `0` |

Resume anchors：

| Anchor | Value |
| --- | --- |
| projectId | `c788eaff-6243-4e97-8be3-c4e174ee7944` |
| projectTitle | `西洽会 - 泸州` |
| ownerOrganizationId | `e6bf4567-016e-45f9-9420-9c950237690e` |
| bidId | `6e936969-3520-44bc-8804-1c804351423e` |
| bidderOrganizationId | `bdfb4523-aeb7-4b56-89a1-992170fb5d98` |

## 7. Rollback Plan

No rollback was executed.

Current R2 candidate：

- Server：`/srv/releases/server/20260426013000-project-detail-bid-candidates`
- BFF：`/srv/releases/bff/20260426013000-project-detail-bid-candidates/apps/bff`

Candidate rollback target, based on the previous transaction UAT receipts and release sequence：

- Server：`/srv/releases/server/20260425204500-order-detail-projectid-cloud-patch`
- BFF：`/srv/releases/bff/20260425204500-order-detail-projectid-cloud-patch/apps/bff`

Rollback procedure remains the frozen current-symlink procedure：

1. record current targets again before rollback;
2. switch `/srv/apps/server/current` to the rollback Server target;
3. switch `/srv/apps/bff/current` to the rollback BFF target;
4. restart `exhibition-server.service`;
5. restart `exhibition-bff.service`;
6. verify `systemctl is-active`, process cwd, health/live, health/ready, and route gates.

Rollback risk：

- Rolling back will likely lose the project-detail bid-candidate patch needed for owner-side selection UI.
- Rollback is therefore reserved for runtime regression, not for incomplete Day0611 UAT.

## 8. 阶段门禁核查表

Passed gates：

- Current/release/process cwd aligned.
- Server/BFF services active.
- Nginx tunnel health/live and health/ready pass.
- Transaction migration keys present in local source, active dist, and cloud ledger.
- Critical order/rating/credit schema columns present.
- App-facing routes materialized and gated.
- Rollback procedure and candidate target recorded.

Failed gates：

- No real order row exists.
- No completed order exists.
- No `project_counterparty_ratings` rows exist.
- No rating-derived credit trigger / ledger exists.
- Day0611 Computer Use dual-account UAT has not passed.

Veto gates：

- Do not claim production acceptance.
- Do not claim cutover readiness.
- Do not use route probes or schema proof as substitute for real dual-account UAT.

Next stage：

- Go for Day0611 Computer Use dual-account UAT only.
- No-Go for Day0612 final production acceptance until Day0611 passes and DB proof exists.
