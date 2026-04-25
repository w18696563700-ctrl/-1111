# Exhibition Trade Task P0-Pay Day19 Real-Account UAT Receipt Addendum V1.3

status: uat_receipt
planned_gate_date: 2026-05-19
actual_execution_date_local: 2026-04-25
owner: Codex Control
scope: real-account dual-account UAT, P0-Pay fixed-price bid chain

## 0. Conclusion

2026-05-19 UAT 第 1 轮双账号完整链路已执行。

Gate decision:

- Server / BFF business chain: `passed`
- Flutter project-list and project-detail basic readback: `passed`
- Flutter project-detail P0-Pay full read-only fund-state display: `partial`
- Messages building automatic project handoff for this new UAT project: `failed`
- Overall Day19 UAT: `conditional_pass_for_business_truth`, `no_go_for_100_percent_uat_signoff`

The current stage is fit to enter 2026-05-20 issue repair and evidence补齐. It is not fit for production release, gray release, or real-money payment trial.

## 1. Real Accounts Used

Publisher side:

- displayed account: `重庆海川展览工厂`
- organization: `重庆坤特展览展示有限公司`
- organizationId: `e6bf4567-016e-45f9-9420-9c950237690e`
- session status: `valid`
- certification status: `approved`

Factory side:

- displayed account: `江北嘴嘴帅`
- organization: `重庆展宏展览展示有限公司`
- organizationId: `bdfb4523-aeb7-4b56-89a1-992170fb5d98`
- session status: `valid`
- certification status: `approved`

Sensitive runtime tokens, payment callback secret values, and mobile numbers are not recorded in this receipt.

## 2. UI Preflight

Observed with Computer Use:

1. Both accounts were already logged in.
2. `江北嘴嘴帅` entered `去发布项目` and was blocked by UI with `当前创建资格未通过`.
3. `重庆海川展览工厂` entered `去发布项目` and could access the create-project form.
4. Because the create-project form was not stable enough for full manual entry during this UAT, the write chain was executed through BFF using the two valid real sessions after explicit user approval.

Boundary:

- No real Alipay or WeChat final payment confirmation was touched.
- Payment/preauthorization application used the signed `other` test callback path.

## 3. Business Chain Evidence

Run:

- runId: `uat-20260425-1777097443318-7cff68`
- taskId: `8583f40e-5b65-4be9-9476-0e902007da2f`
- bidId: `9b81993e-2132-41fa-9e71-53d7c54443c0`
- authorizationId: `ac6ac630-2284-4b68-bc43-b5c315bd61ed`

Executed steps:

1. Publisher created fixed-price bid task through BFF.
   - HTTP status: `202`
   - task status: `published`
   - publish gate: `passed`
2. Factory submitted fixed-price bid through BFF.
   - HTTP status: `202`
   - bid status: `pending_service_fee_authorization`
   - quoted amount: `88000.00`
   - estimated platform service fee: `2640.00`
3. Factory completed platform service fee preauthorization through the test channel.
   - create status: `202`
   - authorize-init status: `202`
   - signed callback status: `applied`
   - authorization readback: `authorized`
4. Publisher selected the factory.
   - award status: `202`
   - award state: `converted_to_order`
   - orderId: `ca606463-987a-4e18-bcd1-3775165b4cb8`
   - contractId: `a8fe613e-3c2d-4ac0-b19d-e4427adeda3c`
5. Publisher and factory completed contract confirmation.
   - publisher confirmation: `pending_counterparty`
   - factory confirmation: `confirmed`
   - final confirmed amount: `90000.00`
   - final platform service fee: `2700.00`
   - authorization readback: `charged`

DB readback:

- project state: `converted_to_order`
- bid state: `awarded`
- authorization status: `charged`
- estimated fee amount: `2640.00`
- final fee amount: `2700.00`
- authorizedAt: `2026-04-25T06:10:43.539Z`
- chargedAt: `2026-04-25T06:10:43.654Z`

## 4. BFF Read-Only Projection Evidence

Route:

- `GET /api/app/exhibition/trade-tasks/8583f40e-5b65-4be9-9476-0e902007da2f`

Readback:

