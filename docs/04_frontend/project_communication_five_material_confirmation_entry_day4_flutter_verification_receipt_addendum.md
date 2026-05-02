---
owner: Codex 总控
status: accepted
purpose: >
  Record Day 4 Flutter verification receipt for the project communication five
  material confirmation entry minimum loop.
layer: L5 Frontend
verification_scope: Flutter scoped tests and analyze only
inputs_canonical:
  - docs/00_ssot/project_communication_five_material_confirmation_entry_min_loop_day1_freeze_addendum.md
  - docs/04_frontend/project_communication_five_material_confirmation_entry_day2_flutter_structure_addendum.md
---

# 《项目沟通五类资料确认入口 Day 4 Flutter 验收回执》

## 1. 总裁决

Day 4 前端验证结论为 `Conditional Pass`。

当前 Flutter-only 最小闭环通过 scoped widget tests、scoped analyze 和 diff whitespace check。

本回执不代表：

- BFF / Server 已部署。
- 云端 active runtime 已验证。
- 五类资料真实确认状态已持久化。
- `已确认` 已可作为生产业务真值使用。

## 2. 本轮目标

验证 Day 3 Flutter 实现是否满足 Day 1 / Day 2 冻结边界：

- 五类资料确认固定在 `项目工作入口`。
- 底部聊天输入栏不再承接五类资料确认主操作。
- 资料存在只显示 `待确认`。
- 资料缺失显示 `未提交`。
- 读取失败显示 `资料状态暂不可读`，不得伪装成 `未提交`。
- 窄屏下五类按钮可滚动、可见、无测试期溢出异常。

## 3. 验证命令

```bash
cd apps/mobile && flutter test test/project_communication_five_material_confirmation_entry_test.dart test/counterpart_conversation_chat_test.dart test/project_attachment_prepublish_and_bid_materials_test.dart
```

结果：

- `26` tests passed.
- 覆盖五类资料确认入口、项目沟通页回归、历史确认卡读回、底部确认入口移除、五类报价依据资料投影回归。

```bash
cd apps/mobile && flutter analyze lib/features/exhibition/presentation/exhibition_trade_pages.dart lib/features/exhibition/presentation/pages/counterpart_conversation_page.dart lib/features/exhibition/presentation/pages/counterpart_conversation_widgets.dart lib/features/exhibition/presentation/pages/counterpart_conversation_chat_widgets.dart lib/features/exhibition/presentation/pages/counterpart_conversation_material_confirmation_widgets.dart lib/features/exhibition/presentation/presentation_support/counterpart_conversation_material_confirmation_support.dart test/project_communication_five_material_confirmation_entry_test.dart test/counterpart_conversation_chat_test.dart test/project_attachment_prepublish_and_bid_materials_test.dart
```

结果：

- `No issues found`.

```bash
git diff --check -- apps/mobile/lib/features/exhibition/presentation/exhibition_trade_pages.dart apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_page.dart apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_widgets.dart apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_chat_widgets.dart apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_material_confirmation_widgets.dart apps/mobile/lib/features/exhibition/presentation/presentation_support/counterpart_conversation_material_confirmation_support.dart apps/mobile/test/project_communication_five_material_confirmation_entry_test.dart apps/mobile/test/counterpart_conversation_chat_test.dart
```

结果：

- 通过，无 whitespace error。

## 4. 验收结论

已通过：

- `资料确认` 固定区出现在 `项目工作入口` 内。
- 五个按钮固定显示：
  - `效果图确认`
  - `材质图确认`
  - `尺寸图确认`
  - `设备物料清单确认`
  - `服务清单确认`
- 原有 `进入审核 / 后续承接状态 / 项目相册` 保留。
- 资料列表存在对应 `attachmentKind` 时显示 `待确认`。
- 缺少对应 `attachmentKind` 时显示 `未提交`。
- 403 / 不可读状态显示 `资料状态暂不可读` 和 `暂不可读`，不降级为 `未提交`。
- 底部输入栏不再展示 `确认` 按钮或 `发送确认卡` 表单。
- 历史 `confirmation_card` 消息仍可读回。
- 窄屏 `320 x 760` widget 验证未出现布局异常。

## 5. 未完成项

本轮未做：

- Computer Use 真机 / 桌面点击验收。
- Browser Use 页面验证。
- 云端 BFF / Server health check。
- 云端资料接口真实账号读链路验证。
- 五类资料真实确认状态持久化。

## 6. 风险与边界

当前仍为 Flutter-only 验证。

已确认风险：

- 当前 contracts 没有五类资料逐项独立确认状态。
- `已确认` 不能由 Flutter 根据文件存在推断。
- 当前工作区存在本任务外的 BFF / Server / messages / shell 脏改，本轮未回退、未清理、未归属。
- 本地测试不能证明云端 active runtime 行为。

## 7. 下一阶段准入

允许进入第 5 天的条件：

- 只做云端只读联调与最终收口。
- 使用既有隧道做 health check。
- 不做 POST / PUT / PATCH / DELETE。
- 不部署、不重启、不改云端配置。

若要求真实确认持久化：

- 第 5 天不得直接执行。
- 必须回到 Gate 1，先冻结 SSOT / contracts，再进入 BFF / Server。
