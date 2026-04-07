---
owner: Codex 总控
status: draft
purpose: Record the stage gate for entering the BFF / Backend / Contracts implementation layer for the four-document governance package, with explicit material-level review before implementation unlock.
layer: L0 SSOT
---

# 展览项目发布-竞标-履约治理四文书
# BFF / Backend / Contracts 阶段门禁核查与实现前 Stage Unlock 评审

## Scope
- Current object:
  - `展览项目发布-竞标-履约治理四文书 / BFF + Backend + Contracts / implementation unlock`
- This checklist is for:
  - post-SSOT/App 对齐冻结的联合确认
  - implementation 前的 L2 / L2-后端 / L3-BFF 分界核验
  - 决定是否可进入实现提示下一轮
- It does not by itself:
  - approve release
  - approve implementation execution
  - approve result verification closure

## 审核材料（本体级，强制核验）
以下文档不只要确认摘要，必须逐文件核验到位：

- `docs/00_ssot/exhibition_trade_governance_four_documents_mother_blueprint_v1.md`
- `docs/00_ssot/exhibition_trade_governance_four_documents_app_alignment_diff_v1.md`
- `docs/00_ssot/exhibition_trade_governance_four_documents_app_aligned_freeze_v1.md`

### 账户与企业认证（第 1 组）
- `docs/00_ssot/account_and_enterprise_certification_rules_v1_app_aligned_freeze_addendum.md`
- `docs/01_contracts/account_and_enterprise_certification_rules_v1_contracts_addendum.md`
- `docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md`
- `docs/03_bff/account_and_enterprise_certification_rules_v1_bff_surface_addendum.md`

### 假项目举报与裁决（第 2 组）
- `docs/00_ssot/fake_project_report_and_adjudication_rules_v1_app_aligned_freeze_addendum.md`
- `docs/01_contracts/fake_project_report_and_adjudication_rules_v1_contracts_addendum.md`
- `docs/02_backend/fake_project_report_and_adjudication_rules_v1_backend_truth_addendum.md`
- `docs/03_bff/fake_project_report_and_adjudication_rules_v1_bff_surface_addendum.md`

### 合同归档与履约（第 3 组）
- `docs/00_ssot/contract_archive_and_mandatory_fulfillment_chain_rules_v1_app_aligned_freeze_addendum.md`
- `docs/01_contracts/contract_archive_and_mandatory_fulfillment_chain_rules_v1_contracts_addendum.md`
- `docs/02_backend/contract_archive_and_mandatory_fulfillment_chain_rules_v1_backend_truth_addendum.md`
- `docs/03_bff/contract_archive_and_mandatory_fulfillment_chain_rules_v1_bff_surface_addendum.md`

### 黑白名单与永久封禁（第 4 组）
- `docs/00_ssot/blacklist_whitelist_and_permanent_ban_rules_v1_app_aligned_freeze_addendum.md`
- `docs/01_contracts/blacklist_whitelist_and_permanent_ban_rules_v1_contracts_addendum.md`
- `docs/02_backend/blacklist_whitelist_and_permanent_ban_rules_v1_backend_truth_addendum.md`
- **`docs/03_bff/blacklist_whitelist_and_permanent_ban_rules_v1_bff_surface_addendum.md`（本次本体级硬性核验项）**

### 工具链与通道冻结底座
- `docs/01_contracts/openapi.yaml`
- `docs/01_contracts/error_codes.yaml`
- `docs/03_bff/bff_ssot.md`
- `docs/03_bff/bff_routes.md`
- `docs/00_ssot/permission_matrix.md`
- `docs/00_ssot/project_publish_board_boundary_freeze_addendum.md`
- `docs/00_ssot/account_login_identity_permission_minimum_freeze_addendum.md`
- `docs/00_ssot/review_ticket_risk_governance_baseline_addendum.md`
- `docs/00_ssot/platform_capability_unified_baseline_addendum.md`
- `docs/00_ssot/gate_register_v1.md`
- `AGENTS.md`

## Passed Gates
- 目标态与对齐层：三份母图谱/对齐层已建立
  - `四文书治理母蓝图 V1`
  - `四文书治理母蓝图 × 当前 App 对齐差异表 V1`
  - `展览项目发布-竞标-履约治理四文书 App 对齐冻结版 V1`
- 上层边界：已冻结 `organization / roleKeys / certificationStatus / permission matrix / /api/app/* / /server/admin/*` 的承载体系
- 第一次 BFF 聚合边界核验通过：
  - `docs/03_bff/bff_ssot.md` 明确 BFF 仅聚合
- 四套 BFF surface addendum 均存在且有本体：
  - `account_and_enterprise...`
  - `fake_project_report...`
  - `contract_archive_and_mandatory_fulfillment_chain_rules...`
  - `blacklist_whitelist...`（已纳入本次核验本体清单）
- `blacklist_whitelist...` addendum 本体具备关键闭环：
  - 明确 `GET /api/app/profile/governance/status`
  - 明确 `POST /api/app/profile/governance/appeals`
  - 明确 `server/admin/governance/*` 的仅 Server 持有真相边界
  - 明确“仅列举 route 不等于放开后链实现”禁令
- L2 合同端证据链存在：
  - 四份 `docs/01_contracts/*_v1_contracts_addendum.md` 已在仓内
  - 对应治理错误码与路由已在 `openapi.yaml` 与 `error_codes.yaml` 显示
- 后端真相边界存在：
  - 四份 `docs/02_backend/*_v1_backend_truth_addendum.md` 已在仓内

## Failed Gates
- 实现前提的最小验收未达成：
  - 未完成 BFF / Backend / Contracts 实施轮级统一验收报告
- 关键实现状态未进入：
  - 本轮仅为阶段 gate 评审，不代表实现可执行
- 生成与发布产物层不是本轮目标：
  - 无要求修改本轮签批为“发布可交付”

## Veto Gates
- 禁止第二套身份/组织/权限真相
- 禁止 `/auth/*`、`/orgs/*`、`/me/*`、`/risk/*`、`/penalty/*`、`/appeal/*`、`/ban/*` 等越界裸路径作为实现放开依据
- 禁止 BFF 持有 `blacklist / penalty / appeal / permanent-bans / whitelist` 业务真相
- 禁止在本轮将 `project_publish_board` 最小走廊之外的 bid/order/contract/fulfillment/dispute 实现为已解锁项
- 禁止将 BFF route family 本体当作“实现完成”证据，而不核验对应后端真值边界

## Stage Go / No-Go
- Stage decision:
  - `No-Go` for entering implementation prompts in this pass (implementation unlock not yet passed)
  - `Go` for继续阶段内的 L2 / L3 文书核验派工（基于本体材料补充完整后）
  - `No-Go` for release-prep and release-execution in this pass

## Stage Meaning
- 当前含义（Allowed）:
  - 本轮是 BFF / Backend / Contracts 的实现前联合门禁评审
  - 本体级核验材料清单已补齐，且 `blacklist_whitelist...` BFF addendum 本体已入清单，避免只信回执
- 当前含义（Not Allowed）:
  - 本轮结论不等于“实现可执行”
  - 不得据此宣称模块可发布或交付完成

## Next Unique Action
- `Codex` 提交下一步：
  - 给出“实现前独立复核”子任务（不触发生产实现）
  - 对 `blacklist_whitelist...` BFF 本体中 `section 14（执行禁令）`、`section 3/4/5/11/12` 的约束进行逐条复核签收
  - 仅在复核通过后，按阶段门禁再次发起 implementation unlock 评审
