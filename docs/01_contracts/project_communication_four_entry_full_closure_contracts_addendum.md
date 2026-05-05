---
owner: Codex 总控
status: frozen
purpose: Freeze Day 2 contracts and OpenAPI裁决 for doing the four project-communication entries thoroughly.
layer: L2 Contracts
effective_local_date: 2026-05-05
based_on:
  - docs/00_ssot/project_communication_four_entry_full_closure_truth_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 项目沟通四入口做透 V1 Contracts Addendum

## 1. 总裁决

Day 2 裁决：

- `项目相册` app-facing 路径进入 `openapi.yaml`，并以 `ProjectAlbumPhoto*` schema 表达。
- 相册图片真实预览继续复用受控 file preview/access surface；不得暴露 `objectKey`。
- `资料确认单` 的写命令仍仅为 `/api/app/message/project-communication/workbench/material-review`，只处理 8 个资料条目。
- `合同确认 / 最终成交金额确认` 不走 material-review，继续由 `/api/app/project/{projectId}/deal-confirmations` 承接。
- `/api/app/contract/confirm` 仍不得携带 `finalConfirmedAmount`。
- 后续承接红点优先复用 `businessTodoSummary.dealConfirmationPendingCount`，本轮不新增过重后续承接 schema。

## 2. Project Album Paths

| Method | App-facing Path | Server truth | 用途 |
| --- | --- | --- | --- |
| `GET` | `/api/app/project/{projectId}/album/photos` | `ProjectAlbumPhoto` | 读取项目证据相册。 |
| `POST` | `/api/app/project/{projectId}/album/photos` | `ProjectAlbumPhoto + FileAsset` | 绑定已确认上传的 `FileAsset` 为相册照片。 |
| `DELETE` | `/api/app/project/{projectId}/album/photos/{photoId}` | `ProjectAlbumPhoto.photoState` | 将相册照片标记为 removed。 |

Schema:

- `ProjectAlbumPhotoCategory`
- `ProjectAlbumPhotoBindRequest`
- `ProjectAlbumPhotoReadModel`
- `ProjectAlbumPhotoListReadModel`

边界：

- 相册不是履约系统。
- 相册不是验收或争议状态机。
- 相册不得使用 `objectKey` 作为 App-facing truth。
- 图片预览必须通过受控 file preview/access。

## 3. File Preview / Access Reuse

复核裁决：

- `GET /api/app/file/preview/access` 可继续承接受控文件预览。
- 相册真实图片预览可以复用该 preview/access 机制，前提是 Server 权限分支承认项目相册 FileAsset。
- 返回值只允许短期 `accessUrl` 等展示字段，不得暴露对象存储内部 key。

## 4. Workbench Material Review Boundary

`ProjectCommunicationMaterialReviewRequest` 只处理以下 8 个 entryKey：

- `publisher_effect_image_review`
- `publisher_construction_doc_review`
- `publisher_material_sample_review`
- `publisher_equipment_material_list_review`
- `publisher_service_list_review`
- `bid_project_understanding_review`
- `bid_quote_sheet_review`
- `bid_schedule_plan_review`

以下 entryKey 不得通过 material-review 写入：

- `contract_confirmation`
- `final_confirmed_amount_confirmation`

## 5. Deal Confirmation Boundary

`/api/app/project/{projectId}/deal-confirmations` 继续是最终金额确认唯一 app-facing 路径族。

`DealConfirmationCreateRequest.finalConfirmedAmount` 是唯一最终合同金额输入字段。

`/api/app/contract/confirm` 继续只允许承接合同 continuation，不得新增：

- `finalConfirmedAmount`
- `quoteAmount`
- `totalAmount`
- `serviceFeeAmount`
- payment / settlement / invoice / wallet fields

## 6. Red Badge Fields

不新增大模型字段。四入口红点继续复用：

- `projectGroups[].businessTodoSummary.totalPendingCount`
- `businessTodoSummary.bidParticipationReviewPendingCount`
- `businessTodoSummary.publisherMaterialReviewPendingCount`
- `businessTodoSummary.bidMaterialReviewPendingCount`
- `businessTodoSummary.dealConfirmationPendingCount`
- `entries[].badgeCount`

BFF 和 Flutter 不得计算这些值。

## 7. Day 3 Admission

允许进入 generated types 对齐，仅限：

- 运行 contracts generate。
- 检查 `ProjectAlbumPhoto* / ProjectAlbumPhotoList* / ProjectAlbumPhotoBind*`。
- 检查 `DealConfirmation*` 无漂移。
- 检查 `ContractConfirmRequest` 仍不含金额字段。
