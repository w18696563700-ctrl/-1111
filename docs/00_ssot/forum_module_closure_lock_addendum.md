---
owner: Codex 总控
status: frozen
closure_type: module_closure_lock
layer: L0 SSOT
scope:
  - forum app-facing routes
  - forum Flutter surfaces
  - forum BFF forwarding
  - forum Server business truth
  - forum attachment preview reuse
effective_local_date: 2026-05-05
purpose: >
  Record the Forum module closure lock after the current route matrix, posting,
  my-post management, interaction inbox, author profile, comment, like,
  bookmark, report, draft, and published attachment preview loops reached the
  current minimum closed state. This file blocks future opportunistic Forum
  changes unless a formal reopening gate is approved first.
---

# 论坛模块收口锁定 Addendum

## 1. 总裁决

论坛模块在当前阶段正式收口。

本文件的结论是：

- `Go` for freezing the current Forum module as maintenance-only.
- `No-Go` for any future Agent continuing to add, redesign, rename, reshape, or
  refactor Forum functionality by default.
- Any future work touching Forum must first open a new SSOT reopening gate,
  explain the business necessity, define exact file scope, and pass contracts /
  runtime truth checks where relevant.

本文件不是新功能授权，不替代 OpenAPI，不批准继续施工，不允许用“顺手修一下”绕过阶段门禁。

## 2. 当前最小闭环

当前论坛最小闭环冻结为：

| 能力 | 当前冻结状态 | 真源 |
| --- | --- | --- |
| 论坛列表 / 分类 / 本地 / 关注 | 已形成当前读侧闭环 | BFF `/api/app/forum/*` -> Server Forum |
| 发帖草稿编辑 | 已形成保存草稿闭环 | Server draft truth |
| 草稿箱发布 | 已形成从草稿发布到帖子详情闭环 | Server publish truth |
| 帖子详情 | 已形成正文、作者、互动、评论、附件图片区闭环 | Server post detail + shared file access |
| 正文图片 / 附件查看 | 已形成真实 FileAsset 读取闭环 | `FileAsset` + `/api/app/file/access` |
| 我的帖子 | 已形成查看、编辑、删除已发布帖闭环 | Server owner post truth |
| 我的评论 / 收藏 / 点赞 / 关注 | 已形成当前资产读侧闭环 | Server my-asset projections |
| 作者主页 | 已形成公共作者资料和公开帖子读侧闭环 | Server author projections |
| 评论 | 已形成默认前 10 条、继续加载、一级评论写链闭环 | Server comment truth |
| 点赞 / 收藏 / 关注 | 已形成真实 toggle 或受控提示闭环 | Server interaction truth |
| 举报 | 已形成提交和我的举报记录读侧闭环 | Server report ticket truth |
| 消息楼里的论坛互动入口 | 已形成当前 bounded inbox 入口 | Server forum interaction inbox |

当前最小闭环到此为止，不继续扩大。

## 3. 禁改范围

除非新的 reopening gate 明确批准，后续开发不得改动以下范围：

- `docs/00_ssot/*forum*`
- `docs/01_contracts/*forum*`
- `docs/02_backend/*forum*`
- `docs/03_bff/*forum*`
- `docs/04_frontend/*forum*`
- `docs/01_contracts/openapi.yaml` 中 `/api/app/forum/*`、Forum schemas、Forum attachment refs
- `packages/contracts/**` 中 Forum generated projection
- `apps/mobile/lib/features/exhibition/data/forum_*`
- `apps/mobile/lib/features/exhibition/presentation/forum/**`
- `apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart` 中 Forum route registration
- `apps/mobile/lib/shell/navigation/app_router.dart` 中 Forum route registration
- `apps/bff/src/routes/forum/**`
- `apps/server/src/modules/forum/**`
- Forum 依赖的 shared file-access branch, only when the change affects Forum attachment preview semantics

禁止把论坛需求夹带进消息、项目沟通、首页推荐、个人中心、附件、通知等相邻模块的施工里。

## 4. 禁止继续开发的事项

后续开发默认不得做：

