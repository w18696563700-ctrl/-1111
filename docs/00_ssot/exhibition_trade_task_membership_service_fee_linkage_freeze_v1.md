---
title: exhibition_trade_task_membership_service_fee_linkage_freeze_v1
owner: Codex 总控
status: superseded
layer: L0 SSOT
updated_at: 2026-04-28
purpose: Historical membership-tier service-fee linkage freeze retained for audit and migration comparison only; no longer the current fee-rule owner after platform_pricing_rules_master_v1.
inputs_canonical:
  - docs/00_ssot/exhibition_trade_task_payment_mainline_p0_pay_freeze_v1_3.md
  - docs/02_backend/exhibition_trade_task_p0_pay_server_truth_addendum_v1_3.md
  - docs/00_ssot/my_building_v20_membership_entitlement_and_quota_rules_addendum.md
  - docs/00_ssot/bid_submit_material_access_template_grid_p0_pay_copy_ruling_addendum.md
  - docs/03_bff/exhibition_trade_task_p0_pay_bff_surface_freeze_addendum_v1_3.md
  - docs/04_frontend/bid_submit_template_grid_and_p0_pay_copy_frontend_surface_addendum.md
---

# P0-Pay 会员分层服务费率联动 L0 规则冻结单 V1

## Supersede Note

自 `2026-04-29` 起，本文件不再作为当前费率总裁决使用。

当前唯一收费母文件改为：

- [platform_pricing_rules_master_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/platform_pricing_rules_master_v1.md)

本文件保留为历史记录，仅用于：

1. 回看旧 `固定 3% -> 会员分层费率联动` 的演进方案
2. 对比旧 `No-Go` 逻辑与新收费母文件之间的差异
3. 后续 contracts / backend / BFF / Flutter 重写时的迁移参考

以下旧结论不再作为当前收费施工真相继续指挥：

1. `当前正式费率仍固定 3%`
2. `2.5% / 2.0% / 1.5%` 当前只能作为 future linkage 候选
3. `会员分层费率正式启用 = No-Go`

## 0. 总裁决

- 当前是否允许正式启用会员分层服务费率：`No-Go`
- 当前是否允许把 `2.5% / 2.0% / 1.5%` 写成现行运行规则：`No-Go`
- 当前是否允许进入 L0 fee linkage freeze：`Go`
- 当前是否允许进入 L2 Contracts authoring：`Go after this L0 freeze`
- 当前是否允许 Server / BFF / Flutter implementation：`No-Go`
- 当前是否允许云端写入或支付链路改造：`No-Go`

核心原因：

- 当前 P0-Pay 正式运行规则仍是固定 `3%`。
- 会员分层费率当前仍是候选商业参数，不是当前正式上线参数。
- P0-Pay 尚未接入组织会员等级读取、费率快照、contracts 字段、BFF 投影和 Flutter 动态展示。
- 本文件只冻结未来联动规则，不改变当前运行真相。

下一轮唯一动作：

- 进入 L2 Contracts addendum 编写，补齐会员费率快照字段。

## 1. 当前 blocker 复核

| blocker | 当前证据 | 是否仍成立 | 处理方向 |
|---|---|---:|---|
| 正式 P0-Pay 仍是固定 `3%` | `exhibition_trade_task_payment_mainline_p0_pay_freeze_v1_3.md` 写明 `平台服务费率：3%`；`exhibition_trade_task_p0_pay_server_truth_addendum_v1_3.md` 写明 `P0 平台服务费率固定为 3%` | 是 | 本轮不改现行费率，只冻结未来联动规则 |
| 会员分层费率仍是候选参数 | `my_building_v20_membership_entitlement_and_quota_rules_addendum.md` 写明费率仍属于候选商业参数，不属于现行冻结运行参数 | 是 | 本文件不得把候选费率写成已启用规则 |
| 竞标提交侧仍暂不开通会员分层 | `bid_submit_material_access_template_grid_p0_pay_copy_ruling_addendum.md` 与 `bid_submit_template_grid_and_p0_pay_copy_frontend_surface_addendum.md` 均保留 `服务费率会员分层` 为暂不开通 | 是 | L2/L3/L4/L5 全链通过前继续 No-Go |
| Contracts 字段不足 | `exhibition_trade_task_p0_pay_contracts_addendum_v1_3.md` 只有 `feeRate` 等最小字段，缺 `feeRateSource / membershipTierSnapshot / feeRateRuleVersion / feeRateSnapshotHash / feeCalculatedAt` | 是 | 下一轮 L2 Contracts 补字段 |
| Server 仍写死 `0.03` | `apps/server/src/modules/p0_pay/p0-pay.state.ts` 仍有 `P0_PAY_DEFAULT_SERVICE_FEE_RATE = 0.03` | 是 | L3 Server truth 与后续 implementation 解锁后再改 |
| 会员等级读模型有基础但未接入 P0-Pay | `apps/server/src/modules/membership/membership.query.service.ts` 可读 `paidMembershipTier`；P0-Pay 模块未读取该 query | 是 | L3 Server truth 冻结 policy 接入点 |
| BFF 只读旧 `feeRate` | `apps/bff/src/routes/exhibition_p0_pay/exhibition-p0-pay.read-model.ts` 只投影 `feeRate` 等旧字段 | 是 | L4 BFF 只读投影补字段 |
| Flutter 竞标侧仍展示/预估 `3%` | `p0_pay_bid_authorization_support.dart` 写有 `成交金额的 3%` 与 `quoteAmount * 0.03` | 是 | L5 Flutter 去硬编码 |

