---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the BFF surface for Quote Basis Material Package V1, including
  five-kind bid-material forwarding and scoped file-access transport.
layer: L4 BFF
freeze_date_local: 2026-04-27
inputs_canonical:
  - docs/00_ssot/quote_basis_material_package_v1_ruling_addendum.md
  - docs/01_contracts/quote_basis_material_package_v1_contract_addendum.md
  - docs/02_backend/quote_basis_material_package_v1_backend_truth_addendum.md
---

# 《报价依据资料包 V1 BFF surface》

## 1. Conclusion

BFF 只做 app-facing 转发、字段裁剪和错误归一，不持有报价依据资料真相。

## 2. Bid-materials

`GET /api/app/project/bid-materials?projectId={projectId}` 固定转发：

- Server path: `GET /server/projects/{projectId}/bid-materials`
- kind 白名单：`effect_image / construction_doc / material_sample / equipment_material_list / service_list`
- 明确排除：`other_material`

BFF 返回结构必须稳定为 `projectId + attachments[]`，不得返回 owner 写动作、OSS 裸地址或第二附件 carrier。

## 3. File Access

`GET /api/app/file/access` 增加透传参数：

- `projectId`
- `accessScope=bid_material`

省略 `accessScope` 时仍按旧 `owner_private` 处理，避免破坏 owner 附件预览。

## 4. Error Copy

材料清单读取错误归一为：

- `当前项目材料清单暂不可读，请稍后再试。`

接单方无资格下载归一为：

- `当前账号暂不能下载该项目材料。`

不得把 403 作为主要用户体验，不得提示账号损坏或泛化为 owner 权限异常。
