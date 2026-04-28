---
title: exhibition_trade_task_membership_service_fee_linkage_contracts_addendum_v1
owner: Codex 总控
status: frozen
layer: L2 Contracts
updated_at: 2026-04-28
purpose: Freeze the app-facing contract fields for future P0-Pay membership-tier service-fee linkage, without enabling tiered service fees or unlocking Server/BFF/Flutter implementation.
inputs_canonical:
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_freeze_v1.md
  - docs/01_contracts/exhibition_trade_task_p0_pay_contracts_addendum_v1_3.md
  - docs/00_ssot/exhibition_trade_task_payment_mainline_p0_pay_freeze_v1_3.md
  - docs/02_backend/exhibition_trade_task_p0_pay_server_truth_addendum_v1_3.md
  - docs/03_bff/exhibition_trade_task_p0_pay_bff_surface_freeze_addendum_v1_3.md
  - docs/04_frontend/bid_submit_template_grid_and_p0_pay_copy_frontend_surface_addendum.md
---

# P0-Pay 会员分层服务费率联动 L2 Contracts Addendum V1

## 0. 总裁决

- 当前是否允许正式启用会员分层服务费率：`No-Go`
- 当前是否允许进入 L2 Contracts 字段冻结：`Go`
- 当前是否允许修改 OpenAPI / generated types：`No-Go in this round`
- 当前是否允许 Server / BFF / Flutter implementation：`No-Go`
- 当前是否允许云端写入、预授权、扣费或 migration：`No-Go`

核心原因：

- L0 已冻结未来会员费率联动规则，但现行 P0-Pay 仍固定 `3%`。
- 本文件只冻结 app-facing contract 字段、枚举、响应位置和字段 owner。
- OpenAPI / generated types 需要在 implementation unlock 后按本文件同步，不在本轮直接生成或改写。

下一轮唯一动作：

- 进入 L3 Server truth addendum，冻结 `P0PayServiceFeeRatePolicy`、membership query 读取、异常回退、精度和合同确认复用锁定费率。

## 1. 当前 Contracts 缺口复核

| 当前对象 | 现有字段 | 缺口 | 本轮处理 |
|---|---|---|---|
| `platformServiceFeeRequirement` | `feeRate / quotedAmount / estimatedFeeAmount / currency / authorizationRequired / authorizationStatus` | 缺 `feeRateLabel / feeRateSource / membershipTierSnapshot / feeRateRuleVersion / feeRateSnapshotHash / feeCalculatedAt` | 冻结新增字段 |
| service-fee authorization create response | `authorizationId / authorizationStatus / estimatedFeeAmount / currency / channelCandidates / expiresAt / updatedAt` | 缺完整 fee snapshot 回显 | 冻结新增字段 |
| service-fee authorization status response | `authorizationId / authorizationStatus / quotedAmount / feeRate / estimatedFeeAmount / currency / channelSummary / failureReasonCode / updatedAt` | 缺 fee snapshot 和 tier snapshot | 冻结新增字段 |
| contract confirmation response | `contractConfirmationId / contractStatus / finalConfirmedAmount / platformServiceFeeFinalAmount / platformServiceFeeStatus / nextAction / updatedAt` | 缺 charge fee snapshot | 冻结 `platformServiceFeeCharge` 响应对象 |
| P0-Pay summary response | `platformServiceFee` 聚合对象未冻结会员费率字段 | 缺只读聚合中的 fee snapshot | 冻结只读投影字段 |

## 2. 字段 Owner 冻结

| 字段族 | Owner | BFF 职责 | Flutter 职责 |
|---|---|---|---|
| fee rate 计算 | Server | 只读透传，不计算 | 只展示，不计算正式费率 |
| membership tier snapshot | Server | 只读透传，可做字段裁剪 | 只展示，不伪造 |
| fee rule version / hash | Server | 只读透传 | 只展示或随 Server 返回值确认 |
| estimated / final fee amount | Server | 只读透传 | 只展示，不作为正式金额真相 |
| expected fee echo | Server 校验 | BFF 只转发 client echo | Flutter 只能回显 Server 返回值用于一致性校验 |

Contract rule：

