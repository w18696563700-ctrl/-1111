# Exhibition Trade Task P0-Pay Flutter Day21 Project Detail And Message Readonly Receipt Addendum V1.3

status: execution_receipt
target_workday: 2026-05-15
actual_authoring_date_local: 2026-04-25
owner: Codex Control
scope: Flutter only, with non-mutating cloud preflight

## 0. Conclusion

2026-05-15 Flutter scope is completed locally:

1. Project detail now preserves BFF-provided `taskId`, `tradeTaskId`, and embedded `p0PaySummary` through the Flutter contract mapper.
2. Project detail reads the bounded BFF P0-Pay summary route and renders only a read-only status card.
3. Messages building now accepts optional `p0PaySummary` / `paymentStatusSummary` and renders a read-only P0-Pay status card inside project communication items.
4. Both carriers explicitly remain display and handoff surfaces only.
5. Flutter still does not execute payment, receive callback truth, create fee truth, mutate money state, judge deduction, process guarantee deposit, create wallet/balance/coins, or call Server directly.

## 1. Implemented Files

- `apps/mobile/lib/features/exhibition/data/p0_pay_read_only_summary.dart`
- `apps/mobile/lib/features/exhibition/data/services/exhibition_contract_mapper.dart`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_trade_pages.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart`
- `apps/mobile/lib/features/messages/data/messages_interaction_models.dart`
- `apps/mobile/lib/features/messages/data/messages_interaction_parser.dart`
- `apps/mobile/lib/features/messages/presentation/messages_page.dart`
- `apps/mobile/lib/features/messages/presentation/messages_page_support.dart`
- `apps/mobile/test/messages_instance_todo_test.dart`
- `apps/mobile/test/trading_im_round_a_consumption_test.dart`

## 2. Project Detail Readonly Carry

Implemented:

1. Preserve `taskId`, `tradeTaskId`, and `p0PaySummary` after project-detail response sanitization.
2. Derive the P0-Pay task id from project detail payload.
3. Read `GET /api/app/exhibition/trade-tasks/{taskId}/p0-pay-summary` through `ExhibitionConsumerLayer`.
4. Render platform service-fee, inquiry sincerity-money, contract-confirmation, message-display status, `routeTarget`, and `updatedAt` as read-only lines.
5. Keep refresh as a read-only reload only.

Not introduced:

1. payment button in project-detail P0-Pay status card
2. payment execution
3. payment callback handling
4. local money truth
5. direct Server calls

## 3. Message Building Readonly Carry

Implemented:

1. Parse optional project-communication `p0PaySummary` / `paymentStatusSummary`.
2. Render a compact `P0-Pay 只读状态` card inside project communication items.
3. Display only bounded status lines and read-only `routeTarget` handoff text.
4. Keep the project communication open action unchanged.

Message building still may not own or decide:

1. payment execution
2. funds-state truth
3. fee deduction judgment
4. guarantee-deposit judgment
5. full dispute desk
6. generic DM / group chat / global unread governance

## 4. Verification

Passed locally:

- `flutter test test/messages_instance_todo_test.dart test/trading_im_round_a_consumption_test.dart`
- `flutter analyze lib/features/exhibition/data/p0_pay_read_only_summary.dart lib/features/exhibition/data/services/exhibition_contract_mapper.dart lib/features/exhibition/presentation/exhibition_trade_pages.dart lib/features/messages/data/messages_interaction_models.dart lib/features/messages/data/messages_interaction_parser.dart lib/features/messages/presentation/messages_page.dart lib/features/messages/presentation/messages_page_support.dart`

Observed but non-blocking:

- The combined widget test command still prints existing Flutter scroll hit-test warnings in older bid-thread tests. The command exits successfully and the warnings are not introduced by the Day21 P0-Pay readonly implementation.

## 5. Cloud Preflight For Day22

Non-mutating checks against `127.0.0.1:8080` show:

1. Tunnel target is reachable.
2. `GET /api/app/exhibition/home` returns `200`.
3. `GET /api/app/project/list` returns `200`.
4. `GET /api/app/project/detail?projectId=c788eaff-6243-4e97-8be3-c4e174ee7944` returns `200`, but the response currently does not include `taskId`, `tradeTaskId`, or `p0PaySummary`.
5. `GET /api/app/message/interactions?lane=project_communication` returns controlled `401 AUTH_SESSION_INVALID`, proving auth is required for message-building integration.
6. `GET /api/app/exhibition/trade-tasks/probe/p0-pay-summary` returns `404 Cannot GET`, indicating the active cloud BFF route family is not yet proven mounted for the P0-Pay summary route.

No mutating inquiry, sincerity-money, quote-seat, refund, release, or payment-channel command was executed.

The separate cloud-integration subthread could not use the provided root SSH tunnel command because the environment blocked that SSH action under platform safety controls. This receipt therefore records Day22 cloud integration as `blocked / not passed`, not as completed.

## 6. Remaining Gates

Day22 cloud integration requires all of the following before it can pass:

1. active cloud BFF exposes the frozen P0-Pay route family;
2. active project-detail or trade-task projection exposes a usable `taskId` / `tradeTaskId`;
3. controlled test actor or auth transport is available;
4. inquiry quote task seed exists;
5. inquiry sincerity-money order, payment status, quote-seat capacity, result processing, and refund/return paths can be verified without production-money side effects;
6. Computer Use联调 starts only after route smoke and auth smoke pass.

Still blocked:

1. P1 履约保证金
2. wallet, balance, coins, funds pool
3. settlement, invoice, finance-admin
4. Flutter-owned payment callback or money truth
5. release-prep or production release claims
