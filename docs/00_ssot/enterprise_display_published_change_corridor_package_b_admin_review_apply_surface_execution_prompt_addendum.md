---
owner: Codex 总控
status: active
purpose: Execution prompt for Package B of the enterprise display published-change corridor runtime implementation.
layer: L0 SSOT
freeze_date_local: 2026-04-12
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/enterprise_display_published_change_corridor_package_b_admin_review_apply_surface_stage_gate_checklist_addendum.md
  - docs/00_ssot/enterprise_display_published_change_corridor_truth_freeze_addendum.md
  - docs/01_contracts/enterprise_display_published_change_corridor_contract_freeze_addendum.md
  - docs/00_ssot/enterprise_display_published_change_corridor_package_a_server_governance_truth_execution_receipt_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《enterprise display published change corridor Package B admin review-apply surface execution prompt》

## 1. 执行角色

- `Backend Agent（Admin）`

## 2. 唯一目标

你这轮只负责落实 `Package B / Admin review-apply surface package`。

当前唯一目标固定为：

1. 落实 review queue
2. 落实 review detail
3. 落实 review action
4. 落实 apply action

## 3. 强制阅读

1. [enterprise_display_published_change_corridor_truth_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_published_change_corridor_truth_freeze_addendum.md)
2. [enterprise_display_published_change_corridor_contract_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/enterprise_display_published_change_corridor_contract_freeze_addendum.md)
3. [enterprise_display_published_change_corridor_runtime_implementation_planning_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_published_change_corridor_runtime_implementation_planning_addendum.md)
4. [enterprise_display_published_change_corridor_package_a_server_governance_truth_execution_receipt_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_published_change_corridor_package_a_server_governance_truth_execution_receipt_addendum.md)
5. [enterprise_display_published_change_corridor_package_b_admin_review_apply_surface_stage_gate_checklist_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_published_change_corridor_package_b_admin_review_apply_surface_stage_gate_checklist_addendum.md)
6. [openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)

## 4. 只允许修改的范围

- `apps/admin/**`
- 与 Admin published-change queue / detail / review / apply 直接相关的最小 supporting touch
- 与本轮最小 surface 闭环直接相关的最小测试文件

## 5. 禁止事项

- 不改 `apps/server/**`
- 不改 `apps/bff/**`
- 不改 `apps/mobile/**`
- 不把 Admin surface 写成治理真相 owner
- 不反向定义 `Server` 治理状态机
- 不发明第二套 published-change 状态机
- 不把 `approved` 与 `applied` 混成一个动作
- 不顺手扩到频次治理

## 6. 你必须完成

1. review queue
- 落实：
  - `GET /server/admin/exhibition/enterprise-hub/change-requests`

2. review detail
- 落实：
  - `GET /server/admin/exhibition/enterprise-hub/change-requests/{changeRequestId}`

3. review action
- 落实：
  - `POST /server/admin/exhibition/enterprise-hub/change-requests/{changeRequestId}/review`
- 必须明确区分：
  - `approved`
  - `revision_required`
  - `rejected`

4. apply action
- 落实：
  - `POST /server/admin/exhibition/enterprise-hub/change-requests/{changeRequestId}/apply`
- 必须明确：
  - `approved` 仅代表审核通过
  - `apply` 才代表写入 live listing

## 7. 非目标

当前明确不做：

- `Server governance truth`
- `BFF published-corridor surface`
- `Flutter published-change workbench`
- 第二状态机
- 频次治理

## 8. 最低验证要求

至少证明：

1. queue 页面只读取 review queue，不定义治理真相
2. detail 页面可区分 current change snapshot 与 live snapshot
3. review action 能独立处理 `approved / revision_required / rejected`
4. apply action 与 review action 保持两步分离
5. 当前 UI 不会伪装成“审核通过即已上线”

## 9. 回执要求

- 回执必须单独落盘为：
  - `docs/00_ssot/enterprise_display_published_change_corridor_package_b_admin_review_apply_surface_execution_receipt_addendum.md`
- 回执至少必须包含：
  1. 修改文件清单
  2. queue/detail/review/apply 各自实现说明
  3. `approved / applied` 分离说明
  4. 测试清单
  5. build / test 结果
  6. 是否允许进入 `Package C`

## 10. 输出禁令

- 不要写“应该可以”
- 不要把 `approved` 与 `applied` 混成一个动作
- 不要把 Admin surface 写成治理真相 owner
- 不要提前放行 `Package C / D`
- 只给真实实现、真实测试、真实剩余风险
