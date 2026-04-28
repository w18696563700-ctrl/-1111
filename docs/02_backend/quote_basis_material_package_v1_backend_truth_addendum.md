---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Server-side truth and persistence implementation boundary for
  Quote Basis Material Package V1.
layer: L3 Backend
freeze_date_local: 2026-04-27
inputs_canonical:
  - docs/00_ssot/quote_basis_material_package_v1_ruling_addendum.md
  - docs/01_contracts/quote_basis_material_package_v1_contract_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《报价依据资料包 V1 backend truth》

## 1. Conclusion

Server 继续是报价依据资料包的唯一业务真相 owner：

- `file_assets` 承载已确认上传资产。
- `project_attachments` 承载项目附件业务绑定和 `attachment_kind`。
- OSS 只承载二进制对象，`objectKey` 不得成为业务分类真源。

## 2. Persistence

`project_attachments.attachment_kind` 的 DB check 必须兼容：

- V1 主路径：`effect_image / construction_doc / material_sample / equipment_material_list / service_list`
- 历史兼容：`other_material`

Server 新写入只允许 V1 五类；`other_material` 只能读历史数据，不得作为新材质图主路径。

## 3. Bind Validation

发布方绑定项目附件时必须校验：

- 当前组织是项目发布方组织。
- 项目处于附件补充走廊允许状态。
- `FileAsset.businessType = project`
- `FileAsset.businessId = project.id`
- `FileAsset.fileKind = project_attachment`
- `FileAsset.organizationId = project.organizationId`
- `attachmentKind` 属于 V1 五类；MIME 仅作为 FileAsset 技术属性记录，不再按资料分类收窄。

## 4. Bid-material Projection

`GET /server/projects/{projectId}/bid-materials` 只从 `project_attachments` 投影五类 V1 资料：

- `effect_image`
- `construction_doc`
- `material_sample`
- `equipment_material_list`
- `service_list`

返回字段只能是接单方可见字段，不得返回 owner 管理动作、OSS 裸地址或 `other_material`。

## 5. Access Permission

接单方查看 / 下载使用专用 `bid_material` 访问分支：

- 必须登录。
- 必须具备竞标资格。
- 项目必须已发布且可竞标。
- 当前组织不得等于项目发布方组织。
- 附件必须属于同一项目和 V1 五类。

不得放宽通用 owner-private file access。
