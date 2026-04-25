---
owner: Codex 总控
status: conditional_pass
purpose: >
  Submit the Day-8 stage gate checklist for the counterpart conversation
  container after Flutter implementation, tunnel verification, and regression.
layer: L0 SSOT
updated_at: 2026-04-24
based_on:
  - docs/04_frontend/counterpart_conversation_day6_day8_acceptance_report.md
  - docs/00_ssot/counterpart_conversation_day8_release_cutover_addendum.md
---

# 《对方主体会话容器 Day-8 阶段门禁核查表》

## 1. Passed Gates

- Day-6 标题权限 sheet gate：
  - passed
  - 标题点击先弹 `ProjectNameAccessPermissionSheet`。
- 独立权限大卡移除 gate：
  - passed
  - 项目详情页下方独立权限大卡已移除。
- 统一消息入口 gate：
  - passed
  - 消息楼一级展示对方主体会话容器。
- 项目分组 gate：
  - passed
  - 统一会话页按项目分组展示业务卡。
- 旧 carrier fallback gate：
  - passed
  - `名称查看申请` 旧详情 carrier 仍可进入。
- Flutter regression gate：
  - passed
  - `analyze` 与目标测试通过。
- live tunnel visual gate：
  - passed
  - 本地 macOS Flutter 通过 `127.0.0.1:8080` 连接阿里云 BFF 完成实际点击验证。
- project communication text gate：
  - passed
  - 统一项目沟通页可发送文字，点击刷新后仍可读回。
- bid fallback gate：
  - passed
  - 从统一项目沟通页点击 `进入竞标沟通` 可进入旧 `bid_thread` carrier。
- message card visual gate：
  - passed
  - 消息楼会话卡已隐藏内部业务 chip，改为头像、对方名称、昵称和摘要。

## 2. Failed Gates

- UAT signoff gate：
  - failed
  - 当前尚未取得用户 UAT 签字。
- production hard cutover gate：
  - failed
  - 当前不得删除旧入口或宣称主入口已最终切换。

## 3. Veto Gates

- 不得删除旧 `project_name_access_thread` detail route。
- 不得删除旧 `bid_thread` detail route。
- 不得让统一容器生成新的统一业务状态机。
- 不得跨项目合并审批、竞标、澄清、通知状态。
- 不得让任何业务动作丢失 `projectId`。
- 不得把裸 `curl` 未认证 `401` 误判为业务 route failure。

## 4. Go / No-Go Decision

- `Go` for：
  - 用户 UAT。
  - release candidate 观察。
  - 继续保留旧 carrier 的兼容发布。
  - 统一项目沟通页作为 UAT 主入口候选。
- `No-Go` for：
  - 生产主入口硬切。
  - 旧 carrier 删除。
  - 下线历史通知和深链 fallback。
  - 把 UAT candidate 误标为最终生产 cutover。

## 5. Next Stage Allowed

- 是否允许进入下一阶段：
  - `Yes, UAT only`
- 当前不允许进入：
  - `production hard cutover`
  - `old-carrier deletion`
  - `route-family cleanup`
