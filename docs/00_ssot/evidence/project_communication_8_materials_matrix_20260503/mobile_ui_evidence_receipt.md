---
owner: Codex 总控
status: accepted
layer: L4 Flutter UI evidence
recorded_at_local: 2026-05-03
scope: Project communication 8 material items matrix UI evidence
---

# 项目沟通 8 个资料项 UI Evidence Receipt

## 1. 总裁决

本轮 mobile UI evidence 裁决为 `PASS`。

Flutter 项目沟通工作入口已按 UI matrix 收敛为 3 个资料入口：

- `发布方资料`
- `中间方成交确认`
- `竞标资料`

点击资料入口后使用 bottom sheet 展示对应资料项列表。8 个资料项不再作为长期平铺列表污染聊天流；2 个成交确认项继续保持 `Reserved / next gate`。

## 2. Evidence 路径

| Evidence | Path | 证明点 |
| --- | --- | --- |
| 顶部 3 入口 / folded | `docs/00_ssot/evidence/20260503-project-communication-workbench-folded.png` | 工作入口中 3 个资料入口可见，未长期平铺 8 项资料。 |
| 发布方资料 bottom sheet | `docs/00_ssot/evidence/20260503-project-communication-workbench-expanded.png` | 点击 `发布方资料` 后 bottom sheet 展示 5 个发布方资料项。 |
| 窄屏布局 | `docs/00_ssot/evidence/20260503-project-communication-workbench-narrow.png` | 移动窄屏下 3 个入口不溢出，聊天流保持独立。 |

说明：本轮截图由 Flutter golden/mobile UI capture 生成，用于证明本地 Flutter UI matrix 消费结果。真实双账号 Computer Use UAT 可在后续独立视觉门禁中执行；本轮未做业务写 smoke。

## 3. Flutter 验证

| Command | Result |
| --- | --- |
| `flutter test test/project_communication_five_material_confirmation_entry_test.dart test/project_communication_workbench_folded_entry_capture_test.dart` | `PASS`, 5/5 |
| `flutter analyze lib/features/exhibition/presentation/pages/counterpart_conversation_workbench_widgets.dart test/project_communication_five_material_confirmation_entry_test.dart test/project_communication_workbench_folded_entry_capture_test.dart` | `PASS` |
| `flutter test --update-goldens test/project_communication_workbench_folded_entry_capture_test.dart` | `PASS`, evidence images updated |

## 4. 边界确认

本轮 UI evidence 未触发：

- 新增 BFF / Server / contracts。
- 支付。
- 扣费。
- 支付回调。
- 真实合同确认。
- 最终成交金额确认。
- 文件上传三步流。
- 云端部署、migration、服务重启、current 切换。

## 5. 已知后续项

- `counterpart_conversation_chat_test.dart` broader failure 是既有 Flutter Release Gate 待处理项；本轮 scoped workbench tests 已通过。
- 后续如需真实双账号截图，应单独进入 Computer Use UAT 门禁，避免把视觉 UAT 与本轮本地 UI matrix 入库混在一起。
