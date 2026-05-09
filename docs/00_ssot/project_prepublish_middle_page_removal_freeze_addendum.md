# 预发布中间页移除冻结 Addendum

状态：本轮冻结

## 1. 本轮最小闭环

本轮只收敛 Flutter 前端展示层和路由承接：

- 删除的是 `ProjectCreatePage(projectId)` 在 `submitted` 状态下形成的 `编辑项目 预发布列表` 中间页体验。
- 不删除“我的项目”中的 `预发布列表` 阶段。
- 不删除 `submitted` 状态。
- 不改 BFF / Server / OpenAPI / contracts / 数据库 / 项目状态机 / 云端 runtime。

运行结构仍按当前总控口径执行：

- 本地只运行 Flutter 前端。
- BFF / Server 在阿里云。
- 本地联调统一通过 SSH 隧道访问 `http://127.0.0.1:8080`。
- 不把本地 3000 / 3001 当作真实 BFF / Server。

## 2. 页面职责冻结

| 页面 / 阶段 | 状态 | 职责 |
| --- | --- | --- |
| 草稿编辑页 | `draft` | 只负责基础信息、项目地点、计划时间、补充说明等草稿态编辑，并提交进入预发布。 |
| 我的项目预发布列表 | `submitted` 列表分组 | 只作为列表阶段和入口，不是功能页。 |
| 预发布补资料并发布页 | `submitted` 详情 | 唯一负责报价依据资料、诚意金绿色通道表态、确认发布。 |

`ProjectCreatePage(projectId)` 不再承接 `submitted` 主流程；如果旧深链打开到 `submitted`，只能做轻量兜底跳转或提示，不得展示补资料 checklist、发布主流程、诚意金绿色通道或完整中间页。

## 3. 按钮去向冻结

| 入口 / 按钮 | 当前真实去向 | 本轮冻结去向 |
| --- | --- | --- |
| 草稿列表 `继续编辑` | `projectEditWithProjectId` | 保持，进入草稿编辑页。 |
| 草稿编辑页 `确认保存并进入预发布信息补充页` | 现有 submit/save action | 成功返回 `submitted` 后直接进入 `myProjectDetailWithProjectId`。 |
| 预发布列表卡片 `补资料后确认发布` | `myProjectDetailWithProjectId` | 保持，进入预发布补资料并发布页。 |
| 预发布补资料页 `返回草稿继续编辑` | 现有 withdraw action | 成功后回读编辑详情；回读为 `draft` 才进入 `projectEditWithProjectId`。 |

## 4. 不做事项

本轮不做：

- 不改 BFF。
- 不改 Server。
- 不改 OpenAPI / contracts。
- 不改数据库 / migration。
- 不改项目状态机。
- 不改保存草稿、提交预发布、正式发布、撤回、作废、归档真实 action。
- 不新增 mock 状态。
- 不新增接口字段。
- 不伪造云端回读状态。
- 不删除上传、预览、打开、移除、刷新、诚意金表态、确认发布等既有能力。

## 5. 兼容和降级

- 如果 `ProjectCreatePage(projectId)` 被旧深链打开且云端回读状态为 `submitted`，页面不得崩溃。
- 该场景只允许轻量提示“项目已进入预发布补资料并发布页”，并提供进入 `myProjectDetailWithProjectId` 的真实路由。
- 如需自动跳转，必须仍保留安全兜底，不得循环跳转。
- 如果撤回到草稿后云端短时间仍回读 `submitted`，Flutter 不得强行伪造 `draft`；应停留并提示稍后刷新。

## 6. 验收标准

本轮验收必须满足：

- 草稿继续编辑仍进入草稿编辑页。
- 草稿编辑提交成功后直接进入预发布补资料并发布页。
- 不再出现 `编辑项目 预发布列表` 中间页。
- `ProjectCreatePage submitted` 不再展示报价依据资料 checklist 或补资料主流程。
- 预发布补资料并发布页是唯一补资料与发布页。
- `返回草稿继续编辑` 成功后进入草稿编辑页。
- 不改接口、不改状态机、不改云端。

## 7. Gate 结论

本轮允许进入 Flutter 前端最小收敛，前提是：

- 只改本 addendum、Flutter 展示/路由承接和相关测试断言。
- BFF / Server / contracts / OpenAPI / 数据库保持只读确认。
- 验收时必须明确当前仓库已有非本轮 dirty files，不能误归因。
