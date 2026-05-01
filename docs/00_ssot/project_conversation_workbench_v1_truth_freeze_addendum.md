---
owner: Codex 总控
status: accepted
purpose: Freeze Project Conversation Workbench V1 truth, message types, attachment truth, confirmation-card boundary, and in-app soft reminder scope.
layer: L0 SSOT
---

# 《项目沟通工作台 V1 施工真相冻结》

## 1. 结论

项目沟通工作台 V1 是挂在 `projectId + threadId` 上的项目工作沟通页面，不是微信式聊天、不是通用私信、不是消息楼总框聊天容器。

本轮正式目标是把当前项目沟通页升级为“项目 + 投标关系”的工作沟通台，并让图片、附件、确认卡成为真实项目沟通消息类型。所有能力必须继续围绕项目归属、双方身份、平台内留痕、关键确认沉淀展开。

## 2. 当前问题

1. 当前项目沟通页上半区和消息流之间割裂，视觉上像低配 IM。
2. 消息流缺少头像、身份标签和双方主体感。
3. `聊天` 语义过泛，不能表达项目工作沟通和平台留痕。
4. 图片 / 附件 / 确认入口如果只做假按钮，会继续削弱平台专业度。
5. 现有 `project_communication_messages` 仅承载文本 `body`，缺少结构化消息 payload。
6. 上传链路已有 `FileAsset` 和 `init -> direct upload -> confirm`，不应另造上传体系。

## 3. 本轮最小闭环

本轮只允许完成以下闭环：

1. 项目沟通页 UI 升级为项目沟通工作台 V1。
2. 消息仍强制绑定 `projectId + threadId`。
3. 消息类型冻结为：
   - `text`
   - `image`
   - `file`
   - `confirmation_card`
4. 图片和附件必须先通过既有三步上传形成 `FileAsset`，再作为项目沟通消息 payload 发送。
5. 附件 / 图片消息只引用 `fileAssetId` 作为业务真值。
6. `objectKey` 只属于上传传输层和存储层，不得进入项目沟通业务真值。
7. 确认卡作为“消息级工作确认卡”落在项目沟通消息流中。
8. 联系方式提醒只做 App 内软提醒，不做封禁、不做处罚、不做 Server 风控。

## 4. 明确不做

本轮不做：

- 通用 IM / 私信 / 群聊
- 消息楼总框聊天
- 系统级 push
- 声音 / 震动 / 锁屏通知
- 跨楼层通知中心
- 复杂通知设置
- 消息撤回
- 已读回执列表
- 语音 / 视频消息
- 文件在线编辑
- 确认卡驱动订单、合同、履约状态机
- 风控封禁、风控处罚、客服仲裁台
- 通过关键词拦截联系方式发送

## 5. 消息类型真相

### 5.1 `text`

文本消息继续使用既有 `body` 字段。

- `messageKind = text`
- `body` 必填
- `payload` 可为空
- 继续参与 unread / read cursor / realtime event

### 5.2 `image`

图片是项目沟通附件的一种展示形态，不另造图片上传体系。

- `messageKind = image`
- `body` 是可选说明或空字符串
- `payload.attachment.fileAssetId` 必填
- `payload.attachment.category = image`
- `payload.attachment.mimeType` 必须是图片 mime
- `payload.attachment.fileName`、`size` 用于 App 展示

### 5.3 `file`

文件是项目沟通附件的一种展示形态。

- `messageKind = file`
- `body` 是可选说明或空字符串
- `payload.attachment.fileAssetId` 必填
- `payload.attachment.category = file`
- `payload.attachment.fileName`、`mimeType`、`size` 用于 App 展示

### 5.4 `confirmation_card`

确认卡是项目沟通消息流中的“工作确认卡”，不是订单、合同、履约状态机。

本轮只允许三种确认卡：

- `quote`: 报价确认
- `material_process`: 工艺 / 材质确认
- `schedule`: 排期确认

确认卡 payload：

- `confirmationType`
- `title`
- `summary`
- `status`

本轮 `status` 只表达消息卡片展示状态，默认 `proposed`。不得据此改变订单、审核、合同或履约状态。

## 6. 附件与上传真相

1. 项目沟通图片 / 附件上传复用既有三步：
   - `init`
   - direct upload
   - `confirm`
2. 上传完成后，Server 生成 `FileAsset`。
3. 项目沟通消息只绑定 `fileAssetId`。
4. `FileAsset.businessType` 必须为 `project`。
5. `FileAsset.businessId` 必须等于当前消息所属 `projectId`。
6. `FileAsset.fileKind` 必须为 `project_communication_attachment`，不得复用项目相册 `project_album_photo` 或 owner-private `project_attachment` 语义。
7. `FileAsset.organizationId` 必须属于当前发送方组织。
8. 发送消息时必须校验发送方是该 `projectId + threadId` 的参与方。
9. 禁止把 OSS `objectKey` 当作业务字段输出给项目沟通消息流。

## 7. 项目沟通工作台 UI 真相

项目沟通页从上到下固定为：

1. 顶部导航栏
2. 会话对象信息区
3. 项目动作区
4. 平台倡议提示条
5. 消息流
6. 底部输入与动作区

页面表达目标：

- 一眼知道是谁在跟谁沟通。
- 一眼知道沟通归属哪个具体项目。
- 一眼知道平台建议优先在平台内沟通。
- 一眼知道图片、附件、确认卡都属于当前项目沟通。

## 8. 身份与头像来源

会话对象信息和消息流头像按以下顺序展示：

1. 企业 logo
2. 人物头像
3. 默认首字母 / 占位头像

Flutter 可以根据 `senderOrganizationId` 与当前 thread 的 `ownerOrganizationId` / `counterpartOrganizationId` 映射左右身份。若某一侧头像或企业 logo 暂无结构化字段，允许显示默认头像，不允许从 summary 字符串里猜身份。

## 9. 联系方式软提醒

联系方式提醒只在 App 端执行本地检测。

触发内容包括：

- 手机号
- 微信号
- QQ
- `联系我`
- `加我`
- `电话多少`

弹窗文案冻结为：

标题：

> 建议优先在平台内继续沟通

正文：

> 平台内沟通更便于留存关键记录，报价、材质、排期等事项建议优先保留在项目沟通中。

按钮：

- 返回修改
- 继续发送

软提醒不是封禁弹窗。用户点击“继续发送”后，App 必须允许发送原内容。

## 10. 分层职责

| Layer | Responsibility |
| --- | --- |
| Server | 项目沟通消息真值、FileAsset 校验、确认卡 payload 校验、审计、read cursor |
| BFF | App-facing shape 校验、错误归一、Server 透传、上传编排入口复用 |
| Flutter | 工作台 UI、文件/图片选择、三步上传调用、确认卡表单、软提醒弹窗 |
| OSS | 传输和对象存储，不拥有业务真值 |

## 11. 门禁

下一阶段进入 Server 实现前必须满足：

- 本文已登记为 L0 SSOT。
- L2 contracts 已冻结。
- 阶段门禁核查表明确允许 Day 2。
- 任何实现不得突破“不做通用 IM、不做系统通知、不接订单状态机”的边界。
