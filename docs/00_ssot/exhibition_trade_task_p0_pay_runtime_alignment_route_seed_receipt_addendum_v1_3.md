# Exhibition Trade Task P0-Pay Runtime Alignment / Route Seed Receipt Addendum V1.3

status: source_aligned_cloud_runtime_blocked
target_workdays:
  - 2026-05-17
  - 2026-05-18
actual_execution_date_local: 2026-04-25
owner: Codex Control
scope: BFF / Server runtime alignment, controlled route gates, state action route family, test actor and seed readiness

## 0. Conclusion

当前裁决：

- 本地 `BFF / Server source package` 已完成 P0-Pay runtime alignment 修补。
- 本地构建与定向测试通过。
- 云上 active BFF 仍未对齐：`/api/app/exhibition/trade-tasks*` 仍返回 route-level `404`。
- 因此 `2026-05-17` 与 `2026-05-18` 不能重跑，不能进入 UAT。

本回执不宣称：

1. 云上 P0-Pay route family 已部署。
2. 云上 BFF / Server 已重启到当前代码。
3. 已完成真实支付、预授权、释放、退回、扣费或挂起链路。
4. 已具备 UAT 放行条件。

## 1. Current Minimum Closure

本轮最小闭环只处理 P0-Pay runtime route alignment：

1. 让本地 BFF 挂载 `/api/app/exhibition/trade-tasks*`。
2. 让本地 Server 挂载 BFF-forwarded `/server/exhibition/trade-tasks*`。
3. 补齐三类受控状态动作：
   - 未中标释放：`release-non-winning`
   - 发布方毁约退回：`publisher-breach-release`
   - 工厂拒签挂起：`factory-refusal-breach-hold`
4. 让缺 auth 的 GET 先返回受控 `401`。
5. 让空 body / 缺字段的 POST 先返回受控 `400`。
6. 让幂等冲突归一为受控 `409`。

更稳的路径：

- 先证明 cloud route family 从 `404` 变成 `401/400/409`，再跑 05-17 / 05-18。

更省成本的路径：

- 只做 BFF/Server 发版与重启，不扩到 Flutter、钱包、结算、履约保证金或财务后台。

更适合当前阶段的路径：

- 只解除 P0-Pay active runtime route drift，不提前打开 UAT 或 production gate。

风险更大的路径：

- 在 active cloud 仍为 `404` 时直接跑双账号 UAT、支付联调或生产发布。

## 2. Local Source Alignment

本地 Server 已具备以下 route family：

- `POST /server/exhibition/trade-tasks`
- `GET /server/exhibition/trade-tasks/:taskId`
- `POST /server/exhibition/trade-tasks/:taskId/authenticity-materials`
- `POST /server/exhibition/trade-tasks/:taskId/fixed-price-bids`
- `POST /server/exhibition/trade-tasks/:taskId/inquiry-quotations`
- `POST /server/exhibition/trade-tasks/:taskId/inquiry-result`
- `GET /server/exhibition/trade-tasks/:taskId/p0-pay-summary`
- `POST /server/exhibition/trade-tasks/:taskId/p0-pay-actions/release-non-winning`
- `POST /server/exhibition/trade-tasks/:taskId/p0-pay-actions/publisher-breach-release`
- `POST /server/exhibition/trade-tasks/:taskId/p0-pay-actions/factory-refusal-breach-hold`

本地 BFF 已具备对应 app-facing route family：

- `POST /api/app/exhibition/trade-tasks`
- `GET /api/app/exhibition/trade-tasks/:taskId`
- `POST /api/app/exhibition/trade-tasks/:taskId/authenticity-materials`
- `POST /api/app/exhibition/trade-tasks/:taskId/fixed-price-bids`
- `POST /api/app/exhibition/trade-tasks/:taskId/inquiry-quotations`
- `POST /api/app/exhibition/trade-tasks/:taskId/inquiry-result`
- `GET /api/app/exhibition/trade-tasks/:taskId/p0-pay-summary`
- `POST /api/app/exhibition/trade-tasks/:taskId/p0-pay-actions/release-non-winning`
- `POST /api/app/exhibition/trade-tasks/:taskId/p0-pay-actions/publisher-breach-release`
- `POST /api/app/exhibition/trade-tasks/:taskId/p0-pay-actions/factory-refusal-breach-hold`

