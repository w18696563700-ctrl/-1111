---
owner: 总控 Agent
status: frozen
purpose: Freeze Day 7 P0-D app listing compliance minimum-entry checklist and residual No-Go boundaries.
layer: L0 SSOT
freeze_date_local: 2026-05-01
inputs_canonical:
  - AGENTS.md
  - docs/legal/user_agreement.md
  - docs/legal/privacy_policy.md
  - apps/mobile/assets/legal/user_agreement.md
  - apps/mobile/assets/legal/privacy_policy.md
  - docs/00_ssot/auth_login_legal_consent_minimum_closure_addendum.md
  - docs/04_frontend/auth_login_legal_consent_frontend_surface_addendum.md
  - docs/00_ssot/profile_settings_p0_account_logout_day1_boundary_freeze_addendum.md
  - docs/00_ssot/profile_settings_p0_privacy_location_notification_day3_day5_boundary_freeze_addendum.md
  - apps/mobile/lib/features/profile/presentation/profile_login_page.dart
  - apps/mobile/lib/features/profile/presentation/profile_identity_legal_pages.dart
  - apps/mobile/lib/features/profile/presentation/profile_settings_page.dart
  - apps/mobile/lib/features/profile/presentation/profile_privacy_permission_info_page.dart
---

# 《P0-D 上架合规最低入口核查表》

## 1. 总裁决

P0-D 当前结论固定为：`Conditional Pass for minimum app-visible compliance entries`。

当前只允许声明：

- App 已具备登录页协议/隐私勾选与入口。
- App 已具备设置页法律文书、隐私与权限说明、定位/通知系统设置跳转。
- App 已补齐客服邮箱、账号注销/删除账号受理说明、SDK/第三方能力最小说明、支付只读说明入口。
- iOS `Info.plist` 已补齐定位、相机、相册用途说明；本轮只做权限说明配置，不新增采集能力。
- 文书已同步把注销口径从“一键自助注销”降为“应用内受理说明 + 客服邮箱受理”，避免承诺未实现能力。

当前不得声明：

- 完整上架合规已通过。
- 账号一键自助注销已实现。
- 正式 SDK 清单/隐私清单已法务确认。
- 真实生产支付、退款、结算、开票、财务后台已上线。
- 完整客服工单台、投诉 SLA、Admin 全量治理台已上线。

## 2. 合规入口矩阵

| 合规项 | 当前 App 入口 | 文书/代码依据 | 当前状态 | 风险 | 下一步 |
| --- | --- | --- | --- | --- | --- |
| 用户协议 | 登录页勾选区；设置 -> 隐私与权限说明 -> 用户协议 | `profile_login_page.dart`、`profile_identity_legal_pages.dart`、`docs/legal/user_agreement.md`、`apps/mobile/assets/legal/user_agreement.md` | `Conditional Pass` | 正文仍需上线前法务审定 | 法务定稿后同步 asset |
| 隐私政策 | 登录页勾选区；设置 -> 隐私与权限说明 -> 隐私政策 | `profile_identity_legal_pages.dart`、`docs/legal/privacy_policy.md`、`apps/mobile/assets/legal/privacy_policy.md` | `Conditional Pass` | SDK/隐私清单需逐项核对 | 上架前形成正式 SDK/隐私清单 |
| 登录同意 | 未勾选前不可发验证码或登录；请求传 `consentAccepted` | `auth_login_legal_consent_*` 文书与 `profile_login_page.dart` | `Pass at code level` | runtime 仍需人工复核 | Day9 由人工提供登录核验结果 |
| 权限说明 | 设置 -> 隐私与权限说明 | `profile_settings_page.dart`、`profile_privacy_permission_info_page.dart` | `Pass at minimum` | 只覆盖当前可见权限，不是动态权限审计中心 | 保持只读说明 |
| iOS 权限用途说明 | iOS 系统授权弹窗 | `apps/mobile/ios/Runner/Info.plist` | `Pass at plist level` | 仍需真机/构建包确认弹窗文案 | 上架前随真机材料复核 |
| 定位权限 | 设置 -> 定位权限；只读授权状态与系统设置跳转 | `profile_settings_p0_privacy_location_notification_day3_day5_boundary_freeze_addendum.md`、`profile_settings_page.dart` | `Pass at minimum` | 真机系统设置跳转需 UAT | Day9/后续真机补证 |
| 系统通知 | 设置 -> 系统通知；跳转应用系统设置 | `profile_settings_page.dart` | `Conditional Pass` | 不是专用通知设置页，也不是推送链路 | 不接推送 SDK；真机补证 |
| 客服/投诉 | 设置 -> 关于我们 -> 客服与投诉；隐私与权限说明 -> 客服与投诉 | `profile_settings_page.dart`、`profile_privacy_permission_info_page.dart`、`docs/legal/*` | `Conditional Pass` | 只有邮箱，客服电话暂未公示；无 SLA | 后续补客服投诉处理规则 |
| 账号注销/删除账号 | 设置 -> 账号与安全 -> 账号注销/删除账号；隐私与权限说明同名入口 | `profile_settings_page.dart`、`profile_privacy_permission_info_page.dart`、`privacy_policy.md` | `Conditional Pass` | 只是受理说明，不是一键自助注销 | 后续补正式注销规则与处理时限 |
| SDK/第三方能力说明 | 隐私与权限说明 -> SDK 与第三方能力说明 | `profile_privacy_permission_info_page.dart`、`privacy_policy.md` | `Conditional Pass` | 非正式应用商店 SDK 清单 | 上架前形成独立清单 |
| 支付说明 | 隐私与权限说明 -> 支付说明；我的页支付/账单只读面 | `profile_privacy_permission_info_page.dart`、支付/账单只读页面 | `Conditional Pass` | 真实支付资质、callback、provider 侧证据未完成 | 不宣称真实支付上线 |

