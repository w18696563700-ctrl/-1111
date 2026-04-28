---
title: exhibition_trade_task_membership_service_fee_linkage_final_verification_receipt_v1
owner: Codex 总控
status: frozen
layer: L0 Verification Receipt
updated_at: 2026-04-29
purpose: Record Day 8 read-only runtime verification, Day 9 controlled-write gate, and Day 10 formal enablement Go/No-Go for P0-Pay membership-tier service-fee linkage.
inputs_canonical:
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_freeze_v1.md
  - docs/01_contracts/exhibition_trade_task_membership_service_fee_linkage_contracts_addendum_v1.md
  - docs/02_backend/exhibition_trade_task_membership_service_fee_linkage_server_truth_addendum_v1.md
  - docs/02_backend/exhibition_trade_task_membership_service_fee_linkage_persistence_migration_unlock_addendum_v1.md
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_day9_controlled_write_unlock_request_v1.md
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_day9_controlled_write_receipt_v1.md
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_runtime_alignment_gate_checklist_v1.md
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_runtime_alignment_execution_receipt_v1.md
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_day10_formal_enablement_gate_receipt_v1.md
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_day10a_controlled_sample_receipt_v1.md
  - apps/server/src/modules/p0_pay/p0-pay-service-fee-rate.policy.ts
  - apps/bff/src/routes/exhibition_p0_pay/exhibition-p0-pay.read-model.ts
  - apps/mobile/lib/features/exhibition/presentation/presentation_support/p0_pay_bid_authorization_support.dart
---

# P0-Pay 会员分层服务费率联动 Day 8-10 验证回执 V1

## 0. 总裁决

- 第 8 天只读 runtime 联调：`Pass with Evidence Missing`
- 第 9 天受控测试数据联调：`Pass for standard tier snapshot after runtime alignment`
- 第 10 天正式启用门禁：`Go for full tier authorization snapshot / No-Go for payment auto-unlock`
- Day 10A 受控样本补证：`Pass`
- 当前是否允许正式启用 `2.5% / 2.0% / 1.5%` 全量会员分层服务费率的 authorization snapshot 链路：`Go`
- 当前是否允许支付初始化 / callback / 真实扣款 / 合同确认扣费自动放行：`No-Go`
- 核心原因：云端 Server/BFF 已对齐本地 Day 5/6 实现，`standard / professional / ka / flagship` 的 fee requirement、authorization snapshot 和 BFF summary 投影均已通过；所有样本均停在 `pending_authorization`，未进入支付。
- 下一轮唯一动作：进入正式启用收口包，明确发布口径、回滚路径和支付链路后续门禁；不得自动调用 authorize-init 或扣款。

## 1. Day 8 只读 Runtime 证据

| 项 | 结果 | 证据 | 结论 |
|---|---|---|---|
| SSH 隧道 | 可用 | `127.0.0.1:8080` 已由 ssh 监听 | Pass |
| app-facing API | 可用 | `GET /api/app/project/list` 返回 200 | Pass |
| health endpoint | 未暴露 | `GET /health/live`、`GET /health/ready` 返回 nginx 404 | Evidence Missing |
| 测试账号 A 登录 | 可用 | password login 返回 200，shell context 返回 200 | Pass |
| 测试账号 A membership | 可读但无等级 | `paidMembershipTier = null`、`rateBand = null` | Evidence Missing |
| 测试账号 B 登录 | 可用 | password login 返回 200，shell context 返回 200 | Pass |
| 测试账号 B membership | 可读但无等级 | `paidMembershipTier = null`、`rateBand = null` | Evidence Missing |
| P0-Pay summary A 项目 | 可读但无 fee snapshot | `platformServiceFee.status = not_required` | Evidence Missing |
| P0-Pay summary B 项目 | 可读但无 fee snapshot | `platformServiceFee.status = not_required` | Evidence Missing |
| 权限边界 | 正常 | 非可读项目返回 `P0_PAY_PERMISSION_DENIED` 403 | Pass |

## 2. Flutter 展示核对

| 项 | 结果 | 证据 | 结论 |
|---|---|---|---|
| 用户可见固定 3% | 已删除 | `rg` 未发现 `成交金额的 3%` 或 P0-Pay service fee `quoteAmount * 0.03` | Pass |
| 提交前展示 | 安全 | 显示 `待平台返回`，不本地计算正式金额 | Pass |
| BFF 字段消费 | 已接入 | Flutter 读取 `feeRate`、`feeRateLabel`、`feeRateSource`、`membershipTierSnapshot`、`estimatedFeeAmount` | Pass |
| Unknown 态 | 已接入 | BFF 未返回 `platformServiceFeeRequirement` 时显示服务费快照未返回 | Pass |
| Computer Use 云端展示 | 未出现动态费率样本 | 当前云端项目未开放可验证的 bid service-fee 面 | Evidence Missing |

## 3. Day 9 受控测试数据联调门禁

| 门禁项 | 当前结论 | 是否通过 |
|---|---|---:|
| 是否获得单独明确云端写入授权 | 已获得，用户确认“确认执行 Day9 受控写入包” | 是 |
| 是否有会员等级测试样本 | 已为工厂组织写入临时 `standard` 会员记录并回读成功 | 是 |
| 是否创建测试任务和测试竞标 | 已创建固定价测试任务与固定价测试竞标 | 是 |
| 是否返回会员分层 fee snapshot | 未返回，仍为固定 `0.030000` 且缺 snapshot 字段 | 否 |
| 是否确认不会触发真实支付扣款 | 已按 stop rule 停止，未调用 authorize-init / payment callback / contract confirmation | 是 |

