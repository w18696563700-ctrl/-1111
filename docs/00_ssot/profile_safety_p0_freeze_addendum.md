---
title: Profile Safety P0 Freeze
status: frozen
owner: Document Freeze
scope: docs-only
created_at: 2026-04-07
---

# Profile Safety P0 冻结单

## A. 冻结对象

本文件冻结 `Profile Safety P0` 子包边界。

本包只覆盖账号资料层的最小安全治理，不进入 forum、messages、Admin 全台、AI runtime、处罚台或申诉台。

## B. 本轮纳入项

| 能力编号 | 能力名称 | 当前冻结语义 |
| --- | --- | --- |
| CS-001 | 昵称硬规则拦截 | 对昵称提交执行 P0 rule-engine 拦截，至少覆盖联系方式、保留词、违法低俗明显词与异常字符。 |
| CS-002 | 头像基础文件校验 | 对头像提交执行文件类型、文件大小、已确认 FileAsset、图片 mime、当前用户归属等基础校验。 |
| CS-003 | 简介硬规则拦截 | 对简介提交执行 P0 rule-engine 拦截，至少覆盖联系方式、引流、保留词、违法低俗明显词。 |
| CS-004 | 账号资料先审后显状态流 | 采用 `旧值继续显示 / 新值待审 / 通过替换 / 拒绝给原因 / 可重提` 模型。 |
| CS-005 | 账号资料审核留痕 | 对提交、规则结果、人工结果、替换、拒绝、重提留痕。 |
| CS-006 | 头像违规提示与拒绝原因回显 | 用户端展示审核中、拒绝原因、重提入口，不把待审误写成已生效。 |

## C. 本轮明确不纳入项

- 头像 OCR 图中文字识别
- 头像二维码检测
- 头像 AI 风险识别
- 完整个人资料中心
- 个人实名
- 身份证上传
- 公司认证
- 处罚台
- 申诉台

## D. 不纳入但保留在母版中的项

| 能力编号 | 能力名称 | 保留阶段 |
| --- | --- | --- |
| CS-007 | 头像 OCR 图中文字识别 | P1 |
| CS-008 | 头像二维码检测 | P1 |
| CS-009 | 头像 AI 风险识别 | P1 |
| CS-027 | 处罚动作体系 | P1 |
| CS-028 | 申诉工单体系 | P1 |
| CS-030 | 我的申诉记录 | P2 |
| CS-032 | 用户违规累计分 | P1 |

## E. 对应能力编号映射

本包直接承接：

- CS-001
- CS-002
- CS-003
- CS-004
- CS-005
- CS-006

本包引用但不实施：

- CS-007
- CS-008
- CS-009
- CS-027
- CS-028
- CS-030
- CS-032

## F. 当前依赖项

- 《内容安全治理母版 V1 控制包定位单》
- 《内容安全 P0 docs-only bundle freeze》
- 《内容安全 P0 实施顺序锁定单》
- 《Profile Safety P0 状态机补充冻结单》
- 《内容安全 P0 运行时依赖裁决单》
- Safety Audit P0 冻结单

## G. 当前禁止越界项

- 不得把 AI 写成 P0 runtime 前提。
- 不得提交新头像后立即公开替换旧头像。
- 不得待审时隐藏旧昵称或旧头像。
- 不得拒绝后不给原因且不允许重提。
- 不得把永久封号作为 P0 自动动作。

## H. 当前不得触碰范围

当前冻结单不允许触碰：

- `apps/server/**`
- `apps/bff/**`
- `apps/mobile/**`
- `apps/admin/**`
- `docs/01_contracts/**`
- `docs/02_backend/**`
- `docs/03_bff/**`
- `docs/04_frontend/**`

## I. 当前下游承接线程

后续承接顺序：

1. 文书冻结线程继续输出 contracts/backend/BFF/frontend 细化冻结。
2. 后端线程在总控单独 dispatch 后承接 Server truth 与状态机。
3. BFF 线程在 Server truth 冻结后承接 app-facing shaping。
4. 前端线程在 BFF surface 冻结后承接 UI 状态展示。
5. 结果校验线程独立复核。

## J. 当前验收入口条件

进入 implementation 前必须满足：

- 本冻结单已登记到 source_of_truth_map。
- CS-001 至 CS-006 已在追踪总表回写为已冻结。
- Safety Audit P0 已完成冻结。
- Profile 状态机补充冻结被引用且未被改写。

## K. 当前不允许进入实施的情形

任一条件成立则不得实施：

- 五份 P0 子包冻结单未全部落盘。
- 追踪总表未回写。
- 总控未输出子包冻结完成复核结论。
- AI 被写成 P0 必需 runtime。
- Admin Review P0 被提前扩成完整后台。
