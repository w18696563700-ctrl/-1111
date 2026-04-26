---
owner: Codex 总控
status: active
purpose: >
  Submit the Day-1 stage gate checklist for the corrected counterpart
  conversation IA, deciding whether the project-sliced frontend implementation
  may start while BFF / Server field expansion remains gated.
layer: L0 SSOT
updated_at: 2026-04-26
based_on:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/counterpart_conversation_project_sliced_ia_correction_addendum.md
  - docs/04_frontend/counterpart_conversation_project_sliced_frontend_consumption_addendum.md
  - docs/00_ssot/counterpart_conversation_truth_freeze_addendum.md
  - docs/04_frontend/counterpart_conversation_frontend_consumption_freeze_addendum.md
---

# 《对方主体会话容器项目切片 Day-1 阶段门禁核查表》

## 1. Scope

- 当前对象：
  - 对方主体会话容器项目切片 IA 修订
- 当前阶段：
  - Day 1 文书冻结
- 本门禁用于判断：
  - 是否允许进入 Day 2 Flutter IA 实现
  - 是否允许扩展 BFF / Server 字段
  - 是否允许进入云上 UAT 或 release judgment
- 本门禁不代表：
  - 前端实现完成
  - BFF / Server 云上改造完成
  - computer use 联调完成
  - 双账号多项目 UAT 通过

## 2. Passed Gates

- 真源门禁：
  - passed
  - 已先补 L0 SSOT 修订冻结，再补 L5 frontend consumption 冻结。
- 目录洁癖门禁：
  - passed
  - 新增文书放入 `docs/00_ssot` 与 `docs/04_frontend`，未污染代码目录。
- 架构边界门禁：
  - passed
  - 仍在 `messages` building 内承接，没有新增第六栋楼。
- Flutter 只经 BFF 门禁：
  - passed
  - 文书继续禁止 Flutter direct-to-Server。
- 对方主体总框语义门禁：
  - passed
  - `CounterpartConversationContainer` 已冻结为项目入口容器，不承担聊天业务。
- 项目边界门禁：
  - passed
  - 聊天必须绑定 `projectId + threadId`。
- 无第二聊天真值门禁：
  - passed
  - 文书禁止用 `conversationId`、`counterpartOrganizationId` 或本地假 thread 承担聊天 truth。
- 前端体验门禁：
  - passed
  - 总框只显示项目列表，项目页才显示聊天和输入框。
- 数据与上传门禁：
  - passed
  - 相册仍绑定 `projectId + fileAssetId`，`objectKey` 不成为业务真值。
- 阶段控制门禁：
  - passed
  - 当前只冻结 Day 1 文书，没有跳入实现或云上发布判断。

## 3. Failed Or Deferred Gates

- BFF / Server 独立认证公司字段门禁：
  - deferred
  - 现有稳定字段只确认到 `displayName / avatarUrl / organizationId / role` 口径；若要真实展示 `昵称 + 认证公司`，必须另补 L2/L3/L4 字段冻结。
- Flutter implementation runtime gate：
  - failed
  - 当前尚未改造本地 Flutter 页面。
- cloud runtime gate：
  - failed
  - 当前未通过 `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198` 隧道做云上验证。
- dual-account multi-project UAT gate：
  - failed
  - 当前尚未验证同一对方主体下两个项目的消息隔离。
- computer use integration gate：
  - failed
  - 当前尚未进行浏览器或模拟器联调截图验收。
- release judgment gate：
  - failed
  - 当前不具备 release / cutover 证据。

## 4. Veto Gates

- 若总框页继续显示聊天记录或输入框：
  - veto
- 若总框页自动加载 project thread / messages / WebSocket：
  - veto
- 若聊天没有绑定 `projectId + threadId`：
  - veto
- 若用 `conversationId` 代替 `threadId`：
  - veto
- 若多个项目消息合并到一个对方主体总框：
  - veto
- 若 Flutter 伪造认证公司字段：
  - veto
- 若 Flutter direct-to-Server：
  - veto
- 若 BFF 拥有业务 truth 或第二状态机：
  - veto
- 若 Server truth 未冻结就改状态机：
  - veto
- 若订单状态卡或相册在总框页展开：
  - veto
- 若项目沟通页默认展开重型订单状态卡或相册列表，而不是按钮化入口：
  - veto

## 5. Stage Go / No-Go Decision

- Go for：
  - Day 2 Flutter IA implementation within the frozen boundary
  - 拆分总框项目列表态与项目沟通态
  - 移除总框页聊天记录和输入框
  - 项目沟通页按钮化承接申请 / 订单 / 相册
  - 项目聊天按 `projectId + threadId` 加载
- No-Go for：
  - BFF / Server projection 字段扩展，除非另补字段冻结
  - 云上 release judgment
  - 跳过双账号多项目 UAT
  - 在总框页保留聊天业务

## 6. Current Minimum Loop

- 当前最小闭环：
  1. 文书冻结已经完成
  2. 下一阶段只做本地 Flutter IA 纠偏
  3. BFF / Server 只通过既有云上接口验证，不默认本地修改
  4. 实现后再走 8080 隧道、双账号、多项目隔离验收

## 7. Reserved But Closed

- 保留但暂不开通：
  - generic DM
  - group chat
  - 图片聊天消息
  - 认证公司本地假字段
  - 跨项目统一聊天
  - release cutover

## 8. Expansion Slots

- 后续扩展位：
  - BFF / Server certified company projection
  - 项目相册独立受控页
  - 订单状态独立受控页
  - 项目级 unread summary
  - WebSocket 接收侧稳定化

## 9. Strategy Judgment

- 更稳：
  - Day 2 只按冻结 IA 做 Flutter 纠偏，Day 3 后再接云上双账号 UAT。
- 更省成本：
  - 不扩展 BFF / Server 字段，先用现有 `displayName / avatarUrl` 完成本地闭环。
- 更适合当前阶段：
  - 先消除总框混入聊天的架构错误，再决定是否补认证公司字段。
- 风险更大：
  - 继续在现有总框页面堆聊天、订单和相册。
  - 未经字段冻结直接改云上 BFF / Server。
  - 不做多项目隔离验收就判断完成。

## 10. Next Stage Allowed

- 是否允许下一阶段：
  - Yes
- 允许的下一阶段范围：
  - Day 2 Flutter IA implementation only
- 不允许的下一阶段范围：
  - BFF / Server field expansion without freeze
  - cloud release judgment
  - production cutover
