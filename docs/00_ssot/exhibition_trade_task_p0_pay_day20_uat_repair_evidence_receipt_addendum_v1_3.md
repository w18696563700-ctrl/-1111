# Exhibition Trade Task P0-Pay Day20 UAT Repair Evidence Receipt Addendum V1.3

status: uat_repair_receipt
planned_gate_date: 2026-05-20
actual_execution_date_local: 2026-04-25
owner: Codex Control
scope: Day19 UAT issue repair, message-building carry, project-detail/message read-only P0-Pay display

## 0. Conclusion

2026-05-20 UAT issue repair is completed for the P0-Pay Day19 blockers.

Gate decision:

1. Server message-building carrier seed for P0-Pay fixed-price bid submission: `passed`.
2. BFF message index readback for the UAT project: `passed`.
3. Flutter project-detail read-only P0-Pay summary consumption: `passed by widget regression`.
4. Computer Use message-building visual readback for the original Day19 UAT project: `passed`.
5. Overall Day20 repair: `passed_for_release_gate_entry`, `no_go_for_production_release_without_release_gate`.

This receipt closes the Day19 `conditional_pass_for_day20_repair` state and allows the next production-release-gate checklist to be authored. It does not approve production release, gray release, or real-money payment trial.

## 1. Day19 Issues Closed

Day19 retained issues:

1. Server must seed or update the approved message interaction carrier for the active project-bid relationship.
2. BFF `GET /api/app/message/interactions?lane=project_communication` must include the new UAT project conversation after the bid/award chain creates the relationship.
3. Flutter messages building must surface the latest UAT project rather than only the historical project-name-access conversation.
4. Flutter project detail should render the full read-only P0-Pay summary already available from BFF.

Day20 closure:

1. New P0-Pay fixed-price bid submissions now create `bid_private_threads` and `bid_thread_messages(system_seed)` in the Server transaction.
2. Message interaction projection reads the bid-thread seed and carries read-only `p0PaySummary`.
3. BFF continues to forward `/server/message/interactions`; it does not fabricate message data.
4. Flutter renders BFF-returned `p0PaySummary` in project detail and messages building.
5. The original Day19 UAT task was repaired with an idempotent, additive backfill for its missing bid-thread carrier.

## 2. Active Runtime

Server:

- active release: `/srv/releases/server/20260425161006-p0-pay-day20-message-carry`
- rollback target captured before cutover: `/srv/releases/server/20260425150611-project-transaction-day29-r1`
- process: `exhibition-server`
- status: `active`

BFF:

- active release: `/srv/releases/bff/20260425154325-day29-bff-runtime-routes/apps/bff`
- process: `exhibition-bff`
- status: `active`

Route gate:

- `infra/scripts/p0_pay_cloud_route_smoke.sh`
- result: `200 / 401 / 400 / 400`

Runtime code probe:

- active Server `P0PayTradeTaskService` contains `createForSubmittedBid`.
- active Server message projection contains `buildP0PaySummary`.
- active Server message projection contains `readOnly: true`.

## 3. Local Verification

Server targeted tests:

```bash
node --test apps/server/test/p0-pay-calculator-idempotency.test.cjs apps/server/test/p0-pay-server-mainline.test.cjs apps/server/test/message-interaction-bid-carry.test.cjs
```

Result:

- `13/13 passed`

BFF targeted tests:

```bash
node --test apps/bff/test/message-interaction-transport.test.cjs apps/bff/test/exhibition-p0-pay-transport.test.cjs
```

Result:

- `15/15 passed`

Flutter targeted tests:

```bash
cd apps/mobile && flutter test test/p0_pay_flutter_consumption_test.dart test/trading_im_round_a_consumption_test.dart test/messages_instance_todo_test.dart
```

Result:

- `24/24 passed`
- Flutter emitted non-fatal `drag()` hit-test warnings in existing scroll tests; no test failed.

Server build:

```bash
corepack pnpm --filter @exhibition/server build
```

Result:

- `passed`

## 4. New Day20 Real-Account Regression

Script:

- `infra/scripts/p0_pay_day20_real_account_uat.js`

Run:

- runId: `uat-day20-1777104791712-e342e0`
- taskId: `2e615622-da31-4f9a-aa2b-1c18cf4fd5a4`
- bidId: `ada7b031-4093-4bd8-b141-58c39771445d`
- authorizationId: `1019c16c-32d5-4b05-b95e-16ade2b839b7`

Business chain:

