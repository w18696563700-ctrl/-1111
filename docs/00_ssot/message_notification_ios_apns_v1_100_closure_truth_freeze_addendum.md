---
owner: Codex 总控
status: frozen
purpose: Freeze the L0 truth for the 100-point minimum closure of in-app notifications, iOS APNs system push, default sound/vibration, and routeTarget return.
layer: L0 SSOT
---

# 消息提示 / iOS APNs V1 100 分闭环 Truth Freeze Addendum

## 1. 总裁决

本 addendum 冻结 `消息提示 / iOS APNs V1 100 分闭环` 的验收口径。

100 分闭环只包含：

- 站内通知中心：铃铛、来源分组、未读、mark-read、routeTarget 引导。
- 站内来源：`project_communication`、`forum_interaction`、`business_todo`、`system`。
- iOS-only APNs：获取 APNs token、注册 device token、Server delivery attempt、真实 iPhone 后台 / 锁屏系统通知。
- 系统默认声音和默认震动：跟随 iOS 系统通知行为，不做自定义震动。
- 点击系统通知回 App：消费同一套 `routeTarget`，不可定位时中文兜底且不改业务状态。

本轮不是通用通知平台，不是新 IM，不是营销推送，不是通知偏好中心，不是 Android FCM。

## 2. Relationship With Existing Truth

本 addendum 是总控闭环冻结，建立在以下既有 truth 之上：

- `message_notification_guidance_v1_truth_freeze_addendum.md`
- `message_notification_guidance_v1_contracts_addendum.md`
- `stale_notification_route_target_availability_v1_truth_freeze_addendum.md`
- `stale_notification_route_target_availability_v1_contracts_addendum.md`
- `project_communication_notification_preview_v1_truth_freeze_addendum.md`
- `project_communication_notification_preview_v1_contracts_addendum.md`
- `ios_apns_cloud_credentials_and_real_push_uat_gate_addendum.md`

若本 addendum 与早期通知文书表述不一致，以本 addendum 的 100 分最小闭环边界为准；它不放大早期文书的非目标项。

## 3. Truth Ownership

| 真值 | 唯一归属 | 说明 |
| --- | --- | --- |
| app notification | Server | `app_notifications` 是普通通知列表和 unread 的真值。 |
| device push token | Server | `device_push_tokens` 保存用户 / 设备 / provider / platform / token 活跃状态。 |
| push delivery attempt | Server | `push_delivery_attempts` 只记录系统推送投递尝试，不代表业务完成。 |
| unread bucket | Server | `unread.total` 必须等于各来源 bucket 合计。 |
| routeTarget availability | Server | 可用、过期、无权限、缺上下文都必须可解释。 |
| business todo badge | Server | 仍以 `businessTodoSummary` 和 `entries[].badgeCount` 为真值，不等于普通 unread。 |

BFF 只允许转发、shape、错误映射和登录态承接，不拥有 token truth、unread truth、notification truth、delivery truth 或业务待办 truth。

Flutter 只允许请求权限、读取 token、注册 token、展示通知、导航 routeTarget、请求 mark-read 和展示受控空 / 错 / 失效态。Flutter 不得计算业务待办，不得把推送成功当业务真相，不得本地伪造 unread。

## 4. Source Lane Rules

四个 source lane 必须可解释：

| source | 允许内容 | 禁止内容 |
| --- | --- | --- |
| `project_communication` | 项目沟通消息、项目聊天到达提醒、项目上下文提醒 | 论坛回复 / 点赞 / 关注 |
| `forum_interaction` | 论坛回复、点赞、关注 | 项目沟通、竞标申请、资料确认 |
| `business_todo` | 业务待办提醒的通知入口，如参与申请、需要处理的业务动作 | 项目沟通普通聊天 unread |
| `system` | 平台系统提醒 | 论坛业务状态、项目业务状态 |

论坛互动若要进入铃铛、未读 bucket、系统推送，必须由 Server 写入 `app_notifications` 或等价 Server-owned notification truth。`/api/app/forum/interaction/inbox` 只能是论坛互动 read projection，不得成为第二套 unread truth。

## 5. Mark-Read And RouteTarget Rules

通知已读必须满足：

