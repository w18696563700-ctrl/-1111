---
owner: Codex 总控
status: pass
purpose: Record Day 6 tunnel integration, Flutter regression, acceptance screenshots, interface results, and remaining issue list for profile settings P0 account, legal, location, and notification entries.
layer: L0 SSOT
acceptance_date_local: 2026-04-28
---

# 《设置 P0 Day6 隧道联调 / 回归 / 验收归档回执》

## 1. 当前结论

Day6 验收结论为：`pass`。

通过项：

1. 8080 SSH 隧道可用。
2. 云端 BFF 未登录接口返回受控 `401`。
3. 云端登录接口在无效验证码下返回受控 `AUTH_LOGIN_INVALID`。
4. 云端退出接口在无效登录态下返回受控 `AUTH_SESSION_INVALID`。
5. 真实测试账号密码登录返回 `200`，并返回 access / refresh session envelope。
6. 登录后 `GET /api/app/shell/context` 返回 `200`。
7. 登录后 `POST /api/app/auth/logout` 返回 `200`。
8. 退出后使用同一 access token 再查 `shell/context` 返回 `401 AUTH_SESSION_INVALID`。
9. Flutter 设置页账号状态、退出登录、隐私说明、定位权限、系统通知入口回归通过。
10. 设置页验收截图已生成。

阻塞项：

- 无。

## 2. 环境与隧道

- 本地只有 Flutter App。
- BFF / Server 在阿里云。
- 8080 隧道监听结果：
  - `ssh` PID `58869`
  - `127.0.0.1:8080`
  - `[::1]:8080`
- Flutter app-facing base URL：
  - `http://127.0.0.1:8080/api/app`

## 3. 接口结果

### 3.1 `GET /api/app/shell/context`

- 命令：
  - `curl -i http://127.0.0.1:8080/api/app/shell/context`
- 结果：
  - HTTP `401`
  - `code=AUTH_SESSION_INVALID`
  - `source=bff`
- 判定：
  - 未登录态受控返回，通过。

### 3.2 `POST /api/app/auth/otp/login`

- 命令：
  - `POST /api/app/auth/otp/login`
  - body 使用 `13000000000 / 000000 / codex-day6-probe / consentAccepted=true`
- 结果：
  - HTTP `401`
  - `code=AUTH_LOGIN_INVALID`
  - `message=当前验证码错误或已失效，请重试。`
  - `source=server`
- 判定：
  - 登录接口可达，错误验证码受控返回，通过。
  - 不等于真实登录成功 UAT。

### 3.3 `POST /api/app/auth/logout`

- 命令：
  - `POST /api/app/auth/logout`
  - body 使用 `deviceId=codex-day6-probe`
- 结果：
  - HTTP `401`
  - `code=AUTH_SESSION_INVALID`
  - `message=当前登录态不可用，请重新登录或刷新后再试。`
  - `source=server`
- 判定：
  - 无效登录态受控返回，通过。
  - Flutter 已按 Day1-Day2 冻结规则将 `401` 视为本地 session 清理完成条件。

### 3.4 `POST /api/app/auth/password/login`

- 命令：
  - `POST /api/app/auth/password/login`
  - body 使用测试账号 `186****1020`、`consentAccepted=true`、一次性 `deviceId=codex-day6-uat-*`
  - 不记录、不归档明文密码与完整 token
- 结果：
  - HTTP `200`
  - `accessToken_present=yes`
  - `refreshToken_present=yes`
  - `expiresInSeconds=899`
  - `shellBootstrapState=authenticated`
- 判定：
  - 真实账号密码登录成功，通过。

### 3.5 登录后 `GET /api/app/shell/context`

- 命令：
  - `GET /api/app/shell/context`
  - header 使用本次密码登录返回的 `Authorization: Bearer <accessToken>`
- 结果：
  - HTTP `200`
  - `userId_present=yes`
  - `visibleBuildings_count=3`
  - `unreadSummary_present=yes`
- 判定：
  - 认证态 shell context 成立，通过。

### 3.6 登录后 `POST /api/app/auth/logout`

- 命令：
  - `POST /api/app/auth/logout`
  - header 使用本次密码登录返回的 `Authorization: Bearer <accessToken>`
  - body 使用本次登录的 `deviceId`