- Flutter / BFF 不得作为 `feeRate` 真源。
- `expectedFeeRate` 只能作为 Server 返回值的确认回显；Server 必须重新以自身费率策略和快照校验。
- BFF 不得在 Server 缺字段时自行生成 `2.5% / 2.0% / 1.5%`。

## 3. 新增枚举冻结

### 3.1 `feeRateSource`

```text
fixed_default
paid_membership_tier
legacy_fixed_default
unknown
```

语义：

| 值 | 语义 | 是否允许新创建使用 |
|---|---|---:|
| `fixed_default` | 默认固定费率，包含无有效 paid membership 或 `free_certified` | 是 |
| `paid_membership_tier` | Server 按有效 paid membership tier 计算 | 当前 `No-Go`；仅在 implementation unlock 且 L3/L4/L5 完成后允许新创建使用 |
| `legacy_fixed_default` | 历史 P0 固定 3% 记录的只读兼容来源 | 否，仅旧数据读回 |
| `unknown` | 只读降级态，表示旧记录或异常数据无法确认来源 | 否，新创建不得使用 |

### 3.2 `membershipTierSnapshot`

```text
none
free_certified
standard
professional
ka
flagship
unknown
```

语义：

- `none`：无有效 paid membership tier。
- `free_certified`：免费认证企业，默认 `3.0%`。
- `standard`：标准会员，候选 `2.5%`。
- `professional`：专业会员，候选 `2.0%`。
- `ka / flagship`：预留大客户档，候选 `1.5%`，首版可保留不开。
- `unknown`：只读兼容或异常态，不得授予折扣。

字段边界：

- `membershipTierSnapshot` 表示 authorization 创建时由 Server 锁定的组织会员等级快照。
- 首版 L2 不新增 `membershipTierAtContractConfirm` 作为计费字段。
- 若后续需要展示合同确认当日会员状态，只能作为非计费审计字段另行冻结，不得影响本单 fee rate。

## 4. 新增字段冻结

### 4.1 费率快照公共字段

| 字段 | 类型 | 必填 | Owner | 说明 |
|---|---|---:|---|---|
| `feeRate` | decimal string | 是 | Server | 比率字符串，建议六位小数，如 `0.030000` |
| `feeRateLabel` | string | 是 | Server | 用户可见短标签，如 `默认费率 3.0%`、`标准会员 2.5%` |
| `feeRateSource` | enum | 是 | Server | 见 `feeRateSource` |
| `membershipTierSnapshot` | enum | 是 | Server | 见 `membershipTierSnapshot` |
| `feeRateRuleVersion` | string | 是 | Server | 会员费率联动规则版本，不复用旧 P0 固定费率语义时需升级 |
| `feeRateSnapshotHash` | string | 是 | Server | 对 fee rule、tier snapshot、rate、label 等关键信息生成的 hash |
| `feeCalculatedAt` | ISO datetime string | 是 | Server | 费率计算与锁定时间 |

兼容规则：

- 新建 authorization 必须返回完整公共字段。
- 旧固定 `3%` 记录读回时，Server/BFF 可使用 `legacy_fixed_default` 或 `fixed_default`，但必须由 Server 决定。
- `feeRateLabel` 只是展示文案快照，不参与计费、不作为规则真相、不扩大 Server 费率策略面。
- `feeRateSnapshotHash` 不是支付通道签名，不得被 Flutter 生成。

## 5. Fixed-price Bid Submit Response

`POST /api/app/exhibition/trade-tasks/{taskId}/fixed-price-bids`

`platformServiceFeeRequirement` 字段冻结为：

```yaml
platformServiceFeeRequirement:
  feeRate: string
  feeRateLabel: string
  feeRateSource: fixed_default | paid_membership_tier | legacy_fixed_default | unknown
  membershipTierSnapshot: none | free_certified | standard | professional | ka | flagship | unknown
  feeRateRuleVersion: string
  feeRateSnapshotHash: string
  feeCalculatedAt: string
  quotedAmount: string
  estimatedFeeAmount: string
  currency: CNY
  authorizationRequired: boolean
  authorizationStatus: string
```

Contract rules：

1. `platformServiceFeeRequirement` 由 Server 生成。
2. BFF 只读投影，不得重算或改写。
3. Flutter 只能展示并在后续 authorization create 时回显 `expectedFeeRate / expectedAuthorizationAmount` 用于 Server 一致性校验。
4. 本响应不是预授权成功凭证，只表示提交报价后需要进入预授权。

