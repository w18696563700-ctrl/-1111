---
title: exhibition_trade_task_membership_service_fee_linkage_server_truth_addendum_v1
owner: Codex 总控
status: frozen
layer: L3 Server Truth
updated_at: 2026-04-28
purpose: Freeze the Server truth design for future P0-Pay membership-tier service-fee linkage, without enabling tiered service fees or unlocking implementation.
inputs_canonical:
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_freeze_v1.md
  - docs/01_contracts/exhibition_trade_task_membership_service_fee_linkage_contracts_addendum_v1.md
  - docs/02_backend/exhibition_trade_task_p0_pay_server_truth_addendum_v1_3.md
  - apps/server/src/modules/p0_pay/p0-pay.state.ts
  - apps/server/src/modules/p0_pay/p0-pay-trade-task.service.ts
  - apps/server/src/modules/p0_pay/p0-pay-service-fee.factory.ts
  - apps/server/src/modules/p0_pay/p0-pay-contract-confirmation.service.ts
  - apps/server/src/modules/membership/membership.query.service.ts
---

# P0-Pay 会员分层服务费率联动 L3 Server Truth Addendum V1

## 0. 总裁决

- 当前是否允许正式启用会员分层服务费率：`No-Go`
- 当前是否允许进入 L3 Server truth 冻结：`Go`
- 当前是否允许修改 `apps/server`：`No-Go in this round`
- 当前是否允许 migration：`No-Go in this round`
- 当前是否允许 BFF / Flutter implementation：`No-Go`
- 当前是否允许云端写入、预授权、扣费或 runtime enablement：`No-Go`

核心原因：

- L0 已冻结未来会员费率联动业务规则。
- L2 已冻结 app-facing fee snapshot 字段和字段 owner。
- 当前 Server 仍以固定 `0.03` 作为 P0-Pay 运行真相，本文件只冻结后续 Server truth 设计，不改变运行态。

下一轮唯一动作：

- 进入 L3 Persistence / migration design，冻结 authorization / charge 最小持久化字段、旧数据兼容和回滚方案。

## 1. 当前 Server 真相复核

| blocker | 当前证据 | 是否仍成立 | L3 处理方向 |
|---|---|---:|---|
| P0-Pay 仍固定 `3%` | `apps/server/src/modules/p0_pay/p0-pay.state.ts` 定义 `P0_PAY_DEFAULT_SERVICE_FEE_RATE = 0.03` | 是 | 后续由 `P0PayServiceFeeRatePolicy` 替代直接常量调用 |
| 报价提交返回要求仍按 `0.03` | `p0-pay-trade-task.service.ts` 使用 `calculatePlatformServiceFeeAmount(..., P0_PAY_DEFAULT_SERVICE_FEE_RATE)` 并返回 `feeRate: '0.030000'` | 是 | 后续改为 Server policy 生成 fee requirement preview |
| 预授权校验/创建仍按 `0.03` | `p0-pay-service-fee.factory.ts` 用默认费率校验 expected 值并创建 authorization | 是 | 后续预授权创建时由 policy 生成并锁定 fee snapshot |
| 合同确认扣费仍重新用默认 `0.03` | `p0-pay-contract-confirmation.service.ts` 用 `P0_PAY_DEFAULT_SERVICE_FEE_RATE` 计算 `finalFeeAmount` 与 charge `feeRate` | 是 | 后续必须复用 authorization 锁定 feeRate，不得重新读取会员等级 |
| membership paid tier 可读但不是 P0-Pay 真源 | `membership.query.service.ts` 可按 organization 读取当前有效 `paidMembershipTier`，但 P0-Pay module 未接入 `MembershipModule` | 是 | 后续新增 Server policy 接入 membership truth |
| authorization 快照不完整 | `PlatformServiceFeeAuthorizationEntity` 已有 `feeRate / ruleVersion / ruleSnapshotHash / agreementTextSnapshot`，缺 `feeRateSource / membershipTierSnapshot / feeRateRuleVersion / feeRateSnapshotHash / feeCalculatedAt` | 是 | 下一轮 persistence 设计补字段 |
| charge 快照不完整 | `PlatformServiceFeeChargeEntity` 已有 `finalConfirmedAmount / feeRate / finalFeeAmount`，缺 fee source、tier snapshot、fee rule version/hash | 是 | 下一轮 persistence 设计补字段 |

