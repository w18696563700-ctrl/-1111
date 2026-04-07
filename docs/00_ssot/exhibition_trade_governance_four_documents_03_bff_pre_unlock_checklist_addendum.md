---
owner: Codex 总控
status: frozen
purpose: 给出 docs/03_bff 四包在进入实现提示前的 package-level implementation 解锁条件、核验材料、通过/阻断标准与复核人。
layer: L0 SSOT
---

# 展览项目发布-竞标-履约治理四文书 BFF package-level implementation 前解锁条件清单

## 适用对象
- 对象：`docs/03_bff` 四包聚合面
- 目标：形成可判定的 implementation 前提决策清单

## 约束确认（固定）
- 本轮不做 implementation、联调、release-prep、release；
- 本轮保留在 `phase0 安全边界`；
- BFF 只聚合，不持有业务真相；
- 不得绕开 `/api/app/*` 与 `/server/admin/*` 体系；
- 不得把现有回执当作实现完成证据。

## 解锁前提条件清单（逐项）

### 条件 1：四包文档完整归档
- 核验材料：
  - `docs/03_bff/account_and_enterprise_certification_rules_v1_bff_surface_addendum.md`
  - `docs/03_bff/fake_project_report_and_adjudication_rules_v1_bff_surface_addendum.md`
  - `docs/03_bff/contract_archive_and_mandatory_fulfillment_chain_rules_v1_bff_surface_addendum.md`
  - `docs/03_bff/blacklist_whitelist_and_permanent_ban_rules_v1_bff_surface_addendum.md`
- 通过标准：四份文件存在且状态字段与目标章节完整，不冲突于上位 ssot。
- 阻断标准：任一文件缺失、缺章节或与本轮边界冲突。
- 复核人：Codex 总控 + Backend Agent（文档一致性抽检）

### 条件 2：本体级核验已闭环
- 核验材料：
  - 上述四份 BFF surface addendum 本体
  - 本轮附带的《本体级独立复核签收表》
- 通过标准：每份本体在关键 section 全部逐条打勾（见独立复核签收表）。
- 阻断标准：存在未复核关键条款（所有权、route 家族、错误码、禁入规则、文件真相边界）。
- 复核人：独立复核组（总控主导）

### 条件 3：上位真相链无冲突
- 核验材料：
  - `docs/00_ssot/permission_matrix.md`
  - `docs/00_ssot/project_publish_board_boundary_freeze_addendum.md`
  - `docs/00_ssot/account_login_identity_permission_minimum_freeze_addendum.md`
  - `docs/00_ssot/platform_capability_unified_baseline_addendum.md`
- 通过标准：无冲突项；冲突时以 active board freeze 为先。
- 阻断标准：出现新的权限真相、组织真相、角色真相或 route 套路冲突。
- 复核人：Codex 总控

### 条件 4：接口真相与 BFF 角色边界保持一致
- 核验材料：
  - `docs/01_contracts/openapi.yaml`
  - `docs/01_contracts/error_codes.yaml`
  - `docs/03_bff/bff_ssot.md`
  - `docs/03_bff/bff_routes.md`
- 通过标准：BFF addendum 中约束可映射到已冻结接口与 bff constitution，不出现 BFF-owned state machine。
- 阻断标准：出现 `/server/admin/*` 代理、裸路径越权或新增治理 state machine。
- 复核人：Codex 总控

### 条件 5：实现解锁门禁保持关闭
- 核验材料：
  - `docs/00_ssot/exhibition_trade_governance_four_documents_bff_aggregation_stage_gate_checklist_addendum.md`
  - `docs/00_ssot/exhibition_trade_governance_four_documents_bff_backend_contracts_stage_unlock_gate_checklist_addendum.md`
- 通过标准：当前 stage decision 在 implementation 维度明确 `No-Go`，且未开始 implementation / 联调 / release 的行为。
- 阻断标准：任何 implement/联调/release 已开始行为。
- 复核人：项目总控（你）

## 解锁判定规则
- 本清单成立后，仅可进入下一轮“implementation前复核收口”，不能直接转 implementation 提示。
- 任何一项阻断不满足，解锁结果为 `No-Go for implementation`。
- 当前评估：条件1~5已完成签核闭环，`implementation 解锁` 结论仍为 `No-Go`；  
  复核推进状态为 `Go for implementation 前独立复核`.

## 责任边界
- Codex 总控：gate/复核签收、结论归档。
- Backend Agent：对照后端真相侧与 error/contract 映射。
- BFF Agent：仅执行实现前文档准备，禁止越权实现。
