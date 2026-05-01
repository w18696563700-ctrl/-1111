---
owner: Codex 总控
status: completed
purpose: Record the Flutter-only execution result for the project create UI
  refinement round.
layer: L5 Flutter App
---

# Project Create UI Refine Execution Receipt

## Scope Result

本轮只执行 Flutter 展示层精修：

1. 创建页增加不可点击发布流程 stepper：基础信息 / 报价依据资料 / 诚意金 / 确认发布 / 已发布。
2. 当前步骤提示改为“正在填写项目基础信息”，并说明真实承接为我的项目草稿箱后续继续核对。
3. 报价意向明价 / 询价改为稳定单行 segmented control。
4. 输入框统一圆角、边框、填充和高度观感。
5. 底部主按钮改为真实跳转文案“保存并查看我的项目”，并增加 safe-area 留白与轻提示。
6. 创建页仍隐藏补充说明与附件；补充资料继续在草稿 / 预发布承接链路出现。

## Non-changes

本轮未修改：

1. BFF
2. Server
3. OpenAPI
4. database
5. 项目发布状态机
6. `ProjectCreateCommand` / 创建接口字段
7. bottom nav 路由
8. 附件、支付、正式发布真实业务入口

## Validation

| 命令 | 结果 | 说明 |
|---|---|---|
| `flutter analyze` | 未通过 | 剩余 40 项均为既有 lint / warning，未出现本轮创建页展示文件新增 error。 |
| `flutter test test/project_publish_round_a_productization_test.dart` | 通过 | 9 tests passed。 |
| `flutter test test/project_showcase_filter_create_refactor_test.dart` | 通过 | 12 tests passed。 |
| `flutter test test/shell_app_test.dart --name "project create"` | 通过 | 9 tests passed。 |
| `flutter test test/my_project_private_carry_test.dart` | 通过 | 19 tests passed。 |
| `flutter test test/project_create_ui_refine_capture_test.dart` | 通过 | 2 screenshots passed。 |
| `flutter test test/exhibition_mainline_flow_test.dart` | 未通过 | 创建入口相关用例通过；后续失败在项目详情 / 竞标链路，非本轮创建页展示改动范围。 |

## Screenshots

1. 常规宽度：
   `/Users/wangweiwei/Desktop/展览装修之家总控/.tmp/agent_reports/project_create_ui_refine/20260502/project_create_regular_top.png`
2. 窄屏底部按钮：
   `/Users/wangweiwei/Desktop/展览装修之家总控/.tmp/agent_reports/project_create_ui_refine/20260502/project_create_narrow_bottom.png`

## Acceptance Notes

1. 所有现有字段保留。
2. 保存按钮仍调用原 `createProject` 并跳转我的项目草稿箱 / 我的项目草稿阶段。
3. 报价方式仍只改变本地 `_p0PayTaskType`，不进入 `ProjectCreateCommand`。
4. 地区联动逻辑保持不变。
5. 未新增可点击假步骤、假入口、假支付、假上传。
6. 询价态预算红星继续不显示；预算是否真正可空仍受现有创建接口 `budgetAmount` 必填事实约束，未在本轮绕过。
