# Project Transaction Lifecycle Day0611-Day0612 Computer Use UAT / Final Acceptance Pack No-Go Addendum

计划日期：2026-06-11 至 2026-06-12
执行记录日期：2026-04-26
状态：Final acceptance No-Go

## 1. 结论

Day0611 双账号完整点击验收未通过；Day0612 不能形成 100% 生产验收。

原因不是 Server/BFF 路由或 schema 当前不可用，而是真实 App 会话与业务数据闭环未达标：

- Computer Use 当前只暴露一个可操作 `mobile` 窗口；
- 该窗口停留在 `登录入口`，未登录；
- 没有可操作的发布方 + 承接方双窗口；
- 云上 DB 当前 `orders=0`、`project_counterparty_ratings=0`、`credit_triggers=0`、`credit_ledgers=0`；
- 因此无法通过 UI 完成“选择合作方 -> 生成订单 -> 完工 -> 双方互评 -> 信用触发”。

更稳：保留 No-Go，不用 mock、DB 手工插入、actor hint 或单账号窗口冒充双账号验收。

更省成本：复用当前真实项目和真实竞标，等两个真实登录窗口恢复后继续，不重造项目、不重发版。

更适合当前阶段：把 Day0612 输出为 final acceptance pack 的 No-Go 版，明确剩余门禁。

风险更大：把 Day0610 route/schema 通过写成 100% 生产验收。

## 2. 当前最小闭环

已具备：

- 云上 Server/BFF R2 候选 active。
- migration/schema 已对齐。
- app-facing 路由已 materialized。
- 真实项目已存在。
- 真实竞标已存在。
- Flutter QA/UI 负向修复已通过本地测试。

未具备：

- 可操作的双账号 Flutter 会话。
- 发布方 UI 选择合作方。
- 真实订单。
- 订单完成态。
- 双方互评。
- 评价触发的信用 shadow/ledger 证据。

## 3. Computer Use Observation

Computer Use 当前观察：

| Item | Value | Gate |
| --- | --- | --- |
| App | `mobile / com.example.mobile` | Pass |
| Visible window count | one operable window | Fail for dual-account |
| Current screen | `登录入口` | Fail |
| Login state | not authenticated | Fail |
| Buyer / publisher visible session | Not available | Fail |
| Seller / bidder visible session | Not available | Fail |

The visible UI contains：

- `登录入口`
- `验证码登录`
- `账号密码登录`
- `请输入可接收验证码的手机号`
- `我已阅读并同意《用户协议》和《隐私政策》`

No business action was clicked because doing so from an unauthenticated window cannot produce production UAT evidence.

## 4. Required Day0611 Click Script

This is the exact resume script once two visible logged-in windows are available.

### 4.1 Account precheck

Window A must be publisher / buyer：

- `我的 -> 我的公司`
- expected organization：`重庆坤特展览展示有限公司`

Window B must be bidder / seller：

- `我的 -> 我的公司`
- expected organization：`重庆展宏展览展示有限公司`

Fail if both windows show the same account or same organization.

### 4.2 Publisher selects partner

Use existing project：

- projectId：`c788eaff-6243-4e97-8be3-c4e174ee7944`
- title：`西洽会 - 泸州`
- bidId：`6e936969-3520-44bc-8804-1c804351423e`

Expected publisher UI anchors：

- `发布方选择合作方`
- `投标 ID`
- `选择为合作方`
- `确认选择合作方`
- `合作方选择已受理`
- `订单 ID`

DB proof after success：

- one new `orders` row;
- carries `project_id / id / buyer_organization_id / supplier_organization_id`.

### 4.3 Seller requests completion

Seller opens order detail.

Expected seller anchors：

- `订单状态卡`
- `当前账号按承接方处理，可提交申请完工`
- `申请完工`
- after click：`已申请完工`

### 4.4 Publisher confirms completion

Publisher opens same order detail.

Expected publisher anchors：

- `当前账号按发布方处理，可确认完成或拒绝完工`
- `确认完成`
- after click：`当前订单已进入完成态`
- `查看双方互评入口`

DB proof after success：

- `orders.state = completed`;
- `orders.completion_request_state = confirmed`;
- `orders.completed_at IS NOT NULL`.

### 4.5 Both sides submit counterparty rating

Each side enters：

- `查看双方互评入口`

Expected rating page anchors：

- `双方互评入口`
- `当前互评锚点`
- `当前订单 ID`
- `当前项目 ID`
- `被评主体 ID`
- `当前状态：待评价`
- `提交双方互评`
- after submit：`双方互评已提交`

Both directions must exist：

- buyer rates seller;
- seller rates buyer.

DB proof after success：

- two `project_counterparty_ratings` rows for the same `order_id`;
- unique rater/ratee directions;
- no duplicate direction.

### 4.6 Credit proof

Credit proof must be read-only DB evidence, not Flutter calculation.

Expected：

- `organization_shadow_credit_recompute_triggers.source_type = project_counterparty_rating`
- `organization_shadow_credit_ledgers.source_type = project_counterparty_rating`
- source rating/order anchors present.

## 5. Final Acceptance Pack

### 5.1 Release Note

R2 candidate includes：

- project detail owner-side bid candidate projection;
- bid selection to order route family;
- order detail with `projectId` anchor;
- order completion request/confirm route family;
- new `ProjectCounterpartyRating` entry/submit route family;
- credit shadow `source_type` alignment;
- Flutter controlled error/empty/loading/disabled states for transaction chain.

### 5.2 Cutover Position

Cutover status：No-Go.

Allowed：

- continue gray UAT;
- keep current R2 candidate running if no runtime regression;
- resume Day0611 after two logged-in windows are available.

Not allowed：

- production acceptance announcement;
- full cutover;
- cleanup of old fallback routes;
- deletion of legacy `/api/app/rating/*`;
- DB-manufactured order/rating/credit proof.

### 5.3 Rollback Position

No rollback executed.

Rollback should only be used for runtime regression. Current UAT blocker is login/session availability, not a proven R2 runtime fault.

Candidate rollback target remains：

- Server：`/srv/releases/server/20260425204500-order-detail-projectid-cloud-patch`
- BFF：`/srv/releases/bff/20260425204500-order-detail-projectid-cloud-patch/apps/bff`

## 6. 上线门禁核查表

Passed gates：

- Day0610 R2 runtime route/schema gate passed.
- Health/live and health/ready passed.
- Critical migration/schema present.
- Existing project and bid are clean resume anchors.
- Flutter QA/UI local tests passed in Day0608-Day0609.

Failed gates：

- Two logged-in visible app sessions missing.
- Publisher did not select partner through UI.
- Real order was not generated.
- Order was not completed.
- Both sides did not submit ratings.
- Credit trigger/ledger proof absent.

Veto gates：

- `orders=0`
- `project_counterparty_ratings=0`
- `credit_triggers=0`
- `credit_ledgers=0`
- active visible App window is login page

Final decision：

- `Day0611 Computer Use UAT = No-Go`
- `Day0612 final acceptance pack = No-Go`
- `100% production acceptance = Not satisfied`

## 7. Resume Condition

To resume and convert this No-Go pack into a Pass pack, provide or restore：

1. one visible `mobile` window logged in as publisher organization `重庆坤特展览展示有限公司`;
2. one visible `mobile` window logged in as bidder organization `重庆展宏展览展示有限公司`;
3. keep the current real project and bid untouched;
4. allow Computer Use to complete the Day0611 click script;
5. allow read-only DB verification after each business step.
