---
owner: Codex 总控
status: frozen
purpose: Record that the current enterprise-hub public-case-detail fix is a read-consistency alignment only and introduces no app-facing schema delta.
layer: L1 Contract
freeze_date_local: 2026-04-23
inputs_canonical:
  - docs/00_ssot/enterprise_hub_public_case_detail_read_alignment_truth_ruling_addendum.md
  - apps/server/src/modules/enterprise_hub/enterprise-hub-query.service.ts
  - apps/bff/src/routes/enterprise_hub/enterprise-hub.service.ts
  - apps/mobile/lib/features/exhibition/data/enterprise_hub_consumer_layer.dart
---

# 《enterprise hub public case detail read alignment contract note》

## 1. Canonical Path

- 当前 path 保持不变：
  - `GET /server/exhibition/enterprise-hub/public-cases/{caseId}`
  - `GET /api/app/exhibition/enterprise-hub/public-cases/{caseId}`

## 2. Response Shape

- 当前 contract 输出字段保持不变：
  - `caseId`
  - `enterpriseId`
  - `boardType`
  - `title`
  - `exhibitionType`
  - `city`
  - `eventTime`
  - `summary`
  - `caseCoverFileAssetId`
  - `caseMediaFileAssetIds`
  - `caseImageUrlMap`
  - `isFeatured`
  - `caseStatus`

## 3. Semantic Delta

- 当前唯一 contract 语义变化是：
  - 当企业详情主链路已经可见该案例卡时，
    `public-cases/{caseId}` 不再因为未完成的发布态补偿而误报不可用。
- 当前不新增：
  - 新字段
  - 新 query 参数
  - 新错误码族

## 4. Explicit Freeze

- `formal-info` 路径 contract 本轮无改动。
- 企业案例详情仍只暴露公域已批准案例，不放宽公开范围。
