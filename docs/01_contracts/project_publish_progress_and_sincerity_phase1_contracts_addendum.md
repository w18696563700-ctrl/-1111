# Project Publish Progress and Sincerity Phase 1 Contracts Addendum

## 0. Verdict

- Current route family remains `pricing-summary + authenticity-sincerity orders + pay-init + order-status`.
- `pricing-summary` remains read-only.
- BFF may project Server-returned order continuation fields.
- Flutter must not fabricate an `orderId`, payment status, or payment URL.

## 1. Pricing Summary Publisher Fields

`GET /api/app/project/{projectId}/pricing-summary`

`publisherPricing` keeps the existing fields and adds optional continuation fields:

| Field | Type | Owner | Meaning |
|---|---|---|---|
| `authenticitySincerityOrderId` | `string | null` | Server via BFF | Current project active/completed 200 CNY order id when visible |
| `authenticitySincerityCurrency` | `string | null` | Server via BFF | Currency for the current project sincerity order |
| `authenticitySincerityChannelCandidates` | `string[]` | Server via BFF | Candidate channels for continuing payment |
| `authenticitySincerityExpiresAt` | `string | null` | Server via BFF | Optional order expiry timestamp |

These fields are optional for compatibility. Missing fields must be treated as `Evidence Missing`, not as payment success.

## 2. Continue Payment Rule

Flutter may call:

`POST /api/app/project/{projectId}/authenticity-sincerity/orders/{orderId}/pay-init`

only when:

1. `publisherPricing.authenticitySincerityOrderId` exists, or
2. the create-order response returns `orderId`.

If `orderId` is absent, Flutter must show a Chinese fallback telling the user to refresh or wait for cloud order information.

## 3. Owner Boundary

| Layer | Allowed | Forbidden |
|---|---|---|
| Server | Owns project sincerity order status and active-order decision | None |
| BFF | Read-only projection and Chinese-safe field shaping | Computing payment success |
| Flutter | Display progress/status and call existing routes | Creating duplicate active orders or treating pay-init as paid |

## 4. Minimum Compatibility

Older Server/BFF releases may only return:

- `authenticitySincerityStatus`
- `authenticitySincerityAmount`
- `publishGateStatus`

Flutter must still show a readable status card. It may not show continue-payment unless an order id is present.
