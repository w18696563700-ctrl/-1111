---
owner: Codex 总控
status: frozen
purpose: Freeze the bounded unlock dispatch for `certification/resubmit expired-path success sample` inside `我的楼功能本体 Round 1`, rectifying the earlier dispatch freeze that still treated expired-path resubmit success-sample work as frozen after the current expired-path runtime sample had already been materially established.
layer: L0 SSOT
freeze_date_local: 2026-04-05
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/my_building_functionality_body_round1_increment_dispatch_judgment_addendum.md
  - docs/00_ssot/my_building_functionality_body_round1_next_increment_dispatch_judgment_addendum.md
  - docs/00_ssot/my_building_functionality_body_round1_certification_resubmit_rejected_path_bounded_unlock_dispatch_addendum.md
  - docs/00_ssot/account_and_enterprise_certification_rules_v1_app_aligned_freeze_addendum.md
  - docs/01_contracts/account_and_enterprise_certification_rules_v1_contracts_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md
  - docs/03_bff/account_and_enterprise_certification_rules_v1_bff_surface_addendum.md
  - docs/04_frontend/account_and_enterprise_certification_rules_v1_frontend_surface_addendum.md
  - apps/server/src/modules/profile/profile-certification-write.service.ts
  - apps/server/src/modules/profile/profile-query.service.ts
  - apps/server/src/modules/profile/profile.presenter.ts
  - apps/bff/src/routes/profile/profile-command.service.ts
  - apps/mobile/lib/features/profile/presentation/profile_identity_access_pages.dart
  - apps/mobile/lib/features/profile/presentation/profile_detail_pages.dart
---

# 《我的楼功能本体 Round 1 certification/resubmit expired-path bounded unlock 派工补充单》

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
  - `certification/resubmit success sample` 在当前活跃派工边界中的阶段定义
- 本补充单不把当前主线切回任何后段门禁链

## 2. Why Rectification Is Required

- 先前活跃派工依据仍把：
  - `certification/resubmit success sample`
  写成：
  - 当前继续冻结
  - 只有当真实 `rejected / expired` truth 进入当前范围后，才允许继续推进
- `rejected-path` 已经在前一份补充单中正式重开。
- 当前 `expired-path` 的实现包也已经形成可独立引用的真实 runtime sample：
  - 当前验证环境已真实跑通：
    - `expired -> resubmit`
  - resubmit 前 truth 已真实落为：
    - `expired`
    - `expiresAt` 非空且已过期
  - resubmit 后 truth 已真实回到：
    - `pending_review`
    - `expiresAt = null`
    - `submittedAt` 已刷新
- 因此当前阻断不再是：
  - expired-path runtime sample 不存在
- 而是：
  - 活跃 L0 派工边界尚未正式重开 `expired-path certification/resubmit success sample`

## 3. Formal Rectification

- 自本补充单起，`我的楼功能本体 Round 1` 当前允许新增一个正式 bounded package：
  - `certification/resubmit expired-path bounded unlock`
- 当前对该包的正式定义改为：
  - 不再是纯冻结占位
  - 已允许作为 `认证与成员身份 / 我的公司 / 我的楼 hub` 下的最小真实消费链
- 当前允许的最小消费范围只限：
  - 一个已真实成立的 `expired` certification truth
  - `POST /api/app/profile/certification/resubmit`
  - success 后最小 read-back 回到：
    - `pending_review`
- 当前明确不等于：
  - 完整 certification review/resubmit 体系
  - admin review console 开放
  - governance center 开放

## 4. Current Scope Of The Unlock

- 当前 `certification/resubmit` 只允许真实承接：
  - `expired-path` success sample
  - `expiresAt` 的最小 projection
  - resubmit success 后同源 read-back
- 当前正式禁止扩到：
  - admin review 列表/详情/控制台
  - appeals
  - governance status center
  - 第二套 review 流转页面
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
  - `certification/resubmit success sample` 当前是否仍为纯冻结项
- 本补充单只重开：
  - `expired-path`
- 其它边界继续不变：
  - `admin review / governance` 继续冻结
  - `我的项目` 主体继续只做稳态维护
  - `完整安全中心` 继续冻结在 `devices list / revoke` 之外

## 6. Current Remaining Gaps After This Unlock

- 在 `certification/resubmit expired-path bounded unlock` 正式重开后，当前仍未完成但继续冻结的只剩：
  - `admin review / governance`
  - `我的项目` owner action execution
  - `organizationType=both` richer dual-role semantics
  - `我的项目` richer 私域状态、附件、治理、动作矩阵
- 当前不再允许把：
  - `certification/resubmit expired-path success sample`
 继续写成：
  - “当前继续冻结”
  - “当前不得推进”

## 7. Current Dispatch Meaning

- 当前 dispatch recommendation：
  - `Go` for `certification/resubmit expired-path bounded unlock` inside `我的楼功能本体 Round 1`
- 其真实含义只有：
  - 本轮结果校验不得再把 expired-path resubmit 实现本身判成“越权施工”
  - 后续增量推进可以把 expired-path 当作当前已正式重开的 bounded package
- 其不代表：
  - 完整 review/resubmit 体系已开放
  - admin review / governance 已开放
  - 当前主线可切回任何后段门禁

## 8. Next Unique Action

- 下一轮唯一动作：
  - 输出《我的楼功能本体 Round 1 BFF 派工口令：certification/resubmit expired-path app-facing 对齐》
