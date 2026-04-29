---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the BFF app-facing surface for the exhibition bid-submit full
  version so the Flutter page only sees the 6-field submit command, the
  public-resource template catalog, and shared file-access reuse, while seat
  and completeness are no longer presented as the current submit page face.
layer: L4 BFF
freeze_date_local: 2026-04-15
inputs_canonical:
  - docs/00_ssot/exhibition_bid_submit_full_version_truth_freeze_addendum.md
  - docs/01_contracts/exhibition_bid_submit_full_version_contract_freeze_addendum.md
  - docs/02_backend/exhibition_bid_submit_full_version_backend_truth_addendum.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/latest_user_confirmed_change_ledger.md
  - docs/00_ssot/project_public_resource_download_zone_ruling_addendum.md
  - docs/01_contracts/openapi.yaml
---

## Pricing Gate Note

当前 `bid/submit` 的 6 字段主体 request shape、模板区和共享 file-access 规则继续沿用本文件。

但自 [platform_pricing_bff_surface_master_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/platform_pricing_bff_surface_master_v1.md) 生效后，本文件不再拥有收费 gate authority。

当前正式补充冻结如下：

1. `POST /api/app/bid/submit` 的主体 shape 保持不变
2. 当前 actor 除了已有 `approved` 的 `bidParticipationRequest`，还必须已有同一 `projectId` 下状态为 `frozen` 的 `bidServiceFeeAuthorization`
3. 若缺少 `4000 元竞标服务费预授权额度` 冻结，`BFF` 必须 fail closed
4. `BFF` 不得要求 Flutter 在 `bid/submit` body 内重复携带收费真相
5. `approved` 后如仍需先冻结 `4000`，首个 CTA 必须指向 pricing gate，而不是直接指向 `bid_submit.open`

# 《竞标提交页满分版 BFF surface freeze》

## 1. Scope

- 本文件只覆盖：
  - `竞标提交页` 的 BFF app-facing surface
  - template catalog shaping
  - shared file-access reuse
- 本文件不进入：
  - implementation
  - second upload system
  - seat console
  - completeness workspace

## 2. Boundary

- `BFF` 只允许做：
  - aggregation
  - normalize
  - response shaping
  - visibility trim
  - controlled error mapping
  - light idempotency
- `BFF` 不得：
  - 持有 bid truth
  - 持有 FileAsset truth
  - 持有 template catalog truth
  - 持有 seat truth
  - 持有 completeness truth

## 3. Canonical Mapping Freeze

- 当前 submit 命令继续通过：
  - `POST /api/app/bid/submit`
- 当前 upload corridor 继续通过：
  - `POST /api/app/file/upload/init`
  - `POST /api/app/file/upload/confirm`
- 当前模板下载目录继续复用：
  - `GET /api/app/project/public-resources`
  - `GET /api/app/file/access`
- 当前 page 不再把 seat / completeness 做成主消费面。

## 4. Request Shaping Freeze

- `POST /api/app/bid/submit` 只允许传递：
  - `projectId`
  - `quoteAmount`
  - `proposalSummary`
  - `projectUnderstandingFileAssetId`
  - `quoteSheetFileAssetId`
  - `schedulePlanFileAssetId`
- `BFF` 不得补入：
  - `objectKey`
  - 未 confirm 的 upload session
  - seat 数量信息
  - completeness 投影信息

## 5. Template Catalog Shaping Freeze

- `GET /api/app/project/public-resources` 在当前页面只承担：
  - 三份实例模板目录
- 当前只允许在模板区消费：
  - `contract_template`
- 当前模板区必须保持为：
  - step 3 的下载入口
  - 不是结果页按钮下方的附属区
- `BFF` 不得代理：
  - `/server/admin/config/templates*`
  到 App 侧

## 6. Response Shaping Freeze

- `POST /api/app/bid/submit` 成功响应继续只保留：
  - `bidId`
- `BFF` 不得把成功响应扩写成：
  - full bid model
  - seat state card
  - completeness card
  - result explanation block

## 7. Error Mapping Freeze

- 缺少必选附件：
  - 进入 controlled invalid
- 附件未 confirm：
  - 进入 controlled invalid
- 模板目录不可用：
  - 进入 controlled unavailable
- `BFF` 不得用 fallback 伪造成功。

## 8. Formal Conclusion

- 当前 BFF authority 正式冻结为：
  - 6 字段 bid submit shaping
  - 3 个 confirmed FileAsset slot shaping
  - public-resource template catalog shaping
  - shared file-access reuse

## 9. Duplicate Submit Error Freeze

- `2026-04-15` 残余缺陷修复后，`BFF` 对 `POST /api/app/bid/submit` 额外冻结：
  - 上游 duplicate submit 不再落成通用 `500`
  - 必须归一为 app-facing controlled conflict
- 当前 canonical app-facing 形态固定为：
  - `HTTP 409`
  - `code = BID_DUPLICATE_SUBMISSION`
  - message:
    - `当前项目已提交过投标，请勿重复提交。`
- `BFF` 只允许做：
  - status/code normalize
  - 中文 message rewrite
  - transport details 透传
- `BFF` 不得做：
  - 第二套重复提交状态机
  - 伪造成功响应
  - 把 duplicate 场景重新兜回 `AUTH_RESOURCE_UNAVAILABLE`
