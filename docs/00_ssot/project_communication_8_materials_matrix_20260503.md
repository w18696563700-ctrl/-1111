---
owner: Codex 总控
status: frozen
layer: L0 SSOT / Project communication material review matrix
recorded_at_local: 2026-05-03
scope: Project communication 8 material review entries only
---

# 项目沟通 8 个资料项 Matrix 20260503

## 1. 总裁决

本 matrix 裁决为 `PASS`。

本文件只冻结项目沟通工作台中 8 个资料审阅项的业务真值、角色可见性、状态和动作边界。`contract_confirmation` 与 `final_confirmed_amount_confirmation` 是成交确认入口，保持 `Reserved / next gate`，不得混入 8 项资料审阅。

## 2. 当前最小闭环

8 个资料项来自现有 workbench read-model：

- Server 是唯一业务真值 owner。
- BFF 只转发和塑形，不持有第二状态机。
- Flutter 只消费 `ProjectCommunicationWorkbenchEntry`，不得用本地 UI state、聊天文本、objectKey 推导业务真值。
- 每个资料项动作必须携带 `projectId`、`threadId`，涉及竞标资料或具体竞标关系时必须携带 `bidId`。

## 3. 8 个资料项正式 Matrix

| entryKey | 中文名 | group | subjectOwnerRole | reviewer / action owner | truth source | sourceFiles 来源 | owner 可见内容 | counterpart 可见内容 | 可点击 | 可发起动作 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `publisher_effect_image_review` | 效果图确认 | `publisher_materials` | `publisher` | 竞标方组织 | `project_attachments.effect_image` | `truthAnchor.materialKind=effect_image` 或 `sourceFiles` | 发布方查看自己上传的效果图、竞标方确认/反馈结果 | 竞标方查看发布方真实效果图并确认或要求补充 | 是，资料存在时进详情 | 竞标方可 `confirm` / `request_supplement`；发布方只读 |
| `publisher_construction_doc_review` | 尺寸图 / 施工图确认 | `publisher_materials` | `publisher` | 竞标方组织 | `project_attachments.construction_doc` | `truthAnchor.materialKind=construction_doc` 或 `sourceFiles` | 发布方查看自己上传的尺寸图 / 施工图、竞标方反馈 | 竞标方查看真实尺寸图 / 施工图并确认或要求补充 | 是，资料存在时进详情 | 竞标方可动作；发布方只读 |
| `publisher_material_sample_review` | 材质图 / 材料样板确认 | `publisher_materials` | `publisher` | 竞标方组织 | `project_attachments.material_sample` | `truthAnchor.materialKind=material_sample` 或 `sourceFiles` | 发布方查看自己上传的材质图 / 材料样板、竞标方反馈 | 竞标方查看真实材质图 / 材料样板并确认或要求补充 | 是，资料存在时进详情 | 竞标方可动作；发布方只读 |
| `publisher_equipment_material_list_review` | 设备物料清单确认 | `publisher_materials` | `publisher` | 竞标方组织 | `project_attachments.equipment_material_list` | `truthAnchor.materialKind=equipment_material_list` 或 `sourceFiles` | 发布方查看自己上传的设备物料清单、竞标方反馈 | 竞标方查看真实设备物料清单并确认或要求补充 | 是，资料存在时进详情 | 竞标方可动作；发布方只读 |
| `publisher_service_list_review` | 服务清单确认 | `publisher_materials` | `publisher` | 竞标方组织 | `project_attachments.service_list` | `truthAnchor.materialKind=service_list` 或 `sourceFiles` | 发布方查看自己上传的服务清单、竞标方反馈 | 竞标方查看真实服务清单并确认或要求补充 | 是，资料存在时进详情 | 竞标方可动作；发布方只读 |
| `bid_project_understanding_review` | 项目理解确认 | `bid_materials` | `bidder` | 发布方组织 | `bids.projectUnderstandingFileAssetId` | `truthAnchor.bidMaterialSlot=project_understanding` 或 `sourceFiles` | 发布方查看竞标方真实项目理解并确认或要求补充 | 竞标方查看自己提交的项目理解、发布方确认/反馈结果 | 是，资料存在时进详情 | 发布方可动作；竞标方只读 |
| `bid_quote_sheet_review` | 报价表确认 | `bid_materials` | `bidder` | 发布方组织 | `bids.quoteSheetFileAssetId` | `truthAnchor.bidMaterialSlot=quote_sheet` 或 `sourceFiles` | 发布方查看竞标方真实报价表并确认或要求补充 | 竞标方查看自己提交的报价表、发布方确认/反馈结果 | 是，资料存在时进详情 | 发布方可动作；竞标方只读 |
| `bid_schedule_plan_review` | 进度安排确认 | `bid_materials` | `bidder` | 发布方组织 | `bids.schedulePlanFileAssetId` | `truthAnchor.bidMaterialSlot=schedule_plan` 或 `sourceFiles` | 发布方查看竞标方真实进度安排并确认或要求补充 | 竞标方查看自己提交的进度安排、发布方确认/反馈结果 | 是，资料存在时进详情 | 发布方可动作；竞标方只读 |

