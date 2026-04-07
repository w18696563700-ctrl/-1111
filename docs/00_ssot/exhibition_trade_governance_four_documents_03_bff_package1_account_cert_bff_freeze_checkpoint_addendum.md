---
owner: Codex 总控
status: frozen
purpose: 第 1 份 docs/03_bff package（账户与企业认证）在 package-level 的冻结 checkpoint 与边界复核归档，作为下一步 implementation 前复核链的一部分。
layer: L0 SSOT
---

# 展览项目发布-竞标-履约治理四文书 BFF 四包：第一包冻结 Checkpoint（账户与企业认证）

## 1. Checkpoint 对象

- 对象：`docs/03_bff` 下第一聚合包
- 包名：`账户与企业认证规则 V1`
- 目标文件：`docs/03_bff/account_and_enterprise_certification_rules_v1_bff_surface_addendum.md`
- 本次结论定位：`package-level冻结签核`，非 implementation 解锁。

## 2. 本轮冻结范围（限定）

- 路径家族：`auth`、`shell`、`profile`（仅本文件当前声明的 app-facing 面）
- 禁止扩展项：
  - 不新增 `/api/app/auth`/`/api/app/profile` 外的交易或治理后链实现
  - 不新增 `/server/admin` 透传到 BFF
  - 不新增 `/risk/* /penalty/* /appeal/* /ban/* /whitelist/*` 裸路由
  - 不新增第二身份/组织/认证/权限真相

## 3. 核验对照清单

### 3.1 上位文书与契约基线
- [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md)
- [bff_ssot.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/bff_ssot.md)
- [bff_routes.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/bff_routes.md)
- [account_and_enterprise_certification_rules_v1_app_aligned_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/account_and_enterprise_certification_rules_v1_app_aligned_freeze_addendum.md)
- [account_and_enterprise_certification_rules_v1_contracts_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/account_and_enterprise_certification_rules_v1_contracts_addendum.md)
- [account_and_enterprise_certification_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md)
- [permission_matrix.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/permission_matrix.md)

### 3.2 关键 section 核验（本体）
- Scope 与 scope-limit：通过
  - 覆盖 `auth`、`shell`、`profile` handoff/shaping；
  - 明确“仅聚合、非真相 owner”。
- 聚合语义边界：通过
  - request/trace 透传、read-model shaping、失败态 copy；
  - 明确不触碰审核流、会员决策、组织真相。
- 非 owner 限制：通过
  - 明确禁止 ownership：`users / sessions / organizations / organization_members / organization_certifications / devices / security_events / derived eligibility truth`。
- 异常文案边界：通过
  - blocked/unavailable copy 限定于已冻结文案集合；
  - 不暴露 raw reviewer / raw security internal。
- 接口方向一致性：通过
- 生产实现条件：不在本体阶段放开
  - 本文档不构成实现 unlock。

## 4. 条款风险说明（本 checkpoint 内）

- 本 checkpoint 为 package 1 聚合边界冻结，仅覆盖该包；
- 不是四包总 package-level 解锁；
- 不包含四包后续实现链（fake_project / contract / blacklist）；
- 不包含 implementation/release 前置；
- 不改变 `project_publish_board` 当前最小走廊。

## 5. 结果结论

- 本包 Checkpoint 结论：`passed`
- 本文件角色结论：`package-level_frozen_checkpoint`
- 实施授权：`No-Go for implementation`
- 允许动作：`Go for docs-only 下一包实现前对齐复核`

## 6. 责任与签字

- 复核与冻结归档：Codex 总控
- 关键复核依据：`docs/00_ssot/exhibition_trade_governance_four_documents_03_bff_body_level_independent_review_signoff_sheet.md`

## 7. 下一步

- 该 checkpoint 与本体签核一并归档后，进入下一轮 `implementation` 前 `package-level` 解锁复核，提交：
  - `docs/00_ssot/exhibition_trade_governance_four_documents_03_bff_pre_unlock_checklist_addendum.md`
  - `docs/00_ssot/exhibition_trade_governance_four_documents_03_bff_body_level_independent_review_signoff_sheet.md`

## 8. 非允许含义

- 本文件不是 `/apps/bff` implementation dispatch。
- 本文件不是 `release-prep` / `release` 许可。
- 本文件不是 admin 面实施许可。
