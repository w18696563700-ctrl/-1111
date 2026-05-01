---
owner: Codex 总控
status: frozen
purpose: Freeze the bounded Flutter-only UI refinement scope for the project
  creation page.
layer: L5 Flutter App
freeze_date_local: 2026-05-02
---

# Project Create UI Refine Frontend Freeze Addendum

## 1. Day 1 Read-only Truth

| 核查项 | 结论 |
|---|---|
| A. 创建项目页面文件位置 | `apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart`；Round A 表单展示拆在 `apps/mobile/lib/features/exhibition/presentation/widgets/project_create_round_a_widgets.dart`。 |
| B. 发布进度步骤来源 | `_ProjectPublishProgressStep`、`_projectPublishProgressNodes`、`_ProjectPublishProgressCard` 位于 `apps/mobile/lib/features/exhibition/presentation/presentation_support/project_publish_progress_support.dart`。创建页当前固定传 `currentStep: basic`。 |
| C. 基础信息字段来源 | 展会、品牌、项目类型、预算金额、项目面积、类型备注来自 `ProjectCreatePage` 内对应 `TextEditingController`，由 `_buildProjectCreateRoundABody` 消费。 |
| D. 报价方式字段来源 | 报价意向为本地 `_p0PayTaskType`，取值为 `fixed_price_bid` / `inquiry_quote`，仅连接 P0-Pay 意向选择，不进入 `ProjectCreateCommand.toJson()`。 |
| E. 地区选择联动逻辑 | `showChinaCityPicker` 选择省 / 市后写入 `_selectedStandardizedLocation`、省、市 controller；区/县从所选城市 `districts` 二次选择，缺上级时只提示，不本地伪造地区。 |
| F. 保存按钮真实行为 | 新建页调用 `createProject`，成功后如有 `projectId` 跳转 `ExhibitionRoutes.myProjectDraftboxWithProjectId(projectId)`，即我的项目草稿箱；无 `projectId` fallback 到我的发布草稿列表。 |
| G. 草稿保存能力 | 有。新建页创建成功状态为草稿承接；编辑页 draft 状态支持 `仅保存草稿` 和 `保存到预发布列表`。 |
| H. 预发布路由 | 无新增预发布独立路由。预发布以 `submitted` 状态和我的项目详情 / 编辑页承接。 |
| I. bottom nav 遮挡 | 当前 shell 使用 Scaffold `bottomNavigationBar`，不是覆盖 body；创建页 `ListView` 底部仍需保留足够 padding，确保主按钮滚动到导航栏上方。 |
| J. 相关测试文件 | `apps/mobile/test/project_publish_round_a_productization_test.dart`、`apps/mobile/test/project_showcase_filter_create_refactor_test.dart`、`apps/mobile/test/shell_app_test.dart`、`apps/mobile/test/my_project_private_carry_test.dart`、`apps/mobile/test/exhibition_mainline_flow_test.dart`。 |

## 2. Execution Boundary

本轮只允许修改 Flutter 展示层：

1. `project_create_page.dart`
2. `project_create_round_a_widgets.dart`
3. `project_publish_progress_support.dart`
4. 必要的通用 Flutter 表单 / frame widget
5. 对应 Flutter tests / screenshots

本轮不修改：

1. BFF / Server / OpenAPI / database
2. `ProjectCreateCommand` / `ProjectSaveCommand` 的接口字段
3. 项目发布状态机
4. bottom nav 路由
5. 附件上传、支付、确认发布真实入口

## 3. UI Freeze

创建页改成项目发布向导观感：

1. 保留返回按钮和标题 `创建项目`。
2. 不新增右上角“说明”入口。
3. 发布进度为不可点击横向流程预告：`基础信息 / 报价依据资料 / 诚意金 / 确认发布 / 已发布`。
4. 当前步骤提示卡显示：`正在填写项目基础信息`，说明保存后进入我的项目草稿箱，后续按真实状态进入预发布核对。
5. 基础信息、项目地点与范围、计划时间继续分区展示。
6. 报价方式继续只作为 `fixed_price_bid` / `inquiry_quote` 的本地意向选择，不进入项目创建接口。
7. 地区锁定态弱化为说明态：未选择上级时提示 `请先选择省 / 市`。
8. 底部按钮文案按真实跳转冻结为 `保存并查看我的项目`，不写 `保存并进入预发布`。
9. 按当前 contract 事实，`budgetAmount` 仍是 `ProjectCreateCommand` 必填字段；询价态本轮只保持视觉红星不显示，不在本轮绕过接口字段。

## 4. Validation Boundary

本轮验收必须证明：

1. 所有现有字段保留。
2. 保存按钮仍调用原 `createProject` 并跳转我的项目草稿箱。
3. 报价方式仍只改变 `_p0PayTaskType`，不进入 `ProjectCreateCommand`。
4. 地区联动逻辑保持不变。
5. 不新增可点击假步骤、假入口、假支付、假上传。