## 4. 状态映射

| Contract field / enum | 中文展示 | UI 颜色 | 业务含义 | 是否允许进入详情 | 是否允许动作 |
| --- | --- | --- | --- | --- | --- |
| `reviewState=unsubmitted` 或 `availabilityState=unsubmitted` | 未提交 | 灰色 | 资料真值不存在或当前不可读取。 | 可进入只读空态详情或显示空态。 | 否 |
| `reviewState=pending_review` 且 `availabilityState=readable` | 待确认 | 橙色 | 资料存在，等待对方组织审阅。 | 是 | 仅 reviewer 且 `actionState=enabled` 可动作 |
| `reviewState=confirmed` | 已确认 | 绿色 | 对方组织已确认，Server 持久化。 | 是，只读或可查看确认结果 | 否，除非后续版本另开重审门禁 |
| `reviewState=needs_supplement` | 需补充 | 鲜红色 | 对方组织已提交补充反馈，Server 持久化。 | 是 | subject owner 只读查看反馈；reviewer 后续是否可重复反馈由 Server gate 决定 |
| `availabilityState=unavailable` | 暂不可用 | 灰色 | 当前资料或上下文不可读。 | 否或只读提示 | 否 |
| `actionState=blocked` | 锁定 | 灰色 | 当前账号不能执行动作。 | 可只读查看，不可动作 | 否 |
| `actionState=readonly` | 只读 | 灰色 | 当前账号只读。 | 是，若资料可读 | 否 |

不得新增独立的“已拒绝”状态；需要补充的业务状态统一为 `needs_supplement`。

## 5. 空态 / 错误态 / 锁态

| 场景 | 展示 | 行为 |
| --- | --- | --- |
| 资料未提交 | `当前资料尚未提交` | 不允许确认，不允许反馈；可提示对方补充但不得写业务状态。 |
| workbench 读取失败 | `工作台状态暂不可读` 或 BFF 返回 message | 不显示假状态，不本地补齐 entries。 |
| entry 缺少 `projectId` / `threadId` | 显示错误态 | 不允许动作。 |
| bid material 缺少 `bidId` | 显示错误态 | 不允许动作。 |
| `truthOwner != server` | 合同漂移错误 | 不允许动作。 |
| `entryKey` 未知 | 合同漂移错误 | 不允许动作。 |

## 6. Reserved / Next Gate

| entryKey | 中文名 | 状态 | 本轮行为 |
| --- | --- | --- | --- |
| `contract_confirmation` | 合同确认 | `Reserved / next gate` | 只读入口或提示，不执行真实合同确认。 |
| `final_confirmed_amount_confirmation` | 最终成交金额确认 | `Reserved / next gate` | 只读入口或提示，不写最终成交金额，不触发扣费。 |
| `POST /api/app/message/project-communication/messages` | 项目沟通消息发送 | `Reserved / next gate for this matrix` | 代码存在，但不是本轮 8 项资料 matrix 的 Current。 |

## 7. No-Go

以下行为禁止：

- 用 `objectKey`、文件名、OSS 路径、聊天消息、UI 本地 state 推导资料确认状态。
- 未提交资料显示为可确认。
- Flutter / BFF 自己把资料变成 `confirmed` 或 `needs_supplement`。
- 把 `contract_confirmation` 或 `final_confirmed_amount_confirmation` 塞进 material-review command。
- 触发支付、扣费、支付回调、真实合同确认、最终成交金额确认。
- 新增 BFF / Server / contracts 字段来补 UI。

## 8. 是否允许进入 UI Matrix

`允许`。

条件：UI matrix 必须按本文件的 8 项资料和 2 项 Reserved 分组，不得长期平铺进聊天区，不得污染消息流。
