---
owner: Codex 总控
status: recorded
purpose: >
  Record the bounded runtime data clearance performed on 2026-04-16 to empty
  the exhibition project showcase and directly related trading objects for
  focused feature testing, while preserving profile and enterprise-display
  data.
layer: L0 SSOT
decision_date_local: 2026-04-16
inputs_canonical:
  - AGENTS.md
  - apps/server/src/modules/project
  - apps/server/src/modules/bid
  - apps/server/src/modules/order
  - apps/server/src/modules/contract
  - apps/server/src/modules/milestone
  - apps/server/src/modules/inspection
  - apps/server/src/modules/rating
  - apps/server/src/modules/dispute
---

# 项目展示运行时数据清空执行回执

## 1. Intent

- 当前用户明确要求：
  - 清空 `项目展示` 中现有项目
  - 为后续功能测试提供更干净的运行环境
- 本次动作属于：
  - 运行时测试数据清理
  - 不是产品行为变更
  - 不是 schema 变更

## 2. Scope

- 已清空的 exhibition/trading 相关表：
  - `project`
  - `projects`
  - `project_attachments`
  - `project_clarifications`
  - `project_public_resources`
  - `project_publish_audit_log`
  - `bids`
  - `bid_awards`
  - `bid_seats`
  - `bid_private_threads`
  - `bid_thread_messages`
  - `bid_thread_confirmation_cards`
  - `orders`
  - `contracts`
  - `milestones`
  - `inspections`
  - `ratings`
  - `disputes`
- 已按业务类型清理：
  - `file_asset where business_type = 'project'`
  - `upload_session where business_type = 'project'`

- 明确保留：
  - `profile` 相关数据
  - `enterprise_display` 相关数据
  - 账号、认证、组织、会员等非项目测试对象

## 3. Before Counts

- 清理前主要计数：
  - `project = 34`
  - `projects = 76`
  - `project_attachments = 12`
  - `project_public_resources = 1`
  - `bids = 68`
  - `bid_awards = 3`
  - `bid_seats = 1`
  - `orders = 63`
  - `contracts = 62`
  - `milestones = 60`
  - `inspections = 38`
  - `ratings = 8`
  - `disputes = 24`
  - `project_publish_audit_log = 334`
  - `file_asset.business_type = 'project' -> 29`
  - `upload_session.business_type = 'project' -> 45`

## 4. Execution

- 执行方式：
  - 单事务 `TRUNCATE ... CASCADE`
  - 再按 `business_type = 'project'` 删除 `file_asset` 与 `upload_session`
- 目标：
  - 清空项目展示与直接关联交易对象
  - 避免遗留孤立文件资产或上传会话

## 5. After Counts

- 清理后已确认归零：
  - `project = 0`
  - `projects = 0`
  - `project_attachments = 0`
  - `project_clarifications = 0`
  - `project_public_resources = 0`
  - `bids = 0`
  - `bid_awards = 0`
  - `bid_seats = 0`
  - `bid_private_threads = 0`
  - `bid_thread_messages = 0`
  - `bid_thread_confirmation_cards = 0`
  - `orders = 0`
  - `contracts = 0`
  - `milestones = 0`
  - `inspections = 0`
  - `ratings = 0`
  - `disputes = 0`
  - `project_publish_audit_log = 0`

- 保留计数确认：
  - `file_asset` 仅剩：
    - `enterprise_display = 7`
    - `profile = 39`
  - `upload_session` 中 `project` 业务类型已清空
- 运行态回查：
  - `GET http://127.0.0.1:3001/server/projects`
  - 返回：
    - `items = []`
    - `total = 0`

## 6. Anti-misread Note

- 后续线程如果看到：
  - `项目展示为空`
  - `我的项目为空`
  - 项目相关交易对象为零
- 当前默认解释应为：
  - 用户于 `2026-04-16` 主动要求清空测试数据
  - 不是系统异常
  - 不是 migration 丢失
  - 不是读链路损坏

## 7. Conclusion

- 本轮项目展示运行时数据清空已完成。
- 当前环境适合继续进行更聚焦的功能测试。