- 新增论坛 tab、频道、话题、标签、推荐流、搜索排序或榜单规则。
- 新增私信、群聊、泛 IM、作者主页社交能力或组织主页社交能力。
- 新增论坛审核、治理、处罚、申诉、举报处理动作或 Admin 工作台。
- 新增浏览数、热度、推荐分、虚拟数据、假封面、假回复数、假点赞数、假作者资产。
- 改论坛状态机、草稿状态、发布状态、删除状态、评论状态、举报状态。
- 改 `/api/app/forum/*` path、request、response、enum、error-code 语义。
- 改 Forum BFF 为业务真源，或让 Flutter 直连 Server。
- 做大规模 UI 重构、视觉再精修、卡片体系再抽象、文案大改、页面命名重排。
- 为了相邻模块施工顺手改论坛入口、论坛红点、论坛资产页、论坛详情页。
- 用本地 mock、截图、测试 fixture 代替云端真实 runtime 结论。

## 5. 允许的维护例外

论坛收口后只允许以下维护进入评估：

| 类型 | 是否允许 | 前置条件 |
| --- | --- | --- |
| P0 崩溃 | 条件允许 | 只修崩溃，不改变业务语义 |
| 安全 / 权限漏洞 | 条件允许 | 先记录风险、影响面、修复边界 |
| 云端 runtime 与已冻结合同不一致 | 条件允许 | 先给只读证据，再最小修复 |
| 已发布链路不可用 | 条件允许 | 只恢复既有闭环，不新增能力 |
| 图片 / 附件读取失败 | 条件允许 | 只恢复 FileAsset 访问，不新增媒体能力 |
| 文案错别字 | 默认不允许 | 只有误导业务语义或验收缺陷时可开维护单 |
| 视觉微调 | 默认不允许 | 只有遮挡、不可点击、空白、溢出等缺陷可修 |
| 新业务需求 | 不允许直接进入 | 必须另开完整 SSOT / contracts / implementation gate |

维护例外不得批量重构，不得夹带新功能。

## 6. 保留但暂不开通

以下能力保留为后续扩展位，但当前冻结为不开通：

- 话题关注、机构关注、标签关注、推荐算法。
- 作者主页深度社交关系、私信、黑名单增强、互动关系图。
- 论坛内容治理后台、举报处理流、处罚、申诉。
- 浏览量、热度榜、推荐频道、内容分发策略。
- 富文本编辑器、正文内多媒体排版、视频内嵌播放、PDF/Office 内嵌渲染。
- 论坛与项目交易链路的深度绑定。
- 论坛商业化、会员权益、付费内容、广告位。

这些扩展位必须另开冻结方案，不能从当前收口记录直接施工。

## 7. Reopening Gate

任何触碰论坛的后续工作必须先提交 reopening gate，至少包含：

1. 为什么当前维护冻结不足以满足目标。
2. 本轮是否涉及 Flutter、BFF、Server、OpenAPI、generated contracts、数据库、云端部署。
3. 精确文件范围和禁止触碰范围。
4. 是否改变 `/api/app/forum/*` 或 Forum schemas。
5. 是否改变 Server 业务真相、状态机、权限、审计、治理。
6. 是否需要云端读写 smoke，是否会写真实业务数据。
7. 回滚路径和验收证据。
8. 明确 Go / No-Go 裁决。

未完成 reopening gate 前，Forum 相关改动一律 `No-Go`。

## 8. 四类判断

| 判断项 | 结论 |
| --- | --- |
| 哪个更稳 | 论坛进入 maintenance-only，只保留 P0 / 安全 / runtime drift / 既有闭环不可用修复 |
| 哪个更省成本 | 不再继续做论坛 UI 精修、功能扩展、字段补齐和接口重排 |
| 哪个更适合当前阶段 | 把后续资源转向消息楼、项目沟通、竞标、合作确认等主链路，不让论坛继续占用施工窗口 |
| 哪个风险最大 | 在无 reopening gate 的情况下继续改论坛代码、合同、路由、状态或云端运行逻辑 |

## 9. 后续 Agent 操作口令

后续 Agent 如遇论坛相关需求，默认回复口径应为：

> 论坛模块已于 `2026-05-05` 进入收口冻结。除 P0 崩溃、安全漏洞、runtime drift、既有闭环不可用等维护例外外，任何论坛改动必须先提交并通过新的 SSOT reopening gate；未通过前不得改代码、合同、数据库或云端。