## 6. Service-fee Authorization Contracts

### 6.1 Create Authorization Request

`POST /api/app/exhibition/trade-tasks/{taskId}/fixed-price-bids/{bidId}/service-fee-authorizations`

Request 保持兼容：

- `expectedQuotedAmount`
- `expectedFeeRate`
- `expectedAuthorizationAmount`
- `currency`
- `idempotencyKey`

Contract rules：

1. `expectedFeeRate` 不是 Flutter 费率真相。
2. `expectedFeeRate` 必须来自上一跳 Server 返回的 `platformServiceFeeRequirement.feeRate`。
3. Server 必须重新计算或读取自身锁定策略，并拒绝与 Server 真相不一致的 expected 值。
4. BFF 不得补齐 expected 值。

### 6.2 Create Authorization Response

Response 新增 fee snapshot 字段：

```yaml
authorizationId: string
authorizationStatus: string
quotedAmount: string
feeRate: string
feeRateLabel: string
feeRateSource: fixed_default | paid_membership_tier | legacy_fixed_default | unknown
membershipTierSnapshot: none | free_certified | standard | professional | ka | flagship | unknown
feeRateRuleVersion: string
feeRateSnapshotHash: string
feeCalculatedAt: string
estimatedFeeAmount: string
currency: CNY
channelCandidates: array
expiresAt: string | null
updatedAt: string
```

### 6.3 Authorization Status Response

`GET /api/app/exhibition/trade-tasks/{taskId}/fixed-price-bids/{bidId}/service-fee-authorizations/{authorizationId}`

Response 新增 fee snapshot 字段：

```yaml
authorizationId: string
authorizationStatus: string
quotedAmount: string
feeRate: string
feeRateLabel: string
feeRateSource: fixed_default | paid_membership_tier | legacy_fixed_default | unknown
membershipTierSnapshot: none | free_certified | standard | professional | ka | flagship | unknown
feeRateRuleVersion: string
feeRateSnapshotHash: string
feeCalculatedAt: string
estimatedFeeAmount: string
currency: CNY
channelSummary: object | null
failureReasonCode: string | null
updatedAt: string
```

Contract rules：

1. Authorization status 读回必须展示创建预授权时锁定的 fee snapshot。
2. 会员升级、过期、降级不得改变已创建 authorization 的 `feeRate`。
3. `feeCalculatedAt` 是预授权创建时的费率锁定时间，不是支付通道授权时间。

## 7. Contract Confirmation / Charge Response

`POST /api/app/exhibition/trade-tasks/{taskId}/contract-confirmations`

Response 保持旧字段兼容，并新增 `platformServiceFeeCharge`：

```yaml
contractConfirmationId: string
contractStatus: string
finalConfirmedAmount: string
platformServiceFeeFinalAmount: string
platformServiceFeeStatus: string
platformServiceFeeCharge:
  finalConfirmedAmount: string
  feeRate: string
  feeRateLabel: string
  feeRateSource: fixed_default | paid_membership_tier | legacy_fixed_default | unknown
  membershipTierSnapshot: none | free_certified | standard | professional | ka | flagship | unknown
  feeRateRuleVersion: string
  feeRateSnapshotHash: string
  feeCalculatedAt: string
  finalFeeAmount: string
  currency: CNY
nextAction: string
updatedAt: string
```

Contract rules：

1. `platformServiceFeeCharge.feeRate` 必须复用 authorization 创建时锁定的费率。
2. 合同确认时只使用 `finalConfirmedAmount` 重新计算 `finalFeeAmount`。
3. 合同确认时不得重新读取会员等级参与计费。
4. 旧字段 `platformServiceFeeFinalAmount` 继续作为兼容字段，但不承载完整 fee snapshot。

## 8. P0-Pay Summary Response

`GET /api/app/exhibition/trade-tasks/{taskId}/p0-pay-summary`

`platformServiceFee` 聚合对象后续至少需要只读投影：

