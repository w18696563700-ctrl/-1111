---
owner: Codex 总控
status: frozen
purpose: Freeze the V1 contract path and schema decisions for the downstream bid-to-contract-amount chain.
layer: L2 Contracts
freeze_scope:
  - bid participation app-facing paths
  - bid submit three attachment fields
  - project communication workbench and material review paths
  - BidAward primary path and legacy selection boundary
  - deal-confirmation final amount schemas
effective_local_date: 2026-05-04
inputs_canonical:
  - docs/00_ssot/downstream_bid_to_contract_amount_v1_truth_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 下游竞标到合同金额确认链路 V1 Contracts Addendum

## 1. 总裁决

本文件冻结 V1 下游链路 contracts 裁决：

- `POST /api/app/project/bid-participation/request` 是竞标方申请参与主路径。
- `POST /api/app/bid/submit` 必须携带 `Bid.quoteAmount` 和三份 confirmed `FileAsset`。
- `/api/app/message/project-communication/workbench*` 只承接资料确认和入口 read model。
- `POST /api/app/bid/award` 是发布方选择合作方 / BidAward 主路径。
- `POST /api/app/bid/select-bid-and-create-order` 只允许作为旧兼容实现路径或历史别名，不得成为第二 app-facing 主路径。
- `/api/app/project/{projectId}/deal-confirmations` 是最终合同金额确认唯一 app-facing 主路径。
- `/api/app/contract/confirm` 不得携带 `finalConfirmedAmount`，不得承接最终合同金额确认。

## 2. App-facing Path Freeze

| 能力 | Method | Path | 状态 |
| --- | --- | --- | --- |
| 竞标方申请参与 | `POST` | `/api/app/project/bid-participation/request` | V1 主路径 |
| 申请/审核详情 | `GET` | `/api/app/project/bid-participation/thread/detail` | V1 主路径 |
| 发布方待审列表 | `GET` | `/api/app/my/projects/{projectId}/bid-participation/pending` | V1 主路径 |
| 发布方通过 | `POST` | `/api/app/my/projects/{projectId}/bid-participation/{requestId}/approve` | V1 主路径 |
| 发布方拒绝 | `POST` | `/api/app/my/projects/{projectId}/bid-participation/{requestId}/reject` | V1 主路径 |
| 报价提交 | `POST` | `/api/app/bid/submit` | V1 主路径，三附件必须在 body |
| 项目沟通工作台 | `GET` | `/api/app/message/project-communication/workbench` | V1 主路径 |
| 资料确认 | `POST` | `/api/app/message/project-communication/workbench/material-review` | V1 主路径 |
| 选择合作方 | `POST` | `/api/app/bid/award` | V1 唯一主路径 |
| 最终合同金额确认 | `POST/GET` | `/api/app/project/{projectId}/deal-confirmations*` | V1 唯一主路径 |
| 合同 continuation 确认 | `POST` | `/api/app/contract/confirm` | 不得写最终金额 |

## 3. Server-facing Path Freeze

| App-facing path | Server-facing pair | 规则 |
| --- | --- | --- |
| `/api/app/project/bid-participation/request` | `/server/projects/bid-participation/request` | Server 写参与申请真值 |
| `/api/app/project/bid-participation/thread/detail` | `/server/projects/bid-participation/thread/detail` | Server 读申请详情 |
| `/api/app/my/projects/{projectId}/bid-participation/pending` | `/server/my/projects/{projectId}/bid-participation/pending` | Server 读待审 |
| `/api/app/my/projects/{projectId}/bid-participation/{requestId}/approve` | `/server/my/projects/{projectId}/bid-participation/{requestId}/approve` | Server 写 approved |
| `/api/app/my/projects/{projectId}/bid-participation/{requestId}/reject` | `/server/my/projects/{projectId}/bid-participation/{requestId}/reject` | Server 写 rejected |
| `/api/app/bid/submit` | `/server/bids` | Server 写 Bid 和三附件引用 |
| `/api/app/message/project-communication/workbench` | `/server/project-communication/workbench` | Server 读 10 入口 |
| `/api/app/message/project-communication/workbench/material-review` | `/server/project-communication/workbench/material-review` | Server 写资料确认真值 |
| `/api/app/bid/award` | `/server/bid/award` | Server 写 BidAward / Order seed / Contract seed |
| `/api/app/project/{projectId}/deal-confirmations*` | `/server/projects/{projectId}/deal-confirmations*` | Server 写/读最终金额确认语义，可复用内部 ContractConfirmation 实体 |

## 4. Schema Freeze

`BidSubmitRequest` V1 必须包含：

- `projectId`
- `quoteAmount`
- `proposalSummary`
- `projectUnderstandingFileAssetId`
- `quoteSheetFileAssetId`
- `schedulePlanFileAssetId`

`DealConfirmationCreateRequest.finalConfirmedAmount` 是唯一最终合同金额输入字段。

`ContractConfirmRequest` 只允许包含 `orderId`，不得新增：

- `finalConfirmedAmount`
- `quoteAmount`
- `totalAmount`
- `serviceFeeAmount`
- payment / settlement / invoice fields

## 5. No-Go

- 不允许双主路径确认最终合同金额。
- 不允许 `/api/app/contract/confirm` 写最终金额。
- 不允许 `Bid.quoteAmount` 或 `Order.totalAmount` 替代 `finalConfirmedAmount`。
- 不允许 BFF fallback 金额成为合同金额。
- 不允许消息楼资料确认状态成为合同金额确认状态。
- 不允许 payment / service-fee charge / deposit / settlement / invoice 进入本轮 OpenAPI。

## 6. Admission

本文件允许进入 generated types 同步和分层实现，但实现必须继续遵守：

- Server 业务真值唯一。
- BFF 不持有最终金额真值。
- Flutter 不拼接金额真值。
- 云端 runtime 通过 `http://127.0.0.1:8080` 验证，不能用本地 3000 / 3001 证明线上可用。
