# App P0-D 上架合规最小入口补齐核查表 Addendum

更新时间：2026-05-01

适用范围：全 App P0 六主线中的「上架合规」。本文件只冻结最低可达入口、文案边界和后续门禁，不代表完整应用商店合规终审通过。

## 1. 总裁决

| 项 | 结论 |
| --- | --- |
| 当前状态 | Conditional Pass：最低入口补齐；完整上架合规仍需人工 runtime 与法务复核 |
| 是否允许进入第 8 天 | 允许 |
| 是否允许声明 full pass | 不允许 |
| 是否新增业务能力 | 否 |
| 是否新增 BFF / Server 接口 | 否 |
| 是否涉及支付、信用、会员、工单、settings、feature flags 扩写 | 否 |
| 最大残余风险 | 真机截图、SDK 清单、权限清单、客服 SLA、账号注销实际处理流程仍需按真实运行时与上架材料复核 |

## 2. 最小闭环矩阵

| 合规项 | 当前入口 | 当前处理方式 | 当前状态 | 依据类型 |
| --- | --- | --- | --- | --- |
| 用户协议 | 登录页勾选与法律文书页 | 展示本地 legal asset | Conditional Pass | 代码：`apps/mobile/lib/features/profile/presentation/profile_login_page.dart`；代码：`apps/mobile/assets/legal/user_agreement.md` |
| 隐私政策 | 登录页勾选、设置页、隐私与权限说明页 | 展示本地 legal asset，并同步 docs/legal 口径 | Conditional Pass | 代码：`apps/mobile/lib/features/profile/presentation/profile_privacy_permission_info_page.dart`；文书：`docs/legal/privacy_policy.md` |
| 账号注销 / 删除账号 | 设置页「账号注销 / 删除账号」 | 当前只提供受理说明和客服邮箱，不承诺一键自助删除 | Conditional Pass | 代码：`apps/mobile/lib/features/profile/presentation/profile_settings_page.dart`；文书：`docs/legal/privacy_policy.md` |
| 客服与投诉 | 设置页「客服与投诉」 | 当前提供客服邮箱 `182401625@qq.com` | Conditional Pass | 代码：`apps/mobile/lib/features/profile/presentation/profile_settings_page.dart` |
| SDK 与第三方能力说明 | 隐私与权限说明页 | 当前为最小静态说明，要求以后按真实 SDK 更新 | Conditional Pass | 代码：`apps/mobile/lib/features/profile/presentation/profile_privacy_permission_info_page.dart`；文书：`docs/legal/privacy_policy.md` |
| 权限说明 | 隐私与权限说明页 | 说明相机、相册、通知等按实际使用场景申请 | Conditional Pass | 代码：`apps/mobile/lib/features/profile/presentation/profile_privacy_permission_info_page.dart` |
| iOS 权限用途说明 | iOS `Info.plist` | 已补齐定位、相机、相册用途说明；不新增采集能力 | Pass at plist level | 代码：`apps/mobile/ios/Runner/Info.plist` |
| 支付说明 | 隐私与权限说明页 | 明确当前不开放完整支付结算链路，不承诺资金闭环 | Conditional Pass | 代码：`apps/mobile/lib/features/profile/presentation/profile_privacy_permission_info_page.dart`；Root AGENTS Phase 0 guardrail |

## 3. 本轮补齐内容

| 变更点 | 说明 | 是否扩张业务 |
| --- | --- | --- |
| 设置页新增账号注销 / 删除账号入口 | 只展示受理说明、保留合规留痕边界，不直连删除接口 | 否 |
| 设置页新增客服与投诉入口 | 只提供客服邮箱和受理口径，不引入工单系统 | 否 |
| 隐私与权限说明页新增客服、注销、SDK、支付说明 | 统一上架最低说明入口 | 否 |
| `docs/legal/privacy_policy.md` 与 App asset 同步 | 将「自行注销」改为「受理说明 + 邮箱受理」，避免虚假承诺 | 否 |
| `Info.plist` 补齐相机/相册用途说明 | 只补 `NSCameraUsageDescription`、`NSPhotoLibraryUsageDescription`，保留定位用途说明 | 否 |

## 4. 不允许声明的能力

| 能力 | 当前裁决 | 原因 |
| --- | --- | --- |
| 一键自助注销账号 | 不允许声明 | 当前未冻结 Server 删除状态机、审计保留规则、争议留痕处理 |
| 完整客服工单系统 | 不进入 P0 | 会扩成工单重系统，超出 Phase 0 |
| 完整 SDK 自动披露中心 | 不进入 P0 | 需要真实 SDK 清单、商店材料与构建产物共同复核 |
| 完整支付生产闭环 | 不进入 P0 | Root AGENTS 明确禁止 payment / billing / settlement 扩写 |
| 完整法务合规通过 | 不允许声明 | 需要人工 runtime、应用商店材料、真实隐私采集与第三方 SDK 复核 |

## 5. 验证记录

| 验证项 | 结果 |
| --- | --- |
| Dart 格式化 | 已执行：`dart format apps/mobile/lib/features/profile/presentation/profile_settings_page.dart apps/mobile/lib/features/profile/presentation/profile_privacy_permission_info_page.dart` |
| App legal asset 与 docs/legal 隐私政策同步 | 已执行：`diff -u docs/legal/privacy_policy.md apps/mobile/assets/legal/privacy_policy.md`，无差异输出 |
| iOS Info.plist 格式 | 已通过：`plutil -lint apps/mobile/ios/Runner/Info.plist` |
| iOS 权限说明键 | 已确认：`NSLocationWhenInUseUsageDescription`、`NSCameraUsageDescription`、`NSPhotoLibraryUsageDescription` |
| Flutter 目标测试 | 已通过：`flutter test test/profile_page_test.dart --name "settings page opens privacy permissions and legal documents"` |
| Diff 空白检查 | 已通过：`git diff --check -- apps/mobile/lib/features/profile/presentation/profile_settings_page.dart apps/mobile/lib/features/profile/presentation/profile_privacy_permission_info_page.dart docs/legal/privacy_policy.md apps/mobile/assets/legal/privacy_policy.md` |

## 6. 需要人工 runtime 复核项

| 核验项 | 需要提供的结果 | 阻断级别 |
| --- | --- | --- |
| 登录页协议与隐私政策是否能从真实 App 入口打开 | 截图或操作结果 | P0 上架合规阻断 |
| 设置页是否能进入账号注销 / 删除账号说明 | 截图或操作结果 | P0 上架合规阻断 |
| 设置页是否能进入客服与投诉说明 | 截图或操作结果 | P0 上架合规阻断 |
| 隐私与权限说明页是否能看到 SDK、权限、支付说明 | 截图或操作结果 | P0 上架合规阻断 |
| 实际构建包 SDK 清单是否与隐私政策一致 | 构建材料或人工清单 | 上架前阻断 |
| iOS 真机权限弹窗是否展示定位、相机、相册用途说明 | 截图或操作结果 | 上架前阻断 |

## 7. 下一步

第 8 天只允许进入 Admin IA / Shell 轻度规整：整理命名、边界和现有页面职责，不新增接口、不新增状态机、不把 Admin 做成第二业务真值。
