---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the publisher-side my-project detail information-density optimization
  boundary after Quote Basis Material Package V1, so Flutter can simplify the
  page without deleting project communication capability or reopening BFF /
  Server scope.
layer: L0 SSOT
freeze_date_local: 2026-04-27
inputs_canonical:
  - docs/00_ssot/quote_basis_material_package_v1_ruling_addendum.md
  - docs/04_frontend/quote_basis_material_package_v1_frontend_surface_addendum.md
  - docs/04_frontend/my_project_detail_compact_materials_surface_frontend_addendum.md
  - docs/04_frontend/project_public_resource_download_zone_frontend_consumption_addendum.md
  - docs/04_frontend/project_communication_album_rating_frontend_consumption_freeze_addendum.md
---

# 《发布方项目详情页信息密度优化 ruling》

## 1. 本轮目标

本轮只优化发布方 `我的项目详情` 页的信息密度和任务优先级。

页面应从“信息全部摊开”调整为“报价依据资料优先、基础信息可展开、沟通入口不抢主线、公共资源降噪”。

本轮不改变任何业务真相、权限真相、上传真相或交易状态机。

## 2. 当前最小闭环

发布方进入项目详情页时，当前主任务是维护本项目的 `报价依据资料`：

- 效果图
- 尺寸图 / 施工图
- 材质图 / 材料样板
- 设备物料清单
- 服务清单

这些资料仍使用既有三段式上传和绑定链路：

`upload init -> direct upload -> upload confirm -> bind project attachment`

正式业务真相仍是：

- `FileAsset`
- `project_attachments`
- `attachmentKind`
- OSS object 只承载文件，不承载业务分类真相

## 3. 冻结决策

### 3.1 基础信息默认折叠

`已保存的项目基础信息摘要` 在发布方项目详情页默认折叠。

折叠态只保留足够确认身份和状态的摘要信息，例如：

- 项目名称
- 项目编号
- 当前状态
- 预算或面积等关键摘要
- 展开入口

完整项目基础信息仍可展开查看，不删除字段、不丢失项目核对能力。

### 3.2 项目沟通当前页隐藏主入口

`项目沟通` 能力不删除。

本轮只在发布方项目详情页隐藏项目沟通的主入口卡片，避免它在当前页面与报价依据资料抢主线。

项目沟通的正式主入口继续归属 `消息` building。

后续如需要从项目详情快速进入沟通，只允许在必要状态下增加轻量跳转，不允许恢复成大面积主卡片，也不允许在本轮新增聊天能力或消息状态机。

### 3.3 报价依据资料成为主任务区

`报价依据资料` 是本页当前最主要的可操作模块。

该区域应在基础信息折叠摘要之后优先展示，并成为发布方补充、预览、删除本项目报价依据资料的主工作区。

资料卡片展示应强化人可理解的资料类型，不应把随机文件名作为第一视觉中心。

资料名称来自 `attachmentKind` 的固定映射，不新增资料标题字段。

固定映射为：

| attachmentKind | 资料名称 |
| --- | --- |
| `effect_image` | 效果图 |
| `construction_doc` | 尺寸图 / 施工图 |
| `material_sample` | 材质图 / 材料样板 |
| `equipment_material_list` | 设备物料清单 |
| `service_list` | 服务清单 |

### 3.4 公共资源弱化

`公共资源下载区` 保留能力，但在发布方项目详情页中弱化。

本轮不把公共资源作为发布方当前页面主任务。

公共资源区域应减少解释型文案，保留必要分类、资源列表和下载动作；不得与 `报价依据资料` 合并成同一业务区。

## 4. 明确不做

本轮明确不做以下事项：

- 不改 BFF。
- 不改 Server。
- 不改数据库表结构。
- 不改 OSS object key 规则。
- 不新增 `资料标题`、`materialTitle`、`displayName` 等后端字段。
- 不允许发布方自定义每个附件的业务标题。
- 不删除项目沟通能力。
- 不新增项目沟通消息能力。
- 不改变 `消息` building 对项目沟通的主入口定位。
- 不开放或调整接单方无资格下载。
- 不把公共资源与报价依据资料混为一个模块。
- 不把工程量清单加入本轮报价依据资料包。

## 5. 需要保留但暂不开通

以下能力保留扩展位，但本轮不实现：

- 项目详情页中的轻量 `进入项目沟通` 跳转。
- 资料卡片自定义标题。
- 发布方上传资料的批量排序。
- 公共资源按项目状态自动推荐。
- 工程量清单独立阶段。
- 接单方报价依据资料下载后的水印、审计和更细权限策略。

## 6. 选项判断

- 更稳：只做 Flutter 展示层信息密度调整，保留既有 BFF / Server / DB / OSS 真相不动。
- 更省成本：基础信息默认折叠、项目沟通隐藏当前页主入口、公共资源裁剪文案，均属于页面编排与文案调整。
- 更适合当前阶段：报价依据资料包 V1 已经成为发布方与接单方报价链路的核心资料入口，本页应优先服务该任务。
- 风险更大：删除项目沟通能力、为资料名称新增后端字段、重开 BFF / Server 权限、或把公共资源和报价依据资料合并。

## 7. 阶段结论

本 ruling 冻结后，允许进入 `L5 Frontend Surface` 冻结和 Flutter 实现。

后续 Flutter 只能在本 ruling 范围内调整发布方项目详情页，不得借本轮信息密度优化扩大到 BFF、Server、DB、OSS 或项目沟通业务能力重构。