1. Publisher created fixed-price task through BFF: HTTP `202`, task status `published`, publish gate `passed`.
2. Factory submitted fixed-price bid through BFF: HTTP `202`, bid status `pending_service_fee_authorization`.
3. Factory completed platform service fee preauthorization through signed test callback: callback `applied`, authorization `authorized`.
4. Publisher awarded the bid: HTTP `202`, award state `converted_to_order`.
5. Publisher and factory completed contract confirmation: factory contract `confirmed`, platform service fee `charged`, final fee `2700.00`.

Readback:

- P0-Pay summary `platformServiceFee.status`: `charged`
- P0-Pay summary `platformServiceFee.finalFeeAmount`: `2700.00`
- P0-Pay summary `contractConfirmation.status`: `confirmed`
- P0-Pay summary `messageDisplaySummary.readOnly`: `true`
- DB `bid_private_threads`: `1`
- DB `bid_thread_messages`: `1`
- DB `project_communication_threads`: `0`
- Publisher message index contains new task: `true`
- Factory message index contains new task: `true`
- Publisher message index P0-Pay status: `charged`
- Factory message index P0-Pay status: `charged`
- Both message indexes carry read-only P0-Pay summary: `true`

Decision:

- New Day20 chain proves the Server/BFF message-building carry repair.

## 5. Original Day19 Backfill Evidence

Original Day19 task:

- taskId: `8583f40e-5b65-4be9-9476-0e902007da2f`
- bidId: `9b81993e-2132-41fa-9e71-53d7c54443c0`

Before Day20 repair:

- `bid_private_threads`: `0`
- `bid_thread_messages`: `0`
- `project_communication_threads`: `0`

Backfill action:

- Created missing `bid_private_threads` row.
- Created missing `bid_thread_messages` `system_seed` row.
- backfill type: idempotent, additive, UAT-data-only.

Backfill result:

- threadId: `5b0b68c4-df92-4e86-a541-ccb2e1326288`
- seedMessageId: `b13ac99e-a0e0-4557-842c-7a758be37e29`
- `bid_private_threads`: `1`
- `bid_thread_messages`: `1`

BFF message index readback after backfill:

Publisher organization:

- status: `200`
- contains Day19 task: `true`
- firstProjectId: `8583f40e-5b65-4be9-9476-0e902007da2f`
- first P0-Pay status: `charged`
- first P0-Pay readOnly: `true`

Factory organization:

- status: `200`
- contains Day19 task: `true`
- firstProjectId: `8583f40e-5b65-4be9-9476-0e902007da2f`
- first P0-Pay status: `charged`
- first P0-Pay readOnly: `true`

Decision:

- The original Day19 UAT message-building failure is repaired.

## 6. Computer Use Evidence

App:

- `mobile` / `com.example.mobile`

Observed page:

- `消息`
- `互动中心`
- `项目沟通`

Observed text:

- `新的竞标已提交`
- `P0-Pay 只读状态`
- `消息楼只展示资金状态摘要，不执行支付、不裁定扣费、不处理履约保证金。`
- `任务类型：明价竞标单`
- `平台服务费：已扣取`
- `预计服务费：2640.00`
- `最终服务费：2700.00`
- `只读 handoff：p0_pay_summary.read · /api/app/exhibition/trade-tasks/8583f40e-5b65-4be9-9476-0e902007da2f/p0-pay-summary`

Decision:

- The message-building UI now visually carries the original Day19 UAT project and its read-only P0-Pay status.

## 7. Boundary Confirmation

This repair did not implement, touch, or validate:

1. real Alipay / WeChat final payment confirmation
2. wallet
3. balance
4. coins
5. fund pool
6. payment account binding
7. generic payment center
8. generic billing center
9. settlement
10. invoice
11. P1 guarantee-deposit freeze / release / deduction / dispute / lawyer-assist
12. production release
13. gray release

The message-building surface remains read-only. It reads Server/BFF payment-state projection only and does not execute, mutate, or judge funds.

## 8. Final Gate Result

Day20 status:

- Day19 business truth: `already_passed`
- Day19 BFF payment projection: `already_passed`
- Day19 Flutter list/detail basic visibility: `already_passed`
- Flutter full payment-summary visibility: `passed`
- messages building UAT project handoff: `passed`
- original Day19 UAT project backfill: `passed`
- final: `go_for_release_gate_authoring`, `no_go_for_release_without_gate`

Next allowed work:

- 2026-05-21 production release gate checklist and cutover review.
