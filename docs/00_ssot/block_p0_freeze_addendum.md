---
title: Block P0 Freeze
status: frozen
owner: Document Freeze
scope: docs-only
created_at: 2026-04-07
---

# Block P0 冻结单

## A. 冻结对象

本文件冻结 `Block P0` 子包边界。

本包只覆盖最小用户拉黑关系与拉黑后的互动屏蔽边界，不进入完整私信治理。

## B. 本轮纳入项

| 能力编号 | 能力名称 | 当前冻结语义 |
| --- | --- | --- |
| CS-018 | 用户拉黑关系 | 建立用户对用户的最小 block relation 真相。 |
| CS-019 | 拉黑后互动屏蔽边界 | 冻结被拉黑后的最小互动限制边界。 |

## C. 本轮明确不纳入项

- 私信单条举报
- 私信硬规则拦截
- 消息列表预览治理
- 陌生人消息风控
- 群聊治理
- 会话级复杂状态机
- 完整处罚台
- 完整申诉台

## D. 不纳入但保留在母版中的项

| 能力编号 | 能力名称 | 保留阶段 |
| --- | --- | --- |
| CS-020 | 私信单条举报 | P1 |
| CS-021 | 私信硬规则拦截 | P2 |
| CS-022 | 消息列表预览治理 | P2 |
| CS-027 | 处罚动作体系 | P1 |
| CS-028 | 申诉工单体系 | P1 |

## E. 对应能力编号映射

本包直接承接：

- CS-018
- CS-019

本包引用但不实施：

- CS-020
- CS-021
- CS-022
- CS-027
- CS-028

## F. 当前依赖项

- 《内容安全 P0 docs-only bundle freeze》
- 《内容安全 P0 实施顺序锁定单》
- Safety Audit P0 冻结单
- Forum Report P0 冻结单中的可举报 / 可交互目标边界

## G. 当前禁止越界项

- 不得扩成完整私信治理。
- 不得新增完整 messages 状态机。
- 不得自动处罚被拉黑用户。
- 不得把拉黑关系放到 BFF 当真相。
- 不得把 block P0 变成用户封禁系统。

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

1. 后端线程承接 block relation 真相。
2. BFF 线程承接 app-facing block / unblock shaping。
3. 前端线程承接最小拉黑入口与屏蔽提示。
4. 结果校验线程独立复核。

## J. 当前验收入口条件

进入 implementation 前必须满足：

- CS-018 与 CS-019 已在追踪总表回写为已冻结。
- Safety Audit P0 已冻结。
- messages 复杂治理明确不在本轮。
- 总控复核允许进入 Block P0 implementation。

## K. 当前不允许进入实施的情形

任一条件成立则不得实施：

- messages 域边界被混入。
- 处罚 / 申诉体系被混入。
- 追踪总表未回写。
- 总控未输出子包冻结完成复核结论。
