---
owner: Codex 总控
status: accepted
layer: L0/L3/L4/L6 independent verification
recorded_at_local: 2026-05-03
scope: Project communication 8 material items matrix independent verification
---

# 项目沟通 8 个资料项 Matrix 独立校验回执

## 1. 总裁决

本轮独立校验裁决为 `PASS`。

文书 matrix、Flutter UI、contracts 边界和 runtime 只读健康未发现越权漂移。允许进入入库门禁。

## 2. 文书与 UI 一致性

| Check | Result |
| --- | --- |
| 8 个资料项 matrix | `docs/00_ssot/project_communication_8_materials_matrix_20260503.md` 已冻结 5 个发布方资料和 3 个竞标资料。 |
| UI matrix | `docs/00_ssot/project_communication_8_materials_ui_matrix_20260503.md` 已冻结 3 个入口和 bottom sheet 展开方式。 |
| Flutter UI | `counterpart_conversation_workbench_widgets.dart` 已显示 `发布方资料`、`中间方成交确认`、`竞标资料` 三入口；点击后使用 bottom sheet 展示 entries。 |
| Reserved | `contract_confirmation`、`final_confirmed_amount_confirmation` 只提示，不触发真实合同、最终金额或扣费动作。 |

## 3. Contracts / BFF / Server / Admin 边界

| Layer | Result |
| --- | --- |
| `docs/01_contracts/openapi.yaml` | 本轮未修改。 |
| `packages/contracts/src/generated/**` | 本轮未修改。 |
| `apps/bff/**` | 本轮未修改。 |
| `apps/server/**` | 本轮未修改。 |
| `apps/admin/**` | 本轮未修改。 |
| migration | 本轮未新增、未执行。 |

## 4. Runtime 只读健康

| Check | Result |
| --- | --- |
| `GET http://127.0.0.1:8080/health/bff/live` | `200` |
| `GET http://127.0.0.1:8080/health/server/live` | `200` |

本轮未执行 POST / PUT / PATCH / DELETE runtime smoke。

## 5. 验证命令

| Command | Result |
| --- | --- |
| `flutter test test/project_communication_five_material_confirmation_entry_test.dart test/project_communication_workbench_folded_entry_capture_test.dart` | `PASS`, 5/5 |
| `flutter analyze lib/features/exhibition/presentation/pages/counterpart_conversation_workbench_widgets.dart test/project_communication_five_material_confirmation_entry_test.dart test/project_communication_workbench_folded_entry_capture_test.dart` | `PASS` |
| `git diff --check` | `PASS` |

## 6. 禁止项确认

本轮未触发：

- 支付。
- 扣费。
- 支付回调。
- 真实合同确认。
- 最终成交金额确认。
- 文件上传三步流。
- BFF / Server / Admin 修改。
- contracts / generated types 修改。
- 云端部署。
- migration。
- Server / BFF / Admin 重启。
- current symlink 切换。

## 7. 是否允许进入入库门禁

`允许`。

入库时只允许提交本轮 SSOT 文书、Flutter 最小 UI patch、Flutter tests、UI evidence 和本目录回执。
