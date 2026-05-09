# My Project ProjectCreatedAt Display Field Freeze Addendum

## 1. 本轮最小闭环

本轮只冻结并打通 `我的项目` 列表展示项目创建时间的最小闭环：

- 字段名：`projectCreatedAt`
- 类型：`string`
- format：`date-time`
- 真源：`Server Project.createdAt`
- 作用：仅用于 `我的项目` 列表展示项目创建时间

`projectCreatedAt` 是 app-facing 展示字段，不代表保存时间、更新时间、草稿更新时间或最近操作时间。
为兼容 Server 读侧尚未部署新字段的窗口期，BFF app-facing carrier 可返回 `null`；`null` 只表示真源暂未返回，不是业务时间。

## 2. 展示降级规则

- 当 `projectCreatedAt` 存在且可解析时，Flutter 展示：`创建时间：YYYY-MM-DD HH:mm`
- 当 `projectCreatedAt` 未返回、为空或不可解析时，Flutter 展示：`创建时间暂未返回`

Flutter、BFF 均不得用当前时间、`updatedAt`、`savedAt` 或其它非冻结字段兜底。

## 3. 报价依据资料草稿态文案冻结

草稿态轻量提示卡固定为：

- 标题：`报价依据资料`
- 说明：`当前处于草稿阶段，需先确认保存到预发布列表；进入预发布列表后，可继续补充报价依据资料。`

该文案只解释现有流程，不新增上传能力、不改变报价依据资料规则。

## 4. 分层边界

### Server

- 仅在 `/server/my/projects` 读侧输出 `projectCreatedAt`
- 映射来源为 `Project.createdAt.toISOString()`
- 不改数据库结构
- 不改创建项目逻辑
- 不改保存草稿 / 提交预发布逻辑

### BFF

- 仅在 `/api/app/my/projects` 透传 / 整形 `projectCreatedAt`
- 不创造业务真值
- 不使用当前时间兜底
- Server 未返回时返回 `null`，由 Flutter 展示降级文案

### Flutter

- 我的项目草稿卡片展示创建时间
- 替换旧的 `已保存到草稿箱` 高亮文案
- 不新增假字段
- 不修改按钮 action

## 5. 本轮不做事项

- 不新增 `savedAt`
- 不新增 `updatedAt`
- 不改已有状态枚举
- 不改数据库 migration
- 不改项目状态机
- 不改保存逻辑
- 不改提交逻辑
- 不改报价依据资料规则
- 不改支付或诚意金规则
- 不做云端部署

## 6. 验收标准

- OpenAPI / generated contracts 包含 `MyProjectListItemReadModel.projectCreatedAt`
- Server presenter 从 `Project.createdAt` 输出 ISO 字符串
- BFF read model 返回 `projectCreatedAt`，缺失时不造值
- Flutter 草稿卡显示 `创建时间：YYYY-MM-DD HH:mm` 或 `创建时间暂未返回`
- 报价依据资料草稿态提示文案与本 addendum 一致
