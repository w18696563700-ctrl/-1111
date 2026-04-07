---
title: Content Safety P0 Runtime Dependency Judgment
status: frozen
owner: Codex Control
scope: docs-only
created_at: 2026-04-07
---

# 内容安全 P0 运行时依赖裁决单

## 1. Purpose

本文件冻结内容安全 P0 runtime 允许依赖与禁止依赖，防止 AI 审核被误写成 P0 实施前提。

## 2. P0 Allowed Engine Types

P0 runtime 只允许以下审核引擎类型：

- `engine_type=rule`
- `engine_type=manual`

其中：

- `rule` 负责确定性硬规则拦截、保留词、联系方式、明显违规文本等。
- `manual` 负责最小人工复核、拒绝原因、通过 / 拒绝动作。

## 3. P0 Disallowed Runtime Dependency

P0 不允许把以下能力写成 runtime 前提：

- AI 文本审核
- AI 图片审核
- AI OCR 图中文字识别
- AI 自动封号
- 多模型交叉审核
- 自动处罚状态机
- 存量 AI 复扫

## 4. AI Reserved Carrier

AI 审核继续保留在母版与能力追踪总表中，但只作为 P1 reserved carrier：

- CS-009 头像 AI 风险识别
- CS-016 帖子 AI 风险审核
- CS-017 评论 AI 风险审核
- CS-034 AI 审核服务统一接入层

P0 可以预留字段，但不得要求 runtime 接入 AI 才能通过。

允许预留：

- `engine_type`
- `risk_score`
- `risk_labels`
- `raw_payload`

禁止：

- P0 依赖外部 AI 服务可用性
- P0 直接用 AI 结果做永久封号
- P0 将 AI 不可用视为阻断所有资料提交
- P0 将 AI 接入作为 Admin Review P0 前置

## 5. Permanent Suspension Rule

`permanent_suspend` 在 P0 只能作为母版保留动作，不得作为 P0 自动执行动作。

任何永久封禁必须等待后续 Governance P1/P2 对以下能力完成冻结：

- 处罚动作体系
- 申诉工单体系
- 审计证据留存
- 人工复核责任
- 恢复 / 撤销路径

## 6. Gate Result

### Passed Gates

- P0 runtime allowed engines 已冻结为 rule/manual。
- AI 已冻结为 P1 reserved carrier。
- 永久封号不得在 P0 自动执行已冻结。

### Failed Gates

- P0 具体 rule engine 规则库尚未冻结。
- P0 manual review 最小操作台尚未冻结。

### Veto Gates

- 若 P0 实施要求接入 AI 才能上线，veto。
- 若 P0 自动执行永久封号，veto。
- 若 P0 因 AI 不可用阻断 rule/manual 最小治理链，veto。

## 7. Next Unique Action

文书冻结线程必须在五份 P0 子包冻结单中写明：P0 runtime 只允许 `rule/manual`，AI 只保留为 P1 reserved carrier。
