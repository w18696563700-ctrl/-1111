---
title: Forum Report P0 Freeze
status: frozen
owner: Document Freeze
scope: docs-only
created_at: 2026-04-07
---

# Forum Report P0 冻结单

## A. 冻结对象

本文件冻结 `Forum Report P0` 子包边界。

本包只覆盖论坛帖子 / 评论的最小举报入口、举报工单真源与最小后台查看前提，不重写 forum 发布主链。

## B. 本轮纳入项

| 能力编号 | 能力名称 | 当前冻结语义 |
| --- | --- | --- |
| CS-010 | 发帖举报入口 | 在帖子详情或可见帖子面提供受控举报入口。 |
| CS-011 | 评论举报入口 | 在评论 / 回复可见面提供受控举报入口。 |
| CS-012 | 举报工单真源与状态流 | Server 持有举报工单真相，BFF 只转发和塑形。 |
| CS-013 | 举报后台最小查看能力 | Admin Review P0 可最小查看举报工单，不做完整治理台。 |

## C. 本轮明确不纳入项

- 帖子发前 precheck
- 评论发前 precheck
- 帖子 / 评论 AI 风险审核
- 举报历史中心
- 自动隐藏目标内容
- 恶意举报处罚自动化
- 完整申诉流
- 完整处罚台

## D. 不纳入但保留在母版中的项

| 能力编号 | 能力名称 | 保留阶段 |
| --- | --- | --- |
| CS-014 | 帖子发前 precheck | P1 |
| CS-015 | 评论发前 precheck | P1 |
| CS-016 | 帖子 AI 风险审核 | P1 |
| CS-017 | 评论 AI 风险审核 | P1 |
| CS-029 | 我的举报记录 | P1 |
| CS-033 | 存量内容复扫 | P2 |
| CS-034 | AI 审核服务统一接入层 | P1 |

## E. 对应能力编号映射

本包直接承接：

- CS-010
- CS-011
- CS-012
- CS-013

本包引用但不实施：

- CS-014
- CS-015
- CS-016
- CS-017
- CS-029
- CS-033
- CS-034

## F. 当前依赖项

- 《内容安全 P0 docs-only bundle freeze》
- 《内容安全 P0 实施顺序锁定单》
- 《内容安全 P0 运行时依赖裁决单》
- Safety Audit P0 冻结单
- Admin Review P0 冻结单

## G. 当前禁止越界项

- 不得把一次举报直接等同为自动下架。
- 不得让 BFF 持有举报裁决真相。
- 不得把 forum report 扩成完整内容审核平台。
- 不得把 Forum Report P0 写成发前审核 precheck。
- 不得接入 AI 作为 P0 runtime 必需项。

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

1. 后端线程承接举报工单真源与状态流。
2. BFF 线程承接 app-facing report submit shaping。
3. 前端线程承接帖子 / 评论举报入口。
4. Admin Review P0 承接最小查看。
5. 结果校验线程独立复核举报链路。

## J. 当前验收入口条件

进入 implementation 前必须满足：

- CS-010 至 CS-013 已在追踪总表回写为已冻结。
- Safety Audit P0 明确可承接举报快照与审计日志。
- Admin Review P0 最小查看边界已冻结。
- 总控复核允许进入 Forum Report P0 implementation。

## K. 当前不允许进入实施的情形

任一条件成立则不得实施：

- Safety Audit P0 未冻结。
- Admin Review P0 未冻结。
- 追踪总表未回写。
- 总控未输出子包冻结完成复核结论。