## 2. Server Owner 冻结

| 真相项 | Owner | 冻结结论 |
|---|---|---|
| 费率计算 | Server | 只能由 Server 根据 `factoryOrganizationId` 的 organization paid membership tier 计算 |
| 费率快照 | Server | 只能由 Server 生成、保存和读回 |
| 会员等级读取 | Server | P0-Pay 通过 Server membership truth 读取，不允许 BFF/Flutter 提供等级 |
| expected fee echo 校验 | Server | Flutter/BFF 只能回显上一跳 Server 值；Server 必须重新计算或读取锁定快照后校验 |
| 合同确认最终金额 | Server | `finalFeeAmount = finalConfirmedAmount * lockedFeeRate`，金额仍以合同确认金额为真 |

禁止事项：

- 禁止 BFF 计算 `2.5% / 2.0% / 1.5%`。
- 禁止 Flutter 计算正式 feeRate 或正式 fee amount。
- 禁止合同确认时重新读取会员等级参与本单计费。
- 禁止把 `expectedFeeRate` 当成前端费率真相。

## 3. `P0PayServiceFeeRatePolicy` 设计冻结

后续 implementation unlock 后，Server 应新增等价于 `P0PayServiceFeeRatePolicy` 的独立策略模块。

建议职责：

1. 接收 `factoryOrganizationId`、`quotedAmount`、`calculatedAt`、`context`。
2. 读取该工厂组织在 `calculatedAt` 时点的当前有效 paid membership tier。
3. 根据冻结映射输出 `feeRate / feeRateLabel / feeRateSource / membershipTierSnapshot`。
4. 使用统一金额算法计算 `estimatedFeeAmount`。
5. 生成 `feeRateRuleVersion / feeRateSnapshotHash / feeCalculatedAt`。
6. 在 authorization 创建时输出可持久化 snapshot。
7. 在合同确认时只提供“复用已锁定 snapshot 计算最终金额”的方法，不重新查询 membership。

建议输出模型：

```ts
type P0PayFeeRateSnapshot = {
  feeRate: string;
  feeRateLabel: string;
  feeRateSource: 'fixed_default' | 'paid_membership_tier';
  membershipTierSnapshot: 'none' | 'free_certified' | 'standard' | 'professional' | 'ka' | 'flagship';
  feeRateRuleVersion: string;
  feeRateSnapshotHash: string;
  feeCalculatedAt: Date;
  estimatedFeeAmount: string;
};
```

兼容读模型中允许 `legacy_fixed_default / unknown`，但新建 authorization 不得使用 `unknown`。

## 4. Membership 查询冻结

当前可用事实：

- `OrganizationPaidMembershipEntity` 以 `organization_id` 绑定 paid membership。
- `membership.query.service.ts` 当前通过：
  - `effective_at <= now`
  - `expires_at IS NULL OR expires_at > now`
  - `effective_at DESC, created_at DESC`
  选取当前有效 cycle。
- `MembershipModule` 已导出 `MembershipQueryService`，但 `P0PayModule` 当前未导入 `MembershipModule`。

后续 Server implementation 需冻结为：

1. P0-Pay 不直接读当前登录人的个人会员。
2. P0-Pay 只按 `factoryOrganizationId` 查询 organization paid membership tier。
3. 查询时点为 authorization 创建时的 Server 时间。
4. 需要在 membership side 增加或暴露专用只读方法，例如：

```ts
getPaidMembershipTierSnapshotForOrganization(
  organizationId: string,
  at: Date
): Promise<{
  tierCode: string | null;
  effectiveAt: Date | null;
  expiresAt: Date | null;
  sourceType: string | null;
  sourceRef: string | null;
}>;
```