## 2. 会员费率联动规则冻结

| 规则项 | 冻结结论 | 原因 |
|---|---|---|
| 费率享受主体 | `factoryOrganizationId` 对应的工厂组织 | 平台服务费由竞标工厂承担，不能按个人账号、当前登录人或发布方组织计算 |
| 费率来源 | Server 读取该 `factoryOrganizationId` 的当前有效 organization paid membership tier | Server 是业务真相 owner；BFF/Flutter 不得拥有费率真相 |
| 当前正式费率 | 仍为固定 `3.0%` | 现行 P0-Pay 已冻结为 3%，本文件不改变运行规则 |
| 未来映射：none | `3.0%` | 无有效会员等级时回退默认费率 |
| 未来映射：free_certified | `3.0%` | 免费认证企业默认费率，不构成折扣 |
| 未来映射：standard | `2.5%` | 标准会员候选费率，待 L2-L5 和 runtime 全链通过后才能启用 |
| 未来映射：professional | `2.0%` | 专业会员候选费率，待 L2-L5 和 runtime 全链通过后才能启用 |
| 未来映射：ka / flagship | `1.5%`，首版可保留不开 | 当前会员 catalog 首轮未形成完整 KA / flagship 运行真相；字段可预留，启用需单独门禁 |
| 费率锁定时点 | 平台服务费预授权创建时由 Server 锁定 `feeRate` 与 fee snapshot | 避免会员升级、过期或降级导致同一交易反复变价 |
| 合同确认扣费 | 合同确认时只使用预授权时锁定的 `feeRate` 乘以 `finalConfirmedAmount` 计算 `finalFeeAmount` | 合同确认金额是真实最终成交金额；会员等级不得在合同确认时重新读取 |
| 预授权前升级 | 若预授权创建时会员已生效，按升级后的当前有效等级计算 | 费率以预授权创建时 Server 读取结果为准 |
| 预授权后升级 | 不影响本单已锁定费率 | 交易快照优先，避免事后改价 |
| 预授权前过期 | 预授权创建时已无有效等级，则按当前有效等级或默认 `3.0%` 计算 | 以 Server 当前有效会员周期为准 |
| 预授权后过期 | 不影响本单已锁定费率 | 已授权交易保持可审计一致性 |
| 预授权后降级 | 不影响本单已锁定费率 | 已授权交易保持可审计一致性 |
| 未知 tier | 首版必须 fail closed 到 `3.0%`，并在 snapshot 中标记未知来源原因 | 禁止未知 tier 获得错误折扣 |
| membership query 失败 | 首版不得静默给折扣；应 fail closed 或返回受控错误，由 L3 冻结具体策略 | 收费规则不能在依赖失败时误降费 |
| 前端回传 expectedFeeRate | 只能作为 Server 返回值的确认回显；Server 必须重新以自身计算和快照校验，不能信任前端输入 | 当前 P0-Pay 有 expected amount 校验链，不能把它误解为前端拥有费率真相 |

## 3. 快照字段方向冻结

### 3.1 预授权侧最小快照

`PlatformServiceFeeAuthorization` 后续至少需要在 L2 Contracts 中正式定义以下方向：

- `feeRate`
- `feeRateLabel`
- `feeRateSource`
- `membershipTierSnapshot`
- `membershipTierAtAuthorization`
- `feeRateRuleVersion`
- `feeRateSnapshotHash`
- `feeCalculatedAt`
- `estimatedFeeAmount`
- `agreementTextSnapshot`

### 3.2 合同确认扣费侧最小快照

`PlatformServiceFeeCharge` 后续至少需要在 L2 Contracts 中正式定义以下方向：