Day 9 初次裁决：`Executed with Stop`。允许的 membership seed、测试任务、测试竞标已完成；由于云端 active runtime 仍返回固定 `3%` 且缺 snapshot 字段，service-fee authorization 未创建。

Day 9 证据冻结在：

- `docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_day9_controlled_write_receipt_v1.md`
- `docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_runtime_alignment_execution_receipt_v1.md`

关键 runtime 证据：

| 证据项 | 结果 |
|---|---|
| 测试会员记录 | `organization_paid_memberships.id = day9-standard-bdfb4523-20260429` |
| 工厂组织 | `bdfb4523-aeb7-4b56-89a1-992170fb5d98` |
| 工厂会员回读 | `paidMembershipTier = standard` |
| 测试任务 | `taskId = e75af0c1-1ae1-428f-84fa-38d15e67ff2c` |
| 测试竞标 | `bidId = 4b021100-ada1-43ab-8029-c943911f83cd` |
| bid requirement feeRate | `0.030000` |
| bid requirement estimatedFeeAmount | `3000.00` |
| authorization count | `0` |

Runtime alignment 后 Day 9 重跑证据：

| 证据项 | 结果 |
|---|---|
| Release ID | `20260429013340-membership-fee-runtime-alignment` |
| 工厂会员回读 | `paidMembershipTier = standard` |
| 测试任务 | `4faacb53-2431-4eac-9635-4177ca2c6a1c` |
| 测试竞标 | `4a6c2ba8-86ca-4c80-bb7c-ac84f572bc01` |
| bid requirement feeRate | `0.025000` |
| bid requirement source | `paid_membership_tier` |
| bid requirement tier | `standard` |
| bid requirement estimatedFeeAmount | `2500.00` |
| authorization id | `f6f6c17a-e307-4365-8c90-128f0f9d611b` |
| authorization status | `pending_authorization` |
| payment init / callback / charge | 未触发 |

Day 10A 高阶样本证据：

| tier | feeRate | authorizationId | status |
|---|---:|---|---|
| professional | `0.020000` | `4d937b2d-9c3d-4bdc-bfe5-2c631a22b917` | `pending_authorization` |
| ka | `0.015000` | `7741424d-fd33-4abb-aa7b-9fc86b662739` | `pending_authorization` |
| flagship | `0.015000` | `66bc7f72-d869-4f8e-84e5-f67fc671e41f` | `pending_authorization` |

Day 10A 临时高阶会员记录已置为过期，当前有效 paid membership tier 仅剩 `standard` 测试记录。

## 4. 本地实现验证

| 层 | 命令 | 结果 |
|---|---|---|
| Server | `node --test test/p0-pay-calculator-idempotency.test.cjs test/p0-pay-server-mainline.test.cjs` | Pass，12/12 |
| BFF | `node --test test/exhibition-p0-pay-transport.test.cjs` | Pass，8/8 |
| Flutter | `flutter analyze` 指定 P0-Pay 相关 4 个文件 | Pass |
| Flutter | `flutter test test/p0_pay_flutter_consumption_test.dart` | Pass，7/7 |
| Flutter | `flutter test test/shell_app_test.dart --name "bid submit service fee uses fixed validity and user-facing copy"` | Pass |
| Flutter | `flutter test test/shell_app_test.dart --name "bid submit default content no longer exposes technical disclosure copy"` | Pass |

## 5. Day 10 正式启用门禁

| 阶段 | 当前结论 | blocker |
|---|---|---|
| L0 Rule Freeze | Pass | 无 |
| L2 Contracts | Pass | OpenAPI / generated types 尚未同步，仍属后续门禁 |
| L3 Server Truth | Pass | 云端 `standard -> 2.5%` 已验证 |
| L3 Persistence | Pass | 云端 migration key 已落库，snapshot columns 存在 |
| L4 BFF | Pass | 云端 p0-pay-summary 已投影 fee snapshot |
| L5 Flutter | Pass locally | Flutter 消费动态字段，本轮未重测 UI 截图 |
| Runtime Verification | Pass for standard | `paidMembershipTier = standard`、fee snapshot 已回读 |
| Controlled Write Verification | Pass for standard | authorization snapshot 已创建，停在 `pending_authorization` |
| Formal Enablement | Go / No-Go | 全量 authorization snapshot 链路可放行；支付初始化、callback、扣款和合同确认扣费仍 No-Go |

## 6. 回滚方案

若后续受控联调失败，回滚策略为：

1. 云端不启用会员分层费率开关或等价配置。
2. 保持 Server 固定 3% 现行规则作为正式运行规则。
3. Flutter 保留“待平台返回 / 以平台返回为准”展示，不恢复本地 3% 计算。
4. BFF 保持只读透传，不补算费率。
5. 已有旧数据继续按 `legacy_fixed_default` 或旧字段兼容显示。

## 7. 下一轮唯一动作

进入正式启用收口包：

- 明确启用范围仅为 fee requirement、authorization snapshot、BFF/Flutter 展示。
- 明确支付初始化、callback、真实扣款、合同确认扣费仍需单独门禁。
- 明确 rollback target 与清理策略。
