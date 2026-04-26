# 《消息楼简化收口 Day5 联调、截图与阶段收口记录》

## 1. 文书定位

本文为消息楼简化收口 Day5 的阶段验收记录。

本文只记录本轮事实：

- Flutter 展示层联调结果
- 本地隧道到云上 BFF 的真实入口预览结果
- 修改前后截图证据
- 测试结果与已知红灯
- 本轮提交清单边界

本文不解锁新的业务功能，不修改 BFF / Server / OpenAPI / 数据库 / 状态机。

## 2. 当前最小闭环

当前 Day5 最小闭环为：

1. 真实 App 入口 `/messages` 可通过本地 Flutter macOS App 打开。
2. AppBar 标题显示为 `互动中心`。
3. 页面内容区不再保留页内说明文案。
4. 页面内容区保留两个入口框：
   - `项目沟通`
   - `论坛互动`
5. `项目沟通` 入口已压缩为轻量入口卡：
   - 展示对方主体公司名
   - 展示项目数量
   - 保留 `进入项目沟通`
   - 隐藏头像、昵称、聊天摘要、重复竞标沟通信息
6. `论坛互动` 与 `项目沟通` 统一为入口框表达，保留：
   - `回复我的`
   - `收到的赞`
   - `新关注`
7. 底部导航保持不变：
   - `展览`
   - `消息`
   - `我的`

更稳：当前只收口消息楼展示层和入口表达，不把论坛、聊天、项目详情能力重构混入本轮。

更省成本：复用现有 `MessagesPage`、`MessagesConsumerLayer`、`ForumConsumerLayer` 与现有路由跳转，只调整展示结构。

更适合当前阶段：先把消息楼从“聊天详情 + 论坛列表 + 项目卡混杂”收口成“平台消息中心入口”，不扩大消息系统能力。

风险更大：把当前工作区内的 Server displayName truth、BFF transport test、展览会话切片和消息楼 UI 一起打包成一个 Day5 全通过结论。

## 3. 修改前后截图

修改前截图：

- `docs/04_frontend/screenshots/messages_center_day1_before.png`

修改后真实入口截图：

- `docs/04_frontend/screenshots/messages_center_day5_after_real_entry.png`

截图对比结论：

- 修改前：页内标题 `互动中心` 与说明文案占据顶部；项目沟通像详情卡，头像、昵称、聊天摘要、重复标签造成社交聊天误读。
- 修改后：`互动中心` 上移为 AppBar 标题；内容区只保留 `项目沟通` 与 `论坛互动` 两个入口框；项目沟通高度明显降低，入口属性更清楚。

## 4. 隧道与真实入口联调

隧道状态：

```bash
nc -z 127.0.0.1 8080
```

结果：

- `127.0.0.1:8080` 可连接。

BFF 真实在线检查：

```bash
curl -i http://127.0.0.1:8080/health/bff/live
```

结果：

- `200 OK`
- `service=exhibition-bff`

消息接口未登录访问检查：

```bash
curl -i "http://127.0.0.1:8080/api/app/message/interactions?lane=project_communication"
```

结果：

- `401 AUTH_SESSION_INVALID`
- 说明当前 route 进入 BFF auth gate，不是 nginx 404，也不是前端假数据。

Shell context 未登录访问检查：

```bash
curl -i http://127.0.0.1:8080/api/app/shell/context
```

结果：

- `401 AUTH_SESSION_INVALID`
- 返回受控中文登录态提示。

真实 App 入口预览命令：

```bash
APP_INITIAL_ROUTE=/messages apps/mobile/scripts/run_macos_formal.sh
```

结果：

- macOS Flutter App 启动成功。
- Runtime entry mode 为 `ssh_tunnel`。
- BFF base URL 为 `http://127.0.0.1:8080/api/app`。
- Computer Use 验收命中真实消息楼内容态：
  - `互动中心`
  - `项目沟通`
  - `重庆坤特展览展示有限公司`
  - `项目 1 个`
  - `进入项目沟通`
  - `论坛互动`
  - `回复我的`
  - `收到的赞`
  - `新关注`
  - 底部 `展览 / 消息 / 我的`

## 5. Flutter 验证结果

### 5.1 本轮改动文件定向 analyze

命令：

```bash
cd apps/mobile
dart analyze \
  lib/features/messages/presentation/messages_page.dart \
  lib/features/messages/presentation/messages_page_support.dart \
  lib/shell/shell_page.dart \
  test/messages_instance_todo_test.dart
```

结果：

- Pass
- `No issues found`

### 5.2 消息楼定向测试

命令：

```bash
cd apps/mobile
flutter test --no-pub test/messages_instance_todo_test.dart
```

结果：

- Pass
- `8/8`

### 5.3 真实跳转相关回归

命令：

```bash
cd apps/mobile
flutter test --no-pub test/shell_app_test.dart --name "messages interactions jump stably to project communication page"
```

结果：

- Pass
- `1/1`

### 5.4 全量 analyze

