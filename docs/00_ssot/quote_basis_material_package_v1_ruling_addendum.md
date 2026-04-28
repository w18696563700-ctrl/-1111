---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Quote Basis Material Package V1 truth for publisher-side project
  material upload and bidder-side bid-submit material consumption, including
  the five canonical attachment kinds, nine-grid surface boundary, permission
  boundary, and DB / OSS truth split.
layer: L0 SSOT
freeze_date_local: 2026-04-27
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_attachment_prepublish_and_bid_materials_truth_freeze_addendum.md
  - docs/01_contracts/project_attachment_prepublish_and_bid_materials_contract_freeze_addendum.md
  - docs/00_ssot/bid_submit_five_step_business_flow_ruling_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《报价依据资料包 V1 ruling》

## 1. Formal Conclusion

当前正式新增 `报价依据资料包 V1`，用于解决同一个业务问题：

- 发布方在 `我的项目 -> 我的发布 -> 项目发布工作台 / 项目详情文书区` 上传影响报价的项目资料。
- 接单方在 `竞标提交 -> 第二步 查看项目详情材料` 读取同一批报价依据资料。
- 资料业务真值继续落在 `project_attachments`。
- 上传资产真值继续落在 `file_assets`。
- OSS 只保存二进制文件，不保存业务分类真值。

本轮不新建第二附件 carrier，不新建 public attachment center，不把竞标方页面做成 owner 附件管理页。

## 2. Current Minimum Closure

当前最小闭环固定为：

1. 发布方创建或提交项目后，进入 owner 私域项目工作台补齐 `报价依据资料包`。
2. 上传继续复用三段式文件链路：`init -> direct upload -> confirm -> bind project attachment`。
3. `project_attachments.attachment_kind` 承载业务分类。
4. 接单方进入竞标提交页后，在第二步看到同一个资料包的只读九宫格。
5. 接单方根据资料自行评估报价，再进入第三步填写报价与服务费确认。

## 3. Five Canonical Material Kinds

`报价依据资料包 V1` 只冻结以下 5 类资料：

| attachmentKind | 用户名称 | 影响报价的核心原因 | 发布方上传入口 | 接单方读取入口 |
| --- | --- | --- | --- | --- |
| `effect_image` | 效果图 | 决定视觉复杂度、造型、灯光氛围 | 报价依据资料包 | 第二步九宫格 |
| `construction_doc` | 尺寸图 / 施工图 | 决定面积、结构、用料、人工 | 报价依据资料包 | 第二步九宫格 |
| `material_sample` | 材质图 / 材料样板 | 决定板材、饰面、五金、工艺成本 | 报价依据资料包 | 第二步九宫格 |
| `equipment_material_list` | 设备物料清单 | LED、电视、触摸机、桌椅、绿植、饮水机等会影响租赁、采购、运输、安装成本 | 报价依据资料包 | 第二步九宫格 |
| `service_list` | 服务清单 | 保洁、摄影摄像、礼仪、模特、演绎、安保等会影响人力、排期和外协成本 | 报价依据资料包 | 第二步九宫格 |

## 4. Nine-grid Rule

- 前端表现采用九宫格能力，但 V1 只放 5 个真实业务格子。
- 不得为了凑满九宫格而新增虚假必传项。
- 缺失的资料格子显示为 `未上传` 或 `发布方暂未提供`，不得引导接单方上传、删除、替换。
- 接单方九宫格只允许读取、查看、下载已开放资料，不显示 owner 管理动作。

推荐提示文案：

> 建议先将资料下载到手机，再导入电脑完成报价测算和方案整理。下载后的资料仅用于本项目竞标，请勿外传。

## 5. Publisher / Bidder Correspondence

发布方侧和接单方侧必须是一一对应关系：

- 发布方 `报价依据资料包.效果图` -> 接单方 `第二步.效果图`
- 发布方 `报价依据资料包.尺寸图 / 施工图` -> 接单方 `第二步.尺寸图 / 施工图`
- 发布方 `报价依据资料包.材质图 / 材料样板` -> 接单方 `第二步.材质图 / 材料样板`
- 发布方 `报价依据资料包.设备物料清单` -> 接单方 `第二步.设备物料清单`
- 发布方 `报价依据资料包.服务清单` -> 接单方 `第二步.服务清单`