- `finalConfirmedAmount`
- `feeRate`
- `finalFeeAmount`
- `feeRateSource`
- `membershipTierSnapshot`
- `feeRateRuleVersion`
- `feeRateSnapshotHash`

说明：

- 合同确认侧不重新读取会员等级。
- 若后续为了审计展示合同确认当日会员状态，只能作为非计费审计信息，不得参与本单费率计算。
- 本节不是 L2 Contracts 字段完成态；字段类型、枚举、可空性、兼容策略与响应位置必须由下一轮 L2 Contracts addendum 正式冻结。

## 4. Server / BFF / Flutter 边界

| 层级 | 冻结职责 | 禁止事项 |
|---|---|---|
| Server | 唯一 fee rate 计算 owner；唯一 fee snapshot owner；读取 organization paid membership tier；保存 authorization / charge 快照 | 禁止依赖 Flutter/BFF 传入的 feeRate 作为真相；禁止合同确认时重新取会员等级参与计费 |
| BFF | 只读投影、字段整形、可见性裁剪、受控错误承接 | 禁止计算会员等级；禁止计算 `2.5% / 2.0% / 1.5%`；禁止覆盖 Server feeRate |
| Flutter | 展示 BFF/Server 返回的 feeRate、feeRateLabel、estimatedFeeAmount、membershipTierSnapshot；提交确认动作 | 禁止本地计算正式费率；禁止把 `quoteAmount * rate` 作为正式真相；禁止伪造会员等级或 fee snapshot |

## 5. 当前最小闭环

本阶段只允许完成：

- L0 规则冻结。
- blocker 复核。
- 未来 L2 Contracts 字段方向冻结。
- 阶段门禁结论。

本阶段不允许：

- 改代码。
- 改 contracts。
- 改 OpenAPI / generated types。
- 改 BFF / Server / Flutter。
- 改数据库 / migration。
- 动云端服务。
- 启用会员分层费率。

## 6. 需要保留但暂不开通

- `standard = 2.5%`
- `professional = 2.0%`
- `ka / flagship = 1.5%`
- 单笔服务费封顶。
- 活动费率。
- 后台配置费率。
- 城市、行业、大客户差异费率。
- 支付通道真实预授权 / 扣费流程的会员折扣运行态启用。

## 7. 后续扩展位

- L2 Contracts addendum：补齐 fee snapshot 字段。
- L3 Server truth addendum：冻结 `P0PayServiceFeeRatePolicy`、异常策略、精度策略、快照 hash 规则。
- L3 Persistence / migration addendum：补授权表与扣费表字段、旧数据兼容与回滚方案。
- L4 BFF surface addendum：冻结只读投影字段和 fail-closed 行为。
- L5 Flutter consumption addendum：冻结去硬编码、Unknown 态和展示文案。
- Implementation unlock addendum：只有 L0-L5 文书链通过后才能进入实现。
- Verification receipt：双账号 / 多会员等级 / runtime 证据齐全后再进入正式启用门禁。

## 8. 阶段门禁

| 阶段 | 当前结论 | 是否允许进入 | blocker |
|---|---|---:|---|
| L0 Rule Freeze | 本文件完成后成立 | 是 | 需保持 No-Go for enablement |
| L2 Contracts | 下一轮唯一动作 | 是 | 需补 fee snapshot 字段 |
| L3 Server Truth | 尚未开始 | 否 | 等 L2 字段冻结 |
| L3 Persistence | 尚未开始 | 否 | 等 L3 Server truth |
| L4 BFF | 尚未开始 | 否 | 等 Server 返回字段冻结 |
| L5 Flutter | 尚未开始 | 否 | 等 BFF 投影冻结 |
| Implementation | 尚未解锁 | 否 | 等 L0-L5 文书链与 implementation unlock |
| Runtime Verification | 尚未具备 | 否 | 等实现部署与测试账号证据 |
| Formal Enablement | `No-Go` | 否 | 所有 blocker 未清零 |

## 9. Go / No-Go

- `Go` for L2 Contracts addendum authoring.
- `No-Go` for Server implementation.
- `No-Go` for BFF implementation.
- `No-Go` for Flutter implementation.
- `No-Go` for migration.
- `No-Go` for cloud write.
- `No-Go` for enabling `2.5% / 2.0% / 1.5%` in runtime.

## 10. 下一轮唯一动作

进入 L2 Contracts addendum 编写：

- 定义 `platformServiceFeeRequirement` 的会员费率快照字段。
- 定义 service-fee authorization response 的快照字段。
- 定义 contract-confirmation / charge response 的快照字段。
- 明确字段 owner 为 Server。
- 明确 Flutter/BFF 不得作为 feeRate 真源。
