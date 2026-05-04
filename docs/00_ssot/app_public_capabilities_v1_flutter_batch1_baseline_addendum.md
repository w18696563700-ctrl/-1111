# App 公共能力 V1 Flutter 第 1 批基线回填 Addendum

## 0. 文书属性

- 文书类型：公共能力台账回填 / Flutter 公共能力基线记录
- 适用范围：`apps/mobile`
- 本轮性质：文书/治理回填
- 正式基线 commit：`6535092 feat: add shared Flutter public capability foundation`
- 本轮不包含：Flutter 页面批量迁移、Admin 公共能力实现、BFF / Server 实现、OpenAPI 修改、generated types 生成、部署、tunnel smoke、commit

## 1. 公共能力台账 V1 回填回执

第 1 批 Flutter 公共能力 V1 已完成 bounded implementation，并以 commit `6535092` 入库。该批次只建立 Flutter 侧可复用底座和 3 个示范接入点，不改变业务真值、不新增接口、不扩云端 runtime surface。

验收命令已完成：

- `flutter analyze` 目标文件：通过
- `flutter test test/public_capabilities_v1_test.dart`：通过
- `git diff --check`：通过

### 1.1 已实现公共能力

| 能力 | 状态 | 入口文件 | 当前最小闭环 | 仍需注意的边界 |
| --- | --- | --- | --- | --- |
| `FileOpenCoordinator` | 已实现 | `apps/mobile/lib/shared/file/file_open_coordinator.dart` | 统一本地文件打开、外部 URI 打开、桌面 fallback、失败结果 | 只负责文件打开协调，不负责 `file/access`、鉴权、`objectKey`、`accessUrl` 真值 |
| `AttachmentTile / FileTile` | 已实现 | `apps/mobile/lib/shared/file/attachment_tile.dart` | 统一附件行展示、文件元信息、状态、打开/删除/更多动作入口 | 只负责展示和动作入口，不持有业务附件真值 |
| `AppPageStateView` | 已实现，待逐页赋能 | `apps/mobile/lib/shared/widgets/app_page_state_view.dart` | 统一 loading / empty / retryable error / auth / forbidden / not found 展示壳 | 只负责 UI 展示，不吞掉真实错误码 |
| `SubmitGuard` | 已实现，待表单赋能 | `apps/mobile/lib/shared/state/submit_guard.dart` | 统一前端防重复提交、提交中状态、失败后恢复 | 只防重复点击，不替代后端幂等 |
| `MoneyFormatter` | 已实现 | `apps/mobile/lib/shared/format/money_formatter.dart` | 统一金额展示、分转元、`CNY` / `¥`、空值、不可用、隐藏金额 | 不计算 200 元、4000 元、服务费、会员折扣或支付状态 |
| `StatusBadgePolicy` 轻量版 | 已实现，待逐域冻结 | `apps/mobile/lib/shared/ui/status_badge_policy.dart` | 统一展示 tone 与 unknown 兜底；扩展 `AppStatusTone` | 不定义业务状态机，不覆盖全量业务枚举 |

### 1.2 已完成示范接入点

| 示范接入点 | 状态 | 涉及文件 | 说明 |
| --- | --- | --- | --- |
| 公共资源文件打开接 `FileOpenCoordinator` | 已接入 | `apps/mobile/lib/features/exhibition/presentation/presentation_support/project_public_resource_support.dart` | 页面不再直接调用 `open_filex` 打开下载后的公共资源文件 |
| 项目附件打开接 `FileOpenCoordinator` | 已接入 | `apps/mobile/lib/features/exhibition/presentation/presentation_support/project_attachment_support.dart` | 本地文件打开与外部链接打开统一走协调器 |
| 项目附件展示接 `AttachmentTile` | 已接入 | `apps/mobile/lib/features/exhibition/presentation/widgets/project_attachment_panels.dart` | 正式附件记录使用公共附件行展示，保留业务高级信息区 |
| Profile 金额展示接 `MoneyFormatter` | 已接入 | `apps/mobile/lib/features/profile/presentation/profile_membership_purchase_support.dart` | 会员购买金额展示改为公共格式化，不引入支付或折扣判断 |

### 1.3 能力壳与未批量迁移说明

已有页面不要求立即全量迁移。只有在新功能、修复、局部优化或相关页面改造时，才必须优先复用已登记公共能力。

当前仍属能力壳或待赋能：

- `AppPageStateView`：已具备统一展示壳，尚未批量替换首页、消息、Profile、详情页状态区。
- `SubmitGuard`：已具备前端防重复提交底座，尚未批量接入项目发布、企业 Workbench、举报、报价入口。
- `StatusBadgePolicy`：仅提供 tone 与 unknown 兜底，逐域状态文案必须等待 SSOT / contract 状态冻结后再接入。

## 2. 第 1 批 Flutter 公共能力正式基线记录

正式基线：

- commit：`6535092`
- message：`feat: add shared Flutter public capability foundation`

