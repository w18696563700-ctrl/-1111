---
owner: Codex 总控
status: frozen
purpose: 本体级独立复核签收表；只核验文档本体，不等同实现通过。用于 implementation 前 gate 复核归档。
layer: L0 SSOT
---

# 展览项目发布-竞标-履约治理四文书 本体级独立复核签收表（docs/03_bff）

## 复核范围
- 目标：四个 `docs/03_bff` surface addendum 的关键条款与边界签收
- 复核原则：仅核验本体文本，不核验 runtime 实现，不替代联调
- 复核基线：`no second truth` 与 `no second route` 不变；`/api/app/*` 与 `/server/admin/*` 为硬边界

## 签收表

### A. `account_and_enterprise_certification_rules_v1_bff_surface_addendum.md`
- 关键条款核验：
  1. Scope 与 Route-group 仅列举 app-facing 与 shell/profile 聚合面（`Section 3 / 4`）
  2. BFF 非 owner 边界明确（`Section 5/9/10`）
  3. 受限态/blocked copy 约束有明示（`Section 6/12/15`）
  4. 不引入 `/auth/* /orgs/* /me/*` 作为实现证据（`Section 11`）
- 复核结果：`passed`
- 风险说明：`risk`（本体签核通过；四包 package-level checkpoint 已形成；implementation unlock 判定待闭环）
- 复核人结论：`passed`（建议继续），待提交 implementation 前实现解锁签收后方可进入下一轮 implementation unlock 评审。

### B. `fake_project_report_and_adjudication_rules_v1_bff_surface_addendum.md`
- 关键条款核验：
  1. 举报提交与受理透传边界定义完整（`Section 7/8/9`）
  2. BFF 非 owner 与禁止 Admin 代理清晰（`Section 5/8/11`）
  3. error-shaping 与不可用态边界可追溯（`Section 10/12/13`）
  4. 与项目发布走廊冲突时不得放开后链实现（`Section 15`）
- 复核结果：`passed`
- 风险说明：`risk`（本体签核通过；implementation unlock 判定待闭环）
- 复核人结论：`passed`（建议继续），不触发实现解锁。

### C. `contract_archive_and_mandatory_fulfillment_chain_rules_v1_bff_surface_addendum.md`
- 关键条款核验：
  1. Contract/Milestone/Inspection/Rating/Dispute 仅作为 app-facing shaping 与透传承接（`Section 9-12`）
  2. BFF 无 admin/state-machine 权限（`Section 6/8/11/20`）
  3. file truth 与 error shaping 与现有三段式上传一致（`Section 8/9`）
  4. 不在本文件承诺后链完整实现（`Section 13/14`）
- 复核结果：`passed`
- 风险说明：`risk`（本体签核通过；implementation unlock 判定待闭环）
- 复核人结论：`passed`（继续复核），不能替代实现前置验收。

### D. `blacklist_whitelist_and_permanent_ban_rules_v1_bff_surface_addendum.md`
- 关键条款核验：
  1. 关键 route scope 收敛在 profile/governance（`Section 4`）
  2. BFF 仅整形与申诉提交透传，不承接处罚/封禁真相（`Section 5/6/7/8/12/13`）
  3. 文件真相与错误码边界齐全（`Section 10/11`）
  4. 与发布最小走廊冲突时按 board freeze 先行（`Section 14`）
  5. no-admin-bridge 明确（`Section 12`）
- 复核结果：`passed`
- 风险说明：`risk`（本体签核通过；四包 checkpoint 已形成；implementation unlock 判定待闭环）
- 复核人结论：`passed`（已纳入硬核验），不构成实现放开条件。

## 复核人签字
- Codex 总控：已完成四包本体级逐条核验，签发 `risk-boundary-pass`；待 package-level 解冻条件全部满足后，才可进入下一轮 implementation unlock 评审。

## 总复核结论
- 四包本体核验：`passed`  
- 但当前 stage 全局结论仍是：`No-Go for implementation / release`  
- 可继续动作：`Go for implementation 前独立复核`
