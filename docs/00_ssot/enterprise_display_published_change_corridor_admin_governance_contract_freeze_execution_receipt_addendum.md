---
owner: Codex 总控
status: completed
purpose: Record the completed admin-governance contract freeze for the enterprise display published-change corridor before any runtime implementation planning starts.
layer: L0 SSOT
freeze_date_local: 2026-04-12
inputs_canonical:
  - docs/00_ssot/enterprise_display_published_change_corridor_truth_freeze_addendum.md
  - docs/01_contracts/enterprise_display_published_change_corridor_contract_freeze_addendum.md
  - docs/00_ssot/enterprise_display_published_change_corridor_admin_governance_contract_freeze_stage_gate_checklist_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《enterprise display published change corridor admin-governance contract freeze execution receipt》

## 1. 修改文件清单

- `docs/01_contracts/openapi.yaml`
- `docs/01_contracts/enterprise_display_published_change_corridor_contract_freeze_addendum.md`
- `docs/00_ssot/enterprise_display_published_change_corridor_admin_governance_contract_freeze_execution_receipt_addendum.md`

## 2. 新增冻结的 Admin / 治理 contract family 清单

- `GET /server/admin/exhibition/enterprise-hub/change-requests`
  - review queue read canonical path
- `GET /server/admin/exhibition/enterprise-hub/change-requests/{changeRequestId}`
  - review detail read canonical path
- `POST /server/admin/exhibition/enterprise-hub/change-requests/{changeRequestId}/review`
  - 单一路径承接：
    - `approved`
    - `revision_required`
    - `rejected`
- `POST /server/admin/exhibition/enterprise-hub/change-requests/{changeRequestId}/apply`
  - apply approved change snapshot to live listing canonical path

正式收口结论：

- review / revision / approve / reject / apply 现在都已有 formal contract owner
- 当前没有第二条 published-edit 治理主链
- `approve` 与 `apply` 已被明确拆开，不允许混写

## 3. change status 流转说明

- `draft`
  - 由 app-facing `changes/current` save family 承接
- `submitted`
  - 由 app-facing `POST /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/submit` 触发
- `under_review`
  - 由 `Server / Admin` 治理 intake 承接
  - 不是 Flutter 本地推导
- `revision_required`
  - 由 Admin `review.action=revision_required` 触发
- `approved`
  - 由 Admin `review.action=approved` 触发
- `rejected`
  - 由 Admin `review.action=rejected` 触发
- `applied`
  - 由 Admin `POST /server/admin/exhibition/enterprise-hub/change-requests/{changeRequestId}/apply` 触发

强制语义：

- `approve` 只代表治理审核通过，不代表 live listing 已更新
- `apply` 才是把 approved snapshot 写入 live listing 的唯一正式动作

## 4. app-facing 与 Admin-facing 对接说明

- `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/status`
  现在与 Admin 治理面共享同一套：
  - `EnterpriseHubChangeRequestStatus`
- app-facing `submitted / under_review / revision_required / approved / applied`
  现在都有 Admin-facing 对应态，不再是 app-facing 半套 contract
- `revision_required` 返回用户侧时：
  - 继续回到同一条 `changeRequestId`
  - 用户继续修改后可再次 `submit`
- `apply` 完成后：
  - live listing 必须更新为当前 approved change snapshot
  - 后续 public list / detail 读取以更新后的 live listing truth 为准

## 5. 当前剩余禁止语义

- 已发布修改绕过治理直接进 live listing
- `approve` 与 `apply` 混成同一步
- Admin review 没有 formal carrier、只靠口头约定
- 把当前 contract freeze 直接偷换成 runtime implementation dispatch

## 6. 当前是否允许进入 runtime implementation planning

- `是`

约束说明：

- 这只代表当前 published corridor 的治理 contract owner 已补齐
- 现在允许进入 contract-first 顺序下的 runtime implementation planning
- 这不等于：
  - runtime implementation dispatch send
  - direct implementation
  - integration
  - release-prep
  - production release
