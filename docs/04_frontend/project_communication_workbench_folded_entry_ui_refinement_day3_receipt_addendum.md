---
owner: Codex 总控
status: frozen
layer: L4 Flutter Frontend
freeze_date_local: 2026-05-03
purpose: Record the Flutter-only implementation, verification, screenshots, and retained runtime boundary for the project communication workbench folded-entry UI refinement.
inputs_canonical:
  - docs/04_frontend/project_communication_workbench_folded_entry_ui_refinement_day1_freeze_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_workbench_widgets.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_workbench_fold_support.dart
  - apps/mobile/test/project_communication_five_material_confirmation_entry_test.dart
  - apps/mobile/test/project_communication_workbench_folded_entry_capture_test.dart
---

# 项目沟通页工作入口折叠精修 Day 3 验收回执

## 0. 总裁决

- 本轮总裁决：`Conditional Pass`。
- Flutter 展示层折叠精修：`Pass`。
- BFF 修改：`No`。
- Server 修改：`No`。
- OpenAPI / generated contracts 修改：`No`。
- 数据库修改：`No`。
- 消息发送接口修改：`No`。
- 资料确认真值修改：`No`。
- 云端写入 / 部署 / 重启：`No`。

保留条件：Computer Use 真实云端页面联调被本地 App 未登录态挡住，本轮未触发登录、短信或账号写操作。视觉截图采用 Flutter fake transport capture，验证的是本轮 Flutter 展示层。

## 1. 本轮 changed_files

新增：

1. `docs/04_frontend/project_communication_workbench_folded_entry_ui_refinement_day1_freeze_addendum.md`
2. `docs/04_frontend/project_communication_workbench_folded_entry_ui_refinement_day3_receipt_addendum.md`
3. `apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_workbench_fold_support.dart`
4. `apps/mobile/test/project_communication_workbench_folded_entry_capture_test.dart`
5. `docs/00_ssot/evidence/20260503-project-communication-workbench-folded.png`
6. `docs/00_ssot/evidence/20260503-project-communication-workbench-expanded.png`
7. `docs/00_ssot/evidence/20260503-project-communication-workbench-narrow.png`

修改：

1. `apps/mobile/lib/features/exhibition/presentation/exhibition_trade_pages.dart`
2. `apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_workbench_widgets.dart`
3. `apps/mobile/test/project_communication_five_material_confirmation_entry_test.dart`

删除：无。

## 2. 文件改动说明

| 文件 | 改动 |
|---|---|
| `counterpart_conversation_workbench_widgets.dart` | 将 workbench section 改为 Stateful 折叠结构；三组默认折叠；展开后复用原 `_WorkbenchEntryTile`；不改变 entry 状态、点击入口、详情页、提交逻辑 |
| `counterpart_conversation_workbench_fold_support.dart` | 新增三组摘要的纯展示派生逻辑：状态优先级、摘要文案、状态视觉 |
| `exhibition_trade_pages.dart` | 增加新的 Flutter part 注册 |
| `project_communication_five_material_confirmation_entry_test.dart` | 更新断言：默认只显示三组摘要；展开后十项入口完整；确认、反馈、成交确认不扣费回归继续成立 |
| `project_communication_workbench_folded_entry_capture_test.dart` | 新增截图测试，输出折叠态、展开态、窄屏态 |

## 3. 关键验收项

| 验收项 | 结果 |
|---|---|
| 资料 / 成交确认是否默认折叠 | `Pass`，三组默认折叠 |
| 十项状态是否仍保留 | `Pass`，展开后保留原状态 badge |
| 是否新增假资料状态 | `No` |
| 是否把灰色状态伪造成待确认 / 已确认 | `No` |
| 项目沟通记录区域是否上移 | `Pass`，折叠态截图中项目沟通记录紧跟工作入口下方 |
| 底部输入栏是否遮挡消息 | `Pass`，截图中消息气泡未被输入栏遮挡 |
| 窄屏是否溢出 | `Pass`，窄屏截图无横向溢出 |

## 4. 验证命令

```bash
flutter analyze lib/features/exhibition/presentation/exhibition_trade_pages.dart lib/features/exhibition/presentation/pages/counterpart_conversation_workbench_widgets.dart lib/features/exhibition/presentation/pages/counterpart_conversation_workbench_fold_support.dart test/project_communication_five_material_confirmation_entry_test.dart test/project_communication_workbench_folded_entry_capture_test.dart
```

结果：`No issues found`。

```bash
flutter test test/project_communication_five_material_confirmation_entry_test.dart
```

结果：`4` tests passed。

```bash
flutter test --update-goldens test/project_communication_workbench_folded_entry_capture_test.dart
```

结果：`1` capture test passed。

## 5. 截图证据

| 场景 | 路径 |
|---|---|
| 折叠态 | `docs/00_ssot/evidence/20260503-project-communication-workbench-folded.png` |
| 展开态 | `docs/00_ssot/evidence/20260503-project-communication-workbench-expanded.png` |
| 窄屏态 | `docs/00_ssot/evidence/20260503-project-communication-workbench-narrow.png` |

## 6. Computer Use 结果

执行过 macOS Flutter App + Computer Use 尝试：

1. 隧道健康：
   - `GET /health/bff/live` -> `200`
   - `GET /health/server/live` -> `200`
2. 新 macOS Flutter App 可启动。
3. 当前 App 进入消息页时返回 `尚未登录`。
4. 本轮未输入账号、未触发短信、未登录、未发送业务写请求。

因此 Computer Use 只能证明当前 App 启动与登录态门禁存在，不能作为真实云端项目沟通页视觉通过证据。本轮视觉验收证据以 Flutter fake transport capture 为准。

## 7. 风险与边界

1. 当前截图不是云端登录态真页截图，而是 Flutter 展示层截图。
2. 本轮未改变十项入口的业务可用性；灰色项仍由上游状态控制。
3. 本轮没有解决“为什么云端账号当前未登录”的问题。
4. 本地工作区已有大量未归属脏文件，本轮未清理、未回滚。

## 8. 下一步建议

如需真实云端页面截图，需要提供可用登录态或单独授权登录流程；该动作会涉及账号会话和可能的短信验证，不应并入本轮 Flutter 展示精修。
