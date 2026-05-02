# Alipay APP Pay Channel Integration Addendum

## 0. Verdict

- Current package: connect the existing P0-Pay payment-order and callback truth to Alipay APP Pay.
- Current boundary: Server generates Alipay APP Pay SDK order string and verifies Alipay asynchronous notifications.
- Still forbidden: Flutter/BFF deciding payment success, storing user Alipay accounts, automatic wallet/balance, automatic payout settlement, or writing secrets into repo.

## 1. Official Product Facts

| Item | Frozen fact |
|---|---|
| Product | Alipay APP Pay |
| Client mode | Merchant mobile app integrates Alipay SDK and invokes Alipay app for payment |
| Server mode | Server signs OpenAPI request parameters with RSA2 and returns SDK payload to client |
| Callback | A public HTTP(S) application gateway / notify URL is required for asynchronous notifications |
| Merchant account | App must be bound to the merchant account that opened APP Pay |
| Refund | Refund is supported within product rules; refund service fee is not returned |
| Settlement | Settlement goes to the signed Alipay merchant account balance by product rules |

## 2. Server Truth Boundary

| Rule | Freeze |
|---|---|
| Payment order owner | Server `payment_orders` |
| Payment success owner | Server verified Alipay callback only |
| Callback verification | Alipay RSA2 signature verification with Alipay public key |
| Request signing | Server signs `alipay.trade.app.pay` APP Pay order string |
| Flutter role | Invoke native SDK payload, then poll Server read model |
| BFF role | Pass through Server response and errors; no payment truth |
| Missing config | Fail closed as `unavailable`, never fake a payment URL |

## 3. Required Runtime Configuration

| Env | Required | Notes |
|---|---:|---|
| `P0_PAY_ALIPAY_APP_PAY_ENABLED` | Yes | Must be `true` before Server emits real SDK payload |
| `P0_PAY_ALIPAY_APP_ID` | Yes | Alipay Open Platform APPID |
| `P0_PAY_ALIPAY_APP_PRIVATE_KEY` or `_BASE64` | Yes | App private key, stored only in runtime secret env |
| `P0_PAY_ALIPAY_PUBLIC_KEY` or `_BASE64` | Yes | Alipay public key used for callback verification |
| `P0_PAY_ALIPAY_NOTIFY_URL` | Yes | Public callback URL for Alipay asynchronous notification |
| `P0_PAY_ALIPAY_GATEWAY_URL` | No | Defaults to `https://openapi.alipay.com/gateway.do` |

## 4. Current Minimum Closed Loop

1. Server creates P0-Pay payment order.
2. Server returns Alipay `sdk_payload` with signed APP Pay order string.
3. Flutter invokes native Alipay SDK when running on a supported mobile platform.
4. Alipay calls Server callback URL.
5. Server verifies RSA2 callback signature.
6. Server updates payment order and business pricing object.
7. Flutter polls BFF/Server read model and only displays the result.

## 5. Retained But Not Opened

- Manual Alipay console creation / review submission.
- Runtime secret provisioning in repository.
- Automatic real-money UAT without whitelist.
- Generic wallet, balance, invoice, payout, or fund pool.
- BFF or Flutter callback endpoints.
- Flutter-owned success judgment.

## 6. Later Extension Slots

- Alipay certificate signing mode if required by later fund-out interfaces.
- Server IP whitelist.
- Formal refund API execution package.
- Public callback ingress allowlist and replay window hardening.
- iOS native SDK callback URL scheme hardening.
- Admin finance operation console.

## 7. Stage Gate

| Gate | Verdict |
|---|---|
| APP Pay server signing | Go |
| Alipay callback verification | Go |
| Android native SDK bridge | Go |
| iOS SDK bridge | Conditional Go, retained for next native package |
| Production real-money open | No-Go until Alipay app online, merchant binding, secrets, callback domain, and whitelist UAT pass |
