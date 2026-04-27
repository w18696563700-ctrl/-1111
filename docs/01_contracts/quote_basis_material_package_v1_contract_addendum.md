---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the L2 contract for Quote Basis Material Package V1, including the
  five canonical attachmentKind values shared by Flutter, BFF, and Server, the
  owner upload/read family, bidder read projection, and access boundary.
layer: L2 Contracts
freeze_date_local: 2026-04-27
inputs_canonical:
  - docs/00_ssot/quote_basis_material_package_v1_ruling_addendum.md
  - docs/01_contracts/project_attachment_prepublish_and_bid_materials_contract_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《报价依据资料包 V1 contract freeze》

## 1. Scope

本合同冻结只覆盖：

- owner 私域项目附件 family：
  - `GET /api/app/my/projects/{projectId}/attachments`
  - `POST /api/app/my/projects/{projectId}/attachments`
  - `DELETE /api/app/my/projects/{projectId}/attachments/{attachmentId}`
- 竞标方只读资料投影：
  - `GET /api/app/project/bid-materials?projectId={projectId}`
- 对应 Server 内部路径：
  - `GET /server/projects/{projectId}/bid-materials`
- `attachmentKind` 枚举扩展。

本合同不新增通用 public attachment center，不新增竞标方附件写入 family，不把 OSS objectKey 作为合同字段真源。

## 2. Canonical attachmentKind

`报价依据资料包 V1` 的正式业务枚举固定为 5 个：

```yaml
ProjectQuoteBasisMaterialKind:
  - effect_image
  - construction_doc
  - material_sample
  - equipment_material_list
  - service_list
```

含义固定为：

| attachmentKind | 用户名称 | 说明 |
| --- | --- | --- |
| `effect_image` | 效果图 | 展示视觉效果、造型、灯光氛围 |
| `construction_doc` | 尺寸图 / 施工图 | 展示尺寸、面积、结构、用料和施工边界 |
| `material_sample` | 材质图 / 材料样板 | 展示板材、饰面、五金、特殊工艺 |
| `equipment_material_list` | 设备物料清单 | 展示 LED、电视、触摸机、桌椅、绿植、饮水机等非装修但必需物料 |
| `service_list` | 服务清单 | 展示保洁、摄影摄像、礼仪、模特、演绎、安保等服务需求 |

Flutter、BFF、Server 必须以以上枚举为准，不得靠中文标题、文件名、OSS 目录名推断资料类型。

## 3. Legacy `other_material`

`other_material` 不属于 `报价依据资料包 V1` 的新主路径。

- 它只保留为历史兼容值。
- 新的发布方报价依据资料上传入口不得继续把 `材质图` 写成 `other_material`。
- 新的竞标方 `bid-materials` 投影不得把 `other_material` 当作报价依据资料返回。
- 如果旧数据要进入新五类资料，必须经过独立迁移或手工重绑，不得在 BFF / Flutter 临时映射。

## 4. Owner Upload Contract

发布方上传继续复用现有三段式链路：

1. `POST /api/app/file/upload/init`
2. direct upload to OSS
3. `POST /api/app/file/upload/confirm`
4. `POST /api/app/my/projects/{projectId}/attachments`

绑定请求最小字段继续为：

```yaml
ProjectAttachmentCreateRequest:
  fileAssetId: string
  fileName: string
  attachmentKind: ProjectQuoteBasisMaterialKind
  mimeType: string
  sortOrder: integer
```

绑定约束固定为：

- `fileAssetId` 必须指向 confirmed `FileAsset`。
- `FileAsset.businessType` 必须为 `project`。
- `FileAsset.fileKind` 必须为 `project_attachment`。
- `project_attachments.project_id` 必须等于 path 中的 `projectId`。
- `project_attachments.attachment_kind` 必须使用 5 个 V1 枚举之一。

## 5. Bidder Read Projection Contract

竞标方读取继续使用：

