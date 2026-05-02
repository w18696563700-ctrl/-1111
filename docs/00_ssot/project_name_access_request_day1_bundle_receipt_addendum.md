---
owner: Codex 总控
status: frozen
purpose: >
  Record the Day-1 document bundle completion for `项目名称申请查看`, so the
  repo has a single receipt for the five-layer addenda plus the stage gate and
  the field/route tables.
layer: L0 SSOT
freeze_date_local: 2026-04-24
inputs_canonical:
  - docs/00_ssot/project_name_access_request_truth_freeze_addendum.md
  - docs/01_contracts/project_name_access_request_contract_freeze_addendum.md
  - docs/02_backend/project_name_access_request_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/project_name_access_request_bff_surface_freeze_addendum.md
  - docs/04_frontend/project_name_access_request_frontend_consumption_freeze_addendum.md
  - docs/00_ssot/project_name_access_request_stage_gate_checklist_addendum.md
  - docs/00_ssot/project_name_access_request_field_table_addendum.md
  - docs/00_ssot/project_name_access_request_route_table_addendum.md
---

# 《项目名称申请查看 Day-1 文书包回执》

## 1. Bundle Contents

- `L0 SSOT truth freeze`
- `L2 contract freeze`
- `L3 backend truth freeze`
- `L4 BFF surface freeze`
- `L5 frontend consumption freeze`
- `Day-1 阶段门禁核查表`
- `字段表`
- `路由表`

## 2. Day-1 Outcome

- 当前文书包已经明确：
  - 首页红框摘要改版的字段口径
  - 公域项目名称遮罩规则
  - `ProjectNameAccessRequest` 的最小状态机
  - owner 审批命令面
  - 消息楼会话化承接的 bounded 版本

## 3. Residual Risk

- 当前仍未解除的风险只有两个：
  - live cloud 仍向未授权 non-owner 泄露真实项目名称
  - 消息楼会话化承接仍需要 bounded extension 复签，不可直接放大成 generic chat

## 4. Next Step

- 先落：
  - 首页红框 Flutter 改版
  - Server/BFF 的公域名称遮罩与申请命令面
- 再落：
  - 消息楼会话化承接
