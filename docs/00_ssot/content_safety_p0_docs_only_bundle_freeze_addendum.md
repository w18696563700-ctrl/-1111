---
title: Content Safety P0 Docs-only Bundle Freeze
status: frozen
owner: Codex Control
scope: docs-only
created_at: 2026-04-07
---

# 内容安全 P0 docs-only bundle freeze

## 1. Scope

本文件冻结《内容安全治理母版 V1 控制包》进入 P0 docs-only bundle 的范围、排除项、禁止越界项和实施顺序约束。

本轮只做文书冻结，不做代码施工。

## 2. P0 Bundle Definition

P0 当前冻结为五个子包：

1. Profile Safety P0
2. Forum Report P0
3. Block P0
4. Admin Review P0
5. Safety Audit P0

五包可以在文书层一次性冻结，但不得一次性实施。

## 3. Included P0 Packages

### P0-1 Profile Safety P0

纳入项：

- CS-001 昵称硬规则拦截
- CS-002 头像基础文件校验
- CS-003 简介硬规则拦截
- CS-004 账号资料先审后显状态流
- CS-005 账号资料审核留痕
- CS-006 头像违规提示与拒绝原因回显

本包只允许围绕账号资料层建立最小安全状态流。

### P0-2 Forum Report P0

纳入项：

- CS-010 发帖举报入口
- CS-011 评论举报入口
- CS-012 举报工单真源与状态流
- CS-013 举报后台最小查看能力

本包只允许建立最小举报入口与举报工单真源。

不得把 forum 发布主链改成完整审核平台。

### P0-3 Block P0

纳入项：

- CS-018 用户拉黑关系
- CS-019 拉黑后互动屏蔽边界

本包只允许建立最小拉黑关系与互动屏蔽边界。

不得扩成完整私信治理。

### P0-4 Admin Review P0

纳入项：

- CS-023 最小审核任务队列
- CS-024 最小审核后台

本包只允许冻结最小审核台边界。

不得扩成完整处罚台、申诉台、运营后台或治理控制塔。

### P0-5 Safety Audit P0

纳入项：

- CS-025 审计日志
- CS-026 内容快照留存
- CS-031 敏感词 / 保留词规则库

本包作为横切底座，只允许服务 P0 最小安全链路。

## 4. Explicit Non-inclusions Retained in Master

以下能力不纳入 P0 runtime 实施，但必须继续保留在母版与追踪总表中：

- CS-007 头像 OCR 图中文字识别
- CS-008 头像二维码检测
- CS-009 头像 AI 风险识别
- CS-014 帖子发前 precheck
- CS-015 评论发前 precheck
- CS-016 帖子 AI 风险审核
- CS-017 评论 AI 风险审核
- CS-020 私信单条举报
- CS-021 私信硬规则拦截
- CS-022 消息列表预览治理
- CS-027 处罚动作体系
- CS-028 申诉工单体系
- CS-029 我的举报记录
- CS-030 我的申诉记录
- CS-032 用户违规累计分
- CS-033 存量内容复扫
- CS-034 AI 审核服务统一接入层

这些项目不得因本轮不实施而被删除。

## 5. Forbidden Scope

本 P0 docs-only bundle 禁止：

- 直接实现 backend / BFF / Flutter / Admin 代码
- 直接打开完整 AI 审核平台
- 直接把 AI 写成 P0 runtime 前提
- 直接进入完整处罚台
- 直接进入完整申诉台
- 直接进入复杂私信治理
- 直接重写 forum 发布状态机
- 直接进行 release-prep 或 launch approval
- 跳过独立复核
- 跳过能力追踪总表

## 6. Implementation Order Lock

P0 实施顺序锁定为：

1. Profile Safety P0 + Safety Audit P0
2. Forum Report P0
3. Block P0
4. Admin Review P0
5. 联动复核

冻结顺序与实施顺序不是一回事。

文书层可以一次性冻结五包；代码层必须按上述顺序分阶段放行。

## 7. Acceptance Principles

P0 任何能力点不得仅凭执行回执改为“已完成”。

必须满足：

- 文书冻结存在
- 能力追踪总表已登记
- 代码落地在允许边界内
- 独立复核确认无遗漏、无越界、无伪完成

## 8. Gate Result

### Passed Gates

- P0 五包边界已识别。
- P0 不纳入项已保留在母版。
- P0 实施顺序已锁定。
- 当前阶段仅为 docs-only freeze。

### Failed Gates

- 五份子包冻结单尚未由文书冻结线程完成。
- 后端 / BFF / 前端 / Admin 尚未获得开工许可。

### Veto Gates

- 若五包一次性实施，veto。
- 若跳过 Profile Safety P0 + Safety Audit P0 先做 Admin 全台，veto。
- 若把 AI 写成 P0 runtime gate，veto。
- 若把未纳入项默认删除，veto。

## 9. Next Unique Action

将 docs-only bundle freeze 与五份冻结单派给文书冻结线程先完成，在冻结单全部完成并经总控复核前，不允许任何实施线程开工。