5. P0-Pay implementation 应通过 `MembershipModule` 或等价 provider 注入该只读能力。
6. 不得通过 BFF、Flutter、请求 body 或当前个人账号推断会员等级。

## 5. 费率映射冻结

| membership tier snapshot | feeRate | feeRateLabel | feeRateSource | 首版运行规则 |
|---|---:|---|---|---|
| `none` | `0.030000` | `默认费率 3.0%` | `fixed_default` | 无有效 paid membership 时使用 |
| `free_certified` | `0.030000` | `免费认证企业 3.0%` | `fixed_default` | 若 membership truth 显式返回该 tier 时使用 |
| `standard` | `0.025000` | `标准会员 2.5%` | `paid_membership_tier` | L0-L5 + runtime 通过后才可启用 |
| `professional` | `0.020000` | `专业会员 2.0%` | `paid_membership_tier` | L0-L5 + runtime 通过后才可启用 |
| `ka` | `0.015000` | `KA 会员 1.5%` | `paid_membership_tier` | 字段与策略预留；需 KA runtime truth 证据 |
| `flagship` | `0.015000` | `旗舰会员 1.5%` | `paid_membership_tier` | 字段与策略预留；需 flagship runtime truth 证据 |

当前仍是 `No-Go for runtime enablement`，以上映射是后续实现目标，不改变现行固定 `3%`。

## 6. 异常回退冻结

| 场景 | 冻结处理 | 原因 |
|---|---|---|
| 无 paid membership cycle | 使用 `none / fixed_default / 0.030000` | 这是正常默认路径，不是异常 |
| tier 为 `free_certified` | 使用 `fixed_default / 0.030000` | 免费认证企业不产生折扣 |
| tier 为 `standard / professional` | 按映射给折扣 | 仅 implementation/runtime 门禁通过后启用 |
| tier 为 `ka / flagship` | 按映射预留；若当前会员 runtime 未提供样本，则验收标 `Evidence Missing` | 1.5% 需要独立证据 |
| tier 为未知字符串 | 新建 authorization 必须受控失败，不得授予折扣，不得写 `unknown` 新快照 | 防止未知会员等级误降费 |
| membership query 依赖失败 | 新建 authorization 必须受控失败，不得静默按折扣或默认费率继续 | 避免会员用户被错误按 3% 收费，也避免错误折扣 |
| snapshot 字段生成失败 | 新建 authorization 必须受控失败 | 收费规则无快照不可预授权 |
| expected fee echo 与 Server snapshot 不一致 | 拒绝 authorization create，返回刷新当前 fee requirement 的受控错误 | 防止前端旧值或篡改值进入资金链 |

说明：

- 只读历史数据可以显示 `legacy_fixed_default / unknown`。
- 新创建资金相关记录不得写入 `unknown` 作为正常快照。

## 7. 精度与金额算法冻结

| 项 | 冻结结论 |
|---|---|
| feeRate 存储格式 | decimal string，六位小数，例如 `0.025000` |
| 金额输入格式 | decimal string，两位小数 |
| 预计服务费 | `quotedAmount * feeRate`，按 cents 四舍五入，输出两位小数 |
| 最终服务费 | `finalConfirmedAmount * lockedFeeRate`，按 cents 四舍五入，输出两位小数 |
| 货币 | 首版仅 `CNY` |
| 算法复用 | 后续继续复用或扩展 `calculatePlatformServiceFeeAmount`，不得在多个服务内复制金额算法 |

合同确认金额变化处理：

- 合同确认时允许 `finalConfirmedAmount` 与原 `quotedAmount` 不同。
- 只重新计算 `finalFeeAmount`。
- 不重新读取 membership tier。
- 不重新生成新的 feeRate。
- 不覆盖 authorization 的 `feeCalculatedAt / feeRateSnapshotHash`。

## 8. Fee Snapshot Hash 冻结

后续 `feeRateSnapshotHash` 应由 Server 生成，建议使用稳定 canonical JSON + SHA-256。

最小 hash 输入：

