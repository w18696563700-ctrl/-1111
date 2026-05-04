# App 公共能力 V1 Flutter 第 2 批页面赋能执行回执

## 0. 文书属性

- 文书类型：执行回执 / 页面赋能记录
- 适用范围：`apps/mobile`
- 前置基线：
  - `6535092 feat: add shared Flutter public capability foundation`
  - `973968f docs: record Flutter public capability baseline`
- 本轮主线：方案 A，`AppPageStateView / SubmitGuard` 小范围 Flutter 页面赋能
- 本轮不包含：Admin、BFF、Server、OpenAPI、generated types、云端部署、tunnel smoke、FileAccessClient、AppPermissionGate、RouteEntryValidator、支付/账单/钱包/结算/发票/财务后台

## 1. Gate 0 只读扫描结论

本轮只读扫描确认：

- 当前 `apps/mobile/AGENTS.md` 已登记 Flutter 公共能力复用规则。
- 第 1.5 批 SSOT 已记录第 1 批公共能力正式基线。
- 本轮候选仅允许 3 个 Flutter 页面/模块，不进入全 App 批量迁移。
- 不需要改 BFF、Server、Admin、OpenAPI、generated types。
- 不需要云端联调或 tunnel smoke；本轮不声明 runtime pass。

## 2. 最终接入点

| 接入点 | 文件 | 复用公共能力 | 说明 |
| --- | --- | --- | --- |
| 展览首页项目推荐模块 | `apps/mobile/lib/features/exhibition/presentation/exhibition_home_project_forum_panels.dart` | `AppPageStateView` | 将项目推荐 empty / error / retry 状态接入公共状态壳；loading 保留原静态提示，避免测试环境持续动画导致 `pumpAndSettle` 不收敛 |
| Profile / 我的楼会员局部状态 | `apps/mobile/lib/features/profile/presentation/profile_membership_current_page.dart` | `AppPageStateView` | 将未登录、loading、错误/重试状态接入公共状态壳；继续使用 `profileVisibleReadMessage` 保留真实 state/message 语义 |
| 项目发布页主创建动作 | `apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart` | `SubmitGuard` | 将创建项目主提交入口包入前端防重复点击守卫；保留原 `_submitting` UI loading 状态 |

## 3. 重要边界

- `AppPageStateView` 只负责 UI 状态展示，不吞掉真实错误码、unknown state 或 contract drift。
- `SubmitGuard` 只负责前端防重复点击，不替代后端幂等、权限、审计、业务校验或 Server 状态机。
- 首页 error 文案继续保持“不会用本地演示项目替代云端推荐”的边界，不把假内容当真内容。
- Profile 会员状态继续消费 BFF 返回的 `AppPageState` 与 message，不在前端伪造会员真值。
- 项目创建仍由 BFF `/api/app/project/create` 与 Server 真值处理；本轮不改变接口、命令、DTO 或状态机。

## 4. 验收命令

已执行：

- `flutter analyze` 目标文件：通过
- `flutter test test/public_capabilities_v1_test.dart test/exhibition_home_test.dart`：通过
- `flutter test test/profile_identity_contract_compat_test.dart --plain-name "membership current stays content on HTTP 200"`：通过
- `flutter test test/exhibition_mainline_flow_test.dart --plain-name "project create success invalidates cached my project list for same-session backflow"`：通过

待提交前必须执行：

- `git diff --check -- <本批改动文件>`
- `git status --short --untracked-files=all`
- 禁改目录状态检查：`apps/admin apps/bff apps/server docs/01_contracts packages/contracts`

## 5. 残留风险

- 本轮没有做全量页面迁移；已有页面仍可在后续新功能、修复或局部优化时逐步接入公共能力。
- `StatusBadgePolicy` 逐域状态映射仍未冻结，本轮未施工。
- `AdminStatusState / AdminListDetailWorkbench` 仍是后续单独立项。
- `FileAccessClient` 真实链路仍是 No-Go，必须先冻结 `file/access`、`FileAsset`、临时 `accessUrl` 与鉴权边界。

## 6. 下一轮建议

1. 继续做 `AppPageStateView` 小范围赋能，但每轮最多 3 个页面/模块。
2. 单独冻结 `StatusBadgePolicy` 逐域状态映射，先 SSOT / contracts 后 UI。
3. 单独启动 Admin 公共状态方案，不与 Flutter App 页面赋能混合。
4. 任何 FileAccessClient 真实链路必须先做跨层只读扫描和 contract freeze，不允许从 Flutter 直接拼 `objectKey` 或长期消费临时 `accessUrl`。
