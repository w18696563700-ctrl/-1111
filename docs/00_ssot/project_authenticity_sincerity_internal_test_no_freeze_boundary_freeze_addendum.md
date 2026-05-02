---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the L0 boundary for the internal-test waiver of the current
  `200 元项目真实性诚意金` publish gate. The waiver keeps the full order and
  pay-init process visible, but temporarily does not freeze or charge real
  funds during internal testing.
layer: L0 SSOT
freeze_date_local: 2026-05-02
version: V1
effective_scope: project_authenticity_sincerity_internal_test_no_freeze
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/platform_pricing_rules_master_v1.md
  - docs/00_ssot/payment_finance_mainline_l0_freeze.md
  - docs/00_ssot/platform_pricing_day12_final_acceptance_receipt.md
  - docs/01_contracts/platform_pricing_contracts_master_v1.md
  - docs/02_backend/platform_pricing_backend_truth_master_v1.md
  - docs/03_bff/platform_pricing_bff_surface_master_v1.md
  - docs/04_frontend/platform_pricing_frontend_consumption_master_v1.md
  - apps/server/src/modules/project/project-write.service.ts
  - apps/server/src/modules/p0_pay/p0-pay-trade-task.service.ts
  - apps/bff/src/routes/exhibition_p0_pay/exhibition-p0-pay.read-model-support.ts
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/presentation_support/project_publish_progress_support.dart
---

# 《项目真实性诚意金内测暂不冻结边界冻结单》

## 0. 总裁决

本轮冻结 `Conditional Pass`：

1. Go for `L2 contracts freeze` authoring.
2. Go for bounded local implementation after L2 contracts are frozen.
3. No-Go for Flutter-only fake waiver.
4. No-Go for marking the order as `paid / frozen / succeeded / satisfied`.
5. No-Go for cloud deploy, cloud database migration, Nginx, systemd, or production config mutation until the deployment gate is separately opened.

当前问题不是“按钮打不开支付宝”本身，而是现网内测阶段支付通道可能返回：

```text
channelActionType=unavailable
reasonCode=alipay_app_pay_disabled
paymentInitStatus=pending_user_confirm
```

在当前正式真相里，`project/publish` 仍要求 `200 元项目真实性诚意金` 处于 `paid`，所以只改前端文案会让用户看到“内测暂不冻结”，但 Server 仍会拒绝发布。

## 1. 当前只读核实结论

| 核实项 | 当前事实 | 裁决 |
|---|---|---|
| SSOT | `platform_pricing_rules_master_v1` 将发布前 `200 元项目真实性诚意金` 冻结为当前收费主线 | 需要新增内测豁免 addendum |
| contracts | `platform_pricing_contracts_master_v1` 写明状态不是 `paid` 不得发布 | 必须追加 L2 contract |
| Server publish gate | `project-write.service.ts` 当前只查询 `status='paid'` 的订单 | 不能靠 Flutter 绕过 |
| pricing summary | `p0-pay-trade-task.service.ts` 返回当前 deposit status 或 `not_required` | 需返回正式豁免状态 |
| BFF shaping | `readPublisherPricing` 当前按 `status === 'paid'` 得出 `publishGateStatus=satisfied` | 需承认豁免状态但不伪造 paid |
| Flutter | 现有 satisfied 只承认 `paid/frozen/succeeded/satisfied/not_required` | 需消费正式豁免状态 |
| Runtime evidence | 云端验收曾记录未付 200 发布返回 `PROJECT_AUTHENTICITY_SINCERITY_REQUIRED` | 说明 Server 门禁是真阻断 |

## 2. 当前最小闭环

本轮最小闭环只做：

1. 新增正式状态：`internal_test_no_freeze_required`。
2. 该状态表示：内测阶段不冻结真实资金，但项目仍处在需要完成诚意金流程的业务分支。
3. Server 在配置开关打开时，可把发布门禁判定为 `internal_test_no_freeze_allowed`。
4. pricing summary / publish gate 必须返回可被 App 明确识别的豁免状态和说明文案。
5. pay-init 仍可发起，支付通道不可用时不得推进成支付成功。
6. 用户反馈只记录“支持冻结 / 反对冻结”的统计，不影响支付状态、不影响发布门禁。
7. App 只展示 Server/BFF 返回的状态和统计，不本地推断豁免。

## 3. 需要保留但暂不开通

本轮必须保留但暂不开通：

