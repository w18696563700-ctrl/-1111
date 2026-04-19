---
owner: Codex 总控
status: frozen
purpose: Freeze the owner-private app-facing contract family for the post-publish materials supplement corridor, so backend implementation may proceed on a single attachment family without public overclaim or upload-confirm pseudo truth.
layer: L2 Contracts
freeze_date_local: 2026-04-13
inputs_canonical:
  - docs/00_ssot/project_publish_workbench_post_publish_materials_corridor_v1_truth_freeze_addendum.md
  - docs/01_contracts/project_publish_workbench_full_extension_mainline_contract_freeze_addendum.md
  - docs/01_contracts/upload_contracts.yaml
  - docs/01_contracts/openapi.yaml
  - docs/00_ssot/source_of_truth_map.md
---

# 《项目发布工作台 / 已发布项目资料补充走廊 V1 contract freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `项目发布工作台 / 已发布项目资料补充走廊 V1`
- 本冻结单只服务于：
  - owner-private app-facing attachment family
  - upload reuse 边界
  - request / response / visibility contract 边界
- 本冻结单不进入：
  - backend implementation
  - BFF implementation
  - frontend implementation
  - integration

## 2. Canonical App-facing Path Family Freeze

- 当前 corridor 的唯一合法 app-facing 路由族固定为：
  - `GET /api/app/my/projects/{projectId}/attachments`
  - `POST /api/app/my/projects/{projectId}/attachments`
  - `DELETE /api/app/my/projects/{projectId}/attachments/{attachmentId}`
- create success 页与 project edit 页继续复用同一 owner-private app-facing 附件族。
- public project detail 不新增 attachment read path。
- 当前不得新增：
  - `/api/app/project/detail/attachments`
  - `/api/app/project/attachments/public`
  - 第二条 `projectAttachment` family

## 3. Request / Response Freeze

### 3.1 GET `/api/app/my/projects/{projectId}/attachments`

- 返回只承接 owner-private 正式附件列表。
- 最小响应 carrier 固定为：
  - `projectId`
  - `attachments[]`
- 每个 attachment item 最小字段固定为：
  - `attachmentId`
  - `projectId`
  - `fileAssetId`
  - `fileName`
  - `attachmentKind`
  - `mimeType`
  - `visibility`
  - `sortOrder`
  - `createdAt`
- `createdBy` 允许作为附加审计字段返回，但不再属于 app-facing 最小成功 carrier。
- `visibility` 在 V1 固定返回：
  - `owner_private`

### 3.2 POST `/api/app/my/projects/{projectId}/attachments`

- 最小请求字段固定为：
  - `fileAssetId`
  - `fileName`
  - `attachmentKind`
  - `mimeType`
  - `sortOrder`
- 最小成功响应固定为：
  - 正式 `ProjectAttachmentReadModel`
- `POST` 语义固定为：
  - 把已确认的 `fileAssetId` 绑定为正式项目附件 truth
  - 不生成第二套上传真值

### 3.3 DELETE `/api/app/my/projects/{projectId}/attachments/{attachmentId}`

- 最小成功响应固定为：
  - `attachmentId`
  - `projectId`
  - `state=deleted`
- DELETE 只承接 owner 对 owner-private attachment 的受控删除。

## 4. Attachment Kind / MIME Contract Freeze

- `attachmentKind` V1 固定为：
  - `effect_image`
  - `construction_doc`
  - `other_material`
- 允许 MIME 固定为：
  - `image/png`
  - `image/jpeg`
  - `image/webp`
  - `application/pdf`
  - `application/msword`
  - `application/vnd.openxmlformats-officedocument.wordprocessingml.document`
- 合法组合固定为：
  - `effect_image -> image/*`
  - `construction_doc -> pdf/doc/docx`
  - `other_material -> image/pdf/doc/docx`

## 5. OTP / Upload Reuse Rule

- V1 固定复用：
  - `POST /api/app/file/upload/init`
  - direct upload
  - `POST /api/app/file/upload/confirm`
- post-publish materials supplement 的上传口径固定为：
  - `businessType=project`
  - `fileKind=project_attachment`
  - `businessId={projectId}`
- 当前必须明确：
  - upload confirm 只确认 `FileAsset`
  - 项目附件正式列表必须通过 `POST /api/app/my/projects/{projectId}/attachments` 形成
- 忘记附件绑定时，不得只靠 upload confirm 本地记录假装列表已成立

## 6. Controlled Error / Invalid-state Freeze

- 当前最小 contract 错误家族固定包括：
  - malformed request
  - invalid attachment kind / mime combination
  - file asset not confirmed
  - owner permission denied
  - attachment not found
  - controlled unavailable
- public owner-private attachment 读取不成立，因此不新增 public visibility access family。

## 7. Hard Boundary

- 当前 contract family 只属于 owner-private continuation。
- `workbench` 只承接 handoff，不成为附件真值页。
- `file_asset` 不是项目附件业务真值。
- 不允许把 `set of confirmed fileAssetIds` 偷写成正式附件列表。
- 不允许把 current corridor 扩写到：
  - admin 审核流
  - public attachment detail
  - order / contract / fulfillment

## 8. Next Unique Action

- 下一步唯一动作：
  - 输出《项目发布工作台 / 已发布项目资料补充走廊 V1 backend truth / persistence freeze》
