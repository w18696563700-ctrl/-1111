# Project Publish Progress and Sincerity Phase 1 Rule Freeze Addendum

## 0. Gate Verdict

- Current gate: Go for Phase 1 publish-progress visibility and sincerity-payment continuation.
- Formal payment truth owner: Server.
- App-facing projection owner: BFF.
- UI owner: Flutter, display and user action only.
- No-Go in this phase: refund, deduction, payment callback, settlement, or payment-state-machine redesign.

## 1. Minimum Closed Loop

This phase only solves the current publisher confusion:

1. Every page in the project publish chain must show a consistent publish progress indicator.
2. The 200 CNY project-authenticity sincerity money is scoped to the current project.
3. If the current project already has an active sincerity order, Flutter must not create a duplicate order.
4. If the current project has an active order and an order id is available, Flutter may call the existing pay-init route to continue payment.
5. Flutter must show Chinese status and next action text for pending, processing, completed, unavailable, and missing-order cases.

## 2. Frozen Progress Nodes

The publish progress nodes are frozen as:

| Node | Meaning | Truth Owner |
|---|---|---|
| Basic information | Project base fields have been created or are being edited | Server project state plus Flutter form state |
| Quote basis materials | Five quote-basis material categories are available for completion | Server attachment truth |
| Authenticity sincerity money | Current project requires or has completed 200 CNY sincerity money | Server P0-Pay truth |
| Publish confirmation | Publisher confirms no obvious issue and requests formal publish | Server project lifecycle |
| Published | Project is in public bidding surface | Server project lifecycle |

## 3. Page Coverage

Phase 1 publish progress must be visible on:

| Page | Required Display |
|---|---|
| Create project | Current node: Basic information |
| Edit project | Current node follows draft/submitted/published state |
| My project detail | Current node follows submitted/published/active state and sincerity status |

## 4. Sincerity Money Rules

1. The 200 CNY order belongs to the current project only.
2. Server decides whether a project already has an active order.
3. Flutter must never infer payment success from local state, button taps, pay-init success, or browser launch.
4. Flutter may only continue payment when BFF/Server returns an order id or the create-order response returns an order id.
5. If an active order exists but no order id is projected, Flutter must show a refresh/fallback state instead of creating another order.

## 5. Boundary

This phase does:

- Add publish progress display.
- Add read-only sincerity status card.
- Add continue-payment entry for an existing active order.
- Localize active-order conflict and missing-channel failure copy.
- Add minimal fields to pricing summary projection when needed.

This phase does not:

- Implement refund.
- Implement deduction.
- Implement payment callback.
- Change payment provider integration.
- Change final settlement.
- Treat pay-init as payment success.

## 6. Stage Gate

Allowed next stage after this addendum:

- Contracts / field freeze for `pricing-summary` continuation fields.

Blocked until separate freeze:

- Payment callback truth changes.
- Refund / deduction / breach-money handling.
- Payment channel redesign.
