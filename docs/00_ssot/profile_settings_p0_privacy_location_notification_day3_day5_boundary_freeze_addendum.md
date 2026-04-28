---
owner: Codex 总控
status: frozen
purpose: Freeze the Day 3-5 P0 boundary for profile settings legal handoff, location permission status, and system notification settings entry without widening into push, background location, or backend work.
layer: L0 SSOT
freeze_date_local: 2026-04-28
---

# 《设置 P0 隐私、定位、通知 Day3-Day5 边界冻结单》

## 1. 当前结论

本轮继续只改 Flutter App 前端，不修改本地 BFF / Server，不新增云端接口。

本冻结单覆盖：

1. 设置页接入《用户协议》。
2. 设置页接入《隐私政策》。
3. 设置页接入隐私与权限说明。
4. 设置页展示定位权限状态。
5. 设置页提供定位权限状态刷新。
6. 设置页提供打开系统定位设置 / 应用权限设置。
7. 设置页提供系统通知入口，跳转应用系统设置。

## 2. 运行真相

- 本地只有 Flutter App。
- `BFF` 和 `Server` 在阿里云。
- 联调默认走：
  - `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`
- 本轮无 BFF / Server 变更需求。

## 3. 正式真源

- `docs/legal/user_agreement.md`
  - 已冻结用户协议正文。
- `docs/legal/privacy_policy.md`
  - 已冻结隐私政策正文。
  - 账号登录与退出、定位与地区上下文、撤回授权、终端能力清单已有正式说明。
- `apps/mobile/assets/legal/user_agreement.md`
  - App 内置用户协议资产。
- `apps/mobile/assets/legal/privacy_policy.md`
  - App 内置隐私政策资产。
- `apps/mobile/lib/core/location/device_location_service.dart`
  - 现有定位能力入口。

## 4. Day 3 最小闭环

- 设置页不得继续显示：
  - `当前保持受控开放`
- 设置页必须能进入：
  - 《用户协议》
  - 《隐私政策》
  - 隐私与权限说明
- 隐私与权限说明只做当前已开放能力说明，不新增未冻结能力承诺。

## 5. Day 4 最小闭环

- 定位权限状态只允许读取：
  - 系统定位服务是否开启
  - App 定位授权状态
- 定位权限状态读取禁止：
  - 主动请求定位权限
  - 调用 `requestPermission`
  - 调用 `getCurrentPosition`
  - 采集经纬度
  - 反向地理编码
  - 写入业务地区真值
- 必须提供：
  - 刷新状态
  - 打开应用权限设置
  - 打开系统定位设置

## 6. Day 5 最小闭环

- 系统通知入口只作为系统设置跳转。
- 不引入：
  - 推送 SDK
  - APNs / FCM token 注册
  - 后台通知链路
  - 通知分类开关
  - BFF / Server notification preference
- 文案不得暗示 App 已完成真实推送链路。

## 7. 需要保留但暂不开通

- 通知分类：论坛、系统、竞标、审核、认证。
- 推送 token 注册与解绑。
- 服务端通知偏好。
- 后台定位。
- 定位历史。
- 权限使用记录。
- 第三方 SDK 动态清单。

## 8. 稳定性判断

- 更稳：只读权限状态 + 系统设置跳转，不请求新权限。
- 更省成本：复用 `geolocator` 打开设置能力，不新增插件。
- 更适合当前阶段：把设置页 P0 入口做成真实、低风险、可回退的 app-native 闭环。
- 风险更大：提前接入推送 SDK、后台定位、服务端通知偏好或权限审计中心。

## 9. 阶段门禁结论

- passed gates：
  - 已确认法律文书资产存在。
  - 已确认定位状态只读边界。
  - 已确认通知只做系统设置跳转。
  - 已确认本轮不改 BFF / Server。
- failed gates：
  - 无。
- veto gates：
  - 无。
- next stage allowed：
  - 允许进入 Day3-Day5 Flutter 实现与结果校验。
