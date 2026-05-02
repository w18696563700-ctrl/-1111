---
owner: Codex 总控
status: accepted
purpose: >
  Record Day 4 validation receipt for the project communication workbench
  publisher/bidder role-split rework.
layer: L5 Frontend Validation Receipt
verification_scope: Flutter scoped test/analyze and macOS Computer Use visual check
inputs_canonical:
  - docs/00_ssot/project_communication_workbench_role_split_rework_day1_freeze_addendum.md
  - docs/04_frontend/project_communication_workbench_role_split_rework_day2_flutter_structure_addendum.md
evidence:
  - docs/00_ssot/evidence/20260502-project-communication-role-split-publisher.png
---

# 《项目沟通工作入口角色分流返工 Day 4 验收回执》

## 1. 总裁决

Day 4 结论为 `Conditional Pass`。

当前 Flutter-only 返工已完成：

- 发布方视角显示 3 个确认按钮。
- 竞标方视角显示 5 份资料入口。
- 底部聊天输入栏没有恢复 `确认` 主入口。
- 未修改 BFF / Server / contracts / 云端。

本回执不代表：

- 发布方三项确认已由 Server 持久化。
- `已确认` 绿色状态已经是生产业务真值。
- 竞标方五份资料已支持逐项确认。
- 云端已经部署本地 Flutter 改动。

## 2. 本轮范围

本轮包含：

- Day 1 返工冻结。
- Day 2 Flutter 施工图。
- Day 3 Flutter-only 角色分流实现。
- Day 4 scoped Flutter test / analyze。
- macOS App + Computer Use 视觉复验。

本轮不包含：

- BFF 修改。
- Server 修改。
- contracts 修改。
- 云端部署、重启、Nginx reload、数据库操作。
- POST / PUT / PATCH / DELETE 业务接口 smoke。

## 3. 实现摘要

发布方：

- `projectRelation == my_published`
- 显示 `确认事项`。
- 固定显示：
  - `报价确认`
  - `排期确认`
  - `工艺材质确认`
- 点击待确认项后仅在当前 Flutter 页面内显示绿色 `已确认`。

竞标方：

- `projectRelation == my_bid`
- 显示 `资料`。
- 固定显示：
  - `效果图`
  - `材质图`
  - `尺寸图`
  - `设备物料清单`
  - `服务清单`
- 有资料显示 `待查看`。
- 无资料显示 `未提交`。
- 不可读显示 `暂不可读`。

未知视角：

- 不展示三项确认。
- 不展示五份资料。
- 显示受控不可读提示。

## 4. 测试回执

命令：

```bash
cd apps/mobile && flutter test test/project_communication_five_material_confirmation_entry_test.dart test/counterpart_conversation_chat_test.dart test/project_attachment_prepublish_and_bid_materials_test.dart
```

结果：

- `27` tests passed.

覆盖：

- 发布方只显示三项确认。
- 发布方不显示五份资料。
- 发布方点击 `报价确认` 后显示 `已确认`。
- 竞标方只显示五份资料。
- 竞标方不显示三项确认。
- 竞标方读取失败受控显示 `资料状态暂不可读`。
- 底部输入栏不显示 `确认` 或 `发送确认卡`。
- 点击固定区不产生项目沟通消息 POST。

## 5. Analyze 回执

命令：

```bash
cd apps/mobile && flutter analyze lib/features/exhibition/presentation/exhibition_trade_pages.dart lib/features/exhibition/presentation/pages/counterpart_conversation_page.dart lib/features/exhibition/presentation/pages/counterpart_conversation_widgets.dart lib/features/exhibition/presentation/pages/counterpart_conversation_chat_widgets.dart lib/features/exhibition/presentation/pages/counterpart_conversation_material_confirmation_widgets.dart lib/features/exhibition/presentation/presentation_support/counterpart_conversation_material_confirmation_support.dart test/project_communication_five_material_confirmation_entry_test.dart test/counterpart_conversation_chat_test.dart test/project_attachment_prepublish_and_bid_materials_test.dart
```

结果：

- `No issues found`.

## 6. Computer Use 视觉回执

启动方式：

```bash
SMOKE_SKIP_TUNNEL=1 APP_INITIAL_ROUTE="/messages" ./apps/mobile/scripts/run_macos_exhibition_smoke.sh
```

运行边界：

- 本地 Flutter macOS App。
- BFF base URL: `http://127.0.0.1:8080/api/app`
- 复用既有隧道。
- 未执行云端写操作。

### 6.1 发布方视角

截图证据：

- `docs/00_ssot/evidence/20260502-project-communication-role-split-publisher.png`

观察结果：

- 页面显示 `确认事项`。
- 只显示 `报价确认 / 排期确认 / 工艺材质确认`。
- 未显示 `效果图 / 材质图 / 尺寸图 / 设备物料清单 / 服务清单`。
- 点击 `报价确认` 后，该按钮显示绿色 `已确认`。
- 底部输入栏未显示 `确认`。

### 6.2 竞标方视角

Computer Use 状态树观察结果：

- 页面显示 `资料`。
- 只显示 `效果图 / 材质图 / 尺寸图 / 设备物料清单 / 服务清单`。
- 未显示 `报价确认 / 排期确认 / 工艺材质确认`。
- 当前真实项目资料状态不可读时，各项显示 `暂不可读`。
- 底部输入栏未显示 `确认`。

竞标方截图归档状态：

- 截图保存时 macOS `mobile` 窗口句柄丢失，后续重启未恢复可抓取窗口。
- 因此本轮没有归档竞标方截图文件。
- 竞标方视觉由 Computer Use 状态树观察和 widget test 双重兜底。

## 7. 风险与边界

已确认风险：

- 发布方绿色 `已确认` 是当前 Flutter 页面内反馈态，不是 Server 持久化业务真值。
- 竞标方真实账号项目当前资料不可读，未覆盖真实 `待查看` 资料预览。
- Flutter Web target 不存在，本轮不能用 Browser Use 做网页验收。
- 当前工作区存在本任务外 BFF / Server / messages / shell 脏改，本轮未触碰、未清理。

## 8. 最终判断

当前最小闭环达到：

- 发布方不是五份资料。
- 竞标方不是三项确认。
- 旧三个入口保留。
- 工作台文字已压缩。
- 确认主入口未回到底部聊天框。
- 不改 BFF / Server / contracts / 云端。

若下一轮要求真实持久化绿色状态，必须回到 Gate 1，先冻结 contracts 和 Server 状态机。
