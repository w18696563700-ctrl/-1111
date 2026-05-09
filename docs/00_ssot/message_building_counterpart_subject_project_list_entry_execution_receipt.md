---
owner: Codex 总控
status: current
layer: L0 SSOT
scope: messages_building_counterpart_subject_entry_execution_receipt
created_at: 2026-05-09
commit: 6ec9967
---

# 消息楼主体入口项目列表优先执行回执

## 1. Execution Target

本轮目标是修正消息楼项目沟通首页主体卡点击落点：

- 主体卡进入该主体项目列表。
- 项目列表内的“进入沟通”进入具体项目聊天。
- 铃铛通知 / 项目消息通知仍可直达具体项目聊天。

## 2. Final Decision

`PASS with Risk`

原因：

- Flutter 主体卡入口语义已修正并提交。
- SSOT reopening 已新增并登记。
- 定向 Flutter analyze 和 widget tests 通过。
- Computer Use 已验证主体卡进入项目列表，项目列表“进入沟通”进入具体聊天。
- 本轮未部署云端，因此不能把结果声明为 cloud runtime 已发布。

## 3. Implementation Record

提交：

- `6ec9967 fix mobile counterpart subject entry route`

提交文件：

- `apps/mobile/lib/features/messages/presentation/messages_page.dart`
- `apps/mobile/test/messages_instance_todo_test.dart`
- `docs/00_ssot/message_building_counterpart_subject_project_list_entry_reopening_addendum.md`
- `docs/00_ssot/source_of_truth_map.md`

## 4. Important Adjustment

原计划曾考虑主体卡只携带 `conversationId`。

实际只读核对发现：

- 当前 `CounterpartConversationConsumerLayer.loadDetail` 仍要求 `conversationId + projectId` 才能读取主体项目列表。
- 只携带 `conversationId` 会进入受控错误页。

因此最终冻结并实现为：

- 主体卡携带 `conversationId + projectId` 作为主体项目列表读取上下文。
- 主体卡不携带 `threadId`，避免自动进入具体聊天。
- 通知 deep link 仍携带 `conversationId + projectId + threadId`，保持具体聊天直达。

## 5. Verification Evidence

本轮执行过以下校验：

- `git diff --check`
- `cd apps/mobile && flutter analyze lib/features/messages/presentation/messages_page.dart test/messages_instance_todo_test.dart test/project_notification_preview_consumption_test.dart`
- `cd apps/mobile && flutter test test/messages_instance_todo_test.dart`
- `cd apps/mobile && flutter test test/project_notification_preview_consumption_test.dart`

结果：

- Flutter scoped analyze：通过。
- `messages_instance_todo_test.dart`：通过，`11/11`。
- `project_notification_preview_consumption_test.dart`：通过，`12/12`。

Computer Use 验证：

- 点击消息楼项目沟通主体卡后，进入“项目列表 / 共 15 个”。
- 在项目列表点击“进入沟通”后，进入具体项目聊天。

## 6. Boundary Confirmation

本轮未修改：

- BFF
- Server
- OpenAPI
- generated types
- 云端 runtime
- 支付、合同金额、服务费、论坛、相册、APNs / 推送

本轮未执行：

- push
- deploy
- cloud runtime switch

## 7. Remaining Risk

- 工作区仍存在其他线程脏改，本回执不覆盖这些文件。
- 未做云端 runtime 发布，因此线上环境是否包含本 commit 仍需后续部署门禁验证。
- 真实铃铛通知直达聊天没有可用未读样本做 Computer Use 点击，只由 routeTarget threadId 测试覆盖不回归。

## 8. Next Gate

如需进入下一步，建议使用：

`进入执行回执文书 commit 门禁，只提交本回执文书和 source_of_truth_map.md 登记，不混入其他线程脏改。`