任何一端不得自行改名成新业务分类。Flutter、BFF、Server 必须以合同枚举为准，不得靠中文标题猜字段。

## 6. DB / OSS Truth Boundary

当前真相边界固定为：

- `file_assets`：
  - 保存上传资产真值。
  - 必须是已确认上传。
  - `fileKind` 固定为 `project_attachment`。
  - `businessType` 固定为 `project`。
- `project_attachments`：
  - 保存项目附件业务真值。
  - 保存 `projectId / fileAssetId / attachmentKind / visibility / sortOrder / createdAt` 等业务绑定。
  - `attachmentKind` 是报价依据资料分类真源。
  - `mimeType` 只是文件技术属性；经全格式补充冻结后，不再按 `attachmentKind` 收窄文件格式。
- OSS：
  - 只保存二进制对象。
  - `objectKey` 不得作为业务分类、项目归属、权限或资料类型真源。
  - 不得用 OSS 目录名反推 `attachmentKind`。

## 7. Permission Boundary

当前 V1 权限方向固定为：

- 发布方 owner 组织可以上传、查看、删除自己项目下的报价依据资料。
- 接单方只能在具备竞标资格、项目处于可竞标状态、且当前组织不是发布方时读取开放资料。
- 接单方下载或查看必须走受控访问链路，不得拿到长期裸 OSS 地址。
- 未登录、无项目读取资格、非竞标方组织、非发布方 owner 组织，均不得查看或下载。
- 不开放无资格下载。

注意：Day1 只冻结真相和合同。本地不直接修改云上 BFF / Server 权限；后续若要真正开放接单方查看 / 下载，必须进入独立的 L3 Backend、L4 BFF、L5 Flutter 和云端发布门禁。

## 8. Explicit Non-goals

本轮明确不进入：

- 不放 `工程量清单`。
- 不把 `工程量清单` 伪装成设备清单或服务清单。
- 不复用 `other_material` 做 `材质图 / 材料样板` 的新主路径。
- 不把旧 `other_material` 投影给竞标方作为新资料包成员。
- 不开放无资格下载。
- 不开放接单方上传、删除、替换、绑定项目附件。
- 不把报价依据资料包并入竞标方上传的 `项目理解 / 报价表 / 进度安排`。
- 不把资料包做成通用资料库、模板中心或 Admin 配置中心。

## 9. Legacy Compatibility

`other_material` 只保留为历史兼容分类：

- 旧数据可以继续按历史规则存在。
- 新的 `报价依据资料包 V1` 不得把 `other_material` 当作材质图主路径。
- 如需把历史 `other_material` 迁移为 `material_sample`，必须另开数据迁移和权限复核门禁。

## 10. Reserved Extension Slots

以下内容影响报价，但当前暂不开通：

- 工程量清单
- 现场交付限制表
- 主办方施工规范
- 进撤场时间表
- 展馆特殊费用表

这些只作为后续扩展位，不进入 V1 九宫格，不得在前端提前显示为必传项。

## 11. Option Judgment

- 更稳：新增明确的五类 `attachmentKind`，继续使用 `project_attachments + FileAsset` 真值链，下载另走资格校验访问链。
- 更省成本：沿用既有 owner 附件上传绑定和 bid-materials 只读投影，只扩枚举与文案/布局。
- 更适合当前阶段：Day1 先冻结 L0 / L2，后续再按 Backend -> BFF -> Flutter -> 云端验证推进。
- 风险更大：复用 `other_material` 承载材质图、直接开放通用 `file/access` 给所有接单方、或把接单方九宫格做成 owner 附件管理入口。

## 12. Formal Day1 Gate

当前 Day1 结论：

- `报价依据资料包 V1` 真相已冻结。
- 5 类资料已冻结。
- 九宫格只读消费边界已冻结。
- 发布方 / 接单方对应关系已冻结。
- DB / OSS 真相边界已冻结。
- `工程量清单`、`other_material` 新主路径、无资格下载均为 No-Go。
