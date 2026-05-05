# 我的项目详情：报价依据资料附件紧凑展示与上传体验冻结 Addendum

## 1. 本轮对象

页面：我的项目详情（预发布补资料并发布页）。

本轮只收敛报价依据资料附件区域的 Flutter 展示与现有 Flutter 交互触发时机：

- 附件按资料类型归属展示。
- 正式附件从大卡片压缩为紧凑文件行。
- 高级信息默认折叠。
- 操作图标化。
- 标准手机宽度、窄屏、长文件名和 bottom nav 安全区必须可用。
- 如现有状态管理稳定，允许选择文件后自动触发现有上传三步流。

## 2. 不做事项

- 不改 BFF、Server、OpenAPI、数据库。
- 不改上传三步流：`upload/init -> direct OSS upload -> upload/confirm/bind`。
- 不改 `FileAsset`、`Evidence`、`ProjectAttachment` 业务真值。
- 不新增资料类型。
- 不限制原本允许上传的文件格式。
- 不引入重型预览依赖。
- 不伪造附件状态、资料数量、绿色通道状态、发布确认状态。
- 不为了 UI 隐藏真实的上传失败、删除失败、未满足、待补充状态。

## 3. 字段真源

| 展示项 | 真源 | 规则 |
| --- | --- | --- |
| 五类资料类型 | Flutter 常量 `_projectAttachmentKindOptions` | 固定展示五类：效果图、尺寸图 / 施工图、材质图 / 材料样板、设备物料清单、服务清单 |
| 待上传附件 | Flutter 临时状态 `_selectedDraftsByKind` | 只代表上传前草稿态，不是业务真值 |
| 正式附件 | BFF 回读的 `ProjectAttachmentReadModel` | 正式资料以后端回读为准 |
| 附件所属资料类型 | `attachmentKind` | 正式附件按自身 `attachmentKind` 展示 |
| 全部类型 5 | 五类资料类型数量 | 不是附件数量 |
| 待补充 N | 当前前端列表派生 | 无待上传草稿且无正式附件的资料类型数量 |
| 待上传 N | 当前前端临时状态派生 | `_selectedDraftsByKind` 下待上传附件数量 |
| 已上传 N | 当前正式附件列表派生 | `ProjectAttachmentReadModel` 数量 |

## 4. 上传状态冻结

现有 Flutter 已存在以下上传状态：

- `idle`
- `selecting`
- `selectedReady`
- `initStarting`
- `initFailed`
- `directUploading`
- `directUploadFailed`
- `confirming`
- `confirmFailed`
- `binding`
- `bindFailed`
- `bindSucceeded`
- `unsupportedType`

因此本轮允许在 Flutter 内把“选择文件后再点上传”收敛为“选择文件后自动上传”，但必须复用现有三步流和失败重试能力。

自动上传边界：

- 选择文件时记录当时资料类型。
- 上传绑定使用附件自己的资料类型，不使用当前选中态兜底。
- 上传失败不得丢失待上传文件。
- 上传成功后自动刷新正式附件列表。
- 删除、预览、系统打开、更多 / 高级信息能力必须保留。

## 5. 预览能力冻结

当前能力与本轮冻结：

- 图片：优先 App 内图片弹窗预览；远程图片读取失败时走外部链接兜底。
- PDF：申请 preview 链接后下载为临时文件，并复用既有 `open_filex` 本地文件打开能力；不新增独立 PDF 渲染器。
- DOCX / XLSX：申请 preview 链接后下载为临时文件，并复用既有 `open_filex` 本地文件打开能力；不新增 Office 渲染依赖。
- 其他文件：按现有 MIME 能力走 preview 或 download 链接，不新增重型依赖。

按钮语义：

- 预览：图片走 App 内图片弹窗；PDF / DOCX / XLSX 等文件走本地临时文件打开能力。
- 打开：调用系统能力或外部应用打开。

## 6. 手机适配验收

- 标准手机宽度下主内容不得横向滚动。
- 长文件名必须单行省略。
- 极窄屏下操作图标可收进“更多”，不得挤压文件名。
- 统计筛选 pill 可横向滑动，不得文字重叠。
- bottom nav 不得遮挡刷新、提示、附件行或发布前待办。
- 标题中的括号说明可缩小或换行，但不得遮挡“预览项目”。

## 7. 进入实现判断

本轮允许进入 Flutter 实现。

原因：

- 自动上传可复用现有 Flutter 上传状态和三步流。
- 正式附件紧凑化只影响展示层。
- 预览能力不新增依赖，只按现有能力分级展示。
- 无需 BFF / Server / contracts / 数据库改动。
