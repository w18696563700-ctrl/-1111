---
owner: Codex 总控
status: frozen
purpose: Freeze the Server truth and persistence shape for the post-publish owner-private materials corridor, so backend implementation can bind confirmed FileAssets into project-owned attachment truth without reopening public detail or upload truth ownership.
layer: L3 Backend truth specs
freeze_date_local: 2026-04-13
inputs_canonical:
  - docs/00_ssot/project_publish_workbench_post_publish_materials_corridor_v1_truth_freeze_addendum.md
  - docs/01_contracts/project_publish_workbench_post_publish_materials_corridor_v1_contract_freeze_addendum.md
  - docs/02_backend/project_publish_workbench_full_extension_mainline_backend_truth_persistence_freeze_addendum.md
  - docs/01_contracts/upload_contracts.yaml
  - docs/01_contracts/openapi.yaml
  - apps/server/src/modules/upload
  - apps/server/src/modules/project
---

# 《项目发布工作台 / 已发布项目资料补充走廊 V1 backend truth / persistence freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `项目发布工作台 / 已发布项目资料补充走廊 V1`
- 本冻结单只服务于：
  - `Server` truth ownership
  - `project_attachments` persistence
  - create / list / delete truth
  - upload-asset to project-attachment binding
- 本冻结单不进入：
  - BFF implementation
  - frontend implementation
  - admin 审核流

## 2. Server Canonical Truth Family

- 当前 corridor 的唯一合法 server truth 路由族固定为：
  - `GET /server/projects/{projectId}/attachments`
  - `POST /server/projects/{projectId}/attachments`
  - `DELETE /server/projects/{projectId}/attachments/{attachmentId}`
- 这三条路径只服务于：
  - owner-private
  - exhibition project
  - post-publish materials supplement

## 3. Truth Ownership Freeze

- `Server` 是唯一项目附件业务真值 owner。
- `file_asset` 继续是上传资产真值 owner。
- `project_attachments` 是项目附件业务真值 carrier。
- 二者关系固定为：
  - `file_asset` 先成立
  - `project_attachments` 后绑定
- upload confirm 不得直接替代 `project_attachments`。

## 4. Persistence Carrier Freeze

- V1 正式 persistence carrier 固定为：
  - `project_attachments`
- `project_attachments` 最小 canonical 持久化字段固定为：
  - `attachment_id`
  - `project_id`
  - `file_asset_id`
  - `file_name`
  - `attachment_kind`
  - `mime_type`
  - `visibility`
  - `sort_order`
  - `created_at`
  - `created_by`
- `visibility` 在 V1 固定为：
  - `owner_private`

## 5. Create / List / Delete Truth Freeze

### 5.1 Create

- `POST /server/projects/{projectId}/attachments` 的正式语义是：
  - 校验 owner project scope
  - 校验 `fileAssetId` 已由共享上传三步链确认
  - 校验 `attachmentKind + mimeType` 组合合法
  - 创建 `project_attachments` row
- create 不得：
  - 改写 `file_asset` truth
  - 创建第二附件状态机

### 5.2 List

- `GET /server/projects/{projectId}/attachments` 只返回当前 owner-private 正式附件列表。
- list 结果只读取 `project_attachments` 正式业务 row。
- list 不得读取“本地 confirm 记录”或“临时上传会话”冒充正式业务 truth。

### 5.3 Delete

- `DELETE /server/projects/{projectId}/attachments/{attachmentId}` 只承接 owner 对当前项目 owner-private 附件的受控删除。
- delete 后的 active truth 结果固定为：
  - 附件不再出现在当前正式列表中
- V1 不要求 trash / recycle-bin / restore truth。

## 6. Upload Binding Freeze

- post-publish attachments 固定复用共享上传链：
  - init
  - direct upload
  - confirm
- 但正式附件业务绑定固定发生在：
  - `POST /server/projects/{projectId}/attachments`
- `businessType=project + fileKind=project_attachment + businessId=projectId`
  只承接 post-publish materials supplement 的 upload transport binding。
- `objectKey` 继续不是业务真值。

## 7. Audit And Ordering Freeze

- `project_attachments` 最小 audit 事件固定为：
  - `project_attachment_created`
  - `project_attachment_deleted`
- 最小 audit 字段固定至少包括：
  - `projectId`
  - `attachmentId`
  - `fileAssetId`
  - `actorUserId`
  - `attachmentKind`
  - `traceId`
- `sortOrder` 只作为 owner-private 列表排序 truth，不扩写成第二内容治理体系。

## 8. Non-goals

- V1 不进入：
  - public attachment visibility
  - admin review
  - CAD / ZIP / 视频
  - attachment preview protocol family
  - order / contract / fulfillment
  - enterprise display published-change corridor 的实现复用

## 9. Next Unique Action

- 下一步唯一动作：
  - 输出《项目发布工作台 / 已发布项目资料补充走廊 V1 BFF surface freeze》