```http
GET /api/app/project/bid-materials?projectId={projectId}
```

响应最小模型固定为：

```yaml
ProjectBidMaterialListResponse:
  projectId: string
  attachments:
    - attachmentId: string
      projectId: string
      fileAssetId: string
      fileName: string
      attachmentKind: ProjectQuoteBasisMaterialKind
      mimeType: string
      sortOrder: integer
      createdAt: date-time
```

该响应不得返回：

- OSS 裸地址
- owner 上传、删除、替换动作
- `other_material`
- 第二附件 carrier 字段
- 无资格下载凭证

## 6. View / Download Boundary

接单方可以查看或下载报价依据资料，但必须满足合同边界：

- 当前组织已登录。
- 当前组织具备该项目竞标资格。
- 当前项目处于允许竞标的状态。
- 当前组织不是项目发布方 owner 组织。
- 目标附件属于同一项目。
- 目标附件 `attachmentKind` 属于 5 个 V1 枚举之一。

下载 / 查看不得依赖列表响应中的裸 URL。若后续开放访问动作，必须由 BFF 转发到 Server 做资格校验，再返回短期受控访问凭证。

未满足资格时，错误必须归一为材料不可读或下载不可用，不得让用户误解成账号损坏。

## 7. MIME Contract

当前建议 MIME family 固定为：

| attachmentKind | 允许文件类型 |
| --- | --- |
| `effect_image` | `image/png`, `image/jpeg`, `image/webp` |
| `construction_doc` | `application/pdf`, `application/msword`, `application/vnd.openxmlformats-officedocument.wordprocessingml.document`, 可后续扩展 CAD |
| `material_sample` | `image/png`, `image/jpeg`, `image/webp`, `application/pdf`, Word 文档 |
| `equipment_material_list` | Excel, PDF, Word, CSV |
| `service_list` | Excel, PDF, Word, CSV |

Flutter 只负责前端提示和选择限制；Server 仍是最终校验真源。

## 8. Error Contract

竞标方材料列表和访问动作的用户语义固定为：

- 无资料：`发布方暂未上传报价依据资料`
- 部分缺失：对应格子显示 `未上传`
- 无资格读取：`当前项目材料暂不可读`
- 无资格下载：`当前账号暂不能下载该项目材料`
- 后端异常：`材料清单暂不可读，请稍后再试`

不得把 403 直接暴露为主要用户体验，不得提示 `账号异常` 或 `权限坏了`。

## 9. OpenAPI Authority

`docs/01_contracts/openapi.yaml` 必须同步承载以下合同变化：

- `ProjectAttachmentKind` 增加：
  - `material_sample`
  - `equipment_material_list`
  - `service_list`
- `ProjectBidMaterialKind` 增加：
  - `material_sample`
  - `equipment_material_list`
  - `service_list`
- `other_material` 只能作为 legacy-compatible owner attachment value，不进入新的 `ProjectBidMaterialKind`。

生成投影仍以 `pnpm contracts:generate` 为唯一入口，不得手工维护派生 bundle。

## 10. Option Judgment

- 更稳：五类资料使用显式枚举，访问动作走资格校验，不用 OSS 路径或文件名推断业务。
- 更省成本：沿用现有 owner attachments family 和 bid-materials read route，只做枚举/响应范围扩展。
- 更适合当前阶段：先冻结 L2，再进入 Backend / BFF / Flutter 分层实现。
- 风险更大：继续使用 `other_material` 承载新材质图、把列表响应直接塞 OSS URL、或让无资格组织下载。

## 11. Formal Day1 Gate

当前 Day1 L2 结论：

- `material_sample / equipment_material_list / service_list` 已正式进入合同枚举。
- `effect_image / construction_doc` 继续保留。
- `other_material` 不进入 V1 主路径。
- 发布方上传通道、接单方读取通道、DB / OSS 真相边界已冻结。
- 后续代码实现不得再临场猜字段。
