---
owner: Codex 总控
status: frozen
purpose: Freeze the owner-private BFF surface for the post-publish materials supplement corridor, so app-facing transport, shaping, and error mapping remain aligned to Server truth without creating a second attachment state machine or public visibility expansion.
layer: L4 BFF
freeze_date_local: 2026-04-13
inputs_canonical:
  - docs/00_ssot/project_publish_workbench_post_publish_materials_corridor_v1_truth_freeze_addendum.md
  - docs/01_contracts/project_publish_workbench_post_publish_materials_corridor_v1_contract_freeze_addendum.md
  - docs/02_backend/project_publish_workbench_post_publish_materials_corridor_v1_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/project_publish_workbench_full_extension_mainline_bff_surface_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《项目发布工作台 / 已发布项目资料补充走廊 V1 BFF surface freeze》

## 1. 目标

- `BFF` 只承接 Round V1 post-publish materials supplement 的 app-facing owner-private surface。
- `BFF` 不拥有 project attachment truth。

## 2. BFF 职责边界

- `BFF` 只做：
  - app-facing -> server-facing transport
  - request normalization
  - response shaping
  - error mapping
- `BFF` 不做：
  - `file_asset` truth ownership
  - `project_attachments` truth ownership
  - 第二状态机
  - public visibility 放大
  - upload confirm -> attachment list 的伪绑定

## 3. Path Mapping Freeze

- 当前唯一路由映射固定为：
  - `GET /api/app/my/projects/{projectId}/attachments`
    -> `GET /server/projects/{projectId}/attachments`
  - `POST /api/app/my/projects/{projectId}/attachments`
    -> `POST /server/projects/{projectId}/attachments`
  - `DELETE /api/app/my/projects/{projectId}/attachments/{attachmentId}`
    -> `DELETE /server/projects/{projectId}/attachments/{attachmentId}`
  - `POST /api/app/file/upload/init` with
    `businessType=project`, `fileKind=project_attachment`
    -> `POST /server/uploads/init`

## 4. Request Surface Freeze

### 4.1 Attachment Create

- `POST /api/app/my/projects/{projectId}/attachments` 的最小 app-facing 输入固定为：
  - `fileAssetId`
  - `fileName`
  - `attachmentKind`
  - `mimeType`
  - `sortOrder`

### 4.2 Attachment List

- `GET /api/app/my/projects/{projectId}/attachments`
  只承接 owner-private 正式附件列表读取。

### 4.3 Attachment Delete

- `DELETE /api/app/my/projects/{projectId}/attachments/{attachmentId}`
  只承接 owner-private 正式附件删除。

## 5. Response Shaping Freeze

- list 成功响应只整形成：
  - `projectId`
  - `attachments[]`
- 每个 `attachment` item 只承接已冻结 canonical 字段。
- `POST` 成功后返回正式 `ProjectAttachmentReadModel`。
- `DELETE` 成功后返回统一最小 delete accepted envelope。
- `BFF` 不新开第二套 attachment response family。

## 6. Error Mapping Freeze

- 当前最小映射固定包括：
  - malformed request
  - invalid attachment kind / mime combination
  - file asset not confirmed
  - owner permission denied
  - attachment not found
  - controlled unavailable
- public detail 不开放 owner-private attachments，因此 `BFF` 不新增 public visibility access error family。
- 若 backend 对 owner permission / not found 做统一最小返回，`BFF` 不得拆成第二套业务真值差异。

## 7. Consent / Upload / Normalization Boundary

- 本 corridor 不新增新的 consent truth。
- `BFF` 只透传 upload carrier，不生成 upload truth。
- `BFF` 最小 normalization 边界固定为：
  - `fileName` trim
  - `attachmentKind` / `mimeType` shape normalization
  - `sortOrder` 数值承接
- `BFF` 不改写 attachment kind / MIME policy。

## 8. Workbench / Create / Edit Consumption Boundary

- create success 页与 project edit 页继续复用同一 owner-private attachment family。
- workbench 只允许 handoff / summary，不新增附件真值页。
- `BFF` 不为 workbench 创建第二个 attachment summary truth family。

## 9. 合规与发布门禁

- `BFF surface freeze` 完成前，不进入 frontend surface implementation dispatch。
- `BFF` 不得新开：
  - username/email/third-party path
  - public attachment path
  - second attachment otp / upload family

## 10. No-Go 边界

- `BFF` 不持有 `project_attachments` truth
- `BFF` 不接管 `file_asset` truth
- `BFF` 不做 attachment state machine
- 不新开第二条 attachment family
- 不把 `project attachment add` 写成 public publish 完成
- 不把 `attachment delete` 写成 public unpublish
- 不把 `workbench` 写成附件真值页

## 11. 裁决

- `Round V1 BFF surface freeze 是否可入库：是`
- `下一步唯一动作是什么：输出《项目发布工作台 / 已发布项目资料补充走廊 V1 frontend consumption freeze》`