```json
{
  "feeRateRuleVersion": "p0_pay_membership_service_fee_v1",
  "factoryOrganizationId": "...",
  "feeRate": "0.025000",
  "feeRateLabel": "标准会员 2.5%",
  "feeRateSource": "paid_membership_tier",
  "membershipTierSnapshot": "standard",
  "feeCalculatedAt": "ISO-8601"
}
```

可选审计输入：

- `membershipEffectiveAt`
- `membershipExpiresAt`
- `membershipSourceType`
- `membershipSourceRef`

冻结规则：

1. `feeRateSnapshotHash` 不是支付通道签名。
2. BFF/Flutter 不得生成或覆盖。
3. 同一 authorization 的 hash 必须随 authorization 持久化。
4. charge 侧必须复制 authorization 锁定 hash，不得重新生成代表新会员等级的 hash。

## 9. Authorization 链路冻结

### 9.1 Fixed-price bid submit

`POST /fixed-price-bids` 后续返回的 `platformServiceFeeRequirement` 是 Server 生成的 fee requirement preview。

冻结规则：

1. 它由 Server policy 计算。
2. 它不是支付通道预授权成功凭证。
3. 它不是最终锁定快照。
4. Flutter 可在下一跳 create authorization 中回显 expected fee fields。
5. 若下一跳创建 authorization 时 membership tier 已变化，Server 以创建 authorization 时点重新计算并校验。

### 9.2 Create service-fee authorization

真正锁定发生在：

`POST /fixed-price-bids/{bidId}/service-fee-authorizations`

冻结规则：

1. Server 使用 `factoryOrganizationId` 和创建时点计算 fee snapshot。
2. Server 对 `expectedQuotedAmount / expectedFeeRate / expectedAuthorizationAmount` 做一致性校验。
3. 校验通过后，authorization 持久化 fee snapshot。
4. 校验不通过时，拒绝创建，并提示客户端刷新当前 fee requirement。
5. 授权创建后，会员升级、过期、降级均不改变本单锁定费率。

## 10. Contract Confirmation / Charge 链路冻结

合同确认后平台服务费扣费必须使用 authorization 锁定快照。

冻结规则：

1. `PlatformServiceFeeCharge.feeRate` 从 authorization 锁定 snapshot 复制。
2. `PlatformServiceFeeCharge.feeRateSource` 从 authorization 锁定 snapshot 复制。
3. `PlatformServiceFeeCharge.membershipTierSnapshot` 从 authorization 锁定 snapshot 复制。
4. `PlatformServiceFeeCharge.feeRateRuleVersion` 从 authorization 锁定 snapshot 复制。
5. `PlatformServiceFeeCharge.feeRateSnapshotHash` 从 authorization 锁定 snapshot 复制。
6. `finalFeeAmount` 只由 `finalConfirmedAmount * lockedFeeRate` 得出。
7. 合同确认时禁止调用 membership query 重新决定折扣。

需要修正的当前风险：

- 当前 `p0-pay-contract-confirmation.service.ts` 使用 `P0_PAY_DEFAULT_SERVICE_FEE_RATE` 重新计算最终服务费。
- 后续实现必须改为读取 `ownership.authorization` 中的锁定 feeRate 和 fee snapshot。

## 11. Persistence 影响清单

下一轮 L3 Persistence / migration design 至少需要冻结：

| 表/实体 | 当前字段 | 需补字段 |
|---|---|---|
| `platform_service_fee_authorizations` | `fee_rate / rule_version / rule_snapshot_hash / agreement_text_snapshot` | `fee_rate_label / fee_rate_source / membership_tier_snapshot / fee_rate_rule_version / fee_rate_snapshot_hash / fee_calculated_at` |
| `platform_service_fee_charges` | `final_confirmed_amount / fee_rate / final_fee_amount` | `fee_rate_label / fee_rate_source / membership_tier_snapshot / fee_rate_rule_version / fee_rate_snapshot_hash / fee_calculated_at` |

旧数据兼容方向：

- 旧 authorization 可读为 `legacy_fixed_default / 0.030000`。
- 旧 charge 可读为 `legacy_fixed_default / 0.030000`。
- 旧数据不得被批量改写成 paid membership 折扣。
- 是否需要 backfill 由下一轮 migration design 冻结。

