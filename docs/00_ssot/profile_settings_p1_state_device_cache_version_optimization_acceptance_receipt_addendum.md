---
owner: Codex 总控
status: pass
purpose: Record the execution and acceptance result for the P1 profile settings optimization covering certification identity status, current session/device display, safe cache cleanup, and version/runtime information.
layer: L0 SSOT
acceptance_date_local: 2026-04-28
---

# 《设置 P1 状态展示与本地轻操作优化验收回执》

## 1. 总控结论

本轮结论：`pass`。

本轮实际完成范围：

1. 公司认证与我的身份：设置页展示状态摘要；点击进入状态-only 页面。
2. 会话与设备：设置页展示当前设备会话摘要；点击进入当前设备-only 页面。
3. 清理缓存：提供二次确认；仅清理图片缓存与已知临时预览文件。
4. 当前版本：展示真实版本号、构建号、环境标签、入口模式、脱敏 API 入口与构建模式。

本轮未修改：

- contracts
- BFF
- Server
- Admin
- 云端部署

## 2. 派工回执

### 2.1 文书冻结 Agent

- 输出冻结单：
  - `docs/00_ssot/profile_settings_p1_state_device_cache_version_optimization_freeze_addendum.md`
- 结论：
  - 本轮只做 Flutter P1 最小闭环。
  - 不进入完整认证中心、完整设备管理、缓存管理中心或 BFF / Server 字段扩展。

### 2.2 前端 Agent

- 实现位置：
  - `apps/mobile/lib/features/profile/presentation/profile_settings_page.dart`
  - `apps/mobile/lib/features/profile/presentation/profile_settings_support.dart`
  - `apps/mobile/lib/features/profile/presentation/profile_settings_p1_pages.dart`
  - `apps/mobile/lib/core/local_cache/local_cache_cleanup_service.dart`
  - `apps/mobile/lib/core/runtime_info/app_runtime_info_service.dart`
  - `apps/mobile/lib/features/profile/navigation/profile_routes.dart`
  - `apps/mobile/lib/shell/navigation/app_router.dart`
- 结论：
  - 已完成 Flutter-only 最小闭环。

### 2.3 BFF / Server 只读 Agent

- 结论：
  - P1 四项不需要新增或修改 contracts / BFF / Server。
  - `security/devices` 虽然存在，但本轮不作为设置 P1 默认消费。
  - 风险更大的是提前打开完整设备列表与撤销设备。

### 2.4 结果校验 Agent

- 结论：
  - `Pass`。
  - 风险不阻塞进入下一轮。

### 2.5 Computer Use 联调 Agent

- 结论：
  - `Pass`。
  - 已使用真实 Flutter macOS 界面观察，不以静态截图替代真实联调。

## 3. 验证结果

### 3.1 Flutter 静态分析

- 命令：
  - `dart analyze lib/core/runtime_info/app_runtime_info_service.dart lib/core/local_cache/local_cache_cleanup_service.dart lib/features/profile/navigation/profile_routes.dart lib/shell/navigation/app_router.dart lib/features/profile/presentation/profile_detail_pages.dart lib/features/profile/presentation/profile_settings_page.dart lib/features/profile/presentation/profile_settings_support.dart lib/features/profile/presentation/profile_settings_p1_pages.dart test/profile_page_test.dart test/profile_settings_p1_capture_test.dart`
- 结果：
  - `No issues found`

### 3.2 聚焦 widget tests

- 命令：
  - `flutter test --no-pub test/profile_page_test.dart --name "settings p1|settings page opens privacy|settings page reads location|settings page opens app and location|settings page shows|switch account logs out|logout treats unauthorized|settings auth actions require confirmation"`
- 结果：
  - `12/12 pass`

覆盖项：

1. P1 公司认证与我的身份状态-only 页面。
2. P1 会话与设备 current-device-only 页面。
3. P1 清理缓存二次确认，取消不清理，确认后不丢 session。
4. P1 当前版本与运行态展示。
5. P0 设置项未回退。
6. 切换账号 / 退出登录仍需确认。

### 3.3 验收截图

- 命令：
  - `flutter test --no-pub --update-goldens test/profile_settings_p1_capture_test.dart`
  - `flutter test --no-pub test/profile_settings_p1_capture_test.dart`
- 结果：
  - `1/1 pass`
- 输出目录：
  - `.tmp/agent_reports/profile_settings_p1_acceptance_20260428`

截图文件：

1. `01_settings_p1_account_security.png`
2. `02_settings_p1_cache_version.png`
3. `03_certification_identity_status.png`
4. `04_session_device_status.png`
5. `05_version_runtime_info.png`