关键修补：

1. `release-non-winning` 不再错误引用未定义 `bidId`，也不再错误写入发布方毁约标记。
2. `publisher-breach-release` 在释放前写入发布方毁约标记和审计。
3. 三类状态动作均先校验当前组织为发布方组织。
4. BFF 新增三类状态动作 app-facing route、Server forwarding、payload 裁剪、幂等头转发和 read-model 收口。
5. BFF 测试覆盖三类状态动作的 path / payload / header forwarding。
6. Server route drift 测试覆盖三类状态动作 route。

## 3. Local Verification

已通过：

```text
apps/server:
node --test test/p0-pay-calculator-idempotency.test.cjs test/p0-pay-server-mainline.test.cjs
-> PASS 5/5

npm run build
-> PASS

apps/bff:
node --test test/exhibition-p0-pay-transport.test.cjs
-> PASS 7/7

npm run build
-> PASS
```

新增 smoke 脚本：

```text
infra/scripts/p0_pay_cloud_route_smoke.sh
```

该脚本只做 route gate smoke：

1. `GET /api/app/exhibition/home` 应为 `200`。
2. `GET /api/app/exhibition/trade-tasks/probe/p0-pay-summary` 应为 `401`。
3. `POST /api/app/exhibition/trade-tasks {}` 应为 `400`。
4. `POST /api/app/exhibition/trade-tasks/probe/p0-pay-actions/release-non-winning {}` 应为 `400`。

## 4. Cloud Runtime Smoke Result

执行时间：

```text
2026-04-25 05:02 CST
```

执行命令：

```text
infra/scripts/p0_pay_cloud_route_smoke.sh
```

结果：

```text
[info] P0-Pay cloud route smoke base: http://127.0.0.1:8080
[ok] exhibition home ingress baseline: 200
[fail] trade-task summary route mounted and auth-gated: expected 401, got 404
{"message":"Cannot GET /api/app/exhibition/trade-tasks/probe/p0-pay-summary","error":"Not Found","statusCode":404}
```

补充手工 probe：

```text
GET http://127.0.0.1:8080/api/app/exhibition/home
-> 200 OK

GET http://127.0.0.1:8080/api/app/exhibition/trade-tasks/probe/p0-pay-summary
-> 404 Cannot GET /api/app/exhibition/trade-tasks/probe/p0-pay-summary

POST http://127.0.0.1:8080/api/app/exhibition/trade-tasks {}
-> 404 Cannot POST /api/app/exhibition/trade-tasks

POST http://127.0.0.1:8080/api/app/exhibition/trade-tasks/probe/p0-pay-actions/release-non-winning {}
-> 404 Cannot POST /api/app/exhibition/trade-tasks/probe/p0-pay-actions/release-non-winning

GET http://127.0.0.1:8080/api/app/message/interactions?lane=project_communication
-> 401 AUTH_SESSION_INVALID
```

解释：

1. 云上 BFF ingress 是活的。
2. 其他已挂载 BFF route 能返回受控 `401`。
3. P0-Pay app-facing route family 仍未在 active cloud runtime 挂载。
4. 当前失败点是 cloud BFF / Server runtime alignment，不是 Flutter 消费层。

## 5. Test Actor Packet

05-17 / 05-18 需要三个受控 actor，不得用裸 `x-actor-id` 伪造通过：

| Actor | Organization | Required truth | Required carrier |
| --- | --- | --- | --- |
| Publisher A | `buyer` or `both` | active user, active org, `buyer_admin`, organization certification `approved` | valid Bearer current-session carrier scoped to publisher org |
| Factory B | `supplier` or `both` | active user, active org, `supplier_admin`, organization certification `approved`, personal certification `approved` and locked to current user | valid Bearer current-session carrier scoped to factory org |
| Factory C | `supplier` or `both` | active user, active org, `supplier_admin`, organization certification `approved`, personal certification `approved` and locked to current user | valid Bearer current-session carrier scoped to factory org |

注意：

1. BFF 的 `x-actor-id / x-user-id / x-organization-id` 只是 forwarding hint。
2. Server 会校验 Bearer current-session carrier、session truth、organization membership、organization certification、personal certification。
3. 因此正式联调必须先拿到三套有效 app session，不能只补 header。