1. 通知存在。
2. `routeTargetAvailability.state = available` 或等价可用状态。
3. Flutter 成功定位到目标页面。
4. 然后才允许调用 `/api/app/notifications/read`。

以下情况不得自动 mark-read：

- `routeTarget` 缺失。
- `routeTarget` 缺少必要参数。
- 目标已删除、过期、无权限或缺上下文。
- Flutter 只能打开 fallback 列表而没有进入目标详情。

不可定位时必须保留 unread，并显示中文受控提示。不得进入英文错误页，不得用本地推断清除 unread。

## 6. iOS APNs V1 Rules

iOS V1 只走原生 APNs，不引入 Firebase iOS，不引入 Android FCM。

Flutter / iOS 必须完成：

- 请求 iOS 系统通知权限。
- 获取 APNs device token。
- token refresh 后重新注册。
- 调用 `POST /api/app/notifications/device-token/register`，`provider=apns`，`platform=ios`。
- 接收系统通知点击，并把 payload 中的 `routeTarget` 交给 Flutter routeTarget 导航。
- 启动时如存在 pending routeTarget，受控消费一次。

权限拒绝时 App 仍可使用站内通知，不阻塞主流程。

## 7. Sound And Vibration Rules

V1 声音 / 震动只走系统默认行为：

- APNs payload 使用系统默认声音。
- 震动由 iOS 系统通知设置和设备状态决定。
- 不写自定义 vibration pattern。
- 不引入 vibration package。
- 不做免打扰、不做按业务类型开关、不做通知偏好中心。

验收时只能说“默认声音 / 默认震动跟随系统设置通过或未验证”，不得宣称自定义震动完成。

## 8. APNs Delivery Rules

Server APNs delivery attempt 必须至少区分：

- `success`
- `provider_credentials_unavailable`
- `provider_rejected`
- `token_invalid`
- `network_error`
- `unknown_error`

凭据缺失时必须受控降级并记录 attempt，不得静默成功。

`token_invalid` 时允许停用对应 token。

APNs 投递成功不代表：

- 通知已读。
- 业务待办完成。
- 项目状态改变。
- 聊天状态改变。
- 支付、合同、履约状态改变。

## 9. Explicit Non-Goals

本轮不做：

- Android FCM。
- Firebase iOS / Firebase Android。
- 自定义震动。
- 通知偏好中心。
- 免打扰。
- 分业务类型通知开关。
- 营销推送。
- 群发推送。
- Admin 推送运营平台。
- 通用通知平台。
- 泛 IM、私聊、群聊。
- AI workflow message center。
- rule engine。
- email / SMS 聚合。
- 支付、钱包、结算、发票、合同金额、履约。

## 10. 100 分验收口径

100 分完成必须同时满足：

1. SSOT、Contracts、generated 对通知 V1 口径无漂移。
2. Server 四类 source lane 可解释，`unread.total` 与 buckets 一致。
3. 论坛互动若计入铃铛，必须进入 Server notification truth，不得只靠 forum inbox 假未读。
4. BFF 不计算 unread、不保存 token、不记录 delivery attempt。
5. Flutter 铃铛能找到未读、可定位、失败不误清、无 overflow、无英文异常。
6. iOS 真机能请求权限、获取 APNs token、注册 token。
7. Server 能记录 APNs delivery attempt，缺凭据时受控降级，有凭据时可真实发送。
8. 真实 iPhone 后台 / 锁屏收到系统通知。
9. 默认声音 / 默认震动跟随系统。
10. 点击系统通知能回 App routeTarget；不可定位时中文兜底且不改业务状态。

若第 8-10 项未通过，只能判为站内通知闭环或 APNs degraded closure，不能宣称系统推送 / 震动 100 分。

## 11. Runtime And Secret Rules

本地代码、OpenAPI、generated、测试通过都不能证明云端 runtime 已对齐。

云端 UAT 必须单独完成：

- active release / rollback point 核对。
- Server / BFF health。
- APNs secret 受控配置，不进 repo，不进日志，不进回执明文。
- authenticated read-only smoke。
- explicitly approved write / push trigger smoke。
- 真机截图、录屏或日志回执，且不得输出 token、cookie、完整 signed URL、APNs key、手机号密码等敏感信息。

未经部署门禁确认，不得写云端 env、不得重启服务、不得部署、不得执行真实 push UAT。
