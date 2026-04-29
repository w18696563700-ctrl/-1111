---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the L2 app-facing contract delta for the exhibition bid-submit full
  version so the current command shape, upload-chain binding, and template
  download reuse all point to confirmed FileAsset truth instead of objectKey
  or a hidden seat/completeness workspace.
layer: L2 Contracts
freeze_date_local: 2026-04-15
inputs_canonical:
  - docs/00_ssot/exhibition_bid_submit_full_version_truth_freeze_addendum.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/latest_user_confirmed_change_ledger.md
  - docs/00_ssot/project_public_resource_download_zone_ruling_addendum.md
  - docs/00_ssot/project_detail_document_zone_and_public_resource_download_ruling_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《竞标提交页满分版 contract freeze》

## Pricing Gate Note

自 `2026-04-29` 起，若项目已接入
[platform_pricing_contracts_master_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/platform_pricing_contracts_master_v1.md)
定义的收费主线，则本文件保留 `POST /api/app/bid/submit` 的既有 request/response shape，但新增收费准入硬门禁：

1. 当前 actor 必须已有 `approved` 的 `bidParticipationRequest`
2. 当前 actor 必须已有同一 `projectId` 下状态为 `frozen` 的 `bidServiceFeeAuthorization`
3. 若缺任一条件，`bid/submit` 必须 fail closed，不得伪成功

## 1. Scope

- 本文件只覆盖：
  - `竞标提交页` 的 app-facing contract delta
  - 模板下载复用规则
  - confirmed FileAsset 绑定规则
- 本文件不进入：
  - implementation
  - runtime
  - 新的 template governance system
  - seat console
  - completeness workspace

## 2. Canonical Request / Response Freeze

### 2.1 `POST /api/app/bid/submit`

- 当前唯一合法的 submit request 最小字段固定为：
  - `projectId`
  - `quoteAmount`
  - `proposalSummary`
  - `projectUnderstandingFileAssetId`
  - `quoteSheetFileAssetId`
  - `schedulePlanFileAssetId`
- 以上 3 个附件字段必须引用：
  - confirmed `FileAsset`
- 以上 3 个附件字段不得引用：
  - `objectKey`
  - 未 confirm 的 upload session
  - 本地临时文件路径
- 当前 success body 继续保持最小化：
  - `bidId`
- 当前 success body 不得扩写成：
  - full bid read model
  - seat state payload
  - completeness workspace payload

### 2.2 Upload corridor

- 当前页面继续复用：
  - `POST /api/app/file/upload/init`
  - `POST /api/app/file/upload/confirm`
- 这两个路径只负责：
  - 生成上传会话
  - 生成 confirmed FileAsset
- 它们不得被扩写成：
  - submit truth
  - second attachment truth

### 2.3 Template download reuse

- 当前页面的模板下载区复用既有：
  - `GET /api/app/project/public-resources`
  - `GET /api/app/file/access`
- 当前页面只消费：
  - `resourceCategory = contract_template`
- 当前页面模板项的正式语义固定为：
  - `项目理解模板`
  - `报价表模板`
  - `进度安排模板`

## 3. Required Attachment Semantics

- 3 个附件槽位是固定槽位，不是自由附件池。
- 槽位顺序与语义固定为：
  1. `projectUnderstanding`
  2. `quoteSheet`
  3. `schedulePlan`
- 允许的最小失败态固定为：
  - 某一槽位未上传
  - 某一槽位未 confirm
  - 某一槽位 confirm 失败
- submit request 在 3 个槽位都已 confirmed 前不得进入 success path。

## 4. Path Retention Decision

- `seat` 与 `bid package completeness` 相关 canonical path truth 不在本轮重新 author。
- 当前 contract 只冻结：
  - submit command
  - upload chain
  - template catalog reuse
- 这表示：
  - 旧 seat / completeness paths 不是本 submit page 的 active consumption 面
  - 但 canonical truth 不被草率删除

## 5. Error Boundary

- 缺少必选附件：
  - 必须进入 controlled invalid state
- 附件未 confirm：
  - 必须进入 controlled invalid state
- 模板目录不可用：
  - 必须进入 controlled unavailable state
- 缺少 `4000 元竞标服务费预授权额度` 冻结：
  - 必须进入 controlled pricing-gate state
- 任何情况下都不得把这些状态伪装成 success。

## 6. Formal Conclusion

- 当前 L2 contract 的正式结论固定为：
  - `bid/submit` 是 6 字段提交命令 + 3 个 confirmed FileAsset slot
  - 模板下载复用既有 public resource catalog
  - `objectKey` 只保留为存储位置，不进入业务 contract truth
