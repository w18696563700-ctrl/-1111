---
title: Content Safety P0 Implementation Order Lock
status: frozen
owner: Codex Control
scope: docs-only
created_at: 2026-04-07
---

# 内容安全 P0 实施顺序锁定单

## 1. Purpose

本文件冻结内容安全 P0 五包的实施顺序，防止文书层一次性冻结被误读为代码层一次性实施。

## 2. Frozen Distinction

五包冻结顺序与五包实施顺序不是一回事。

- 文书层：可以一次性完成 P0 五包冻结。
- 实施层：必须按锁定顺序逐包放行。
- 复核层：每包必须独立复核，不得用后一包结果倒推前一包完成。

## 3. Locked Implementation Order

P0 实施顺序锁定为：

1. Profile Safety P0 + Safety Audit P0
2. Forum Report P0
3. Block P0
4. Admin Review P0
5. 联动复核

## 4. Order Rationale

### 1. Profile Safety P0 + Safety Audit P0 first

理由：

- 当前 `profile` 已有昵称 / 头像编辑入口，治理缺口已经影响真实用户资料展示。
- Safety Audit P0 是后续举报、审核、复核的底座。
- 若没有资料审核留痕，后续 Admin Review 只能做空台。

### 2. Forum Report P0 second

理由：

- forum 已有公开内容面，举报是 UGC app 的最低治理入口。
- 但 forum 当前发布仍是直接 `published`，因此 P0 只做 report，不在这一阶段强行重写完整 precheck。

### 3. Block P0 third

理由：

- block 依赖用户关系与互动边界，需要先明确可举报 / 可互动目标。
- 当前 messages 域尚未完整，因此 P0 只锁最小 block relation 与互动屏蔽边界，不做复杂私信治理。

### 4. Admin Review P0 fourth

理由：

- Admin 当前缺少内容安全审核台。
- 审核台必须基于 Profile Safety、Forum Report、Safety Audit 的最小真源输入建立。
- 不得先做一个无输入、无真源的空后台。

### 5. 联动复核 last

理由：

- 联动复核只能判断链路是否贯通。
- 联动复核不得替代任何子包实现。
- 联动复核不得替代独立结果校验。

## 5. Forbidden Reordering

禁止：

- 跳过 Profile Safety P0 直接做完整 Admin 后台。
- 跳过 Safety Audit P0 直接做处罚台。
- 跳过 Forum Report P0 直接做论坛 AI 审核。
- 跳过 Block P0 直接做私信复杂治理。
- 跳过独立复核直接进入联动发布。

## 6. Gate Result

### Passed Gates

- P0 五包实施顺序已冻结。
- 文书冻结与实施放行的区别已冻结。
- 联动复核必须最后执行已冻结。

### Failed Gates

- 当前没有任何 P0 实施包获得放行。

### Veto Gates

- 任一线程把五包冻结误读为五包同时实施，veto。
- 任一线程把 Admin Review P0 提前到 Profile Safety P0 + Safety Audit P0 之前实施，veto。

## 7. Next Unique Action

将该实施顺序作为五份 P0 子包冻结单的共同前置约束写入文书冻结线程输出。
