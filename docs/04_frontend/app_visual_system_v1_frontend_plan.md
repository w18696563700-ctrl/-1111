---
owner: Frontend Agent
status: frozen
layer: L5 Frontend
scope: App Visual System V1
---

# App 视觉系统 V1 前端施工计划

## 1. Day 1 盘点结论

首发可见楼：

- `AppBuilding.exhibition`
- `AppBuilding.messages`
- `AppBuilding.profile`

预埋隐藏楼：

- `AppBuilding.renovation`
- `AppBuilding.customFurniture`

真实入口依据：

- `apps/mobile/lib/shell/navigation/app_building.dart`
- `apps/mobile/lib/shell/shell_page.dart`
- `apps/mobile/lib/shell/navigation/app_router.dart`
- `apps/mobile/lib/shell/presentation/app_shell_scaffold.dart`

修改前截图：

- `docs/04_frontend/screenshots/app_visual_system_v1_day1_before_exhibition_home.png`
- `docs/04_frontend/screenshots/app_visual_system_v1_day1_before_project_showcase.png`
- `docs/04_frontend/screenshots/app_visual_system_v1_day1_before_project_detail.png`
- `docs/04_frontend/screenshots/app_visual_system_v1_day1_before_messages.png`
- `docs/04_frontend/screenshots/app_visual_system_v1_day1_before_profile.png`

## 2. 页面类型矩阵

首页 / 频道页：

- 展览首页
- 消息互动中心
- 我的页
- 论坛频道
- 企业展示频道

列表页：

- 项目展示
- 我的项目
- 企业 / 工厂 / 供应商列表
- 论坛 feed / 话题 / 草稿
- 我的论坛集合

详情页：

- 项目详情
- 我的项目详情
- 企业详情
- 论坛详情
- 个人资料 / 公司资料 / 认证详情

表单页：

- 登录页
- 项目创建 / 编辑
- 竞标提交
- 企业展示工作台
- 论坛发布
- 组织 / 认证 / 密码页

状态流页：

- 参与竞标申请
- 项目名称查看申请
- 企业申请状态
- 支付 / 账单 / 信用只读状态页

空状态 / 未登录页：

- Shell 阻断态
- 路由不可用页
- 预埋楼骨架
- 消息空态
- Profile 未登录态

## 3. 现有视觉资产

已有全局主题：

- `apps/mobile/lib/shared/theme/app_theme.dart`

已有展览首页局部 token：

- `apps/mobile/lib/features/exhibition/presentation/exhibition_home_visual_tokens.dart`

已有最小视觉规范页：

- `apps/mobile/lib/features/exhibition/presentation/pages/minimal_visual_spec_page.dart`

V1 要求：

- 保留 `AppTheme.light()` 作为全局主题入口。
- 新增 App 级 token，逐步替代页面私有色值。
- 展览首页局部 token 后续迁移到 App 级 token；本轮不强行大规模替换。

## 4. 第一批迁移范围

第一批只迁移：

1. 我的页未登录卡 / 登录页。
2. 参与竞标申请 / 项目名称查看申请状态页。
3. 项目展示列表页。

不迁移：

- 展览首页。
- 项目详情。
- 我的项目。
- 消息楼。
- 企业 / 工厂 / 供应商详情。
- 装修、全屋定制隐藏楼页面。

## 5. 前端文件许可边界

允许新增或修改：

- `apps/mobile/lib/shared/ui/**`
- `apps/mobile/lib/shared/theme/app_theme.dart`
- `apps/mobile/lib/features/profile/presentation/**`
- `apps/mobile/lib/features/exhibition/presentation/pages/project_name_access_thread_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/project_list_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/widgets/project_showcase_card_widgets.dart`
- 相关 Flutter test

禁止修改：

- `apps/bff/**`
- `apps/server/**`
- `docs/01_contracts/openapi.yaml`
- 数据库 migration
- 业务状态机
- 业务路由规则

## 6. 验收口径

每批交付必须输出：

- `changed_files`
- token / 组件新增清单
- 已迁移页面
- 未迁移页面
- 是否触碰隐藏楼页面
- Flutter analyze / test 结果
- 页面截图路径
- 窄屏截图路径
- 底部导航遮挡检查
- 横向裁切检查
- 下一批建议迁移页面
