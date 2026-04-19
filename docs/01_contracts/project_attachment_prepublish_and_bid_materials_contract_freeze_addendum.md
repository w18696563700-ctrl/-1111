---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the bounded contract adjustment for prepublish owner attachment
  continuation and the new bid-submit read-only project-materials projection,
  while retaining the existing attachment carrier and upload-reuse chain.
layer: L2 Contracts
freeze_date_local: 2026-04-16
inputs_canonical:
  - docs/00_ssot/project_attachment_prepublish_and_bid_materials_truth_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/01_contracts/project_publish_workbench_post_publish_materials_corridor_v1_contract_freeze_addendum.md
---

# 《项目附件预发布前移与竞标材料只读投影 contract freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `/api/app/my/projects/{projectId}/attachments*`
  - `/api/app/project/bid-materials`
  - 对应 `/server/*` 对等路径
- 本冻结单不进入：
  - 新上传 path
  - 新 lifecycle path
  - 通用 public attachment list family

## 2. Owner Attachment Family

- 当前 owner 附件 app-facing 路由族继续固定为：
  - `GET /api/app/my/projects/{projectId}/attachments`
  - `POST /api/app/my/projects/{projectId}/attachments`
  - `DELETE /api/app/my/projects/{projectId}/attachments/{attachmentId}`
- 当前 contract authority 调整为：
  - `submitted-or-later owner continuation`
  - 不再限定为 `post-publish only`
- 当前 attachment bind 继续要求：
  - confirmed `fileAssetId`
  - `businessType=project`
  - `fileKind=project_attachment`
  - `businessId=projectId`

## 3. Bid Materials Read Contract

- 当前新增 app-facing 只读路径：
  - `GET /api/app/project/bid-materials?projectId={projectId}`
- 当前新增 server-side 对等路径：
  - `GET /server/projects/{projectId}/bid-materials`
- 当前路径只允许返回：
  - `projectId`
  - `attachments[]`
- `attachments[]` 当前最小字段固定为：
  - `attachmentId`
  - `projectId`
  - `fileAssetId`
  - `fileName`
  - `attachmentKind`
  - `mimeType`
  - `sortOrder`
  - `createdAt`
- 当前路径不得返回：
  - `other_material`
  - owner 删除/写入动作
  - 第二附件 truth

## 4. Visibility Boundary

- owner 附件写侧仍属于 owner continuation contract。
- bid-side 新路径只承接：
  - `effect_image`
  - `construction_doc`
  的只读投影。
- 当前仍不得 author：
  - `/api/app/project/detail/attachments`
  - `/api/app/project/attachments/public-center`
  - 通用 public attachment 管理 path

## 5. Superseded Slice

- [project_publish_workbench_post_publish_materials_corridor_v1_contract_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/project_publish_workbench_post_publish_materials_corridor_v1_contract_freeze_addendum.md)
  中关于 owner 附件 family `post-publish only` 的限制，
  当前仅在本对象范围内被本冻结单取代。

## 6. Formal Conclusion

- 当前 contract 正式冻结为：
  - owner 附件 family 前移到 `submitted-or-later`
  - bid-submit 新增 bounded `bid-materials` 只读投影
