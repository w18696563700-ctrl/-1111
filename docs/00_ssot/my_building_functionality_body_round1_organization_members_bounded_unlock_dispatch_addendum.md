---
owner: Codex 总控
status: frozen
purpose: Freeze the bounded unlock dispatch for `组织成员管理最小承接` inside `我的楼功能本体 Round 1`, rectifying the earlier dispatch freeze that still treated `organization members list / role / disable` as a frozen placeholder after the current minimal implementation package had already been materially established.
layer: L0 SSOT
freeze_date_local: 2026-04-05
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/my_building_functionality_body_round1_increment_dispatch_judgment_addendum.md
  - docs/00_ssot/my_building_functionality_body_round1_next_increment_dispatch_judgment_addendum.md
  - docs/00_ssot/account_and_enterprise_certification_rules_v1_app_aligned_freeze_addendum.md
  - docs/01_contracts/account_and_enterprise_certification_rules_v1_contracts_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md
  - docs/03_bff/account_and_enterprise_certification_rules_v1_bff_surface_addendum.md
  - docs/04_frontend/account_and_enterprise_certification_rules_v1_frontend_surface_addendum.md
  - apps/server/src/modules/profile/profile.controller.ts
  - apps/server/src/modules/organization/entities/organization-member.entity.ts
  - apps/bff/src/routes/profile/profile-members.service.ts
  - apps/mobile/lib/features/profile/presentation/profile_member_management_sheet.dart
  - apps/mobile/test/profile_page_test.dart
  - apps/mobile/test/profile_identity_contract_compat_test.dart
  - apps/mobile/test/my_project_private_carry_test.dart
---

# 《我的楼功能本体 Round 1 组织成员管理最小承接 bounded unlock 派工补充单》

## 1. Current Single Mainline

- 当前唯一主线仍然是：
  - `我的楼功能本体推进`
- 当前唯一动作仍然是：
  - `增量施工判断 / 派工`
- 当前仍明确禁止：
  - `integration`
  - `release-prep`
  - `launch-approval`
  - `closure judgment`
- 本补充单只修正：
  - `organization members list / role / disable` 在当前活跃派工边界中的阶段定义
- 本补充单不把当前主线切回任何后段门禁链

## 2. Why Rectification Is Required

- 先前活跃派工依据仍把：
  - `organization members list`
  - `organization member role change`
  - `organization member disable`
  写成：
  - 当前继续冻结
  - 当前不得打开
- 但当前实现包已经形成最小 bounded consumption：
  - `Server` 已 materialize
    - `GET /server/profile/organization/members`
    - `PATCH /server/profile/organization/members/{memberId}/role`
    - `PATCH /server/profile/organization/members/{memberId}/disable`
  - `BFF` 已只做转发与最小整形
  - `Flutter App` 已有最小成员管理 sheet、角色调整、成员禁用、成功样本与受控失败分支
- 因此当前阻断不再是：
  - 实现未完成
- 而是：
  - 活跃 L0 派工边界尚未正式重开 `组织成员管理最小承接`

## 3. Formal Rectification

- 自本补充单起，`我的楼功能本体 Round 1` 当前允许新增一个正式 bounded package：
  - `组织成员管理最小承接 bounded unlock`
- 当前对该包的正式定义改为：
  - 不再是纯冻结占位
  - 已允许作为 `我的公司 / 认证与成员身份` 下的最小真实消费面
- 当前允许的最小消费范围只限：
  - `GET /api/app/profile/organization/members`
  - `PATCH /api/app/profile/organization/members/{memberId}/role`
  - `PATCH /api/app/profile/organization/members/{memberId}/disable`
- 当前明确不等于：
  - 完整治理后台
  - 完整组织控制台
  - 第二套角色系统
  - 第二套权限中心

## 4. Current Scope Of The Unlock

- 当前 `组织成员管理最小承接` 只允许真实承接：
  - 当前 organization scope 下的成员列表
  - 最小角色调整
  - 最小成员禁用
  - 成功与受控失败后的真值回读
- 当前正式禁止扩到：
  - admin review
  - governance center
  - 风险标签
  - 审批流控制台
  - 完整公司治理后台
  - 完整权限体系重构
- 当前该包仍必须保持：
  - bounded
  - app-native
  - `profile` family 内消费
  - `Server` truth owner 不变

## 5. Relationship With Existing Round 1 Documents

- 本补充单对以下旧表述做局部 supersede：
  - `my_building_functionality_body_round1_increment_dispatch_judgment_addendum.md`
  - `my_building_functionality_body_round1_next_increment_dispatch_judgment_addendum.md`
- supersede 只发生在：
  - `organization members list / role / disable` 当前是否仍为纯冻结项
- 其它边界继续不变：
  - `certification/resubmit` success sample 继续冻结
  - `admin review / governance` 继续冻结
  - `我的项目` 主体继续只做稳态维护
  - `完整安全中心` 继续冻结在 `devices list / revoke` 之外

## 6. Current Remaining Gaps After This Unlock

- 在 `组织成员管理最小承接` 正式重开后，当前仍未完成但继续冻结的只剩：
  - `certification/resubmit` success sample
  - `admin review / governance`
  - `我的项目` owner action execution
  - `organizationType=both` richer dual-role semantics
  - `我的项目` richer 私域状态、附件、治理、动作矩阵
- 当前不再允许把：
  - `organization members list / role / disable`
 继续写成：
  - “当前继续冻结”
  - “不得打开”

## 7. Current Dispatch Meaning

- 当前 dispatch recommendation：
  - `Go` for `组织成员管理最小承接 bounded unlock` inside `我的楼功能本体 Round 1`
- 其真实含义只有：
  - 本轮结果校验不得再把 members 实现本身判成“越权施工”
  - 后续增量推进可以把该包当作当前已正式重开的 bounded package
- 其不代表：
  - 完整治理后台已开放
  - 当前主线可切回任何后段门禁

## 8. Next Unique Action

- 下一轮唯一动作：
  - 重跑《我的楼功能本体 Round 1 结果校验口令：组织成员管理最小承接》
