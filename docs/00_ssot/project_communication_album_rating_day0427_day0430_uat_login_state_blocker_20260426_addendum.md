---
owner: Codex 总控
status: frozen
layer: L0 UAT blocker receipt
recorded_at_local: 2026-04-26
scope:
  - 2026-04-27 dual-account role verification
  - 2026-04-28 completion request
  - 2026-04-29 completion confirmation
  - 2026-04-30 buyer-to-supplier rating
purpose: >
  Record the Computer Use UAT attempt after the progress catch-up checkpoint.
  The attempt is blocked by unavailable or invalid real App login state, and no
  business state was written.
---

# Day04-27 Day04-30 Computer Use UAT Login-State Blocker Receipt

## 1. Conclusion

The planned Day04-27 to Day04-30 Computer Use execution could not complete.

Reason:

- two visible `mobile` windows exist on the desktop;
- the valid project communication window shows the current account as the
  contractor role and exposes `申请完工`;
- the other visible window cannot serve as the publisher because `我的公司`
  shows `当前会话暂不可用`;
- clicking `申请完工` on the contractor-side order card did not write business
  state because the App returned `当前登录态不可用，请重新登录后再试`.

No manual DB mutation was used. No production acceptance was claimed.

## 2. Tasks Ruling

| Date | Task | Result | Ruling |
| --- | --- | --- | --- |
| 2026-04-26 | checkpoint submit and progress governance | Done | Two commits already exist: docs checkpoint and implementation baseline. |
| 2026-04-27 | double-account same-order communication page role check | Blocked | Contractor-side role visible; publisher-side session unavailable. |
| 2026-04-28 | contractor clicks `申请完工` | Blocked | Button click returned login-state error; DB remains unchanged. |
| 2026-04-29 | publisher clicks `确认完成` | Blocked | No valid publisher window. |
| 2026-04-30 | publisher rates contractor | Blocked | Requires completed order and valid publisher window. |

## 3. UI Evidence Summary

Observed contractor-side order card:

- `订单状态卡`
- `订单 ID: a3c63f04-8c10-44d1-9e0c-710ae00c7211`
- `项目 ID: c788eaff-6243-4e97-8be3-c4e174ee7944`
- `订单状态: 进行中`
- `完工申请状态: 未申请完工`
- `当前账号按承接方处理，可提交申请完工`
- `申请完工`

Observed unavailable publisher-side candidate window:

- `我的公司`
- `当前会话暂不可用`
- `当前没有可验证的会话，我的公司页不展示伪造企业卡片`
- `进入登录入口`

Observed contractor-side click failure:

- `当前动作未完成`
- `当前登录态不可用，请重新登录后再试`
- `回到展览`

## 4. Read-Only DB Evidence After Click Attempt

Read-only DB check after the failed click:

| Item | Value |
| --- | --- |
| orderId | `a3c63f04-8c10-44d1-9e0c-710ae00c7211` |
| order state | `active` |
| completionRequestState | `none` |
| completedAt | `NULL` |
| projectCounterpartyRatings | `0` |
| project counterparty rating credit triggers | `0` |
| project counterparty rating credit ledgers | `0` |

## 5. Gate Decision

This is a login/session blocker, not a permission to bypass the UI.

Allowed next action:

1. user restores two visible logged-in App windows;
2. Window A must be publisher/buyer organization for the real order;
3. Window B must be supplier/contractor organization for the real order;
4. retry contractor `申请完工`;
5. verify DB `completion_request_state=requested`;
6. continue publisher `确认完成`;
7. continue bilateral rating and credit ledger verification.

Not allowed:

- mark Day04-27 to Day04-30 as complete;
- use DB edits to set `requested` or `completed`;
- use actor hints or mock tokens to replace Computer Use evidence;
- claim final production acceptance while ratings and credit ledger remain zero.

## 6. Stability / Cost / Stage Fit

- More stable: stop at the login-state blocker and preserve DB truth.
- More cost-efficient: keep the existing order and resume after session restore;
  do not recreate project, bid, or order.
- More suitable for the current stage: only repair or restore App login sessions,
  then rerun the same UAT script.
- Higher risk: forcing completion by API/DB without a valid real UI session.