## 3. 本日代码与文书补齐范围

本日已补：

1. 设置页“账号注销 / 删除账号”受理说明入口。
2. 设置页“客服与投诉”入口。
3. 隐私与权限说明页“客服与投诉”入口。
4. 隐私与权限说明页“账号注销 / 删除账号”受理说明入口。
5. 隐私与权限说明页“SDK 与第三方能力”最小说明。
6. 隐私与权限说明页“支付说明”只读说明。
7. `docs/legal/privacy_policy.md` 与 `apps/mobile/assets/legal/privacy_policy.md` 注销口径同步改为“客服邮箱受理，不承诺一键自助注销”。
8. `apps/mobile/ios/Runner/Info.plist` 补齐 `NSCameraUsageDescription`、`NSPhotoLibraryUsageDescription`，保留 `NSLocationWhenInUseUsageDescription`。

本日未补：

- 独立帮助中心。
- 完整客服工单系统。
- 自助注销接口。
- SDK 自动清单。
- 推送 SDK。
- 支付生产链路。
- 任何 BFF / Server / contracts 变更。

## 4. No-Go 清单

| 项 | 当前裁决 | 原因 |
| --- | --- | --- |
| 完整上架合规 | `No-Go` | 法务终稿、SDK 清单、商店隐私清单、支付资质、客服电话/SLA 均待复核。 |
| 一键自助注销 | `No-Go` | 本轮只做受理说明，不做身份核验、注销状态机、通知闭环。 |
| 真实支付上线 | `No-Go` | Provider sandbox/production callback、商户、密钥、白名单、UAT 仍待证据。 |
| 客服工单系统 | `No-Go` | 当前只提供邮箱受理，不做工单状态流转。 |
| SDK 动态披露中心 | `No-Go` | 当前只做静态最小说明，正式清单需上架前专项核对。 |
| Admin 全量治理台 | `No-Go` | 本轮 P0 只收口最小治理入口，Admin 不成为第二业务真值。 |

## 5. 人工复核项

Day9 或上架前必须由人工提供以下结果：

1. 登录页未勾选协议时，验证码和登录不可执行。
2. 登录页用户协议、隐私政策均可打开并显示正文。
3. 设置页“隐私与权限说明”可打开。
4. 设置页“客服与投诉”可打开并显示邮箱。
5. 设置页“账号注销 / 删除账号”可打开并明确不是一键注销。
6. 隐私与权限说明页包含 SDK/第三方能力与支付说明。
7. 真机定位权限和系统通知入口可跳转系统设置。
8. 应用商店 SDK 清单、隐私清单与实际包内 SDK 一致。
9. iOS 真机权限弹窗展示定位、相机、相册用途说明。

## 6. 第 7 天验收结论

第 7 天状态固定为：`PASS WITH LEGAL / STORE REVIEW REQUIRED`。

通过理由：

- App 内最低合规入口已经可见。
- iOS 定位、相机、相册用途说明已在 `Info.plist` 中具备，`plutil -lint` 通过。
- 文案不再承诺未实现的一键注销。
- 支付、SDK、客服、注销均按受理/说明口径处理，没有扩写业务系统。
- 未改 BFF、Server、contracts、数据库或云端。

下一步进入第 8 天：只做 Admin IA/Shell 轻度规整或冻结说明，不新增接口、不新增状态机、不扩展 Admin 业务真值。