### 3.4 隧道联调

- 隧道入口：
  - `http://127.0.0.1:8080`
- 真实测试账号密码登录：
  - `POST /api/app/auth/password/login = 200`
  - `accessToken_present=yes`
  - `refreshToken_present=yes`
- 登录后 shell context：
  - `GET /api/app/shell/context = 200`
  - `userId_present=yes`
  - `visibleBuildings_count=3`
- 未登录 shell context：
  - `GET /api/app/shell/context = 401`
  - `code=AUTH_SESSION_INVALID`
- 健康路由探查：
  - `/health = 404`
  - `/healthz = 404`
  - `/api/app/health = 404`
  - `/api/app/health/live = 404`
  - 说明：当前未发现公开 health endpoint；以 app-facing 登录、shell context 与 logout smoke 作为本轮联调证明。
- 本轮临时 session 退出：
  - `POST /api/app/auth/logout = 200`
  - `ok=yes`

### 3.5 Computer Use 真实界面观察

- 启动方式：
  - `flutter run --no-pub -d macos --dart-define-from-file=/tmp/mobile-p1-bootstrap.*.json`
- 观察结论：
  - 设置页展示“会话与设备：账号密码登录 · 当前设备已建立”。
  - 设置页展示“公司认证与我的身份：企业已认证 · 我的认证已通过 · 已开通”。
  - 会话与设备页只展示本设备登录态、token 存在状态、脱敏设备标识、有效期。
  - 会话与设备页未展示其他设备列表，未展示“撤销此设备”。
  - 公司认证与我的身份页只展示当前状态、状态来源、本轮边界。
  - 清理缓存弹窗明确说明不退出登录、不删除草稿、附件或用户资料。
  - 当前版本页展示 `1.0.0+1 · SSH隧道`、`127.0.0.1:8080/api/app`、`debug`。

## 4. 文件边界

### 4.1 本轮新增 / 修改

- `docs/00_ssot/profile_settings_p1_state_device_cache_version_optimization_freeze_addendum.md`
- `docs/00_ssot/profile_settings_p1_state_device_cache_version_optimization_acceptance_receipt_addendum.md`
- `apps/mobile/pubspec.yaml`
- `apps/mobile/pubspec.lock`
- `apps/mobile/lib/core/local_cache/local_cache_cleanup_service.dart`
- `apps/mobile/lib/core/runtime_info/app_runtime_info_service.dart`
- `apps/mobile/lib/features/profile/navigation/profile_routes.dart`
- `apps/mobile/lib/shell/navigation/app_router.dart`
- `apps/mobile/lib/features/profile/presentation/profile_detail_pages.dart`
- `apps/mobile/lib/features/profile/presentation/profile_settings_page.dart`
- `apps/mobile/lib/features/profile/presentation/profile_settings_support.dart`
- `apps/mobile/lib/features/profile/presentation/profile_settings_p1_pages.dart`
- `apps/mobile/test/profile_page_test.dart`
- `apps/mobile/test/profile_settings_p1_capture_test.dart`

### 4.2 明确未越界

- 未改 contracts。
- 未改 BFF。
- 未改 Server。
- 未启动本地 BFF / Server。
- 未把 mock 数据当生产事实。
- 未清理登录态、业务草稿、待上传附件或用户资料。

## 5. 风险清单

| 编号 | 风险 | 级别 | 处理 |
|---|---|---:|---|
| P1-01 | `cache/`、`runtime/` 目录名被 `.gitignore` 忽略 | P1 | 已关闭；改为 `core/local_cache` 与 `core/runtime_info` |
| P1-02 | `flutter pub get` 将 `package_info_plus` 变为 direct dependency，并刷新 matcher/test_api 锁定版本 | P2 | 可接受；由当前 Flutter SDK 重新解析，测试已通过 |
| P1-03 | 公开 health endpoint 未暴露 | P3 | 不阻塞；本轮以 app-facing login / shell context / logout smoke 证明 BFF / Server 可达 |
| P1-04 | 真机缓存路径表现可能与 macOS 不完全一致 | P3 | 不阻塞；清理范围已限制为图片缓存与已知临时预览前缀 |

## 6. 下一轮唯一动作

下一轮建议只做：

- `设置 P1 真机补验`：
  - 真机打开设置页。
  - 验证清理缓存确认弹窗。
  - 验证当前版本展示。
  - 验证页面无横向溢出和文字遮挡。

不建议下一轮直接进入完整设备管理或认证提交链，除非先补新的 SSOT / contracts / BFF / Server 门禁。
