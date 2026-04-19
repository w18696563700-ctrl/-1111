---
owner: Codex 总控
status: active
purpose: Execution prompt for Package A of the enterprise display published-change corridor runtime implementation.
layer: L0 SSOT
freeze_date_local: 2026-04-12
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/enterprise_display_published_change_corridor_package_a_server_governance_truth_stage_gate_checklist_addendum.md
  - docs/00_ssot/enterprise_display_published_change_corridor_truth_freeze_addendum.md
  - docs/01_contracts/enterprise_display_published_change_corridor_contract_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《enterprise display published change corridor Package A Server governance truth execution prompt》

## 1. 执行角色

- Backend Agent

## 2. 唯一目标

你这轮只负责在 `Server` 落实 published change corridor 的治理真相。

当前唯一目标固定为：

1. 落实 `listing-owned current change request` 真相
2. 落实 `changes/current` app-facing save / submit / status truth
3. 落实 Admin `change-requests` review / apply truth
4. 落实：
   - 只有 `apply` 才能更新 live listing

## 3. 强制阅读

1. [enterprise_display_published_change_corridor_truth_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_published_change_corridor_truth_freeze_addendum.md)
2. [enterprise_display_published_change_corridor_contract_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/enterprise_display_published_change_corridor_contract_freeze_addendum.md)
3. [enterprise_display_published_change_corridor_package_a_server_governance_truth_stage_gate_checklist_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/enterprise_display_published_change_corridor_package_a_server_governance_truth_stage_gate_checklist_addendum.md)
4. [docs/01_contracts/openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)

## 4. 只允许修改的范围

- `apps/server/src/modules/enterprise_hub/**`
- 与 published change corridor 直接相关的最小 supporting touch
- 与本轮最小真相闭环直接相关的最小测试文件

## 5. 禁止事项

- 不改 `apps/bff/**`
- 不改 `apps/mobile/**`
- 不改 `apps/admin/**`
- 不发明第二条 published-edit 治理主链
- 不把 `approve` 与 `apply` 混成同一步
- 不让 save draft 直接写 live listing
- 不顺手扩到修改频次治理

## 6. 你必须完成

1. current change carrier
- 落实：
  - `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current`
  - `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/basic`
  - `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/profiles/*`
  - `POST /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/cases`
  - `PUT /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/cases/{caseId}`
  - `DELETE /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/cases/{caseId}`
  - `POST /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/submit`
  - `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/status`

2. Admin governance truth
- 落实：
  - `GET /server/admin/exhibition/enterprise-hub/change-requests`
  - `GET /server/admin/exhibition/enterprise-hub/change-requests/{changeRequestId}`
  - `POST /server/admin/exhibition/enterprise-hub/change-requests/{changeRequestId}/review`
  - `POST /server/admin/exhibition/enterprise-hub/change-requests/{changeRequestId}/apply`

3. 核心真相边界
- 必须成立：
  - 同一 `listing` 同时最多一条活动中的 `change request`
  - save 只写 current change carrier
  - submit 把 current carrier 送入治理态
  - `approved` 不更新 live listing
  - `apply` 才更新 live listing
  - `revision_required` 回到同一条 `changeRequestId`

4. controlled error
- 至少收口：
  - `AUTH_SESSION_INVALID`
  - `ENTERPRISE_HUB_PERMISSION_DENIED`
  - `ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND`
  - `ENTERPRISE_HUB_CHANGE_CORRIDOR_NOT_AVAILABLE`
  - `ENTERPRISE_HUB_INVALID_STATE_TRANSITION`

## 7. 最低测试要求

至少补齐：

1. 同一 listing 不能并行创建多条活动中的 change request
2. `save` 不会更新 live listing
3. `submit -> under_review -> approved -> applied` 流转与 frozen contract 一致
4. `approved` 后 live listing 仍未更新
5. `apply` 后 live listing 才更新
6. `revision_required` 可回到同一 `changeRequestId` 继续修改
7. invalid transition 返回 `ENTERPRISE_HUB_INVALID_STATE_TRANSITION`

## 8. 完成标准

结果必须证明：

1. `Server` 已具备 published change corridor 治理真相
2. app-facing 与 Admin-facing carrier 都锚定同一条 `listing-owned change request`
3. `approve` 与 `apply` 已被 runtime 真正分开
4. live listing 不会被 save draft 直接污染

如果只能闭合一部分：

- 必须逐条写出未闭合项
- 不得把整个 Package A 写成已完成

## 9. 回执要求

- 回执必须单独落盘为：
  - `docs/00_ssot/enterprise_display_published_change_corridor_package_a_server_governance_truth_execution_receipt_addendum.md`
- 回执至少必须包含：
  1. 修改文件清单
  2. 每个修改点对应的冻结事实编号
  3. current change carrier 实现说明
  4. Admin governance truth 实现说明
  5. `approve / apply` 分离说明
  6. live listing apply 边界说明
  7. 新增或更新的测试清单
  8. build / test 结果
  9. 当前剩余未闭合项
  10. 是否允许进入 Package B dispatch

## 10. 输出禁令

- 不要写“应该可以”
- 不要把问题甩回 `BFF / Flutter / Admin`
- 不要把 `approve` 与 `apply` 混写
- 不要让 live listing 被 current change save 污染
- 只给真实实现、真实测试、真实剩余风险
