---
owner: Codex 总控
status: accepted
layer: L4 Computer Use mobile UI evidence
recorded_at_local: 2026-05-03
scope: Project communication 8 material items matrix dual-account UI UAT
---

# 项目沟通 8 个资料项 Matrix 双账号 Computer Use UAT 回执

## 1. 总裁决

本轮双账号 Computer Use UI UAT 裁决为 `PASS`。

两组测试账号均可登录本地最新 Flutter 前端，并进入同一项目沟通链路。项目工作入口展示 3 个资料入口：

- `发布方资料`
- `竞标资料`
- `中间方成交确认`

点击入口后使用 bottom sheet 展示对应资料项。`中间方成交确认` 仅展示 `合同确认`、`最终成交金额确认` 两项 `暂不可读`，未触发真实合同确认、最终金额确认、支付、扣费或回调。

## 2. 登录与视角

| 视角 | 账号标识 | 结果 |
| --- | --- | --- |
| counterpart / 竞标方 | `186****3700` | 登录成功，进入项目沟通成功。 |
| owner / 发布方 | `186****1020` | 登录成功，进入项目沟通成功。 |

## 3. 截图 evidence

| Evidence | Path | 证明点 |
| --- | --- | --- |
| 旧运行实例诊断 | `docs/00_ssot/evidence/project_communication_8_materials_matrix_20260503/computer_use_dual_account_uat/01_counterpart_workbench_top.png` | 启动最新本地前端前，当前旧运行实例仍可见。 |
| 旧运行实例诊断 | `docs/00_ssot/evidence/project_communication_8_materials_matrix_20260503/computer_use_dual_account_uat/02_counterpart_publisher_material_inline_runtime.png` | 旧运行实例仍为内联展开形态，仅作诊断，不作为最终验收。 |
| 竞标方工作台 | `docs/00_ssot/evidence/project_communication_8_materials_matrix_20260503/computer_use_dual_account_uat/03_counterpart_latest_workbench_top.png` | 最新本地前端显示 3 个资料入口。 |
| 竞标方发布方资料 | `docs/00_ssot/evidence/project_communication_8_materials_matrix_20260503/computer_use_dual_account_uat/04_counterpart_publisher_material_bottom_sheet.png` | `发布方资料` bottom sheet 展示 5 项资料，含 `效果图确认` 已确认。 |
| 竞标方竞标资料 | `docs/00_ssot/evidence/project_communication_8_materials_matrix_20260503/computer_use_dual_account_uat/05_counterpart_bid_material_bottom_sheet.png` | `竞标资料` bottom sheet 展示 3 项资料，含 `报价表确认` 已确认。 |
| 竞标方成交确认 Reserved | `docs/00_ssot/evidence/project_communication_8_materials_matrix_20260503/computer_use_dual_account_uat/06_counterpart_deal_reserved_bottom_sheet.png` | `合同确认`、`最终成交金额确认` 均为 `暂不可读`。 |
| 竞标方消息可见 | `docs/00_ssot/evidence/project_communication_8_materials_matrix_20260503/computer_use_dual_account_uat/07_counterpart_message_uat_visible.png` | `UAT smoke 2026-05-03` 消息在竞标方视角可见。 |
| 发布方工作台 | `docs/00_ssot/evidence/project_communication_8_materials_matrix_20260503/computer_use_dual_account_uat/08_owner_latest_workbench_top.png` | 发布方视角显示 3 个资料入口。 |
| 发布方发布方资料 | `docs/00_ssot/evidence/project_communication_8_materials_matrix_20260503/computer_use_dual_account_uat/09_owner_publisher_material_bottom_sheet.png` | 发布方视角 `发布方资料` bottom sheet 展示 5 项资料。 |
| 发布方竞标资料 | `docs/00_ssot/evidence/project_communication_8_materials_matrix_20260503/computer_use_dual_account_uat/10_owner_bid_material_bottom_sheet.png` | 发布方视角 `竞标资料` bottom sheet 展示 3 项资料。 |
| 发布方消息可见 | `docs/00_ssot/evidence/project_communication_8_materials_matrix_20260503/computer_use_dual_account_uat/11_owner_message_uat_visible.png` | `UAT smoke 2026-05-03` 消息在发布方视角可见。 |

## 4. 禁止项确认

本轮未触发：

- 支付。
- 扣费。
- 支付回调。
- 真实合同确认。
- 最终成交金额确认。
- 文件上传三步流。
- 资料确认 / 补充反馈写入。
- 新增消息发送。
- 删除业务数据。
- migration。
- 云端 BFF / Server / Admin 重启。
- current symlink 切换。
- 部署。
- 业务代码修改。

## 5. 运行说明

初始 Computer Use 连接到旧本地 `mobile` 运行实例，仍显示资料项内联展开。为验证最新入库 Flutter 前端，本轮启动了本地 macOS Flutter App 最新代码实例。启动过程中出现 native assets SDK hash 警告，但最新本地 App 仍可运行并完成 UI UAT。

本轮未执行云端写 smoke。所有项目沟通验证动作仅限登录、GET 数据读取、页面导航、bottom sheet 展开和截图。

## 6. 后续建议

下一轮如需继续推进，应只进入 `8 个资料项详情页真实文件预览矩阵`，仍不进入支付、合同确认、最终成交金额确认、文件上传三步流。