commit 文件清单：

- `apps/mobile/lib/features/exhibition/presentation/exhibition_trade_pages.dart`
- `apps/mobile/lib/features/exhibition/presentation/presentation_support/project_attachment_support.dart`
- `apps/mobile/lib/features/exhibition/presentation/presentation_support/project_public_resource_support.dart`
- `apps/mobile/lib/features/exhibition/presentation/widgets/project_attachment_panels.dart`
- `apps/mobile/lib/features/profile/presentation/profile_detail_pages.dart`
- `apps/mobile/lib/features/profile/presentation/profile_membership_purchase_support.dart`
- `apps/mobile/lib/shared/file/attachment_tile.dart`
- `apps/mobile/lib/shared/file/file_open_coordinator.dart`
- `apps/mobile/lib/shared/format/money_formatter.dart`
- `apps/mobile/lib/shared/state/submit_guard.dart`
- `apps/mobile/lib/shared/ui/app_visual_components.dart`
- `apps/mobile/lib/shared/ui/status_badge_policy.dart`
- `apps/mobile/lib/shared/widgets/app_page_state_view.dart`
- `apps/mobile/test/public_capabilities_v1_test.dart`

基线裁决：

- 第 1 批 Flutter 公共能力 V1：`PASS`
- 云端 runtime：未验证，且本批不需要声明 runtime pass
- BFF / Server / OpenAPI / generated types：未修改
- Admin：未修改

## 3. AGENTS.md 公共能力复用补丁

`apps/mobile/AGENTS.md` 需要固化以下规则：

1. 后续文件打开优先复用 `FileOpenCoordinator`。
2. 后续附件展示优先复用 `AttachmentTile / FileTile`。
3. 后续金额展示优先复用 `MoneyFormatter`。
4. 后续 loading / empty / error / retry 优先复用 `AppPageStateView`。
5. 后续表单防重复提交优先复用 `SubmitGuard`。
6. 后续状态 Badge 展示优先复用 `StatusBadgePolicy`。
7. 不允许页面重复直接封装 `open_filex`。
8. 不允许页面重复自写金额格式化。
9. 不允许页面重复自造状态 Badge 文案。
10. 不允许借公共能力名义改 BFF / Server / OpenAPI / generated types。

公共能力边界必须同步记录：

- `FileOpenCoordinator` 只负责文件打开协调，不负责 `file/access`、鉴权、`objectKey`、`accessUrl` 真值。
- `AttachmentTile / FileTile` 只负责附件展示和动作入口，不持有业务附件真值。
- `MoneyFormatter` 只负责金额展示，不计算 200 元、4000 元、服务费、会员折扣或支付状态。
- `StatusBadgePolicy` 只负责展示 tone / 文案兜底，不定义业务状态机。
- `SubmitGuard` 只负责前端防重复点击，不替代后端幂等。
- `AppPageStateView` 只负责 loading / empty / error / retry 展示，不吞掉真实错误码。

## 4. 第 2 批候选任务单

以下仅为候选任务单，不在本轮施工。

### 4.1 推荐候选

1. `AppPageStateView` 页面赋能
   - 候选范围：首页、消息、Profile 局部态。
   - 边界：只换展示壳，不改接口、不吞错误码。

2. `SubmitGuard` 表单赋能
   - 候选范围：项目发布、企业 Workbench、举报、报价候选入口。
   - 边界：只做前端防重复点击，不替代后端幂等或业务校验。

3. `StatusBadgePolicy` 逐域冻结映射
   - 候选范围：项目、竞标、合同、验收、会员、支付展示、治理。
   - 前置条件：先补 SSOT / contract 状态枚举与文案边界。

4. Admin 公共状态单独立项
   - 候选范围：`AdminStatusState`、`AdminListDetailWorkbench`。
   - 边界：第 2 批单独设计，不混入 App Flutter 底座。

5. 文件访问链路单独立项
   - 候选范围：`FileAccessClient` 方案冻结。
   - 前置条件：确认 `file/access`、`FileAsset`、临时 `accessUrl` 消费边界，不允许前端拼 `objectKey`。

### 4.2 继续 No-Go 或后续单独立项

- `FileAccessClient` 真实链路
- `AppPermissionGate` 最终权限判断
- `RouteEntryValidator / MessageActionRegistry` 大改
- `AdminStatusState / AdminListDetailWorkbench`
- 通用支付、账单、钱包、结算、发票、财务后台
- BFF / Server / OpenAPI / generated types 变更

## 5. 后续验收口径

后续涉及 Flutter 页面文件打开、附件展示、金额展示、页面状态、提交防重、状态 Badge 时，必须先检查本台账与 `apps/mobile/AGENTS.md`。

如确实不能复用第 1 批公共能力，任务回执必须说明：

- 为什么不能复用
- 是否需要扩展公共能力
- 是否涉及 SSOT / contracts
- 是否会触碰 BFF / Server / OpenAPI / generated types
- 是否需要单独立项