- 结果：
  - HTTP `200`
  - `ok=yes`
  - `traceId_present=yes`
- 判定：
  - 认证态退出登录成功，通过。

### 3.7 退出后 `GET /api/app/shell/context`

- 命令：
  - `GET /api/app/shell/context`
  - header 继续使用退出前同一 `Authorization: Bearer <accessToken>`
- 结果：
  - HTTP `401`
  - `code=AUTH_SESSION_INVALID`
  - `source=server`
- 判定：
  - 退出后 session 失效成立，通过。

## 4. Flutter 回归结果

### 4.1 静态分析

- 命令：
  - `dart analyze lib/core/boot/app_bootstrap_controller.dart lib/core/location/device_location_service.dart lib/dev/visual_demo/visual_demo_app.dart lib/features/profile/navigation/profile_routes.dart lib/features/profile/presentation/profile_detail_pages.dart lib/features/profile/presentation/profile_settings_page.dart lib/features/profile/presentation/profile_privacy_permission_info_page.dart lib/shell/navigation/app_router.dart test/support/exhibition_home_test_doubles.dart test/enterprise_hub_routes_test.dart test/profile_page_test.dart test/profile_settings_day6_capture_test.dart`
- 结果：
  - `No issues found`

### 4.2 聚焦回归

- 命令：
  - `flutter test --no-pub test/profile_page_test.dart --name "settings page opens privacy|settings page reads location|settings page opens app and location|settings page shows|switch account logs out|logout treats unauthorized"`
- 结果：
  - `7/7 pass`

覆盖项：

1. 设置页已登录账号状态。
2. 设置页未登录账号状态。
3. 切换账号调用 logout 后进入登录页。
4. logout 返回 `401` 时清理本地 session。
5. 隐私与权限说明入口可进入，并可跳用户协议。
6. 定位权限只读状态，不调用定位采集。
7. 系统通知入口只打开 App 系统设置，不接入推送链路。

### 4.3 验收截图生成

- 命令：
  - `flutter test --no-pub --update-goldens test/profile_settings_day6_capture_test.dart`
- 结果：
  - `1/1 pass`
- 输出目录：
  - `.tmp/agent_reports/profile_settings_p0_day6_acceptance_20260428`

截图文件：

1. `01_settings_top_account_notification.png`
2. `02_settings_privacy_location_notification.png`
3. `03_privacy_permission_info.png`

## 5. 问题清单

| 编号 | 问题 | 严重度 | 当前处理 |
|---|---|---:|---|
| D6-01 | 真实账号登录成功与登录后退出成功 UAT 补验 | P1 | 已关闭；2026-04-28 使用专用测试账号完成密码登录、认证态 context、退出、退出后 401 复查 |
| D6-02 | 系统通知入口当前只跳 App 系统设置，不能直达各平台通知页 | P3 | 接受；这是本阶段低风险边界 |
| D6-03 | 权限入口截图来自 Flutter widget 验收，不等同于真机系统设置页截图 | P3 | 接受；真机系统设置跳转可在后续 real-device UAT 补证 |

## 6. 后续扩展位

1. 真机权限 UAT：
   - 定位授权开启 / 关闭 / 永久拒绝
   - 打开 App 设置
   - 打开系统定位设置
2. 通知正式链路另起冻结：
   - 推送 SDK
   - token 注册 / 解绑
   - 通知分类偏好
   - BFF / Server preference 真值

## 7. 正式裁决

- 更稳：
  - 当前 Day6 只声明设置 P0 所需的账号状态、退出登录、权限入口与云端 session 基础链路通过，不扩张到完整账号中心。
- 更省成本：
  - 不新增 BFF / Server，不引入推送 SDK，不接后台定位。
- 更适合当前阶段：
  - Day1-Day5 设置 P0 app-native 闭环可以进入阶段性验收。
- 风险更大：
  - 继续把通知 SDK、后台定位、设备管理、多账号安全中心并入本轮，会扩大 Flutter / BFF / Server 联动面。

Day6 当前允许结项为：

- `Flutter local acceptance: pass`
- `Tunnel unauthenticated route acceptance: pass`
- `Real-account authenticated UAT: pass`