```yaml
platformServiceFee:
  authorizationId: string | null
  authorizationStatus: string | null
  quotedAmount: string | null
  estimatedFeeAmount: string | null
  finalConfirmedAmount: string | null
  finalFeeAmount: string | null
  feeRate: string | null
  feeRateLabel: string | null
  feeRateSource: fixed_default | paid_membership_tier | legacy_fixed_default | unknown | null
  membershipTierSnapshot: none | free_certified | standard | professional | ka | flagship | unknown | null
  feeRateRuleVersion: string | null
  feeRateSnapshotHash: string | null
  feeCalculatedAt: string | null
  currency: CNY
```

Contract rules：

1. P0-Pay summary 只读展示，不创建、不修改 fee snapshot。
2. BFF 可以裁剪不可见字段，但不得补算缺失字段。
3. 消息楼、订单详情、合同详情只能消费该只读摘要，不得成为 fee truth owner。

## 9. OpenAPI / Generated Types Impact List

本轮不直接修改：

- `docs/01_contracts/openapi.yaml`
- `packages/contracts/src/generated/app-api.types.ts`
- `packages/contracts/openapi/openapi.bundle.json`

后续 implementation unlock 后，OpenAPI/types 至少需要同步：

| 对象 | 需新增或调整 |
|---|---|
| `PlatformServiceFeeRequirement` | 新增公共 fee snapshot 字段 |
| `ServiceFeeAuthorizationCreateResponse` | 新增 authorization fee snapshot 字段 |
| `ServiceFeeAuthorizationStatusResponse` | 新增 authorization fee snapshot 字段 |
| `ContractConfirmationResponse` | 新增 `platformServiceFeeCharge` |
| `P0PaySummaryResponse.platformServiceFee` | 新增只读 fee snapshot 字段 |
| enums | 新增 `feeRateSource`、`membershipTierSnapshot` |

## 10. Server / BFF / Flutter 只读影响评估

| 层级 | 影响 | 当前是否允许实现 |
|---|---|---:|
| Server | 后续需要 fee policy、snapshot persistence、authorization/charge presenter 字段 | 否 |
| BFF | 后续需要 read-model 只读投影新增字段 | 否 |
| Flutter | 后续需要去硬编码 `3%` 并展示 Server/BFF 返回字段 | 否 |
| OpenAPI/types | 后续需要按本 addendum 同步 schema 与 generated types | 否 |

## 11. Go / No-Go

- `Go` for L3 Server truth addendum authoring.
- `No-Go` for modifying `apps/server`.
- `No-Go` for modifying `apps/bff`.
- `No-Go` for modifying `apps/mobile`.
- `No-Go` for modifying OpenAPI / generated types in this round.
- `No-Go` for migration.
- `No-Go` for cloud write.
- `No-Go` for enabling membership-tier service fees in runtime.

## 12. 阶段门禁核查表

| 门禁项 | 结论 | 是否通过 | 说明 |
|---|---|---:|---|
| L0 Rule Freeze | 已完成 | 是 | `factoryOrganizationId`、锁定时点、Server/BFF/Flutter 边界已冻结 |
| L2 Contract Fields | 本文件完成 | 是 | 已冻结 fee snapshot 公共字段、authorization response、charge response 和 summary 投影 |
| Field Owner | Server owner | 是 | BFF 只读投影，Flutter 只展示或回显 Server 返回值 |
| Frontend Non-truth | 已冻结 | 是 | `expectedFeeRate` 只作 Server 返回值回显校验，不是 Flutter 真相 |
| OpenAPI / generated types | 未解锁 | 是 | 本轮只冻结 addendum，不改 schema 或 generated artifact |
| Server/BFF/Flutter implementation | 未解锁 | 是 | 等 L3/L4/L5 文书链完成后再进入实现 |
| Cloud / payment runtime | 未解锁 | 是 | 不写云端，不触发预授权、扣费或支付通道 |

阶段结论：

- `Pass` for L2 Contracts 字段冻结。
- `Go` for 第 3 天 L3 Server truth 冻结。
- `No-Go` for implementation and runtime enablement.

## 13. 下一轮唯一动作

进入 L3 Server truth addendum：

- 冻结 `P0PayServiceFeeRatePolicy`。
- 冻结 Server 如何读取 `factoryOrganizationId` 的 paid membership tier。
- 冻结 fee rate 精度、hash 输入、异常回退。
- 冻结合同确认复用 authorization 锁定 feeRate。
- 冻结旧 `3%` 数据兼容策略。
