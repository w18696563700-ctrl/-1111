---
owner: Codex 总控
status: active
purpose: Execution prompt for Package C of the enterprise display published-change corridor runtime implementation.
layer: L0 SSOT
freeze_date_local: 2026-04-12
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/enterprise_display_published_change_corridor_package_c_bff_published_corridor_surface_stage_gate_checklist_addendum.md
  - docs/00_ssot/enterprise_display_published_change_corridor_truth_freeze_addendum.md
  - docs/01_contracts/enterprise_display_published_change_corridor_contract_freeze_addendum.md
  - docs/00_ssot/enterprise_display_published_change_corridor_package_a_server_governance_truth_execution_receipt_addendum.md
  - docs/00_ssot/enterprise_display_published_change_corridor_package_b_admin_review_apply_surface_execution_receipt_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《enterprise display published change corridor Package C BFF published-corridor surface execution prompt》

## 1. 执行角色

- `BFF Agent`

## 2. 唯一目标

你这轮只负责落实 `Package C / BFF published-corridor surface package`。

当前唯一目标固定为：

1. 暴露 `changes/current` family 的 app-facing surface
2. 做 transport
3. 做 normalization
4. 做 error mapping

## 3. 强制阅读

1. [enterprise_display_published_change_corridor_truth_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_published_change_corridor_truth_freeze_addendum.md)
2. [enterprise_display_published_change_corridor_contract_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/enterprise_display_published_change_corridor_contract_freeze_addendum.md)
3. [enterprise_display_published_change_corridor_runtime_implementation_planning_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_published_change_corridor_runtime_implementation_planning_addendum.md)
4. [enterprise_display_published_change_corridor_package_a_server_governance_truth_execution_receipt_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_published_change_corridor_package_a_server_governance_truth_execution_receipt_addendum.md)
5. [enterprise_display_published_change_corridor_package_b_admin_review_apply_surface_execution_receipt_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_published_change_corridor_package_b_admin_review_apply_surface_execution_receipt_addendum.md)
6. [enterprise_display_published_change_corridor_package_c_bff_published_corridor_surface_stage_gate_checklist_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_published_change_corridor_package_c_bff_published_corridor_surface_stage_gate_checklist_addendum.md)
7. [openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)

## 4. 只允许修改的范围

- `apps/bff/src/routes/enterprise_hub/**`
- 与 `changes/current` family 直接相关的最小 supporting touch
- 与本轮最小 BFF surface 闭环直接相关的最小测试文件

## 5. 禁止事项

- 不改 `apps/server/**`
- 不改 `apps/admin/**`
- 不改 `apps/mobile/**`
- 不让 `BFF` 反向定义治理真相
- 不发明第二套 published-change 状态机
- 不把 `approved` 与 `applied` 混成一个动作
- 不做频次治理
- 不在 `BFF` 侧隐式建单

## 6. 你必须完成

1. `changes/current` family 的 app-facing surface
- 落实：
  - `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current`
  - `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/basic`
  - `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/profiles/company`
  - `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/profiles/factory`
  - `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/profiles/supplier`
  - `POST /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/cases`
  - `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/cases/{caseId}`
  - `DELETE /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/cases/{caseId}`
  - `POST /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/submit`
  - `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/status`

2. transport / normalization / error mapping
- 必须成立：
  - `BFF` 只做 transport / normalization / error mapping
  - `BFF` 不得伪造创建 current change carrier
  - `BFF` 不得推导第二状态机
  - `approved` 只代表审核通过
  - `applied` 才代表 live listing 已更新

## 7. 非目标

当前明确不做：

- `Server truth`
- `Admin surface`
- `Flutter`
- 第二状态机
- 频次治理
- 隐式建单

## 8. 最低验证要求

至少证明：

1. `changes/current` family 全部对齐 frozen contract
2. `GET /changes/current` 在 BFF 侧不会伪造创建 carrier
3. error mapping 能承接：
   - `AUTH_SESSION_INVALID`
   - `ENTERPRISE_HUB_PERMISSION_DENIED`
   - `ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND`
   - `ENTERPRISE_HUB_CHANGE_CORRIDOR_NOT_AVAILABLE`
   - `ENTERPRISE_HUB_INVALID_STATE_TRANSITION`
4. `approved / applied` 在 BFF surface 明确保持分离

## 9. 回执要求

- 回执必须单独落盘为：
  - `docs/00_ssot/enterprise_display_published_change_corridor_package_c_bff_published_corridor_surface_execution_receipt_addendum.md`
- 回执至少必须包含：
  1. 修改文件清单
  2. `changes/current` family 暴露说明
  3. error mapping 说明
  4. `approved / applied` 边界说明
  5. 测试清单
  6. build / test 结果
  7. 是否允许进入 `Package D`

## 10. 输出禁令

- 不要写“应该可以”
- 不要把 `approved` 与 `applied` 混成一个动作
- 不要把 `BFF` 写成治理真相 owner
- 不要提前放行 `Package D`
- 只给真实实现、真实测试、真实剩余风险