## 6. Seed Packet

05-17 固定 seed：

1. 一个 `fixed_price_bid` trade task。
2. 发布方为 Publisher A。
3. 任务状态 `published`，报价截止时间为未来时间。
4. 真实性材料至少一份，FileAsset 属于 Publisher A。
5. Factory B 提交固定报价和方案，附件 FileAsset 属于 Factory B。
6. Factory C 提交固定报价和方案，附件 FileAsset 属于 Factory C。
7. 两个工厂均创建平台服务费预授权。
8. 测试支付通道将两个预授权推进到 `authorized`。
9. Publisher A 选择其中一个为 winner。
10. 调用 `release-non-winning`，未中标工厂预授权应为 `authorization_released`。

05-18 固定 seed：

1. 复用 05-17 的 winning bid。
2. 创建合同确认，最终成交确认金额必须由 Server 重新计算平台服务费。
3. 测试支付通道将平台服务费 charge 推进到 `charged`。
4. 发布方毁约场景调用 `publisher-breach-release`，预授权或相关费用应释放 / 退回，不得作为平台服务费扣取。
5. 工厂拒签场景调用 `factory-refusal-breach-hold`，预授权应进入 `breach_hold`，不得默认全额扣平台服务费。
6. 三类状态动作都必须能在 `p0-pay-summary` 或对应状态 readback 中被 Server 真值反映。

当前 seed 状态：

- Seed packet 已冻结。
- 云上 DB 未写入本回执中的 seed。
- 原因：active cloud route family 仍为 `404`，且当前会话不具备可证明的云上部署 / DB seed 执行回执。

## 7. Required Cloud Alignment Before Re-Run

必须先完成：

1. 将当前 BFF source package 发布到云上 active BFF runtime。
2. 将当前 Server source package 发布到云上 active Server runtime。
3. 确认 Nginx / process manager 指向新 runtime。
4. 确认 Server migration 已包含 P0-Pay tables。
5. 执行 `infra/scripts/p0_pay_cloud_route_smoke.sh`，必须通过。
6. 准备三套有效 Bearer current-session actor。
7. 准备 05-17 / 05-18 seed。

通过标准：

```text
GET /api/app/exhibition/trade-tasks/probe/p0-pay-summary
-> 401 AUTH_SESSION_INVALID

POST /api/app/exhibition/trade-tasks {}
-> 400 P0_PAY_REQUEST_INVALID

POST /api/app/exhibition/trade-tasks/probe/p0-pay-actions/release-non-winning {}
-> 400 P0_PAY_REQUEST_INVALID
```

只有上述通过后，才允许重跑：

1. `2026-05-17 明价竞标、预授权、未中标释放`
2. `2026-05-18 合同确认扣费、毁约退回、拒签挂起`

## 8. Stage Gate Decision

Passed gates:

1. Local Server source route family aligned.
2. Local BFF source route family aligned.
3. Local controlled state action routes aligned.
4. Local BFF/Server targeted tests pass.
5. Local BFF/Server build pass.
6. Test actor and seed requirements frozen.

Failed gates:

1. Active cloud BFF P0-Pay route family remains router `404`.
2. Cloud Server runtime alignment not proven.
3. Cloud migration state not proven.
4. Authenticated test actors not proven.
5. 05-17 seed not inserted.
6. 05-18 seed not inserted.
7. BFF -> Server -> persistence -> readback chain not proven.

Veto gates:

1. `/api/app/exhibition/trade-tasks*` route-level `404`.
2. Missing cloud runtime route smoke pass.
3. Missing valid Bearer current-session actor packet.

Next stage allowed:

- Cloud BFF / Server deployment alignment.
- Non-mutating route smoke.
- Controlled test actor / seed preparation on an explicitly approved test environment.

Next stage not allowed:

- 05-17 rerun.
- 05-18 rerun.
- UAT.
- production release gate.
- gray release.
- real-money payment trial.

## 9. Final Freeze

本轮正式冻结为：

```text
Local source alignment for P0-Pay runtime routes is complete.
Active cloud runtime alignment is not complete.
Day 05-17 and Day 05-18 remain blocked until /api/app/exhibition/trade-tasks* returns controlled 401/400/409 instead of route-level 404.
```