命令：

```bash
cd apps/mobile
flutter analyze --no-pub
```

结果：

- Fail
- 当前仍有 `44 issues`
- 主要集中在既有 exhibition/profile/test 辅助文件，包括 `avoid_print`、`unused_element`、`invalid_use_of_protected_member`、既有测试辅助 unused import 等。
- 本轮消息楼改动文件定向 analyze 已通过。

### 5.5 全量 test

命令：

```bash
cd apps/mobile
flutter test --no-pub
```

结果：

- Fail
- 结束状态约为 `471 passed / 121 failed`
- 失败集中在既有 profile/forum/exhibition/golden/capture/路由断言与跨模块测试。
- 本轮消息楼定向测试和项目沟通跳转回归测试均通过。

## 6. 本轮改动文件清单

Day4/Day5 消息楼 UI 收口相关文件：

- `apps/mobile/lib/features/messages/presentation/messages_page.dart`
- `apps/mobile/lib/features/messages/presentation/messages_page_support.dart`
- `apps/mobile/lib/shell/shell_page.dart`
- `apps/mobile/test/messages_instance_todo_test.dart`
- `docs/00_ssot/messages_center_day5_integration_screenshot_and_stage_closure_addendum.md`
- `docs/04_frontend/screenshots/messages_center_day5_after_real_entry.png`

已存在并被引用的修改前截图：

- `docs/04_frontend/screenshots/messages_center_day1_before.png`

## 7. 不纳入本轮 Day5 通过结论的工作区改动

当前工作区还存在其他并行改动，不应混入消息楼 Day5 UI 收口结论：

- `apps/server/src/modules/message_interaction/*`
- `apps/server/test/message-interaction-bid-carry.test.cjs`
- `apps/bff/test/message-interaction-transport.test.cjs`
- `apps/mobile/lib/features/exhibition/**`
- `apps/mobile/lib/shell/navigation/app_router.dart`
- `apps/mobile/lib/shell/presentation/app_shell_scaffold.dart`
- `apps/mobile/test/counterpart_conversation_chat_test.dart`
- `apps/mobile/test/project_name_access_day45_test.dart`
- `apps/mobile/test/shell_app_test.dart`
- `docs/00_ssot/source_of_truth_map.md`
- 其他 counterpart conversation / project album 相关新增文书与截图

这些改动可另行作为 Server displayName truth、BFF transport regression、对方主体会话切片或展览项目相册链路收口，不得在本文中被写成消息楼 Day5 UI 全量通过。

## 8. 阶段门禁核查表

| Gate | 结论 | 证据 |
| --- | --- | --- |
| 真实 App 入口可验收 | Pass | `messages_center_day5_after_real_entry.png` |
| 底部导航不变 | Pass | 截图与 accessibility tree 均显示 `展览 / 消息 / 我的` |
| 项目沟通入口不影响点击进入 | Pass | `messages interactions jump stably to project communication page` 通过 |
| 本轮消息楼定向测试 | Pass | `messages_instance_todo_test.dart` 8/8 |
| 本轮改动文件定向 analyze | Pass | `No issues found` |
| 云上 BFF 隧道可达 | Pass | `/health/bff/live` 返回 `200 OK` |
| BFF/Server 路由不变 | Pass for Day5 | Day5 未修改 BFF / Server 路由；消息接口未登录返回 `401 AUTH_SESSION_INVALID` |
| 全量 Flutter analyze | Fail, non-veto for Day5 | 44 个既有跨模块 issue |
| 全量 Flutter test | Fail, non-veto for Day5 | 471 passed / 121 failed，失败跨 profile/forum/exhibition/golden/capture |

下一阶段允许条件：

- 可以提交本轮消息楼 UI 收口文件，但提交时必须分组，避免把 Server/BFF/展览会话切片混进同一提交。
- 如果要做全仓库质量门禁，则必须另开修复包处理全量 analyze/test 红灯。

## 9. 后续扩展位

当前保留但暂不开通：

- 项目沟通未读数
- 论坛互动未读聚合
- 消息中心搜索
- 通知设置
- 项目沟通多项目聚合排序

以上扩展位当前不得在 Day5 中实现。

## 10. Formal Conclusion

消息楼简化收口 Day5 结论：

1. 本轮消息楼 UI 收口已完成真实入口预览。
2. `互动中心` 已上移到 AppBar。
3. 页内说明文案已移除。
4. `项目沟通` 已从详情卡收口为半高入口卡。
5. `论坛互动` 已与 `项目沟通` 形成同层入口框。
6. 头像、昵称、聊天摘要、重复竞标沟通信息已从消息楼入口区隐藏。
7. `进入项目沟通`、`回复我的`、`收到的赞`、`新关注` 保留。
8. 底部导航不变。
9. Day5 未修改 BFF / Server / OpenAPI / 数据库 / 接口契约 / 状态机。
10. 全量 Flutter analyze/test 仍有跨模块红灯，不得宣称全仓库通过。