## 12. Presenter / Read Model 影响

后续 Server presenter 至少需要新增：

- service-fee authorization create response 的 fee snapshot 字段。
- service-fee authorization status response 的 fee snapshot 字段。
- contract confirmation response 的 `platformServiceFeeCharge` 对象。
- P0-Pay summary 的只读 fee snapshot 字段。

冻结规则：

- Presenter 只能读 entity/snapshot，不得计算会员费率。
- Presenter 不得在缺字段时自行补会员折扣。
- 历史兼容展示可以输出 `legacy_fixed_default`，但必须来自 Server 兼容层。

## 13. 测试冻结

后续 Server implementation 最少需要覆盖：

| 测试 | 期望 |
|---|---|
| 无 paid membership | `0.030000 / fixed_default / none` |
| `free_certified` | `0.030000 / fixed_default / free_certified` |
| `standard` | `0.025000 / paid_membership_tier / standard` |
| `professional` | `0.020000 / paid_membership_tier / professional` |
| `ka` | `0.015000 / paid_membership_tier / ka`，若无 runtime truth 则联调标缺证 |
| `flagship` | `0.015000 / paid_membership_tier / flagship`，若无 runtime truth 则联调标缺证 |
| 预授权后升级 | charge 仍使用 authorization 锁定费率 |
| 预授权后过期 | charge 仍使用 authorization 锁定费率 |
| expected fee mismatch | authorization create 失败，要求刷新 fee requirement |
| membership query failure | authorization create 受控失败，不创建资金记录 |
| finalConfirmedAmount 与 quotedAmount 不同 | `finalFeeAmount = finalConfirmedAmount * lockedFeeRate` |

## 14. Server / BFF / Flutter 边界复签

| 层级 | 本轮冻结后的允许行为 | 仍禁止 |
|---|---|---|
| Server | 后续作为唯一 fee calculation owner 和 fee snapshot owner | 本轮不实现；合同确认不得重读会员等级 |
| BFF | 后续只读投影 Server fields | 不得计算、补齐或覆盖 feeRate |
| Flutter | 后续只展示 BFF 返回 fields，并回显 expected fee fields | 不得本地计算正式 feeRate 或正式 fee amount |

## 15. 阶段门禁

| 阶段 | 当前结论 | 是否允许进入 | blocker |
|---|---|---:|---|
| L0 Rule Freeze | 已完成 | 是 | 保持 No-Go for enablement |
| L2 Contracts | 已完成 | 是 | OpenAPI/types 尚未改，implementation 前再同步 |
| L3 Server Truth | 本文件完成后成立 | 是 | 需进入 persistence/migration design |
| L3 Persistence | 下一轮唯一动作 | 是 | 授权/扣费表字段未冻结 |
| Server Implementation | 尚未解锁 | 否 | 等 persistence + implementation unlock |
| L4 BFF | 尚未开始 | 否 | 等 Server truth/persistence 实现 |
| L5 Flutter | 尚未开始 | 否 | 等 BFF 只读投影 |
| Runtime Verification | 尚未具备 | 否 | 等实现部署与测试账号证据 |
| Formal Enablement | `No-Go` | 否 | 所有 blocker 未清零 |

## 16. Go / No-Go

- `Go` for L3 Persistence / migration design.
- `No-Go` for modifying `apps/server` in this round.
- `No-Go` for modifying `apps/bff`.
- `No-Go` for modifying `apps/mobile`.
- `No-Go` for modifying OpenAPI / generated types.
- `No-Go` for migration.
- `No-Go` for cloud write.
- `No-Go` for enabling membership-tier service fees in runtime.

## 17. 下一轮唯一动作

进入 L3 Persistence / migration design：

- 冻结 `platform_service_fee_authorizations` 新增字段。
- 冻结 `platform_service_fee_charges` 新增字段。
- 冻结旧 `3%` 数据兼容策略。
- 冻结 rollback / backfill / read compatibility。
- 冻结 implementation unlock 是否允许进入 Server patch。
