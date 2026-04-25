---
owner: Codex 总控
status: active
purpose: >
  Freeze the Day-8 release-note and cutover stance for the counterpart
  conversation container, preserving old truth carriers until UAT has passed.
layer: L0 SSOT
updated_at: 2026-04-24
target_schedule:
  - Day 8: 2026-05-07
  - Closeout: 2026-05-08
based_on:
  - docs/04_frontend/counterpart_conversation_day6_day8_acceptance_report.md
  - docs/00_ssot/counterpart_conversation_truth_freeze_addendum.md
  - docs/00_ssot/counterpart_conversation_route_table_addendum.md
  - docs/00_ssot/project_name_access_request_truth_freeze_addendum.md
---

# 《对方主体会话容器 Day-8 release note 与 cutover 口径》

## 1. Release Note

- 消息楼一级入口调整为对方主体会话容器。
- 一个对方主体只展示一个会话入口。
- 消息楼会话卡展示头像、对方主体名称、昵称和业务摘要。
- 消息楼会话卡不再展示 `对方主体 / 1 个项目 / 名称申请` 三个内部分类 chip。
- 统一会话详情页内部继续按 `projectId` 分项目展示。
- 统一项目沟通页支持文字聊天，当前只支持文字输入。
- 文字消息发送、读取、刷新继续锚定 `projectId` 和 `ProjectCommunicationThread`。
- 项目名称申请、竞标、澄清、通知动作继续锚定各自原真值。
- 旧 `project_name_access_thread`、`bid_thread` 只作为详情 carrier 和 fallback。
- `查看申请` 和 `进入竞标沟通` 在统一页内作为原真值动作入口，不生成统一业务状态机。
- 项目详情页标题 `项目名称需申请查看` 可点击打开权限 sheet。
- 申请查看、查看申请状态、刷新状态收口到权限 sheet。
- 项目详情页下方独立权限大卡下线。

## 2. Cutover Decision

- 当前 cutover 状态：
  - `No-Go for production primary-entry hard cutover`
- 当前允许：
  - 工程验收环境进入 UAT。
  - 统一会话入口作为项目沟通 UAT 主入口展示。
  - 旧 carrier 继续保留为详情和 fallback。
- 当前不允许：
  - 删除旧 `project_name_access_thread` detail route。
  - 删除旧 `bid_thread` detail route。
  - 删除旧澄清 / 通知 fallback。
  - 宣称 UAT 已通过。

## 3. Mandatory UAT Gates

- UAT 必须核验：
  - 一级消息楼一个对方主体只有一个会话入口。
  - 统一容器内按项目分组，不跨项目合并状态。
  - 每个业务动作都能追溯到 `projectId`。
  - 项目沟通页可发送文字消息。
  - 发送后刷新仍可读回文字消息。
  - 项目详情标题点击先弹权限 sheet。
  - 旧真值详情仍可回退打开。
- 上述任一项失败：
  - 不允许切主入口。
  - 不允许隐藏旧 carrier。
  - 不允许发布 release pass 结论。

## 4. Old Entry Exposure Policy

- 旧入口当前策略：
  - 保留 detail route。
  - 不作为消息楼一级主入口。
  - 可作为 fallback、深链、历史通知落点使用。
- 旧入口显式露出下线条件：
  - UAT 通过。
  - routeTarget telemetry 无 `actionKey` miss。
  - support 确认历史通知和深链可回退。
  - 产品确认统一入口文案可替代旧入口。

## 5. Rollback Policy

- 若统一消息入口出现阻断：
  - 保留旧 carrier route。
  - BFF 可回滚 `interactionType=counterpart_conversation` 的一级展示。
  - Flutter 旧 detail 页面无需回滚删除，因为本轮未删除。
- 若项目沟通文字聊天出现阻断：
  - 保留统一项目沟通页作为只读容器。
  - 临时关闭底部 composer 展示。
  - 继续允许 `查看申请`、`进入竞标沟通` fallback。
  - Server/BFF 可回滚到上一 release：
    - server previous symlink under `/srv/releases/server/*counterpart-conversation-r1a`
    - bff previous symlink under `/srv/releases/bff/*counterpart-conversation-r1a`
- 若项目详情 sheet 出现阻断：
  - 可临时恢复标题点击为 no-op。
  - 不允许恢复下方独立权限大卡作为长期方案。

## 6. Final Day-8 Ruling

- 工程验收：
  - passed
- 项目沟通文字聊天 actual click：
  - passed
- UAT：
  - pending
- 生产切主入口：
  - blocked until UAT pass
- 旧 carrier 删除：
  - blocked
- 是否把统一项目沟通页作为项目沟通主入口：
  - `Yes for UAT candidate`
  - `No for irreversible production hard cutover before UAT pass`
- 当前下一步：
  - 进入用户 UAT 与 release candidate 观察。
