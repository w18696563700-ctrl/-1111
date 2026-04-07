---
owner: Codex 总控
status: frozen
purpose: Freeze the bounded unlock dispatch for `会话与设备` inside `我的楼功能本体 Round 1`, rectifying the earlier dispatch freeze that still treated `security/devices` as a controlled placeholder after the current minimal implementation package had already been materially established.
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
  - apps/server/src/modules/identity/entities/device.entity.ts
  - apps/bff/src/routes/profile/profile-security.service.ts
  - apps/mobile/lib/features/profile/presentation/profile_identity_access_pages.dart
  - apps/mobile/lib/features/profile/data/profile_identity_consumer_layer.dart
  - apps/mobile/test/profile_page_test.dart
  - apps/mobile/test/profile_identity_contract_compat_test.dart
  - apps/mobile/test/my_project_private_carry_test.dart
---

# 《我的楼功能本体 Round 1 会话与设备 bounded unlock 派工补充单》

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
  - `会话与设备` 在当前活跃派工边界中的阶段定义
- 本补充单不把当前主线切回任何后段门禁链

## 2. Why Rectification Is Required

- 先前活跃派工依据仍把：
  - `security/devices`
  - `security/devices/{deviceId}/revoke`
  写成：
  - 受控壳
  - 当前不得扩到 `devices`
- 但当前实现包已经形成最小 bounded consumption：
  - `Server` 已 materialize `GET/POST /server/profile/security/devices*`
  - `BFF` 已只做转发与最小整形
  - `Flutter App` 已有真实设备列表、撤销按钮、成功后刷新与受控失败分支
- 因此当前阻断不再是：
  - 实现未完成
- 而是：
  - 活跃 L0 派工边界尚未正式重开 `会话与设备`

## 3. Formal Rectification

- 自本补充单起，`我的楼功能本体 Round 1` 当前允许新增一个正式 bounded package：
  - `会话与设备 bounded unlock`
- 当前对 `会话与设备` 的正式定义改为：
  - 不再是纯占位壳
  - 已允许作为 `设置 -> 账号与安全` 下的最小真实消费面
- 当前允许的最小消费范围只限：
  - `GET /api/app/profile/security/devices`
  - `POST /api/app/profile/security/devices/{deviceId}/revoke`
- 当前明确不等于：
  - 完整安全中心
  - 风险中心
  - security-events 控制台
  - 设备信任后台

## 4. Current Scope Of The Unlock

- 当前 `会话与设备` 只允许真实承接：
  - 当前用户设备列表
  - 单设备 revoke
  - 当前设备与已撤销设备的最小显示差异
  - 成功与受控失败后的真值回读
- 当前正式禁止扩到：
  - refresh 体系重写
  - logout 主线重写
  - security-events
  - 风险标签
  - 设备信任评分细节
  - admin 安全治理
- 当前 `会话与设备` 仍必须保持：
  - bounded
  - app-native
  - `profile` family 内消费
  - `Server` truth owner 不变

## 5. Relationship With Existing Round 1 Documents

- 本补充单对以下旧表述做局部 supersede：
  - `my_building_functionality_body_round1_increment_dispatch_judgment_addendum.md`
  - `my_building_functionality_body_round1_next_increment_dispatch_judgment_addendum.md`
- supersede 只发生在：
  - `security/devices` 当前是否仍为纯冻结壳
- 其它边界继续不变：
  - `organization members list / role / disable` 继续冻结
  - `certification/resubmit` success sample 继续冻结
  - `admin review / governance` 继续冻结
  - `我的项目` 主体继续只做稳态维护

## 6. Current Remaining Gaps After This Unlock

- 在 `会话与设备` 正式重开后，当前仍未完成但继续冻结的只剩：
  - `organization members list / role / disable`
  - `certification/resubmit` success sample
  - `admin review / governance`
  - `我的项目` owner action execution
  - `organizationType=both` richer dual-role semantics
- 当前不再允许把：
  - `会话与设备`
 继续写成：
  - “只读受控壳”
  - “不得扩到 devices”

## 7. Current Dispatch Meaning

- 当前 dispatch recommendation：
  - `Go` for `会话与设备 bounded unlock` inside `我的楼功能本体 Round 1`
- 其真实含义只有：
  - 本轮结果校验不得再把 `devices` 实现本身判成“越权施工”
  - 后续增量推进可以把 `会话与设备` 当作当前已正式重开的 bounded package
- 其不代表：
  - 完整安全中心已开放
  - 当前主线可切回任何后段门禁

## 8. Next Unique Action

- 下一轮唯一动作：
  - 重跑《我的楼功能本体 Round 1 结果校验口令：会话与设备 bounded unlock》
