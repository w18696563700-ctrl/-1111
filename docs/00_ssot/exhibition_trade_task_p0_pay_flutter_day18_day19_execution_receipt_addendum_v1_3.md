# Exhibition Trade Task P0-Pay Flutter Day18-Day19 Execution Receipt Addendum V1.3

status: execution_receipt
freeze_date_local: 2026-05-13
actual_authoring_date_local: 2026-04-25
owner: Codex Control
scope: Flutter only

## 0. Conclusion

2026-05-12 and 2026-05-13 Flutter scope is completed locally:

1. Flutter now has bounded P0-Pay app-facing consumption for task publish type selection, authenticity materials, inquiry sincerity-money order/pay-init/status, fixed-price bid submit, platform service fee authorization order/authorize-init/status, and P0-Pay summary reads.
2. Project create carries the P0-Pay publish entry without breaking the existing Round A project-basic-information closure; the P0-Pay publish section is a collapsible secondary entry and only appears after basic form input signals exist.
3. Bid submit carries the fixed-price bid P0-Pay fields and platform service fee preauthorization confirmation, then uses BFF returned `platformServiceFeeRequirement` before creating the authorization order.
4. Flutter opens only BFF-provided channel payload URLs and polls only BFF read-status routes.
5. Flutter still does not own payment truth, fee calculation truth, callback truth, account binding, wallet, balance, funds pool, settlement, invoice, or guarantee-deposit truth.

## 1. Implemented Flutter Files

- `apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart`
- `apps/mobile/lib/features/exhibition/data/commands/p0_pay_commands.dart`
- `apps/mobile/lib/features/exhibition/data/services/p0_pay_consumer_service.dart`
- `apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart`
- `apps/mobile/lib/features/exhibition/data/services/exhibition_contract_mapper.dart`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_trade_pages.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/bid_submit_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/presentation_support/p0_pay_bid_authorization_support.dart`
- `apps/mobile/lib/features/exhibition/presentation/presentation_support/p0_pay_bid_authorization_actions.dart`
- `apps/mobile/test/p0_pay_flutter_consumption_test.dart`

## 2. App-facing Routes Consumed

- `POST /api/app/exhibition/trade-tasks`
- `POST /api/app/exhibition/trade-tasks/{taskId}/fixed-price-bids`
- `POST /api/app/exhibition/trade-tasks/{taskId}/fixed-price-bids/{bidId}/service-fee-authorizations`
- `POST /api/app/exhibition/trade-tasks/{taskId}/fixed-price-bids/{bidId}/service-fee-authorizations/{authorizationId}/authorize-init`
- `GET /api/app/exhibition/trade-tasks/{taskId}/fixed-price-bids/{bidId}/service-fee-authorizations/{authorizationId}`
- `POST /api/app/exhibition/trade-tasks/{taskId}/inquiry-deposit/orders`
- `POST /api/app/exhibition/trade-tasks/{taskId}/inquiry-deposit/orders/{depositOrderId}/pay-init`
- `GET /api/app/exhibition/trade-tasks/{taskId}/inquiry-deposit/orders/{depositOrderId}`
- `GET /api/app/exhibition/trade-tasks/{taskId}/p0-pay-summary`

No Flutter route calls `/server/*`, `/api/app/payment/*`, `/api/app/wallet/*`, `/api/app/settlement/*`, `/api/app/invoice/*`, or `/api/app/guarantee-deposit/*`.

## 3. Boundary Decisions

More stable:

- P0-Pay Flutter consumption is added through dedicated commands, service extension, canonical paths, and a focused bid-authorization support part instead of embedding payment logic in project detail, messages, profile, or a generic payment center.

Lower cost:

- Existing `AppApiClient`, `ExhibitionConsumerLayer`, route guards, form widgets, upload-confirmed `FileAsset` semantics, and `url_launcher` handoff are reused.
- No local payment SDK, account-binding module, wallet page, finance center, or second state machine was introduced.

Best fit for current phase:

- Flutter only submits BFF-shaped commands, displays BFF/Server readbacks, and opens opaque channel payloads.
- Estimated platform service fee is taken from BFF returned `platformServiceFeeRequirement`; Flutter does not calculate the final fee truth.

Higher risk and therefore not done:

- Flutter-owned fee calculation, callback handling, payment-order status mutation, dispute judgment, service-fee deduction judgment, account binding, wallet, balance, funds pool, guarantee deposit, settlement, invoice, or finance-admin surface.

## 4. Page Consumption

Project create / publish entry:

- Adds P0-Pay task type selection: `fixed_price_bid` and `inquiry_quote`.
- Adds authenticity material `FileAsset` ID entry and five authenticity declarations.
- Adds inquiry quote `200` CNY `发单诚意金` order creation, pay-init handoff, and status refresh.
- Keeps `objectKey` out of business truth and avoids `押金 / 罚款 / 保证金` wording for inquiry sincerity money.

Bid submit:

- Adds fixed-price bid fields for quote validity, tax/transport/installation inclusion, material, craft, build process, delivery milestones, risk notes, and attachment `FileAsset` IDs.
- Adds platform service fee preauthorization confirmation copy:
  - preauthorization is not actual charging;
  - unsuccessful bidders are released automatically;
  - selected bidder is charged only after contract confirmation;
  - final amount changes must be recalculated by Server truth.
- Creates authorization only after BFF returns a complete `platformServiceFeeRequirement`.
- Shows `authorized` as preauthorized, not charged.

## 5. Verification

Passed locally:

- `flutter test test/p0_pay_flutter_consumption_test.dart`
- `flutter test test/project_publish_round_a_productization_test.dart test/p0_pay_flutter_consumption_test.dart`

Executed with known current-baseline failures:

- `flutter analyze` exits with existing repository warnings/infos, including legacy `avoid_print`, `unused_element`, and existing `invalid_use_of_protected_member` findings outside the new P0-Pay support file. No syntax error or missing symbol was reported.
- `flutter test test/bid_seat_completeness_consumption_test.dart` fails in the current local baseline with old bid-seat/detail expectations finding no legacy text fields and missing old detail text. This receipt does not claim that suite as passed.

Not executed in this receipt:

- Aliyun cloud deployment.
- SSH tunnel smoke through `127.0.0.1:8080`.
- Real Alipay / WeChat SDK call.
- Computer Use UI联调.

## 6. Remaining Gates

Next allowed work:

1. Project detail read-only P0-Pay status projection hardening.
2. Message-building read-only P0-Pay status projection hardening.
3. Cloud BFF/Server runtime alignment and tunnel smoke for `/api/app/exhibition/trade-tasks*`.
4. Computer Use UI联调 after cloud runtime and tunnel smoke pass.

Still blocked:

1. P1 履约保证金实缴、冻结、扣除、释放、争议协商、人工处理、律师协助.
2. Wallet, balance, coins, funds pool, settlement, invoice, finance-admin.
3. Platform-side user payment account binding.
4. Flutter-owned payment callback, payment status mutation, local fee calculation, or local deduction judgment.
