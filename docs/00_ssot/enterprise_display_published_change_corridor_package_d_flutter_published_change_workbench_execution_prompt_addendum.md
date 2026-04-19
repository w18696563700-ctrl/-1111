---
owner: Codex 总控
status: active
purpose: Execution prompt for Package D of the enterprise display published-change corridor runtime implementation.
layer: L0 SSOT
freeze_date_local: 2026-04-12
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/enterprise_display_published_change_corridor_package_d_flutter_published_change_workbench_stage_gate_checklist_addendum.md
  - docs/00_ssot/enterprise_display_published_change_corridor_truth_freeze_addendum.md
  - docs/01_contracts/enterprise_display_published_change_corridor_contract_freeze_addendum.md
  - docs/00_ssot/enterprise_display_published_change_corridor_package_a_server_governance_truth_execution_receipt_addendum.md
  - docs/00_ssot/enterprise_display_published_change_corridor_package_b_admin_review_apply_surface_execution_receipt_addendum.md
  - docs/00_ssot/enterprise_display_published_change_corridor_package_c_bff_published_corridor_surface_execution_receipt_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《enterprise display published change corridor Package D Flutter published-change workbench execution prompt》

## 1. 执行角色

- `Frontend Agent`

## 2. 唯一目标

你这轮只负责落实 `Package D / Flutter published-change workbench package`。

当前唯一目标固定为：

1. 落实 published-change workbench
2. 落实 status
3. 落实 submit flow
4. 落实 `revision_required` return
5. 落实 `liveSnapshot / current change snapshot` 区分

## 3. 强制阅读

1. [enterprise_display_published_change_corridor_truth_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_published_change_corridor_truth_freeze_addendum.md)
2. [enterprise_display_published_change_corridor_contract_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/enterprise_display_published_change_corridor_contract_freeze_addendum.md)
3. [enterprise_display_published_change_corridor_runtime_implementation_planning_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_published_change_corridor_runtime_implementation_planning_addendum.md)
4. [enterprise_display_published_change_corridor_package_a_server_governance_truth_execution_receipt_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_published_change_corridor_package_a_server_governance_truth_execution_receipt_addendum.md)
5. [enterprise_display_published_change_corridor_package_b_admin_review_apply_surface_execution_receipt_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_published_change_corridor_package_b_admin_review_apply_surface_execution_receipt_addendum.md)
6. [enterprise_display_published_change_corridor_package_c_bff_published_corridor_surface_execution_receipt_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_published_change_corridor_package_c_bff_published_corridor_surface_execution_receipt_addendum.md)
7. [enterprise_display_published_change_corridor_package_d_flutter_published_change_workbench_stage_gate_checklist_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_published_change_corridor_package_d_flutter_published_change_workbench_stage_gate_checklist_addendum.md)
8. [openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)

## 4. 只允许修改的范围

- `apps/mobile/lib/features/exhibition/**`
- 与 published-change workbench / status / submit flow 直接相关的最小 supporting touch
- 与本轮最小 Flutter consumption 闭环直接相关的最小测试文件

## 5. 禁止事项

- 不改 `apps/server/**`
- 不改 `apps/admin/**`
- 不改 `apps/bff/**`
- 不让 `Flutter` 反向定义治理真相
- 不发明第二套 published-change 状态机
- 不把 `approved` 与 `applied` 混成一个用户侧动作
- 不做频次治理
- 不把 `保存修改` 伪装成“已立即上线”

## 6. 你必须完成

1. published-change workbench
- 落实：
  - current change snapshot 消费
  - live listing snapshot 消费
  - workbench 内保存修改入口

2. status
- 落实：
  - `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/status`
- 必须明确区分：
  - `draft`
  - `submitted`
  - `under_review`
  - `revision_required`
  - `approved`
  - `rejected`
  - `applied`

3. submit flow
- 落实：
  - `POST /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/submit`
- 必须明确：
  - `approved` 仅代表审核通过
  - `applied` 才代表 live listing 已更新

4. revision return
- 落实：
  - `revision_required` 返回后，用户可继续在同一 published-change workbench 修改并再次提交

5. snapshot 区分
- 必须明确：
  - `liveSnapshot` 只代表当前 live listing 真相
  - `current change snapshot` 只代表当前 corridor draft / review carrier
  - 两者不得在 UI 上混成一个数据面

## 7. 非目标

当前明确不做：

- `Server truth`
- `Admin surface`
- `BFF surface`
- 第二状态机
- 频次治理
- “保存即上线”假象

## 8. 最低验证要求

至少证明：

1. `Flutter` 只消费 `BFF published-corridor surface`
2. 用户侧 workbench / status / submit / `revision_required return` 语义完整
3. `liveSnapshot` 与 current change snapshot 明确分离
4. 用户侧不会误解为“改完立即上线”
5. `approved / applied` 在用户侧明确保持分离

## 9. 回执要求

- 回执必须单独落盘为：
  - `docs/00_ssot/enterprise_display_published_change_corridor_package_d_flutter_published_change_workbench_execution_receipt_addendum.md`
- 回执至少必须包含：
  1. 修改文件清单
  2. workbench / status / submit flow 实现说明
  3. `liveSnapshot / current snapshot` 区分说明
  4. 用户侧 `approved / applied` 边界说明
  5. 测试清单
  6. analyze / test 结果

## 10. 输出禁令

- 不要写“应该可以”
- 不要把 `approved` 与 `applied` 混成一个动作
- 不要把 `Flutter` 写成治理真相 owner
- 不要把保存修改写成已立即上线
- 只给真实实现、真实测试、真实剩余风险