- taskType: `fixed_price_bid`
- projectName: `UAT-20260425 双账号 P0Pay uat-20260425-1777097443318-7cff68`
- messageHandoff.readOnly: `true`
- contractHandoff.available: `true`
- p0PaySummary.readOnly: `true`

Route:

- `GET /api/app/exhibition/trade-tasks/8583f40e-5b65-4be9-9476-0e902007da2f/p0-pay-summary`

Readback:

- platformServiceFee.status: `charged`
- platformServiceFee.estimatedFeeAmount: `2640.00`
- platformServiceFee.finalFeeAmount: `2700.00`
- inquiryDeposit.status: `not_required`
- contractConfirmation.status: `confirmed`
- messageDisplaySummary.displayAllowed: `true`
- messageDisplaySummary.readOnly: `true`
- messageDisplaySummary.statusTextKey: `charged`

Decision:

- Server truth and BFF read-only P0-Pay projection are complete for this UAT chain.

## 5. Flutter / Computer Use Evidence

Publisher-side project list:

- `项目展示` list displayed the UAT project.
- visible state: `已被承接`
- visible project number: `P0PAY-1777097443365-BC85C5B4`
- visible budget: `¥100000`
- visible area: `128 ㎡`

Publisher-side project detail:

- `项目详情` opened successfully.
- visible title: `UAT-20260425 P0Pay 展会 uat-20260425-1777097443318-7cff68`
- visible state: `已被承接`
- visible description includes the UAT no-real-payment note.
- visible continuation copy states the viewer is the publisher and should continue through `我的项目`.

Factory-side list:

- the factory account could see a controlled project card with `已被承接`.
- due to current project-name permission strategy, the title remained `项目名称需申请查看`.

Messages building:

- `消息 -> 项目沟通` opened successfully.
- current message-center conversation still pointed to the older `西洽会` project-name-access conversation.
- the new UAT project was not listed in the message-center conversation index.

## 6. Message / Thread Readback

For taskId `8583f40e-5b65-4be9-9476-0e902007da2f`, cloud DB readback:

- `bid_private_threads`: `0`
- `bid_thread_confirmation_cards`: `0`
- `bid_thread_messages`: `0`
- `project_communication_threads`: `0`
- `project_communication_messages`: `0`
- `project_communication_read_cursors`: `0`

BFF message index:

- `GET /api/app/message/interactions?lane=project_communication`
- publisher count: `1`, but the item points to historical project `c788eaff-6243-4e97-8be3-c4e174ee7944`
- factory count: `1`, but the item points to historical project `c788eaff-6243-4e97-8be3-c4e174ee7944`
- contains UAT taskId or `UAT-20260425`: `false`

Decision:

- The UAT business chain did not automatically seed or project the new project into the messages building.
- This is a Day20 repair item, not a payment truth failure.

## 7. Issues For 2026-05-20

P0 issues:

1. On bid submission / award / contract confirmation, Server must seed or update the approved message interaction carrier for the active project-bid relationship.
2. BFF `GET /api/app/message/interactions?lane=project_communication` must include the new UAT project conversation after the bid/award chain creates the relationship.
3. Flutter messages building must surface the latest UAT project rather than only the historical project-name-access conversation.
4. Flutter project detail should render the full read-only P0-Pay summary already available from BFF:
   - platform service fee status `charged`
   - final fee amount `2700.00`
   - contract confirmation status `confirmed`
   - `messageDisplaySummary.readOnly=true`

P1 issues:

1. The create-project form needs input stability verification for longer UAT strings and all required fields.
2. Factory-side project list should make the relationship reason clearer when the project name remains permission-controlled after bid award.

## 8. Boundary Confirmation

This UAT did not implement, touch, or validate:

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

## 9. Final Gate Result

Day19 status:

- business truth: `passed`
- BFF payment projection: `passed`
- Flutter list/detail basic visibility: `passed`
- Flutter full payment-summary visibility: `partial`
- messages building UAT project handoff: `failed`
- final: `conditional_pass_for_day20_repair`, `no_go_for_release`

Next allowed work:

- 2026-05-20 修复 UAT 问题，补文书回执和证据.