1. 正式支付宝 App 支付或预授权冻结。
2. 钱包、余额、平台资金池。
3. 退款、扣款、财务后台、发票、结算。
4. 根据用户反馈自动改变收费规则。
5. 运营后台配置开关 UI。
6. 多维度问卷、反馈原因、用户分层统计。

## 4. 后续扩展位

后续扩展位只保留为：

1. 正式期关闭内测豁免后恢复 `paid` 硬门禁。
2. 在 Admin 增加配置开关和反馈统计看板。
3. 支持分组织、分项目类型、分城市的收费策略 A/B。
4. 完整支付通道启用后的真实冻结、退款、扣除、对账闭环。

## 5. 状态边界

`internal_test_no_freeze_required` 的正式语义：

1. 它不是 `paid`。
2. 它不是 `frozen`。
3. 它不是 `succeeded`。
4. 它不是 `not_required`。
5. 它不是财务完成、资金冻结、支付成功或退款完成。
6. 它只表示：内测政策允许当前项目在未冻结真实资金时继续走发布确认。

发布门禁派生状态冻结为：

| 状态 | 语义 |
|---|---|
| `required` | 仍需完成 200 元项目真实性诚意金 |
| `satisfied` | 已有 Server 确认的 `paid` 状态 |
| `internal_test_no_freeze_allowed` | 内测豁免允许继续发布，但未冻结真实资金 |
| `blocked` | 状态冲突、订单不可用或门禁不可判定 |

## 6. 用户反馈边界

反馈最小闭环冻结为：

1. choice 只允许 `support_freeze` / `oppose_freeze`。
2. 同一 `userId + projectId` 只能保留一条有效选择，重复点击为覆盖选择，不刷票。
3. 统计最小返回：`supportFreezeCount`、`opposeFreezeCount`、`myChoice`、`updatedAt`。
4. 反馈不得改变：
   - `ProjectAuthenticitySincerityOrder.status`
   - `PaymentOrder.status`
   - `Project.state`
   - publish gate decision
   - refund / charge / audit financial truth

## 7. 分层责任

| 层 | 允许做 | 禁止做 |
|---|---|---|
| Server | 持有内测豁免开关、publish gate、pricing summary、反馈统计真相、审计 | 把豁免写成 paid/frozen；让 Flutter 决定门禁 |
| BFF | 透传、整形、错误文案、反馈接口 app-facing 聚合 | 拥有第二门禁或第二统计真相 |
| Flutter | 展示说明、发起反馈、展示统计、继续走原支付流程 | 本地伪造 paid/frozen；本地绕过发布门禁 |
| contracts | 冻结新增状态、字段、反馈接口、错误码 | 暗改旧字段含义 |
| 云端 | 仅在部署门禁开启后按回滚点部署 | 未备份、未授权直接改 DB / runtime |

## 8. 阶段门禁核查表

| Gate | 结果 | 说明 |
|---|---|---|
| L0 SSOT boundary | Pass | 本文件冻结最小闭环、非目标、分层责任 |
| L2 contracts | Pending | 必须新增 contract addendum 后才能施工 |
| L3 Server truth | Pending | 必须由 Server 承接 publish gate truth |
| L4 BFF surface | Pending | BFF 只能转发和 shaping |
| L5 Flutter consumption | Pending | Flutter 必须消费正式状态 |
| Cloud write / deploy | No-Go | 当前未进入云端部署门禁 |
| DB migration | Conditional | 本地 additive migration 可施工；云端 schema 变更需单独部署门禁 |

## 9. 四类判断

| 判断 | 方案 |
|---|---|
| 哪个更稳 | Server 正式返回 `internal_test_no_freeze_required`，publish gate 返回 `internal_test_no_freeze_allowed`，BFF/Flutter 只消费 |
| 哪个更省成本 | 先做配置常量 + pricing summary 字段 + Flutter 文案，不开真实支付通道 |
| 哪个更适合当前阶段 | 内测豁免 + 用户反馈统计 + 保留 pay-init 流程 |
| 哪个风险更大 | Flutter 本地把 `alipay_app_pay_disabled` 当成成功，或把订单状态改成 `paid` |

## 10. 下一步

允许进入：

1. `L2 contracts freeze`：新增 app-facing 状态、字段、反馈接口、错误码。
2. 本地实现前必须先完成 contracts freeze。

不允许进入：

1. 云端部署。
2. 云端数据库迁移。
3. 真实支付通道开通。
4. 财务状态改写。
